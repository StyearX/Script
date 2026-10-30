"""
Video to frame data converter.

Reads a video (mp4, webm, mkv, mov, gif, avi or a direct URL), shrinks it, reduces it to a
256 color palette and stores every frame as text. Frames that look almost the same as the
previous one are stored as small changes, so the output stays compact.

Requirements: ffmpeg and ffprobe on PATH, then `pip install numpy pillow`

Usage:
    python Animated.py input.mp4 output.lua
    python Animated.py input.mp4 output.lua --width 384 --fps 15 --tolerance 12

The output is a Lua file that returns:
    { Width, Height, FPS, Palette = { r, g, b, ... 768 numbers }, Frames = { "text", ... } }

Frame text is base64. The first byte of the decoded data selects the kind of frame:
    1  key frame, one palette index per pixel
    2  changes only, applied on top of the previous frame:
         0..127    skip (value + 1) pixels
         128..255  copy the next (value - 127) palette indices to the next pixels
"""

import argparse
import base64
import json
import subprocess
import sys

import numpy as np
from PIL import Image


def probe_size(source):
    result = subprocess.run(
        ["ffprobe", "-v", "error", "-select_streams", "v:0", "-show_entries", "stream=width,height", "-of", "json", source],
        capture_output=True,
        text=True,
        check=True,
    )
    stream = json.loads(result.stdout)["streams"][0]
    return stream["width"], stream["height"]


def read_frames(source, width, height, fps, max_seconds):
    command = ["ffmpeg", "-v", "error", "-i", source]
    if max_seconds:
        command += ["-t", str(max_seconds)]
    command += ["-vf", f"fps={fps},scale={width}:{height}:flags=lanczos", "-f", "rawvideo", "-pix_fmt", "rgb24", "-"]

    size = width * height * 3
    process = subprocess.Popen(command, stdout=subprocess.PIPE)
    frames = []
    while True:
        data = process.stdout.read(size)
        if len(data) < size:
            break
        frames.append(np.frombuffer(data, dtype=np.uint8).reshape(height, width, 3))
    process.wait()
    if not frames:
        sys.exit("No frames could be read from the input")
    return frames


def build_palette(frames, samples=400000):
    pixels = np.concatenate([frame.reshape(-1, 3) for frame in frames])
    if len(pixels) > samples:
        pixels = pixels[np.linspace(0, len(pixels) - 1, samples).astype(np.int64)]
    sample = Image.fromarray(pixels.reshape(1, -1, 3))
    reference = sample.quantize(colors=256, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    palette = reference.getpalette()[:768]
    palette += [0] * (768 - len(palette))
    return reference, np.array(palette, dtype=np.int32).reshape(256, 3)


def to_indices(frame, reference):
    mapped = Image.fromarray(frame).quantize(palette=reference, dither=Image.Dither.NONE)
    return np.asarray(mapped, dtype=np.uint8).reshape(-1)


def encode_changes(indices, changed):
    padded = np.concatenate(([0], changed.astype(np.int8), [0]))
    edges = np.flatnonzero(np.diff(padded))
    output = bytearray([2])
    cursor = 0
    for start, end in zip(edges[0::2], edges[1::2]):
        gap = int(start) - cursor
        while gap > 0:
            step = min(gap, 128)
            output.append(step - 1)
            gap -= step
        position = int(start)
        while position < end:
            step = min(int(end) - position, 128)
            output.append(127 + step)
            output += indices[position:position + step].tobytes()
            position += step
        cursor = int(end)
    return bytes(output)


def encode_frames(frames, reference, palette, tolerance):
    limit = tolerance * tolerance
    encoded = []
    state = None
    for frame in frames:
        indices = to_indices(frame, reference)
        key = bytes([1]) + indices.tobytes()
        data = key
        if state is not None:
            difference = palette[indices] - palette[state]
            changed = np.sum(difference * difference, axis=1) > limit
            candidate = encode_changes(indices, changed)
            if len(candidate) < len(key) * 0.9:
                data = candidate
                indices = np.where(changed, indices, state).astype(np.uint8)
        state = indices
        data += bytes((-len(data)) % 3)
        encoded.append(base64.b64encode(data).decode("ascii"))
    return encoded


def convert(source, width, fps, tolerance, max_seconds):
    source_width, source_height = probe_size(source)
    width = max(2, width)
    height = max(2, round(width * source_height / source_width))

    frames = read_frames(source, width, height, fps, max_seconds)
    reference, palette = build_palette(frames)
    encoded = encode_frames(frames, reference, palette, tolerance)

    size = sum(len(text) for text in encoded) / 1e6
    print(f"{width}x{height} at {fps} fps: {len(encoded)} frames, {len(encoded) / fps:.1f} s, {size:.2f} MB")

    numbers = ",".join(str(int(value)) for value in palette.reshape(-1))
    lines = ["return {", f"\tWidth = {width},", f"\tHeight = {height},", f"\tFPS = {fps},", f"\tPalette = {{{numbers}}},", "\tFrames = {"]
    lines += [f'\t\t"{text}",' for text in encoded]
    lines += ["\t},", "}", ""]
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Convert a video to frame data")
    parser.add_argument("input")
    parser.add_argument("output")
    parser.add_argument("--width", type=int, default=384, help="frame width, height follows the video ratio")
    parser.add_argument("--fps", type=int, default=15, help="frames per second of the result")
    parser.add_argument("--tolerance", type=float, default=12.0, help="color difference ignored between frames, higher is smaller")
    parser.add_argument("--max-seconds", type=float, default=None, help="only convert the first seconds")
    arguments = parser.parse_args()

    text = convert(arguments.input, arguments.width, arguments.fps, arguments.tolerance, arguments.max_seconds)
    with open(arguments.output, "w", encoding="utf-8") as file:
        file.write(text)
    print("written:", arguments.output)


if __name__ == "__main__":
    main()
