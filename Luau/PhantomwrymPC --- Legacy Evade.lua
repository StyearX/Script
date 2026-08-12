local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/StyearX/Script/refs/heads/main/Phantomwrym/Fluent-modded/Main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/StyearX/Script/refs/heads/main/Phantomwrym/Fluent-modded/SaveManager.lua"))()
local FBM = loadstring(game:HttpGet("https://raw.githubusercontent.com/StyearX/Script/refs/heads/main/Phantomwrym/Fluent-modded/FloatingButtonManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/StyearX/Script/refs/heads/main/Phantomwrym/Fluent-modded/InterfaceManager.lua"))()

if not Fluent or not SaveManager or not InterfaceManager or not FBM then return game.Players.LocalPlayer:Kick("Error: Interface didn't load") end

if _G.PhantomWyrmXIsAlreadyRunning then
   game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Script is already running!",
        Text = ""
    })
   return
end

_G.PhantomWyrmXIsAlreadyRunning = true

local Window = Fluent:CreateWindow({
    Title = "PhantomWyrm Hub X - Evade Legacy│PC",
    SubTitle = "v2.24.21 Made By Carey",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})


local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "rbxassetid://7733960981" }),
    Nextbots = Window:AddTab({ Title = "Anti Nextbots", Icon = "shield" }),
    Misc = Window:AddTab({ Title = "Movement", Icon = "rbxassetid://7734068321" }),
    Visual = Window:AddTab({ Title = "Visual", Icon = "rbxassetid://10709819149" }),
    Info = Window:AddTab({ Title = "Info", Icon = "rbxassetid://10723415903" }),
    Settings = Window:AddTab({ Title = "Configuration", Icon = "rbxassetid://7734052335" }),
    Extension = Window:AddTab({ Title = "Universal", Icon = "rbxassetid://10734930886" })
}

local Options = Fluent.Options

-- Services

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService('Lighting')
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local CAS = game:GetService("ContextActionService")

-- Optimize (1)

local function GetAutoDuration()
    local dt = RunService.RenderStepped:Wait()
    local fps = 1 / dt

    local duration = 60 / math.clamp(fps, 5, 60)
    return math.clamp(duration, 1, 6)
end

local Duration = GetAutoDuration()

-- Toggle Gui
local openshit = Instance.new("ScreenGui")
openshit.Name = "openshit"
openshit.Parent = LocalPlayer.PlayerGui
openshit.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
openshit.ResetOnSpawn = false

local mainopen = Instance.new("TextButton")
mainopen.Name = "mainopen"
mainopen.Parent = openshit
mainopen.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainopen.BackgroundTransparency = 1
mainopen.Position = UDim2.new(0.101969875, 0, 0.110441767, 0)
mainopen.Size = UDim2.new(0, 64, 0, 42)
mainopen.Text = ""
mainopen.Visible = true

local mainopens = Instance.new("UICorner")
mainopens.Parent = mainopen

local SizeBackMulti = 0.1
local AssetsIcon = "rbxassetid://"
local AssetsBackground = "rbxassetid://"

-- === ROTATING BACKGROUND IMAGE (inside the button) ===
local backgroundImage = Instance.new("ImageLabel")
backgroundImage.Name = "RotatingBackground"
backgroundImage.Parent = mainopen
backgroundImage.Size = UDim2.new(1.5 + SizeBackMulti, 0, 1.5 + SizeBackMulti, 0)
backgroundImage.Position = UDim2.new(0.5, 0, 0.5, 0)
backgroundImage.AnchorPoint = Vector2.new(0.5, 0.5)
backgroundImage.BackgroundTransparency = 1
backgroundImage.Image = AssetsBackground
backgroundImage.SizeConstraint = Enum.SizeConstraint.RelativeXX
backgroundImage.ZIndex = 0

-- === STATIC FRONT IMAGE ===
local frontImage = Instance.new("ImageLabel")
frontImage.Name = "StaticIcon"
frontImage.Parent = mainopen
frontImage.Size = UDim2.new(0.8, 0, 1, 0)
frontImage.Position = UDim2.new(0.5, 0, 0.5, 0)
frontImage.AnchorPoint = Vector2.new(0.5, 0.5)
frontImage.BackgroundTransparency = 1
frontImage.Image = AssetsIcon
frontImage.ZIndex = 1

local frontCorner = Instance.new("UICorner")
frontCorner.CornerRadius = UDim.new(1, 0)
frontCorner.Parent = frontImage

-- === ROTATION LOOP ===
local rotation = 0
local speed = 90 
local lastTime = tick()

task.spawn(function()
	while true do
		local now = tick()
		local delta = now - lastTime
		lastTime = now
		
		rotation = (rotation + speed * delta) % 360
		backgroundImage.Rotation = rotation

		task.wait()
	end
end)

local function MakeDraggable(topbarobject, object, locked)
    local Dragging = false
    local DragInput
    local DragStart
    local StartPosition

    local Holding = false
    local HoldTime = 1.0
    local MoveCancelThreshold = 6
    local HoldToken = 0

    object:SetAttribute("Locked", locked or false)

    local function Update(input)
        if object:GetAttribute("Locked") then return end
        local delta = input.Position - DragStart
        object.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + delta.Y
        )
    end

    local function ToggleLock()
        local newState = not object:GetAttribute("Locked")
        object:SetAttribute("Locked", newState)

        Fluent:Notify({
            Title = newState and "Button Locked" or "Button Unlocked",
            Content = newState and "This button is now locked in place." or "This button can now be moved.",
            Duration = 2
        })
    end

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        Dragging = not object:GetAttribute("Locked")
        Holding = true
        DragStart = input.Position
        StartPosition = object.Position

        HoldToken += 1
        local token = HoldToken

        task.delay(HoldTime, function()
            if Holding and token == HoldToken then
                ToggleLock()
            end
        end)

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                Dragging = false
                Holding = false
            end
        end)
    end)

    topbarobject.InputChanged:Connect(function(input)
        if not DragStart then return end

        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            if (input.Position - DragStart).Magnitude > MoveCancelThreshold then
                Holding = false
            end
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            Update(input)
        end
    end)
end

MakeDraggable(mainopen, mainopen, false)

local function playSound(soundId)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. soundId
    sound.Parent = game:GetService("SoundService")
    sound:Play()
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
end

mainopen.MouseButton1Click:Connect(function()
    local sounds = { "", "", "" }
    playSound(sounds[math.random(#sounds)])
    Window:Minimize()

    local function smoothSpeed(target, duration)
        local start = speed
        local steps = 30
        for i = 1, steps do
            speed = start + (target - start) * (i / steps)
            task.wait(duration / steps)
        end
        speed = target
    end
    
    smoothSpeed(360, 0.4)
    task.wait(0.5)
    smoothSpeed(180, 0.4)
    task.wait(0.3)
    smoothSpeed(90, 0.4)
end)

-- FPS Counter

local Stats = game:GetService("Stats")
local RunService = game:GetService("RunService")

local startTime = tick()
local FPS_Data = {
    GUI = nil,
    Connection = nil
}

local function ToggleFPSCounter(state)
    if not state then
        if FPS_Data.GUI then
            FPS_Data.GUI:Destroy()
            FPS_Data.GUI = nil
        end
        if FPS_Data.Connection then
            FPS_Data.Connection:Disconnect()
            FPS_Data.Connection = nil
        end
        return
    end

    if state and not FPS_Data.GUI then
        local fpsCounter = Instance.new("ScreenGui")
        fpsCounter.Name = "FPSCounter"
        fpsCounter.Parent = game.CoreGui
        fpsCounter.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        fpsCounter.ResetOnSpawn = false
        FPS_Data.GUI = fpsCounter

        local frame = Instance.new("Frame")
        frame.Parent = fpsCounter
        frame.Size = UDim2.new(0, 180, 0, 80)
        frame.Position = UDim2.new(0, 300, 0, 10)
        frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        frame.BackgroundTransparency = 0.7

        local corner = Instance.new("UICorner", frame)
        corner.CornerRadius = UDim.new(0, 15)

        local gradient = Instance.new("UIGradient", frame)
        gradient.Color = getgenv().ButtonGradients.Background

        local uiStroke = Instance.new("UIStroke", frame)
        uiStroke.Thickness = 2
        uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

        local gradientstroke = Instance.new("UIGradient", uiStroke)
        gradientstroke.Color = getgenv().ButtonGradients.Stroke

        
        task.spawn(function()
            while fpsCounter and fpsCounter.Parent do
                gradient.Rotation = (gradient.Rotation + 1) % 360
                gradient.Color = getgenv().ButtonGradients.Background 
                task.wait(0.03)
            end
        end)

        task.spawn(function()
            while fpsCounter and fpsCounter.Parent do
                gradientstroke.Rotation = (gradientstroke.Rotation + 0.5) % 360
                gradientstroke.Color = getgenv().ButtonGradients.Stroke
                task.wait()
            end
        end)

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, -10, 1, -10)
        label.Position = UDim2.new(0, 5, 0, 5)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBlack
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.Text = "Loading..."

        if typeof(MakeDraggable) == "function" then
            MakeDraggable(frame, frame, false)
        end

        local lastUpdateTime = tick()
        local frameCount = 0

        FPS_Data.Connection = RunService.RenderStepped:Connect(function()
            frameCount = frameCount + 1
            local now = tick()
            local dt = now - lastUpdateTime

            if dt >= 1 then
                local fps = math.round(frameCount / dt)
                local elapsed = now - startTime
                local h = math.floor(elapsed / 3600)
                local m = math.floor((elapsed % 3600) / 60)
                local s = math.floor(elapsed % 60)
                
                local ping = 0
                pcall(function()
                    ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                end)

                label.Text = string.format("FPS: %d | Ping: %d ms\nClient Timer: %dh %dm %ds", fps, ping, h, m, s)
                lastUpdateTime = now
                frameCount = 0
            end
        end)
    end
end

ToggleFPSCounter(true)

-- UNC Requirements

if not require then
    return LocalPlayer:Kick("UNC RESTRICTION MISSING: require(path) | PLEASE TRY OTHER EXECUTORS")
else
   print("Supported require()")
end

if not firetouchinterest  then
    return LocalPlayer:Kick("UNC RESTRICTION MISSING: firetouchinterest() | PLEASE TRY OTHER EXECUTORS")
else
   print("Supported firetouchinterest()")
end

if not setfpscap or setfpscap(500) then
    return LocalPlayer:Kick("UNC RESTRICTION MISSING: setfpscap() | PLEASE TRY OTHER EXECUTORS")
else
   print("Supported setfpscap()")
end

if game.Players then
   print("Advance Api")
else
   print("Common Api")
end

-- Scripts

function CreateBillboardESP(Name, Part, Color, TextSize)
  if not Part or Part:FindFirstChild(Name) then return nil end

  local BillboardGui = Instance.new("BillboardGui")
  local TextLabel = Instance.new("TextLabel")
  local TextStroke = Instance.new("UIStroke")

  BillboardGui.Parent = Part
  BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
  BillboardGui.Name = Name
  BillboardGui.AlwaysOnTop = true
  BillboardGui.LightInfluence = 1
  BillboardGui.Size = UDim2.new(0, 200, 0, 50)
  BillboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
  BillboardGui.MaxDistance = 1000

  TextLabel.Parent = BillboardGui
  TextLabel.BackgroundTransparency = 1
  TextLabel.Size = UDim2.new(1, 0, 1, 0)
  TextLabel.TextScaled = false
  TextLabel.Font = Enum.Font.SourceSans
  TextLabel.TextSize = TextSize or 14
  TextLabel.TextColor3 = Color or Color3.fromRGB(255, 255, 255)

  TextStroke.Parent = TextLabel
  TextStroke.Thickness = 1
  TextStroke.Color = Color3.new(0, 0, 0)

  return BillboardGui
end

function UpdateBillboardESP(Name, Part, NameText, Color, TextSize, PartPosition)
  if not Part then return false end

  local esp = Part:FindFirstChild(Name)
  if esp and esp:FindFirstChildOfClass("TextLabel") then
    local label = esp:FindFirstChildOfClass("TextLabel")
    
    if Color then
      label.TextColor3 = Color
    end
    
    if TextSize then
      label.TextSize = TextSize
    end
    
    if PartPosition then
      local Pos 
      if typeof(PartPosition) == "Instance" and PartPosition:IsA("BasePart") then
        Pos = PartPosition.Position
      elseif typeof(PartPosition) == "Vector3" then
        Pos = PartPosition
      end

      if Pos then
        local distance = math.floor((Pos - Part.Position).Magnitude)
        local name = NameText or Part.Parent and Part.Parent.Name or Part.Name
        label.Text = string.format("%s - [ %d M ]", name, distance)
      end
    else
      local name = NameText or Part.Parent and Part.Parent.Name or Part.Name
      label.Text = name
    end    
    return true
  end
  return false
end

function DestroyBillboardESP(Name, Part)
  if not Part then return false end
  
  local esp = Part:FindFirstChild(Name)
  if esp then
    esp:Destroy()
    return true
  end
  
  return false
end

function CreateTracerESP(tracerTable, part, thickness, color)
  local tracer = Drawing.new("Line")
  tracer.Thickness = thickness or 2
  tracer.Color = color or Color3.fromRGB(255, 255, 255)
  tracer.Transparency = 1
  tracer.Visible = false
  tracerTable[part] = tracer
  return tracer
end

function UpdateTracerESP(tracerTable, part, color)
  local tracer = tracerTable[part]
  if not tracer then return end

  if typeof(part) ~= "Instance" then
    tracerTable[part] = nil
    return
  end
  
  if not part.Parent or not part:IsDescendantOf(workspace) then
    tracer.Visible = false
    DestroyTracerESP(tracerTable, part)
    return
  end

  local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)  
  if onScreen then
    if color then tracer.Color = color end
    tracer.From = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y)
    tracer.To = Vector2.new(screenPos.X, screenPos.Y)
    tracer.Visible = true
  else
    tracer.Visible = false
  end
end

function DestroyTracerESP(tracerTable, part)
  if typeof(part) ~= "Instance" then
    tracerTable[part] = nil
    return
  end
  
  local tracer = tracerTable[part]
  if tracer then 
    if tracer.Remove then tracer:Remove() end
    tracerTable[part] = nil
  end 
end

function CreateHighlightESP(Name, Part, HighlightColor, OutlineColor, ShowHighlight)
  if not Part then return false end

  local Highlight = Instance.new("Highlight")
  Highlight.Name = Name
  Highlight.FillColor = HighlightColor or Color3.fromRGB(255, 255, 255)
  Highlight.OutlineColor = OutlineColor or Color3.fromRGB(0, 0, 0)

  if ShowHighlight then
    Highlight.FillTransparency = 0
  else
    Highlight.FillTransparency = 1
  end

  Highlight.OutlineTransparency = 0
  Highlight.Parent = Part

  return true
end

function UpdateHighlightESP(Name, Part, HighlightColor, OutlineColor, ShowHighlight)
  local Highlight = Part and Part:FindFirstChild(Name)

  if not Highlight or not Highlight:IsA("Highlight") then return false end

  if HighlightColor then Highlight.FillColor = HighlightColor end
  if OutlineColor then Highlight.OutlineColor = OutlineColor end

  if ShowHighlight ~= nil then
    Highlight.FillTransparency = ShowHighlight and 0 or 0.5
  end

  return true
end

function DestroyHighlightESP(Name, Part)
  local Highlight = Part and Part:FindFirstChild(Name)

  if Highlight and Highlight:IsA("Highlight") then
    Highlight:Destroy()
    return true
  end

  return false
end

-- Local Variables

local DFunctions = {}
local DConfiguration = {
    ESP = {
        Players = false,
        Nextbots = false,
        Tickets = false,
        Objective = false,
    },

    Tracers = {
        Players = false,
        Nextbots = false,
        Tickets = false,
        Objective = false,
    },
    
    Highlight = {
        Players = false,
        Nextbots = false,
        Tickets = false,
        Objective = false,
        OutlineOnly = false,
    },

    Boxes = {
        Players = false,
        Nextbots = false,
        Tickets = false,
        Objective = false,
    },

    Removals = {
        CameraShake = false,
        InvisibleWalls = false,
        DamageParts = false,
    },

    Main = {
        AntiAFK = true,
        AutoRespawn = false,
        RespawnType = "Spawnpoint",
        AutoWhistle = false,
        ShowTimer = false,
        Fly = false,
        FlySpeed = 20,
        Noclip = false,
    },

    Nextbots = {
        AntiNextbot = false,
        AntiNextbotRange = 15,
        AntiNextbotType = "Spawn",
    },

    Misc = {
        PlayerAdjustment = {
            Default = {
                Speed = 1500,
                JumpHeight = 3,
                AirStrafe = 182,
                GroundAcceleration = 1,
            },

            Update = {
                Speed = 1500,
                JumpHeight = 3,
                AirStrafe = 182,
                GroundAcceleration = 1,
            },

            Saved = {
                Speed = 1500,
                JumpHeight = 3,
                AirStrafe = 182,
                GroundAcceleration = 1,
            },

            Tick = {
                Speed = 0,
                JumpHeight = 0,
                AirStrafe = 0,
                GroundAcceleration = 0,
            },

            Debounce = {
                Speed = false,
                JumpHeight = false,
                AirStrafe = false,
                GroundAcceleration = false,
            },
        },

        Humanoids = {
            WalkspeedCF = false,
            OriginalJumpHeight = false,
            CF = 5,
            JP = 20,
        },

        Utilities = {
            GetCurrentSpeed = 0,

            BounceModification = {
                Enabled = false,
                DefaultBounce = 80,
                EmoteBounce = 120,
            },

            LagSwitch = {
                MSDelay = 200,
                Mode = "Normal",
            },
        },
        
        GameAutomation = {
            Macro = {
                SelectedPrimary = 1,
                FloatingButton = false,
                Keybind = false,
            },
        },

        MovementModification = {
            EmoteModification = {           
	            AggressiveEmoteDash = {
	                Enabled = false,
                    Type = "Blatant",
                    Speed = 3000,
                    Acceleration = -2,
	            },
	
                ModifyEmote = {
	                Enabled = true,
	                TurnSpeed = 0.5,
                },
	        },

            Gravity = {
                FloatingButton = false,
                Keybind = false,
                Value = 10,
            },

            BHOP = {
                Enabled = false,
                FloatingButton = false,
                AutoAcceleration = false,
                MaxSpeed = 70,
                JumpButton = false,
                HipHeight1 = 0,
                HipHeight2 = 0,
                Type = "Acceleration",
                JumpType = "Simulated",
                Acceleration = -0.1,
                lastTick = 0.01,
            },
        },

        AntiLags = {
            Low = false,
            Moderate = false,
            High = false,
        },
    },

    Visual = {
        OriginalCosmetics = {
            Cosmetics1 = "",
            Cosmetics2 = "",
            Cosmetics3 = "",
            Cosmetics4 = "",
        },
        
        ModifyCosmetics = {
            Cosmetics1 = "",
            Cosmetics2 = "",
            Cosmetics3 = "",
            Cosmetics4 = "",
        },

        OriginalEmotes = {
            Emote1 = "",
            Emote2 = "",
            Emote3 = "",
            Emote4 = "",
            Emote5 = "",
            Emote6 = "",
        },

        ModifyEmotes = {
            Emote1 = "",
            Emote2 = "",
            Emote3 = "",
            Emote4 = "",
            Emote5 = "",
            Emote6 = "",
        },
    },

    Settings = {
        GuiScale = {
            Respawn = 0,
            AutoCarry = 0,
            InstantRevive = 0,
            AutoEmoteDash = 0,
            MacroButton1 = 0,
            MacroButton2 = 0,
            Crouch = 0,
            Gravity = 0,
            AutoJump = 0,
            LagSwitch = 0,
        },
    },
}

-- Functions

function DFunctions.CreateButton(ButtonName, Name, Size1, Size2, ScriptLogic, CircleMode)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = ButtonName
    screenGui.Parent = LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false

    local frame = Instance.new("Frame")
    frame.Name = ButtonName
    frame.Size = UDim2.new(Size1, 0, Size2, 0)
    frame.Position = UDim2.new(0.5 - Size1 / 2, 0, 0.5 - Size2 / 2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BackgroundTransparency = 0.7
    frame.Parent = screenGui

    local gradient = Instance.new("UIGradient")
    gradient.Color = getgenv().ButtonGradients.Background
    gradient.Parent = frame

    task.spawn(function()
        while task.wait(0.03) do
            gradient.Rotation = (gradient.Rotation + 1) % 360
            gradient.Color = getgenv().ButtonGradients.Background
        end
    end)

	local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Parent = frame

    local gradientstroke = Instance.new("UIGradient")
    gradientstroke.Color = getgenv().ButtonGradients.Stroke
    
    gradientstroke.Rotation = 0
    gradientstroke.Parent = stroke

    task.spawn(function()
        while frame.Parent do
           gradientstroke.Rotation = (gradientstroke.Rotation + 0.5) % 360
           gradientstroke.Color = getgenv().ButtonGradients.Stroke
           task.wait()
        end
    end)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 15)
    corner.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = Name
    button.Font = Enum.Font.SourceSansBold
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 24
    button.TextScaled = false
    button.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 28, 0, 28)
    toggle.Position = UDim2.new(1, 6, 0.5, -14)
    toggle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    toggle.Text = "○"
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Visible = false
    toggle.Parent = frame

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(1, 0)
    tc.Parent = toggle

    local originalSize = UDim2.new(Size1, 0, Size2, 0)
    local holding = false
    local holdStart = 0
    local hideAt = 0

    frame:SetAttribute("IsCircle", false)

    local isCircle
    if CircleMode ~= nil then
        isCircle = CircleMode
    else
        isCircle = frame:GetAttribute("IsCircle")
    end

    local function applyShape(circle)
        frame:SetAttribute("IsCircle", circle)
        local s = math.min(frame.AbsoluteSize.X, frame.AbsoluteSize.Y)
        if circle then
            frame.Size = UDim2.new(0, s, 0, s)
            button.TextWrapped = true
            button.TextScaled = true
            button.TextSize = math.floor(s * 0.45)
            corner.CornerRadius = UDim.new(1, 0)
            toggle.Text = "▢"
        else
            frame.Size = originalSize
            button.TextWrapped = false
            button.TextScaled = false
            button.TextSize = 24
            corner.CornerRadius = UDim.new(0, 15)
            toggle.Text = "○"
        end
    end

    applyShape(isCircle)

    task.spawn(function()
        while task.wait(0.25) do
            if toggle.Visible and tick() - hideAt >= 10 then
                toggle.Visible = false
            end
        end
    end)

    button.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            holding = true
            holdStart = tick()
        end
    end)

    button.InputEnded:Connect(function(i)
        if holding and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
            holding = false
            if tick() - holdStart >= 0.6 then
                toggle.Visible = true
                hideAt = tick()
            end
        end
    end)

    toggle.MouseButton1Click:Connect(function()
        hideAt = tick()
        local current = frame:GetAttribute("IsCircle")
        applyShape(not current)
    end)

    button.Activated:Connect(function()
        if ScriptLogic then
            ScriptLogic(button)
        end
    end)

    FBM:AddButton(ButtonName, frame, false)
    MakeDraggable(button, frame, false)

    return button
end

function DFunctions.UpdateButton(Name, Size1, Size2)
    local gui = LocalPlayer.PlayerGui:FindFirstChild(Name)
    if gui then
        local frame = gui:FindFirstChild(Name)
        if frame then
            frame.Size = UDim2.new(Size1, 0, Size2, 0)
            local isCircle = frame:GetAttribute("IsCircle")
            if isCircle then
                local s = math.min(frame.AbsoluteSize.X, frame.AbsoluteSize.Y)
                frame.Size = UDim2.new(0, s, 0, s)
            end
        end
    end
end

function DFunctions.DestroyButton(Name)
	local gui = LocalPlayer.PlayerGui:FindFirstChild(Name)
	if gui then
		gui:Destroy()
	end
end

--main

function DFunctions.AutoRespawn()
 	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	 if char and char:GetAttribute("Downed") == true and DConfiguration.Main.RespawnType == "Spawnpoint" then
		 game:GetService("ReplicatedStorage").Events.Respawn:FireServer()
     elseif char and char:GetAttribute("Downed") == true and DConfiguration.Main.RespawnType == "Fake Revive" then
	     local PreviousPosition
	     PreviousPosition = LocalPlayer.Character.HumanoidRootPart.Position
    	 wait(0.2)
	     game:GetService("ReplicatedStorage").Events.Respawn:FireServer()
	     wait(1)
	     LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(PreviousPosition)
	 end
end

function DFunctions.Whistle()
    LocalPlayer.PlayerScripts.Events.KeybindUsed:Fire("Whistle", true)
    game:GetService("ReplicatedStorage").Events.Whistle:FireServer()
end

function DFunctions.RemoveDamagePart()
   local Map = game.Workspace.Game.Map
   
   for i, v in pairs(Map:GetDescendants()) do
     if v:IsA("BasePart") and v.CanTouch == true then
          v.CanTouch = false
       end
   end
end

function DFunctions.DisableTouch(t)
	for i, v in next, t:GetChildren() do
		if v.IsA(v, 'BasePart') then
			v.CanTouch = false
		end
	end
end

function DFunctions.DisableInvisParts(state)
    for i, v in pairs(Workspace.Game.Map.InvisParts:GetChildren()) do
       if v:IsA("BasePart") then
          v.CanCollide = state
       end
    end
end

function DFunctions.CreateTimer()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Parent = LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.Name = "TimerGui"

    local timerLabel = Instance.new("TextLabel")
    timerLabel.Parent = screenGui
    timerLabel.Size = UDim2.new(0, 200, 0, 50)
    timerLabel.Position = UDim2.new(0.5, -100, 0.1, 0) 
    timerLabel.BackgroundTransparency = 1 
    timerLabel.TextScaled = true
    timerLabel.Font = Enum.Font.SourceSans
    timerLabel.TextColor3 = Color3.new(1, 1, 1) 
end

function DFunctions.RemoveTimer()
   if LocalPlayer.PlayerGui:FindFirstChild("TimerGui") then
       LocalPlayer.PlayerGui.TimerGui:Destroy()
    end
end

function DFunctions.Noclip()
   pcall(function()
      for i, v in pairs(LocalPlayer.Character:GetDescendants()) do
          if v:IsA("BasePart") and v:IsA("MeshPart") then
              v.CanCollide = false
          end
      end
   end)
end

-- nExtbots

function DFunctions.AntiNextbot()
    if game.Workspace:FindFirstChild("Game") and game.Workspace.Game:FindFirstChild("Players") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    
        local playerTeam = game.Workspace.Game.Players[LocalPlayer.Name]:GetAttribute("Team")
        if playerTeam == "Nextbot" then
            return 
        end
    
        for i, v in pairs(game.Workspace.Game.Players:GetDescendants()) do
            if v:IsA("Model") and v:GetAttribute("Team") == "Nextbot" then
                local humanoidRootPart = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("HRP")
                if humanoidRootPart then
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                    
                    if distance < DConfiguration.Combat.AntiNextbotRange then
                        if DConfiguration.Combat.AntiNextbotType == "Spawn" then
                            local parts = workspace.Game.Map.ItemSpawns:GetChildren()
                            local randomPart = parts[math.random(1, #parts)]
                            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(randomPart.Position)
                        elseif DConfiguration.Combat.AntiNextbotType == "Players" then
                            local randomPlayer = Players:GetPlayers()[math.random(1, #game.Players:GetPlayers())]
                            if randomPlayer then
                              LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(randomPlayer.Character.Head.Position.X, randomPlayer.Character.Head.Position.Y, randomPlayer.Character.Head.Position.Z)
                            end
                        end
                    end
                end
            end
        end
    end
end

function DFunctions.HookMovement(char)
    local success, module = pcall(function()
        return require(char:WaitForChild("Movement"))
    end)
    if not success then return end

    local oldFriction
    local oldAccel

    if module.ApplyFriction then
        oldFriction = hookfunction(module.ApplyFriction, function(...)
            local args = {...}

            if args[2] and char:GetAttribute("Crouching") == true then
                args[2] = math.max(-0.1, DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration - 0.9)
            elseif args[2] then
                args[2] = DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration
            end

            return oldFriction(unpack(args))
        end)
    end

    if module.Accelerate then
        oldAccel = hookfunction(module.Accelerate, function(...)
            local args = {...}

            if args[3] == 182 or args[4] == 182 then
                args[3] = DConfiguration.Misc.PlayerAdjustment.Update.AirStrafe
                args[4] = DConfiguration.Misc.PlayerAdjustment.Update.AirStrafe
            end

            return oldAccel(unpack(args))
        end)
    end
end

function DFunctions.GetSpeedometer()
    local currentspeed = LocalPlayer.Character:GetAttribute("CurrentMoveSpeed")
    
    return currentspeed
end

local CachedRayParams = RaycastParams.new()
CachedRayParams.FilterType = Enum.RaycastFilterType.Exclude

function DFunctions.StartLag(ms)
	local LagTime = ms * 0.002
	local mode = DConfiguration.Misc.Utilities.LagSwitch.Mode
	local character = LocalPlayer.Character
	if not character then return end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local storedVelocity = hrp.AssemblyLinearVelocity
	if storedVelocity.Magnitude < 1 then return end

	local start = tick()
	while tick() - start < LagTime do end
	
	if mode == "FastFlag" or LagTime < 0.2 then
	   setfflag("MaxMissedWorldStepsRemembered", "9999")
	   return
	end
	
	if mode ~= "Demon" or LagTime < 0.2 then return end
	
	CachedRayParams.FilterDescendantsInstances = {character}

	local multiplier = math.random(2, 4)
	local horizontalVelocity = Vector3.new(storedVelocity.X, 0, storedVelocity.Z)
	local direction = horizontalVelocity.Magnitude > 0 and horizontalVelocity.Unit or hrp.CFrame.LookVector
	local distance = math.min(horizontalVelocity.Magnitude * LagTime * multiplier, 30)
	local forwardPos = hrp.Position + direction * distance
	local targetPos = forwardPos

	local forwardResult = workspace:Raycast(hrp.Position, forwardPos - hrp.Position, CachedRayParams)
	if forwardResult then
		targetPos = forwardResult.Position - direction * 2
	end

	local function detectSlope(dir, dist)
		return workspace:Raycast(hrp.Position + dir * dist, Vector3.new(0, -60, 0), CachedRayParams)
	end

	local longSlopeCheck = detectSlope(direction, 50)
	local shortSlopeCheck = nil

	for i = 2, 20, 2 do
		local result = detectSlope(direction, i)
		if result then
			shortSlopeCheck = result
			break
		end
	end

	local slopeLengthBoost, shortSlopeBoost = 1, 1
	local slopeDirBoost = 1
	local hoverBuffer = 0
	local slopeAngle = 0
	local earlyBounce = false

	if longSlopeCheck then
		local normal = longSlopeCheck.Normal
		slopeAngle = math.deg(math.acos(normal:Dot(Vector3.new(0, 1, 0))))
		if slopeAngle >= 20 and slopeAngle <= 80 then
			slopeLengthBoost = math.clamp(slopeAngle / 25, 1, 2.2)
			slopeDirBoost = math.clamp(slopeAngle / 40, 1, 2)
			hoverBuffer = math.clamp((slopeAngle - 20) * 0.06, 0, 3)
			if slopeAngle < 35 then
				targetPos = targetPos + Vector3.new(0, 3, 0) + direction * (2 * slopeDirBoost)
			else
				targetPos = targetPos + Vector3.new(0, slopeAngle * 0.3 + hoverBuffer, 0)
			end
		end
	end

	if shortSlopeCheck then
		local normal = shortSlopeCheck.Normal
		slopeAngle = math.deg(math.acos(normal:Dot(Vector3.new(0, 1, 0))))
		if slopeAngle >= 20 and slopeAngle <= 80 then
			shortSlopeBoost = math.clamp(slopeAngle / 22, 1, 2.5)
			slopeDirBoost = slopeDirBoost + math.clamp(slopeAngle / 50, 0, 1.6)
			hoverBuffer = hoverBuffer + math.clamp((slopeAngle - 20) * 0.05, 0, 3)
			local verticalDist = hrp.Position.Y - shortSlopeCheck.Position.Y
			local minForward = 4
			local minUp = 4
			if slopeAngle >= 50 and verticalDist < 3 then
				earlyBounce = true
				targetPos = targetPos + direction * minForward + Vector3.new(0, minUp, 0)
			else
				if slopeAngle < 35 then
					targetPos = targetPos + Vector3.new(0, 3, 0) + direction * (2 * slopeDirBoost)
				else
					targetPos = targetPos + Vector3.new(0, slopeAngle * 0.4 + hoverBuffer, 0)
				end
			end
		end
	end

	if slopeAngle >= 35 then
		targetPos = targetPos + direction * (5 * slopeDirBoost)
	end

	local safetyCheck = workspace:Raycast(hrp.Position, targetPos - hrp.Position, CachedRayParams)
	if safetyCheck then
		targetPos = safetyCheck.Position + Vector3.new(0, 2, 0) - direction * 2
	end

	if shortSlopeCheck or longSlopeCheck then
		local hitPos = (shortSlopeCheck or longSlopeCheck).Position
		local verticalDist = hrp.Position.Y - hitPos.Y
		if verticalDist < 2 then
			targetPos = hrp.Position + direction * 2 + Vector3.new(0, 2, 0)
		end
	end

	hrp.CFrame = CFrame.new(targetPos, targetPos + hrp.CFrame.LookVector)

	local delta = targetPos - hrp.Position
	local speed = storedVelocity.Magnitude
	local forwardBoost = math.clamp(speed * 0.4, 4, 20)
	local safeDir = delta.Magnitude > 0 and delta.Unit or direction
	local safeCheck = workspace:Raycast(hrp.Position, safeDir * forwardBoost, CachedRayParams)

	if not safeCheck then
		hrp.AssemblyLinearVelocity += safeDir * forwardBoost
	else
		local safeDist = (safeCheck.Position - hrp.Position).Magnitude
		if safeDist > 3 then
			hrp.AssemblyLinearVelocity += safeDir * (safeDist * 0.6)
		end
	end

	local bounceMultiplier = 1.2
	if slopeAngle >= 45 then
		local angleBoost = math.clamp((slopeAngle - 45) / 20, 0, 1.0)
		bounceMultiplier = 1.2 + angleBoost
	end

	if storedVelocity.Y < -60 then
		bounceMultiplier *= 0.9 * slopeLengthBoost * shortSlopeBoost
	elseif storedVelocity.Y < -30 then
		bounceMultiplier *= 1.0 * slopeLengthBoost * shortSlopeBoost
	end

	if storedVelocity.Y < -10 then
		local angleFactor = math.clamp((slopeAngle - 20) / 40, 0, 1)
		local bounceY = math.abs(storedVelocity.Y) * (1.1 + angleFactor * 0.9)
		bounceY = bounceY + storedVelocity.Magnitude * (0.3 + angleFactor * 0.5)
		bounceY = math.clamp(bounceY * bounceMultiplier * 1.0, 0, 60 + storedVelocity.Magnitude * 0.4)

		hrp.AssemblyLinearVelocity = Vector3.new(
			storedVelocity.X * slopeDirBoost,
			bounceY,
			storedVelocity.Z * slopeDirBoost
		)

		if earlyBounce then
			local forwardBoost = math.clamp(5 + storedVelocity.Magnitude * 0.1, 6, 20)
			local forwardCheck = workspace:Raycast(hrp.Position, direction * forwardBoost, CachedRayParams)
			if not forwardCheck then
				hrp.CFrame = hrp.CFrame + direction * forwardBoost
			else
				local safeDist = (forwardCheck.Position - hrp.Position).Magnitude
				if safeDist > 3 then
					hrp.CFrame = hrp.CFrame + direction * (safeDist * 0.5)
				end
			end
		end
	end
	
	hrp.Size = Vector3.new(3, 20, 3)
	wait(0.1)
	hrp.Size = Vector3.new(2, 4, 2)
end

function DFunctions.BounceFunction()
    local speedometer = DFunctions.GetSpeedometer()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = char and char:FindFirstChild("Humanoid")

    if speedometer then
        DConfiguration.Misc.Utilities.GetCurrentSpeed = speedometer
    end

    if not DConfiguration.Misc.Utilities.BounceModification.Enabled and humanoid then
        humanoid.WalkSpeed = 0
        return
    end
     
    if char and humanoid then
        if char:GetAttribute("Downed") == true or not DConfiguration.Misc.Utilities.BounceModification.Enabled then
            humanoid.WalkSpeed = 0
        elseif char:GetAttribute("Emoting") == true and char:GetAttribute("Crouching") == true then
            humanoid.WalkSpeed = DConfiguration.Misc.Utilities.BounceModification.EmoteBounce + DConfiguration.Misc.Utilities.GetCurrentSpeed
        elseif DConfiguration.Misc.Utilities.GetCurrentSpeed < 15 or char:GetAttribute("Emoting") == true or char:GetAttribute("Downed") == true then
            humanoid.WalkSpeed = 0
        else
            humanoid.WalkSpeed = DConfiguration.Misc.Utilities.BounceModification.DefaultBounce + DConfiguration.Misc.Utilities.GetCurrentSpeed
        end
    end
end

function DFunctions.SprintEmoteDash()
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	
	if DConfiguration.Misc.MovementModification.EmoteModification.AggressiveEmoteDash.Type == "Legit" and (char and char:GetAttribute("Emoting") == true and char:GetAttribute("Crouching") == true) then
	    DConfiguration.Misc.PlayerAdjustment.Debounce.GroundAcceleration = false
	    DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = DConfiguration.Misc.MovementModification.EmoteModification.AggressiveEmoteDash.Acceleration
    else
        if DConfiguration.Misc.PlayerAdjustment.Debounce.GroundAcceleration then     
			DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = DConfiguration.Misc.PlayerAdjustment.Saved.GroundAcceleration
			wait(0.1)
			DConfiguration.Misc.PlayerAdjustment.Debounce.GroundAcceleration = true
		end
	end
	
	if DConfiguration.Misc.MovementModification.EmoteModification.AggressiveEmoteDash.Type == "Blatant" and (char and char:GetAttribute("Emoting") == true) then
		DConfiguration.Misc.PlayerAdjustment.Update.Speed = DConfiguration.Misc.MovementModification.EmoteModification.AggressiveEmoteDash.Speed
	else
	    DConfiguration.Misc.PlayerAdjustment.Update.Speed = DConfiguration.Misc.PlayerAdjustment.Saved.Speed
	end
end

function DFunctions.BHOPFunction()
    local speedometer = DFunctions.GetSpeedometer()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoidrootpart = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local debounce
    
    if not char then return end
    if not humanoidrootpart then return end
    if not humanoid then return end
    
    -- Fix
    
    -- LocalPlayer.Character.Communicator:InvokeServer("JumpDone")
    LocalPlayer.Character.Movement.JumpEnded:Fire()
    
    if DConfiguration.Misc.MovementModification.BHOP.Type == "Acceleration" then
        if speedometer > 60 then
            DConfiguration.Misc.MovementModification.BHOP.HipHeight2 = -1.05
        else
            DConfiguration.Misc.MovementModification.BHOP.HipHeight2 = -1.10
        end
        
        debounce = 0.01
        humanoid.HipHeight = DConfiguration.Misc.MovementModification.BHOP.HipHeight2
    elseif DConfiguration.Misc.MovementModification.BHOP.Type == "Ground Acceleration" then
        DConfiguration.Misc.MovementModification.BHOP.HipHeight2 = -2
        
        humanoid.HipHeight = DConfiguration.Misc.MovementModification.BHOP.HipHeight2
        debounce = 0.01      
    elseif DConfiguration.Misc.MovementModification.BHOP.Type == "No Acceleration" then
        debounce = 0.125
    end
    
    if DConfiguration.Misc.MovementModification.BHOP.AutoAcceleration then
        local Speed = speedometer
        local Threshold = math.clamp(Speed, 25, 50)
        local Devisor = math.clamp(Speed / Threshold, 0, 6) 
        local Decrease = math.clamp(1 - (Devisor * 1.7), 0.01, 0.8)
        
        if Speed < DConfiguration.Misc.MovementModification.BHOP.MaxSpeed then
            DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = DConfiguration.Misc.MovementModification.BHOP.Acceleration
        else 
            DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = Decrease
        end
    else
        DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = DConfiguration.Misc.MovementModification.BHOP.Acceleration
    end
    
    local now = tick()
    local lastGrounded = 0

    if humanoid.FloorMaterial ~= Enum.Material.Air then
        lastGrounded = now
    end

    local grounded = (now - lastGrounded) < 0.06

    if DConfiguration.Misc.MovementModification.BHOP.JumpType == "Simulated" then
        if grounded and (now - DConfiguration.Misc.MovementModification.BHOP.lastTick) > debounce then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            DConfiguration.Misc.MovementModification.BHOP.lastTick = now
        end
    end
end

function DFunctions.ResetBHOP()
   local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
   local humanoid = char:FindFirstChildOfClass("Humanoid")
   
   DConfiguration.Misc.MovementModification.BHOP.HipHeight1 = -1.25
   DConfiguration.Misc.MovementModification.BHOP.HipHeight2 = -1.10
           
   if humanoid then
       humanoid.HipHeight = DConfiguration.Misc.MovementModification.BHOP.HipHeight1
       DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = 1
       wait(0.3)
       DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = 1
    end
end

-- Main
local GamePlayers = workspace:WaitForChild("Game"):WaitForChild("Players")

Tabs.Main:AddSection("Game Modification")

Tabs.Main:AddParagraph({
        Title = "Billboard ESP",
        Content = " "
    })

local Toggle = Tabs.Main:AddToggle("BillboardNextbots", {Title = "Billboard Nextbots", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.ESP.Nextbots = value
   
    while DConfiguration.ESP.Nextbots and wait(0.1) do
        for _, v in pairs(GamePlayers:GetChildren()) do
            if not Players:FindFirstChild(v.Name) and v:FindFirstChild("HumanoidRootPart") then
                local ESPName = "NextbotESP"
                local hrp
                
                if v:FindFirstChild("Hitbox") then
                   hrp = v.Hitbox
                elseif v:FindFirstChild("Base") then
                   hrp = v.Base
                elseif v:FindFirstChild("Head") then
                   hrp = v.Head
                else
                   hrp = v:FindFirstChildWhichIsA("Part")
                end
                
                if hrp and not hrp:FindFirstChild(ESPName) then
                   CreateBillboardESP(ESPName, hrp, Color3.fromRGB(255, 255, 255), 18)
                end
                
                if hrp then
	                UpdateBillboardESP(ESPName, hrp, v.Name, Color3.fromRGB(255, 0, 0), 18, Camera.CFrame.Position)
                end
            end
        end
    end
    
    if not DConfiguration.ESP.Nextbots then
	    for _, v in pairs(GamePlayers:GetDescendants()) do
            if not Players:FindFirstChild(v.Name) and v:FindFirstChild("HumanoidRootPart") then
                local hrp 
                
                if v:FindFirstChild("Hitbox") then
                   hrp = v.Hitbox
                elseif v:FindFirstChild("Base") then
                   hrp = v.Base
                elseif v:FindFirstChild("Head") then
                   hrp = v.Head
                else
                   hrp = v:FindFirstChildWhichIsA("Part")
                end
                
                if not hrp then return end
                
                DestroyBillboardESP("NextbotESP", hrp)
            end
        end
    end
end)

local Toggle = Tabs.Main:AddToggle("BillboardPlayers", {Title = "Billboard Players", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.ESP.Players = value
   
    while DConfiguration.ESP.Players and wait(0.1) do
	    for _, v in pairs(Players:GetPlayers()) do
			if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
			    local ESPName = "PlayerESP"
				local PlayerChar = v.Character
				
                if PlayerChar then
					if not PlayerChar.HumanoidRootPart:FindFirstChild(ESPName) then
					   CreateBillboardESP(ESPName, PlayerChar.HumanoidRootPart, Color3.fromRGB(255, 255, 255), 14)
					end
				
					local PlayerStats = GamePlayers:FindFirstChild(v.Name)
					if PlayerStats and PlayerStats:GetAttribute("Downed") == true then
						UpdateBillboardESP(ESPName, PlayerChar.HumanoidRootPart, v.Name, Color3.fromRGB(0, 255, 0), 14, Camera.CFrame.Position)
					else
						UpdateBillboardESP(ESPName, PlayerChar.HumanoidRootPart, v.Name, Color3.fromRGB(255, 255, 255), 14, Camera.CFrame.Position)
					end
				end
			end
		end
    end

   if not DConfiguration.ESP.Players then
	   for _, v in pairs(Players:GetPlayers()) do
			if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
				DestroyBillboardESP("PlayerESP", v.Character.HumanoidRootPart)
		 	end
		 end
     end
end)

Tabs.Main:AddSection("Tracer ESP")
 
local TracerLinesBots = {}
local TracerLines = {}

local Toggle = Tabs.Main:AddToggle("TracersPlayers", {
    Title = "Tracer Players",
    Default = false
})

Toggle:OnChanged(function(State)
    DConfiguration.Tracers.Players = State

    if not DConfiguration.Tracers.Players then
        for part, _ in pairs(TracerLines) do
            if typeof(part) == "Instance" then
                DestroyTracerESP(TracerLines, part)
            else
                TracerLines[part] = nil
            end
        end
        TracerLines = {}
        return
    end

    task.spawn(function()
        while DConfiguration.Tracers.Players and task.wait() do
            if not DConfiguration.Tracers.Players then break end
            pcall(function()
                local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not localHRP then return end

                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            if not TracerLines[hrp] then
                                CreateTracerESP(TracerLines, hrp, 2, Color3.fromRGB(255, 255, 255))
                            end

                            local color = Color3.fromRGB(255, 255, 255)
                            local gamePlayer = workspace:FindFirstChild("Game") and workspace.Game.Players:FindFirstChild(player.Name)
                            if gamePlayer and gamePlayer:GetAttribute("Downed") then
                                color = Color3.fromRGB(0, 255, 0)
                            end

                            UpdateTracerESP(TracerLines, hrp, color)
                        end
                    end
                end

                for part, tracer in pairs(TracerLines) do
                    if typeof(part) ~= "Instance" or not part.Parent then
                        DestroyTracerESP(TracerLines, part)
                    elseif tracer and tracer.Visible and not part:IsDescendantOf(workspace) then
                        tracer.Visible = false
                        DestroyTracerESP(TracerLines, part)
                    end
                end
            end)
        end
    end)
end)

local Toggle = Tabs.Main:AddToggle("TracersBots", {
    Title = "Tracer Bots",
    Default = false
})

Toggle:OnChanged(function(State)
    DConfiguration.Tracers.Nextbots = State

    if not DConfiguration.Tracers.Nextbots then
        for part, _ in pairs(TracerLinesBots) do
            if typeof(part) == "Instance" then
                DestroyTracerESP(TracerLinesBots, part)
            else
                TracerLinesBots[part] = nil
            end
        end
        TracerLinesBots = {}
        return
    end

    task.spawn(function()
        while DConfiguration.Tracers.Nextbots and task.wait() do
            if not DConfiguration.Tracers.Nextbots then break end
            pcall(function()
                local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not localHRP then return end

                local gamePlayers = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Players")
                if not gamePlayers then return end

                for _, bot in pairs(gamePlayers:GetChildren()) do
                    local hrp = bot:FindFirstChild("HumanoidRootPart")
                    if hrp and not Players:FindFirstChild(bot.Name) then
                        if not TracerLinesBots[hrp] then
                            CreateTracerESP(TracerLinesBots, hrp, 5, Color3.fromRGB(255, 0, 0))
                        end
                        UpdateTracerESP(TracerLinesBots, hrp, Color3.fromRGB(255, 0, 0))
                    end
                end

                for part, tracer in pairs(TracerLinesBots) do
                    if typeof(part) ~= "Instance" or not part.Parent then
                        DestroyTracerESP(TracerLinesBots, part)
                    elseif tracer and tracer.Visible and not part:IsDescendantOf(workspace) then
                        tracer.Visible = false
                        DestroyTracerESP(TracerLinesBots, part)
                    end
                end
            end)
        end
    end)
end)

Tabs.Main:AddSection("Highlight ESP")

local Toggle = Tabs.Main:AddToggle("HighlightNextbot", {Title = "Highlight Nextbots", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.Highlight.Nextbots = value
   
    while DConfiguration.Highlight.Nextbots and wait(0.1) do
        for _, v in pairs(GamePlayers:GetChildren()) do
            if not Players:FindFirstChild(v.Name) and v:FindFirstChild("HumanoidRootPart") then
                local ESPName = "NextbotHighlight"
                local hrp = v:FindFirstChild("HumanoidRootPart")
                
                if v and not v:FindFirstChild(ESPName) then
                   CreateHighlightESP(ESPName, v, Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 0, 0), DConfiguration.Highlight.OutlineOnly)
                end
                
                if v then
	                UpdateHighlightESP(ESPName, v, Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 0, 0), DConfiguration.Highlight.OutlineOnly)
	                if hrp then
		                hrp.Transparency = 0.1
	                end
                end
            end
        end
    end
    
    if not DConfiguration.Highlight.Nextbots then
	    for _, v in pairs(GamePlayers:GetDescendants()) do
            if not Players:FindFirstChild(v.Name) and v:FindFirstChild("HumanoidRootPart") then
                local hrp = v:FindFirstChild("HumanoidRootPart")
                
                if not hrp then return end
                
                if hrp then
	                hrp.Transparency = 1
                end
                DestroyHighlightESP("NextbotHighlight", v)
            end
        end
    end
end)

local Toggle = Tabs.Main:AddToggle("HighlightPlayers", {Title = "Highlight Players", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.Highlight.Players = value
   
    while DConfiguration.Highlight.Players and wait(0.1) do
	    for _, v in pairs(Players:GetPlayers()) do
			if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
			    local ESPName = "PlayerHighlight_D"
				local PlayerChar = v.Character
				
                if PlayerChar then
					if not PlayerChar:FindFirstChild(ESPName) then
					   CreateHighlightESP(ESPName, PlayerChar, Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255), DConfiguration.Highlight.OutlineOnly)
					end
				
					local PlayerStats = GamePlayers:FindFirstChild(v.Name)
					if PlayerStats and PlayerStats:GetAttribute("Downed") == true then
						UpdateHighlightESP(ESPName, PlayerChar, Color3.fromRGB(0, 255, 0), Color3.fromRGB(255, 255, 255), DConfiguration.Highlight.OutlineOnly)
					else
						UpdateHighlightESP(ESPName, PlayerChar, Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 255, 255), DConfiguration.Highlight.OutlineOnly)
					end
				end
			end
		end
    end

   if not DConfiguration.Highlight.Players then
	   for _, v in pairs(Players:GetPlayers()) do
			if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
				DestroyHighlightESP("PlayerHighlight_D", v.Character)
		 	end
		 end
     end
end)

Tabs.Main:AddSection("Game Modification")

local Toggle = Tabs.Main:AddToggle("AutoRespawn", {Title = "Auto Respawn", Default = false })

    Toggle:OnChanged(function(value)
       DConfiguration.Main.AutoRespawn = value
        
       while DConfiguration.Main.AutoRespawn and wait(0.1) do
          spawn(DFunctions.AutoRespawn)
	 end
end)

local Keybind = Tabs.Main:AddKeybind("RespawnKey", {
    Title = "Respawn Keybind",
    Mode = "Toggle", 
    Default = "R",
    
    Callback = function(State)
     
        if State then          
            task.spawn(function()                    
                DFunctions.AutoRespawn() 
                print("Respawned!") 
            end)
        end
    end,
})



Tabs.Main:AddButton({
    Title = "Force Respawn",
    Description = "",
    Callback = function()
        game:GetService("ReplicatedStorage").Events.Respawn:FireServer()
    end
})

local Dropdown = Tabs.Main:AddDropdown("RespawnType", {
        Title = "Respawn Type",
        Values = {"Spawnpoint", "Fake Revive"},
        Multi = false,
        Default = 1,
    })

    Dropdown:OnChanged(function(value)
        DConfiguration.Main.RespawnType = value
    end)
    
Tabs.Main:AddParagraph({
        Title = " ",
        Content = ""
    })
    
local Toggle = Tabs.Main:AddToggle("AutoWhistle", {Title = "Auto Whistle", Default = false })

    Toggle:OnChanged(function(value)
        DConfiguration.Main.AutoWhistle = value
        
      while task.wait(1) and DConfiguration.Main.AutoWhistle do
	   	DFunctions.Whistle()
		end
    end)
    
Tabs.Main:AddSection("Alternative Settings")
    
local Toggle = Tabs.Main:AddToggle("AntiAfk", {Title = "Anti-AFK", Default = false })

    Toggle:OnChanged(function()
    local vu = game:GetService("VirtualUser")
    
    repeat wait() until game:IsLoaded() 
	   LocalPlayer.Idled:connect(function()
       game:GetService("VirtualUser"):ClickButton2(Vector2.new())
	  	vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
	  	wait(1)
		  vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
     end)
 end)
 
 Options.AntiAfk:SetValue(true)
 
 local Toggle = Tabs.Main:AddToggle("RemoveCameraShake", {Title = "Disable Camera Shake", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.Removals.CameraShake = value

    while task.wait() and DConfiguration.Removals.CameraShake do
	    LocalPlayer.PlayerScripts.CameraShake.Value = CFrame.new(0,0,0) * CFrame.new(0,0,0)
 	end
end)

local Toggle = Tabs.Main:AddToggle("ShowTimer", {Title = "Show Timer", Default = false })

    Toggle:OnChanged(function(State)
    DConfiguration.Main.ShowTimer = State

   if DConfiguration.Main.ShowTimer then
      DFunctions.CreateTimer()
   else
      DFunctions.RemoveTimer()
   end

    while DConfiguration.Main.ShowTimer and wait(0.1) do
       if LocalPlayer.PlayerGui:FindFirstChild("TimerGui") then
             LocalPlayer.PlayerGui.TimerGui.TextLabel.Text = LocalPlayer.PlayerGui:WaitForChild("HUD").Center.Vote.Info.Read.Timer.Text
           end
        end
    end)
    
local Toggle = Tabs.Main:AddToggle("QuickRevive", {Title = "Quick Revive", Default = false })

    Toggle:OnChanged(function(State)
        if State then
            workspace.Game.Settings:SetAttribute("ReviveTime", 1.75)
		else
            workspace.Game.Settings:SetAttribute('ReviveTime', 3)
		end        
    end)
    
Tabs.Main:AddSection("Map Modification")
    
local Toggle = Tabs.Main:AddToggle("RemoveDamage", {Title = "Remove Damage Objects", Default = false })

    Toggle:OnChanged(function(value)
        DConfiguration.Removals.DamageParts = value
        
      while task.wait(1) and DConfiguration.Removals.DamageParts do
			spawn(DFunctions.RemoveDamagePart)
		end
    end)
    
local Toggle = Tabs.Main:AddToggle("RemoveReducingRewards", {Title = "Remove Invisible Walls", Default = false })

    Toggle:OnChanged(function(value)
        DConfiguration.Removals.InvisibleWalls = value
        
      while task.wait(1) and DConfiguration.Removals.InvisibleWalls do
          spawn(function()
				DFunctions.DisableInvisParts(false)
			end)
		end
		
		if not DConfiguration.Removals.InvisibleWalls then
			DFunctions.DisableInvisParts(true)
		end
    end)
    
Tabs.Main:AddSection("Player Modification")
    
local Toggle = Tabs.Main:AddToggle("Noclip", {Title = "Noclip", Default = false })

Toggle:OnChanged(function(value)
        DConfiguration.Main.Noclip = value
        
        while DConfiguration.Main.Noclip and wait(0.1) do
           DFunctions.Noclip()
         end
    end)

Options.Noclip:SetValue(false)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

_G.Fly = false
_G.flySpeed = 20

local FLYING = false
local velocityHandlerName = "FlyVelocity"
local gyroHandlerName = "FlyGyro"
local mfly1, mfly2
local controlModule

local function getControlModule()
    if controlModule then return controlModule end
    local playerScripts = LP:FindFirstChild("PlayerScripts")
    local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule")
    local CM = playerModule and playerModule:FindFirstChild("ControlModule")
    if CM then
        controlModule = require(CM)
        return controlModule
    end
    return nil
end

local function unmobilefly()
    FLYING = false
    local character = LP.Character
    if character then
        local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
        if root then
            local bv = root:FindFirstChild(velocityHandlerName)
            local bg = root:FindFirstChild(gyroHandlerName)
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end
    end
    if mfly1 then mfly1:Disconnect() mfly1 = nil end
    if mfly2 then mfly2:Disconnect() mfly2 = nil end
end

local function mobilefly()
    unmobilefly()
    FLYING = true

    local character = LP.Character
    if not character then return end
    
    local root = character:WaitForChild("HumanoidRootPart", 5) or character:WaitForChild("Torso", 5)
    if not root then return end

    local camera = workspace.CurrentCamera
    local v3zero = Vector3.new(0, 0, 0)
    local v3inf = Vector3.new(9e9, 9e9, 9e9)
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = velocityHandlerName
    bv.Parent = root
    bv.MaxForce = v3inf
    bv.Velocity = v3zero

    local bg = Instance.new("BodyGyro")
    bg.Name = gyroHandlerName
    bg.Parent = root
    bg.MaxTorque = Vector3.new(9e9, 0, 9e9) 
    bg.P = 1000
    bg.D = 50

    mfly1 = LP.CharacterAdded:Connect(function(newChar)
        unmobilefly()
        newChar:WaitForChild("HumanoidRootPart", 5)
        if _G.Fly then mobilefly() end
    end)

    mfly2 = RunService.PreRender:Connect(function()
        if not _G.Fly then unmobilefly() return end
        
        local ch = LP.Character
        local r = ch and (ch:FindFirstChild("HumanoidRootPart") or ch:FindFirstChild("Torso"))
        local VelocityHandler = r and r:FindFirstChild(velocityHandlerName)
        local GyroHandler = r and r:FindFirstChild(gyroHandlerName)

        if r and VelocityHandler and GyroHandler then
            VelocityHandler.MaxForce = v3inf
            
            local camCFrame = camera.CFrame
            GyroHandler.CFrame = CFrame.new(r.Position) * CFrame.Angles(0, math.atan2(-camCFrame.LookVector.X, -camCFrame.LookVector.Z), 0)

            local moveVector = Vector3.new(0, 0, 0)
            local CM = getControlModule()
            if CM and CM.GetMoveVector then
                moveVector = CM:GetMoveVector()
            end

            if moveVector.X ~= 0 or moveVector.Z ~= 0 then
                local look = camera.CFrame.LookVector
                local right = camera.CFrame.RightVector
                local flyDirection = (right * moveVector.X - look * moveVector.Z).unit
                
                VelocityHandler.Velocity = flyDirection * (_G.flySpeed * 25)
            else
                VelocityHandler.Velocity = v3zero
            end
        end
    end)
end

local function toggleFly(toggleValue)
    _G.Fly = toggleValue
    if toggleValue then
        mobilefly()
    else
        unmobilefly()
    end
end

Tabs.Main:AddKeybind("FlyKeybind", {
    Title = "Fly Toggle",
    Mode = "Toggle",
    Default = "F",
    Callback = function(Value)
        toggleFly(Value)
    end
})

local FlySpeedInput = Tabs.Main:AddInput("FlySpeedInput", {
    Title = "Fly Speed",
    Default = tostring(_G.flySpeed),
    Placeholder = "Enter fly speed",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        _G.flySpeed = tonumber(Value) or 20
    end
})


-- Nextbots

Tabs.Nextbots:AddSection("Nextbot Modification")

local Toggle = Tabs.Nextbots:AddToggle("AntiNextbotToggle", {Title = "Anti Nextbot Toggle", Default = false })

    Toggle:OnChanged(function(value)
    DConfiguration.Nextbots.AntiNextbot = value
        
    while DConfiguration.Nextbots.AntiNextbot and wait(0.1) do
          spawn(DFunctions.AntiNextbot)
       end
    end)

local Dropdown = Tabs.Nextbots:AddDropdown("AntiBotTeleport", {
        Title = "Anti Nextbot Teleport Type",
        Values = {"Spawn", "Players"},
        Multi = false,
        Default = 1,
    })

    Dropdown:OnChanged(function(Value)
        DConfiguration.Nextbots.AntiNextbotType = Value
    end)
    
  Tabs.Nextbots:AddInput("NextbotDistance", {
    Title = "Anti Nextbot Distance",
    Default = 15,
    Placeholder = "Number",
    Numeric = false, 
    Finished = false, 
    Callback = function(Value)
        DConfiguration.Nextbots.AntiNextbotRange = tonumber(Value) or 15 
    end
})

wait(Duration)

-- Misc

Tabs.Misc:AddSection("Player Adjustments")

Tabs.Misc:AddInput("PlayerSpeed", {
        Title = "Player Speed",
        Description = "",
        Default = "1500",
        Placeholder = "Speed Number",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Misc.PlayerAdjustment.Update.Speed = tonumber(Value) or 1500
            DConfiguration.Misc.PlayerAdjustment.Saved.Speed = tonumber(Value) or 1500
        end
    })
    
 Tabs.Misc:AddInput("PlayerJump", {
        Title = "Player Jump",
        Description = "",
        Default = "3",
        Placeholder = "Jump Number",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Misc.PlayerAdjustment.Update.JumpHeight = tonumber(Value) or 3
            DConfiguration.Misc.PlayerAdjustment.Saved.JumpHeight = tonumber(Value) or 3
        end
    })
    
 Tabs.Misc:AddInput("PlayerStrafeAcceleration", {
        Title = "Player Strafe Acceleration",
        Description = "",
        Default = "182",
        Placeholder = "Number",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Misc.PlayerAdjustment.Update.AirStrafe = tonumber(Value) or 182
            DConfiguration.Misc.PlayerAdjustment.Saved.AirStrafe = tonumber(Value) or 182
        end
    })
    
Tabs.Misc:AddParagraph({
        Title = " ",
        Content = ""
    })
    
local Toggle = Tabs.Misc:AddToggle("PlayerWalkspeed", {Title = "Walkspeed Toggle", Default = false })

    Toggle:OnChanged(function(State)
        DConfiguration.Misc.Humanoids.WalkspeedCF = State
 
        while DConfiguration.Misc.Humanoids.WalkspeedCF and wait(0.01) do
            local hb = RunService.Heartbeat
            local speaker = game.Players.LocalPlayer
            local chr = speaker.Character
            local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
            local delta = hb:Wait()

            if chr and hum.MoveDirection.Magnitude > 0 then
               chr:TranslateBy(hum.MoveDirection * DConfiguration.Misc.Humanoids.CF * delta * 10)
           end
        end
    end)

 Tabs.Misc:AddInput("PlayerWalkCf", {
        Title = "Player Walkspeed",
        Default = "5",
        Placeholder = "Walk Number",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Misc.Humanoids.CF = tonumber(Value) or 5
        end
    })
    
Tabs.Misc:AddSection("Utilities")

Tabs.Misc:AddKeybind("LagSwitchKey", {
    Title = "Lag Switch",
    Mode = "Toggle",
    Default = "L",
    
    Callback = function(State)
        if State then
            task.spawn(function() 
                DFunctions.StartLag(DConfiguration.Misc.Utilities.LagSwitch.MSDelay) 
            end)
        end
    end,
})

    
 Tabs.Misc:AddInput("DelayMS", {
        Title = "Delay MS",
        Default = "200",
        Placeholder = "Value",
        Numeric = false, -- Only allows numbers
        Finished = false, -- Only calls callback when you press enter
        Callback = function(Value)
            DConfiguration.Misc.Utilities.LagSwitch.MSDelay = tonumber(Value) or 200
        end
    })
    
local Dropdown = Tabs.Misc:AddDropdown("LagMode", {
        Title = "Lag Mode",
        Values = {"Normal", "Demon", "FastFlag"},
        Multi = false,
        Default = 1,
    })

    Dropdown:OnChanged(function(Value)
        DConfiguration.Misc.Utilities.LagSwitch.Mode = Value
    end)

Tabs.Misc:AddParagraph({
        Title = " ",
        Content = ""
    })
    
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

_SB = _SB or { Power = 100 }
DConfiguration = DConfiguration or { Settings = { GuiScale = { BounceBot = 0 } } }
DFunctions = DFunctions or {}

local function TriggerBounce()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    
    if rootPart and humanoid then
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.FilterDescendantsInstances = {character}
        raycastParams.IgnoreWater = true
        
        local rayResult = workspace:Raycast(rootPart.Position, Vector3.new(0, -100, 0), raycastParams)
        
        if rayResult and rayResult.Instance and rayResult.Instance:IsA("BasePart") and rayResult.Instance.CanCollide then
            local safePower = math.clamp(_SB.Power, 0, 500)
            
            humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            rootPart.AssemblyLinearVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, safePower, rootPart.AssemblyLinearVelocity.Z)
            
            task.defer(function()
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
                end
            end)
        end
    end
end    
    
local Toggle = Tabs.Misc:AddToggle("AdjustBounce", {Title = "Modify Bounce", Default = false })

Toggle:OnChanged(function(State)
    DConfiguration.Misc.Utilities.BounceModification.Enabled = State
     
    while DConfiguration.Misc.Utilities.BounceModification.Enabled and wait(0.1) do
        spawn(DFunctions.BounceFunction)
    end
end)

 Tabs.Misc:AddInput("PlayerBounce", {
        Title = "Player Bounce",
        Default = "80",
        Placeholder = "Bounce Number",
        Numeric = false,
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Misc.Utilities.BounceModification.DefaultBounce = tonumber(Value) or 80
        end
    })
    
 Tabs.Misc:AddInput("EmoteBounce", {
        Title = "Emote Bounce",
        Default = "120",
        Placeholder = "Bounce Number",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Misc.Utilities.BounceModification.EmoteBounce = tonumber(Value) or 120
        end
    })
    
    Tabs.Misc:AddParagraph({
        Title = " ",
        Content = ""
    })
    
local KeybindRegular = Tabs.Misc:AddKeybind("BounceKey", {
    Title = "Bounce (Keybind)",
    Mode = "Toggle", 
    Default = "O", 
    Callback = function(State)
        if State then
            task.spawn(function()
                TriggerBounce()
            end)
        end
    end,
})
Tabs.Misc:AddInput("BouncePowerInput", {
    Title = "Bounce Power",
    Default = tostring(_SB.Power or 100),
    Placeholder = "100",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            _SB.Power = math.clamp(num, 0, 500)
        else
            _SB.Power = 100
        end
    end
})
    
    
 Tabs.Misc:AddParagraph({
        Title = " ",
        Content = ""
    })

local LP = game.Players.LocalPlayer
local RS = game:GetService("RunService")
local Cam = workspace.CurrentCamera

getgenv().EasyBounce = getgenv().EasyBounce or {
    Enabled = false,
    Mode = "Forward",
    BaseSpeed = 50,
    ExtraSpeed = 100
}

local EB = getgenv().EasyBounce
local state = {
    speed = EB.BaseSpeed,
    last = tick(),
    airTick = 0,
    airSum = 0,
    airborne = false,
    bv = nil
}

local function getMeter()
    local ok, v = pcall(function()
        return LP.PlayerGui.Shared.HUD.Overlay.Default.CharacterInfo.Item.Speedometer.Players
    end)
    return ok and v or nil
end

local function cut(n) return math.floor(n * 10) / 10 end

local function resetPhysics(hrp, hum)
    if state.bv then 
        state.bv:Destroy() 
        state.bv = nil 
    end
    if hrp then
        for _, child in ipairs(hrp:GetChildren()) do
            if (child:IsA("BodyVelocity") and child.Name == "BodyVelocity") or child:IsA("BodyForce") then
                child:Destroy()
            end
        end
    end
    state.speed = EB.BaseSpeed
    state.airTick, state.airSum, state.airborne = 0, 0, false
end

RS.RenderStepped:Connect(function()
    local ch = LP.Character
    local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
    local hum = ch and ch:FindFirstChild("Humanoid")
    
    if _G.Fly or not EB.Enabled then
        resetPhysics(hrp, hum)
        return 
    end

    if not hrp or not hum then return end

    local dt = tick() - state.last
    state.last = tick()

    local inAir = hum.FloorMaterial == Enum.Material.Air
    local spdUI = getMeter()

    if state.airborne and not inAir then
        state.speed = math.max(EB.BaseSpeed, state.speed - 10)
        if spdUI then spdUI.Text = cut(state.speed) end
        state.airSum = 0
    end
    state.airborne = inAir

    local shouldPush = true

    if shouldPush then
        if inAir then
            state.airSum = state.airSum + dt
            state.airTick = state.airTick + dt
            while state.airTick >= 0.04 do
                state.airTick = state.airTick - 0.04
                state.speed = math.min(EB.BaseSpeed + EB.ExtraSpeed, state.speed + 0.1)
            end
        else
            state.airTick, state.airSum = 0, 0
            state.speed = math.max(EB.BaseSpeed, state.speed - (2.5 * dt))
        end

        if not state.bv or state.bv.Parent ~= hrp then
            if state.bv then state.bv:Destroy() end
            state.bv = Instance.new("BodyVelocity")
            state.bv.Parent = hrp
        end
        
        local camDir = Cam.CFrame.LookVector
        local moveDir = Vector3.new(camDir.X, 0, camDir.Z).Unit
        
        if EB.Mode == "Back" then
            moveDir = -moveDir
        end

        state.bv.Velocity = moveDir * state.speed
        state.bv.MaxForce = Vector3.new(4e5, 0, 4e5) 

        if spdUI then spdUI.Text = cut(state.speed) end
    else
        if state.bv then
            state.bv.MaxForce = Vector3.new(0, 0, 0) 
            state.bv.Velocity = Vector3.new(0, 0, 0)
        end
        state.speed = EB.BaseSpeed
    end
end)

Tabs.Misc:AddKeybind("EB_ToggleKey", {
    Title = "Easy Bounce Toggle",
    Mode = "Toggle",
    Default = "V",
    Callback = function(State)
        EB.Enabled = State
    end
})

Tabs.Misc:AddDropdown("EB_ModeDropdown", {
    Title = "Easy Bounce Mode",
    Values = {"Forward", "Back"},
    Default = EB.Mode,
    Callback = function(v)
        EB.Mode = v
    end
})

Tabs.Misc:AddInput("EB_Base", {
    Title = "Base Speed", 
    Default = tostring(EB.BaseSpeed), 
    Numeric = true, 
    Finished = true, 
    Callback = function(v) 
        EB.BaseSpeed = tonumber(v) or 50 
        if getgenv().UpdateBounceSpeed then
            getgenv().UpdateBounceSpeed(EB.BaseSpeed)
        end
    end
})

Tabs.Misc:AddInput("EB_Extra", {
    Title = "Extra Speed (Boost)", 
    Default = tostring(EB.ExtraSpeed), 
    Numeric = true, 
    Finished = true, 
    Callback = function(v) 
        EB.ExtraSpeed = tonumber(v) or 100 
    end
})

Tabs.Misc:AddParagraph({
        Title = " ",
        Content = ""
    })
    
 do
    local PlatData = {
        Enabled = false,
        Size = 10,
        Transparency = 0.1,
        List = {}
    }

    local function ClearPlates()
        for _, p in pairs(PlatData.List) do
            if p and p.Parent then p:Destroy() end
        end
        PlatData.List = {}
    end

    local function GetFolder()
        local g = workspace:FindFirstChild("Game")
        local m = g and g:FindFirstChild("Map")
        local p = m and m:FindFirstChild("Parts")
        return p and p:FindFirstChild("ImmovableProps")
    end

    local function CreatePlates()
        ClearPlates()
        if not PlatData.Enabled then return end
        local folder = GetFolder()
        if not folder then return end
        
        for _, obj in pairs(folder:GetChildren()) do
            if obj.Name == "Cactus1" or obj.Name == "Cactus2" then
                local pos, size
                if obj:IsA("Model") then
                    local cf, s = obj:GetBoundingBox()
                    pos, size = cf.Position, s
                elseif obj:IsA("BasePart") then
                    pos, size = obj.Position, obj.Size
                end

                if pos and size then
                    local p = Instance.new("Part")
                    p.Name = "PhantomWyrm"
                    p.Size = Vector3.new(PlatData.Size, 1, PlatData.Size)
                    p.Anchored, p.CanCollide = true, true
                    p.Material = Enum.Material.Neon
                    p.Transparency = PlatData.Transparency
                    p.Color = Color3.fromRGB(0, 255, 150)
                    p.Position = pos + Vector3.new(0, (size.Y / 2) + 0.5, 0)
                    p.Parent = workspace
                    table.insert(PlatData.List, p)
                end
            end
        end
    end

    Tabs.Misc:AddToggle("CactusToggle", {
        Title = "Cactus Platform",
        Default = false,
        Callback = function(Value)
            PlatData.Enabled = Value
            CreatePlates()
        end
    })

    Tabs.Misc:AddInput("CactusTransInput", {
        Title = "Platform Transparency (0-1)",
        Description = "make platforms invisible 3-5",
        Default = "0.5",
        Numeric = true,
        Finished = true,
        Callback = function(Value)
            local num = tonumber(Value) or 0.5
            PlatData.Transparency = math.clamp(num, 0, 1)
            for _, p in pairs(PlatData.List) do
                if p and p.Parent then p.Transparency = PlatData.Transparency end
            end
        end
    })

    Tabs.Misc:AddInput("CactusSizeInput", {
        Title = "Platform Size",
        Default = "12",
        Numeric = true,
        Finished = true,
        Callback = function(Value)
            PlatData.Size = tonumber(Value) or 12
            if PlatData.Enabled then CreatePlates() end
        end
    })

    task.spawn(function()
        while task.wait(3) do
            if PlatData.Enabled and #PlatData.List == 0 then
                CreatePlates()
            end
        end
    end)
end

Tabs.Misc:AddSection("Camera Adjustment")

if not _G.Phantom then
    _G.Phantom = {}
end
_G.Phantom.ResolutionValue = 1
local a = workspace.CurrentCamera
if _G.PhantomCameraLoop == nil then
    _G.PhantomCameraLoop =
        game:GetService("RunService").RenderStepped:Connect(
        function()
            local b = _G.Phantom.ResolutionValue
            if b and b ~= 1 then
                a.CFrame = a.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, b, 0, 0, 0, 1)
            end
        end
    )
end

Tabs.Misc:AddInput("PhantomFOV", {
        Title = "Stretch",
        Description = "write 0.8 or 0.1",
        Default = "1",
        Placeholder = "",
        Numeric = false,
        Finished = false,
        Callback = function(c)
            local d = tonumber(c)
            if d and d > 0 then
                _G.Phantom.ResolutionValue = d
            else
                _G.Phantom.ResolutionValue = 1
            end
        end
    }
)

_G.FinalStrictFOV = 70

if _G.StrictFovLoop then
    _G.StrictFovLoop:Disconnect()
    _G.StrictFovLoop = nil
end

if _G.FovChangedConnection then
    _G.FovChangedConnection:Disconnect()
    _G.FovChangedConnection = nil
end

local camera = workspace.CurrentCamera

local function enforceFov()
    if camera and camera.FieldOfView ~= _G.FinalStrictFOV then
        camera.FieldOfView = _G.FinalStrictFOV
    end
end

local mt = getrawmetatable(game)
local oldNewIndex = mt.__newindex
setreadonly(mt, false)

mt.__newindex = newcclosure(function(self, property, value)
    if self == workspace.CurrentCamera and property == "FieldOfView" then
        return oldNewIndex(self, property, _G.FinalStrictFOV)
    end
    return oldNewIndex(self, property, value)
end)

setreadonly(mt, true)

if camera then
    camera.FieldOfView = _G.FinalStrictFOV
    _G.FovChangedConnection = camera:GetPropertyChangedSignal("FieldOfView"):Connect(enforceFov)
end

Tabs.Misc:AddInput("PlayerFOV", {
    Title = "Player FOV (Optimized Lock)",
    Description = "Minimum 30 │ Max 120",
    Default = "70",
    Placeholder = "FOV Number",
    Numeric = true,
    Finished = false,
    Callback = function(text)
        local number = tonumber(text)
        if number and number >= 30 and number <= 120 then
            _G.FinalStrictFOV = number
            if workspace.CurrentCamera then
                workspace.CurrentCamera.FieldOfView = number
            end
        end
    end
})

Tabs.Misc:AddSection("Game Automations")

Tabs.Misc:AddKeybind("MacroKey1", {
    Title = "Macro: Emote/Crouch",
    Mode = "Toggle",
    Default = "Q", 
    Callback = function()
        task.spawn(function()
            game:GetService("ReplicatedStorage").Events.Emote:FireServer(DConfiguration.Misc.GameAutomation.SelectedPrimary)
            LocalPlayer.Character.Communicator:InvokeServer("Crouching", true)
        end)
    end,
})

Tabs.Misc:AddKeybind("MacroKey2", {
    Title = "Macro: Uncrouch",
    Mode = "Toggle",
    Default = "E", 
    Callback = function()
        task.spawn(function()
            LocalPlayer.Character.Communicator:InvokeServer("Crouching", false)
        end)
    end,
})

    
 local Dropdown = Tabs.Misc:AddDropdown("SelectionEmoteSlot", {
        Title = "Select Emote Slots",
        Values = {"1", "2", "3", "4", "5", "6"},
        Multi = false,
        Default = 1,
    })

    Dropdown:OnChanged(function(Value)
        DConfiguration.Misc.GameAutomation.SelectedPrimary = Value
    end)
    
Tabs.Misc:AddSection("Movement Modification")

local Toggle = Tabs.Misc:AddToggle("SprintEmoteDash", {Title = "Aggressive Emote Dash", Default = false })

Toggle:OnChanged(function(State)
	DConfiguration.Misc.MovementModification.EmoteModification.AggressiveEmoteDash.Enabled = State
	
	if not DConfiguration.Misc.MovementModification.EmoteModification.AggressiveEmoteDash.Enabled then
	    DConfiguration.Misc.PlayerAdjustment.Debounce.GroundAcceleration = false
	    DConfiguration.Misc.PlayerAdjustment.Update.Speed = DConfiguration.Misc.PlayerAdjustment.Saved.Speed
	end
end)

local Dropdown = Tabs.Misc:AddDropdown("SprintEmoteType", {
        Title = "Aggressive Emote Type",
        Values = {"Legit", "Blatant"},
        Multi = false,
        Default = 2,
    })

    Dropdown:OnChanged(function(Value)
        DConfiguration.Misc.MovementModification.EmoteModification.AggressiveEmoteDash.Type = Value
    end)
    
 Tabs.Misc:AddInput("EmoteSpeed", {
        Title = "Aggressive Emote Speed",
        Default = "2000",
        Placeholder = "Emote Speed Number",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Misc.MovementModification.EmoteModification.AggressiveEmoteDash.Speed = tonumber(Value) or 2000
        end
    })
    
Tabs.Misc:AddInput("CrouchSpeed", {
        Title = "Aggressive Emote Acceleration (Negative Only)",
        Default = "-2",
        Placeholder = "Acceleration Number",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Misc.MovementModification.EmoteModification.AggressiveEmoteDash.Acceleration = tonumber(Value) or 0.2
        end
    })
    
Tabs.Misc:AddParagraph({
        Title = " ",
        Content = ""
    })
    
local Toggle = Tabs.Misc:AddToggle("ModifyEmote", {
    Title = "Modify Emote Movement",
    Default = false
})

local connection

Toggle:OnChanged(function(State)
    DConfiguration.Misc.MovementModification.EmoteModification.ModifyEmote.Enabled = State  

    if connection then
        connection:Disconnect()
        connection = nil
    end

    if not State then return end

    connection = RunService.RenderStepped:Connect(function(dt)
        if not DConfiguration.Misc.MovementModification.EmoteModification.ModifyEmote.Enabled then
            connection:Disconnect()
            connection = nil
            return
        end

        local char = LocalPlayer.Character
        if not char then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        local moveDir = hum.MoveDirection
        if moveDir.Magnitude <= 0 then return end

        local emoting = char:GetAttribute("Emoting")
        local downed = char:GetAttribute("Downed")
        if not (emoting or downed) then return end

        local targetCF = CFrame.lookAt(
            hrp.Position,
            hrp.Position + moveDir
        )

        local turnSpeed = DConfiguration.Misc.MovementModification.EmoteModification.ModifyEmote.TurnSpeed
        local alpha = math.clamp(turnSpeed * dt * 16, 0, 1)

        hrp.CFrame = hrp.CFrame:Lerp(targetCF, alpha)
    end)
end)

Tabs.Misc:AddInput("EmoteRotation", {
        Title = "Emote Rotation Speed",
        Default = "0.5",
        Placeholder = "Rotation Number",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Misc.MovementModification.EmoteModification.ModifyEmote.TurnSpeed = tonumber(Value) or 0.5
        end
    })
    
Tabs.Misc:AddParagraph({
        Title = " ",
        Content = ""
    })
    
local NormalGravity = game.Workspace.Gravity

Tabs.Misc:AddInput("GravityAdjust", {
    Title = "Gravity Adjustment",
    Default = "10",
    Placeholder = "Number",
    Numeric = true,
    Finished = false, 
    Callback = function(Value)
        DConfiguration.Misc.MovementModification.Gravity.Value = tonumber(Value) or 10
    end
})

local Toggle = Tabs.Misc:AddToggle("GravityToggle", {
    Title = "Gravity Toggle", 
    Default = false,
    Callback = function(State)
        DConfiguration.Misc.MovementModification.Gravity.FloatingButton = State
        
        if State then
           
            workspace.Gravity = DConfiguration.Misc.MovementModification.Gravity.Value
        else
          
            workspace.Gravity = NormalGravity
        end
    end
})

    
Tabs.Misc:AddParagraph({
        Title = " ",
        Content = ""
    })
    
Tabs.Misc:AddKeybind("BHOPToggleKey", {
    Title = "BHOP Toggle",
    Mode = "Toggle",
    Default = "B",
    Callback = function(State)
        DConfiguration.Misc.MovementModification.BHOP.FloatingButton = State
        DConfiguration.Misc.MovementModification.BHOP.Enabled = State
        
        if not State then
            task.spawn(DFunctions.ResetBHOP)
            task.wait(0.1)
            task.spawn(DFunctions.ResetBHOP)
        end
    end,
})

local UserInputService = game:GetService("UserInputService")

Tabs.Misc:AddKeybind("BHOPToggleKey", {
    Title = "BHOP Hold",
    Mode = "Toggle",
    Default = "Space",
    Callback = function()
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            DConfiguration.Misc.MovementModification.BHOP.FloatingButton = true
            DConfiguration.Misc.MovementModification.BHOP.Enabled = true
            
            while UserInputService:IsKeyDown(Enum.KeyCode.Space) do
                task.wait()
            end
            
            DConfiguration.Misc.MovementModification.BHOP.FloatingButton = false
            DConfiguration.Misc.MovementModification.BHOP.Enabled = false
            
            task.spawn(DFunctions.ResetBHOP)
            task.wait(0.1)
            task.spawn(DFunctions.ResetBHOP)
        end
    end,
})

local Dropdown = Tabs.Misc:AddDropdown("BHOPVersion", {
        Title = "Select BHOP Version",
        Values = {"Acceleration", "Ground Acceleration", "No Acceleration"},
        Multi = false,
        Default = 1,
    })

    Dropdown:OnChanged(function(Value)
        DConfiguration.Misc.MovementModification.BHOP.Type = Value
    end)
    
local Dropdown = Tabs.Misc:AddDropdown("JumpType", {
        Title = "Select Jump Type",
        Values = {"Simulated", "Nil"},
        Multi = false,
        Default = 1,
    })

    Dropdown:OnChanged(function(Value)
        DConfiguration.Misc.MovementModification.BHOP.JumpType = Value
    end)
    
Tabs.Misc:AddInput("BHOPAcceleration", {
        Title = "BHOP Acceleration (Negative Only)",
        Default = "-0.1",
        Placeholder = "-1",
        Numeric = false, -- Only allows numbers
        Finished = false, -- Only calls callback when you press enter
        Callback = function(Value)
            DConfiguration.Misc.MovementModification.BHOP.Acceleration = tonumber(Value) or -0.1
        end
    })
    
Tabs.Misc:AddParagraph({
        Title = " ",
        Content = ""
    })
    
local Toggle = Tabs.Misc:AddToggle("BHOPAutoAccelerate", {Title = "Auto Acceleration (Legit)", Default = false })

 Toggle:OnChanged(function(State)
      DConfiguration.Misc.MovementModification.BHOP.AutoAcceleration = State
end)

Tabs.Misc:AddInput("BHOPAcceleration", {
        Title = "Max Speed Acceleration",
        Default = "70",
        Placeholder = "70",
        Numeric = false, -- Only allows numbers
        Finished = false, -- Only calls callback when you press enter
        Callback = function(Value)
            DConfiguration.Misc.MovementModification.BHOP.MaxSpeed = tonumber(Value) or 70
        end
    })

RunService.Heartbeat:Connect(function()
    local stop = false

    if DConfiguration.Misc.MovementModification.BHOP.Enabled or DConfiguration.Misc.MovementModification.BHOP.Keybind then
        task.spawn(DFunctions.BHOPFunction)
        stop = true
    end

    if DConfiguration.Misc.MovementModification.Gravity.FloatingButton or DConfiguration.Misc.MovementModification.Gravity.Keybind then
        game.Workspace.Gravity = DConfiguration.Misc.MovementModification.Gravity.Value
    else
        game.Workspace.Gravity = NormalGravity
    end
    
    if not stop then
        if DConfiguration.Misc.MovementModification.EmoteModification.AggressiveEmoteDash.Enabled then
            task.spawn(DFunctions.SprintEmoteDash)
        end
    end
    
    RunService.RenderStepped:Wait()
end)

-- Visual

local ItemsFolder = ReplicatedStorage.Items

local Folder = Instance.new("Folder", ItemsFolder)
Folder.Name = "D-Folder"

local ChangeEmote1 = ""
local ChangeEmote2 = "" 
local ChangeCosmetics1 = "HeartSkaters" 
local ChangeCosmetics2 = "ToxicInferno"

function Normalize(input)
	return input:lower():gsub("%s+", "") 
end

function FindRealName(folder, userInput)
	local normalizedInput = Normalize(userInput)
	for _, item in ipairs(folder:GetChildren()) do
		if Normalize(item.Name) == normalizedInput then
			return item.Name
		end
	end
	return nil
end

function ChangeCosmetics(Name1, Name2)
	local Cosmetics = ReplicatedStorage.Items.Cosmetics
	local RealName1 = FindRealName(Cosmetics, Name1)
	local RealName2 = FindRealName(Cosmetics, Name2)

	if RealName1 and RealName2 then
		local I = Cosmetics:FindFirstChild(RealName1)
		local V = Cosmetics:FindFirstChild(RealName2)
		if I and V then
			I.Name = RealName2
			task.wait()
			V.Name = RealName1
		end
	end
end

function ChangeEmotes(Name1, Name2)
	local Emotes = ReplicatedStorage.Items.Emotes
	local RealName1 = FindRealName(Emotes, Name1)
	local RealName2 = FindRealName(Emotes, Name2)

	if RealName1 and RealName2 then
		local I = Emotes:FindFirstChild(RealName1)
		local V = Emotes:FindFirstChild(RealName2)
		if I and V then
			I.Name = RealName2
			task.wait()
			V.Name = RealName1
		end
	end
end

Tabs.Visual:AddSection("Skin/Cosmetics Changer")
    
local Input = Tabs.Visual:AddInput("CosmeticsChange1", {
        Title = "Current Cosmetics",
        Default = "HeartSkaters",
        Placeholder = "",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            ChangeCosmetics1 = Value
        end
    })
    
local Input = Tabs.Visual:AddInput("CosmeticsChange2", {
        Title = "Select Cosmetics",
        Default = "ToxicInferno",
        Placeholder = "",
        Numeric = false,
        Finished = false, 
        Callback = function(Value)
            ChangeCosmetics2 = Value
        end
    })
    
    
Tabs.Visual:AddButton({
        Title = "Change Cosmetics",
        Description = "" ,
        Callback = function()
          spawn(function()
             ChangeCosmetics(ChangeCosmetics1, ChangeCosmetics2)
           end)
        end
    })

Tabs.Visual:AddSection("Emote Changer")

CurrentEmote1 = ""
CurrentEmote2 = ""
CurrentEmote3 = ""
CurrentEmote4 = ""
CurrentEmote5 = ""
CurrentEmote6 = ""

SelectEmote1 = ""
SelectEmote2 = ""
SelectEmote3 = ""
SelectEmote4 = ""
SelectEmote5 = ""
SelectEmote6 = ""

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function Normalize(input)
    return input:lower():gsub("%s+", "") 
end

local function FindRealName(folder, userInput)
    if not folder then return nil end
    local normalizedInput = Normalize(userInput)
    for _, item in ipairs(folder:GetChildren()) do
        if Normalize(item.Name) == normalizedInput then
            return item.Name
        end
    end
    return nil
end

local function DirectNameSwapEmote(Name1, Name2)
    pcall(function()
        local EmotesFolder = ReplicatedStorage:FindFirstChild("Items") and ReplicatedStorage.Items:FindFirstChild("Emotes")
        if not EmotesFolder then return end
        
        local RealName1 = FindRealName(EmotesFolder, Name1)
        local RealName2 = FindRealName(EmotesFolder, Name2)
        
        if RealName1 and RealName2 and RealName1 ~= RealName2 then
            local I = EmotesFolder:FindFirstChild(RealName1)
            local V = EmotesFolder:FindFirstChild(RealName2)
            if I and V then
                I.Name = RealName2
                task.wait(0.01)
                V.Name = RealName1
            end
        end
    end)
end

Tabs.Visual:AddInput("EmoteCurrent1", {
    Title = "1 Current Emote",
    Default = CurrentEmote1,
    Placeholder = "",
    Numeric = false, Finished = false,
    Callback = function(Value) CurrentEmote1 = Value end
})

Tabs.Visual:AddInput("EmoteCurrent2", {
    Title = "2 Current Emote",
    Default = CurrentEmote2,
    Placeholder = "",
    Numeric = false, Finished = false,
    Callback = function(Value) CurrentEmote2 = Value end
})

Tabs.Visual:AddInput("EmoteCurrent3", {
    Title = "3 Current Emote",
    Default = CurrentEmote3,
    Placeholder = "",
    Numeric = false, Finished = false,
    Callback = function(Value) CurrentEmote3 = Value end
})

Tabs.Visual:AddInput("EmoteCurrent4", {
    Title = "4 Current Emote",
    Default = CurrentEmote4,
    Placeholder = "",
    Numeric = false, Finished = false,
    Callback = function(Value) CurrentEmote4 = Value end
})

Tabs.Visual:AddInput("EmoteCurrent5", {
    Title = "5 Current Emote",
    Default = CurrentEmote5,
    Placeholder = "",
    Numeric = false, Finished = false,
    Callback = function(Value) CurrentEmote5 = Value end
})

Tabs.Visual:AddInput("EmoteCurrent6", {
    Title = "6 Current Emote",
    Default = CurrentEmote6,
    Placeholder = "",
    Numeric = false, Finished = false,
    Callback = function(Value) CurrentEmote6 = Value end
})

Tabs.Visual:AddParagraph({ Title = " ", Content = "" })

Tabs.Visual:AddInput("EmoteSelect1", {
    Title = "1 Select Emote",
    Default = SelectEmote1,
    Placeholder = "",
    Numeric = false, Finished = false,
    Callback = function(Value) SelectEmote1 = Value end
})

Tabs.Visual:AddInput("EmoteSelect2", {
    Title = "2 Select Emote",
    Default = SelectEmote2,
    Placeholder = "",
    Numeric = false, Finished = false,
    Callback = function(Value) SelectEmote2 = Value end
})

Tabs.Visual:AddInput("EmoteSelect3", {
    Title = "3 Select Emote",
    Default = SelectEmote3,
    Placeholder = "",
    Numeric = false, Finished = false,
    Callback = function(Value) SelectEmote3 = Value end
})

Tabs.Visual:AddInput("EmoteSelect4", {
    Title = "4 Select Emote",
    Default = SelectEmote4,
    Placeholder = "",
    Numeric = false, Finished = false,
    Callback = function(Value) SelectEmote4 = Value end
})

Tabs.Visual:AddInput("EmoteSelect5", {
    Title = "5 Select Emote",
    Default = SelectEmote5,
    Placeholder = "",
    Numeric = false, Finished = false,
    Callback = function(Value) SelectEmote5 = Value end
})

Tabs.Visual:AddInput("EmoteSelect6", {
    Title = "6 Select Emote",
    Default = SelectEmote6,
    Placeholder = "",
    Numeric = false, Finished = false,
    Callback = function(Value) SelectEmote6 = Value end
})

Tabs.Visual:AddParagraph({ Title = "Don't use Stride with Rockin' Stride", Content = "It is advisable not to use Stride at all" })

Tabs.Visual:AddButton({
    Title = "Change Emotes",
    Description = "",
    Callback = function()
        task.spawn(function()
            local emotePairs = {
                {current = CurrentEmote1, select = SelectEmote1},
                {current = CurrentEmote2, select = SelectEmote2},
                {current = CurrentEmote3, select = SelectEmote3},
                {current = CurrentEmote4, select = SelectEmote4},
                {current = CurrentEmote5, select = SelectEmote5},
                {current = CurrentEmote6, select = SelectEmote6}
            }
            
            local usedEmotes = {}
            
            for i, pair in ipairs(emotePairs) do
                if pair.current and pair.select and pair.current ~= "" and pair.select ~= "" and pair.current ~= pair.select then
                    if not usedEmotes[pair.current] and not usedEmotes[pair.select] then
                        DirectNameSwapEmote(pair.current, pair.select)
                        
                        usedEmotes[pair.current] = true
                        usedEmotes[pair.select] = true
                        
                        task.wait(0.02)
                    end
                end
            end
        end)
    end
})

-- info

Tabs.Info:AddParagraph({
        Title = "PhantomWyrm Hub X / Overhaul Script",
        Content = "Created by Carey"
    })
    
Tabs.Info:AddParagraph({
        Title = "Adjustments / Movement Modification",
        Content = "Created by Carey"
    })

Tabs.Info:AddParagraph({
        Title = "Adjustments / ESP / Legacy Script",
        Content = "Created By Carey"
    })

Tabs.Info:AddButton({
    Title = "Discord Server",
    Description = "Click to copy link",
    Callback = function()
        setclipboard("https://discord.gg/DzgZSV8gk5")
    end
})
    
Tabs.Info:AddParagraph({
        Title = "UI: Fluent",
        Content = "Created by dawidscripts"
    })
     
-- Settings

Tabs.Settings:AddParagraph({
        Title = "Configuration",
        Content = " "
    })

Tabs.Settings:AddToggle("FPSCounterToggle", {
    Title = "FPS & Ping Counter",
    Default = true,
    Callback = function(Value)
        ToggleFPSCounter(Value)
    end
})
    
Tabs.Extension:AddSection("Character Extension")

_G.KorbloxR_Enabled = false
_G.KorbloxL_Enabled = false
_G.Headless_Enabled = false

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function revertChanges()
    local char = player.Character
    if not char then return end
    
    local head = char:FindFirstChild("Head")
    if head then
        head.Transparency = 0
        local mesh = head:FindFirstChild("HeadlessMesh")
        if mesh then mesh:Destroy() end
    end
    
    for _, partName in ipairs({"RightUpperLeg", "RightLowerLeg", "RightFoot", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "Right Leg", "Left Leg"}) do
        local part = char:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            part.Transparency = 0
            local m = part:FindFirstChild("KorbloxMesh")
            if m then m:Destroy() end
        end
    end
end

local function applyKorblox(side)
    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local isR15 = humanoid and humanoid.RigType == Enum.HumanoidRigType.R15
    
    if isR15 then
        local parts = (side == "Right") and {"RightUpperLeg", "RightLowerLeg", "RightFoot"} or {"LeftUpperLeg", "LeftLowerLeg", "LeftFoot"}
        for _, partName in ipairs(parts) do
            local part = char:FindFirstChild(partName)
            if part then
                part.Transparency = 1
            end
        end
    else
        local legName = (side == "Right") and "Right Leg" or "Left Leg"
        local leg = char:FindFirstChild(legName)
        local meshId = (side == "Right") and "rbxassetid://101851696" or "rbxassetid://101851582"
        
        if leg then
            for _, child in ipairs(leg:GetChildren()) do
                if child:IsA("SpecialMesh") then child:Destroy() end
            end
            leg.Color = Color3.fromRGB(50, 50, 50)
            local mesh = Instance.new("SpecialMesh")
            mesh.Name = "KorbloxMesh"
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.MeshId = meshId
            mesh.Parent = leg
        end
    end
end

local function applyHeadless()
    local char = player.Character
    local head = char and char:FindFirstChild("Head")
    if head then
        head.Transparency = 1
        if head:FindFirstChild("face") then head.face:Destroy() end
        
        if not head:FindFirstChild("HeadlessMesh") then
            local mesh = Instance.new("SpecialMesh")
            mesh.Name = "HeadlessMesh"
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.MeshId = "rbxassetid://1095708"
            mesh.Scale = Vector3.new(0.001, 0.001, 0.001)
            mesh.Parent = head
        end
    end
end

local function checkAndApplyAll()
    revertChanges()
    if _G.KorbloxR_Enabled then applyKorblox("Right") end
    if _G.KorbloxL_Enabled then applyKorblox("Left") end
    if _G.Headless_Enabled then applyHeadless() end
end

player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.5)
    checkAndApplyAll()
end)

if player.Character then
    checkAndApplyAll()
end

Tabs.Extension:AddToggle("KorbloxRToggle", {
    Title = "Korblox (Right)",
    Description = "",
    Default = false,
    Callback = function(Value)
        _G.KorbloxR_Enabled = Value
        checkAndApplyAll()
    end
})

Tabs.Extension:AddToggle("KorbloxLToggle", {
    Title = "Korblox (Left)",
    Description = "",
    Default = false,
    Callback = function(Value)
        _G.KorbloxL_Enabled = Value
        checkAndApplyAll()
    end
})

Tabs.Extension:AddToggle("HeadlessToggle", {
    Title = "Headless",
    Description = "",
    Default = false,
    Callback = function(Value)
        _G.Headless_Enabled = Value
        checkAndApplyAll()
    end
})

Tabs.Extension:AddParagraph({
        Title = " ",
        Content = ""
    })

_G.Players = game:GetService("Players")
_G.LPlayer = _G.Players.LocalPlayer

_G.ExtStates = {
    Wings = false,
    Poison = false,
    Frozen = false,
    Fire = false,
    Doomsekkar = false,
}

_G.ApplySingleExt = function(id, name, state)
    if not state then
        if _G.LPlayer.Character and _G.LPlayer.Character:FindFirstChild(name) then
            _G.LPlayer.Character[name]:Destroy()
        end
        return
    end
    
    local char = _G.LPlayer.Character
    if not char or char:FindFirstChild(name) then return end
    
    local s, obj = pcall(function() return game:GetObjects("rbxassetid://" .. id)[1] end)
    if s and obj then
        obj.Name = name
        obj.Parent = char
        
        local h = obj:FindFirstChild("Handle")
        if h and h:IsA("BasePart") then
            h.CanCollide = false
            
            local w = Instance.new("Weld")
            w.Part0 = h
            
            if name == "Wings_Acc" then
                local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                if torso then
                    w.Part1 = torso
                    w.C0 = obj.AttachmentPoint
                    w.C1 = CFrame.new(0, 1.7, 0.3) 
                else
                    w.Part1 = char:FindFirstChild("Head")
                    w.C0 = obj.AttachmentPoint
                    w.C1 = CFrame.new(0, 0.5, 0)
                end
            else
                w.Part1 = char:FindFirstChild("Head")
                w.C0 = obj.AttachmentPoint
                w.C1 = CFrame.new(0, 0.5, 0) 
            end
            
            w.Parent = h
        end
    end
end

_G.RefreshExts = function()
    if _G.ExtStates.Wings then _G.ApplySingleExt(192557913, "Wings_Acc", true) end
    if _G.ExtStates.Poison then _G.ApplySingleExt(1744060292, "Poison_Acc", true) end
    if _G.ExtStates.Frozen then _G.ApplySingleExt(74891470, "Frozen_Acc", true) end
    if _G.ExtStates.Fire then _G.ApplySingleExt(215718515, "Fire_Acc", true) end
    if _G.ExtStates.Doomsekkar then _G.ApplySingleExt(132809431, "Doomsekkar_Acc", true) end
    if _G.ExtStates.Frostsekkar then _G.ApplySingleExt(182672520, "Frostsekkar_Acc", true) end
    if _G.ExtStates.Infernosekkar then _G.ApplySingleExt(319643443, "Infernosekkar_Acc", true) end
    if _G.ExtStates.PoisonDusekkar then _G.ApplySingleExt(174405374, "PoisonDusekkar_Acc", true) end
end

_G.LPlayer.CharacterAdded:Connect(function()
    task.wait(1.5) 
    _G.RefreshExts()
end)

_G.Players = game:GetService("Players")
_G.LPlayer = _G.Players.LocalPlayer

_G.ExtStates = {
    Wings = false,
    Poison = false,
    Frozen = false,
    Fire = false,
    Doomsekkar = false,
}

_G.ApplySingleExt = function(id, name, state)
    if not state then
        if _G.LPlayer.Character and _G.LPlayer.Character:FindFirstChild(name) then
            _G.LPlayer.Character[name]:Destroy()
        end
        return
    end
    
    local char = _G.LPlayer.Character
    if not char or char:FindFirstChild(name) then return end
    
    local s, obj = pcall(function() return game:GetObjects("rbxassetid://" .. id)[1] end)
    if s and obj then
        obj.Name = name
        obj.Parent = char
        
        local h = obj:FindFirstChild("Handle")
        if h and h:IsA("BasePart") then
            h.CanCollide = false
            
            local w = Instance.new("Weld")
            w.Part0 = h
            
            if name == "Wings_Acc" then
                local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
                if torso then
                    w.Part1 = torso
                    w.C0 = obj.AttachmentPoint
                    w.C1 = CFrame.new(0, 1.7, 0.3) 
                else
                    w.Part1 = char:FindFirstChild("Head")
                    w.C0 = obj.AttachmentPoint
                    w.C1 = CFrame.new(0, 0.5, 0)
                end
            else
                w.Part1 = char:FindFirstChild("Head")
                w.C0 = obj.AttachmentPoint
                w.C1 = CFrame.new(0, 0.5, 0) 
            end
            
            w.Parent = h
        end
    end
end

_G.RefreshExts = function()
    if _G.ExtStates.Wings then _G.ApplySingleExt(192557913, "Wings_Acc", true) end
    if _G.ExtStates.Poison then _G.ApplySingleExt(1744060292, "Poison_Acc", true) end
    if _G.ExtStates.Frozen then _G.ApplySingleExt(74891470, "Frozen_Acc", true) end
    if _G.ExtStates.Fire then _G.ApplySingleExt(215718515, "Fire_Acc", true) end
    if _G.ExtStates.Doomsekkar then _G.ApplySingleExt(132809431, "Doomsekkar_Acc", true) end
    if _G.ExtStates.Frostsekkar then _G.ApplySingleExt(182672520, "Frostsekkar_Acc", true) end
    if _G.ExtStates.Infernosekkar then _G.ApplySingleExt(319643443, "Infernosekkar_Acc", true) end
    if _G.ExtStates.PoisonDusekkar then _G.ApplySingleExt(174405374, "PoisonDusekkar_Acc", true) end
end

_G.LPlayer.CharacterAdded:Connect(function()
    task.wait(1.5) 
    _G.RefreshExts()
end)

Tabs.Extension:AddToggle("TogWings", {
    Title = "Angelic Wings",
    Default = false,
    Callback = function(state) 
        _G.ExtStates.Wings = state 
        _G.ApplySingleExt(192557913, "Wings_Acc", state) 
    end
})

Tabs.Extension:AddToggle("TogPoison", {
    Title = "Poisonous Horns",
    Default = false,
    Callback = function(state) 
        _G.ExtStates.Poison = state 
        _G.ApplySingleExt(1744060292, "Poison_Acc", state) 
    end
})

Tabs.Extension:AddToggle("TogFrozen", {
    Title = "Frozen Horn",
    Default = false,
    Callback = function(state) 
        _G.ExtStates.Frozen = state 
        _G.ApplySingleExt(74891470, "Frozen_Acc", state) 
    end
})

Tabs.Extension:AddToggle("TogFire", {
    Title = "Fire Horn",
    Default = false,
    Callback = function(state) 
        _G.ExtStates.Fire = state 
        _G.ApplySingleExt(215718515, "Fire_Acc", state) 
    end
})

Tabs.Extension:AddToggle("TogDoomsekkar", {
    Title = "Doomsekkar",
    Default = false,
    Callback = function(state) 
        _G.ExtStates.Doomsekkar = state 
        _G.ApplySingleExt(132809431, "Doomsekkar_Acc", state) 
    end
})

Tabs.Extension:AddParagraph({
        Title = " ",
        Content = ""
    })

local Players = game:GetService("Players")
local player = Players.LocalPlayer

_G.DeleteHatsEnabled = false

task.spawn(function()
    while true do
        if _G.DeleteHatsEnabled then
            local char = player.Character
            if char then
                for _, v in ipairs(char:GetChildren()) do 
                    if v:IsA("Accessory") then
                        v:Destroy() 
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

Tabs.Extension:AddToggle("DeleteHats", {
    Title = "Remove Accessories",
    Description = "",
    Default = false,
    Callback = function(Value)
        _G.DeleteHatsEnabled = Value
    end
})


Tabs.Extension:AddButton({
    Title = "AvatarChanger",
    Description = "By Byteed",
    Callback = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-client-avatar-changer-92130"))()
    end
})

Tabs.Extension:AddSection("Camera Extension")

Tabs.Extension:AddButton({
        Title = "sensitivity",
        Description = "",
        Callback = function()
loadstring(game:HttpGet("https://raw.githubusercontent.com/inuaposzoawjsjs-glitch/.githubasset/refs/heads/master/MODDEDFLUENT/Sensitivity.lua"))()
        end
    }
)

Tabs.Extension:AddSection("Shader Extension")

local function ClearLighting()
    for _, child in ipairs(Lighting:GetChildren()) do
        if child.Name ~= "MenuBlur" then
            child:Destroy()
        end
    end
end

Tabs.Extension:AddButton(
    {
        Title = "Day",
        Description = "",
        Callback = function()
            ClearLighting()

            Lighting.Ambient = Color3.new(0, 0, 0)
            Lighting.OutdoorAmbient = Color3.new(0.568627, 0.501961, 0.372549)
            Lighting.Brightness = 3.130000114440918
            Lighting.ClockTime = 14.5
            Lighting.ExposureCompensation = 0
            Lighting.FogColor = Color3.new(0.572549, 0.815686, 1)
            Lighting.FogEnd = 3000
            Lighting.FogStart = 300
            Lighting.GlobalShadows = true
            Lighting.GeographicLatitude = 143
            Lighting.EnvironmentDiffuseScale = 0.5830000042915344
            Lighting.EnvironmentSpecularScale = 1
            Lighting.ShadowSoftness = 0.03999999910593033
            Lighting.ColorShift_Top = Color3.new(0.737255, 0.552941, 0.00392157)
            Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
            Lighting.Technology = Enum.Technology.ShadowMap
            Lighting.TimeOfDay = "14:30:00"

            local Sky = Instance.new("Sky")
            Sky.Name = "Sky"
            Sky.SkyboxBk = "rbxassetid://6444884337"
            Sky.SkyboxDn = "rbxassetid://6444884785"
            Sky.SkyboxFt = "rbxassetid://6444884337"
            Sky.SkyboxLf = "rbxassetid://6444884337"
            Sky.SkyboxRt = "rbxassetid://6444884337"
            Sky.SkyboxUp = "rbxassetid://6412503613"
            Sky.MoonAngularSize = 11
            Sky.SunAngularSize = 11
            Sky.MoonTextureId = "rbxassetid://6444320592"
            Sky.SunTextureId = "rbxassetid://1084351190"
            Sky.StarCount = 0
            Sky.Parent = Lighting

            local Bloom = Instance.new("BloomEffect")
            Bloom.Name = "Bloom"
            Bloom.Enabled = true
            Bloom.Intensity = 1
            Bloom.Threshold = 2
            Bloom.Size = 90
            Bloom.Parent = Lighting

            local ColorCorrection = Instance.new("ColorCorrectionEffect")
            ColorCorrection.Name = "ColorCorrection"
            ColorCorrection.Enabled = true
            ColorCorrection.Brightness = 0.03999999910593033
            ColorCorrection.Contrast = 0.1899999976158142
            ColorCorrection.Saturation = 0.11999999731779099
            ColorCorrection.TintColor = Color3.new(1, 1, 1)
            ColorCorrection.Parent = Lighting
        end
    }
)

Tabs.Extension:AddButton(
    {
        Title = "Sunset",
        Description = "",
        Callback = function()
            ClearLighting()

            Lighting.Ambient = Color3.new(0.67451, 0.67451, 0.67451)
            Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
            Lighting.Brightness = 3.799999952316284
            Lighting.ClockTime = 7.099999904632568
            Lighting.ExposureCompensation = -0.23999999463558197
            Lighting.FogColor = Color3.new(0, 0, 0)
            Lighting.FogEnd = 100000000
            Lighting.FogStart = 20
            Lighting.GlobalShadows = true
            Lighting.GeographicLatitude = 72
            Lighting.EnvironmentDiffuseScale = 0.30000001192092896
            Lighting.EnvironmentSpecularScale = 0.05999999865889549
            Lighting.ShadowSoftness = 0.10000000149011612
            Lighting.ColorShift_Top = Color3.new(1, 0.682353, 0.168627)
            Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
            Lighting.Technology = Enum.Technology.Future
            Lighting.TimeOfDay = "07:06:00"

            local Sky = Instance.new("Sky")
            Sky.Name = "Sky"
            Sky.CelestialBodiesShown = true
            Sky.SkyboxBk = "rbxassetid://1009082031"
            Sky.SkyboxDn = "rbxassetid://1009082487"
            Sky.SkyboxFt = "rbxassetid://1009082252"
            Sky.SkyboxLf = "rbxassetid://1009082137"
            Sky.SkyboxRt = "rbxassetid://1009081946"
            Sky.SkyboxUp = "rbxassetid://1009082428"
            Sky.MoonAngularSize = 0
            Sky.SunAngularSize = 9
            Sky.MoonTextureId = "rbxasset://sky/moon.jpg"
            Sky.SunTextureId = "rbxasset://sky/sun.jpg"
            Sky.StarCount = 3000
            Sky.Parent = Lighting

            local Bloom = Instance.new("BloomEffect")
            Bloom.Name = "Bloom"
            Bloom.Enabled = true
            Bloom.Intensity = 1
            Bloom.Threshold = 1.8240000009536743
            Bloom.Size = 56
            Bloom.Parent = Lighting

            local SunRays = Instance.new("SunRaysEffect")
            SunRays.Name = "SunRays"
            SunRays.Enabled = true
            SunRays.Intensity = 0.18000000715255737
            SunRays.Spread = 0.11999999731779099
            SunRays.Parent = Lighting

            local ColorCorrection = Instance.new("ColorCorrectionEffect")
            ColorCorrection.Name = "ColorCorrection"
            ColorCorrection.Enabled = true
            ColorCorrection.Brightness = 0
            ColorCorrection.Contrast = 0.10000000149011612
            ColorCorrection.Saturation = -0.20000000298023224
            ColorCorrection.TintColor = Color3.new(1, 1, 1)
            ColorCorrection.Parent = Lighting

            local Atmosphere = Instance.new("Atmosphere")
            Atmosphere.Name = "Atmosphere"
            Atmosphere.Color = Color3.new(0.780392, 0.666667, 0.419608)
            Atmosphere.Density = 0.41999998688697815
            Atmosphere.Offset = 0
            Atmosphere.Glare = 0
            Atmosphere.Haze = 0
            Atmosphere.Parent = Lighting
        end
    }
)

Tabs.Extension:AddButton(
    {
        Title = "Shore",
        Description = "",
        Callback = function()
            ClearLighting()

            Lighting.Ambient = Color3.new(0.427451, 0.458824, 0.529412)
            Lighting.OutdoorAmbient = Color3.new(0.141176, 0.184314, 0.227451)
            Lighting.Brightness = 1.9210000038146973
            Lighting.ClockTime = -6.399722099304199
            Lighting.ExposureCompensation = -0.20000000298023224
            Lighting.FogColor = Color3.new(0.752941, 0.752941, 0.752941)
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
            Lighting.GlobalShadows = true
            Lighting.GeographicLatitude = 0
            Lighting.EnvironmentDiffuseScale = 0.1720000058412552
            Lighting.EnvironmentSpecularScale = 0.6380000114440918
            Lighting.ShadowSoftness = 0.25
            Lighting.ColorShift_Top = Color3.new(0.886275, 0.294118, 0)
            Lighting.ColorShift_Bottom = Color3.new(0.972549, 0.647059, 0.623529)
            Lighting.Technology = Enum.Technology.ShadowMap
            Lighting.TimeOfDay = "-06:23:59"

            local Sky = Instance.new("Sky")
            Sky.Name = "Sky"
            Sky.CelestialBodiesShown = true
            Sky.SkyboxBk = "rbxassetid://88585370973398"
            Sky.SkyboxDn = "rbxassetid://128014535205529"
            Sky.SkyboxFt = "rbxassetid://85323615042244"
            Sky.SkyboxLf = "rbxassetid://77415797450913"
            Sky.SkyboxRt = "rbxassetid://127566931602371"
            Sky.SkyboxUp = "rbxassetid://102320981098060"
            Sky.MoonAngularSize = 0
            Sky.SunAngularSize = 4
            Sky.MoonTextureId = "rbxasset://sky/moon.jpg"
            Sky.SunTextureId = "rbxasset://sky/sun.jpg"
            Sky.StarCount = 5000
            Sky.Parent = Lighting

            local SunRays = Instance.new("SunRaysEffect")
            SunRays.Name = "SunRays"
            SunRays.Enabled = true
            SunRays.Intensity = 0.024000000208616257
            SunRays.Spread = 0.46299999952316284
            SunRays.Parent = Lighting

            local Bloom = Instance.new("BloomEffect")
            Bloom.Name = "Bloom"
            Bloom.Enabled = true
            Bloom.Intensity = 1
            Bloom.Threshold = 2.2911999225616455
            Bloom.Size = 50
            Bloom.Parent = Lighting

            local ColorCorrection = Instance.new("ColorCorrectionEffect")
            ColorCorrection.Name = "ColorCorrection"
            ColorCorrection.Enabled = true
            ColorCorrection.Brightness = 0
            ColorCorrection.Contrast = 0.20000000298023224
            ColorCorrection.Saturation = 0
            ColorCorrection.TintColor = Color3.new(1, 1, 1)
            ColorCorrection.Parent = Lighting

            local Atmosphere = Instance.new("Atmosphere")
            Atmosphere.Name = "Atmosphere"
            Atmosphere.Color = Color3.new(1, 0.847059, 0.760784)
            Atmosphere.Density = 0.35899999737739563
            Atmosphere.Offset = 0
            Atmosphere.Glare = 2.9700000286102295
            Atmosphere.Haze = 1.5199999809265137
            Atmosphere.Parent = Lighting

            local Blur = Instance.new("BlurEffect")
            Blur.Name = "Blur"
            Blur.Size = 4
            Blur.Parent = Lighting
        end
    }
)

Tabs.Extension:AddButton(
    {
        Title = "Cloudy",
        Description = "",
        Callback = function()
            ClearLighting()

            Lighting.Ambient = Color3.new(0, 0, 0)
            Lighting.OutdoorAmbient = Color3.new(0.34902, 0.266667, 0.184314)
            Lighting.Brightness = 5.630000114440918
            Lighting.ClockTime = 17.628889083862305
            Lighting.ExposureCompensation = 0.6299999952316284
            Lighting.FogColor = Color3.new(0.572549, 0.815686, 1)
            Lighting.FogEnd = 3000
            Lighting.FogStart = 300
            Lighting.GlobalShadows = true
            Lighting.GeographicLatitude = 21.58930015563965
            Lighting.EnvironmentDiffuseScale = 0.5830000042915344
            Lighting.EnvironmentSpecularScale = 1
            Lighting.ShadowSoftness = 0.03999999910593033
            Lighting.ColorShift_Top = Color3.new(0.811765, 0.447059, 0)
            Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
            Lighting.Technology = Enum.Technology.ShadowMap
            Lighting.TimeOfDay = "17:37:44"

            local Sky = Instance.new("Sky")
            Sky.Name = "Sky"
            Sky.CelestialBodiesShown = true
            Sky.SkyboxBk = "rbxassetid://2177969403"
            Sky.SkyboxDn = "rbxassetid://2177972406"
            Sky.SkyboxFt = "rbxassetid://2177970251"
            Sky.SkyboxLf = "rbxassetid://2177969836"
            Sky.SkyboxRt = "rbxassetid://2177968823"
            Sky.SkyboxUp = "rbxassetid://2177971305"
            Sky.MoonAngularSize = 1.5
            Sky.SunAngularSize = 3
            Sky.MoonTextureId = "rbxassetid://1075087760"
            Sky.SunTextureId = "rbxasset://sky/sun.jpg"
            Sky.StarCount = 500
            Sky.Parent = Lighting

            local Bloom = Instance.new("BloomEffect")
            Bloom.Name = "Bloom"
            Bloom.Enabled = true
            Bloom.Intensity = 1
            Bloom.Threshold = 2
            Bloom.Size = 90
            Bloom.Parent = Lighting

            local ColorCorrection = Instance.new("ColorCorrectionEffect")
            ColorCorrection.Name = "ColorCorrection"
            ColorCorrection.Enabled = true
            ColorCorrection.Brightness = 0.03999999910593033
            ColorCorrection.Contrast = 0.15000000596046448
            ColorCorrection.Saturation = 0.20000000298023224
            ColorCorrection.TintColor = Color3.new(1, 1, 1)
            ColorCorrection.Parent = Lighting

            local SunRays = Instance.new("SunRaysEffect")
            SunRays.Name = "SunRays"
            SunRays.Enabled = true
            SunRays.Intensity = 0.004000000189989805
            SunRays.Spread = 0.16699999570846558
            SunRays.Parent = Lighting

            local Atmosphere = Instance.new("Atmosphere")
            Atmosphere.Name = "Atmosphere"
            Atmosphere.Color = Color3.new(0.647059, 0.647059, 0.647059)
            Atmosphere.Density = 0.3569999933242798
            Atmosphere.Offset = 0
            Atmosphere.Glare = 0.20999999344348907
            Atmosphere.Haze = 1.4600000381469727
            Atmosphere.Parent = Lighting
        end
    }
)

Tabs.Extension:AddButton(
    {
        Title = "Night",
        Description = "",
        Callback = function()
            ClearLighting()

            Lighting.Ambient = Color3.new(0, 0, 0)
            Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
            Lighting.Brightness = 2
            Lighting.ClockTime = 3
            Lighting.ExposureCompensation = 0
            Lighting.FogColor = Color3.new(0, 0, 0)
            Lighting.FogEnd = 100000
            Lighting.FogStart = 0
            Lighting.GlobalShadows = true
            Lighting.GeographicLatitude = 41.733001708984375
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
            Lighting.ShadowSoftness = 0.20000000298023224
            Lighting.ColorShift_Top = Color3.new(0, 0, 0)
            Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
            Lighting.Technology = Enum.Technology.Future
            Lighting.TimeOfDay = "03:00:00"

            local Sky = Instance.new("Sky")
            Sky.Name = "Sky"
            Sky.CelestialBodiesShown = true
            Sky.SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex"
            Sky.SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex"
            Sky.SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex"
            Sky.SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex"
            Sky.SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex"
            Sky.SkyboxUp = "rbxasset://textures/sky/sky512_up.tex"
            Sky.MoonAngularSize = 11
            Sky.SunAngularSize = 21
            Sky.MoonTextureId = "rbxasset://sky/moon.jpg"
            Sky.SunTextureId = "rbxasset://sky/sun.jpg"
            Sky.StarCount = 5000
            Sky.Parent = Lighting

            local Blur = Instance.new("BlurEffect")
            Blur.Name = "Blur"
            Blur.Enabled = true
            Blur.Size = 0
            Blur.Parent = Lighting

            local Atmosphere = Instance.new("Atmosphere")
            Atmosphere.Name = "Atmosphere"
            Atmosphere.Color = Color3.new(0, 0, 0)
            Atmosphere.Density = 0.5600000023841858
            Atmosphere.Offset = 0
            Atmosphere.Glare = 0
            Atmosphere.Haze = 0
            Atmosphere.Parent = Lighting
        end
    }
)

Tabs.Extension:AddSection("Custom Sky")

task.spawn(function()
    local L = game:GetService("Lighting")
    local skyData = {
        ["Default"] = "",
        ["BlackHole3D"] = "rbxassetid://80849072113452",
        ["BlackHole2D"] = "rbxassetid://107612473658715",
        ["Galaxy"] = "rbxassetid://103103587555183",
        ["Saturn"] = "rbxassetid://78498232605923",
        ["Moon"] = "rbxassetid://130749862399911",
        ["Retro"] = "rbxassetid://103427685372239",
        ["BlueEye"] = "rbxassetid://127514067186397",
        ["PhantomWyrm"] = "rbxassetid://75138310179914",
        ["RetroDiscord"] = "rbxassetid://89057708562209",
        ["Cat"] = "rbxassetid://120407577036889" ,
        ["Cat2"] = "rbxassetid://127289321458446",
    }

    local skyNames = {}
    for n in pairs(skyData) do table.insert(skyNames, n) end
    table.sort(skyNames)

    Tabs.Extension:AddDropdown("SkyboxChanger", {
        Title = "Skybox Selection",
        Values = skyNames,
        Default = "Default",
        Callback = function(v)
            local id = skyData[v]
            local oldSky = L:FindFirstChild("CustomSkybox")
            if oldSky then oldSky:Destroy() end

            if v ~= "Default" and id and id ~= "" then 
                local newCs = Instance.new("Sky")
                newCs.Name = "CustomSkybox"
                local s = {"SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp"}
                for _, side in ipairs(s) do newCs[side] = id end
                newCs.Parent = L
            end
        end
    })
    
    DFunctions.rbConn = nil

    Tabs.Extension:AddToggle("RainbowAmbient", {
        Title = "Rainbow Ambient",
        Default = false,
        Callback = function(Value)
            if DFunctions.rbConn then DFunctions.rbConn:Disconnect() end
            if Value then
                DFunctions.rbConn = game:GetService("RunService").RenderStepped:Connect(function()
                    local c = Color3.fromHSV((tick() * 0.2) % 1, 0.8, 1)
                    L.Ambient = c
                    L.OutdoorAmbient = c
                end)
            else
                L.Ambient = Color3.fromRGB(127, 127, 127)
                L.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            end
        end
    })
end)

        
Tabs.Extension:AddSection("Lightning Extension")

local Lighting = game:GetService("Lighting")

local fbLoopActive = false
local fogLoopActive = false

getgenv().FbBrightnessValue = 2

local function forceFullBright()
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
    Lighting.ColorShift_Top = Color3.new(1, 1, 1)
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
    Lighting.ClockTime = 14
    Lighting.Brightness = getgenv().FbBrightnessValue
end

local function forceNoFog()
    Lighting.FogEnd = 100000
    local A = Lighting:FindFirstChildOfClass("Atmosphere")
    if A then
        A.Density = 0
        A.Glare = 0
        A.Haze = 0
    end
end

local Toggle = Tabs.Extension:AddToggle("FullBright", {
    Title = "Full Bright", 
    Default = false
})

local BrightnessInput = Tabs.Extension:AddInput("FbBrightnessInput", {
    Title = "Full Bright Brightness",
    Default = "2",
    Placeholder = "Enter brightness level...",
    Numeric = true,
    Finished = false
})

Toggle:OnChanged(function(state)
    fbLoopActive = state

    if state then
        task.spawn(function()
            while fbLoopActive do
                pcall(forceFullBright)
                task.wait(0.1)
            end
        end)
    else
        pcall(function()
            Lighting.GlobalShadows = true
            local A = Lighting:FindFirstChildOfClass("Atmosphere")
            if A then
                Lighting.Ambient = Color3.new(0, 0, 0)
                Lighting.Brightness = 1
            else
                Lighting.Ambient = Color3.fromRGB(128, 128, 128)
                Lighting.Brightness = 1
            end
            Lighting.FogEnd = 1000
        end)
    end
end)

BrightnessInput:OnChanged(function()
    local value = tonumber(BrightnessInput.Value)
    if value then
        getgenv().FbBrightnessValue = value
    else
        getgenv().FbBrightnessValue = 2
    end
end)

Options.FullBright:SetValue(false)

local NoFogToggle = Tabs.Extension:AddToggle("NoFogToggle", {
    Title = "Disable Fog",
    Default = false
})

NoFogToggle:OnChanged(function(Value)
    fogLoopActive = Value
    
    if Value then
        task.spawn(function()
            while fogLoopActive do
                pcall(forceNoFog)
                task.wait(0.1)
            end
        end)
    else
        pcall(function()
            Lighting.FogEnd = 1000
            local A = Lighting:FindFirstChildOfClass("Atmosphere")
            if A then
                A.Density = 0.3
                A.Glare = 0
                A.Haze = 0
            end
        end)
    end
end)


Tabs.Extension:AddSection("Fast Flag Extension")

if setfflag then
    Tabs.Extension:AddButton(
        {
            Title = "Blox Strap Script",
            Description = "",
            Callback = function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/main/Initiate.lua'), 'lol')()
            end
        }
    )
    
    Tabs.Extension:AddButton(
        {
            Title = "Accurate Low Quality",
            Description = "(FastFlag)",
            Callback = function()
                

                setfpscap(900) 

                setfflag("TaskSchedulerTargetFps", "900") 

                local function removeWater()
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("Terrain") then
                            obj.WaterTransparency = 1
                            obj.WaterWaveSize = 0
                            obj.WaterWaveSpeed = 0
                            obj.WaterReflectance = 0
                        end
                    end
                end

                local function removeReflections()
                    local lighting = game:GetService("Lighting")
                    lighting.EnvironmentSpecularScale = 0
                    lighting.EnvironmentDiffuseScale = 0
                end

                local function removeEffects()
                    for _, effect in pairs(workspace:GetDescendants()) do
                        if
                            effect:IsA("ParticleEmitter") or effect:IsA("Smoke") or effect:IsA("Fire") or
                                effect:IsA("Sparkles")
                         then
                            effect.Enabled = false
                        end
                    end
                end

                local function removeGrass()
                    setfflag("FRMMinGrassDistance", "0")
                    setfflag("FRMMaxGrassDistance", "0")
                    setfflag("RenderGrassDetailStrands", "0")
                end

                local function removeExplosions()
                    for _, explosion in pairs(workspace:GetDescendants()) do
                        if explosion:IsA("Explosion") then
                            explosion:Destroy()
                        end
                    end
                end

                local function setLowShadows()
                    game.Lighting.Technology = Enum.Technology.Voxel
                    game.Lighting.GlobalShadows = false
                end

                local function setLowQuality()
                    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                end

                local function setFlagsGraphics()
                    setfflag("DebugGraphicsPreferVulkan", "true")
                    setfflag("DebugTextureManagerSkipMips", "2")
                    setfflag("TaskSchedulerLimitTargetFpsTo2402", "false")
                    setfflag("TaskSchedulerTargetFps", "900")
                end

                local function reduceLag()
                    removeWater()
                    removeReflections()
                  
                    setLowShadows()
                    setLowQuality()
                    setFlagsGraphics()
                    removeGrass()
                end

                reduceLag()

                workspace.DescendantAdded:Connect(
                    function(descendant)
                        if descendant:IsA("Terrain") then
                            wait(0.5)
                            reduceLag()
                        end
                    end
                )
            end
        }
    )
end    
    
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:SetIgnoreIndexes({})

-- Save Folder
InterfaceManager:SetFolder("PhantomWyrmXUniversalPC")
SaveManager:SetFolder("PhantomWyrmXUniversal/Legacy-Evade")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

-- Auto Load Configuration
SaveManager:LoadAutoloadConfig()

local LP = game:GetService("Players").LocalPlayer
local GetMethod = getnamecallmethod
local Select = select

local old
old = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = GetMethod()

    
    if method == "InvokeServer" and self.Name == "Communicator" then
        
        if self.Parent == LP.Character then
            
            if Select(1, ...) == "update" then
                local cfg = DConfiguration.Misc.PlayerAdjustment.Update
                return cfg.Speed, cfg.JumpHeight
            end
        end
    end

    return old(self, ...)
end))


local function initialize(character)
    if character then
        task.delay(5, function()
            if DFunctions and DFunctions.HookMovement then
                DFunctions.HookMovement(character)
            end
        end)
    end
end

LP.CharacterAdded:Connect(initialize)
if LP.Character then
    initialize(LP.Character)
end
