local OpenGui = Instance.new("ScreenGui")
OpenGui.Name = "openshit"
OpenGui.Parent = LocalPlayer.PlayerGui
OpenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
OpenGui.ResetOnSpawn = false

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "mainopen"
OpenButton.Parent = OpenGui
OpenButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
OpenButton.BackgroundTransparency = 1
OpenButton.Position = UDim2.new(0.101969875, 0, 0.110441767, 0)
OpenButton.Size = UDim2.new(0, 64, 0, 42)
OpenButton.Text = ""
OpenButton.Visible = true

local OpenButtonCorner = Instance.new("UICorner")
OpenButtonCorner.Parent = OpenButton

local BackgroundImage = Instance.new("ImageLabel")
BackgroundImage.Name = "RotatingBackground"
BackgroundImage.Parent = OpenButton
BackgroundImage.Size = UDim2.new(1.8 + 0.1, 0, 1.8 + 0.1, 0)
BackgroundImage.Position = UDim2.new(0.5, 0, 0.5, 0)
BackgroundImage.AnchorPoint = Vector2.new(0.5, 0.5)
BackgroundImage.BackgroundTransparency = 1
BackgroundImage.Image = "rbxassetid://115629468950993"
BackgroundImage.SizeConstraint = Enum.SizeConstraint.RelativeXX
BackgroundImage.ZIndex = 0

local FrontImage = Instance.new("ImageLabel")
FrontImage.Name = "StaticIcon"
FrontImage.Parent = OpenButton
FrontImage.Size = UDim2.new(0.85, 0, 1, 0)
FrontImage.Position = UDim2.new(0.5, 0, 0.5, 0)
FrontImage.AnchorPoint = Vector2.new(0.5, 0.5)
FrontImage.BackgroundTransparency = 1
FrontImage.Image = "rbxassetid://80277179956565"
FrontImage.ZIndex = 1
FrontImage.ScaleType = Enum.ScaleType.Stretch 

local FrontImageCorner = Instance.new("UICorner")
FrontImageCorner.CornerRadius = UDim.new(1, 0)
FrontImageCorner.Parent = FrontImage

local Rotation = 0
local Speed = 90 
local LastTime = tick()

task.spawn(function()
	while true do
		local Now = tick()
		local Delta = Now - LastTime
		LastTime = Now
		
		Rotation = (Rotation + Speed * Delta) % 360
		BackgroundImage.Rotation = Rotation

		task.wait()
	end
end)

local function MakeDraggable(TopbarObject, Object, Locked)
    local Dragging = false
    local DragInput
    local DragStart
    local StartPosition

    local Holding = false
    local HoldTime = 1.0
    local MoveCancelThreshold = 6
    local HoldToken = 0

    Object:SetAttribute("Locked", Locked or false)

    local function Update(Input)
        if Object:GetAttribute("Locked") then return end
        local Delta = Input.Position - DragStart
        Object.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
    end

    local function ToggleLock()
        local NewState = not Object:GetAttribute("Locked")
        Object:SetAttribute("Locked", NewState)

        Fluent:Notify({
            Title = NewState and "Button Locked" or "Button Unlocked",
            Content = NewState and "This button is now locked in place." or "This button can now be moved.",
            Duration = 2
        })
    end

    TopbarObject.InputBegan:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1
        and Input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        Dragging = not Object:GetAttribute("Locked")
        Holding = true
        DragStart = Input.Position
        StartPosition = Object.Position

        HoldToken += 1
        local Token = HoldToken

        task.delay(HoldTime, function()
            if Holding and Token == HoldToken then
                ToggleLock()
            end
        end)

        Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then
                Dragging = false
                Holding = false
            end
        end)
    end)

    TopbarObject.InputChanged:Connect(function(Input)
        if not DragStart then return end

        if Input.UserInputType == Enum.UserInputType.MouseMovement
        or Input.UserInputType == Enum.UserInputType.Touch then
            if (Input.Position - DragStart).Magnitude > MoveCancelThreshold then
                Holding = false
            end
            DragInput = Input
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Input == DragInput and Dragging then
            Update(Input)
        end
    end)
end

MakeDraggable(OpenButton, OpenButton, false)

local function PlaySound(SoundId)
    local Sound = Instance.new("Sound")
    Sound.SoundId = "rbxassetid://" .. SoundId
    Sound.Parent = game:GetService("SoundService")
    Sound:Play()
    Sound.Ended:Connect(function()
        Sound:Destroy()
    end)
end

OpenButton.MouseButton1Click:Connect(function()
local SoundIds = { "7127123605", "137566474343039", "438666542", "257001341", "257000833", "7127123554", "131607746976396", "97325669841459", "109312518223078" }
    PlaySound(SoundIds[math.random(#SoundIds)])
    Window:Minimize()

    local function SmoothSpeed(Target, Duration)
        local Start = Speed
        local Steps = 30
        for Index = 1, Steps do
            Speed = Start + (Target - Start) * (Index / Steps)
            task.wait(Duration / Steps)
        end
        Speed = Target
    end
    
    SmoothSpeed(360, 0.4)
    task.wait(0.5)
    SmoothSpeed(180, 0.4)
    task.wait(0.3)
    SmoothSpeed(90, 0.4)
end)
