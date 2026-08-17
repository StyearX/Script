local InputService = game:GetService('UserInputService');
local TextService = game:GetService('TextService');
local CoreGui = game:GetService('CoreGui');
local Teams = game:GetService('Teams');
local Players = game:GetService('Players');
local RunService = game:GetService('RunService')
local TweenService = game:GetService('TweenService');
local RenderStepped = RunService.RenderStepped;
local LocalPlayer = Players.LocalPlayer;
local Mouse = LocalPlayer:GetMouse();
local ProtectGui = protectgui or (syn and syn.protect_gui) or (function() end);
local ScreenGui = Instance.new('ScreenGui');
ProtectGui(ScreenGui);
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
ScreenGui.Parent = (gethui and gethui()) or (get_hidden_gui and get_hidden_gui()) or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui");
local Toggles = {};
local Options = {};
getgenv().Toggles = Toggles;
getgenv().Options = Options;
local IconCache  = {}
local IconPending = {}
local IconURLs = {
    lucide    = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/lucide/dist/Icons.lua",
    gravity   = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/gravity/dist/Icons.lua",
    solar     = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/solar/dist/Icons.lua",
    sfsymbols = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/sfsymbols/dist/Icons.lua",
    craft     = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/craft/dist/Icons.lua",
    geist     = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/geist/dist/Icons.lua",
    hero      = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/hero/dist/Icons.lua",
    gmi       = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/GoogleMaterialIcons/dist/Icons.lua",
}
local function ResolveEntry(source, name)

    local icons    = (type(source) == "table" and source.Icons) and source.Icons or source
    local sprites  = (type(source) == "table" and source.Spritesheets) and source.Spritesheets or nil
    local entry = icons[name]
    if entry == nil then
        entry = icons[name:gsub("^[^%-]+%-", "")]
    end

    if entry == nil then return nil end
    if type(entry) == "string" then
        return { Image = entry, ImageRectOffset = Vector2.zero, ImageRectSize = Vector2.zero }
    elseif type(entry) == "table" then
        local img = entry.Image
        if sprites and type(img) == "number" then
            img = sprites[tostring(img)] or sprites[img] or img
        end

        return {
            Image           = tostring(img or ""),
            ImageRectOffset = entry.ImageRectPosition or entry.ImageRectOffset or Vector2.zero,
            ImageRectSize   = entry.ImageRectSize or Vector2.zero,
        }
    end

    return nil
end

local function ApplyIconData(label, data)
    if not label or not data then return end
    label.Image           = data.Image
    label.ImageRectOffset = data.ImageRectOffset
    label.ImageRectSize   = data.ImageRectSize
end

local function LoadIconPack(prefix)
    if IconCache[prefix] ~= nil then return end
    IconCache[prefix] = false
    local url = IconURLs[prefix]
    if not url then
        warn("[Icons] Unknown icon pack: '" .. prefix .. "'")
        IconPending[prefix] = nil
        return
    end

    task.spawn(function()
        local ok, result = pcall(function()
            return loadstring(game:HttpGet(url, true))()
        end)
        if ok and result then
            IconCache[prefix] = result
        else
            warn("[Icons] Failed to load pack '" .. prefix .. "': " .. tostring(result))
            IconCache[prefix] = false
        end

        local pending = IconPending[prefix]
        if pending then
            IconPending[prefix] = nil
            for _, entry in ipairs(pending) do
                local label, iconKey, name = entry[1], entry[2], entry[3]
                if label and label.Parent then
                    if IconCache[prefix] and IconCache[prefix] ~= false then
                        local data = ResolveEntry(IconCache[prefix], name)
                        ApplyIconData(label, data)
                    end
                end
            end
        end
    end)
end

local Icons = {}
function Icons.GetIcon(key)

    if not key or key == "" then return nil end
    local prefix, name = key:match("^(.-)%/(.+)$")
    if not prefix then return nil end
    local src = IconCache[prefix]
    if not src then return nil end
    if src == false then return nil end
    return ResolveEntry(src, name)
end

local function ApplyIcon(label, iconKey)
    if not label or not iconKey or iconKey == "" then return end
    local prefix, name = iconKey:match("^(.-)%/(.+)$")
    if not prefix then return end
    local src = IconCache[prefix]
    if src and src ~= false then
        local data = ResolveEntry(src, name)
        ApplyIconData(label, data)
    elseif src == false then
        if not IconPending[prefix] then IconPending[prefix] = {} end
        table.insert(IconPending[prefix], {label, iconKey, name})
    else
        IconPending[prefix] = { {label, iconKey, name} }
        LoadIconPack(prefix)
    end
end

local function IsClick(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
end

local ActiveTouches = {}

InputService.TouchStarted:Connect(function(touch)
    ActiveTouches[touch] = Vector2.new(touch.Position.X, touch.Position.Y)
end)
InputService.TouchMoved:Connect(function(touch)
    if ActiveTouches[touch] then
        ActiveTouches[touch] = Vector2.new(touch.Position.X, touch.Position.Y)
    end
end)
InputService.TouchEnded:Connect(function(touch)
    ActiveTouches[touch] = nil
end)

local function IsHeld()
    if InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then return true end
    for _ in next, ActiveTouches do return true end
    return false
end

local function GetCursorPos()
    local mouse = InputService:GetMouseLocation()
    if mouse.X ~= 0 or mouse.Y ~= 0 then return mouse end
    for _, pos in next, ActiveTouches do return pos end
    return Vector2.zero
end

local Library = {
    Registry = {};
    RegistryMap = {};
    HudRegistry = {};
    FontColor = Color3.fromRGB(255, 255, 255);
    MainColor = Color3.fromRGB(28, 28, 28);
    BackgroundColor = Color3.fromRGB(20, 20, 20);
    AccentColor = Color3.fromRGB(0, 85, 255);
    OutlineColor = Color3.fromRGB(50, 50, 50);
    RiskColor = Color3.fromRGB(255, 50, 50),
    Black = Color3.new(0, 0, 0);
    Font = Enum.Font.Gotham,
    OpenedFrames = {};
    DependencyBoxes = {};
    Signals = {};
    ScreenGui = ScreenGui;
    Icons = Icons;
};
function Library:SetFont(newFont)

    if typeof(newFont) == 'string' then
        newFont = Enum.Font[newFont] or Library.Font
    end

    if typeof(newFont) ~= 'EnumItem' then return end
    Library.Font = newFont
    if Library.ScreenGui then
        for _, inst in ipairs(Library.ScreenGui:GetDescendants()) do
            if inst:IsA("TextLabel") or inst:IsA("TextBox") or inst:IsA("TextButton") then
                pcall(function()
                    inst.Font = newFont
                end)
            end
        end
    end
end;

local RainbowStep = 0
local Hue = 0
table.insert(Library.Signals, RenderStepped:Connect(function(Delta)
    RainbowStep = RainbowStep + Delta
    if RainbowStep >= (1 / 60) then
        RainbowStep = 0
        Hue = Hue + (1 / 400);
        if Hue > 1 then
            Hue = 0;
        end;

        Library.CurrentRainbowHue = Hue;
        Library.CurrentRainbowColor = Color3.fromHSV(Hue, 0.8, 1);
    end
end))
local function GetPlayersString()

    local PlayerList = Players:GetPlayers();
    for i = 1, #PlayerList do
        PlayerList[i] = PlayerList[i].Name;
    end;

    table.sort(PlayerList, function(str1, str2) return str1 < str2 end);
    return PlayerList;
end;

local function GetTeamsString()
    local TeamList = Teams:GetTeams();
    for i = 1, #TeamList do
        TeamList[i] = TeamList[i].Name;
    end;

    table.sort(TeamList, function(str1, str2) return str1 < str2 end);
    return TeamList;
end;

function Library:SafeCallback(f, ...)
    if (not f) then
        return;
    end;

    if not Library.NotifyOnError then
        return f(...);
    end;

    local success, event = pcall(f, ...);
    if not success then
        local _, i = event:find(":%d+: ");
        if not i then
            return Library:Notify(event);
        end;

        return Library:Notify(event:sub(i + 1), 3);
    end;
end;

function Library:AttemptSave()
    if Library.SaveManager then
        Library.SaveManager:Save();
    end;
end;

function Library:Create(Class, Properties)
    local _Instance = Class;
    if type(Class) == 'string' then
        _Instance = Instance.new(Class);
    end;

    for Property, Value in next, Properties do
        _Instance[Property] = Value;
    end;

    return _Instance;
end;

function Library:ApplyTextStroke(Inst)
end;

function Library:CreateLabel(Properties, IsHud)
    local _Instance = Library:Create('TextLabel', {
        BackgroundTransparency = 1;
        Font = Library.Font;
        TextColor3 = Library.FontColor;
        TextSize = 16;
        TextStrokeTransparency = 1;
    });
    Library:ApplyTextStroke(_Instance);
    Library:AddToRegistry(_Instance, {
        TextColor3 = 'FontColor';
    }, IsHud);
    return Library:Create(_Instance, Properties);
end;

function Library:MakeDraggable(Instance, Cutoff)
    Instance.Active = true
    local Dragging = false
    local DragOffset = Vector2.zero
    local DragTouch = nil
    local TouchDragging = false

    local function StartDrag(inputPos)
        local absPos = Instance.AbsolutePosition
        local relY = inputPos.Y - absPos.Y
        if relY < 0 or relY > (Cutoff or math.huge) then return end
        if Dragging then return end
        Dragging = true
        DragOffset = Vector2.new(
            inputPos.X - absPos.X - (Instance.AbsoluteSize.X * Instance.AnchorPoint.X),
            inputPos.Y - absPos.Y - (Instance.AbsoluteSize.Y * Instance.AnchorPoint.Y)
        )
        while IsHeld() or TouchDragging do
            local pos = DragTouch and ActiveTouches[DragTouch] or GetCursorPos()
            if not pos then break end
            Instance.Position = UDim2.fromOffset(
                pos.X - DragOffset.X,
                pos.Y - DragOffset.Y
            )
            RenderStepped:Wait()
        end
        DragTouch = nil
        TouchDragging = false
        Dragging = false
    end

    Instance.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            StartDrag(InputService:GetMouseLocation())
        elseif Input.UserInputType == Enum.UserInputType.Touch then
            DragTouch = Input
            TouchDragging = true
            task.spawn(StartDrag, Vector2.new(Input.Position.X, Input.Position.Y))
        end
    end)

    Instance.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.Touch and Input == DragTouch then
            TouchDragging = false
        end
    end)
end

function Library:AddToolTip(InfoStr, HoverInstance)
    local X, Y = Library:GetTextBounds(InfoStr, Library.Font, 14);
    local Tooltip = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor,
        BorderColor3 = Library.OutlineColor,
        Size = UDim2.fromOffset(X + 5, Y + 4),
        ZIndex = 100,
        Parent = Library.ScreenGui,
        Visible = false,
    })
    local Label = Library:CreateLabel({
        Position = UDim2.fromOffset(3, 1),
        Size = UDim2.fromOffset(X, Y);
        TextSize = 14;
        Text = InfoStr,
        TextColor3 = Library.FontColor,
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = Tooltip.ZIndex + 1,
        Parent = Tooltip;
    });
    Library:AddToRegistry(Tooltip, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    });
    Library:AddToRegistry(Label, {
        TextColor3 = 'FontColor',
    });
    local IsHovering = false
    HoverInstance.MouseEnter:Connect(function()
        if Library:MouseIsOverOpenedFrame() then
            return
        end

        IsHovering = true
        local tp = InputService:GetMouseLocation();
        Tooltip.Position = UDim2.fromOffset(tp.X + 15, tp.Y + 12)
        Tooltip.Visible = true
        while IsHovering do
            RunService.Heartbeat:Wait()
            local tp2 = InputService:GetMouseLocation();
            Tooltip.Position = UDim2.fromOffset(tp2.X + 15, tp2.Y + 12)
        end
    end)
    HoverInstance.MouseLeave:Connect(function()
        IsHovering = false
        Tooltip.Visible = false
    end)
end

function Library:OnHighlight(HighlightInstance, Instance, Properties, PropertiesDefault)
    HighlightInstance.MouseEnter:Connect(function()
        local Reg = Library.RegistryMap[Instance];
        for Property, ColorIdx in next, Properties do
            Instance[Property] = Library[ColorIdx] or ColorIdx;
            if Reg and Reg.Properties[Property] then
                Reg.Properties[Property] = ColorIdx;
            end;
        end;
    end)
    HighlightInstance.MouseLeave:Connect(function()
        local Reg = Library.RegistryMap[Instance];
        for Property, ColorIdx in next, PropertiesDefault do
            Instance[Property] = Library[ColorIdx] or ColorIdx;
            if Reg and Reg.Properties[Property] then
                Reg.Properties[Property] = ColorIdx;
            end;
        end;
    end)
end;

function Library:MouseIsOverOpenedFrame()
    local pos = GetCursorPos();
    for Frame, _ in next, Library.OpenedFrames do
        local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;
        if pos.X >= AbsPos.X and pos.X <= AbsPos.X + AbsSize.X
            and pos.Y >= AbsPos.Y and pos.Y <= AbsPos.Y + AbsSize.Y then
            return true;
        end;
    end;
end;

function Library:IsMouseOverFrame(Frame)
    local pos = GetCursorPos();
    local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;
    if pos.X >= AbsPos.X and pos.X <= AbsPos.X + AbsSize.X
        and pos.Y >= AbsPos.Y and pos.Y <= AbsPos.Y + AbsSize.Y then
        return true;
    end;
end;

function Library:UpdateDependencyBoxes()
    for _, Depbox in next, Library.DependencyBoxes do
        Depbox:Update();
    end;
end;

function Library:MapValue(Value, MinA, MaxA, MinB, MaxB)
    return (1 - ((Value - MinA) / (MaxA - MinA))) * MinB + ((Value - MinA) / (MaxA - MinA)) * MaxB;
end;

function Library:GetTextBounds(Text, Font, Size, Resolution)
    local Bounds = TextService:GetTextSize(Text, Size, Font, Resolution or Vector2.new(1920, 1080))
    return Bounds.X, Bounds.Y
end;

function Library:GetDarkerColor(Color)
    local H, S, V = Color3.toHSV(Color);
    return Color3.fromHSV(H, S, V / 1.5);
end;

Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor);
function Library:AddToRegistry(Instance, Properties, IsHud)

    local Idx = #Library.Registry + 1;
    local Data = {
        Instance = Instance;
        Properties = Properties;
        Idx = Idx;
    };
    table.insert(Library.Registry, Data);
    Library.RegistryMap[Instance] = Data;
    if IsHud then
        table.insert(Library.HudRegistry, Data);
    end;
end;

function Library:RemoveFromRegistry(Instance)
    local Data = Library.RegistryMap[Instance];
    if Data then
        for Idx = #Library.Registry, 1, -1 do
            if Library.Registry[Idx] == Data then
                table.remove(Library.Registry, Idx);
            end;
        end;

        for Idx = #Library.HudRegistry, 1, -1 do
            if Library.HudRegistry[Idx] == Data then
                table.remove(Library.HudRegistry, Idx);
            end;
        end;

        Library.RegistryMap[Instance] = nil;
    end;
end;

function Library:UpdateColorsUsingRegistry()
    for Idx, Object in next, Library.Registry do
        for Property, ColorIdx in next, Object.Properties do
            if type(ColorIdx) == 'string' then
                Object.Instance[Property] = Library[ColorIdx];
            elseif type(ColorIdx) == 'function' then
                Object.Instance[Property] = ColorIdx()
            end
        end;
    end;
end;

function Library:GiveSignal(Signal)
    table.insert(Library.Signals, Signal)
end

function Library:Unload()
    for Idx = #Library.Signals, 1, -1 do
        local Connection = table.remove(Library.Signals, Idx)
        Connection:Disconnect()
    end

    if Library.OnUnload then
        Library.OnUnload()
    end

    ScreenGui:Destroy()
end

function Library:OnUnload(Callback)
    Library.OnUnload = Callback
end

Library:GiveSignal(ScreenGui.DescendantRemoving:Connect(function(Instance)
    if Library.RegistryMap[Instance] then
        Library:RemoveFromRegistry(Instance);
    end;
end))
local BaseAddons = {};
do

    local Funcs = {};
    function Funcs:AddColorPicker(Idx, Info)

        local ToggleLabel = self.TextLabel;
        assert(Info.Default, 'AddColorPicker: Missing default value.');
        local ColorPicker = {
            Value = Info.Default;
            Transparency = Info.Transparency or 0;
            Type = 'ColorPicker';
            Title = type(Info.Title) == 'string' and Info.Title or 'Color picker',
            Callback = Info.Callback or function(Color) end;
        };
        function ColorPicker:SetHSVFromRGB(Color)

            local H, S, V = Color3.toHSV(Color);
            ColorPicker.Hue = H;
            ColorPicker.Sat = S;
            ColorPicker.Vib = V;
        end;

        ColorPicker:SetHSVFromRGB(ColorPicker.Value);
        local DisplayFrame = Library:Create('Frame', {
            BackgroundColor3 = ColorPicker.Value;
            BorderColor3 = Library:GetDarkerColor(ColorPicker.Value);
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(0, 28, 0, 14);
            ZIndex = 6;
            Parent = ToggleLabel;
        });
        local CheckerFrame = Library:Create('ImageLabel', {
            BorderSizePixel = 0;
            Size = UDim2.new(0, 27, 0, 13);
            ZIndex = 5;
            Image = 'http://www.roblox.com/asset/?id=12977615774';
            Visible = not not Info.Transparency;
            Parent = DisplayFrame;
        });
        local PickerFrameOuter = Library:Create('Frame', {
            Name = 'Color';
            BackgroundColor3 = Color3.new(1, 1, 1);
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18),
            Size = UDim2.fromOffset(230, Info.Transparency and 271 or 253);
            Visible = false;
            ZIndex = 15;
            Parent = ScreenGui,
        });
        DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
            PickerFrameOuter.Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18);
        end)
        local PickerFrameInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 16;
            Parent = PickerFrameOuter;
        });
        local Highlight = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 0, 2);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });
        local SatVibMapOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 4, 0, 25);
            Size = UDim2.new(0, 200, 0, 200);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });
        local SatVibMapInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Parent = SatVibMapOuter;
        });
        local SatVibMap = Library:Create('ImageLabel', {
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Image = 'rbxassetid://4155801252';
            Parent = SatVibMapInner;
        });
        local CursorOuter = Library:Create('ImageLabel', {
            AnchorPoint = Vector2.new(0.5, 0.5);
            Size = UDim2.new(0, 6, 0, 6);
            BackgroundTransparency = 1;
            Image = 'http://www.roblox.com/asset/?id=9619665977';
            ImageColor3 = Color3.new(0, 0, 0);
            ZIndex = 19;
            Parent = SatVibMap;
        });
        local CursorInner = Library:Create('ImageLabel', {
            Size = UDim2.new(0, CursorOuter.Size.X.Offset - 2, 0, CursorOuter.Size.Y.Offset - 2);
            Position = UDim2.new(0, 1, 0, 1);
            BackgroundTransparency = 1;
            Image = 'http://www.roblox.com/asset/?id=9619665977';
            ZIndex = 20;
            Parent = CursorOuter;
        })
        local HueSelectorOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 208, 0, 25);
            Size = UDim2.new(0, 15, 0, 200);
            ZIndex = 17;
            Parent = PickerFrameInner;
        });
        local HueSelectorInner = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(1, 1, 1);
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18;
            Parent = HueSelectorOuter;
        });
        local HueCursor = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(1, 1, 1);
            AnchorPoint = Vector2.new(0, 0.5);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, 0, 0, 1);
            ZIndex = 18;
            Parent = HueSelectorInner;
        });
        local HueBoxOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.fromOffset(4, 228),
            Size = UDim2.new(0.5, -6, 0, 20),
            ZIndex = 18,
            Parent = PickerFrameInner;
        });
        local HueBoxInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 18,
            Parent = HueBoxOuter;
        });
        Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
            });
            Rotation = 90;
            Parent = HueBoxInner;
        });
        local HueBox = Library:Create('TextBox', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -5, 1, 0);
            Font = Library.Font;
            PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
            PlaceholderText = 'Hex color',
            Text = '#FFFFFF',
            TextColor3 = Library.FontColor;
            TextSize = 14;
            TextStrokeTransparency = 0;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 20,
            Parent = HueBoxInner;
        });
        Library:ApplyTextStroke(HueBox);
        local RgbBoxBase = Library:Create(HueBoxOuter:Clone(), {
            Position = UDim2.new(0.5, 2, 0, 228),
            Size = UDim2.new(0.5, -6, 0, 20),
            Parent = PickerFrameInner
        });
        local RgbBox = Library:Create(RgbBoxBase.Frame:FindFirstChild('TextBox'), {
            Text = '255, 255, 255',
            PlaceholderText = 'RGB color',
            TextColor3 = Library.FontColor
        });
        local TransparencyBoxOuter, TransparencyBoxInner, TransparencyCursor;
        if Info.Transparency then
            TransparencyBoxOuter = Library:Create('Frame', {
                BorderColor3 = Color3.new(0, 0, 0);
                Position = UDim2.fromOffset(4, 251);
                Size = UDim2.new(1, -8, 0, 15);
                ZIndex = 19;
                Parent = PickerFrameInner;
            });
            TransparencyBoxInner = Library:Create('Frame', {
                BackgroundColor3 = ColorPicker.Value;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 19;
                Parent = TransparencyBoxOuter;
            });
            Library:AddToRegistry(TransparencyBoxInner, { BorderColor3 = 'OutlineColor' });
            Library:Create('ImageLabel', {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 1, 0);
                Image = 'http://www.roblox.com/asset/?id=12978095818';
                ZIndex = 20;
                Parent = TransparencyBoxInner;
            });
            TransparencyCursor = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(1, 1, 1);
                AnchorPoint = Vector2.new(0.5, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(0, 1, 1, 0);
                ZIndex = 21;
                Parent = TransparencyBoxInner;
            });
        end;

        local DisplayLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 0, 14);
            Position = UDim2.fromOffset(5, 5);
            TextXAlignment = Enum.TextXAlignment.Left;
            TextSize = 14;
            Text = ColorPicker.Title,
            TextWrapped = false;
            ZIndex = 16;
            Parent = PickerFrameInner;
        });
        local ContextMenu = {}
        do

            ContextMenu.Options = {}
            ContextMenu.Container = Library:Create('Frame', {
                BorderColor3 = Color3.new(),
                ZIndex = 14,
                Visible = false,
                Parent = ScreenGui
            })
            ContextMenu.Inner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.fromScale(1, 1);
                ZIndex = 15;
                Parent = ContextMenu.Container;
            });
            Library:Create('UIListLayout', {
                Name = 'Layout',
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = ContextMenu.Inner;
            });
            Library:Create('UIPadding', {
                Name = 'Padding',
                PaddingLeft = UDim.new(0, 4),
                Parent = ContextMenu.Inner,
            });
            local function updateMenuPosition()

                ContextMenu.Container.Position = UDim2.fromOffset(
                    (DisplayFrame.AbsolutePosition.X + DisplayFrame.AbsoluteSize.X) + 4,
                    DisplayFrame.AbsolutePosition.Y + 1
                )
            end

            local function updateMenuSize()
                local menuWidth = 60
                for i, label in next, ContextMenu.Inner:GetChildren() do
                    if label:IsA('TextLabel') then
                        menuWidth = math.max(menuWidth, label.TextBounds.X)
                    end
                end

                ContextMenu.Container.Size = UDim2.fromOffset(
                    menuWidth + 8,
                    ContextMenu.Inner.Layout.AbsoluteContentSize.Y + 4
                )
            end

            DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(updateMenuPosition)
            ContextMenu.Inner.Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(updateMenuSize)
            task.spawn(updateMenuPosition)
            task.spawn(updateMenuSize)
            Library:AddToRegistry(ContextMenu.Inner, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            });
            function ContextMenu:Show()

                self.Container.Visible = true
            end

            function ContextMenu:Hide()
                self.Container.Visible = false
            end

            function ContextMenu:AddOption(Str, Callback)
                if type(Callback) ~= 'function' then
                    Callback = function() end
                end

                local Button = Library:CreateLabel({
                    Active = false;
                    Size = UDim2.new(1, 0, 0, 15);
                    TextSize = 13;
                    Text = Str;
                    ZIndex = 16;
                    Parent = self.Inner;
                    TextXAlignment = Enum.TextXAlignment.Left,
                });
                Library:OnHighlight(Button, Button,
                    { TextColor3 = 'AccentColor' },
                    { TextColor3 = 'FontColor' }
                );
                Button.InputBegan:Connect(function(Input)
                    if not IsClick(Input) then return end
                    Callback()
                end)
            end

            ContextMenu:AddOption('Copy color', function()
                Library.ColorClipboard = ColorPicker.Value
                Library:Notify('Copied color!', 2)
            end)
            ContextMenu:AddOption('Paste color', function()
                if not Library.ColorClipboard then
                    return Library:Notify('You have not copied a color!', 2)
                end

                ColorPicker:SetValueRGB(Library.ColorClipboard)
            end)
            ContextMenu:AddOption('Copy HEX', function()
                pcall(setclipboard, ColorPicker.Value:ToHex())
                Library:Notify('Copied hex code to clipboard!', 2)
            end)
            ContextMenu:AddOption('Copy RGB', function()
                pcall(setclipboard, table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', '))
                Library:Notify('Copied RGB values to clipboard!', 2)
            end)
        end

        Library:AddToRegistry(PickerFrameInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor'; });
        Library:AddToRegistry(Highlight, { BackgroundColor3 = 'AccentColor'; });
        Library:AddToRegistry(SatVibMapInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor'; });
        Library:AddToRegistry(HueBoxInner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
        Library:AddToRegistry(RgbBoxBase.Frame, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
        Library:AddToRegistry(RgbBox, { TextColor3 = 'FontColor', });
        Library:AddToRegistry(HueBox, { TextColor3 = 'FontColor', });
        local SequenceTable = {};
        for Hue = 0, 1, 0.1 do
            table.insert(SequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)));
        end;

        local HueSelectorGradient = Library:Create('UIGradient', {
            Color = ColorSequence.new(SequenceTable);
            Rotation = 90;
            Parent = HueSelectorInner;
        });
        HueBox.FocusLost:Connect(function(enter)
            if enter then
                local success, result = pcall(Color3.fromHex, HueBox.Text)
                if success and typeof(result) == 'Color3' then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(result)
                end
            end

            ColorPicker:Display()
        end)
        RgbBox.FocusLost:Connect(function(enter)
            if enter then
                local r, g, b = RgbBox.Text:match('(%d+),%s*(%d+),%s*(%d+)')
                if r and g and b then
                    ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(Color3.fromRGB(r, g, b))
                end
            end

            ColorPicker:Display()
        end)
        function ColorPicker:Display()

            ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib);
            SatVibMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1);
            Library:Create(DisplayFrame, {
                BackgroundColor3 = ColorPicker.Value;
                BackgroundTransparency = ColorPicker.Transparency;
                BorderColor3 = Library:GetDarkerColor(ColorPicker.Value);
            });
            if TransparencyBoxInner then
                TransparencyBoxInner.BackgroundColor3 = ColorPicker.Value;
                TransparencyCursor.Position = UDim2.new(1 - ColorPicker.Transparency, 0, 0, 0);
            end;

            CursorOuter.Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0);
            HueCursor.Position = UDim2.new(0, 0, ColorPicker.Hue, 0);
            HueBox.Text = '#' .. ColorPicker.Value:ToHex()
            RgbBox.Text = table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', ')
            Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value);
            Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value);
        end;

        function ColorPicker:OnChanged(Func)
            ColorPicker.Changed = Func;
            Func(ColorPicker.Value)
        end;

        function ColorPicker:Show()
            for Frame, Val in next, Library.OpenedFrames do
                if Frame.Name == 'Color' then
                    Frame.Visible = false;
                    Library.OpenedFrames[Frame] = nil;
                end;
            end;

            PickerFrameOuter.Visible = true;
            Library.OpenedFrames[PickerFrameOuter] = true;
        end;

        function ColorPicker:Hide()
            PickerFrameOuter.Visible = false;
            Library.OpenedFrames[PickerFrameOuter] = nil;
        end;

        function ColorPicker:SetValue(HSV, Transparency)
            local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3]);
            ColorPicker.Transparency = Transparency or 0;
            ColorPicker:SetHSVFromRGB(Color);
            ColorPicker:Display();
        end;

        function ColorPicker:SetValueRGB(Color, Transparency)
            ColorPicker.Transparency = Transparency or 0;
            ColorPicker:SetHSVFromRGB(Color);
            ColorPicker:Display();
        end;

        local function TrackDrag(Input, OnUpdate)
            local activeTouch = (Input.UserInputType == Enum.UserInputType.Touch) and Input or nil
            local dragging = true
            if activeTouch then
                local conn = InputService.TouchEnded:Connect(function(t)
                    if t == activeTouch then dragging = false end
                end)
                task.spawn(function()
                    while dragging do
                        local pos = ActiveTouches[activeTouch] or Vector2.zero
                        OnUpdate(pos)
                        RenderStepped:Wait()
                    end
                    conn:Disconnect()
                    Library:AttemptSave()
                end)
            else
                task.spawn(function()
                    while IsHeld() do
                        OnUpdate(GetCursorPos())
                        RenderStepped:Wait()
                    end
                    Library:AttemptSave()
                end)
            end
        end

        SatVibMap.InputBegan:Connect(function(Input)
            if IsClick(Input) then
                TrackDrag(Input, function(pos)
                    local MinX = SatVibMap.AbsolutePosition.X
                    local MaxX = MinX + SatVibMap.AbsoluteSize.X
                    local MinY = SatVibMap.AbsolutePosition.Y
                    local MaxY = MinY + SatVibMap.AbsoluteSize.Y
                    ColorPicker.Sat = (math.clamp(pos.X, MinX, MaxX) - MinX) / (MaxX - MinX)
                    ColorPicker.Vib = 1 - ((math.clamp(pos.Y, MinY, MaxY) - MinY) / (MaxY - MinY))
                    ColorPicker:Display()
                end)
            end
        end)
        HueSelectorInner.InputBegan:Connect(function(Input)
            if IsClick(Input) then
                TrackDrag(Input, function(pos)
                    local MinY = HueSelectorInner.AbsolutePosition.Y
                    local MaxY = MinY + HueSelectorInner.AbsoluteSize.Y
                    ColorPicker.Hue = (math.clamp(pos.Y, MinY, MaxY) - MinY) / (MaxY - MinY)
                    ColorPicker:Display()
                end)
            end
        end)
        DisplayFrame.InputBegan:Connect(function(Input)
            if IsClick(Input) and not Library:MouseIsOverOpenedFrame() then
                if PickerFrameOuter.Visible then
                    ColorPicker:Hide()
                else
                    ContextMenu:Hide()
                    ColorPicker:Show()
                end;

            elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame() then
                ContextMenu:Show()
                ColorPicker:Hide()
            end
        end);
        if TransparencyBoxInner then
            TransparencyBoxInner.InputBegan:Connect(function(Input)
                if IsClick(Input) then
                    TrackDrag(Input, function(pos)
                        local MinX = TransparencyBoxInner.AbsolutePosition.X
                        local MaxX = MinX + TransparencyBoxInner.AbsoluteSize.X
                        ColorPicker.Transparency = 1 - ((math.clamp(pos.X, MinX, MaxX) - MinX) / (MaxX - MinX))
                        ColorPicker:Display()
                    end)
                end
            end)
        end

        Library:GiveSignal(InputService.InputEnded:Connect(function(Input)
            if IsClick(Input) then
                local AbsPos, AbsSize = PickerFrameOuter.AbsolutePosition, PickerFrameOuter.AbsoluteSize;
                local dpos = GetCursorPos();
                if dpos.X < AbsPos.X or dpos.X > AbsPos.X + AbsSize.X
                    or dpos.Y < (AbsPos.Y - 20 - 1) or dpos.Y > AbsPos.Y + AbsSize.Y then
                    ColorPicker:Hide();
                end;

                if not Library:IsMouseOverFrame(ContextMenu.Container) then
                    ContextMenu:Hide()
                end
            end;

            if Input.UserInputType == Enum.UserInputType.MouseButton2 and ContextMenu.Container.Visible then
                if not Library:IsMouseOverFrame(ContextMenu.Container) and not Library:IsMouseOverFrame(DisplayFrame) then
                    ContextMenu:Hide()
                end
            end
        end))
        ColorPicker:Display();
        ColorPicker.DisplayFrame = DisplayFrame
        Options[Idx] = ColorPicker;
        return self;
    end;

function Funcs:AddKeyPicker(Idx, Info)
        local ParentObj = self;
        local ToggleLabel = self.TextLabel;
        local Container = self.Container;
        assert(Info.Default, 'AddKeyPicker: Missing default value.');
        local KeyPicker = {
            Value = Info.Default;
            Toggled = false;
            Mode = Info.Mode or 'Toggle';
            Type = 'KeyPicker';
            Callback = Info.Callback or function(Value) end;
            ChangedCallback = Info.ChangedCallback or function(New) end;
            SyncToggleState = Info.SyncToggleState or false;
        };
        if KeyPicker.SyncToggleState then
            Info.Modes = { 'Toggle' }
            Info.Mode = 'Toggle'
        end

        local PickOuter = Library:Create('Frame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Size = UDim2.new(0, 40, 0, 15);
            ZIndex = 6;
            Parent = ToggleLabel;
        });
        local DisplayLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 1, 0);
            TextSize = 13;
            Text = Info.Default == 'None' and '=' or Info.Default;
            TextColor3 = Color3.fromRGB(55, 55, 55);
            TextXAlignment = Enum.TextXAlignment.Right;
            ZIndex = 8;
            Parent = PickOuter;
        });
        if Library.RegistryMap[DisplayLabel] then
            Library.RegistryMap[DisplayLabel].Properties.TextColor3 = nil;
        end

        local ModeSelectOuter = Library:Create('Frame', {
            BackgroundColor3 = Library.OutlineColor;
            BorderSizePixel = 0;
            Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y + 1);
            Size = UDim2.new(0, 60, 0, 45 + 2);
            Visible = false;
            ZIndex = 14;
            Parent = ScreenGui;
        });
        Library:Create('UICorner', { CornerRadius = UDim.new(0, 4), Parent = ModeSelectOuter });
        ToggleLabel:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
            ModeSelectOuter.Position = UDim2.fromOffset(PickOuter.AbsolutePosition.X + PickOuter.AbsoluteSize.X + 4, PickOuter.AbsolutePosition.Y + 1);
        end);
        local ModeSelectInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 1, 0, 1);
            Size = UDim2.new(1, -2, 1, -2);
            ZIndex = 15;
            Parent = ModeSelectOuter;
        });
        Library:Create('UICorner', { CornerRadius = UDim.new(0, 3), Parent = ModeSelectInner });
        Library:AddToRegistry(ModeSelectInner, { BackgroundColor3 = 'MainColor'; });
        Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ModeSelectInner;
        });
        local ContainerLabel = Library:CreateLabel({
            TextXAlignment = Enum.TextXAlignment.Left;
            Size = UDim2.new(1, 0, 0, 18);
            TextSize = 13;
            Visible = false;
            ZIndex = 110;
            Parent = Library.KeybindContainer;
        },  true);
        local Modes = Info.Modes or { 'Always', 'Toggle', 'Hold' };
        local ModeButtons = {};
        for Idx, Mode in next, Modes do
            local ModeButton = {};
            local Label = Library:CreateLabel({
                Active = false;
                Size = UDim2.new(1, 0, 0, 15);
                TextSize = 13;
                Text = Mode;
                ZIndex = 16;
                Parent = ModeSelectInner;
            });
            function ModeButton:Select()

                for _, Button in next, ModeButtons do Button:Deselect(); end;
                KeyPicker.Mode = Mode;
                Label.TextColor3 = Library.AccentColor;
                Library.RegistryMap[Label].Properties.TextColor3 = 'AccentColor';
                ModeSelectOuter.Visible = false;
            end;

            function ModeButton:Deselect()
                KeyPicker.Mode = nil;
                Label.TextColor3 = Library.FontColor;
                Library.RegistryMap[Label].Properties.TextColor3 = 'FontColor';
            end;

            Label.InputBegan:Connect(function(Input)
                if IsClick(Input) then
                    ModeButton:Select();
                    Library:AttemptSave();
                end;
            end);
            if Mode == KeyPicker.Mode then ModeButton:Select(); end;
            ModeButtons[Mode] = ModeButton;
        end;

        function KeyPicker:Update()
            if Info.NoUI then return; end;
            local State = KeyPicker:GetState();
            ContainerLabel.Text = string.format('[%s] %s (%s)', KeyPicker.Value == 'None' and 'None' or KeyPicker.Value, Info.Text, KeyPicker.Mode);
            ContainerLabel.Visible = true;
            ContainerLabel.TextColor3 = State and Library.AccentColor or Library.FontColor;
            Library.RegistryMap[ContainerLabel].Properties.TextColor3 = State and 'AccentColor' or 'FontColor';
            local YSize = 0
            local XSize = 0
            for _, Label in next, Library.KeybindContainer:GetChildren() do
                if Label:IsA('TextLabel') and Label.Visible then
                    YSize = YSize + 18;
                    if (Label.TextBounds.X > XSize) then XSize = Label.TextBounds.X end
                end;
            end;

            Library.KeybindFrame.Size = UDim2.new(0, math.max(XSize + 24, 240), 0, YSize + 38)
        end;

        function KeyPicker:GetState()
            if KeyPicker.Mode == 'Always' then return true;
            elseif KeyPicker.Mode == 'Hold' then
                if KeyPicker.Value == 'None' then return false; end
                local Key = KeyPicker.Value;
                if Key == 'MB1' or Key == 'MB2' then
                    return Key == 'MB1' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                        or Key == 'MB2' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2);
                else
                    return InputService:IsKeyDown(Enum.KeyCode[KeyPicker.Value]);
                end;

            else
                return KeyPicker.Toggled;
            end;
        end;

        function KeyPicker:SetValue(Data)
            local Key, Mode = Data[1], Data[2];
            DisplayLabel.Text = Key == 'None' and '=' or Key;
            KeyPicker.Value = Key;
            ModeButtons[Mode]:Select();
            KeyPicker:Update();
        end;

        function KeyPicker:OnClick(Callback) KeyPicker.Clicked = Callback end
        function KeyPicker:OnChanged(Callback)
            KeyPicker.Changed = Callback
            Callback(KeyPicker.Value)
        end

        if ParentObj.Addons then table.insert(ParentObj.Addons, KeyPicker) end
        function KeyPicker:DoClick()

            if ParentObj.Type == 'Toggle' and KeyPicker.SyncToggleState then
                ParentObj:SetValue(not ParentObj.Value)
            end

            Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
            Library:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)
        end

        local Picking = false;
        PickOuter.InputBegan:Connect(function(Input)
            if IsClick(Input) and not Library:MouseIsOverOpenedFrame() then
                Picking = true;
                DisplayLabel.Text = '';
                local Break;
                local Text = '';
                task.spawn(function()
                    while (not Break) do
                        if Text == '...' then Text = ''; end;
                        Text = Text .. '.';
                        DisplayLabel.Text = Text;
                        wait(0.4);
                    end;
                end);
                wait(0.2);
                local Event;
                Event = InputService.InputBegan:Connect(function(Input)
                    local Key;
                    if Input.UserInputType == Enum.UserInputType.Keyboard then
                        if Input.KeyCode == Enum.KeyCode.Escape
                            or Input.KeyCode == Enum.KeyCode.Delete
                            or Input.KeyCode == Enum.KeyCode.Backspace then
                            Key = 'None';
                        else
                            Key = Input.KeyCode.Name;
                        end

                    elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Key = 'MB1';
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                        Key = 'MB2';
                    end;

                    if not Key then return end;
                    Break = true;
                    Picking = false;
                    DisplayLabel.Text = Key == 'None' and '=' or Key;
                    KeyPicker.Value = Key;
                    Library:SafeCallback(KeyPicker.ChangedCallback, Key == 'None' and Enum.KeyCode.Unknown or Input.KeyCode or Input.UserInputType)
                    Library:SafeCallback(KeyPicker.Changed, Key == 'None' and Enum.KeyCode.Unknown or Input.KeyCode or Input.UserInputType)
                    Library:AttemptSave();
                    KeyPicker:Update();
                    Event:Disconnect();
                end);
            elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame() then
                ModeSelectOuter.Visible = true;
            end;
        end);
        Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
            if (not Picking) then
                if KeyPicker.Mode == 'Toggle' then
                    if KeyPicker.Value == 'None' then return end
                    local Key = KeyPicker.Value;
                    if Key == 'MB1' or Key == 'MB2' then
                        if Key == 'MB1' and Input.UserInputType == Enum.UserInputType.MouseButton1
                        or Key == 'MB2' and Input.UserInputType == Enum.UserInputType.MouseButton2 then
                            KeyPicker.Toggled = not KeyPicker.Toggled
                            KeyPicker:DoClick()
                        end;

                    elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                        if Input.KeyCode.Name == Key then
                            KeyPicker.Toggled = not KeyPicker.Toggled;
                            KeyPicker:DoClick()
                        end;
                    end;
                end;

                KeyPicker:Update();
            end;

            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                local AbsPos, AbsSize = ModeSelectOuter.AbsolutePosition, ModeSelectOuter.AbsoluteSize;
                local dpos = InputService:GetMouseLocation();
                if dpos.X < AbsPos.X or dpos.X > AbsPos.X + AbsSize.X
                    or dpos.Y < (AbsPos.Y - 20 - 1) or dpos.Y > AbsPos.Y + AbsSize.Y then
                    ModeSelectOuter.Visible = false;
                end;
            end;
        end))
        Library:GiveSignal(InputService.InputEnded:Connect(function(Input)
            if (not Picking) then KeyPicker:Update(); end;
        end))
        KeyPicker:Update();
        Options[Idx] = KeyPicker;
        return self;
    end;

    BaseAddons.__index = Funcs;
    BaseAddons.__namecall = function(Table, Key, ...)
        return Funcs[Key](...);
    end;
end;

local BaseGroupbox = {};
do

    local Funcs = {};

    Funcs.AddColorPicker = function(self, Idx, Info)
        return BaseAddons.__index.AddColorPicker(self, Idx, Info)
    end
    function Funcs:AddBlank(Size)

        local Groupbox = self;
        local Container = Groupbox.Container;
        Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 0, Size);
            ZIndex = 1;
            Parent = Container;
        });
    end;

    function Funcs:AddLabel(Text, DoesWrap)
        local Label = {};
        local Groupbox = self;
        local Container = Groupbox.Container;
        local TextLabel = Library:CreateLabel({
            Size = UDim2.new(1, -4, 0, 15);
            TextSize = 14;
            Text = Text;
            TextWrapped = DoesWrap or false,
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 5;
            Parent = Container;
        });
        if DoesWrap then
            local Y = select(2, Library:GetTextBounds(Text, Library.Font, 14, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))
            TextLabel.Size = UDim2.new(1, -4, 0, Y)
        else
            Library:Create('UIListLayout', {
                Padding = UDim.new(0, 4);
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Right;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = TextLabel;
            });
        end

        Label.TextLabel = TextLabel;
        Label.Container = Container;
        function Label:SetText(Text)

            TextLabel.Text = Text
            if DoesWrap then
                local Y = select(2, Library:GetTextBounds(Text, Library.Font, 14, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))
                TextLabel.Size = UDim2.new(1, -4, 0, Y)
            end

            Groupbox:Resize();
        end

        if (not DoesWrap) then
            setmetatable(Label, BaseAddons);
        end

        Groupbox:AddBlank(5);
        Groupbox:Resize();
        return Label;
    end;

function Funcs:AddButton(...)
        local Button = {};
        local function ProcessButtonParams(Class, Obj, ...)

            local Props = select(1, ...)
            if type(Props) == 'table' then
                Obj.Text = Props.Text
                Obj.Func = Props.Func
                Obj.DoubleClick = Props.DoubleClick
                Obj.Tooltip = Props.Tooltip
            else
                Obj.Text = select(1, ...)
                Obj.Func = select(2, ...)
            end

            assert(type(Obj.Func) == 'function', 'AddButton: `Func` callback is missing.');
        end

        ProcessButtonParams('Button', Button, ...)
        local Groupbox = self;
        local Container = Groupbox.Container;
    local function CreateBaseButton(Button)

            local Outer = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor;
                BorderSizePixel = 0;
                Size = UDim2.new(1, -4, 0, 24);
                ZIndex = 5;
            });
            Library:Create('UICorner', { CornerRadius = UDim.new(0, 4), Parent = Outer });
            Library:AddToRegistry(Outer, { BackgroundColor3 = 'AccentColor'; });
            local Label = Library:CreateLabel({
                Size = UDim2.new(1, 0, 1, 0);
                TextSize = 13;
                Text = Button.Text;
                ZIndex = 6;
                Parent = Outer;
            });
            Library:RemoveFromRegistry(Label)
            Label.TextColor3 = Library.MainColor
            Library:AddToRegistry(Label, { TextColor3 = 'MainColor' })
            Outer.MouseEnter:Connect(function()
                Outer.BackgroundTransparency = 0.15;
            end)
            Outer.MouseLeave:Connect(function()
                Outer.BackgroundTransparency = 0;
            end)
            return Outer, Outer, Label
        end

        local function InitEvents(Button)
            local function WaitForEvent(event, timeout, validator)
                local bindable = Instance.new('BindableEvent')
                local connection = event:Once(function(...)
                    if type(validator) == 'function' and validator(...) then
                        bindable:Fire(true)
                    else
                        bindable:Fire(false)
                    end
                end)
                task.delay(timeout, function()
                    connection:disconnect()
                    bindable:Fire(false)
                end)
                return bindable.Event:Wait()
            end

            local function ValidateClick(Input)
                if Library:MouseIsOverOpenedFrame() then return false end
                if not IsClick(Input) then return false end
                return true
            end

            Button.Outer.InputBegan:Connect(function(Input)
                if not ValidateClick(Input) then return end
                if Button.Locked then return end
                if Button.DoubleClick then
                    Button.Label.Text = 'Are you sure?'
                    Button.Locked = true
                    local clicked = WaitForEvent(Button.Outer.InputBegan, 0.5, ValidateClick)
                    Button.Label.Text = Button.Text
                    task.defer(rawset, Button, 'Locked', false)
                    if clicked then
                        Library:SafeCallback(Button.Func)
                    end

                    return
                end

                Library:SafeCallback(Button.Func);
            end)
        end

        Button.Outer, Button.Inner, Button.Label = CreateBaseButton(Button)
        Button.Outer.Parent = Container
        InitEvents(Button)
        function Button:AddTooltip(tooltip)

            if type(tooltip) == 'string' then
                Library:AddToolTip(tooltip, self.Outer)
            end

            return self
        end

        function Button:AddButton(...)
            local SubButton = {}
            ProcessButtonParams('SubButton', SubButton, ...)
            self.Outer.Size = UDim2.new(0.5, -2, 0, 24)
            SubButton.Outer, SubButton.Inner, SubButton.Label = CreateBaseButton(SubButton)
            SubButton.Outer.Position = UDim2.new(1, 4, 0, 0)
            SubButton.Outer.Size = UDim2.fromOffset(self.Outer.AbsoluteSize.X - 2, self.Outer.AbsoluteSize.Y)
            SubButton.Outer.Parent = self.Outer
            function SubButton:AddTooltip(tooltip)

                if type(tooltip) == 'string' then
                    Library:AddToolTip(tooltip, self.Outer)
                end

                return SubButton
            end

            if type(SubButton.Tooltip) == 'string' then
                SubButton:AddTooltip(SubButton.Tooltip)
            end

            InitEvents(SubButton)
            return SubButton
        end

        if type(Button.Tooltip) == 'string' then
            Button:AddTooltip(Button.Tooltip)
        end

        Groupbox:AddBlank(5);
        Groupbox:Resize();
        return Button;
    end;

    function Funcs:AddDivider()
        local Groupbox = self;
        local Container = self.Container
        local Divider = {
            Type = 'Divider',
        }
        Groupbox:AddBlank(2);
        local DividerOuter = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderColor3 = Color3.new(0, 0, 0);
            Size = UDim2.new(1, -4, 0, 5);
            ZIndex = 5;
            Parent = Container;
        });
        local DividerInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 6;
            Parent = DividerOuter;
        });
        Library:AddToRegistry(DividerOuter, {
            BorderColor3 = 'Black';
        });
        Library:AddToRegistry(DividerInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });
        Groupbox:AddBlank(9);
        Groupbox:Resize();
    end

function Funcs:AddInput(Idx, Info)
        assert(Info.Text, 'AddInput: Missing `Text` string.')
        local Textbox = {
            Value = Info.Default or '';
            Numeric = Info.Numeric or false;
            Finished = Info.Finished or false;
            Type = 'Input';
            Callback = Info.Callback or function(Value) end;
        };
        local Groupbox = self;
        local Container = Groupbox.Container;
        local InputContainer = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, -4, 0, 24);
            ZIndex = 5;
            Parent = Container;
        });
        local InputLabel = Library:CreateLabel({
            Size = UDim2.new(0.5, 0, 1, 0);
            Position = UDim2.new(0, 0, 0, 0);
            TextSize = 13;
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 6;
            Parent = InputContainer;
        });
        local TextBoxOuter = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0.5, 0, 0, 0);
            Size = UDim2.new(0.5, 0, 1, 0);
            ZIndex = 5;
            Parent = InputContainer;
        });
        Library:Create('UICorner', { CornerRadius = UDim.new(0, 4), Parent = TextBoxOuter });
        Library:AddToRegistry(TextBoxOuter, { BackgroundColor3 = 'BackgroundColor'; });
        local InputHighlight = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 0, 1, -2);
            Size = UDim2.new(1, 0, 0, 2);
            ZIndex = 6;
            Parent = TextBoxOuter;
        });
        Library:Create('UICorner', { CornerRadius = UDim.new(0, 4), Parent = InputHighlight });
        Library:AddToRegistry(InputHighlight, { BackgroundColor3 = 'AccentColor'; });
        local ContainerBox = Library:Create('Frame', {
            BackgroundTransparency = 1;
            ClipsDescendants = true;
            Position = UDim2.new(0, 8, 0, 0);
            Size = UDim2.new(1, -16, 1, 0);
            ZIndex = 7;
            Parent = TextBoxOuter;
        });
        local Box = Library:Create('TextBox', {
            BackgroundTransparency = 1;
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromScale(5, 1),
            Font = Library.Font;
            PlaceholderColor3 = Color3.fromRGB(110, 110, 110);
            PlaceholderText = Info.Placeholder or '';
            Text = Info.Default or '';
            TextColor3 = Library.FontColor;
            TextSize = 13;
            TextStrokeTransparency = 1;
            TextXAlignment = Enum.TextXAlignment.Left;
            ClearTextOnFocus = false;
            ZIndex = 7;
            Parent = ContainerBox;
        });
        function Textbox:SetValue(Text)

            if Info.MaxLength and #Text > Info.MaxLength then
                Text = Text:sub(1, Info.MaxLength);
            end;

            if Textbox.Numeric then
                if (not tonumber(Text)) and Text:len() > 0 then
                    Text = Textbox.Value
                end
            end

            Textbox.Value = Text;
            Box.Text = Text;
            Library:SafeCallback(Textbox.Callback, Textbox.Value);
            Library:SafeCallback(Textbox.Changed, Textbox.Value);
        end;

        if Textbox.Finished then
            Box.FocusLost:Connect(function(enter)
                if enter or (Box.Text ~= '' and Box.Text ~= (Info.Default or '')) then
                    Textbox:SetValue(Box.Text)
                    Library:AttemptSave()
                end
            end)
        else
            Box:GetPropertyChangedSignal('Text'):Connect(function()
                Textbox:SetValue(Box.Text);
                Library:AttemptSave()
            end)
        end

        local function Update()
            local PADDING = 0
            local reveal = ContainerBox.AbsoluteSize.X
            if not Box:IsFocused() or Box.TextBounds.X <= reveal - 2 * PADDING then
                Box.Position = UDim2.new(0, PADDING, 0, 0)
            else
                local cursor = Box.CursorPosition
                if cursor ~= -1 then
                    local subtext = string.sub(Box.Text, 1, cursor-1)
                    local width = TextService:GetTextSize(subtext, Box.TextSize, Box.Font, Vector2.new(math.huge, math.huge)).X
                    local currentCursorPos = Box.Position.X.Offset + width
                    if currentCursorPos < PADDING then
                        Box.Position = UDim2.fromOffset(PADDING-width, 0)
                    elseif currentCursorPos > reveal - PADDING - 1 then
                        Box.Position = UDim2.fromOffset(reveal-width-PADDING-1, 0)
                    end
                end
            end
        end

        task.spawn(Update)
        Box:GetPropertyChangedSignal('Text'):Connect(Update)
        Box:GetPropertyChangedSignal('CursorPosition'):Connect(Update)
        Box.FocusLost:Connect(Update)
        Box.Focused:Connect(Update)
        Library:AddToRegistry(Box, { TextColor3 = 'FontColor'; });
        function Textbox:OnChanged(Func)

            Textbox.Changed = Func;
            Func(Textbox.Value);
        end;

        Groupbox:AddBlank(Info.BlankSize or 5);
        Groupbox:Resize();
        Options[Idx] = Textbox;
        return Textbox;
    end;

function Funcs:AddToggle(Idx, Info)
        assert(Info.Text, 'AddInput: Missing `Text` string.')
        local Toggle = {
            Value = Info.Default or false;
            Type = 'Toggle';
            Callback = Info.Callback or function(Value) end;
            Addons = {},
            Risky = Info.Risky,
        };
        local Groupbox = self;
        local Container = Groupbox.Container;
        local ToggleContainer = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, -4, 0, 15);
            ZIndex = 5;
            Parent = Container;
        });
        local ToggleLabel = Library:CreateLabel({
            Size = UDim2.new(1, -24, 1, 0);
            Position = UDim2.new(0, 0, 0, 0);
            TextSize = 13,
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 6;
            Parent = ToggleContainer;
        });
        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 4);
            FillDirection = Enum.FillDirection.Horizontal;
            HorizontalAlignment = Enum.HorizontalAlignment.Right;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ToggleLabel;
        });
        local ToggleOuter = Library:Create('Frame', {
            BackgroundColor3 = Library.OutlineColor;
            BorderSizePixel = 0;
            AnchorPoint = Vector2.new(1, 0.5);
            Position = UDim2.new(1, 0, 0.5, 0);
            Size = UDim2.new(0, 14, 0, 14);
            ZIndex = 5;
            Parent = ToggleContainer;
        });
        Library:Create('UICorner', {
            CornerRadius = UDim.new(0, 4),
            Parent = ToggleOuter
        });
        Library:AddToRegistry(ToggleOuter, {
            BackgroundColor3 = 'OutlineColor';
        });
        local ToggleInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderSizePixel = 0;
            AnchorPoint = Vector2.new(0.5, 0.5);
            Position = UDim2.new(0.5, 0, 0.5, 0);
            Size = UDim2.new(1, -2, 1, -2);
            ZIndex = 6;
            Parent = ToggleOuter;
        });
        Library:Create('UICorner', {
            CornerRadius = UDim.new(0, 3),
            Parent = ToggleInner
        });
        Library:AddToRegistry(ToggleInner, {
            BackgroundColor3 = 'MainColor';
        });
        local ToggleRegion = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 8;
            Parent = ToggleContainer;
        });
        function Toggle:UpdateColors()

            Toggle:Display();
        end;

        if type(Info.Tooltip) == 'string' then
            Library:AddToolTip(Info.Tooltip, ToggleRegion)
        end

        function Toggle:Display()
            ToggleInner.BackgroundColor3 = Toggle.Value and Library.AccentColor or Library.MainColor;
            ToggleOuter.BackgroundColor3 = Toggle.Value and Library.AccentColor or Library.OutlineColor;
            Library.RegistryMap[ToggleInner].Properties.BackgroundColor3 = Toggle.Value and 'AccentColor' or 'MainColor';
            Library.RegistryMap[ToggleOuter].Properties.BackgroundColor3 = Toggle.Value and 'AccentColor' or 'OutlineColor';
        end;

        function Toggle:OnChanged(Func)
            Toggle.Changed = Func;
            Func(Toggle.Value);
        end;

        function Toggle:SetValue(Bool)
            Bool = (not not Bool);
            Toggle.Value = Bool;
            Toggle:Display();
            for _, Addon in next, Toggle.Addons do
                if Addon.Type == 'KeyPicker' and Addon.SyncToggleState then
                    Addon.Toggled = Bool
                    Addon:Update()
                end
            end

            Library:SafeCallback(Toggle.Callback, Toggle.Value);
            Library:SafeCallback(Toggle.Changed, Toggle.Value);
            Library:UpdateDependencyBoxes();
        end;

        ToggleRegion.InputBegan:Connect(function(Input)
            if IsClick(Input) and not Library:MouseIsOverOpenedFrame() then
                Toggle:SetValue(not Toggle.Value)
                Library:AttemptSave();
            end;
        end);
        if Toggle.Risky then
            Library:RemoveFromRegistry(ToggleLabel)
            ToggleLabel.TextColor3 = Library.RiskColor
            Library:AddToRegistry(ToggleLabel, { TextColor3 = 'RiskColor' })
        end

        Toggle:Display();
        Groupbox:AddBlank(Info.BlankSize or 7);
        Groupbox:Resize();
        Toggle.TextLabel = ToggleLabel;
        Toggle.Container = Container;
        setmetatable(Toggle, BaseAddons);
        Toggles[Idx] = Toggle;
        Library:UpdateDependencyBoxes();
        return Toggle;
    end;

function Funcs:AddSlider(Idx, Info)
        assert(Info.Default, 'AddSlider: Missing default value.');
        assert(Info.Text, 'AddSlider: Missing slider text.');
        assert(Info.Min, 'AddSlider: Missing minimum value.');
        assert(Info.Max, 'AddSlider: Missing maximum value.');
        assert(Info.Rounding, 'AddSlider: Missing rounding value.');
        local Slider = {
            Value = Info.Default;
            Min = Info.Min;
            Max = Info.Max;
            Rounding = Info.Rounding;
            Callback = Info.Callback or function(Value) end;
            Type = 'Slider';
        };
        local Groupbox = self;
        local Container = Groupbox.Container;
        local SliderContainer = Library:Create('Frame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Size = UDim2.new(1, -4, 0, 30);
            ZIndex = 5;
            Parent = Container;
        });
        local SliderLabel = Library:CreateLabel({
            Size = UDim2.new(0.5, 0, 0, 14);
            Position = UDim2.new(0, 0, 0, 0);
            TextSize = 13;
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 6;
            Parent = SliderContainer;
        });
        local SliderValueLabel = Library:CreateLabel({
            Size = UDim2.new(0.5, 0, 0, 14);
            Position = UDim2.new(0.5, 0, 0, 0);
            TextSize = 13;
            Text = tostring(Info.Default) .. (Info.Suffix or '');
            TextXAlignment = Enum.TextXAlignment.Right;
            ZIndex = 6;
            Parent = SliderContainer;
        });
        local SliderOuter = Library:Create('Frame', {
            BackgroundColor3 = Library.OutlineColor;
            BorderSizePixel = 0;
            BorderMode = Enum.BorderMode.Outline;
            ClipsDescendants = false;
            Position = UDim2.new(0, 0, 0, 22);
            Size = UDim2.new(1, 0, 0, 4);
            ZIndex = 5;
            Parent = SliderContainer;
        });
        Library:Create('UICorner', { CornerRadius = UDim.new(0, 4), Parent = SliderOuter });
        Library:AddToRegistry(SliderOuter, { BackgroundColor3 = 'OutlineColor'; });
        local SliderInner = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            BorderMode = Enum.BorderMode.Outline;
            ClipsDescendants = false;
            Position = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(0, 0, 1, 0);
            ZIndex = 6;
            Parent = SliderOuter;
        });
        Library:Create('UICorner', { CornerRadius = UDim.new(0, 4), Parent = SliderInner });
        Library:AddToRegistry(SliderInner, { BackgroundColor3 = 'AccentColor'; });
        local SliderKnob = Library:Create('Frame', {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255);
            BorderSizePixel = 0;
            AnchorPoint = Vector2.new(0.5, 0.5);
            Position = UDim2.new(1, 0, 0.5, 0);
            Size = UDim2.new(0, 10, 0, 10);
            ZIndex = 7;
            Parent = SliderInner;
        });
        Library:Create('UICorner', { CornerRadius = UDim.new(1, 0), Parent = SliderKnob });
        local SliderInteract = Library:Create('TextButton', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 0, 0, 14);
            Size = UDim2.new(1, 0, 0, 16);
            Text = '';
            ZIndex = 8;
            Parent = SliderContainer;
        });
        local Dragging = false;
        function Slider:SetRaw(Percent)

            Percent = math.clamp(Percent, 0, 1);
            local Value = Info.Min + ((Info.Max - Info.Min) * Percent);
            local Mult = 10 ^ Info.Rounding;
            Value = math.round(Value * Mult) / Mult;
            Slider:SetValue(Value);
        end;

        function Slider:SetValue(Value)
            local Num = tonumber(Value);
            if not Num then return; end;
            Num = math.clamp(Num, Info.Min, Info.Max);
            Slider.Value = Num;
            SliderValueLabel.Text = tostring(Num) .. (Info.Suffix or '');
            local Percent = (Num - Info.Min) / (Info.Max - Info.Min);
            TweenService:Create(SliderInner, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(Percent, 0, 1, 0)
            }):Play();
            Library:SafeCallback(Slider.Callback, Slider.Value);
            Library:SafeCallback(Slider.Changed, Slider.Value);
        end;

        function Slider:OnChanged(Func)
            Slider.Changed = Func;
            Func(Slider.Value);
        end;

        local SliderActiveTouch = nil
        SliderInteract.InputBegan:Connect(function(Input)
            if IsClick(Input) and not Library:MouseIsOverOpenedFrame() then
                Dragging = true
                Slider:SetRaw((Input.Position.X - SliderOuter.AbsolutePosition.X) / SliderOuter.AbsoluteSize.X)
                if Input.UserInputType == Enum.UserInputType.Touch then
                    SliderActiveTouch = Input
                end
            end
        end)
        Library:GiveSignal(InputService.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                if Dragging then
                    Dragging = false
                    SliderActiveTouch = nil
                    Library:AttemptSave()
                end
            end
        end))
        Library:GiveSignal(InputService.InputChanged:Connect(function(Input)
            if not Dragging then return end
            if Input.UserInputType == Enum.UserInputType.MouseMovement then
                Slider:SetRaw((Input.Position.X - SliderOuter.AbsolutePosition.X) / SliderOuter.AbsoluteSize.X)
            elseif Input.UserInputType == Enum.UserInputType.Touch and Input == SliderActiveTouch then
                Slider:SetRaw((Input.Position.X - SliderOuter.AbsolutePosition.X) / SliderOuter.AbsoluteSize.X)
            end
        end))
        Slider:SetValue(Slider.Value);
        Groupbox:AddBlank(Info.BlankSize or 6);
        Groupbox:Resize();
        Options[Idx] = Slider;
        return Slider;
    end;

function Funcs:AddDropdown(Idx, Info)
        assert(Info.Text, 'AddDropdown: Missing dropdown text.');
        assert(Info.Values, 'AddDropdown: Missing dropdown values.');
        local Dropdown = {
            Values = Info.Values;
            Value = Info.Multi and {} or '';
            Multi = Info.Multi;
            Type = 'Dropdown';
            SpecialType = Info.SpecialType;
            Callback = Info.Callback or function(Value) end;
        };
        local Groupbox = self;
        local Container = Groupbox.Container;
        local DropdownContainer = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, -4, 0, 24);
            ZIndex = 5;
            Parent = Container;
        });
        local DropdownLabel = Library:CreateLabel({
            Size = UDim2.new(0.5, 0, 1, 0);
            Position = UDim2.new(0, 0, 0, 0);
            TextSize = 13;
            Text = Info.Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 6;
            Parent = DropdownContainer;
        });
        local DropdownOuter = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0.5, 0, 0, 0);
            Size = UDim2.new(0.5, 0, 1, 0);
            ZIndex = 5;
            Parent = DropdownContainer;
        });
        Library:Create('UICorner', { CornerRadius = UDim.new(0, 4), Parent = DropdownOuter });
        Library:AddToRegistry(DropdownOuter, { BackgroundColor3 = 'BackgroundColor'; });
        local DropdownHighlight = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 0, 1, -2);
            Size = UDim2.new(1, 0, 0, 2);
            ZIndex = 6;
            Parent = DropdownOuter;
        });
        Library:Create('UICorner', { CornerRadius = UDim.new(0, 4), Parent = DropdownHighlight });
        Library:AddToRegistry(DropdownHighlight, { BackgroundColor3 = 'AccentColor'; });
        local DropdownInnerLabel = Library:CreateLabel({
            Size = UDim2.new(1, -20, 1, 0);
            Position = UDim2.new(0, 8, 0, 0);
            TextSize = 13;
            Text = 'None';
            TextXAlignment = Enum.TextXAlignment.Left;
            TextColor3 = Library.FontColor;
            ZIndex = 6;
            Parent = DropdownOuter;
        });
        local DropdownArrow = Library:CreateLabel({
            Size = UDim2.new(0, 20, 1, 0);
            Position = UDim2.new(1, -20, 0, 0);
            TextSize = 10;
            Text = 'v';
            TextColor3 = Color3.fromRGB(150, 150, 150);
            ZIndex = 6;
            Parent = DropdownOuter;
        });
        local DropdownInteract = Library:Create('TextButton', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 0, 24);
            Text = '';
            ZIndex = 7;
            Parent = DropdownOuter;
        });
        local ListOuter = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderSizePixel = 0;
            ZIndex = 20;
            Visible = false;
            Parent = ScreenGui;
        });
        Library:Create('UICorner', { CornerRadius = UDim.new(0, 4), Parent = ListOuter });
        Library:AddToRegistry(ListOuter, { BackgroundColor3 = 'BackgroundColor'; });
        local ListStroke = Instance.new("UIStroke")
        ListStroke.Color = Library.MainColor
        ListStroke.Thickness = 1
        ListStroke.Parent = ListOuter
        Library:AddToRegistry(ListStroke, { Color = 'MainColor'; });
        local ScrollingFrame = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            CanvasSize = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, -4, 1, -4);
            Position = UDim2.new(0, 2, 0, 2);
            ZIndex = 21;
            BottomImage = '';
            TopImage = '';
            ScrollBarThickness = 2;
            ScrollBarImageColor3 = Library.AccentColor;
            Parent = ListOuter;
        });
        Library:AddToRegistry(ScrollingFrame, { ScrollBarImageColor3 = 'AccentColor'; });
        local UIListLayout = Library:Create('UIListLayout', {
            Padding = UDim.new(0, 2);
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = ScrollingFrame;
        });
        function Dropdown:Display()

            local Values = Dropdown.Values;
            local Str = '';
            if Info.Multi then
                for Idx, Value in next, Values do
                    if Dropdown.Value[Value] then
                        Str = Str .. Value .. ', ';
                    end;
                end;

                Str = Str:sub(1, -3);
            else
                Str = Dropdown.Value or '';
            end;

            DropdownInnerLabel.Text = (Str == '' and 'None' or Str);
        end;

        function Dropdown:GetActiveValues()
            if Info.Multi then
                local T = {};
                for Value, Bool in next, Dropdown.Value do
                    table.insert(T, Value);
                end;

                return T;
            else
                return Dropdown.Value and { Dropdown.Value } or {};
            end;
        end;

        function Dropdown:BuildDropdownList()
            local Values = Dropdown.Values;
            for _, Element in next, ScrollingFrame:GetChildren() do
                if not Element:IsA('UIListLayout') then
                    Element:Destroy();
                end;
            end;

            local Count = 0;
            for Idx, Value in next, Values do
                local Active = false;
                if Info.Multi then Active = Dropdown.Value[Value];
                else Active = Dropdown.Value == Value; end;
                local Button = Library:Create('TextButton', {
                    BackgroundColor3 = Active and Library.MainColor or Library.BackgroundColor;
                    BorderSizePixel = 0;
                    Size = UDim2.new(1, 0, 0, 20);
                    Text = '';
                    ZIndex = 22;
                    Parent = ScrollingFrame;
                });
                Library:Create('UICorner', { CornerRadius = UDim.new(0, 3), Parent = Button });
                Library:AddToRegistry(Button, { BackgroundColor3 = Active and 'MainColor' or 'BackgroundColor'; });
                local Label = Library:CreateLabel({
                    Size = UDim2.new(1, -10, 1, 0);
                    Position = UDim2.new(0, 6, 0, 0);
                    TextSize = 13;
                    Text = Value;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    TextColor3 = Active and Library.AccentColor or Library.FontColor;
                    ZIndex = 23;
                    Parent = Button;
                });
                Library:AddToRegistry(Label, { TextColor3 = Active and 'AccentColor' or 'FontColor'; });
                local BtnTouchId = nil
                local BtnTouchStartY = nil
                local BtnScrolled = false
                Button.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.Touch then
                        BtnTouchId = Input
                        BtnTouchStartY = Input.Position.Y
                        BtnScrolled = false
                    end
                end)
                Button.InputChanged:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.Touch and Input == BtnTouchId then
                        if BtnTouchStartY and math.abs(Input.Position.Y - BtnTouchStartY) > 8 then
                            BtnScrolled = true
                        end
                    end
                end)
                Button.InputEnded:Connect(function(Input)
                    local isTouch = Input.UserInputType == Enum.UserInputType.Touch
                    local isMouse = Input.UserInputType == Enum.UserInputType.MouseButton1
                    if isTouch and Input == BtnTouchId then
                        BtnTouchId = nil
                        if BtnScrolled then BtnScrolled = false return end
                    elseif not isMouse then return end
                    if isTouch and BtnScrolled then return end
                    if Info.Multi then
                        Dropdown.Value[Value] = not Dropdown.Value[Value]
                        Dropdown:SetValue(Dropdown.Value)
                    else
                        Dropdown.Value = Value
                        Dropdown:SetValue(Dropdown.Value)
                        ListOuter.Visible = false
                        DropdownArrow.Text = 'v'
                        Library.OpenedFrames[ListOuter] = nil
                        DropIsOpen = false
                    end
                    Library:AttemptSave()
                end)
                Count = Count + 1;
            end;

            local MaxHeight = math.min(Count * 22, 120);
            ListOuter.Size = UDim2.new(0, DropdownOuter.AbsoluteSize.X, 0, MaxHeight + 4);
            ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, Count * 22);
        end;

        function Dropdown:SetValue(Val)
            if Dropdown.Multi then
                local nTable = {};
                if type(Val) == 'table' then
                    for Value, Bool in next, Val do
                        if table.find(Dropdown.Values, Value) then nTable[Value] = true end;
                    end;

                elseif type(Val) == 'number' and Dropdown.Values[Val] then
                    nTable[Dropdown.Values[Val]] = true;
                elseif type(Val) == 'string' and table.find(Dropdown.Values, Val) then
                    nTable[Val] = true;
                end;

                Dropdown.Value = nTable;
            else
                if not Val then
                    Dropdown.Value = '';
                elseif type(Val) == 'number' and Dropdown.Values[Val] then
                    Dropdown.Value = Dropdown.Values[Val];
                elseif type(Val) == 'string' and table.find(Dropdown.Values, Val) then
                    Dropdown.Value = Val;
                end;
            end;

            Dropdown:BuildDropdownList();
            Dropdown:Display();
            Library:SafeCallback(Dropdown.Callback, Dropdown.Value);
            Library:SafeCallback(Dropdown.Changed, Dropdown.Value);
        end;

        function Dropdown:SetValues(NewValues)
            if NewValues then Dropdown.Values = NewValues; end;
            Dropdown:BuildDropdownList();
            Dropdown:Display();
        end;

        function Dropdown:OnChanged(Func)
            Dropdown.Changed = Func;
            Func(Dropdown.Value);
        end;

        local DropIsOpen = false
        local DropTouchId = nil
        local DropTouchStartY = nil
        local DropTouchScrolled = false
        local SCROLL_THRESHOLD = 10

        local function OpenDropdown()
            DropIsOpen = true
            ListOuter.Position = UDim2.fromOffset(
                DropdownOuter.AbsolutePosition.X,
                DropdownOuter.AbsolutePosition.Y + DropdownOuter.AbsoluteSize.Y + 2
            )
            Dropdown:BuildDropdownList()
            ListOuter.Visible = true
            DropdownArrow.Text = '^'
            Library.OpenedFrames[ListOuter] = true
        end

        local function CloseDropdown()
            DropIsOpen = false
            ListOuter.Visible = false
            DropdownArrow.Text = 'v'
            Library.OpenedFrames[ListOuter] = nil
        end

        DropdownInteract.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.Touch then
                DropTouchId = Input
                DropTouchStartY = Input.Position.Y
                DropTouchScrolled = false
            end
        end)

        DropdownInteract.InputChanged:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.Touch and Input == DropTouchId then
                if DropTouchStartY and math.abs(Input.Position.Y - DropTouchStartY) > SCROLL_THRESHOLD then
                    DropTouchScrolled = true
                end
            end
        end)

        DropdownInteract.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.Touch and Input == DropTouchId then
                DropTouchId = nil
                if DropTouchScrolled then DropTouchScrolled = false return end
                if DropIsOpen then CloseDropdown() else OpenDropdown() end
            elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if DropIsOpen then CloseDropdown() else OpenDropdown() end
            end
        end)

        Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
            if not DropIsOpen then return end
            if not IsClick(Input) then return end
            task.defer(function()
                if not DropIsOpen then return end
                local pos = (Input.UserInputType == Enum.UserInputType.Touch)
                    and Vector2.new(Input.Position.X, Input.Position.Y)
                    or GetCursorPos()
                local ap, as = ListOuter.AbsolutePosition, ListOuter.AbsoluteSize
                local dp, ds = DropdownOuter.AbsolutePosition, DropdownOuter.AbsoluteSize
                local inList = pos.X >= ap.X and pos.X <= ap.X+as.X and pos.Y >= ap.Y and pos.Y <= ap.Y+as.Y
                local inBtn  = pos.X >= dp.X and pos.X <= dp.X+ds.X and pos.Y >= dp.Y and pos.Y <= dp.Y+ds.Y
                if not inList and not inBtn then
                    CloseDropdown()
                end
            end)
        end))
        Dropdown:SetValues();
        Dropdown:Display();
        local Default = Info.Default;
        if Default then Dropdown:SetValue(Default); end;
        Groupbox:AddBlank(Info.BlankSize or 5);
        Groupbox:Resize();
        Options[Idx] = Dropdown;
        return Dropdown;
    end;

    function Funcs:AddDependencyBox()
        local Depbox = {
            Dependencies = {};
        };
        local Groupbox = self;
        local Container = Groupbox.Container;
        local Holder = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 0, 0);
            Visible = false;
            Parent = Container;
        });
        local Frame = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 1, 0);
            Visible = true;
            Parent = Holder;
        });
        local Layout = Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Frame;
        });
        function Depbox:Resize()

            Holder.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y);
            Groupbox:Resize();
        end;

        Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
            Depbox:Resize();
        end);
        Holder:GetPropertyChangedSignal('Visible'):Connect(function()
            Depbox:Resize();
        end);
        function Depbox:Update()

            for _, Dependency in next, Depbox.Dependencies do
                local Elem = Dependency[1];
                local Value = Dependency[2];
                if Elem.Type == 'Toggle' and Elem.Value ~= Value then
                    Holder.Visible = false;
                    Depbox:Resize();
                    return;
                end;
            end;

            Holder.Visible = true;
            Depbox:Resize();
        end;

        function Depbox:SetupDependencies(Dependencies)
            for _, Dependency in next, Dependencies do
                assert(type(Dependency) == 'table', 'SetupDependencies: Dependency is not of type `table`.');
                assert(Dependency[1], 'SetupDependencies: Dependency is missing element argument.');
                assert(Dependency[2] ~= nil, 'SetupDependencies: Dependency is missing value argument.');
            end;

            Depbox.Dependencies = Dependencies;
            Depbox:Update();
        end;

        Depbox.Container = Frame;
        setmetatable(Depbox, BaseGroupbox);
        table.insert(Library.DependencyBoxes, Depbox);
        return Depbox;
    end;

    BaseGroupbox.__index = Funcs;
    BaseGroupbox.__namecall = function(Table, Key, ...)
        return Funcs[Key](...);
    end;

    function Funcs:AddLeftGroupbox(Name)
        if self.AddGroupbox then return self:AddGroupbox({ Side = 1; Name = Name; }) end
        local g = { Container = self.Container; TextLabel = self.TextLabel; }
        setmetatable(g, BaseGroupbox); return g
    end

    function Funcs:AddRightGroupbox(Name)
        if self.AddGroupbox then return self:AddGroupbox({ Side = 2; Name = Name; }) end
        local g = { Container = self.Container; TextLabel = self.TextLabel; }
        setmetatable(g, BaseGroupbox); return g
    end
end;

do

    Library.NotificationArea = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 0, 0, 40);
        Size = UDim2.new(0, 300, 0, 200);
        ZIndex = 100;
        Parent = ScreenGui;
    });
    Library:Create('UIListLayout', {
        Padding = UDim.new(0, 4);
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = Library.NotificationArea;
    });
    local WatermarkOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 100, 0, -25);
        Size = UDim2.new(0, 213, 0, 20);
        ZIndex = 200;
        Visible = false;
        Parent = ScreenGui;
    });
    local WatermarkInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.AccentColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 201;
        Parent = WatermarkOuter;
    });
    Library:AddToRegistry(WatermarkInner, {
        BorderColor3 = 'AccentColor';
    });
    local InnerFrame = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderSizePixel = 0;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 202;
        Parent = WatermarkInner;
    });
    local Gradient = Library:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
            ColorSequenceKeypoint.new(1, Library.MainColor),
        });
        Rotation = -90;
        Parent = InnerFrame;
    });
    Library:AddToRegistry(Gradient, {
        Color = function()
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                ColorSequenceKeypoint.new(1, Library.MainColor),
            });
        end
    });
    local WatermarkLabel = Library:CreateLabel({
        Position = UDim2.new(0, 5, 0, 0);
        Size = UDim2.new(1, -4, 1, 0);
        TextSize = 14;
        TextXAlignment = Enum.TextXAlignment.Left;
        ZIndex = 203;
        Parent = InnerFrame;
    });
    Library.Watermark = WatermarkOuter;
    Library.WatermarkText = WatermarkLabel;
    Library:MakeDraggable(Library.Watermark);
    local KeybindOuter = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0, 0.5);
        BorderSizePixel = 0;
        Position = UDim2.new(0, 14, 0.5, 0);
        Size = UDim2.new(0, 240, 0, 20);
        Visible = false;
        ZIndex = 100;
        Parent = ScreenGui;
    });
    Library:Create('UICorner', { CornerRadius = UDim.new(0, 6), Parent = KeybindOuter });
    local KeybindInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderSizePixel = 0;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 101;
        Parent = KeybindOuter;
    });
    Library:Create('UICorner', { CornerRadius = UDim.new(0, 6), Parent = KeybindInner });
    Library:AddToRegistry(KeybindInner, {
        BackgroundColor3 = 'MainColor';
    }, true);
    local KeybindStroke = Library:Create('UIStroke', {
        Color = Library.OutlineColor;
        Thickness = 1;
        Transparency = 0.35;
        Parent = KeybindInner;
    });
    Library:AddToRegistry(KeybindStroke, {
        Color = 'OutlineColor';
    }, true);
    local ColorFrame = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Size = UDim2.new(1, -12, 0, 2);
        Position = UDim2.new(0, 6, 0, 6);
        ZIndex = 102;
        Parent = KeybindInner;
    });
    Library:Create('UICorner', { CornerRadius = UDim.new(0, 2), Parent = ColorFrame });
    Library:AddToRegistry(ColorFrame, {
        BackgroundColor3 = 'AccentColor';
    }, true);
    local KeybindLabel = Library:CreateLabel({
        Size = UDim2.new(1, -12, 0, 18);
        Position = UDim2.fromOffset(8, 10),
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Library.Font,
        TextSize = 13,
        Text = 'Keybinds';
        TextColor3 = Library.FontColor;
        ZIndex = 104;
        Parent = KeybindInner;
    });
    local KeybindContainer = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, -12, 1, -30);
        Position = UDim2.new(0, 6, 0, 28);
        ZIndex = 1;
        Parent = KeybindInner;
    });
    Library:Create('UIListLayout', {
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = KeybindContainer;
    });
    Library:Create('UIPadding', {
        PaddingLeft = UDim.new(0, 5),
        Parent = KeybindContainer,
    })
    Library.KeybindFrame = KeybindOuter;
    Library.KeybindContainer = KeybindContainer;
    Library:MakeDraggable(KeybindOuter);
end;

function Library:SetKeybindFrameVisibility(Bool)
    if Library.KeybindFrame then
        Library.KeybindFrame.Visible = Bool;
    end;
end;

function Library:SetWatermarkVisibility(Bool)
    Library.Watermark.Visible = Bool;
end;

function Library:SetWatermark(Text)
    local X, Y = Library:GetTextBounds(Text, Library.Font, 14);
    Library.Watermark.Size = UDim2.new(0, X + 15, 0, (Y * 1.5) + 3);
    Library:SetWatermarkVisibility(true)
    Library.WatermarkText.Text = Text;
end;

function Library:Notify(Text, Time)
    local XSize, YSize = Library:GetTextBounds(Text, Library.Font, 14);
    YSize = YSize + 7
    local NotifyOuter = Library:Create('Frame', {
        BorderColor3 = Color3.new(0, 0, 0);
        Position = UDim2.new(0, 100, 0, 10);
        Size = UDim2.new(0, 0, 0, YSize);
        ClipsDescendants = true;
        ZIndex = 100;
        Parent = Library.NotificationArea;
    });
    local NotifyInner = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderColor3 = Library.OutlineColor;
        BorderMode = Enum.BorderMode.Inset;
        Size = UDim2.new(1, 0, 1, 0);
        ZIndex = 101;
        Parent = NotifyOuter;
    });
    Library:AddToRegistry(NotifyInner, {
        BackgroundColor3 = 'MainColor';
        BorderColor3 = 'OutlineColor';
    }, true);
    local InnerFrame = Library:Create('Frame', {
        BackgroundColor3 = Color3.new(1, 1, 1);
        BorderSizePixel = 0;
        Position = UDim2.new(0, 1, 0, 1);
        Size = UDim2.new(1, -2, 1, -2);
        ZIndex = 102;
        Parent = NotifyInner;
    });
    local Gradient = Library:Create('UIGradient', {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
            ColorSequenceKeypoint.new(1, Library.MainColor),
        });
        Rotation = -90;
        Parent = InnerFrame;
    });
    Library:AddToRegistry(Gradient, {
        Color = function()
            return ColorSequence.new({
                ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                ColorSequenceKeypoint.new(1, Library.MainColor),
            });
        end
    });
    local NotifyLabel = Library:CreateLabel({
        Position = UDim2.new(0, 4, 0, 0);
        Size = UDim2.new(1, -4, 1, 0);
        Text = Text;
        TextXAlignment = Enum.TextXAlignment.Left;
        TextSize = 14;
        ZIndex = 103;
        Parent = InnerFrame;
    });
    local LeftColor = Library:Create('Frame', {
        BackgroundColor3 = Library.AccentColor;
        BorderSizePixel = 0;
        Position = UDim2.new(0, -1, 0, -1);
        Size = UDim2.new(0, 3, 1, 2);
        ZIndex = 104;
        Parent = NotifyOuter;
    });
    Library:AddToRegistry(LeftColor, {
        BackgroundColor3 = 'AccentColor';
    }, true);
    pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, XSize + 8 + 4, 0, YSize), 'Out', 'Quad', 0.4, true);
    task.spawn(function()
        wait(Time or 5);
        pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, 0, 0, YSize), 'Out', 'Quad', 0.4, true);
        wait(0.4);
        NotifyOuter:Destroy();
    end);
end;

function Library:CreateWindow(...)
    local Arguments = { ... }
    local Config = { AnchorPoint = Vector2.zero }
    if type(...) == 'table' then
        Config = ...;
    else
        Config.Title = Arguments[1]
        Config.AutoShow = Arguments[2] or false;
    end

    if type(Config.Title) ~= 'string' then Config.Title = 'KAMIDERE' end
    if type(Config.MenuFadeTime) ~= 'number' then Config.MenuFadeTime = 0.2 end
    if typeof(Config.Position) ~= 'UDim2' then Config.Position = UDim2.fromOffset(175, 50) end
    if typeof(Config.Size) ~= 'UDim2' then Config.Size = UDim2.fromOffset(740, 520) end
    if Config.Center then
        Config.AnchorPoint = Vector2.new(0.5, 0.5)
        Config.Position = UDim2.fromScale(0.5, 0.5)
    end

    local Window = { Tabs = {} };
    local Outer = Library:Create('Frame', {
        AnchorPoint = Config.AnchorPoint,
        BackgroundColor3 = Library.BackgroundColor,
        BorderSizePixel = 0,
        Position = Config.Position,
        Size = Config.Size,
        Visible = false;
        ZIndex = 1;
        Parent = ScreenGui;
    });
    Library:Create('UICorner', { CornerRadius = UDim.new(0, 8), Parent = Outer });
    Library:AddToRegistry(Outer, { BackgroundColor3 = 'BackgroundColor' });

    local MinimizeMode = Config.MinimizeMode or 'titlebar'

    local WindowLabel = Library:CreateLabel({
        Position = UDim2.fromOffset(16, 0),
        Size = UDim2.new(1, -90, 0, 40),
        Text = Config.Title,
        Font = Library.Font,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Library.FontColor,
        ZIndex = 3;
        Parent = Outer;
    });
    Library:AddToRegistry(WindowLabel, { TextColor3 = 'FontColor' });

    local ICON_CHEVRON_DOWN  = 'rbxassetid://134243273101015'
    local ICON_CHEVRON_RIGHT = 'rbxassetid://92473583511724'
    local ICON_X             = 'rbxassetid://110786993356448'

    local MinimizeBtn = Library:Create('ImageButton', {
        BackgroundTransparency = 1;
        Position = UDim2.new(1, -66, 0, 10);
        Size = UDim2.fromOffset(20, 20);
        Image = ICON_CHEVRON_DOWN;
        ImageColor3 = Color3.fromRGB(180, 180, 180);
        ZIndex = 10;
        Parent = Outer;
    });
    local CloseBtn = Library:Create('ImageButton', {
        BackgroundTransparency = 1;
        Position = UDim2.new(1, -38, 0, 10);
        Size = UDim2.fromOffset(20, 20);
        Image = ICON_X;
        ImageColor3 = Color3.fromRGB(180, 180, 180);
        ZIndex = 10;
        Parent = Outer;
    });
    for _, btn in ipairs({ MinimizeBtn, CloseBtn }) do
        btn.MouseEnter:Connect(function() btn.ImageColor3 = Library.AccentColor end)
        btn.MouseLeave:Connect(function() btn.ImageColor3 = Color3.fromRGB(180, 180, 180) end)
    end

    local IsMinimized = false
    local WindowFullSize = Config.Size

    local function DoMinimize(state)
        IsMinimized = state
        if MinimizeMode == 'full' then
            Outer.Visible = not state
        else
            local target = state and UDim2.fromOffset(WindowFullSize.X.Offset, 40) or WindowFullSize
            TweenService:Create(Outer, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = target }):Play()
            task.delay(state and 0 or 0.25, function()
                if LeftPanel then LeftPanel.Visible = not state end
                if TabContainer then TabContainer.Visible = not state end
            end)
        end
        MinimizeBtn.Image = state and ICON_CHEVRON_RIGHT or ICON_CHEVRON_DOWN
    end

    function Window:Minimize() DoMinimize(not IsMinimized) end
    function Library:Minimize() DoMinimize(not IsMinimized) end

    local function ShowMinimizePicker()
        local PickOuter = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, MinimizeBtn.AbsolutePosition.X - Outer.AbsolutePosition.X - 60, 0, 42);
            Size = UDim2.fromOffset(160, 70);
            ZIndex = 50;
            Parent = Outer;
        })
        Library:Create('UICorner', { CornerRadius = UDim.new(0, 6), Parent = PickOuter })
        Library:AddToRegistry(PickOuter, { BackgroundColor3 = 'MainColor' })
        local UIStroke = Instance.new('UIStroke')
        UIStroke.Color = Library.OutlineColor
        UIStroke.Thickness = 1
        UIStroke.Parent = PickOuter
        Library:AddToRegistry(UIStroke, { Color = 'OutlineColor' })

        local options = {
            { label = 'Turn into Titlebar', mode = 'titlebar' },
            { label = 'Fully Minimize',     mode = 'full' },
        }
        for i, opt in ipairs(options) do
            local Row = Library:Create('TextButton', {
                BackgroundTransparency = 1;
                Position = UDim2.fromOffset(0, (i-1)*35);
                Size = UDim2.new(1, 0, 0, 35);
                Font = Library.Font;
                Text = opt.label;
                TextColor3 = MinimizeMode == opt.mode and Library.AccentColor or Library.FontColor;
                TextSize = 13;
                ZIndex = 51;
                Parent = PickOuter;
            })
            Library:AddToRegistry(Row, { TextColor3 = MinimizeMode == opt.mode and 'AccentColor' or 'FontColor' })
            Row.InputBegan:Connect(function(Input)
                if IsClick(Input) then
                    MinimizeMode = opt.mode
                    PickOuter:Destroy()
                    DoMinimize(not IsMinimized)
                end
            end)
        end

        local conn
        conn = InputService.InputBegan:Connect(function(Input)
            if IsClick(Input) then
                local pos = GetCursorPos()
                local ap = PickOuter.AbsolutePosition
                local as = PickOuter.AbsoluteSize
                if pos.X < ap.X or pos.X > ap.X + as.X or pos.Y < ap.Y or pos.Y > ap.Y + as.Y then
                    PickOuter:Destroy()
                    conn:Disconnect()
                end
            end
        end)
    end

    local MinHoldStart = nil
    local MinHoldActive = false

    MinimizeBtn.InputBegan:Connect(function(Input)
        if not IsClick(Input) then return end
        MinHoldStart = tick()
        MinHoldActive = true
        task.spawn(function()
            while MinHoldActive do
                if tick() - MinHoldStart >= 10 then
                    MinHoldActive = false
                    ShowMinimizePicker()
                    return
                end
                task.wait(0.05)
            end
        end)
    end)

    MinimizeBtn.InputEnded:Connect(function(Input)
        if not IsClick(Input) then return end
        if not MinHoldActive then return end
        MinHoldActive = false
        if tick() - MinHoldStart < 10 then
            DoMinimize(not IsMinimized)
        end
    end)

    local function ShowCloseDialog()
        local Overlay = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(0,0,0);
            BackgroundTransparency = 0.5;
            BorderSizePixel = 0;
            Size = UDim2.fromScale(1,1);
            ZIndex = 500;
            Parent = ScreenGui;
        })
        local Dialog = Library:Create('Frame', {
            AnchorPoint = Vector2.new(0.5,0.5);
            BackgroundColor3 = Library.MainColor;
            BorderSizePixel = 0;
            Position = UDim2.fromScale(0.5,0.5);
            Size = UDim2.fromOffset(248,110);
            ZIndex = 501;
            Parent = ScreenGui;
        })
        Library:Create('UICorner', { CornerRadius = UDim.new(0,8), Parent = Dialog })
        Library:AddToRegistry(Dialog, { BackgroundColor3 = 'MainColor' })
        local AccentBar = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1,0,0,2);
            ZIndex = 502;
            Parent = Dialog;
        })
        Library:Create('UICorner', { CornerRadius = UDim.new(0,8), Parent = AccentBar })
        Library:AddToRegistry(AccentBar, { BackgroundColor3 = 'AccentColor' })
        Library:CreateLabel({ Position=UDim2.fromOffset(0,14); Size=UDim2.new(1,0,0,20); TextSize=14; Text='Close window?'; TextXAlignment=Enum.TextXAlignment.Center; ZIndex=503; Parent=Dialog; })
        Library:CreateLabel({ Position=UDim2.fromOffset(0,34); Size=UDim2.new(1,0,0,16); TextSize=12; Text='This will hide the UI.'; TextColor3=Color3.fromRGB(150,150,150); TextXAlignment=Enum.TextXAlignment.Center; ZIndex=503; Parent=Dialog; })
        local function MakeDialogBtn(text, xPos, color, callback)
            local Btn = Library:Create('Frame', { BackgroundColor3=color; BorderSizePixel=0; Position=UDim2.fromOffset(xPos,66); Size=UDim2.fromOffset(108,28); ZIndex=503; Parent=Dialog; })
            Library:Create('UICorner', { CornerRadius=UDim.new(0,6), Parent=Btn })
            local Lbl = Library:CreateLabel({ Size=UDim2.fromScale(1,1); TextSize=13; Text=text; ZIndex=504; Parent=Btn; })
            Library:RemoveFromRegistry(Lbl)
            Lbl.TextColor3 = Color3.fromRGB(255,255,255)
            Btn.InputBegan:Connect(function(Input)
                if IsClick(Input) then
                    Overlay:Destroy(); Dialog:Destroy()
                    if callback then callback() end
                end
            end)
        end
        MakeDialogBtn('Close window', 14, Library.AccentColor, function() task.spawn(Library.Toggle) end)
        MakeDialogBtn('Decline', 130, Library.OutlineColor, nil)
    end

    CloseBtn.InputEnded:Connect(function(Input)
        if IsClick(Input) then ShowCloseDialog() end
    end)

    local DragActive = false
    local DragOffsetX = 0
    local DragOffsetY = 0
    local DragTouchInput = nil

    local TitleBar = Library:Create('Frame', {
        BackgroundTransparency = 1;
        Position = UDim2.new(0, 0, 0, 0);
        Size = UDim2.new(1, -90, 0, 40);
        ZIndex = 5;
        Parent = Outer;
    })

    local function BeginDrag(inputPos, touchInput)
        if DragActive then return end
        DragActive = true
        DragTouchInput = touchInput
        local vp = workspace.CurrentCamera.ViewportSize
        DragOffsetX = inputPos.X - Outer.AbsolutePosition.X
        DragOffsetY = inputPos.Y - Outer.AbsolutePosition.Y
    end

    local function UpdateDrag(inputPos)
        if not DragActive then return end
        local vp = workspace.CurrentCamera.ViewportSize
        Outer.Position = UDim2.fromOffset(
            math.clamp(inputPos.X - DragOffsetX, 0, vp.X - Outer.AbsoluteSize.X),
            math.clamp(inputPos.Y - DragOffsetY, 0, vp.Y - Outer.AbsoluteSize.Y)
        )
    end

    local function EndDrag(touchInput)
        if touchInput and touchInput ~= DragTouchInput then return end
        DragActive = false
        DragTouchInput = nil
    end

    TitleBar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            BeginDrag(InputService:GetMouseLocation(), nil)
        elseif Input.UserInputType == Enum.UserInputType.Touch then
            BeginDrag(Vector2.new(Input.Position.X, Input.Position.Y), Input)
        end
    end)

    Library:GiveSignal(InputService.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateDrag(InputService:GetMouseLocation())
        elseif Input.UserInputType == Enum.UserInputType.Touch and Input == DragTouchInput then
            UpdateDrag(Vector2.new(Input.Position.X, Input.Position.Y))
        end
    end))

    Library:GiveSignal(InputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            EndDrag(nil)
        elseif Input.UserInputType == Enum.UserInputType.Touch then
            EndDrag(Input)
        end
    end))

    local LeftPanel = Library:Create('Frame', {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 150, 1, 0),
        ZIndex = 2,
        Parent = Outer;
    });
    local TabArea = Library:Create('ScrollingFrame', {
        BackgroundTransparency = 1;
        BorderSizePixel = 0;
        Position = UDim2.new(0, 15, 0, 30);
        Size = UDim2.new(1, -30, 1, -40);
        CanvasSize = UDim2.new(0, 0, 0, 0);
        ScrollBarThickness = 0;
        ZIndex = 3;
        Parent = LeftPanel;
    });
    local TabListLayout = Library:Create('UIListLayout', {
        Padding = UDim.new(0, 5);
        FillDirection = Enum.FillDirection.Vertical;
        SortOrder = Enum.SortOrder.LayoutOrder;
        Parent = TabArea;
    });
    TabListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        TabArea.CanvasSize = UDim2.fromOffset(0, TabListLayout.AbsoluteContentSize.Y + 10);
    end);
    local TabContainer = Library:Create('Frame', {
        AnchorPoint = Vector2.new(0, 0),
        BackgroundColor3 = Library.BackgroundColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 151, 0, 40),
        Size = UDim2.new(1, -151, 1, -40),
        ClipsDescendants = true,
        ZIndex = 1,
        Parent = Outer;
    });
    Library:Create('UICorner', { CornerRadius = UDim.new(0, 6), Parent = TabContainer });
    Library:AddToRegistry(TabContainer, { BackgroundColor3 = 'BackgroundColor' });
    function Window:SetWindowTitle(Title)
        WindowLabel.Text = Title;
    end;

    if Config.Footer then
        local Footer = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderSizePixel = 0;
            AnchorPoint = Vector2.new(0, 1);
            Position = UDim2.new(0, 151, 1, 0);
            Size = UDim2.new(1, -151, 0, 22);
            ZIndex = 2;
            Parent = Outer;
        });
        Library:AddToRegistry(Footer, { BackgroundColor3 = 'MainColor' });
        Library:Create('UICorner', { CornerRadius = UDim.new(0, 8), Parent = Footer });
        Library:CreateLabel({
            Size = UDim2.fromScale(1, 1);
            TextSize = 11;
            Text = Config.Footer;
            TextColor3 = Color3.fromRGB(100, 100, 100);
            ZIndex = 3;
            Parent = Footer;
        });
    end

    local FooterText = Config.Footer or ''
    local Footer = Library:Create('Frame', {
        BackgroundColor3 = Library.MainColor;
        BorderSizePixel = 0;
        AnchorPoint = Vector2.new(0, 1);
        Position = UDim2.new(0, 151, 1, 0);
        Size = UDim2.new(1, -151, 0, 22);
        ZIndex = 2;
        Parent = Outer;
    })
    Library:Create('UICorner', { CornerRadius = UDim.new(0, 6), Parent = Footer })
    Library:AddToRegistry(Footer, { BackgroundColor3 = 'MainColor' })
    local FooterLabel = Library:CreateLabel({
        Size = UDim2.fromScale(1, 1);
        TextSize = 11;
        Text = FooterText;
        TextColor3 = Color3.fromRGB(100, 100, 100);
        ZIndex = 3;
        Parent = Footer;
    })
    Library:RemoveFromRegistry(FooterLabel)
    function Window:SetFooter(Text)
        FooterLabel.Text = Text or ''
    end

    function Window:AddTab(Name, IconID)
        local Tab = { Groupboxes = {}, Tabboxes = {} };
        local TabButton = Library:Create('Frame', {
            BackgroundTransparency = 1,
            BackgroundColor3 = Library.MainColor,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 24),
            ZIndex = 4,
            Parent = TabArea;
        });
        Library:Create('UICorner', { CornerRadius = UDim.new(0, 4), Parent = TabButton });
        Library:AddToRegistry(TabButton, { BackgroundColor3 = 'MainColor' });
        local TabHighlight = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor,
            BorderSizePixel = 0,
            Position = UDim2.new(1, 10, 0.5, -8),
            Size = UDim2.new(0, 2, 0, 16),
            Visible = false,
            ZIndex = 5,
            Parent = TabButton;
        });
        Library:Create('UICorner', { CornerRadius = UDim.new(0, 2), Parent = TabHighlight });
        Library:AddToRegistry(TabHighlight, { BackgroundColor3 = 'AccentColor' });
        local HasIcon = (IconID ~= nil and IconID ~= "")
        local TabIcon = nil
        if HasIcon then
            TabIcon = Library:Create('ImageLabel', {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 8, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                Image = '',
                ImageColor3 = Color3.fromRGB(130, 130, 130),
                ZIndex = 5,
                Parent = TabButton;
            });
            ApplyIcon(TabIcon, IconID);
            Library:AddToRegistry(TabIcon, {});
        end

        local TextOffset = HasIcon and 28 or 12
        local TabButtonLabel = Library:CreateLabel({
            Position = UDim2.new(0, TextOffset, 0, 0),
            Size = UDim2.new(1, -TextOffset, 1, 0),
            Text = Name,
            Font = Library.Font,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Color3.fromRGB(130, 130, 130),
            ZIndex = 5,
            Parent = TabButton;
        });
        local TabFrame = Library:Create('Frame', {
            Name = 'TabFrame',
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, 0);
            Visible = false;
            ZIndex = 2;
            Parent = TabContainer;
        });
        local LeftSide = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.new(0, 4, 0, 4);
            Size = UDim2.new(0.5, -6, 1, -8);
            CanvasSize = UDim2.new(0, 0, 0, 0);
            BottomImage = ''; TopImage = '';
            ScrollBarThickness = 0;
            ZIndex = 2;
            Parent = TabFrame;
        });
        local RightSide = Library:Create('ScrollingFrame', {
            BackgroundTransparency = 1;
            BorderSizePixel = 0;
            Position = UDim2.new(0.5, 2, 0, 4);
            Size = UDim2.new(0.5, -6, 1, -8);
            CanvasSize = UDim2.new(0, 0, 0, 0);
            BottomImage = ''; TopImage = '';
            ScrollBarThickness = 0;
            ZIndex = 2;
            Parent = TabFrame;
        });
        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 10);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Parent = LeftSide;
        });
        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 10);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            HorizontalAlignment = Enum.HorizontalAlignment.Center;
            Parent = RightSide;
        });
        for _, Side in next, { LeftSide, RightSide } do
            Side:WaitForChild('UIListLayout'):GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                Side.CanvasSize = UDim2.fromOffset(0, Side.UIListLayout.AbsoluteContentSize.Y);
            end);
        end;

        function Tab:ShowTab()
            for _, Tab in next, Window.Tabs do Tab:HideTab() end;
            TabHighlight.Visible = true;
            TabButton.BackgroundTransparency = 1;
            TabButtonLabel.TextColor3 = Library.FontColor;
            if HasIcon then
                TabIcon.ImageColor3 = Library.AccentColor;
                if not Library.RegistryMap[TabIcon] then Library.RegistryMap[TabIcon] = {Properties={}} end
                Library.RegistryMap[TabIcon].Properties.ImageColor3 = 'AccentColor';
            end

            if not Library.RegistryMap[TabButtonLabel] then Library.RegistryMap[TabButtonLabel] = {Properties={}} end
            Library.RegistryMap[TabButtonLabel].Properties.TextColor3 = 'FontColor';
            TabFrame.Visible = true;
        end;

        function Tab:HideTab()
            TabHighlight.Visible = false;
            TabButton.BackgroundTransparency = 1;
            TabButtonLabel.TextColor3 = Color3.fromRGB(130, 130, 130);
            if HasIcon then
                TabIcon.ImageColor3 = Color3.fromRGB(130, 130, 130);
                if Library.RegistryMap[TabIcon] then
                    Library.RegistryMap[TabIcon].Properties.ImageColor3 = nil;
                end
            end

            if Library.RegistryMap[TabButtonLabel] then
                Library.RegistryMap[TabButtonLabel].Properties.TextColor3 = nil;
            end

            TabFrame.Visible = false;
        end;

        function Tab:SetLayoutOrder(Position)
            TabButton.LayoutOrder = Position;
            TabListLayout:ApplyLayout();
        end;

        function Tab:AddGroupbox(Info)
            local Groupbox = {};
            local BoxOuter = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 507),
                ZIndex = 2,
                Parent = Info.Side == 1 and LeftSide or RightSide;
            });
            Library:Create('UICorner', { CornerRadius = UDim.new(0, 6), Parent = BoxOuter });
            Library:AddToRegistry(BoxOuter, { BackgroundColor3 = 'MainColor' });
            local GroupboxLabel = Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 18),
                Position = UDim2.new(0, 12, 0, 8),
                TextSize = 13,
                Text = Info.Name,
                Font = Library.Font,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextColor3 = Color3.fromRGB(150, 150, 150),
                ZIndex = 5,
                Parent = BoxOuter;
            });
            local Container = Library:Create('Frame', {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, 32),
                Size = UDim2.new(1, -24, 1, -32),
                ZIndex = 1,
                Parent = BoxOuter;
            });
            Library:Create('UIListLayout', {
                Padding = UDim.new(0, 4);
                FillDirection = Enum.FillDirection.Vertical,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = Container;
            });
            function Groupbox:Resize()

                local Size = 0;
                for _, Element in next, Groupbox.Container:GetChildren() do
                    if (not Element:IsA('UIListLayout')) and Element.Visible then
                        Size = Size + Element.Size.Y.Offset + 4;
                    end;
                end;

                BoxOuter.Size = UDim2.new(1, 0, 0, 32 + Size + 8);
            end;

            Groupbox.Container = Container;
            setmetatable(Groupbox, BaseGroupbox);
            Groupbox:Resize();
            Tab.Groupboxes[Info.Name] = Groupbox;
            return Groupbox;
        end;

        function Tab:AddLeftGroupbox(Name) return Tab:AddGroupbox({ Side = 1; Name = Name; }); end;
        function Tab:AddRightGroupbox(Name) return Tab:AddGroupbox({ Side = 2; Name = Name; }); end;
        function Tab:AddTabbox(Info)
            local Tabbox = { Tabs = {} };
            local BoxOuter = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                ZIndex = 2,
                Parent = Info.Side == 1 and LeftSide or RightSide;
            });
            Library:Create('UICorner', { CornerRadius = UDim.new(0, 6), Parent = BoxOuter });
            Library:AddToRegistry(BoxOuter, { BackgroundColor3 = 'MainColor' });
            local TabboxButtons = Library:Create('Frame', {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 1),
                Size = UDim2.new(1, 0, 0, 24),
                ZIndex = 5,
                Parent = BoxOuter;
            });
            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = TabboxButtons;
            });
            function Tabbox:AddTab(Name)

                local Tab = {};
                local Button = Library:Create('Frame', {
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0.5, 0, 1, 0),
                    ZIndex = 6,
                    Parent = TabboxButtons;
                });
                local ButtonLabel = Library:CreateLabel({
                    Size = UDim2.new(1, 0, 1, 0),
                    TextSize = 13,
                    Font = Library.Font,
                    Text = Name,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextColor3 = Library.FontColor,
                    ZIndex = 7,
                    Parent = Button;
                });
                local Underline = Library:Create('Frame', {
                    BackgroundColor3 = Library.AccentColor,
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(0.5, 0),
                    Position = UDim2.new(0.5, 0, 1, -2),
                    Size = UDim2.new(0.6, 0, 0, 2),
                    Visible = false,
                    ZIndex = 8,
                    Parent = Button;
                });
                Library:Create('UICorner', { CornerRadius = UDim.new(0, 4), Parent = Underline });
                Library:AddToRegistry(Underline, { BackgroundColor3 = 'AccentColor' });
                local Container = Library:Create('Frame', {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 4, 0, 28),
                    Size = UDim2.new(1, -8, 1, -28),
                    ZIndex = 1,
                    Visible = false,
                    Parent = BoxOuter;
                });
                Library:Create('UIListLayout', {
                    FillDirection = Enum.FillDirection.Vertical,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 4),
                    Parent = Container;
                });
                function Tab:Show()

                    for _, Tab in next, Tabbox.Tabs do Tab:Hide() end;
                    Container.Visible = true;
                    ButtonLabel.TextColor3 = Library.AccentColor;
                    if not Library.RegistryMap[ButtonLabel] then Library.RegistryMap[ButtonLabel] = {Properties={}} end
                    Library.RegistryMap[ButtonLabel].Properties.TextColor3 = 'AccentColor';
                    Underline.Visible = true;
                    Tab:Resize();
                end;

                function Tab:Hide()
                    Container.Visible = false;
                    ButtonLabel.TextColor3 = Library.FontColor;
                    if not Library.RegistryMap[ButtonLabel] then Library.RegistryMap[ButtonLabel] = {Properties={}} end
                    Library.RegistryMap[ButtonLabel].Properties.TextColor3 = 'FontColor';
                    Underline.Visible = false;
                end;

                function Tab:Resize()
                    local TabCount = 0;
                    for _, Tab in next, Tabbox.Tabs do TabCount = TabCount + 1 end;
                    for _, Button in next, TabboxButtons:GetChildren() do
                        if not Button:IsA('UIListLayout') then
                            Button.Size = UDim2.new(1 / TabCount, 0, 1, 0);
                        end;
                    end;

                    if (not Container.Visible) then return end;
                    local Size = 0;
                    for _, Element in next, Tab.Container:GetChildren() do
                        if (not Element:IsA('UIListLayout')) and Element.Visible then
                            Size = Size + Element.Size.Y.Offset + 4;
                        end;
                    end;

                    BoxOuter.Size = UDim2.new(1, 0, 0, 28 + Size + 6);
                end;

                Button.InputBegan:Connect(function(Input)
                    if IsClick(Input) and not Library:MouseIsOverOpenedFrame() then
                        Tab:Show(); Tab:Resize();
                    end;
                end);
                Tab.Container = Container;
                Tabbox.Tabs[Name] = Tab;
                setmetatable(Tab, BaseGroupbox);
                Tab:AddBlank(1);
                Tab:Resize();
                if #TabboxButtons:GetChildren() == 2 then Tab:Show() end;
                return Tab;
            end;

            Tab.Tabboxes[Info.Name or ''] = Tabbox;
            return Tabbox;
        end;

        function Tab:AddLeftTabbox(Name) return Tab:AddTabbox({ Name = Name, Side = 1; }); end;
        function Tab:AddRightTabbox(Name) return Tab:AddTabbox({ Name = Name, Side = 2; }); end;
        TabButton.InputBegan:Connect(function(Input)
            if IsClick(Input) then Tab:ShowTab() end;
        end);
        if #TabContainer:GetChildren() == 1 then Tab:ShowTab() end;
        Window.Tabs[Name] = Tab;
        return Tab;
    end;

    local ModalElement = Library:Create('TextButton', {
        BackgroundTransparency = 1;
        Size = UDim2.new(0, 0, 0, 0);
        Visible = true;
        Text = '';
        Modal = false;
        Parent = ScreenGui;
    });
    local TransparencyCache = {};
    local Toggled = false;
    local Fading = false;
    function Library:Toggle()

        if Fading then return end;
        local FadeTime = Config.MenuFadeTime;
        Fading = true;
        Toggled = (not Toggled);
        ModalElement.Modal = false ;
        if Toggled then
            Outer.Visible = true;
            task.spawn(function() do return end;
                local State = InputService.MouseIconEnabled;
                local Cursor = Drawing.new('Triangle');
                Cursor.Thickness = 1; Cursor.Filled = true; Cursor.Visible = false ;
                local CursorOutline = Drawing.new('Triangle');
                CursorOutline.Thickness = 1; CursorOutline.Filled = false;
                CursorOutline.Color = Color3.new(0, 0, 0); CursorOutline.Visible = false ;
                while Toggled and ScreenGui.Parent do
                    InputService.MouseIconEnabled = true ;
                    local mPos = InputService:GetMouseLocation();
                    Cursor.Color = Library.AccentColor;
                    Cursor.PointA = Vector2.new(mPos.X, mPos.Y);
                    Cursor.PointB = Vector2.new(mPos.X + 16, mPos.Y + 6);
                    Cursor.PointC = Vector2.new(mPos.X + 6, mPos.Y + 16);
                    CursorOutline.PointA = Cursor.PointA;
                    CursorOutline.PointB = Cursor.PointB;
                    CursorOutline.PointC = Cursor.PointC;
                    RenderStepped:Wait();
                end;

                InputService.MouseIconEnabled = true ;
                Cursor:Remove(); CursorOutline:Remove();
            end);
        end;

        for _, Desc in next, Outer:GetDescendants() do
            local Properties = {};
            if Desc:IsA('ImageLabel') then
                table.insert(Properties, 'ImageTransparency');
                table.insert(Properties, 'BackgroundTransparency');
            elseif Desc:IsA('TextLabel') or Desc:IsA('TextBox') then
                table.insert(Properties, 'TextTransparency');
            elseif Desc:IsA('Frame') or Desc:IsA('ScrollingFrame') then
                table.insert(Properties, 'BackgroundTransparency');
            elseif Desc:IsA('UIStroke') then
                table.insert(Properties, 'Transparency');
            end;

            local Cache = TransparencyCache[Desc];
            if (not Cache) then
                Cache = {};
                TransparencyCache[Desc] = Cache;
            end;

            for _, Prop in next, Properties do
                if not Cache[Prop] then Cache[Prop] = Desc[Prop] end;
                if Cache[Prop] == 1 then continue end;
                TweenService:Create(Desc, TweenInfo.new(FadeTime, Enum.EasingStyle.Linear), { [Prop] = Toggled and Cache[Prop] or 1 }):Play();
            end;
        end;

        task.wait(FadeTime);
        Outer.Visible = Toggled;
        Fading = false;
    end

    Library:GiveSignal(InputService.InputBegan:Connect(function(Input, Processed)
        if type(Library.ToggleKeybind) == 'table' and Library.ToggleKeybind.Type == 'KeyPicker' then
            if Library.ToggleKeybind.Value ~= 'None'
                and Input.UserInputType == Enum.UserInputType.Keyboard
                and Input.KeyCode.Name == Library.ToggleKeybind.Value then
                task.spawn(Library.Toggle)
            end

        elseif Input.KeyCode == Enum.KeyCode.RightControl or (Input.KeyCode == Enum.KeyCode.RightShift and (not Processed)) then
            task.spawn(Library.Toggle)
        end
    end))
    if Config.AutoShow then task.spawn(Library.Toggle) end
    Window.Holder = Outer;
    return Window;
end;

local function OnPlayerChange()
    local PlayerList = GetPlayersString();
    for _, Value in next, Options do
        if Value.Type == 'Dropdown' and Value.SpecialType == 'Player' then
            Value:SetValues(PlayerList);
        end;
    end;
end;

Players.PlayerAdded:Connect(OnPlayerChange);
Players.PlayerRemoving:Connect(OnPlayerChange);
local httpService = game:GetService('HttpService')
local SaveManager = {} do
	SaveManager.Folder = 'LinoriaLibSettings'
	SaveManager.Ignore = {}
	SaveManager.Parser = {
		Toggle = {
			Save = function(idx, object) 
				return { type = 'Toggle', idx = idx, value = object.Value } 
			end,

			Load = function(idx, data)
				if Toggles[idx] then 
					Toggles[idx]:SetValue(data.value)
				end
			end,
		},
		Slider = {
			Save = function(idx, object)
				return { type = 'Slider', idx = idx, value = tostring(object.Value) }
			end,

			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue(data.value)
				end
			end,
		},
		Dropdown = {
			Save = function(idx, object)
				return { type = 'Dropdown', idx = idx, value = object.Value, mutli = object.Multi }
			end,

			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue(data.value)
				end
			end,
		},
		ColorPicker = {
			Save = function(idx, object)
				return { type = 'ColorPicker', idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }
			end,

			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
				end
			end,
		},
		KeyPicker = {
			Save = function(idx, object)
				return { type = 'KeyPicker', idx = idx, mode = object.Mode, key = object.Value }
			end,

			Load = function(idx, data)
				if Options[idx] then 
					Options[idx]:SetValue({ data.key, data.mode })
				end
			end,
		},
		Input = {
			Save = function(idx, object)
				return { type = 'Input', idx = idx, text = object.Value }
			end,

			Load = function(idx, data)
				if Options[idx] and type(data.text) == 'string' then
					Options[idx]:SetValue(data.text)
				end
			end,
		},
	}
	function SaveManager:SetIgnoreIndexes(list)

		for _, key in next, list do
			self.Ignore[key] = true
		end
	end

	function SaveManager:SetFolder(folder)
		self.Folder = folder;
		self:BuildFolderTree()
	end

	function SaveManager:Save(name)
		if (not name) then
			return false, 'no config file is selected'
		end

		local fullPath = self.Folder .. '/settings/' .. name .. '.json'
		local data = {
			objects = {}
		}
		for idx, toggle in next, Toggles do
			if self.Ignore[idx] then continue end
			table.insert(data.objects, self.Parser[toggle.Type].Save(idx, toggle))
		end

		for idx, option in next, Options do
			if not self.Parser[option.Type] then continue end
			if self.Ignore[idx] then continue end
			table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
		end	

		local success, encoded = pcall(httpService.JSONEncode, httpService, data)
		if not success then
			return false, 'failed to encode data'
		end

		writefile(fullPath, encoded)
		return true
	end

	function SaveManager:Load(name)
		if (not name) then
			return false, 'no config file is selected'
		end

		local file = self.Folder .. '/settings/' .. name .. '.json'
		if not isfile(file) then return false, 'invalid file' end
		local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
		if not success then return false, 'decode error' end
		for _, option in next, decoded.objects do
			if self.Parser[option.type] then
				task.spawn(function() self.Parser[option.type].Load(option.idx, option) end)
			end
		end

		return true
	end

	function SaveManager:IgnoreThemeSettings()
		self:SetIgnoreIndexes({ 
			"BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor",
			"ThemeManager_ThemeList", 'ThemeManager_CustomThemeList', 'ThemeManager_CustomThemeName',
		})
	end

	function SaveManager:BuildFolderTree()
		local paths = {
			self.Folder,
			self.Folder .. '/themes',
			self.Folder .. '/settings'
		}
		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function SaveManager:RefreshConfigList()
		local list = listfiles(self.Folder .. '/settings')
		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == '.json' then
				local pos = file:find('.json', 1, true)
				local start = pos
				local char = file:sub(pos, pos)
				while char ~= '/' and char ~= '\\' and char ~= '' do
					pos = pos - 1
					char = file:sub(pos, pos)
				end

				if char == '/' or char == '\\' then
					table.insert(out, file:sub(pos + 1, start - 1))
				end
			end
		end

		return out
	end

	function SaveManager:SetLibrary(library)
		self.Library = library
	end

	function SaveManager:LoadAutoloadConfig()
		if isfile(self.Folder .. '/settings/autoload.txt') then
			local name = readfile(self.Folder .. '/settings/autoload.txt')
			local success, err = self:Load(name)
			if not success then
				return self.Library:Notify('Failed to load autoload config: ' .. err)
			end

			self.Library:Notify(string.format('Auto loaded config %q', name))
		end
	end

	function SaveManager:BuildConfigSection(tab)
		assert(self.Library, 'Must set SaveManager.Library')
		local section = tab:AddRightGroupbox('Configuration')
		section:AddInput('SaveManager_ConfigName',    { Text = 'Config name' })
		section:AddDropdown('SaveManager_ConfigList', { Text = 'Config list', Values = self:RefreshConfigList(), AllowNull = true })
		section:AddDivider()
		section:AddButton('Create config', function()
			local name = Options.SaveManager_ConfigName.Value
			if name:gsub(' ', '') == '' then 
				return self.Library:Notify('Invalid config name (empty)', 2)
			end

			local success, err = self:Save(name)
			if not success then
				return self.Library:Notify('Failed to save config: ' .. err)
			end

			self.Library:Notify(string.format('Created config %q', name))
			Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
			Options.SaveManager_ConfigList:SetValue(nil)
		end):AddButton('Load config', function()
			local name = Options.SaveManager_ConfigList.Value
			local success, err = self:Load(name)
			if not success then
				return self.Library:Notify('Failed to load config: ' .. err)
			end

			self.Library:Notify(string.format('Loaded config %q', name))
		end)
		section:AddButton('Save config', function()
			local name = Options.SaveManager_ConfigList.Value
			local success, err = self:Save(name)
			if not success then
				return self.Library:Notify('Failed to save config: ' .. err)
			end

			self.Library:Notify(string.format('saved config %q', name))
		end)
		section:AddButton('Refresh list', function()
			Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
			Options.SaveManager_ConfigList:SetValue(nil)
		end)
		section:AddButton('Set as autoload', function()
			local name = Options.SaveManager_ConfigList.Value
			writefile(self.Folder .. '/settings/autoload.txt', name)
			SaveManager.AutoloadLabel:SetText('Current autoload config: ' .. name)
			self.Library:Notify(string.format('Set %q to auto load', name))
		end)
		SaveManager.AutoloadLabel = section:AddLabel('Current autoload config: none', true)
		if isfile(self.Folder .. '/settings/autoload.txt') then
			local name = readfile(self.Folder .. '/settings/autoload.txt')
			SaveManager.AutoloadLabel:SetText('Current autoload config: ' .. name)
		end

		SaveManager:SetIgnoreIndexes({ 'SaveManager_ConfigList', 'SaveManager_ConfigName' })
	end

	SaveManager:BuildFolderTree()
end

local ThemeManager = {} do
	ThemeManager.Folder = 'LinoriaLibSettings'
	ThemeManager.Library = nil
	ThemeManager.BuiltInThemes = {
		['Default'] 		= { 1, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1c1c1c","AccentColor":"ffa1ce","BackgroundColor":"121212","OutlineColor":"464646"}') },
		['BBot'] 			= { 2, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1e1e","AccentColor":"7e48a3","BackgroundColor":"232323","OutlineColor":"141414"}') },
		['Fatality']		= { 3, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"1e1842","AccentColor":"c50754","BackgroundColor":"191335","OutlineColor":"3c355d"}') },
		['Jester'] 			= { 4, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"db4467","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
		['Mint'] 			= { 5, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"242424","AccentColor":"3db488","BackgroundColor":"1c1c1c","OutlineColor":"373737"}') },
		['Tokyo Night'] 	= { 6, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"191925","AccentColor":"6759b3","BackgroundColor":"16161f","OutlineColor":"323232"}') },
		['Ubuntu'] 			= { 7, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"3e3e3e","AccentColor":"e2581e","BackgroundColor":"323232","OutlineColor":"191919"}') },
		['Quartz'] 			= { 8, httpService:JSONDecode('{"FontColor":"ffffff","MainColor":"232330","AccentColor":"426e87","BackgroundColor":"1d1b26","OutlineColor":"27232f"}') },
	}
	function ThemeManager:ApplyTheme(theme)

		local customThemeData = self:GetCustomTheme(theme)
		local data = customThemeData or self.BuiltInThemes[theme]
		if not data then return end
		local scheme = data[2]
		for idx, col in next, customThemeData or scheme do
			self.Library[idx] = Color3.fromHex(col)
			if Options[idx] then
				Options[idx]:SetValueRGB(Color3.fromHex(col))
			end
		end

		self:ThemeUpdate()
	end

	function ThemeManager:ThemeUpdate()
		local options = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }
		for i, field in next, options do
			if Options and Options[field] then
				self.Library[field] = Options[field].Value
			end
		end

		self.Library.AccentColorDark = self.Library:GetDarkerColor(self.Library.AccentColor);
		self.Library:UpdateColorsUsingRegistry()
	end

	function ThemeManager:LoadDefault()		
		local theme = 'Default'
		local content = isfile(self.Folder .. '/themes/default.txt') and readfile(self.Folder .. '/themes/default.txt')
		local isDefault = true
		if content then
			if self.BuiltInThemes[content] then
				theme = content
			elseif self:GetCustomTheme(content) then
				theme = content
				isDefault = false;
			end

		elseif self.BuiltInThemes[self.DefaultTheme] then
		 	theme = self.DefaultTheme
		end

		if isDefault then
			Options.ThemeManager_ThemeList:SetValue(theme)
		else
			self:ApplyTheme(theme)
		end
	end

	function ThemeManager:SaveDefault(theme)
		writefile(self.Folder .. '/themes/default.txt', theme)
	end

	function ThemeManager:CreateThemeManager(groupbox)
		groupbox:AddLabel('Background color'):AddColorPicker('BackgroundColor', { Default = self.Library.BackgroundColor });
		groupbox:AddLabel('Main color')	:AddColorPicker('MainColor', { Default = self.Library.MainColor });
		groupbox:AddLabel('Accent color'):AddColorPicker('AccentColor', { Default = self.Library.AccentColor });
		groupbox:AddLabel('Outline color'):AddColorPicker('OutlineColor', { Default = self.Library.OutlineColor });
		groupbox:AddLabel('Font color')	:AddColorPicker('FontColor', { Default = self.Library.FontColor });
		local ThemesArray = {}
		for Name, Theme in next, self.BuiltInThemes do
			table.insert(ThemesArray, Name)
		end

		table.sort(ThemesArray, function(a, b) return self.BuiltInThemes[a][1] < self.BuiltInThemes[b][1] end)
		groupbox:AddDivider()
		groupbox:AddDropdown('ThemeManager_ThemeList', { Text = 'Theme list', Values = ThemesArray, Default = 1 })
		groupbox:AddButton('Set as default', function()
			self:SaveDefault(Options.ThemeManager_ThemeList.Value)
			self.Library:Notify(string.format('Set default theme to %q', Options.ThemeManager_ThemeList.Value))
		end)
		Options.ThemeManager_ThemeList:OnChanged(function()
			self:ApplyTheme(Options.ThemeManager_ThemeList.Value)
		end)
		groupbox:AddDivider()
		groupbox:AddInput('ThemeManager_CustomThemeName', { Text = 'Custom theme name' })
		groupbox:AddDropdown('ThemeManager_CustomThemeList', { Text = 'Custom themes', Values = self:ReloadCustomThemes(), AllowNull = true, Default = 1 })
		groupbox:AddDivider()
		groupbox:AddButton('Save theme', function() 
			self:SaveCustomTheme(Options.ThemeManager_CustomThemeName.Value)
			Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
			Options.ThemeManager_CustomThemeList:SetValue(nil)
		end):AddButton('Load theme', function() 
			self:ApplyTheme(Options.ThemeManager_CustomThemeList.Value) 
		end)
		groupbox:AddButton('Refresh list', function()
			Options.ThemeManager_CustomThemeList:SetValues(self:ReloadCustomThemes())
			Options.ThemeManager_CustomThemeList:SetValue(nil)
		end)
		groupbox:AddButton('Set as default', function()
			if Options.ThemeManager_CustomThemeList.Value ~= nil and Options.ThemeManager_CustomThemeList.Value ~= '' then
				self:SaveDefault(Options.ThemeManager_CustomThemeList.Value)
				self.Library:Notify(string.format('Set default theme to %q', Options.ThemeManager_CustomThemeList.Value))
			end
		end)
		ThemeManager:LoadDefault()
		local function UpdateTheme()

			self:ThemeUpdate()
		end

		Options.BackgroundColor:OnChanged(UpdateTheme)
		Options.MainColor:OnChanged(UpdateTheme)
		Options.AccentColor:OnChanged(UpdateTheme)
		Options.OutlineColor:OnChanged(UpdateTheme)
		Options.FontColor:OnChanged(UpdateTheme)
	end

	function ThemeManager:GetCustomTheme(file)
		local path = self.Folder .. '/themes/' .. file
		if not isfile(path) then
			return nil
		end

		local data = readfile(path)
		local success, decoded = pcall(httpService.JSONDecode, httpService, data)
		if not success then
			return nil
		end

		return decoded
	end

	function ThemeManager:SaveCustomTheme(file)
		if file:gsub(' ', '') == '' then
			return self.Library:Notify('Invalid file name for theme (empty)', 3)
		end

		local theme = {}
		local fields = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }
		for _, field in next, fields do
			theme[field] = Options[field].Value:ToHex()
		end

		writefile(self.Folder .. '/themes/' .. file .. '.json', httpService:JSONEncode(theme))
	end

	function ThemeManager:ReloadCustomThemes()
		local list = listfiles(self.Folder .. '/themes')
		local out = {}
		for i = 1, #list do
			local file = list[i]
			if file:sub(-5) == '.json' then
				local pos = file:find('.json', 1, true)
				local char = file:sub(pos, pos)
				while char ~= '/' and char ~= '\\' and char ~= '' do
					pos = pos - 1
					char = file:sub(pos, pos)
				end

				if char == '/' or char == '\\' then
					table.insert(out, file:sub(pos + 1))
				end
			end
		end

		return out
	end

	function ThemeManager:SetLibrary(lib)
		self.Library = lib
	end

	function ThemeManager:BuildFolderTree()
		local paths = {}
		local parts = self.Folder:split('/')
		for idx = 1, #parts do
			paths[#paths + 1] = table.concat(parts, '/', 1, idx)
		end

		table.insert(paths, self.Folder .. '/themes')
		table.insert(paths, self.Folder .. '/settings')
		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function ThemeManager:SetFolder(folder)
		self.Folder = folder
		self:BuildFolderTree()
	end

	function ThemeManager:CreateGroupBox(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		return tab:AddLeftGroupbox('Themes')
	end

	function ThemeManager:ApplyToTab(tab)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		local groupbox = self:CreateGroupBox(tab)
		self:CreateThemeManager(groupbox)
	end

	function ThemeManager:ApplyToGroupbox(groupbox)
		assert(self.Library, 'Must set ThemeManager.Library first!')
		self:CreateThemeManager(groupbox)
	end

	ThemeManager:BuildFolderTree()
end

Library.SaveManager = SaveManager
Library.ThemeManager = ThemeManager
Library.Icons = Icons
SaveManager:SetLibrary(Library)
ThemeManager:SetLibrary(Library)
getgenv().SaveManager = SaveManager
getgenv().ThemeManager = ThemeManager
getgenv().Library = Library
return Library
