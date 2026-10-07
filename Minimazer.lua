local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "ToggleGui"
ToggleGui.Parent = LocalPlayer.PlayerGui
ToggleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ToggleGui.ResetOnSpawn = false

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ToggleGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Position = UDim2.new(0.101969875, 0, 0.110441767, 0)
ToggleButton.Size = UDim2.new(0, 64, 0, 42)
ToggleButton.Text = ""
ToggleButton.Visible = true

local ToggleButtonCorner = Instance.new("UICorner")
ToggleButtonCorner.Parent = ToggleButton

local RotatingBackground = Instance.new("ImageLabel")
RotatingBackground.Name = "RotatingBackground"
RotatingBackground.Parent = ToggleButton
RotatingBackground.Size = UDim2.new(1.9, 0, 1.9, 0)
RotatingBackground.Position = UDim2.new(0.5, 0, 0.5, 0)
RotatingBackground.AnchorPoint = Vector2.new(0.5, 0.5)
RotatingBackground.BackgroundTransparency = 1
RotatingBackground.Image = "rbxassetid://115629468950993"
RotatingBackground.SizeConstraint = Enum.SizeConstraint.RelativeXX
RotatingBackground.ZIndex = 0

local StaticIcon = Instance.new("ImageLabel")
StaticIcon.Name = "StaticIcon"
StaticIcon.Parent = ToggleButton
StaticIcon.Size = UDim2.new(0.85, 0, 1, 0)
StaticIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
StaticIcon.AnchorPoint = Vector2.new(0.5, 0.5)
StaticIcon.BackgroundTransparency = 1
StaticIcon.Image = "rbxassetid://80277179956565"
StaticIcon.ZIndex = 1
StaticIcon.ScaleType = Enum.ScaleType.Stretch

local StaticIconCorner = Instance.new("UICorner")
StaticIconCorner.CornerRadius = UDim.new(1, 0)
StaticIconCorner.Parent = StaticIcon

local CurrentRotation = 0
local RotationSpeed = 90
local LastTickTime = tick()

task.spawn(function()
	while true do
		local CurrentTime = tick()
		local DeltaTime = CurrentTime - LastTickTime
		LastTickTime = CurrentTime

		CurrentRotation = (CurrentRotation + RotationSpeed * DeltaTime) % 360
		RotatingBackground.Rotation = CurrentRotation

		task.wait()
	end
end)

local function MakeDraggable(DragHandle, TargetObject, IsLocked)
	local IsDragging = false
	local DragInput
	local DragStartPosition
	local ObjectStartPosition

	local IsHolding = false
	local HoldDuration = 1.0
	local MoveCancelThreshold = 6
	local HoldToken = 0

	TargetObject:SetAttribute("Locked", IsLocked or false)

	local function UpdatePosition(Input)
		if TargetObject:GetAttribute("Locked") then return end

		local Delta = Input.Position - DragStartPosition
		TargetObject.Position = UDim2.new(
			ObjectStartPosition.X.Scale,
			ObjectStartPosition.X.Offset + Delta.X,
			ObjectStartPosition.Y.Scale,
			ObjectStartPosition.Y.Offset + Delta.Y
		)
	end

	local function ToggleLock()
		local NewLockState = not TargetObject:GetAttribute("Locked")
		TargetObject:SetAttribute("Locked", NewLockState)

		Fluent:Notify({
			Title = NewLockState and "Button Locked" or "Button Unlocked",
			Content = NewLockState and "This button is now locked in place." or "This button can now be moved.",
			Duration = 2
		})
	end

	DragHandle.InputBegan:Connect(function(Input)
		if Input.UserInputType ~= Enum.UserInputType.MouseButton1
			and Input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		IsDragging = not TargetObject:GetAttribute("Locked")
		IsHolding = true
		DragStartPosition = Input.Position
		ObjectStartPosition = TargetObject.Position

		HoldToken += 1
		local CurrentToken = HoldToken

		task.delay(HoldDuration, function()
			if IsHolding and CurrentToken == HoldToken then
				ToggleLock()
			end
		end)

		Input.Changed:Connect(function()
			if Input.UserInputState == Enum.UserInputState.End then
				IsDragging = false
				IsHolding = false
			end
		end)
	end)

	DragHandle.InputChanged:Connect(function(Input)
		if not DragStartPosition then return end

		if Input.UserInputType == Enum.UserInputType.MouseMovement
			or Input.UserInputType == Enum.UserInputType.Touch then
			if (Input.Position - DragStartPosition).Magnitude > MoveCancelThreshold then
				IsHolding = false
			end
			DragInput = Input
		end
	end)

	UserInputService.InputChanged:Connect(function(Input)
		if Input == DragInput and IsDragging then
			UpdatePosition(Input)
		end
	end)
end

MakeDraggable(ToggleButton, ToggleButton, false)

local function PlaySound(SoundId)
	local NewSound = Instance.new("Sound")
	NewSound.SoundId = "rbxassetid://" .. SoundId
	NewSound.Parent = game:GetService("SoundService")
	NewSound:Play()
	NewSound.Ended:Connect(function()
		NewSound:Destroy()
	end)
end

local function SmoothSpeed(TargetSpeed, Duration)
	local StartSpeed = RotationSpeed
	local StepCount = 30

	for Step = 1, StepCount do
		RotationSpeed = StartSpeed + (TargetSpeed - StartSpeed) * (Step / StepCount)
		task.wait(Duration / StepCount)
	end

	RotationSpeed = TargetSpeed
end

local SoundIds = {
	"7127123605", "137566474343039", "438666542",
	"257001341", "257000833", "7127123554",
	"131607746976396", "97325669841459", "109312518223078",
}

ToggleButton.MouseButton1Click:Connect(function()
	PlaySound(SoundIds[math.random(#SoundIds)])
	Window:Minimize()

	SmoothSpeed(360, 0.4)
	task.wait(0.5)
	SmoothSpeed(180, 0.4)
	task.wait(0.3)
	SmoothSpeed(90, 0.4)
end)
