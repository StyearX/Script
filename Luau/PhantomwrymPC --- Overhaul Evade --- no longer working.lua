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
    Title = "PhantomWyrm Hub X - Evade Overhaul│PC",
    SubTitle = "v3.38.21 Made Carey",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "rbxassetid://7733960981" }),
    AutoFarm = Window:AddTab({ Title = "Auto Farm", Icon = "rbxassetid://10709811110" }),
    Nextbots = Window:AddTab({ Title = "Anti Nextbots", Icon = "shield" }),
    Misc = Window:AddTab({ Title = "Movement", Icon = "rbxassetid://7734068321" }),
    Exploits = Window:AddTab({ Title = "Exploits", Icon = "bomb" }),
    Visual = Window:AddTab({ Title = "Visuals", Icon = "rbxassetid://10709819149" }),
    Info = Window:AddTab({ Title = "Info", Icon = "rbxassetid://10723415903" }),
    Settings = Window:AddTab({ Title = "Configuration", Icon = "rbxassetid://7734052335" }),
    Extension = Window:AddTab({ Title = "Extension", Icon = "rbxassetid://10734930886" }),
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
backgroundImage.Size = UDim2.new(1.8 + SizeBackMulti, 0, 1.8 + SizeBackMulti, 0)
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
        Vignette = false,
        InvisibleWalls = false,
        ReducingRewards = false,
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
    
    Battlepass = {
	    BypassTimer = false,
    },

    AutoFarm = {
        FarmingStates = {
            IsReviving = false,
            IsCompletingObjective = false,
            IsCollectingTickets = false,
            IsCatchingNPC = false,
        },

        AFKFarm = false,
        FarmTickets = false,
        CompleteObjective = false,
        FarmTokens = false,
        
        PurchaseAutomations = {
            Enabled = false,
	        Selected = "Cola",	        
        },
        
        VIPAutomations = {
            AutoVote = false,
            MapSection = 1,
            GamemodeSection = 1,
	        AutoMap = false,
	        MapInput = "DesertBus",
	        AutoSpecialRound = false,
	        SpecialRoundInput = "Plushie Hell",
	        AutoTimer = false,
	        TimerInput = "",
	        AutoProMode = false,
        },
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
                JumpCap = 1,
                JumpAcceleration = 1.5,
                AirStrafe = 182,
                GroundAcceleration = 5,
                BHOPEnabled = false,
            },

            Update = {
                Speed = 1500,
                JumpHeight = 3,
                JumpCap = 1,
                JumpAcceleration = 1.5,
                AirStrafe = 182,
                GroundAcceleration = 5,
                BHOPEnabled = false,
            },

            Saved = {
                Speed = 1500,
                JumpHeight = 3,
                JumpCap = 1,
                JumpAcceleration = 1.5,
                AirStrafe = 182,
                GroundAcceleration = 5,
            },

            Tick = {
                Speed = 0,
                JumpHeight = 0,
                JumpCap = 0,
                JumpAcceleration = 0,
                AirStrafe = 0,
                GroundAcceleration = 0,
                BHOPEnabled = 0,
            },

            Debounce = {
                Speed = false,
                JumpHeight = false,
                JumpCap = false,
                JumpAcceleration = false,
                AirStrafe = false,
                GroundAcceleration = false,
                BHOPEnabled = false,
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
                SuperBounce = false,
                SuperBounceStrength = -50,
            },
            
            EdgeTrimpModification = {
	            Enabled = false,
	            HeightMultiplier = 1.5,
	            DownThreshold = 4.5
            },

            LagSwitch = {
                MSDelay = 200,
                Mode = "Normal",
            },
        },

        CameraAdjustment = {
            StretchX = 1,
            StretchY = 1,
        },

        GunAdjustment = {
            v = nil,
        },

        GameAutomation = {
            Revive = {
                Enabled = false,
                FloatingButton = false,
                Keybind = false,
                WhileEmote = false,
                Delay = 0.1,
            },

            Carry = {
                Enabled = false,
                FloatingButton = false,
                Keybind = false,
                WhileEmote = false,
            },

            Macro = {
                SelectedEmote = "BoldMarch",
                FloatingButton = false,
                Keybind = false,
            },
        },

        MovementModification = {
            AggressiveEmoteDash = {
                Enabled = false,
                Type = "Blatant",
                Speed = 3000,
                Acceleration = -2,
            },

            SlideModification = {
                FloatingButton = false,
                Enabled = false,
                Acceleration = -3,
            },

            Gravity = {
                FloatingButton = false,
                Keybind = false,
                Value = 10,
            },
            
            BHOP = {
                Enabled = false,
                Keybind = false,
                HoldKeybind = false,
                FloatingButton = false,
                JumpButton = false,
                HipHeight1 = 0,
                HipHeight2 = 0,
                lastTick = 0.01,
                Settings = {
	                AutoAcceleration = {
		                Enabled = false,
		                MaxAccelerate = 3,
		                MinAccelerate = -1,
		                MinSpeed = 70
	                },
	                SpiderHop = false,
	                Backwards = false,
	                Type = "Acceleration",
	                JumpType = "Simulated",
	                Acceleration = -0.1,
                },
            },
            
            Crouch = {
	            FloatingButton = false,
	            Keybind = false,
	            Type = "Rapid",
	            isHolding = false,
	            debounce = 0.1,
	            lastTick = 0.1,
	            lastReleaseTick = 0.1,
            },
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
            Emote7 = "",
            Emote8 = "",
            Emote9 = "",
            Emote10 = "",
            Emote11 = "",
            Emote12 = "",
        },

        ModifyEmotes = {
            Emote1 = "",
            Emote2 = "",
            Emote3 = "",
            Emote4 = "",
            Emote5 = "",
            Emote6 = "",
            Emote7 = "",
            Emote8 = "",
            Emote9 = "",
            Emote10 = "",
            Emote11 = "",
            Emote12 = "",
        },
    },

    Settings = {
        GuiScale = {
            Respawn = 0,
            SuperBounce = 0,
            AutoCarry = 0,
            InstantRevive = 0,
            AutoEmoteDash = 0,
            Gravity = 0,
            InfiniteSlide = 0,
            AutoJump = 0,
            AutoCrouch = 0,
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

-- Main logic

function DFunctions.AutoRespawn()
 	local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
     local RespawnType = DConfiguration.Main.RespawnType
     
	 if Character and Character:GetAttribute("Downed") == true and RespawnType == "Spawnpoint" then
		 ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
     elseif Character and Character:GetAttribute("Downed") == true and RespawnType == "Fake Revive" then
	     local PreviousPosition
	     PreviousPosition = LocalPlayer.Character.HumanoidRootPart.Position
    	 wait(0.2)
	     ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
	     wait(1)
	     LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(PreviousPosition)
	 end
end

function DFunctions.RemoveDamagePart()
   local Map = Workspace.Game.Map
   
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

function DFunctions.RemoveReduceRewards()
    for i, v in pairs(Workspace.Game.Map.SafeZones:GetDescendants()) do
       if v:IsA("BasePart") then
          v:Destroy()
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

function DFunctions.DisableCameraShake()
    local FOVAdjusters = LocalPlayer:FindFirstChild("PlayerScripts") and LocalPlayer.PlayerScripts:FindFirstChild("Camera") and LocalPlayer.PlayerScripts.Camera:FindFirstChild("FOVAdjusters")
    local CameraSet = LocalPlayer:FindFirstChild("PlayerScripts") and LocalPlayer.PlayerScripts:FindFirstChild("Camera") and LocalPlayer.PlayerScripts.Camera:FindFirstChild("Set")

    if FOVAdjusters and CameraSet then
       FOVAdjusters:SetAttribute("Fear", 1)
       CameraSet:Invoke("CFrameOffset", "Shake", CFrame.new())
    end
end

function DFunctions.DisableVignette()
	local HUD = LocalPlayer:FindFirstChild("Shared") and LocalPlayer.Shared:FindFirstChild("HUD")
	local NextbotNoise = HUD and HUD:FindFirstChild("NextbotNoise")
	
	if HUD and NextbotNoise then
	   NextbotNoise.ImageTransparency = 1
	   local Noise = NextbotNoise:FindFirstChild("Noise")
	   local Noise2 = NextbotNoise:FindFirstChild("Noise2")
	   
	   if Noise then
	       Noise.ImageTransparency = 1
	   elseif Noise2 then
	       Noise2.ImageTransparency = 1
	   end
	end
end

-- Auto farm logic

function DFunctions.GetDownedPlayer()
    for i,v in pairs(Workspace.Game.Players:GetChildren()) do
        if v:GetAttribute("Downed") then
            return v
        end
    end
end

function DFunctions.GetEventNPC()
    for i,v in pairs(Workspace.Game.Players:GetChildren()) do
        if v.Name == "Lupen" and v:FindFirstChild("HumanoidRootPart") then
            return v
        end
    end
end

function DFunctions.TPEventNPC()
    local npc = DFunctions.GetEventNPC()
    
    DConfiguration.AutoFarm.FarmingStates.IsCatchingNPC = false
    if npc and npc:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHrp = npc:FindFirstChild("HumanoidRootPart") 
        local targetHum = npc:FindFirstChild("Humanoid") 

        if hrp and targetHrp then
            hrp.CFrame = CFrame.new(targetHrp.Position + targetHum.MoveDirection)
            DConfiguration.AutoFarm.FarmingStates.IsCatchingNPC = true
        end
    end
end

function DFunctions.GetObjective()
    local ObjectiveFolder = Workspace.Game.Map.Parts:FindFirstChild("Objectives")
    if not ObjectiveFolder then return nil end

    local Parts = {}

    for _, v in ipairs(ObjectiveFolder:GetChildren()) do
        if v:IsA("Model") then
            local part = v:FindFirstChildWhichIsA("BasePart")
            if part then
                table.insert(Parts, part)
            end
        end
    end

    if #Parts == 0 then
        return nil
    end

    return Parts[math.random(1, #Parts)]
end

local FarmPart

function DFunctions.AFKFarming()
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if not FarmPart then
        FarmPart = Instance.new("Part")
        FarmPart.Size = Vector3.new(10, 1, 10)
        FarmPart.Anchored = true
        FarmPart.CanCollide = true
        FarmPart.Name = "AFKFarmPad"
        FarmPart.CFrame = CFrame.new(0, hrp.Position.Y + 10000, 0)
        FarmPart.Parent = workspace
    end

    hrp.CFrame = FarmPart.CFrame + Vector3.new(0, 3, 0)
end

function DFunctions.RevivePlayer()
    local downedplr = DFunctions.GetDownedPlayer()
    
    DConfiguration.AutoFarm.FarmingStates.IsReviving = false
    if downedplr and downedplr:FindFirstChild("HumanoidRootPart") then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local targetHrp = downedplr:FindFirstChild("HumanoidRootPart")

        if hrp and targetHrp then
            hrp.CFrame = CFrame.new(targetHrp.Position + Vector3.new(0, 2, 0))

            local Interact = ReplicatedStorage.Events.Character.Interact
            Interact:FireServer("Revive", true, tostring(downedplr))
            Interact:FireServer("Revive", true, tostring(downedplr))
            Interact:FireServer("Revive", true, tostring(downedplr))
            DConfiguration.AutoFarm.FarmingStates.IsReviving = true
        end
    end
    
    if not DConfiguration.AutoFarm.FarmingStates.IsReviving then
        DFunctions.AFKFarming()
    end 
end

function DFunctions.PointFarming()
    local Objective = DFunctions.GetObjective()
    
    DConfiguration.AutoFarm.FarmingStates.IsCompletingObjective = false
    if Objective then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        if hrp then
            hrp.CFrame = CFrame.new(Objective.Position)
            LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({Down = true, Key = "Interact"})
            DConfiguration.AutoFarm.FarmingStates.IsCompletingObjective = true
        end
    end
end

function DFunctions.TicketsFarming()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    DConfiguration.AutoFarm.FarmingStates.IsCollectingTickets = false

    for _, v in ipairs(Workspace.Game.Effects.Tickets:GetDescendants()) do
        if v:IsA("BasePart") and v.Name == "HumanoidRootPart" then
            hrp.CFrame = CFrame.new(v.Position)
            DConfiguration.AutoFarm.FarmingStates.IsCollectingTickets = true
            return
        end
    end
    
    DFunctions.AFKFarming()
end

function DFunctions.AutoVote(section1, section2)
	if section1 then
	    ReplicatedStorage.Events.Player.Vote:FireServer(section1)
	end
	
	if section2 then
	    ReplicatedStorage.Events.Player.Vote:FireServer(section1, true)
	end
end

function DFunctions.SetVIPCommands(map, specialround, timer)
    local VIPCommand = ReplicatedStorage.Events.Admin.VIPCommand

    if typeof(map) == "string" and map ~= "" then
        VIPCommand:InvokeServer("!map " .. map)
    end

    if typeof(specialround) == "string" and specialround ~= "" then
        VIPCommand:InvokeServer("!specialround " .. specialround)
    end
    
    if typeof(timer) == "string" and specialround ~= "" then
        VIPCommand:InvokeServer("!timer " .. timer)
    end
end

function DFunctions.BuyItem(Name, Type)
	local Purchase = ReplicatedStorage.Events.Data.Purchase
	local Folder = ReplicatedStorage.Items[Type][Name]
	local ID = Folder:GetAttribute("ID")
	
	Purchase:InvokeServer(ID)
end

local EmoteNames = {}
local LoadoutNames = {}

function DFunctions.GetEmotesName()
    EmoteNames = {}
    local emotesFolder = game:GetService("ReplicatedStorage").Items.Emotes

    for _, thing in ipairs(emotesFolder:GetChildren()) do
        if thing:IsA("LocalScript") or thing:IsA("ModuleScript") then
            EmoteNames[#EmoteNames + 1] = thing.Name 
        end
        if _ % 50 == 0 then
            task.wait(3)
        end
    end

    return EmoteNames
end

function DFunctions.GetLoadoutName()
    LoadoutNames = {}
    local loadoutFolder = game:GetService("ReplicatedStorage").Items.Loadout

    for _, thing in ipairs(loadoutFolder:GetChildren()) do
        if thing:IsA("LocalScript") or thing:IsA("ModuleScript") then
            LoadoutNames[#LoadoutNames + 1] = thing.Name 
        end
        if _ % 50 == 0 then
            task.wait(3)
        end
    end

    return LoadoutNames
end

DFunctions.GetEmotesName()
DFunctions.GetLoadoutName()

-- Nextbots logic

function DFunctions.AntiNextbot()
    if Workspace:FindFirstChild("Game") and game.Workspace.Game:FindFirstChild("Players") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
    
        local playerTeam = Workspace.Game.Players[LocalPlayer.Name]:GetAttribute("Team")
        if playerTeam == "Nextbot" then
            return 
        end
    
        for i, v in pairs(Workspace.Game.Players:GetDescendants()) do
            if v:IsA("Model") and v:GetAttribute("Team") == "Nextbot" then
                local humanoidRootPart = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("HRP")
                if humanoidRootPart then
                    if not LocalPlayer.Character and not LocalPlayer.Character.HumanoidRootPart then 
                        return
                    end
                    
                    local distance = (LocalPlayer.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
                    
                    if distance < DConfiguration.Nextbots.AntiNextbotRange then
                        if DConfiguration.Nextbots.AntiNextbotType == "Spawn" then
                            local parts = workspace.Game.Map.ItemSpawns:GetChildren()
                            local randomPart = parts[math.random(1, #parts)]
                            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(randomPart.Position)
                        elseif DConfiguration.Nextbots.AntiNextbotType == "Players" then
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

-- Misc logic

local CurrentAdjustment = {}

function DFunctions.GetAdjustments()
	table.clear(CurrentAdjustment)
	local character = LocalPlayer.Character
	if not character then
		return
	end

	for _, v in pairs(getgc(true)) do
		if type(v) == "table" then
			local char = rawget(v, "Character")
			local stats = rawget(v, "overrideMovementStats")
			local stats2 = rawget(v, "defaultMovementStats")

			if typeof(char) == "Instance" and char == character then
				if type(stats) == "table" then
					table.insert(CurrentAdjustment, stats)
				end
				if type(stats2) == "table" then
					table.insert(CurrentAdjustment, stats2)
				end
			end
		end
	end
end

function DFunctions.setTSpeed(newSpeed)
    local now = tick()
    if DConfiguration.Misc.PlayerAdjustment.Default.Speed ~= newSpeed and now - DConfiguration.Misc.PlayerAdjustment.Tick.Speed >= 0.1 then
        DConfiguration.Misc.PlayerAdjustment.Default.Speed = newSpeed
        DConfiguration.Misc.PlayerAdjustment.Tick.Speed = now

        for i = 1, #CurrentAdjustment do
            local stats = CurrentAdjustment[i]
            if rawget(stats, "Speed") then
                rawset(stats, "Speed", newSpeed)
            end
        end
    end
end

function DFunctions.setTJump(newJump)
    local now = tick()
    if DConfiguration.Misc.PlayerAdjustment.Default.JumpHeight ~= newJump and now - DConfiguration.Misc.PlayerAdjustment.Tick.JumpHeight >= 0.1 then
        DConfiguration.Misc.PlayerAdjustment.Default.JumpHeight = newJump
        DConfiguration.Misc.PlayerAdjustment.Tick.JumpHeight = now

        for i = 1, #CurrentAdjustment do
            local stats = CurrentAdjustment[i]
            if rawget(stats, "JumpHeight") then
                rawset(stats, "JumpHeight", newJump)
            end
        end
    end
end

function DFunctions.setTJumpCap(newJumpCap)
    local now = tick()
    if DConfiguration.Misc.PlayerAdjustment.Default.JumpCap ~= newJumpCap and now - DConfiguration.Misc.PlayerAdjustment.Tick.JumpCap >= 0.1 then
        DConfiguration.Misc.PlayerAdjustment.Default.JumpCap = newJumpCap
        DConfiguration.Misc.PlayerAdjustment.Tick.JumpCap = now

        for i = 1, #CurrentAdjustment do
            local stats = CurrentAdjustment[i]
            if rawget(stats, "JumpCap") then
                rawset(stats, "JumpCap", newJumpCap)
            end
        end
    end
end

function DFunctions.setTJumpAcceleration(newJumpAcce)
    local now = tick()
    if DConfiguration.Misc.PlayerAdjustment.Default.JumpAcceleration ~= newJumpAcce and now - DConfiguration.Misc.PlayerAdjustment.Tick.JumpAcceleration >= 0.1 then
        DConfiguration.Misc.PlayerAdjustment.Default.JumpAcceleration = newJumpAcce
        DConfiguration.Misc.PlayerAdjustment.Tick.JumpAcceleration = now

        for i = 1, #CurrentAdjustment do
            local stats = CurrentAdjustment[i]
            if rawget(stats, "JumpSpeedMultiplier") then
                rawset(stats, "JumpSpeedMultiplier", newJumpAcce)
            end
        end
    end
end

function DFunctions.setTFriction(newFriction)
    local now = tick()
    if DConfiguration.Misc.PlayerAdjustment.Default.GroundAcceleration ~= newFriction and now - DConfiguration.Misc.PlayerAdjustment.Tick.GroundAcceleration >= 0.1 then
        DConfiguration.Misc.PlayerAdjustment.Default.GroundAcceleration = newFriction
        DConfiguration.Misc.PlayerAdjustment.Tick.GroundAcceleration = now

        for i = 1, #CurrentAdjustment do
            local stats = CurrentAdjustment[i]
            if rawget(stats, "Friction") then
                rawset(stats, "Friction", newFriction)
            end
        end
    end
end

function DFunctions.setBhopEnabled(bool)  
    for i = 1, #CurrentAdjustment do  
        local stats = CurrentAdjustment[i]  
        if rawget(stats, "BhopEnabled") ~= nil then  
            stats.BhopEnabled = bool
        end  
    end  
end  

function DFunctions.setStrafeAcceleration(newAcceleration)
    local now = tick()
    if DConfiguration.Misc.PlayerAdjustment.Default.AirStrafe ~= newAcceleration and now - DConfiguration.Misc.PlayerAdjustment.Tick.AirStrafe >= 0.1 then
        DConfiguration.Misc.PlayerAdjustment.Default.AirStrafe = newAcceleration
        DConfiguration.Misc.PlayerAdjustment.Tick.AirStrafe = now

        for i = 1, #CurrentAdjustment do
            local stats = CurrentAdjustment[i]
            if rawget(stats, "AirStrafeAcceleration") then
                rawset(stats, "AirStrafeAcceleration", newAcceleration)
            end
            if rawget(stats, "AirAcceleration") then
                rawset(stats, "AirAcceleration", 3)
            end
        end
    end
end

function DFunctions.SetPreviousAdjustment()
    for i = 1, #CurrentAdjustment do
        local stats = CurrentAdjustment[i]

        if rawget(stats, "Speed") then
            rawset(stats, "Speed", DConfiguration.Misc.PlayerAdjustment.Default.Speed)
        end
        if rawget(stats, "JumpHeight") then
            rawset(stats, "JumpHeight", DConfiguration.Misc.PlayerAdjustment.Default.JumpHeight)
        end
        if rawget(stats, "JumpCap") then
            rawset(stats, "JumpCap", DConfiguration.Misc.PlayerAdjustment.Default.JumpCap)
        end
        if rawget(stats, "JumpSpeedMultiplier") then
            rawset(stats, "JumpSpeedMultiplier", DConfiguration.Misc.PlayerAdjustment.Default.JumpAcceleration)
        end
        if rawget(stats, "AirStrafeAcceleration") then
            rawset(stats, "AirStrafeAcceleration", DConfiguration.Misc.PlayerAdjustment.Default.AirStrafe)
        end
        if rawget(stats, "AirAcceleration") then
            rawset(stats, "AirAcceleration", 3)
        end
    end
end

function DFunctions.GetSpeedometer()
    local shared = LocalPlayer.PlayerGui:WaitForChild("Shared", 9e9)
    if not shared then return end
    local speedometer = shared.HUD.Overlay.Default.CharacterInfo.Item:WaitForChild("Speedometer", 9e9)
    if not speedometer then return end
    local player = speedometer.Players
    
    return player
end

function DFunctions.BounceFunction()
    local speedometer = DFunctions.GetSpeedometer()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = char and char:FindFirstChild("Humanoid")

    if speedometer then
        DConfiguration.Misc.Utilities.GetCurrentSpeed = tonumber(speedometer.Text)
    end

    if not DConfiguration.Misc.Utilities.BounceModification.Enabled and humanoid then
        humanoid.WalkSpeed = 0
        return
    end
     
    if char and humanoid then
        if char:GetAttribute("State") == "Default" or char:GetAttribute("State") == "Downed" or not DConfiguration.Misc.Utilities.BounceModification.Enabled then
            humanoid.WalkSpeed = 0
        elseif char:GetAttribute("State") == "Emoting" or char:GetAttribute("State") == "EmotingAir" or char:GetAttribute("State") == "EmotingSlide" or char:GetAttribute("State") == "EmotingSlideAir" then
            humanoid.WalkSpeed = DConfiguration.Misc.Utilities.BounceModification.EmoteBounce + DConfiguration.Misc.Utilities.GetCurrentSpeed
        elseif DConfiguration.Misc.Utilities.GetCurrentSpeed < 15 or char:GetAttribute("State") == "Default" then
            humanoid.WalkSpeed = 0
        else
            humanoid.WalkSpeed = DConfiguration.Misc.Utilities.BounceModification.DefaultBounce + DConfiguration.Misc.Utilities.GetCurrentSpeed
        end
    end
end

function DFunctions.SuperBounce()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local HumanoidRootPart = char:FindFirstChild("HumanoidRootPart")
    local Humanoid = char:FindFirstChild("Humanoid")
    local PreviousHipHeight = 0
    
    if char:FindFirstChild("R15Visual") then
        PreviousHipHeight = 0.75
    else
	    PreviousHipHeight = -1.25
    end
   
    if not HumanoidRootPart or not Humanoid then return end
    
    HumanoidRootPart.CanCollide = false
    Humanoid.HipHeight = -100
    wait(2)
    HumanoidRootPart.CanCollide = true
    Humanoid.HipHeight = PreviousHipHeight
end

local CachedRayParams = RaycastParams.new()
CachedRayParams.FilterType = Enum.RaycastFilterType.Exclude

function DFunctions.StartLag(ms)
	local LagTime = ms * 0.002
	local LagType = DConfiguration.Misc.Utilities.LagSwitch.Mode
	local Character = LocalPlayer.Character
	if not Character then return end

	local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
	if not HumanoidRootPart then return end

	local StoredVelocity = HumanoidRootPart.AssemblyLinearVelocity
	if StoredVelocity.Magnitude < 1 then return end

	local start = tick()
	while tick() - start < LagTime do end
	
	if LagType == "FastFlag" or LagTime < 0.2 then
	   setfflag("MaxMissedWorldStepsRemembered", "9999")
	   return
	end
	
	if LagType ~= "Demon" or LagTime < 0.2 then return end
	
	CachedRayParams.FilterDescendantsInstances = {Character}

	local Multiplier = math.random(2, 10)
	local HorizontalVelocity = Vector3.new(StoredVelocity.X, 0, StoredVelocity.Z)
	local direction = HorizontalVelocity.Magnitude > 0 and HorizontalVelocity.Unit or HumanoidRootPart.CFrame.LookVector
	local distance = math.min(HorizontalVelocity.Magnitude * LagTime * Multiplier, 30)
	local forwardPos = HumanoidRootPart.Position + direction * distance
	local targetPos = forwardPos

	local forwardResult = workspace:Raycast(HumanoidRootPart.Position, forwardPos - HumanoidRootPart.Position, CachedRayParams)
	if forwardResult then
		targetPos = forwardResult.Position - direction * 2
	end

	local function detectSlope(dir, dist)
		return workspace:Raycast(HumanoidRootPart.Position + dir * dist, Vector3.new(0, -60, 0), CachedRayParams)
	end

	local LongSlopeCheck = detectSlope(direction, 50)
	local ShortSlopeCheck = nil

	for i = 2, 20, 2 do
		local result = detectSlope(direction, i)
		if result then
			ShortSlopeCheck = result
			break
		end
	end

	local SlopeLengthBoost, shortSlopeBoost = 1, 1
	local SlopeDirBoost = 1
	local HoverBuffer = 0
	local SlopeAngle = 0
	local EarlyBounce = false

	if LongSlopeCheck then
		local normal = LongSlopeCheck.Normal
		SlopeAngle = math.deg(math.acos(normal:Dot(Vector3.new(0, 1, 0))))
		if SlopeAngle >= 20 and SlopeAngle <= 80 then
			SlopeLengthBoost = math.clamp(SlopeAngle / 25, 1, 2.2)
			SlopeDirBoost = math.clamp(SlopeAngle / 40, 1, 2)
			HoverBuffer = math.clamp((SlopeAngle - 20) * 0.06, 0, 3)
			if SlopeAngle < 35 then
				targetPos = targetPos + Vector3.new(0, 3, 0) + direction * (2 * SlopeDirBoost)
			else
				targetPos = targetPos + Vector3.new(0, SlopeAngle * 0.3 + HoverBuffer, 0)
			end
		end
	end

	if ShortSlopeCheck then
		local normal = ShortSlopeCheck.Normal
		SlopeAngle = math.deg(math.acos(normal:Dot(Vector3.new(0, 1, 0))))
		if SlopeAngle >= 20 and SlopeAngle <= 80 then
			ShortSlopeBoost = math.clamp(SlopeAngle / 22, 1, 2.5)
			SlopeDirBoost = SlopeDirBoost + math.clamp(SlopeAngle / 50, 0, 1.6)
			HoverBuffer = HoverBuffer + math.clamp((SlopeAngle - 20) * 0.05, 0, 3)
			local verticalDist = HumanoidRootPart.Position.Y - ShortSlopeCheck.Position.Y
			local minForward = 4
			local minUp = 4
			if SlopeAngle >= 50 and verticalDist < 3 then
				earlyBounce = true
				targetPos = targetPos + direction * minForward + Vector3.new(0, minUp, 0)
			else
				if SlopeAngle < 35 then
					targetPos = targetPos + Vector3.new(0, 3, 0) + direction * (2 * SlopeDirBoost)
				else
					targetPos = targetPos + Vector3.new(0, SlopeAngle * 0.4 + HoverBuffer, 0)
				end
			end
		end
	end

	if SlopeAngle >= 35 then
		targetPos = targetPos + direction * (5 * SlopeDirBoost)
	end

	local safetyCheck = workspace:Raycast(HumanoidRootPart.Position, targetPos - HumanoidRootPart.Position, CachedRayParams)
	if safetyCheck then
		targetPos = safetyCheck.Position + Vector3.new(0, 2, 0) - direction * 2
	end

	if ShortSlopeCheck or LongSlopeCheck then
		local hitPos = (ShortSlopeCheck or LongSlopeCheck).Position
		local verticalDist = HumanoidRootPart.Position.Y - hitPos.Y
		if verticalDist < 2 then
			targetPos = HumanoidRootPart.Position + direction * 2 + Vector3.new(0, 2, 0)
		end
	end

	HumanoidRootPart.CFrame = CFrame.new(targetPos, targetPos + HumanoidRootPart.CFrame.LookVector)

	local Delta = targetPos - HumanoidRootPart.Position
	local Speed = StoredVelocity.Magnitude
	local forwardBoost = math.clamp(Speed * 0.4, 5, 20)
	local safeDir = Delta.Magnitude > 0 and Delta.Unit or direction
	local safeCheck = workspace:Raycast(HumanoidRootPart.Position, safeDir * forwardBoost, CachedRayParams)

	if not safeCheck then
		HumanoidRootPart.AssemblyLinearVelocity += safeDir * forwardBoost
	else
		local safeDist = (safeCheck.Position - HumanoidRootPart.Position).Magnitude
		if safeDist > 3 then
			HumanoidRootPart.AssemblyLinearVelocity += safeDir * (safeDist * 0.6)
		end
	end

	local bounceMultiplier = 1.2
	if SlopeAngle >= 45 then
		local angleBoost = math.clamp((SlopeAngle - 45) / 20, 0, 1.5)
		bounceMultiplier = 1.2 + angleBoost
	end

	if StoredVelocity.Y < -60 then
		bounceMultiplier *= 0.9 * SlopeLengthBoost * ShortSlopeBoost
	elseif StoredVelocity.Y < -30 then
		bounceMultiplier *= 1.0 * SlopeLengthBoost * ShortSlopeBoost
	end

	if StoredVelocity.Y < -10 then
		local angleFactor = math.clamp((SlopeAngle - 20) / 40, 0, 1)
		local bounceY = math.abs(StoredVelocity.Y) * (1.1 + angleFactor * 0.9)
		bounceY = bounceY + StoredVelocity.Magnitude * (0.3 + angleFactor * 0.5)
		bounceY = math.clamp(bounceY * bounceMultiplier * 1.0, 0, 60 + StoredVelocity.Magnitude * 0.4)

		HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(
			StoredVelocity.X * SlopeDirBoost,
			bounceY,
			StoredVelocity.Z * SlopeDirBoost
		)

		if earlyBounce then
			local forwardBoost = math.clamp(5 + StoredVelocity.Magnitude * 0.1, 6, 20)
			local forwardCheck = workspace:Raycast(HumanoidRootPart.Position, direction * forwardBoost, CachedRayParams)
			if not forwardCheck then
				hrp.CFrame = HumanoidRootPart.CFrame + direction * forwardBoost
			else
				local safeDist = (forwardCheck.Position - HumanoidRootPart.Position).Magnitude
				if safeDist > 3 then
					HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + direction * (safeDist * 0.5)
				end
			end
		end
	end
	
	HumanoidRootPart.Size = Vector3.new(3, 25, 3)
	wait(0.1)
	HumanoidRootPart.Size = Vector3.new(2, 4, 2)
end

local EdgeParams = RaycastParams.new()
EdgeParams.FilterType = Enum.RaycastFilterType.Blacklist
EdgeParams.FilterDescendantsInstances = {}

function DFunctions.ModifyEdgeTrimp()
    local Character = LocalPlayer.Character
    if not Character then return end

    local Root = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Root or not Humanoid then return end

    local Velocity = Root.AssemblyLinearVelocity
    local HorizontalVel = Vector3.new(Velocity.X, 0, Velocity.Z)
    local Speed = HorizontalVel.Magnitude
    if Speed < 22 then return end

    local MoveDir = HorizontalVel.Unit
    local LookDir = Root.CFrame.LookVector.Unit

    EdgeParams.FilterDescendantsInstances = {Character}

    local PredictTime = math.clamp(Speed / 110, 0.14, 0.24)
    local EarlyOffset = 2.5

    local FutureMovePos = Root.Position + HorizontalVel * PredictTime + MoveDir * EarlyOffset
    local FutureLookPos = Root.Position + HorizontalVel * PredictTime + LookDir * EarlyOffset

    if Velocity.Y > 5 then return end

    local validEdge = false
    local minRaysForTrigger = 2
    local maxSlope = 0.8
    local minHeightDiff = 1.5

    local fanOffsets = {
        Vector3.new(0,0,0),
        Vector3.new(0.25,0,0.25),
        Vector3.new(-0.25,0,-0.25),
        Vector3.new(0.25,0,-0.25),
        Vector3.new(-0.25,0,0.25)
    }

    local moveHits = 0
    local lookHits = 0

    for _, offset in ipairs(fanOffsets) do
        local startMove = FutureMovePos + offset
        local forwardHitMove = workspace:Raycast(startMove + Vector3.new(0,2,0), MoveDir * 3.5, EdgeParams)

        if forwardHitMove and forwardHitMove.Normal.Y < 0.2 then
            local topCheckMove = workspace:Raycast(
                forwardHitMove.Position + Vector3.new(0,2.2,0),
                Vector3.new(0,-5,0),
                EdgeParams
            )

            if topCheckMove and topCheckMove.Normal.Y >= maxSlope then
                if topCheckMove.Position.Y - Root.Position.Y > minHeightDiff then
                    moveHits += 1
                end
            end
        end

        local startLook = FutureLookPos + offset
        local forwardHitLook = workspace:Raycast(startLook + Vector3.new(0,2,0), LookDir * 3.5, EdgeParams)

        if forwardHitLook and forwardHitLook.Normal.Y < 0.2 then
            local topCheckLook = workspace:Raycast(
                forwardHitLook.Position + Vector3.new(0,2.2,0),
                Vector3.new(0,-5,0),
                EdgeParams
            )

            if topCheckLook and topCheckLook.Normal.Y >= maxSlope then
                if topCheckLook.Position.Y - Root.Position.Y > minHeightDiff then
                    lookHits += 1
                end
            end
        end
    end

    if moveHits >= 1 and lookHits >= 1 then
        validEdge = true
    end

    local downVotes = 0
    local earlyForward = MoveDir * 2
    local dropThreshold = DConfiguration.Misc.Utilities.EdgeTrimpModification.DownThreshold
    local halfDepth = Root.Size.Z / 2
    local forwardDistances = {
	    halfDepth + 0.1,
	    halfDepth + 0.4,
	    halfDepth + 0.7,
	    halfDepth + 1
    }

    for _, offset in ipairs(fanOffsets) do
        local startPos = FutureMovePos + offset + earlyForward

        local downHit = workspace:Raycast(
            startPos + Vector3.new(0,2,0),
            Vector3.new(0,-6,0),
            EdgeParams
        )

        if downHit then
            local drop = Root.Position.Y - downHit.Position.Y

            local edgeFound = false

            for _, dist in ipairs(forwardDistances) do
                local check = workspace:Raycast(
                    Root.Position + MoveDir * dist,
                    Vector3.new(0,-6,0),
                    EdgeParams
                )

                if not check then
                    edgeFound = true
                    break
                end
            end

            if drop >= dropThreshold and edgeFound then
                downVotes += 1
            end
        end
    end

    if downVotes >= minRaysForTrigger then
        validEdge = true
    end

    if not validEdge then return end

    Root.AssemblyLinearVelocity =
        HorizontalVel * 1.05 +
        Vector3.new(0, math.clamp(Speed * 0.7, 22, 85), 0) *
        DConfiguration.Misc.Utilities.EdgeTrimpModification.HeightMultiplier
end

local WorkspacePlayers = game:GetService("Workspace").Game.Players

function DFunctions.getNearestDownedPlayer()
    local nearestPlayer = nil
    local nearestDistance = 10
    local HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return nil end

    for _, v in pairs(WorkspacePlayers:GetChildren()) do
        local targetRoot = v:FindFirstChild("HumanoidRootPart")
        if v:GetAttribute("Downed") and targetRoot and not targetRoot.Anchored then
            local distance = (HumanoidRootPart.Position - targetRoot.Position).Magnitude
            if distance < nearestDistance then
                nearestDistance = distance
                nearestPlayer = v
            end
        end
    end

    return nearestPlayer
end

function DFunctions.InstantRevive()
    local nearestPlayer = DFunctions.getNearestDownedPlayer()
    if not nearestPlayer then return end

    local State = LocalPlayer.Character:GetAttribute("State")
    local AllowWhileEmote = DConfiguration.Misc.GameAutomation.Revive.WhileEmote or (State == "Run" or State == "Air" or State == "Slide" or State == "Fall" or State == "Jump" or State == "Crouch")

    if AllowWhileEmote then
        for i = 1, 7 do
            ReplicatedStorage.Events.Character.Interact:FireServer("Revive", nil, tostring(nearestPlayer))
            ReplicatedStorage.Events.Character.Interact:FireServer("Revive", false, tostring(nearestPlayer))
            ReplicatedStorage.Events.Character.Interact:FireServer("Revive", true, tostring(nearestPlayer))
        end
    end
end

function DFunctions.CarryPlayer()
    local nearestPlayer = DFunctions.getNearestDownedPlayer()
    if not nearestPlayer then return end

    local State = LocalPlayer.Character:GetAttribute("State")
    local AllowWhileEmote = DConfiguration.Misc.GameAutomation.Revive.WhileEmote or (State == "Run" or State == "Air" or State == "Slide" or State == "Fall" or State == "Jump" or State == "Crouch")

    if AllowWhileEmote then
        for i = 1, 7 do
            ReplicatedStorage.Events.Character.Interact:FireServer("Carry", nil, tostring(nearestPlayer))
            ReplicatedStorage.Events.Character.Interact:FireServer("Carry", false, tostring(nearestPlayer))
            ReplicatedStorage.Events.Character.Interact:FireServer("Carry", true, tostring(nearestPlayer))
        end
    end
end

function DFunctions.AggressiveEmoteDashFunction()
	local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local Type = DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Type
	
	if Type == "Legit" and (Character and Character:GetAttribute("State") == "EmotingSlide") then
	    DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Acceleration
    else
        if DConfiguration.Misc.MovementModification.BHOP.Enabled then return end
		DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = DConfiguration.Misc.PlayerAdjustment.Default.GroundAcceleration
	end
	
	if Type == "Blatant" and (Character and Character:GetAttribute("State") == "Emoting" or Character:GetAttribute("State") == "EmotingAir" or Character:GetAttribute("State") == "EmotingSlide" or Character:GetAttribute("State") == "EmotingSlideAir") then
		DConfiguration.Misc.PlayerAdjustment.Update.Speed = DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Speed
	else
	    DConfiguration.Misc.PlayerAdjustment.Update.Speed = DConfiguration.Misc.PlayerAdjustment.Saved.Speed
	end
end

function DFunctions.SetToMovableEmote(EmoteName, Speed)
	local EmoteFolder = ReplicatedStorage.Items.Emotes
	local EmoteInfo = require(EmoteFolder[EmoteName]).EmoteInfo
	EmoteInfo.SpeedMult = Speed
end

function DFunctions.InfiniteSlideFunction()
	local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	
	if Character and Character:GetAttribute("State") == "Slide" or Character:GetAttribute("State") == "EmotingSlide" then
		DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = DConfiguration.Misc.MovementModification.SlideModification.Acceleration
	else
		DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = 5
	end
end

local isHolding = false


function DFunctions.BHOPFunction()
    local speedometer = DFunctions.GetSpeedometer()
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local Humanoidrootpart = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local BHOPConfig = DConfiguration.Misc.MovementModification.BHOP
    local Settings = BHOPConfig.Settings
    local debounce
    
    if not Character then return end
    if not Humanoidrootpart then return end
    if not Humanoid then return end
    
    if BHOPConfig.Settings.SpiderHop and Character and Character:GetAttribute("State") == "Wallrunning" then
        LocalPlayer.PlayerScripts.Events.temporary_events.EndJump:Fire()
        LocalPlayer.PlayerScripts.Events.temporary_events.JumpReact:Fire()
    end
    
    if Settings.Type == "Acceleration" then
        if tonumber(speedometer.Text) > 60 then
            if Character:FindFirstChild("R15Visual") then
                BHOPConfig.HipHeight2 = 1
            else
                BHOPConfig.HipHeight2 = -1.05
            end
        else
            if Character:FindFirstChild("R15Visual") then
                BHOPConfig.HipHeight2 = 0.9
            else
                BHOPConfig.HipHeight2 = -1.10
            end
        end
        
        debounce = 0.01
        Humanoid.HipHeight = BHOPConfig.HipHeight2
    elseif Settings.Type == "Ground Acceleration" then
        if Character:FindFirstChild("R15Visual") then
           BHOPConfig.HipHeight2 = 0.5
        else
           BHOPConfig.HipHeight2 = -2
        end
        
        Humanoid.HipHeight = BHOPConfig.HipHeight2
        debounce = 0.01      
    elseif Settings.Type == "No Acceleration" then
        debounce = 0.125
    end
    
    local CanBHOPBackwards = true
    
    if Settings.AutoAcceleration.Enabled then
        local Speed = tonumber(speedometer.Text)
        local MaxAccel = Settings.AutoAcceleration.MaxAccelerate
        local MinAccel = Settings.AutoAcceleration.MinAccelerate
        if MinAccel > MaxAccel then
            MinAccel, MaxAccel = MaxAccel, MinAccel
        end
        local MinSpeed = Settings.AutoAcceleration.MinSpeed
        local Threshold = math.clamp(Speed, 25, 50)
        local Devisor = math.clamp(Speed / Threshold, 0, 6) 
        local Decrease = math.clamp(5 - (Devisor * 1.7), MinAccel, MaxAccel)
        
        if Settings.Type == "No Acceleration" then
           return
        end
        
        if Speed < MinSpeed then
            DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = MinAccel
            CanBHOPBackwards = true
        else 
            DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = Decrease
            CanBHOPBackwards = false
        end
    else
        if Settings.Type == "No Acceleration" then
           return
        end
        
        DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = Settings.Acceleration
    end
    
    local now = tick()
    local lastGrounded = 0

    if Humanoid.FloorMaterial ~= Enum.Material.Air then
        lastGrounded = now
    end

    local grounded = (now - lastGrounded) < 0.06
    
    if Settings.JumpType == "Simulated" then
        if grounded and (now - BHOPConfig.lastTick) > debounce then
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            BHOPConfig.lastTick = now
        end
    elseif Settings.JumpType == "Realistic" then
        if grounded and (now - BHOPConfig.lastTick) > debounce then
            LocalPlayer.PlayerScripts.Events.temporary_events.EndJump:Fire()
            LocalPlayer.PlayerScripts.Events.temporary_events.JumpReact:Fire()
            BHOPConfig.lastTick = now
        end
    end
    
    if BHOPConfig.Settings.Backwards then
	    local LookVector = Humanoidrootpart.CFrame.LookVector
        local Velocity = Humanoidrootpart.AssemblyLinearVelocity
        local MoveDir = Humanoid.MoveDirection

        local HorizontalVelocity = Vector3.new(Velocity.X, 0, Velocity.Z)
        local Speed = HorizontalVelocity.Magnitude
        
        local VelocityBackwards = false
        local InputBackwards = false

        if Speed > 1 then
            VelocityBackwards = (LookVector:Dot(HorizontalVelocity.Unit) < -0.3)
        end

        if MoveDir.Magnitude > 0 then
            InputBackwards = (LookVector:Dot(MoveDir) < -0.3)
        end

        if VelocityBackwards or InputBackwards then
            DFunctions.setBhopEnabled(CanBHOPBackwards)
            RunService.Heartbeat:Wait()
            DFunctions.setBhopEnabled(false)
        end
    end
end

function DFunctions.ResetBHOP()
   local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
   local Humanoid = Character:FindFirstChildOfClass("Humanoid")
   local BHOPConfig = DConfiguration.Misc.MovementModification.BHOP
   
   if Character:FindFirstChild("R15Visual") then
       BHOPConfig.HipHeight1 = 0.75
       BHOPConfig.HipHeight2 = 0.9
   else
       BHOPConfig.HipHeight1 = -1.25
       BHOPConfig.HipHeight2 = -1.10
   end
           
   if Humanoid then
       Humanoid.HipHeight = BHOPConfig.HipHeight1
       DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = 5
       wait(0.3)
       DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = 5
       DFunctions.setBhopEnabled(false)
    end
end

function DFunctions.CrouchFunction()
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if not Character then return end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid or not HumanoidRootPart then return end

    local Config = DConfiguration.Misc.MovementModification.Crouch
    local Type = Config.Type or "Normal"
    local now = tick()

    if Type == "Rapid" then
        Config.isHolding = Config.isHolding or false
        Config.lastTick = Config.lastTick or 0

        if (now - Config.lastTick) >= Config.debounce then
            Config.isHolding = not Config.isHolding
            LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({
                Key = "Crouch",
                Down = Config.isHolding
            })
            Config.lastTick = now
        end
        return
    end

    local isOnGround = Humanoid.FloorMaterial ~= Enum.Material.Air

    if Type == "Air" then
        if Config.isHolding == nil then Config.isHolding = false end

        if not isOnGround then
            if not Config.isHolding then
                Config.isHolding = true
                LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({ Key = "Crouch", Down = true })
            end
        else
            if Config.isHolding then
                Config.isHolding = false
                LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({ Key = "Crouch", Down = false })
            end
        end
        return
    end

    local shouldHold = false

    if Type == "Ground" then
        if isOnGround then
            shouldHold = true
        end
    elseif Type == "Normal" then
        shouldHold = true
    end

    if Config.isHolding == nil then Config.isHolding = false end

    if shouldHold then
        if not Config.isHolding then
            Config.isHolding = true
            LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({ Key = "Crouch", Down = true })
        end
    else
        if Config.isHolding then
            Config.isHolding = false
            LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({ Key = "Crouch", Down = false })
        end
    end
end



local Folder = Instance.new("Folder", ReplicatedStorage.Items)
Folder.Name = "D-Folder"

function DFunctions.Normalize(input)
	return input:lower():gsub("%s+", "") 
end

function DFunctions.FindRealName(folder, userInput)
	local normalizedInput = DFunctions.Normalize(userInput)
	for _, item in ipairs(folder:GetChildren()) do
		if DFunctions.Normalize(item.Name) == normalizedInput then
			return item.Name
		end
	end
	return nil
end

function DFunctions.ChangeCosmetics(Name1, Name2)
	local Cosmetics = ReplicatedStorage.Items.Cosmetics
	local RealName1 = DFunctions.FindRealName(Cosmetics, Name1)
	local RealName2 = DFunctions.FindRealName(Cosmetics, Name2)
	if not (RealName1 and RealName2) then return end

	local I = Cosmetics:FindFirstChild(RealName1)
	local V = Cosmetics:FindFirstChild(RealName2)
	if not (I and V) then return end

	if I:FindFirstChild("OriginalName") or V:FindFirstChild("OriginalName") then
		return
	end

	local s1 = Instance.new("StringValue")
	s1.Name = "OriginalName"
	s1.Value = I.Name
	s1.Parent = I

	local s2 = Instance.new("StringValue")
	s2.Name = "OriginalName"
	s2.Value = V.Name
	s2.Parent = V

	for _, partName in ipairs({ "Character", "CharacterClassic", "Viewmodel" }) do
		local a = I:FindFirstChild(partName)
		local b = V:FindFirstChild(partName)

		if a and not a:FindFirstChild("OriginalParent") then
			local p = Instance.new("StringValue")
			p.Name = "OriginalParent"
			p.Value = I.Name
			p.Parent = a
		end

		if b and not b:FindFirstChild("OriginalParent") then
			local p = Instance.new("StringValue")
			p.Name = "OriginalParent"
			p.Value = V.Name
			p.Parent = b
		end

		if a then a.Parent = Folder end
		if b then b.Parent = I end
		if a then a.Parent = V end
	end
end

function DFunctions.RestoreCosmetics()
	local Cosmetics = ReplicatedStorage.Items.Cosmetics

	for _, cosmetic in ipairs(Cosmetics:GetChildren()) do
		for _, container in ipairs(cosmetic:GetChildren()) do
			local op = container:FindFirstChild("OriginalParent")
			if op then
				local original = Cosmetics:FindFirstChild(op.Value)
				if original then
					container.Parent = original
				end
				op:Destroy()
			end
		end
	end

	for _, container in ipairs(Folder:GetChildren()) do
		local op = container:FindFirstChild("OriginalParent")
		if op then
			local original = Cosmetics:FindFirstChild(op.Value)
			if original then
				container.Parent = original
			end
			op:Destroy()
		end
	end

	for _, cosmetic in ipairs(Cosmetics:GetChildren()) do
		local sv = cosmetic:FindFirstChild("OriginalName")
		if sv then
			sv:Destroy()
		end
	end
end

local SelectedVersion = "A"
local IsCurrentPlaying = false

function DFunctions.ChangeAnimation(EmoteFolder, Version)
	if not EmoteFolder then return end

	local options = EmoteFolder:FindFirstChild("PossibleOptions")
	local optionsClassic = EmoteFolder:FindFirstChild("PossibleOptionsClassic")
	if not options and not optionsClassic then return end

	local chosenR15 = options and options:FindFirstChild(Version)
	local chosenR6  = optionsClassic and optionsClassic:FindFirstChild(Version)

	local animR15 = chosenR15 and chosenR15:FindFirstChildWhichIsA("Animation")
	local animR6  = chosenR6 and chosenR6:FindFirstChildWhichIsA("Animation")

	if animR15 and EmoteFolder:FindFirstChild("Animation") then
		local tag = Instance.new("StringValue")
		tag.Name = "OriginalAnimId"
		tag.Value = EmoteFolder.Animation.AnimationId
		tag.Parent = EmoteFolder
		EmoteFolder.Animation.AnimationId = animR15.AnimationId
	end

	if animR6 and EmoteFolder:FindFirstChild("AnimationClassic") then
		local tag = Instance.new("StringValue")
		tag.Name = "OriginalAnimIdClassic"
		tag.Value = EmoteFolder.AnimationClassic.AnimationId
		tag.Parent = EmoteFolder
		EmoteFolder.AnimationClassic.AnimationId = animR6.AnimationId
	end
end

function DFunctions.ChangeEmotes(Name1, Name2)
	local EmotesFolder = ReplicatedStorage.Items.Emotes
	if not EmotesFolder then return end

	local RealName1 = DFunctions.FindRealName(EmotesFolder, Name1)
	local RealName2 = DFunctions.FindRealName(EmotesFolder, Name2)
	if not RealName1 or not RealName2 then return end
	if not IsCurrentPlaying then return end

	local Emote1 = EmotesFolder:FindFirstChild(RealName1)
	local Emote2 = EmotesFolder:FindFirstChild(RealName2)
	if not Emote1 or not Emote2 then return end

	if not Emote1:FindFirstChild("OriginalName") then
		local t = Instance.new("StringValue")
		t.Name = "OriginalName"
		t.Value = Emote1.Name
		t.Parent = Emote1
	end

	if not Emote2:FindFirstChild("OriginalName") then
		local t = Instance.new("StringValue")
		t.Name = "OriginalName"
		t.Value = Emote2.Name
		t.Parent = Emote2
	end

	if not Emote1:FindFirstChild("OriginalParent") then
		local t = Instance.new("StringValue")
		t.Name = "OriginalParent"
		t.Value = Emote1.Parent:GetFullName()
		t.Parent = Emote1
	end

	if not Emote2:FindFirstChild("OriginalParent") then
		local t = Instance.new("StringValue")
		t.Name = "OriginalParent"
		t.Value = Emote2.Parent:GetFullName()
		t.Parent = Emote2
	end

	local hasOptions = Emote2:FindFirstChild("PossibleOptions")
	local hasOptionsClassic = Emote2:FindFirstChild("PossibleOptionsClassic")

	if not hasOptions and not hasOptionsClassic or hasOptions:FindFirstChild("Sun") and hasOptions:FindFirstChild("Moon") then
		local n1, n2 = Emote1.Name, Emote2.Name
		Emote1.Name = n2
		Emote2.Name = n1
		return
	end

	local function MoveModule(obj, parentName)
		if obj and not obj:FindFirstChild("OriginalParent") then
			local t = Instance.new("StringValue")
			t.Name = "OriginalParent"
			t.Value = parentName
			t.Parent = obj
			obj.Parent = Folder
		end
	end

	MoveModule(Emote2:FindFirstChild("EmoteModule"), Emote2.Name)
	MoveModule(Emote2:FindFirstChild("EmoteModuleClassic"), Emote2.Name)

	if Emote1.Parent ~= Folder then
		Emote1.Parent = Folder
	end

	Emote2.Name = Emote1:FindFirstChild("OriginalName").Value

	DFunctions.ChangeAnimation(Emote2, SelectedVersion)
end

function DFunctions.ResetEmoteChanges()
	local Emotes = ReplicatedStorage.Items.Emotes

	for _, emote in ipairs(Emotes:GetChildren()) do
		local originalTag = emote:FindFirstChild("OriginalName")
		if originalTag then
			if emote.Name ~= originalTag.Value then
				emote.Name = originalTag.Value
			end
			originalTag:Destroy()
		end
	end

	for _, emote in ipairs(Folder:GetChildren()) do
		local ptag = emote:FindFirstChild("OriginalParent")
		if ptag then
			local parent = ReplicatedStorage.Items:FindFirstChild(ptag.Value)
			if parent then
				emote.Parent = parent
			else
				emote.Parent = Emotes
			end
			ptag:Destroy()
		end
	end
	
	for _, obj in ipairs(Folder:GetChildren()) do
		if obj:IsA("ModuleScript") then
			local originalParentTag = obj:FindFirstChild("OriginalParent")
			if originalParentTag then
				local parentEmote = Emotes:FindFirstChild(originalParentTag.Value)
				if parentEmote then
					obj.Parent = parentEmote
				else
					obj.Parent = Emotes
				end
				originalParentTag:Destroy()
			end
		end
	end
end

function DFunctions.RestoreEmoteChanges()
    DFunctions.ResetEmoteChanges() 
    wait(0.1)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote1, DConfiguration.Visual.ModifyEmotes.Emote1)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote2, DConfiguration.Visual.ModifyEmotes.Emote2)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote3, DConfiguration.Visual.ModifyEmotes.Emote3)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote4, DConfiguration.Visual.ModifyEmotes.Emote4)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote5, DConfiguration.Visual.ModifyEmotes.Emote5)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote6, DConfiguration.Visual.ModifyEmotes.Emote6)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote7, DConfiguration.Visual.ModifyEmotes.Emote7)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote8, DConfiguration.Visual.ModifyEmotes.Emote8)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote9, DConfiguration.Visual.ModifyEmotes.Emote9)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote10, DConfiguration.Visual.ModifyEmotes.Emote10)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote11, DConfiguration.Visual.ModifyEmotes.Emote11)
    DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote12, DConfiguration.Visual.ModifyEmotes.Emote12)
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer

DFunctions.KorbloxR = false
DFunctions.KorbloxL = false
DFunctions.Headless = false

function DFunctions.ApplyKorblox(side, meshId)
    local char = player.Character
    if not char then return end
    
    local legName = (side == "Right") 
        and (char:FindFirstChild("Right Leg") and "Right Leg" or "RightUpperLeg") 
        or (char:FindFirstChild("Left Leg") and "Left Leg" or "LeftUpperLeg")
        
    local leg = char:FindFirstChild(legName)
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

function DFunctions.ApplyHeadless()
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

function DFunctions.RevertChanges()
    local char = player.Character
    if not char then return end
    
    local head = char:FindFirstChild("Head")
    if head then
        head.Transparency = 0
        local mesh = head:FindFirstChild("HeadlessMesh")
        if mesh then mesh:Destroy() end
    end
    
    for _, legName in pairs({"Right Leg", "RightUpperLeg", "Left Leg", "LeftUpperLeg"}) do
        local leg = char:FindFirstChild(legName)
        if leg then
            leg.Color = Color3.new(1, 1, 1)
            local mesh = leg:FindFirstChild("KorbloxMesh")
            if mesh then mesh:Destroy() end
        end
    end
end

function DFunctions.UpdateVisuals()
    if DFunctions.KorbloxR then DFunctions.ApplyKorblox("Right", "rbxassetid://101851696") end
    if DFunctions.KorbloxL then DFunctions.ApplyKorblox("Left", "rbxassetid://101851582") end
    if DFunctions.Headless then DFunctions.ApplyHeadless() end
    
    if not DFunctions.KorbloxR and not DFunctions.KorbloxL and not DFunctions.Headless then
        DFunctions.RevertChanges()
    end
end

task.spawn(function()
    while true do
        DFunctions.UpdateVisuals()
        task.wait(0.1)
    end
end)

player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    DFunctions.RevertChanges()
end)

-- Main

local GamePlayers = workspace:WaitForChild("Game"):WaitForChild("Players")

Tabs.Main:AddSection("Billboard ESP")

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

local Toggle = Tabs.Main:AddToggle("BillboardTicket", {Title = "Billboard Tickets", Default = false })

    Toggle:OnChanged(function(State)
        DConfiguration.ESP.Tickets = State
        
        while DConfiguration.ESP.Tickets and wait(0.1) do
	        for _, v in pairs(Workspace.Game.Effects.Tickets:GetDescendants()) do
		        if v:IsA("BasePart") and v.Name == "HumanoidRootPart" then 
		            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()	
		            local ESPName = "TicketESP"
		            
		            if not char then
		               return
		            end
		            
		            if not v:FindFirstChild(ESPName) then
		               CreateBillboardESP(ESPName, v, Color3.fromRGB(255, 213, 128), 18)
		            end
		            
		            UpdateBillboardESP(ESPName, v, v.Parent.Name, Color3.fromRGB(255, 213, 128), 18, Camera.CFrame.Position)
		        end
	        end
        end
        
    if not DConfiguration.ESP.Tickets then
       for _, v in pairs(Workspace.Game.Effects.Tickets:GetDescendants()) do
      	 if v:IsA("BasePart") and v.Name == "HumanoidRootPart" then 
               DestroyBillboardESP("TicketESP", v)
             end
	  	end
  	end
 end)
 
Tabs.Main:AddSection("Tracer ESP")
 
local TracerLinesBots = {}
local TracerLines = {}
local TracerLinesTickets = {}

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

local Toggle = Tabs.Main:AddToggle("TracerTickets", {
    Title = "Tracer Tickets",
    Default = false
})

Toggle:OnChanged(function(State)
    DConfiguration.Tracers.Tickets = State

    if not DConfiguration.Tracers.Tickets then
        for part, _ in pairs(TracerLinesTickets) do
            if typeof(part) == "Instance" then
                DestroyTracerESP(TracerLinesTickets, part)
            else
                TracerLinesTickets[part] = nil
            end
        end
        TracerLinesTickets = {}
        return
    end

    task.spawn(function()
        while DConfiguration.Tracers.Tickets and task.wait() do
            if not DConfiguration.Tracers.Tickets then break end
            pcall(function()
                local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not localHRP then return end

                local ticketsFolder = workspace:FindFirstChild("Game") and workspace.Game.Effects:FindFirstChild("Tickets")
                if not ticketsFolder then return end

                for _, v in pairs(ticketsFolder:GetDescendants()) do
                    if v:IsA("BasePart") and v.Name == "HumanoidRootPart" then
                        if not TracerLinesTickets[v] then
                            CreateTracerESP(TracerLinesTickets, v, 2, Color3.fromRGB(255, 213, 128))
                        end
                        UpdateTracerESP(TracerLinesTickets, v, Color3.fromRGB(255, 213, 128))
                    end
                end

                for part, tracer in pairs(TracerLinesTickets) do
                    if typeof(part) ~= "Instance" or not part.Parent then
                        DestroyTracerESP(TracerLinesTickets, part)
                    elseif tracer and tracer.Visible and not part:IsDescendantOf(workspace) then
                        tracer.Visible = false
                        DestroyTracerESP(TracerLinesTickets, part)
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
                local hrp = v:FindFirstChild("Hitbox")
                
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
                local hrp = v:FindFirstChild("Hitbox")
                
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

local Toggle = Tabs.Main:AddToggle("HighlightTicket", {Title = "Highlight Tickets", Default = false })

    Toggle:OnChanged(function(State)
        DConfiguration.Highlight.Tickets = State
        
        if DConfiguration.Highlight.Tickets then
        	CreateHighlightESP("HighlightTicket_D", Workspace.Game.Effects.Tickets, Color3.fromRGB(255, 213, 128), Color3.fromRGB(255, 213, 128), DConfiguration.Highlight.OutlineOnly)
        else
            DestroyHighlightESP("HighlightTicket_D", Workspace.Game.Effects.Tickets)
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
            end)
        end
    end,
})


Tabs.Main:AddButton({
    Title = "Force Respawn",
    Description = "",
    Callback = function()
        ReplicatedStorage.Events.Player.ChangePlayerMode:FireServer(true)
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
	   	 ReplicatedStorage.Events.Character.Whistle:FireServer()
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
 
 local Toggle = Tabs.Main:AddToggle("ShowTimer", {Title = "Show Timer", Default = false})

Toggle:OnChanged(function(State)
    DConfiguration.Main.ShowTimer = State

    if State then
        if not game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("TimerGui") then
            DFunctions.CreateTimer()
        end

        task.spawn(function()
            while DConfiguration.Main.ShowTimer do
                local gui = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("TimerGui")
                local stats = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Stats")

                if gui and stats then
                    local seconds = stats:GetAttribute("Timer") or 0
                    local minutes = math.floor(seconds / 60)
                    local remainingSeconds = seconds % 60
                    
                    gui.TextLabel.Text = string.format("%d:%02d", minutes, remainingSeconds)
                end
                
                task.wait(0.1)
                
                if not gui then break end 
            end
        end)
    else
        DFunctions.RemoveTimer()
    end
end)

do
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "SpecialRoundGui"
    sg.ResetOnSpawn = false
    sg.Parent = lp:WaitForChild("PlayerGui")

    local SpecialRoundFrame = Instance.new("Frame", sg)
    SpecialRoundFrame.AnchorPoint = Vector2.new(0.5, 0)
    SpecialRoundFrame.Position = UDim2.new(0.5, 0, 0.10, 0)
    SpecialRoundFrame.Size = UDim2.new(0.2, 0, 0.04, 0)
    SpecialRoundFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    SpecialRoundFrame.BackgroundTransparency = 0.5
    SpecialRoundFrame.Visible = false
    Instance.new("UICorner", SpecialRoundFrame).CornerRadius = UDim.new(0, 4)

    local label = Instance.new("TextLabel", SpecialRoundFrame)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = ""
    label.TextColor3 = Color3.fromRGB(255, 208, 115)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    Instance.new("UIStroke", label).Thickness = 2

    local Connection = nil
    local isEnabled = false

    local function getTitle(name)
        local success, title = pcall(function()
            return require(ReplicatedStorage.Info.SpecialRounds[name]).Title
        end)
        return success and title or name
    end

    local function update()
        if not isEnabled then 
            SpecialRoundFrame.Visible = false 
            return 
        end

        local stats = workspace:FindFirstChild("Game") and workspace.Game:FindFirstChild("Stats")
        if stats then
            local val = stats:GetAttribute("SpecialRound")
            if val and val ~= "" then
                label.Text = getTitle(tostring(val))
                SpecialRoundFrame.Visible = true
            else
                SpecialRoundFrame.Visible = false
            end
        end
    end

    local function toggleSpecialRound(state)
        isEnabled = state
        
        if Connection then 
            Connection:Disconnect() 
            Connection = nil 
        end

        if state then
            local stats = workspace:WaitForChild("Game"):WaitForChild("Stats")
            Connection = stats:GetAttributeChangedSignal("SpecialRound"):Connect(update)
            update()
        else
            SpecialRoundFrame.Visible = false
        end
    end

    Tabs.Main:AddToggle("SRToggle", {
        Title = "Special Round Display",
        Default = false,
        Callback = toggleSpecialRound
    })
end



do
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local player = Players.LocalPlayer

    local StateService = require(ReplicatedStorage.Modules.Shared.States.StateService)
    local clientHandler = StateService.ClientHandler:Get(nil)

    local PlayerStatsEnabled = false
    local heartbeatConnection = nil
    local textConnections = {}
    local PlayerStats = nil
    local textLabels = {}
    local frontFrames = {}
    local ExperienceCalculator = nil
    
    local leftColumn, levelText, expText, fill

    function formatNumber(num)
        local str = tostring(math.floor(num))
        local formatted = ""
        local length = #str
        for i = 1, length do
            formatted = formatted .. str:sub(i, i)
            if (length - i) % 3 == 0 and i ~= length then
                formatted = formatted .. ","
            end
        end
        return formatted
    end

    function updateFrontFrameXSize(frame, textLabel)
        if not frame or not textLabel then return end
        local textBounds = textLabel.TextBounds
        frame.Size = UDim2.new(0, textBounds.X + 20, 1, 0)
    end

    function createResourceRow(name, defaultValue, textColor, iconAssetId, iconColor, layoutOrder)
        local container = Instance.new("Frame")
        container.Name = name
        container.BackgroundTransparency = 1
        container.Size = UDim2.fromScale(1, 1)
        container.LayoutOrder = layoutOrder
        container.Parent = leftColumn

        local background = Instance.new("ImageLabel")
        background.Name = "Background"
        background.BackgroundTransparency = 1
        background.Image = "rbxassetid://196969716"
        background.ImageColor3 = Color3.fromRGB(21, 21, 21)
        background.ImageTransparency = 0.4
        background.AnchorPoint = Vector2.new(0.5, 0.5)
        background.Position = UDim2.fromScale(0.5, 0.5)
        background.Size = UDim2.fromScale(1.25, 1.25)
        background.ZIndex = 1
        background.Parent = container

        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(0, 4)
        bgCorner.Parent = background

        local icon = Instance.new("ImageLabel")
        icon.BackgroundTransparency = 1
        icon.Image = "rbxassetid://" .. iconAssetId
        if iconColor then icon.ImageColor3 = iconColor end
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.Position = UDim2.fromScale(0.5, 0.5)
        icon.Size = UDim2.fromScale(0.8, 0.8)
        icon.ZIndex = 3
        icon.Parent = container

        local iconAspect = Instance.new("UIAspectRatioConstraint")
        iconAspect.Parent = icon

        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "Value"
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.GothamBold
        textLabel.Text = tostring(defaultValue)
        textLabel.TextColor3 = textColor
        textLabel.TextScaled = true
        textLabel.TextSize = 14
        textLabel.TextStrokeTransparency = 0.9
        textLabel.TextWrapped = true
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.AnchorPoint = Vector2.new(0, 0.5)
        textLabel.Position = UDim2.new(1.3, 0, 0.5, 0)
        textLabel.Size = UDim2.new(6, 0, 0.8, 0)
        textLabel.ZIndex = 3
        textLabel.Parent = container

        textLabels[name] = textLabel

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 2
        stroke.Transparency = 0.5
        stroke.Parent = textLabel

        local clipLeft = Instance.new("Frame")
        clipLeft.BackgroundTransparency = 1
        clipLeft.ClipsDescendants = true
        clipLeft.Size = UDim2.fromScale(1, 1)
        clipLeft.ZIndex = 2
        clipLeft.Parent = container

        local leftEffect = Instance.new("Frame")
        leftEffect.BackgroundColor3 = Color3.new(0, 0, 0)
        leftEffect.BackgroundTransparency = 0.45
        leftEffect.Size = UDim2.new(2, 0, 1, 0)
        leftEffect.ZIndex = 2
        leftEffect.Parent = clipLeft

        local leftCorner = Instance.new("UICorner")
        leftCorner.CornerRadius = UDim.new(0, 4)
        leftCorner.Parent = leftEffect

        local clipFront = Instance.new("Frame")
        clipFront.Name = "Front"
        clipFront.BackgroundTransparency = 1
        clipFront.ClipsDescendants = true
        clipFront.Position = UDim2.new(1, 0, 0, 0)
        clipFront.Size = UDim2.new(0.5, 33, 1, 0)
        clipFront.ZIndex = 2
        clipFront.Parent = container

        local frontEffect = Instance.new("Frame")
        frontEffect.BackgroundColor3 = Color3.new(0, 0, 0)
        frontEffect.BackgroundTransparency = 0.9
        frontEffect.Position = UDim2.new(-1, 0, 0, 0)
        frontEffect.Size = UDim2.new(2, 0, 1, 0)
        frontEffect.ZIndex = 2
        frontEffect.Parent = clipFront

        local frontCorner = Instance.new("UICorner")
        frontCorner.CornerRadius = UDim.new(0, 4)
        frontCorner.Parent = frontEffect

        frontFrames[name] = {
            frame = clipFront,
            effect = frontEffect,
            textLabel = textLabel
        }

        task.spawn(function()
            task.wait()
            updateFrontFrameXSize(clipFront, textLabel)
        end)

        return textLabel
    end

    function getIntStats()
        local success, result = pcall(function()
            local userData = clientHandler:Get("User/" .. player.UserId)
            if userData and userData.Data and userData.Data.intStats then
                return userData.Data.intStats
            end
            return nil
        end)
        if success and result then return result end
        return nil
    end

    function updateStats()
        if not PlayerStatsEnabled or not PlayerStats then return end
        local intStats = getIntStats()
        if intStats then
            if textLabels["Tokens"] then textLabels["Tokens"].Text = formatNumber(intStats.Tokens or 0) end
            if textLabels["Points"] then textLabels["Points"].Text = formatNumber(intStats.Points or 0) end
            if textLabels["Survivals"] then textLabels["Survivals"].Text = formatNumber(intStats.Survivals or 0) end
            if textLabels["Streak"] then textLabels["Streak"].Text = formatNumber(intStats.Streak or 0) end
            if textLabels["Tickets"] then textLabels["Tickets"].Text = formatNumber(intStats.Tickets or 0) end

            for _, data in pairs(frontFrames) do
                if data.frame and data.textLabel then
                    updateFrontFrameXSize(data.frame, data.textLabel)
                end
            end

            local level = intStats.Level or 1
            local exp = intStats.Experience or 0
            levelText.Text = "LEVEL " .. level

            local neededExp = ExperienceCalculator and ExperienceCalculator(level) or (level * 100)
            expText.Text = formatNumber(exp) .. "/" .. formatNumber(neededExp)
            fill.Size = UDim2.new(math.clamp(exp / neededExp, 0, 1), 0, 1, 0)
        end
    end

    function DisableScanData()
        PlayerStatsEnabled = false
        if heartbeatConnection then heartbeatConnection:Disconnect() heartbeatConnection = nil end
        for _, conn in pairs(textConnections) do if conn then conn:Disconnect() end end
        textConnections = {}
        if PlayerStats then PlayerStats:Destroy() PlayerStats = nil end
        textLabels = {}
        frontFrames = {}
    end

    function EnableScanData()
        if PlayerStats then DisableScanData() end
        PlayerStats = Instance.new("ScreenGui")
        PlayerStats.Name = "PlayerStats"
        PlayerStats.ResetOnSpawn = false
        PlayerStats.DisplayOrder = 333
        PlayerStats.Parent = player:WaitForChild("PlayerGui")

        local views = Instance.new("Frame", PlayerStats)
        views.Name = "Views"
        views.BackgroundTransparency = 1
        views.Size = UDim2.fromScale(1, 1)

        local bottom = Instance.new("Frame", views)
        bottom.Name = "Bottom"
        bottom.BackgroundTransparency = 1
        bottom.Position = UDim2.fromScale(0.01, 0.01)
        bottom.Size = UDim2.fromScale(0.98, 0.98)

        local aspectRatio = Instance.new("UIAspectRatioConstraint", bottom)
        local sizeConstraint = Instance.new("UISizeConstraint", bottom)
        sizeConstraint.MinSize = Vector2.new(450, 450)
        sizeConstraint.MaxSize = Vector2.new(700, 700)

        leftColumn = Instance.new("Frame", bottom)
        leftColumn.Name = "Left"
        leftColumn.BackgroundTransparency = 1
        leftColumn.Position = UDim2.new(0.004, 0, 0.06, 0)
        leftColumn.Size = UDim2.new(0.05, 0, 0.05, 0)

        local listLayout = Instance.new("UIListLayout", leftColumn)
        listLayout.Padding = UDim.new(0.175, 0)
        listLayout.SortOrder = Enum.SortOrder.LayoutOrder

        createResourceRow("Tokens", "0", Color3.fromRGB(163, 255, 87), "7149239101", Color3.fromRGB(163, 255, 87), 1)
        createResourceRow("Points", "0", Color3.new(1, 1, 1), "4648327306", nil, 2)
        createResourceRow("Survivals", "0", Color3.fromRGB(255, 188, 110), "88681516628510", Color3.fromRGB(255, 201, 162), 3)
        createResourceRow("Tickets", "0", Color3.fromRGB(255, 121, 121), "14478137255", Color3.fromRGB(255, 115, 115), 4)
        createResourceRow("Streak", "0", Color3.fromRGB(255, 217, 78), "13518130183", Color3.fromRGB(255, 217, 78), 5)

        local levelBar = Instance.new("Frame", bottom)
        levelBar.Name = "Level"
        levelBar.BackgroundColor3 = Color3.fromRGB(105, 138, 255)
        levelBar.BackgroundTransparency = 0.9
        levelBar.Position = UDim2.new(0, 4, 0, 4)
        levelBar.Size = UDim2.new(0.7, 0, 0.016, 0)

        Instance.new("UICorner", levelBar).CornerRadius = UDim.new(0.5, 0)
        local levelStroke = Instance.new("UIStroke", levelBar)
        levelStroke.Thickness = 2
        levelStroke.Transparency = 0.5

        local barContainer = Instance.new("Frame", levelBar)
        barContainer.Name = "Bar"
        barContainer.BackgroundTransparency = 1
        barContainer.ClipsDescendants = true
        barContainer.Size = UDim2.new(1, 0, 1, 0)

        fill = Instance.new("Frame", barContainer)
        fill.BackgroundColor3 = Color3.fromRGB(105, 138, 255)
        fill.BackgroundTransparency = 0.2
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.ZIndex = 2
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0.5, 0)

        local gradient = Instance.new("UIGradient", fill)
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(0.3149, Color3.fromRGB(241, 246, 249)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(168, 201, 222))
        })
        gradient.Rotation = 90

        levelText = Instance.new("TextLabel", levelBar)
        levelText.BackgroundTransparency = 1
        levelText.Font = Enum.Font.GothamBold
        levelText.Text = "LEVEL 1"
        levelText.TextColor3 = Color3.fromRGB(105, 138, 255)
        levelText.TextScaled = true
        levelText.TextXAlignment = "Left"
        levelText.Position = UDim2.new(0, 0, 1.25, 0)
        levelText.Size = UDim2.new(0.5, 0, 1.5, 0)
        Instance.new("UIStroke", levelText).Thickness = 2

        expText = Instance.new("TextLabel", levelBar)
        expText.BackgroundTransparency = 1
        expText.Font = Enum.Font.GothamBold
        expText.Text = "0/100"
        expText.TextColor3 = Color3.fromRGB(105, 138, 255)
        expText.TextScaled = true
        expText.TextXAlignment = "Right"
        expText.AnchorPoint = Vector2.new(1, 0)
        expText.Position = UDim2.new(1, 0, 1.25, 0)
        expText.Size = UDim2.new(0.5, 0, 1.25, 0)
        Instance.new("UIStroke", expText).Thickness = 2

        PlayerStatsEnabled = true
        task.wait(1)
        updateStats()

        heartbeatConnection = RunService.Heartbeat:Connect(function()
            if PlayerStatsEnabled and tick() % 0.5 < 0.05 then
                updateStats()
            end
        end)
    end

    pcall(function()
        ExperienceCalculator = require(ReplicatedStorage.Modules.Shared.TablesAndMethods.ExperienceCalculator)
    end)

    Tabs.Main:AddToggle("PlayerStatsToggle", {
        Title = "Player Stats",
        Default = false,
        Callback = function(state)
            if state then EnableScanData() else DisableScanData() end
        end
    })
end

Tabs.Main:AddParagraph({
        Title = " ",
        Content = ""
    })
 
 local Toggle = Tabs.Main:AddToggle("DisableCameraShake", {Title = "Disable Camera Shake", Default = false })

local CameraShakeConnection 

Toggle:OnChanged(function(value)
    DConfiguration.Removals.CameraShake = value

    if CameraShakeConnection then
        CameraShakeConnection:Disconnect()
        CameraShakeConnection = nil
    end

    if value then
        CameraShakeConnection = RunService.RenderStepped:Connect(function()
            DFunctions.DisableCameraShake()
        end)
    end
end)

local Toggle = Tabs.Main:AddToggle("DisableVignette", {Title = "Disable Vignette", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.Removals.Vignette = value

    while DConfiguration.Removals.Vignette and wait(0.1) do
       spawn(DFunctions.DisableVignette)
    end
end)
    
Tabs.Main:AddSection("Battlepass Modification")

Tabs.Main:AddParagraph({
	Title = "Bypass Timer",
        Content = "Not Work"
    })

local Toggle = Tabs.Main:AddToggle("EnableExchange", {Title = "Enable Exchange", Default = false })

Toggle:OnChanged(function(value)
    local Center = LocalPlayer.PlayerGui and LocalPlayer.PlayerGui:FindFirstChild("Menu") and LocalPlayer.PlayerGui.Menu:FindFirstChild("Views") and LocalPlayer.PlayerGui.Menu.Views:FindFirstChild("Battlepass") and LocalPlayer.PlayerGui.Menu.Views.Battlepass:FindFirstChild("Center")
    local Exchange = LocalPlayer.PlayerGui and LocalPlayer.PlayerGui:FindFirstChild("Menu") and LocalPlayer.PlayerGui.Menu:FindFirstChild("Views") and LocalPlayer.PlayerGui.Menu.Views:FindFirstChild("Battlepass") and LocalPlayer.PlayerGui.Menu.Views.Battlepass:FindFirstChild("Exchange")

    if Center and Exchange then
        Center.Visible = not value
        Exchange.Visible = value
    end
end)

Tabs.Main:AddSection("Player Modification")
    
local Toggle = Tabs.Main:AddToggle("Noclip", {Title = "Noclip", Default = false })

Toggle:OnChanged(function(value)
   DConfiguration.Main.Noclip = value
end)

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

    mfly2 = RS.PreRender:Connect(function()
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

Tabs.Misc:AddKeybind("FlyKeybind", {
    Title = "Fly Toggle",
    Mode = "Toggle",
    Default = "F",
    Callback = function(Value)
        toggleFly(Value)
    end
})

local FlySpeedInput = Tabs.Misc:AddInput("FlySpeedInput", {
    Title = "Fly Speed",
    Default = tostring(_G.flySpeed),
    Placeholder = "Enter fly speed",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        _G.flySpeed = tonumber(Value) or 20
    end
})
    
wait(Duration)

-- Auto Farm

Tabs.AutoFarm:AddSection("Farmings")
    
local Toggle = Tabs.AutoFarm:AddToggle("AutoFarmMoney", {Title = "Auto Farm Money", Default = false })

Toggle:OnChanged(function(State)
    DConfiguration.AutoFarm.FarmTokens = State

    while DConfiguration.AutoFarm.FarmTokens and wait(0.1) do
        spawn(DFunctions.RevivePlayer)
    end
end)

local Toggle = Tabs.AutoFarm:AddToggle("AutoFarmTickets", {Title = "Auto Farm Tickets", Default = false })

Toggle:OnChanged(function(State)
    DConfiguration.AutoFarm.FarmTickets = State

    while DConfiguration.AutoFarm.FarmTickets and wait(0.1) do
        spawn(DFunctions.TicketsFarming)
    end
end)
    
local Toggle = Tabs.AutoFarm:AddToggle("AFKFarm", {Title = "AFK Farm", Default = false })

    Toggle:OnChanged(function(State)
      DConfiguration.AutoFarm.AFKFarm = State
      
      while DConfiguration.AutoFarm.AFKFarm and wait(0.1) do
         spawn(DFunctions.AFKFarming)
       end
    end)
    
Tabs.AutoFarm:AddSection("VIP Automations")

local Toggle = Tabs.AutoFarm:AddToggle("AutoVote", {Title = "Auto Vote", Default = false })

    Toggle:OnChanged(function(State)
       DConfiguration.AutoFarm.VIPAutomations.AutoVote = State
       
       while DConfiguration.AutoFarm.VIPAutomations.AutoVote and wait(1) do
          DFunctions.AutoVote(DConfiguration.AutoFarm.VIPAutomations.MapSection, DConfiguration.AutoFarm.VIPAutomations.GamemodeSection)
       end
    end)
    
local Dropdown = Tabs.AutoFarm:AddDropdown("MapSection", {
        Title = "Map Section",
        Values = {1, 2, 3, 4},
        Multi = false,
        Default = 1,
    })

    Dropdown:OnChanged(function(Value)
        DConfiguration.AutoFarm.VIPAutomations.MapSection = Value
    end)
    
local Dropdown = Tabs.AutoFarm:AddDropdown("GamemodeSection", {
        Title = "Gamemode Section",
        Values = {1, 2, 3, 4},
        Multi = false,
        Default = 1,
    })

    Dropdown:OnChanged(function(Value)
        DConfiguration.AutoFarm.VIPAutomations.GamemodeSection = Value
    end)
    
Tabs.AutoFarm:AddParagraph({
        Title = " ",
        Content = ""
    })

local Toggle = Tabs.AutoFarm:AddToggle("AutoSetMap", {Title = "Auto Set Map", Default = false })

    Toggle:OnChanged(function(State)
      DConfiguration.AutoFarm.VIPAutomations.AutoMap = State
      
      if DConfiguration.AutoFarm.VIPAutomations.AutoMap then
         DFunctions.SetVIPCommands(DConfiguration.AutoFarm.VIPAutomations.MapInput, nil)
      end
    end)
    
local Toggle = Tabs.AutoFarm:AddToggle("AutoSetSpecialRound", {Title = "Auto Set Special Round", Default = false })

    Toggle:OnChanged(function(State)
      DConfiguration.AutoFarm.VIPAutomations.AutoSpecialRound = State
      
      if DConfiguration.AutoFarm.VIPAutomations.AutoSpecialRound then
         DFunctions.SetVIPCommands(nil, DConfiguration.AutoFarm.VIPAutomations.SpecialRoundInput)
       end
    end)
    
local Toggle = Tabs.AutoFarm:AddToggle("AutoSetMap", {Title = "Auto Set Gamemode to Pro (RECOMMENDED)", Default = false })

    Toggle:OnChanged(function(State)
      DConfiguration.AutoFarm.VIPAutomations.AutoProMode = State
      
      if DConfiguration.AutoFarm.VIPAutomations.AutoProMode then
         ReplicatedStorage.Events.CustomServers.Admin:FireServer("Gamemode", "Pro")
	     wait(3)
	     game:GetService("ReplicatedStorage").Events.Player.ChangePlayerMode:FireServer(true)
      end
   end)
    
Tabs.AutoFarm:AddInput("MapInput", {
    Title = "Map Input",
    Default = "DesertBus",
    Placeholder = "DesertBus",
    Numeric = false, 
    Finished = false, 
    Description = "NO SPACE NEEDED",
    Callback = function(Value)
        DConfiguration.AutoFarm.VIPAutomations.MapInput = Value
    end
})

Tabs.AutoFarm:AddInput("SpecialRoundInput", {
    Title = "Special Round Input",
    Default = "Plushie Hell",
    Placeholder = "Plushie Hell",
    Numeric = false, 
    Finished = false, 
    Callback = function(Value)
        DConfiguration.AutoFarm.VIPAutomations.SpecialRoundInput = Value
    end
})

wait(Duration)

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
    Placeholder = "Number",
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
    Placeholder = "Number",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Misc.PlayerAdjustment.Update.JumpHeight = tonumber(Value) or 3
        DConfiguration.Misc.PlayerAdjustment.Saved.JumpHeight = tonumber(Value) or 3
    end
})

Tabs.Misc:AddInput("PlayerJumpAcce", {
    Title = "Player Jump Acceleration",
    Description = "",
    Default = "1.5",
    Placeholder = "Number",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Misc.PlayerAdjustment.Update.JumpAcceleration = tonumber(Value) or 1.5
        DConfiguration.Misc.PlayerAdjustment.Saved.JumpAcceleration = tonumber(Value) or 1.5
    end
})

Tabs.Misc:AddInput("PlayerJumpCap", {
    Title = "Player Jump Cap",
    Description = "",
    Default = "1",
    Placeholder = "Number",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Misc.PlayerAdjustment.Update.JumpCap = tonumber(Value) or 1
        DConfiguration.Misc.PlayerAdjustment.Saved.JumpCap = tonumber(Value) or 1
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

local Keybind = Tabs.Misc:AddKeybind("LagSwitchKey", {
        Title = "Lag Switch Keybind",
        Mode = "Toggle", -- Always, Toggle, Hold
        Default = "H",
        
        Callback = function()
          task.spawn(function() 
	          DFunctions.StartLag(DConfiguration.Misc.Utilities.LagSwitch.MSDelay) 
          end)
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

Tabs.Misc:AddSection("Bouce Adjustments")
    
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
    
local ToggleModify = Tabs.Misc:AddToggle("AdjustBounce", {Title = "Modify Bounce", Default = false })

ToggleModify:OnChanged(function(State)
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

local KeybindSuper = Tabs.Misc:AddKeybind("SuperBounceKey", {
    Title = "Super Bounce",
    Mode = "Toggle", 
    Default = "X", 
    Callback = function(State)
        if State then
            task.spawn(function()
                DFunctions.SuperBounce()
            end)
        end
    end,
})
local KeybindRegular = Tabs.Misc:AddKeybind("BounceKey", {
    Title = "Bounce (Keybind)",
    Mode = "Toggle", 
    Default = "P", 
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
    
local Toggle = Tabs.Misc:AddToggle("AdjustEdgeTrimp", {Title = "Modify Edge Trimp", Default = false })

Toggle:OnChanged(function(State)
    DConfiguration.Misc.Utilities.EdgeTrimpModification.Enabled = State
     
    while DConfiguration.Misc.Utilities.EdgeTrimpModification.Enabled and wait(0.1) do
        spawn(DFunctions.ModifyEdgeTrimp)
    end
end)

Tabs.Misc:AddInput("EdgeTrimpHeight", {
        Title = "Height Multiplier",
        Default = "1.5",
        Placeholder = "Number",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Misc.Utilities.EdgeTrimpModification.HeightMultiplier = tonumber(Value) or 1.5
        end
    })
    
Tabs.Misc:AddInput("DownThreshold", {
        Title = "Falling Threshold",
        Default = "4.5",
        Placeholder = "Number",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Misc.Utilities.EdgeTrimpModification.DownThreshold = tonumber(Value) or 4.5
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
    
Tabs.Misc:AddSection("Camera Adjustments")

Tabs.Misc:AddInput("CamX", {
        Title = "Stretch Horizontal",
        Default = "1",
        Placeholder = "Number",
        Numeric = false,
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Misc.CameraAdjustment.StretchX = tonumber(Value) or 1
        end
    })
    
 Tabs.Misc:AddInput("CamY", {
        Title = "Stretch Vertical",
        Default = "1",
        Placeholder = "Number",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Misc.CameraAdjustment.StretchY = tonumber(Value) or 1
        end
    })
    
 Tabs.Misc:AddInput("PlayerFOV", {
        Title = "Player FOV",
        Default = "1",
        Placeholder = "Number",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            LocalPlayer.PlayerScripts.Camera.FOVAdjusters.Zoom.Value = Value
        end
    })
    
Tabs.Misc:AddButton({
        Title = "Set Camera Stretch",
        Description = "(Warning: Stretch settings can make billboards look weird or disappear from far away.)",
        Callback = function()
           LocalPlayer:SetAttribute("StretchX", DConfiguration.Misc.CameraAdjustment.StretchX)
           LocalPlayer:SetAttribute("StretchY", DConfiguration.Misc.CameraAdjustment.StretchY)
        end
    })
    
Tabs.Misc:AddSection("Gun Adjustments")

Tabs.Misc:AddButton({
    Title = "Grapplehook",
    Description = "Endless",
    Callback = function()
        local success, result = pcall(function()
            local GrappleHook = require(game:GetService("ReplicatedStorage").Tools["GrappleHook"])

            local grappleTask = GrappleHook.Tasks[2]

            
            local shootMethod = grappleTask.Functions[1].Activations[1].Methods[1]

            
            shootMethod.Info.Speed = 10000          
            shootMethod.Info.Lifetime = 10.0        
            shootMethod.Info.Gravity = Vector3.new(0, 0, 0)  
            shootMethod.Info.SpreadIncrease = 0     
            shootMethod.Info.Cooldown = 0.1       

            
            grappleTask.MethodReferences.Projectile.Info.SpreadInfo.MaxSpread = 0
            grappleTask.MethodReferences.Projectile.Info.SpreadInfo.MinSpread = 0
            grappleTask.MethodReferences.Projectile.Info.SpreadInfo.ReductionRate = 100

            
            local checkMethod = grappleTask.AutomaticFunctions[1].Methods[1]
            checkMethod.Info.Cooldown = 0.1
            checkMethod.CooldownInfo.TestCooldown = 0.1

            
            grappleTask.ResourceInfo.Cap = 999999

            
            GrappleHook.Adjustments.ToolViewbob = false
            GrappleHook.Actions.LookBack.Enabled = true
            GrappleHook.Actions.ADS.Enabled = true
            GrappleHook.Actions.ADS.Zoom = 0.5 

            
            shootMethod.GlobalPriority = 500  
            
            return true
        end)
        
        if success then
            Fluent:Notify({
                Title = "GrappleHook",
                Content = "Work!",
                Duration = 5
            })
        else
            Fluent:Notify({
                Title = "GrappleHook Error",
                Content = "Error: " .. tostring(result),
                Duration = 5
            })
        end
    end
})

Tabs.Misc:AddButton({
    Title = "Portal Gun",
    Description = "Endless",
    Callback = function()
        local success, result = pcall(function()
            local Breacher = require(game:GetService("ReplicatedStorage").Tools.Breacher)

           
            local portalTask
            for i, task in ipairs(Breacher.Tasks) do
                if task.ResourceInfo and task.ResourceInfo.Type == "Clip" then
                    portalTask = task
                    break
                end
            end

            if not portalTask then
                portalTask = Breacher.Tasks[2]
            end

 -- ammo
            portalTask.ResourceInfo.Cap = 999999

            
            local blueShoot = portalTask.Functions[1].Activations[1].Methods[1]  
            local yellowShoot = portalTask.Functions[2].Activations[1].Methods[1] 
            blueShoot.Info.Range = 999999
            yellowShoot.Info.Range = 999999

            
            blueShoot.Info.SpreadIncrease = 0
            yellowShoot.Info.SpreadIncrease = 0

            portalTask.MethodReferences.Portal.Info.SpreadInfo.MaxSpread = 0
            portalTask.MethodReferences.Portal.Info.SpreadInfo.MinSpread = 0
            portalTask.MethodReferences.Portal.Info.SpreadInfo.ReductionRate = 100

            
            blueShoot.Info.Cooldown = 0.1
            yellowShoot.Info.Cooldown = 0.1

            
            blueShoot.CooldownInfo = {}
            yellowShoot.CooldownInfo = {}
            blueShoot.Requirements = {}
            yellowShoot.Requirements = {}

            
            Breacher.Actions.ADS.Enabled = false  

            
            local unequipMethod = Breacher.Tasks[1].AutomaticFunctions[2].Methods[1]
            unequipMethod.CooldownInfo = {}  

            
            if blueShoot.CooldownInfo and blueShoot.CooldownInfo.DisabledActions then
            
                local newDisabled = {}
                for _, action in ipairs(blueShoot.CooldownInfo.DisabledActions) do
                    if action ~= "ADS" then
                        table.insert(newDisabled, action)
                    end
                end
                blueShoot.CooldownInfo.DisabledActions = newDisabled
            end

            if yellowShoot.CooldownInfo and yellowShoot.CooldownInfo.DisabledActions then
                
                local newDisabled = {}
                for _, action in ipairs(yellowShoot.CooldownInfo.DisabledActions) do
                    if action ~= "ADS" then
                        table.insert(newDisabled, action)
                    end
                end
                yellowShoot.CooldownInfo.DisabledActions = newDisabled
            end

            
            blueShoot.GlobalPriority = 500
            yellowShoot.GlobalPriority = 500
            blueShoot.Priority = 1
            yellowShoot.Priority = 1

            
            blueShoot.ResourceAboveZero = false
            yellowShoot.ResourceAboveZero = false

            
            portalTask.Functions[1].Activations[1].CanHoldDown = true
            portalTask.Functions[2].Activations[1].CanHoldDown = true

            
            if not blueShoot.Info.Speed then
                blueShoot.Info.Speed = 5000
                yellowShoot.Info.Speed = 5000
            end

            
            local baseTask = Breacher.Tasks[1]
            baseTask.AutomaticFunctions[1].Methods[1].Info.Cooldown = 0.1
            baseTask.AutomaticFunctions[2].Methods[1].Info.Cooldown = 0.1

        
            Breacher.Actions.LookBack.Enabled = true

            
            Breacher.Adjustments.ToolViewbob = true
            Breacher.Adjustments.AnimationRootStraight = true
            Breacher.Adjustments.TurnWaist = true

            
            Breacher.HUD.CrosshairType = "Accurate"  
            Breacher.HUD.Colored = true

            
            if Breacher.Actions.ADS.Zoom then
                Breacher.Actions.ADS.Zoom = nil 
            end
            
            return true
        end)
        
        if success then
            Fluent:Notify({
                Title = "Portal Gun",
                Content = "Work!",
                Duration = 6
            })
        else
            Fluent:Notify({
                Title = "Breacher Error",
                Content = "Error: " .. tostring(result),
                Duration = 5
            })
        end
    end
})
    
Tabs.Misc:AddSection("Game Automations")

local Toggle = Tabs.Misc:AddToggle("InstantRevive", {Title = "Instant Revive", Default = false})

Toggle:OnChanged(function(State)
    DConfiguration.Misc.GameAutomation.Revive.Enabled = State
    
  while DConfiguration.Misc.GameAutomation.Revive.Enabled and wait(DConfiguration.Misc.GameAutomation.Revive.Delay) do
      if DConfiguration.Misc.GameAutomation.Revive.WhileEmote then
          spawn(DFunctions.InstantRevive)
      else
           spawn(DFunctions.InstantReviveNoEmote)
       end
    end
end)

local Toggle = Tabs.Misc:AddToggle("InsQua", {Title = "Instant Revive While Emote", Default = false})

Toggle:OnChanged(function(State)
    DConfiguration.Misc.GameAutomation.Revive.WhileEmote = State
end)

local Slider = Tabs.Misc:AddSlider("ReviveDelay", {
        Title = "Revive Delay",
        Description = "",
        Default = 0.1,
        Min = 0,
        Max = 5,
        Rounding = 1,
        Callback = function(v)
            DConfiguration.Misc.GameAutomation.Revive.Delay = v
        end
    })
    
local Keybind = Tabs.Misc:AddKeybind("KeybindRevive", {
        Title = "Keybind to Instant Revive",
        Mode = "Toggle", 
        Default = "RightShift",
        
        Callback = function(Bool)
        DConfiguration.Misc.GameAutomation.Revive.Keybind = Bool
   end,
    })
    
Tabs.Misc:AddParagraph({
        Title = " ",
        Content = ""
    })

local Toggle = Tabs.Misc:AddToggle("EmoteCarry", {Title = "Carry While Emote", Default = false})

Toggle:OnChanged(function(State)
    DConfiguration.Misc.GameAutomation.Carry.WhileEmote = State
end)

local Keybind = Tabs.Misc:AddKeybind("KeybindCarry", {
        Title = "Keybind to Carry",
        Mode = "Toggle", 
        Default = "Q",
        
        Callback = function(Bool)
        DConfiguration.Misc.GameAutomation.Carry.Keybind = Bool
   end,
})

Tabs.Misc:AddParagraph({
        Title = " ",
        Content = ""
    })

wait(Duration)

local SelectedCrouchMode = "Crouch"
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer

Tabs.Misc:AddDropdown("EmoteCrouchSettings", {
    Title = "Crouch Setting",
    Values = {"Crouch", "Don't Crouch"},
    Multi = false,
    Default = "Crouch",
    Callback = function(Value)
        SelectedCrouchMode = Value
    end
})

Tabs.Misc:AddKeybind("KeyEmoteDash", {
    Title = "Keybind to Emote Dash",
    Mode = "Toggle", 
    Default = "RightControl",
    Callback = function(State)
        if State then
            task.spawn(function()
                local EmoteEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Character") and ReplicatedStorage.Events.Character:FindFirstChild("Emote")
                
                if EmoteEvent then
                    EmoteEvent:FireServer(DConfiguration.Misc.GameAutomation.Macro.SelectedEmote)
                end
                
                task.wait(0.1)
                
                if SelectedCrouchMode == "Crouch" then
                    local UseKeybind = LocalPlayer:FindFirstChild("PlayerScripts") and LocalPlayer.PlayerScripts:FindFirstChild("Events", true) and LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind
                    if UseKeybind then
                        UseKeybind:Fire({ ["Key"] = "Crouch", ["Down"] = true })
                    end
                end
            end)
        end
    end
})

local Dropdown = Tabs.Misc:AddDropdown("EmoteID", {
    Title = "Select Emote ID",
    Values = EmoteNames,
    Multi = false,
    Default = 1,
})

Dropdown:OnChanged(function(Value)
    DConfiguration.Misc.GameAutomation.Macro.SelectedEmote = Value
end)


Tabs.Misc:AddSection("Movement Modification")

local Toggle = Tabs.Misc:AddToggle("AggressiveEmoteDash", {Title = "Aggressive Emote Dash", Default = false })

Toggle:OnChanged(function(State)
	DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Enabled = State
	
	if not DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Enabled then
	    DConfiguration.Misc.PlayerAdjustment.Debounce.GroundAcceleration = false
	    DFunctions.setTSpeed(DConfiguration.Misc.PlayerAdjustment.Saved.Speed)
	end
end)

local Dropdown = Tabs.Misc:AddDropdown("AggressiveEmoteType", {
        Title = "Aggressive Emote Type",
        Values = {"Legit", "Blatant"},
        Multi = false,
        Default = 2,
    })

    Dropdown:OnChanged(function(Value)
        DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Type = Value
    end)
    
 Tabs.Misc:AddInput("EmoteSpeed", {
        Title = "Aggressive Emote Speed",
        Default = "2000",
        Placeholder = "Emote Speed Number",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Speed = tonumber(Value) or 2000
        end
    })
    
Tabs.Misc:AddInput("CrouchSpeed", {
        Title = "Aggressive Emote Acceleration (Negative Only)",
        Default = "-2",
        Placeholder = "Acceleration Number",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Misc.MovementModification.AggressiveEmoteDash.Acceleration = tonumber(Value) or -2
        end
    })
    
Tabs.Misc:AddParagraph({
        Title = " ",
        Content = ""
    })

local Toggle = Tabs.Misc:AddToggle("InfiniteSlide", {Title = "Infinite Slide", Default = false })

Toggle:OnChanged(function(State)
    DConfiguration.Misc.MovementModification.SlideModification.Enabled = State
    
    if not DConfiguration.Misc.MovementModification.SlideModification.Enabled then
        DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = 5
        wait(0.1)
        DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration = 5
    end
end)

 Tabs.Misc:AddInput("CrouchSpeed", {
        Title = "Slide Speed (Negative Only)",
        Default = "-3",
        Placeholder = "Crouch Speed Number",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Misc.MovementModification.SlideModification.Acceleration = tonumber(Value) or -3
        end
    })

 Tabs.Misc:AddParagraph({
        Title = " ",
        Content = ""
    })
    
local NormalGravity = workspace.Gravity

Tabs.Misc:AddToggle("GravityToggle", {
    Title = "Gravity Toggle",
    Default = false,
    Callback = function(State)
        DConfiguration.Misc.MovementModification.Gravity.Keybind = State
        
        if State then
            workspace.Gravity = DConfiguration.Misc.MovementModification.Gravity.Value
        else
            workspace.Gravity = NormalGravity
        end
    end
})

Tabs.Misc:AddInput("GravityAdjust", {
    Title = "Gravity Adjustment",
    Default = "10",
    Placeholder = "Number",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value) or 10
        DConfiguration.Misc.MovementModification.Gravity.Value = num
        
        if DConfiguration.Misc.MovementModification.Gravity.Keybind then
            workspace.Gravity = num
        end
    end
})

    
Tabs.Misc:AddParagraph({
        Title = " ",
        Content = ""
    })

local isHolding = false

Tabs.Misc:AddKeybind("KeybindBHOP", {
    Title = "Toggle BHOP",
    Mode = "Toggle", 
    Default = "B",
    Callback = function(State)        
        DConfiguration.Misc.MovementModification.BHOP.Enabled = State or isHolding        
        if not State and not isHolding then
            task.spawn(DFunctions.ResetBHOP)
        end
    end
})

Tabs.Misc:AddKeybind("KeybindBHOP2", {
    Title = "Hold BHOP",
    Mode = "Hold", 
    Default = "Space",
    Callback = function(State)
        isHolding = State
        local isToggled = DConfiguration.Misc.MovementModification.BHOP.Enabled       
        DConfiguration.Misc.MovementModification.BHOP.Enabled = (isToggled or isHolding)
        
        if not State and not isToggled then
            task.spawn(DFunctions.ResetBHOP)
        end
    end
})

local Dropdown = Tabs.Misc:AddDropdown("BHOPVersion", {
        Title = "Select BHOP Version",
        Values = {"Acceleration", "Ground Acceleration", "No Acceleration"},
        Multi = false,
        Default = 1,
    })

    Dropdown:OnChanged(function(Value)
        DConfiguration.Misc.MovementModification.BHOP.Settings.Type = Value
    end)
    
local Dropdown = Tabs.Misc:AddDropdown("JumpType", {
        Title = "Select Jump Type",
        Values = {"Simulated", "Realistic"},
        Multi = false,
        Default = 1,
    })

    Dropdown:OnChanged(function(Value)
        DConfiguration.Misc.MovementModification.BHOP.Settings.JumpType = Value
    end)
    
local Toggle = Tabs.Misc:AddToggle("BackwardBHOP", {Title = "BHOP Backwards", Default = false })

 Toggle:OnChanged(function(State)
      DConfiguration.Misc.MovementModification.BHOP.Settings.Backwards = State
end)

local Toggle = Tabs.Misc:AddToggle("SpiderHop", {Title = "Spider Hop (Beta)", Default = false })

 Toggle:OnChanged(function(State)
      DConfiguration.Misc.MovementModification.BHOP.Settings.SpiderHop = State
end)
    
Tabs.Misc:AddInput("BHOPAcceleration", {
        Title = "BHOP Acceleration (Negative Only)",
        Default = "-0.1",
        Placeholder = "-1",
        Numeric = false, -- Only allows numbers
        Finished = false, -- Only calls callback when you press enter
        Callback = function(Value)
            DConfiguration.Misc.MovementModification.BHOP.Settings.Acceleration = tonumber(Value) or -0.1
        end
    })
    
Tabs.Misc:AddParagraph({
        Title = " ",
        Content = ""
    })
    
local Toggle = Tabs.Misc:AddToggle("BHOPAutoAccelerate", {Title = "Auto Acceleration (Legit)", Default = false })

 Toggle:OnChanged(function(State)
      DConfiguration.Misc.MovementModification.BHOP.Settings.AutoAcceleration.Enabled = State
end)

Tabs.Misc:AddInput("AutoAccelerationMaxAccel", {
        Title = "Max Acceleration",
        Default = "3",
        Placeholder = "3",
        Numeric = false, -- Only allows numbers
        Finished = false, -- Only calls callback when you press enter
        Callback = function(Value)
            DConfiguration.Misc.MovementModification.BHOP.Settings.AutoAcceleration.MaxAccelerate = tonumber(Value) or 3
        end
    })
    
Tabs.Misc:AddInput("AutoAccelerationMinAccel", {
        Title = "Min Acceleration",
        Default = "-1",
        Placeholder = "-1",
        Numeric = false, -- Only allows numbers
        Finished = false, -- Only calls callback when you press enter
        Callback = function(Value)
            DConfiguration.Misc.MovementModification.BHOP.Settings.AutoAcceleration.MinAccelerate = tonumber(Value) or -1
        end
    })

Tabs.Misc:AddInput("AutoAccelerationMaxSpeed", {
        Title = "Max Speed",
        Default = "70",
        Placeholder = "70",
        Numeric = false, -- Only allows numbers
        Finished = false, -- Only calls callback when you press enter
        Callback = function(Value)
            DConfiguration.Misc.MovementModification.BHOP.Settings.AutoAcceleration.MinSpeed = tonumber(Value) or 70
        end
    })

Tabs.Misc:AddParagraph({
        Title = " ",
        Content = ""
    })

local UserInputService = game:GetService("UserInputService")

if not DConfiguration then DConfiguration = {} end
if not DConfiguration.Misc then DConfiguration.Misc = {} end
if not DConfiguration.Misc.MovementModification then DConfiguration.Misc.MovementModification = {} end
if not DConfiguration.Misc.MovementModification.Crouch then
    DConfiguration.Misc.MovementModification.Crouch = {
        Keybind = false,
        CurrentKey = Enum.KeyCode.RightControl,
        Type = "Normal",
        KeybindMode = "Hold",
        debounce = 0.1,
        lastTick = 0,
        isHolding = false
    }
end

local function GetCrouchConfig()
    return DConfiguration.Misc.MovementModification.Crouch
end

local function toKeyCode(input)
    if typeof(input) == "EnumItem" then return input end
    if typeof(input) == "string" then
        local success, result = pcall(function() return Enum.KeyCode[input] end)
        if success then return result end
    end
    return Enum.KeyCode.RightControl
end

local function resetCrouchState(Config)
    Config.Keybind = false
    Config.isHolding = false
    LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({ ["Key"] = "Crouch", ["Down"] = false })
    task.wait(0.05)
    LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind:Fire({ ["Key"] = "Crouch", ["Down"] = false })
end

local Keybind = Tabs.Misc:AddKeybind("KeybindCrouch", {
    Title = "Keybind to Auto Crouch",
    Mode = "Click", 
    Default = "RightControl",
    Callback = function(Key)
        local Config = GetCrouchConfig()
        Config.CurrentKey = toKeyCode(Key)
    end,
})

Keybind:OnChanged(function()
    local Config = GetCrouchConfig()
    if Keybind.Value then
        Config.CurrentKey = toKeyCode(Keybind.Value)
    end
end)

local KeybindModeDropdown = Tabs.Misc:AddDropdown("CrouchKeybindMode", {
    Title = "Keybind Mode",
    Values = {"Hold", "Toggle"},
    Default = 1,
})

KeybindModeDropdown:OnChanged(function(Value)
    local Config = GetCrouchConfig() 
    Config.KeybindMode = Value
    resetCrouchState(Config)
end)

local Dropdown = Tabs.Misc:AddDropdown("CrouchType", {
    Title = "Select Crouch Type",
    Values = {"Rapid", "Ground", "Air", "Normal"},
    Default = 1,
})

Dropdown:OnChanged(function(Value)
    local Config = GetCrouchConfig() 
    Config.Type = Value
end)

Tabs.Misc:AddInput("CrouchDebounce", {
    Title = "Crouch Speed (Debounce)",
    Default = "0.1",
    Placeholder = "0.1",
    Numeric = true, 
    Callback = function(Value)
        local Config = GetCrouchConfig() 
        Config.debounce = tonumber(Value) or 0.1
    end
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local Config = GetCrouchConfig()
    if not Config.CurrentKey or input.KeyCode ~= Config.CurrentKey then return end

    if Config.KeybindMode == "Toggle" then
        if Config.Keybind then
            resetCrouchState(Config)
        else
            Config.Keybind = true
        end
    else
        Config.Keybind = true
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    local Config = GetCrouchConfig()
    if not Config.CurrentKey or input.KeyCode ~= Config.CurrentKey then return end

    if Config.KeybindMode == "Hold" then
        resetCrouchState(Config)
    end
end)

RunService.Heartbeat:Connect(function()
    local MoveMod = DConfiguration.Misc and DConfiguration.Misc.MovementModification
    local GameAuto = DConfiguration.Misc and DConfiguration.Misc.GameAutomation
    local stop = false

    if DConfiguration.Main and DConfiguration.Main.Noclip then
        spawn(DFunctions.Noclip)
    end

    if GameAuto and GameAuto.Revive and (GameAuto.Revive.FloatingButton or GameAuto.Revive.Keybind) then
        spawn(DFunctions.InstantRevive)
    end
       
    if GameAuto and GameAuto.Carry and (GameAuto.Carry.FloatingButton or GameAuto.Carry.Keybind) then
        spawn(DFunctions.CarryPlayer)
    end
    
    if MoveMod and MoveMod.Gravity and (MoveMod.Gravity.FloatingButton or MoveMod.Gravity.Keybind) then
        game.Workspace.Gravity = MoveMod.Gravity.Value
    else
        game.Workspace.Gravity = NormalGravity
    end

    if MoveMod and MoveMod.BHOP and (MoveMod.BHOP.Enabled or MoveMod.BHOP.Keybind or MoveMod.BHOP.HoldKeybind) then
        task.spawn(DFunctions.BHOPFunction)
        stop = true
    end
    
    if MoveMod and MoveMod.Crouch and MoveMod.Crouch.Keybind then
        task.spawn(DFunctions.CrouchFunction)
        stop = true
    end

    if not stop and MoveMod then
        if MoveMod.AggressiveEmoteDash and MoveMod.AggressiveEmoteDash.Enabled then
            task.spawn(DFunctions.AggressiveEmoteDashFunction)
        end
        
        if MoveMod.SlideModification and MoveMod.SlideModification.Enabled then
            task.spawn(DFunctions.InfiniteSlideFunction)
        end
    end
    
    RunService.RenderStepped:Wait()
end)

Tabs.Misc:AddSection("Spins")

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

local function toKeyCode(input)
    if typeof(input) == "EnumItem" then return input end
    if typeof(input) == "string" then
        local success, result = pcall(function() return Enum.KeyCode[input] end)
        if success then return result end
    end
    return nil
end

Tabs.Misc:AddParagraph({
    Title = "No use Emote",
    Content = " "
})

do 
    local _SP = {
        Enabled = false,
        Speed = 100000,
        Conn = nil,
        CurrentKey = Enum.KeyCode.RightAlt,
        Active = false
    }

    local function ToggleSpin(state)
        _SP.Active = state
        if _SP.Conn then _SP.Conn:Disconnect() _SP.Conn = nil end

        if _SP.Active then
            _SP.Conn = RunService.Heartbeat:Connect(function(dt)
                local character = LP.Character
                local hrp = character and character:FindFirstChild("HumanoidRootPart")
                local hum = character and character:FindFirstChild("Humanoid")
                
                if hrp and hum then
                    if hum.FloorMaterial == Enum.Material.Air then
                        hrp.Orientation = Vector3.new(hrp.Orientation.X, hrp.Orientation.Y + (_SP.Speed * dt), hrp.Orientation.Z)
                    end
                else
                    if _SP.Conn then _SP.Conn:Disconnect() _SP.Conn = nil end
                end
            end)
        end
    end

    local SpinKeybind = Tabs.Misc:AddKeybind("KeybindSpinBot", {
        Title = "Spinbot Keybind",
        Mode = "Click", 
        Default = "RightAlt",
        Callback = function(Key)
            _SP.CurrentKey = toKeyCode(Key)
        end,
    })

    SpinKeybind:OnChanged(function()
        if SpinKeybind.Value then
            _SP.CurrentKey = toKeyCode(SpinKeybind.Value)
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not _SP.CurrentKey or input.KeyCode ~= _SP.CurrentKey then return end

        ToggleSpin(not _SP.Active)
    end)
end

Tabs.Misc:AddParagraph({
    Title = "Use only Emote",
    Content = "Beta! use only 200-100 speed"
})

do
    local _ES = {
        Active = false,
        Speed = 200,
        CurrentKey = Enum.KeyCode.RightShift
    }
    
    local bav = nil
    local EmoteSpinToggleUI = nil

    local function ToggleEmoteSpin(state)
        _ES.Active = state
        
        if EmoteSpinToggleUI and EmoteSpinToggleUI.Set then
            EmoteSpinToggleUI:Set(state, true)
        end
    end

    RunService.RenderStepped:Connect(function()
        local ch = LP.Character
        local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
        
        if not hrp or not _ES.Active then
            if bav then
                bav:Destroy()
                bav = nil
            end
            return
        end

        if not bav or bav.Parent ~= hrp then
            if bav then bav:Destroy() end
            bav = Instance.new("BodyAngularVelocity")
            bav.Parent = hrp
        end

        bav.AngularVelocity = Vector3.new(0, _ES.Speed, 0)
        bav.MaxTorque = Vector3.new(0, 4e5, 0)
    end)

    EmoteSpinToggleUI = Tabs.Misc:AddToggle("EmoteSpinMainToggle", {
        Title = "Enable Emote Spin",
        Default = false,
        Callback = function(v)
            if _ES.Active ~= v then
                ToggleEmoteSpin(v)
            end
        end
    })
    
    local EmoteSpinKeybind = Tabs.Misc:AddKeybind("KeybindEmoteSpin", {
        Title = "Emote Spin Keybind",
        Mode = "Click", 
        Default = "RightShift",
        Callback = function(Key)
            _ES.CurrentKey = toKeyCode(Key)
        end,
    })

    EmoteSpinKeybind:OnChanged(function()
        if EmoteSpinKeybind.Value then
            _ES.CurrentKey = toKeyCode(EmoteSpinKeybind.Value)
        end
    end)
    
    Tabs.Misc:AddInput("EmoteSpinSpeedInput", {
        Title = "Emote Spin Speed",
        Default = tostring(_ES.Speed),
        Numeric = true,
        Finished = true,
        Callback = function(Value)
            _ES.Speed = tonumber(Value) or 200
        end
    })

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not _ES.CurrentKey or input.KeyCode ~= _ES.CurrentKey then return end

        ToggleEmoteSpin(not _ES.Active)
    end)
end


-- Exploits
    
local FakeSection = Tabs.Exploits:AddSection("Pads")

do
    local TeleportModule = {
        SelectedTP = nil,
        AvailableTPs = {},
        LastCount = 0
    }

    local runService = game:GetService("RunService")
    local repStorage = game:GetService("ReplicatedStorage")
    local lp = game.Players.LocalPlayer
    local deployables = workspace:WaitForChild("Game"):WaitForChild("Effects"):WaitForChild("Deployables")
    local event = repStorage:WaitForChild("Events"):WaitForChild("Other"):WaitForChild("DeployableUsed")

    local tpDropdown = Tabs.Exploits:AddDropdown("TeleporterList", {
        Title = "Select Teleporter",
        Values = {"None"},
        Default = 1,
        Callback = function(Value)
            TeleportModule.SelectedTP = Value
        end
    })

    Tabs.Exploits:AddButton({
        Title = "Teleport",
        Description = "Must be standing on a teleporter",
        Callback = function()
            if TeleportModule.SelectedTP and TeleportModule.SelectedTP ~= "None" then
                for _, obj in pairs(deployables:GetChildren()) do
                    if obj.Name == "Teleporter" and tostring(obj:GetDebugId()) == TeleportModule.SelectedTP then
                        event:FireServer(obj)
                        break
                    end
                end
            end
        end
    })

    runService.Heartbeat:Connect(function()
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local nearTP = false
        local currentList = {}
        local foundObjects = deployables:GetChildren()

        for _, obj in pairs(foundObjects) do
            if obj.Name == "Teleporter" then
                local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if primary then
                    local dist = (root.Position - primary.Position).Magnitude
                    if dist < 7 then
                        nearTP = true
                    end
                    table.insert(currentList, tostring(obj:GetDebugId()))
                end
            end
        end

        if nearTP then
            if #currentList ~= TeleportModule.LastCount then
                TeleportModule.LastCount = #currentList
                TeleportModule.AvailableTPs = currentList
                tpDropdown:SetValues(currentList)
            end
        else
            if TeleportModule.LastCount > 0 then
                TeleportModule.LastCount = 0
                TeleportModule.AvailableTPs = {}
                TeleportModule.SelectedTP = nil
                tpDropdown:SetValues({"None"})
            end
        end
    end)
end

do
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local boostEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Character"):WaitForChild("SpeedBoost").OnClientEvent

    local settings = {
        SpeedEnabled = false,
        SpeedValue = 1.3,
        SpeedDuration = 2,
        JumpEnabled = false,
        JumpPower = 50
    }

    local activeConnections = {}
    local lastBoosts = {}

    local function getDeployables()
        local gameDir = workspace:FindFirstChild("Game")
        local effects = gameDir and gameDir:FindFirstChild("Effects")
        return effects and effects:FindFirstChild("Deployables")
    end

    local function handlePad(pad)
        local name = pad.Name:lower()
        local isSpeed = name:find("speed")
        local isJump = name:find("jump")

        if not (isSpeed or isJump) then return end

        activeConnections[pad] = RunService.Heartbeat:Connect(function()
            if not pad.Parent then
                activeConnections[pad]:Disconnect()
                activeConnections[pad] = nil
                lastBoosts[pad] = nil
                return
            end

            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local distance = (hrp.Position - pad:GetPivot().Position).Magnitude

            if isSpeed and settings.SpeedEnabled and distance <= 9 then
                local now = os.clock()
                if now - (lastBoosts[pad] or 0) > 1 then
                    lastBoosts[pad] = now
                    pcall(firesignal, boostEvent, "SpeedPad", settings.SpeedValue, settings.SpeedDuration, Color3.new(0.49, 0.6, 1))
                end
            elseif isJump and settings.JumpEnabled and distance <= 7 then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, settings.JumpPower, hrp.Velocity.Z)
            end
        end)
    end

    local function init()
        for _, conn in pairs(activeConnections) do conn:Disconnect() end
        activeConnections = {}
        
        local container = getDeployables()
        if not container then return end

        for _, pad in ipairs(container:GetChildren()) do
            handlePad(pad)
        end

        if not activeConnections._childAdded then
            activeConnections._childAdded = container.ChildAdded:Connect(function(child)
                task.wait(0.2)
                handlePad(child)
            end)
        end
    end

    Tabs.Exploits:AddToggle("SpeedPadToggle", {
        Title = "SpeedPad Booster",
        Default = false,
        Callback = function(state)
            settings.SpeedEnabled = state
            if state then init() end
        end
    })

    Tabs.Exploits:AddInput("SpeedValueInput", {
        Title = "Speed Multiplier",
        Default = "1.3",
        Numeric = true,
        Callback = function(text) settings.SpeedValue = tonumber(text) or 1.3 end
    })

    Tabs.Exploits:AddInput("SpeedDurationInput", {
        Title = "Duration",
        Default = "2",
        Numeric = true,
        Callback = function(text) settings.SpeedDuration = tonumber(text) or 2 end
    })

    Tabs.Exploits:AddToggle("JumpPadToggle", {
        Title = "Jump Pad Booster",
        Default = false,
        Callback = function(state)
            settings.JumpEnabled = state
            if state then init() end
        end
    })

    Tabs.Exploits:AddInput("JumpInput", {
        Title = "Jump Power",
        Default = "50",
        Numeric = true,
        Callback = function(v) settings.JumpPower = tonumber(v) or 50 end
    })

    player.CharacterAdded:Connect(function()
        task.wait(1)
        if settings.SpeedEnabled or settings.JumpEnabled then init() end
    end)
end

local oldTestHit
local oldTestCollision

Tabs.Exploits:AddToggle("BuildAnywhere", {
    Title = "Pads Build Bypass",
    Description = "All",
    Default = false,
    Callback = function(State)
        local buildModule = getrenv().require(game:GetService("ReplicatedStorage").Modules.Character.Tools.Modules.Methods.Build)        
        if State then
            if not oldTestHit then oldTestHit = buildModule.TestHit end
            if not oldTestCollision then oldTestCollision = buildModule.TestCollision end        
           buildModule.TestHit = function(...)
                return true
            end     
            buildModule.TestCollision = function(...)
                return false, select(2, oldTestCollision(...))
            end
        else
            if oldTestHit then buildModule.TestHit = oldTestHit end
            if oldTestCollision then buildModule.TestCollision = oldTestCollision end
        end
    end
})

local FakeSection = Tabs.Exploits:AddSection("Grenade")

Tabs.Exploits:AddToggle("Revive Grenade Toggle", {
    Title = "Revive Grenade",
    Default = false,
    Callback = function(State)
        pcall(function()
            local ReviveGrenade = require(game:GetService("ReplicatedStorage").Tools["ReviveGrenade"])
            local throwMethod = ReviveGrenade.Tasks[1].Functions[1].Activations[1].Methods[1]
            local equipMethod = ReviveGrenade.Tasks[1].AutomaticFunctions[1].Methods[1]
            local unequipMethod = ReviveGrenade.Tasks[1].AutomaticFunctions[2].Methods[1]

            if State then
                ReviveGrenade.RequiresOwnedItem = false
                throwMethod.ItemUseIncrement = {"ReviveGrenade", 0}
                throwMethod.Info.Cooldown = 0.05
                throwMethod.Info.ThrowVelocity = 200
                ReviveGrenade.Tasks[1].Functions[1].Activations[1].CanHoldDown = true
                throwMethod.Info.SmokeDuration = 999
                throwMethod.Info.SmokeRadius = 100
                throwMethod.Info.FadeTime = 60
                equipMethod.Info.Cooldown = 0.1
                unequipMethod.Info.Cooldown = 0.1
                throwMethod.GlobalPriority = 500
                throwMethod.CooldownInfo = {}
                ReviveGrenade.HUD.ShowAmount = false
                throwMethod.Info.Density = 0.9
                throwMethod.Info.Color = Color3.new(0, 1, 0.5) 
                throwMethod.Info.ExplosionRadius = 20
                throwMethod.CooldownInfo.ActivatePhrase = nil

                local args = {
                    [1] = 0,
                    [2] = 22
                }
                game:GetService("ReplicatedStorage").Events.Character.ToolAction:FireServer(unpack(args))
            else
                
                ReviveGrenade.RequiresOwnedItem = true
                throwMethod.ItemUseIncrement = {"ReviveGrenade", 1}
                throwMethod.Info.Cooldown = 1 
                ReviveGrenade.Tasks[1].Functions[1].Activations[1].CanHoldDown = false
                throwMethod.Info.SmokeDuration = 15 
                throwMethod.Info.SmokeRadius = 15
                ReviveGrenade.HUD.ShowAmount = true
            end
        end)
    end
})

Tabs.Exploits:AddToggle("Smoke Grenade Toggle", {
    Title = "Smoke Grenade",
    Default = false,
    Callback = function(State)
        pcall(function()
            local SmokeGrenade = require(game:GetService("ReplicatedStorage").Tools["SmokeGrenade"])
            local throwMethod = SmokeGrenade.Tasks[1].Functions[1].Activations[1].Methods[1]
            local equipMethod = SmokeGrenade.Tasks[1].AutomaticFunctions[1].Methods[1]
            local unequipMethod = SmokeGrenade.Tasks[1].AutomaticFunctions[2].Methods[1]

            if State then
                SmokeGrenade.RequiresOwnedItem = false  
                throwMethod.ItemUseIncrement = {"SmokeGrenade", 0}
                throwMethod.Info.Cooldown = 0.05  
                throwMethod.Info.ThrowVelocity = 200  
                SmokeGrenade.Tasks[1].Functions[1].Activations[1].CanHoldDown = true  
                throwMethod.Info.SmokeDuration = 999  
                throwMethod.Info.SmokeRadius = 100    
                throwMethod.Info.FadeTime = 60        
                equipMethod.Info.Cooldown = 0.1 
                unequipMethod.Info.Cooldown = 0.1
                throwMethod.GlobalPriority = 500
                throwMethod.CooldownInfo = {}  
                SmokeGrenade.HUD.ShowAmount = false  
                throwMethod.Info.Density = 0.9  
                throwMethod.Info.Color = Color3.new(0.7, 0.7, 0.7)
                throwMethod.Info.ExplosionRadius = 20 
                throwMethod.CooldownInfo.ActivatePhrase = nil 

                local args = {
                    [1] = 0,
                    [2] = 20
                }
                game:GetService("ReplicatedStorage").Events.Character.ToolAction:FireServer(unpack(args))
            else
                
                SmokeGrenade.RequiresOwnedItem = true
                throwMethod.ItemUseIncrement = {"SmokeGrenade", 1}
                throwMethod.Info.Cooldown = 1
                SmokeGrenade.Tasks[1].Functions[1].Activations[1].CanHoldDown = false
                throwMethod.Info.SmokeDuration = 20 
                throwMethod.Info.SmokeRadius = 15
                SmokeGrenade.HUD.ShowAmount = true
            end
        end)
    end
})

do
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local SpeedBoostEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Character"):WaitForChild("SpeedBoost")
    local ColaTool = ReplicatedStorage:WaitForChild("Tools"):FindFirstChild("Cola")
    
    local ColaModule
    pcall(function()
        ColaModule = require(ReplicatedStorage:WaitForChild("Tools"):WaitForChild("Cola"))
    end)

    local ColaModuleTag = ColaTool and ColaTool:GetAttribute("Tag") or nil

    local ColaCheat = {
        FixColaAnimation = true,
        UnlimitedCola = false,
        ModifyStats = true,
        CustomSpeed = 1.4,
        CustomDuration = 3.5
    }

    local function GetCharacter()
        return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    end

    local function GetLPTagValue()
        local char = GetCharacter()
        if char then
            return char:GetAttribute("Tag")
        end
        return nil
    end

    local function GetColaTagValue()
        if ColaTool then
            return ColaTool:GetAttribute("Tag")
        end
        return nil
    end

    local function GetDrinkDelay()
        if not ColaModule then return nil end
        local Tasks = ColaModule.Tasks
        if Tasks and type(Tasks) == "table" then
            for _, task in ipairs(Tasks) do
                local AutomaticFunctions = task.AutomaticFunctions
                if AutomaticFunctions and type(AutomaticFunctions) == "table" then
                    for _, func in ipairs(AutomaticFunctions) do
                        if func.Phrase == "StartDrinking" then
                            local Methods = func.Methods
                            if Methods and type(Methods) == "table" then
                                for _, method in ipairs(Methods) do
                                    local Info = method.Info
                                    if Info and Info.Cooldown then
                                        return Info.Cooldown
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    local function GetSpeedBoostData()
        if not ColaModule then return nil end
        local Tasks = ColaModule.Tasks
        if Tasks and type(Tasks) == "table" then
            for _, task in ipairs(Tasks) do
                local AutomaticFunctions = task.AutomaticFunctions
                if AutomaticFunctions and type(AutomaticFunctions) == "table" then
                    for _, func in ipairs(AutomaticFunctions) do
                        if func.Phrase == "FinishDrink" then
                            local Methods = func.Methods
                            if Methods and type(Methods) == "table" then
                                for _, method in ipairs(Methods) do
                                    local Info = method.Info
                                    if Info then
                                        if ColaCheat.ModifyStats then
                                            return ColaCheat.CustomSpeed, ColaCheat.CustomDuration, Info.Color
                                        else
                                            return Info.SpeedBoost, Info.Duration, Info.Color
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    local function fakecolaspeed()
        local speed, duration, color = GetSpeedBoostData()
        if speed and duration then
            local args = {
                [1] = "Drink",
                [2] = speed,
                [3] = duration,
                [4] = color
            }
            firesignal(SpeedBoostEvent.OnClientEvent, unpack(args))
        end
    end

    local UsePhrase = LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Events"):FindFirstChild("UsePhrase")

    if UsePhrase then
        local parent = UsePhrase.Parent
        local name = UsePhrase.Name

        local newFunction = Instance.new("BindableFunction")
        newFunction.Name = name
        newFunction.Parent = parent

        newFunction.OnInvoke = function(...)
            local args = {...}
            if args[1] and type(args[1]) == "table" and args[1].Phrase == "FinishDrink" then
                if ColaCheat.UnlimitedCola then
                    local tagValue = GetLPTagValue()
                    if tagValue then
                        fakecolaspeed()
                        task.wait(2.25)
                        firesignal(ReplicatedStorage.Events.Character.PassCharacterInfo.OnClientEvent, buffer.fromstring(string.char(tagValue) .. "\18"), { "Weaponless" })
                    else
                        print("No 'Tag' attribute found on character")
                    end
                    return nil
                else
                    if ColaCheat.ModifyStats then
                        firesignal(ReplicatedStorage.Events.Character.SpeedBoost.OnClientEvent, 
                            "Drink",
                            ColaCheat.CustomSpeed,
                            ColaCheat.CustomDuration,
                            Color3.new(0.78039216995239, 0.55294120311737, 0.3647058904171)
                        )
                    end
                    return UsePhrase:Invoke(...)
                end
            end
            return UsePhrase:Invoke(...)
        end

        UsePhrase:Destroy()
    else
        warn("UsePhrase not found, skipping hook")
    end

    local UseKeybind = LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Events"):WaitForChild("temporary_events"):FindFirstChild("UseKeybind")
    if not UseKeybind then
        warn("UseKeybind not found")
    else
        local connections = {}
        for _, conn in ipairs(getconnections(UseKeybind.Event)) do
            table.insert(connections, conn)
        end

        local function newKeyHandler(...)
            local args = {...}
            if ColaCheat.FixColaAnimation == true and args[1] and type(args[1]) == "table" and args[1].Key == "Cola" and args[1].Down == true then
                local colaTag = GetColaTagValue()
                if colaTag then
                    ReplicatedStorage.Events.Character.ToolAction:FireServer(0, colaTag)
                end
                return 
            end
            for _, conn in ipairs(connections) do
                conn.Function(...)
            end
        end

        for _, conn in ipairs(connections) do
            conn:Disconnect()
        end
        UseKeybind.Event:Connect(newKeyHandler)
    end

Tabs.Exploits:AddSection("Cola Adjustments")

    Tabs.Exploits:AddKeybind("ColaKey", {
        Title = "Cola Keybind",
        Mode = "Toggle",
        Default = "C", 
        Callback = function()
            task.spawn(function()
                ReplicatedStorage:WaitForChild("Events"):WaitForChild("Character"):WaitForChild("ToolAction"):FireServer(0, 20)
            end)
        end,
    })

    local featureStates = {
        AutoDrink = false,
        DrinkDelay = 0.5
    }

    local AutoDrinkThread = nil

    local function toggleDrinkLogic(state)
        featureStates.AutoDrink = state
        
        if AutoDrinkThread then 
            task.cancel(AutoDrinkThread) 
            AutoDrinkThread = nil 
        end

        if state then
            AutoDrinkThread = task.spawn(function()
                while featureStates.AutoDrink do
                    pcall(function()
                        local ev = LocalPlayer.PlayerScripts.Events.temporary_events.UseKeybind
                        ev:Fire({
                            ["Forced"] = true,
                            ["Key"] = "Cola",
                            ["Down"] = true
                        })
                    end)
                    task.wait(featureStates.DrinkDelay)
                end
            end)
        end
    end

    Tabs.Exploits:AddToggle("AutoDrinkToggle", {
        Title = "Auto Drink Cola",
        Default = false,
        Callback = function(state)
            toggleDrinkLogic(state)
        end
    })

    Tabs.Exploits:AddInput("DrinkDelayInput", {
        Title = "Drink Delay (seconds)",
        Default = "0.5",
        Numeric = true,
        Finished = false,
        Callback = function(Value)
            local num = tonumber(Value)
            if num and num > 0 then
                featureStates.DrinkDelay = num
            end
        end
    })

    Tabs.Exploits:AddParagraph({
        Title = " ",
        Content = ""
    })

    Tabs.Exploits:AddToggle("UnlimitedColaToggle", {
        Title = "Infinite Cola",
        Description = "",
        Default = false,
        Callback = function(state)
            ColaCheat.UnlimitedCola = state
        end
    })

    Tabs.Exploits:AddInput("ColaSpeedInput", {
        Title = "Speed Value",
        Description = "",
        Default = "1.4",
        Placeholder = "1.4",
        Numeric = true,
        Callback = function(value)
            local num = tonumber(value)
            if num and num > 0 then
                ColaCheat.CustomSpeed = num
            end
        end
    })

    Tabs.Exploits:AddInput("ColaDurationInput", {
        Title = "Duration",
        Description = "",
        Default = "3.5",
        Placeholder = "3.5",
        Numeric = true,
        Callback = function(value)
            local num = tonumber(value)
            if num and num > 0 then
                ColaCheat.CustomDuration = num
            end
        end
    })
end



-- Visuals

Tabs.Visual:AddSection("Character")

do 
    local currentCarryAnim = ""
    local selectedCarryAnim = ""
    local lastCurrentCarryAnim = ""
    local lastSelectedCarryAnim = ""
    local isSwapped = false

    local function normalizeString(str)
        return str:gsub("%s+", ""):lower()
    end

    local function isValidCarryAnimation(name)
        local itemsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Items")
        if not itemsFolder then return false end
        
        local carryAnimsFolder = itemsFolder:FindFirstChild("CarryAnimations")
        if not carryAnimsFolder then return false end
        
        local normalizedInput = normalizeString(name)
        for _, anim in ipairs(carryAnimsFolder:GetChildren()) do
            if normalizeString(anim.Name) == normalizedInput then
                return true, anim.Name
            end
        end
        return false
    end

    local function revertPreviousSwap()
        if lastCurrentCarryAnim ~= "" and lastSelectedCarryAnim ~= "" and isSwapped then
            local itemsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Items")
            if itemsFolder then
                local carryAnimsFolder = itemsFolder:FindFirstChild("CarryAnimations")
                if carryAnimsFolder then
                    local lastCurrentValid, lastCurrentActual = isValidCarryAnimation(lastCurrentCarryAnim)
                    local lastSelectedValid, lastSelectedActual = isValidCarryAnimation(lastSelectedCarryAnim)
                    
                    if lastCurrentValid and lastSelectedValid then
                        pcall(function()
                            local currentFolder = carryAnimsFolder:FindFirstChild(lastCurrentActual)
                            local selectedFolder = carryAnimsFolder:FindFirstChild(lastSelectedActual)
                            
                            if currentFolder and selectedFolder then
                                local tempRoot = Instance.new("Folder")
                                tempRoot.Name = "__temp_revert_swap_" .. tostring(tick()):gsub("%.", "_")
                                tempRoot.Parent = carryAnimsFolder
                                
                                local tempCurrent = Instance.new("Folder")
                                tempCurrent.Name = "tempCurrent"
                                tempCurrent.Parent = tempRoot
                                
                                local tempSelected = Instance.new("Folder")
                                tempSelected.Name = "tempSelected"
                                tempSelected.Parent = tempRoot
                                
                                for _, child in ipairs(currentFolder:GetChildren()) do
                                    child.Parent = tempCurrent
                                end
                                
                                for _, child in ipairs(selectedFolder:GetChildren()) do
                                    child.Parent = tempSelected
                                end
                                
                                for _, child in ipairs(tempCurrent:GetChildren()) do
                                    child.Parent = selectedFolder
                                end
                                
                                for _, child in ipairs(tempSelected:GetChildren()) do
                                    child.Parent = currentFolder
                                end
                                
                                tempRoot:Destroy()
                            end
                        end)
                    end
                end
            end
            isSwapped = false
        end
    end

    local CurrentCarryAnimInput = Tabs.Visual:AddInput("CurrentCarryAnimInput", {
        Title = "Current CarryAnimation",
        Default = "",
        Placeholder = "Enter current carry animation name",
        Finished = false,
        Callback = function(Value)
            if Value ~= currentCarryAnim and currentCarryAnim ~= "" then
                revertPreviousSwap()
            end
            currentCarryAnim = Value
        end
    })

    local SelectedCarryAnimInput = Tabs.Visual:AddInput("SelectedCarryAnimInput", {
        Title = "Selected CarryAnimation",
        Default = "",
        Placeholder = "Enter selected carry animation name",
        Finished = false,
        Callback = function(Value)
            if Value ~= selectedCarryAnim and selectedCarryAnim ~= "" then
                revertPreviousSwap()
            end
            selectedCarryAnim = Value
        end
    })

    local ApplyCarryAnimButton = Tabs.Visual:AddButton({
        Title = "Apply CarryAnimation Swap",
        Callback = function()
            local currentNorm = normalizeString(currentCarryAnim)
            local selectedNorm = normalizeString(selectedCarryAnim)
            
            if currentNorm == "" or selectedNorm == "" then
                return
            end
            
            if currentNorm == selectedNorm then
                return
            end
            
            local itemsFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Items")
            if not itemsFolder then
                return
            end
            
            local carryAnimsFolder = itemsFolder:FindFirstChild("CarryAnimations")
            if not carryAnimsFolder then
                return
            end
            
            local currentAnim, currentActualName = isValidCarryAnimation(currentCarryAnim)
            local selectedAnim, selectedActualName = isValidCarryAnimation(selectedCarryAnim)
            
            if not currentAnim then
                return
            end
            
            if not selectedAnim then
                return
            end
            
            pcall(function()
                revertPreviousSwap()
                
                local currentFolder = carryAnimsFolder:FindFirstChild(currentActualName)
                local selectedFolder = carryAnimsFolder:FindFirstChild(selectedActualName)
                
                if not currentFolder or not selectedFolder then
                    return
                end
                
                local tempRoot = Instance.new("Folder")
                tempRoot.Name = "__temp_carry_swap_" .. tostring(tick()):gsub("%.", "_")
                tempRoot.Parent = carryAnimsFolder
                
                local tempCurrent = Instance.new("Folder")
                tempCurrent.Name = "tempCurrent"
                tempCurrent.Parent = tempRoot
                
                local tempSelected = Instance.new("Folder")
                tempSelected.Name = "tempSelected"
                tempSelected.Parent = tempRoot
                
                for _, child in ipairs(currentFolder:GetChildren()) do
                    child.Parent = tempCurrent
                end
                
                for _, child in ipairs(selectedFolder:GetChildren()) do
                    child.Parent = tempSelected
                end
                
                for _, child in ipairs(tempCurrent:GetChildren()) do
                    child.Parent = selectedFolder
                end
                
                for _, child in ipairs(tempSelected:GetChildren()) do
                    child.Parent = currentFolder
                end
                
                tempRoot:Destroy()
                
                lastCurrentCarryAnim = currentCarryAnim
                lastSelectedCarryAnim = selectedCarryAnim
                isSwapped = true
            end)
        end
    })

    local ResetCarryAnimButton = Tabs.Visual:AddButton({
        Title = "Reset All CarryAnimations",
        Callback = function()
            revertPreviousSwap()
            currentCarryAnim = ""
            selectedCarryAnim = ""
            lastCurrentCarryAnim = ""
            lastSelectedCarryAnim = ""
            isSwapped = false
            CurrentCarryAnimInput:SetValue("")
            SelectedCarryAnimInput:SetValue("")
        end
    })
end

Tabs.Visual:AddParagraph({
        Title = " ",
        Content = ""
    })

local nametagValues = {"Ignore", "None"}
local nametagsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Items"):WaitForChild("Nametags")

for _, mod in ipairs(nametagsFolder:GetChildren()) do
    local success, data = pcall(require, mod)
    if success and data.AppearanceInfo then
        table.insert(nametagValues, data.AppearanceInfo.Name)
    end
end

local TagDropdown = Tabs.Visual:AddDropdown("VisualNametag", {
    Title = "Visual Nametag",
    Values = nametagValues,
    Default = "Ignore",
    Callback = function(Value)
        local folder = workspace.Game.Players:FindFirstChild(game.Players.LocalPlayer.Name)
        if folder then
            if Value == "None" then
                folder:SetAttribute("Nametag", nil)
            elseif Value ~= "Ignore" then
                folder:SetAttribute("Nametag", Value:gsub("%s+", ""))
            end
        end
    end
})

game:GetService("RunService").Heartbeat:Connect(function()
    local val = TagDropdown.Value
    if val and val ~= "Ignore" then
        local folder = workspace.Game.Players:FindFirstChild(game.Players.LocalPlayer.Name)
        if folder then
            local clean = (val == "None") and nil or val:gsub("%s+", "")
            if folder:GetAttribute("Nametag") ~= clean then
                folder:SetAttribute("Nametag", clean)
            end
        end
    end
end)

local FakeSection = Tabs.Visual:AddSection("Fake Statistics")

local streakValue = 0

FakeSection:AddInput("StreakInput", {
    Title = "Enter Streak Amount",
    Default = "0",
    Placeholder = "Number",
    NumericOnly = true,
    Callback = function(Value)
        streakValue = tonumber(Value)
    end
})

FakeSection:AddButton({
    Title = "Apply Fake Streak",
    Description = "",
    Callback = function()
        if streakValue then
            game:GetService("Players").LocalPlayer:SetAttribute("Streak", streakValue)
        end
    end
})

local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local debris = game:GetService("Debris")
local lastPos = Vector3.new(0,0,0)

Tabs.Visual:AddSection("Cosmetics Changer")
    
 Tabs.Visual:AddInput("O_C1", {
        Title = "Current Cosmetics 1",
        Default = " ",
        Placeholder = "",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Visual.OriginalCosmetics.Cosmetics1 = Value
        end
    })
    
 Tabs.Visual:AddInput("O_C2", {
        Title = "Current Cosmetics 2",
        Default = " ",
        Placeholder = "",
        Numeric = false,
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Visual.OriginalCosmetics.Cosmetics2 = Value
        end
    })
    
 Tabs.Visual:AddInput("O_C3", {
        Title = "Current Effect",
        Default = " ",
        Placeholder = "",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Visual.OriginalCosmetics.Cosmetics3 = Value
        end
    })
    
 Tabs.Visual:AddInput("O_C4", {
        Title = "Current Character",
        Default = " ",
        Placeholder = "",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Visual.OriginalCosmetics.Cosmetics4 = Value
        end
    })

Tabs.Visual:AddParagraph({
        Title = " ",
        Content = ""
    })
    
 Tabs.Visual:AddInput("M_C1", {
        Title = "Select Cosmetics 1",
        Default = " ",
        Placeholder = "",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Visual.ModifyCosmetics.Cosmetics1 = Value
        end
    })
    
 Tabs.Visual:AddInput("M_C2", {
        Title = "Select Cosmetics 2",
        Default = " ",
        Placeholder = "",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Visual.ModifyCosmetics.Cosmetics2 = Value
        end
    })
    
 Tabs.Visual:AddInput("M_C3", {
        Title = "Select Effect",
        Default = " ",
        Placeholder = "",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Visual.ModifyCosmetics.Cosmetics3 = Value
        end
    })
    
 Tabs.Visual:AddInput("M_C4", {
        Title = "Select Character",
        Default = " ",
        Placeholder = "",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Visual.ModifyCosmetics.Cosmetics4 = Value
        end
    })
    
Tabs.Visual:AddButton({
        Title = "Apply Cosmetics",
        Description = "" ,
        Callback = function()
          spawn(function()
             DFunctions.RestoreCosmetics()
             wait(0.1)
             DFunctions.ChangeCosmetics(DConfiguration.Visual.OriginalCosmetics.Cosmetics1, DConfiguration.Visual.ModifyCosmetics.Cosmetics1)
             DFunctions.ChangeCosmetics(DConfiguration.Visual.OriginalCosmetics.Cosmetics2, DConfiguration.Visual.ModifyCosmetics.Cosmetics2)
             DFunctions.ChangeCosmetics(DConfiguration.Visual.OriginalCosmetics.Cosmetics3, DConfiguration.Visual.ModifyCosmetics.Cosmetics3)
             DFunctions.ChangeCosmetics(DConfiguration.Visual.OriginalCosmetics.Cosmetics4, DConfiguration.Visual.ModifyCosmetics.Cosmetics4)
           end)
        end
    })

Tabs.Visual:AddButton({
        Title = "Restore Cosmetics",
        Description = "" ,
        Callback = function()
          spawn(function()
             DFunctions.RestoreCosmetics()
           end)
        end
    })
    
Tabs.Visual:AddSection("Color Effect")

do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    DConfiguration = DConfiguration or {}
    DConfiguration.Visual = DConfiguration.Visual or {}
    DConfiguration.Visual.ModifyCosmetics = DConfiguration.Visual.ModifyCosmetics or {}
    
    if DConfiguration.Visual.ModifyCosmetics.SelectedColor == nil then
        DConfiguration.Visual.ModifyCosmetics.SelectedColor = Color3.fromRGB(0, 255, 120)
    end
    if DConfiguration.Visual.ModifyCosmetics.Thickness == nil then
        DConfiguration.Visual.ModifyCosmetics.Thickness = 1
    end
    if DConfiguration.Visual.ModifyCosmetics.Brightness == nil then
        DConfiguration.Visual.ModifyCosmetics.Brightness = 1
    end
    if DConfiguration.Visual.ModifyCosmetics.BrightnessEnabled == nil then
        DConfiguration.Visual.ModifyCosmetics.BrightnessEnabled = false
    end

    local originalColors = {}
    local originalSizes = {}
    local originalGlow = {}
    local affectedObjects = {}
    local rainbowConnection = nil
    local rainbowSpeed = 1
    local hue = 0

    local function isVisualEffect(object)
        return object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam") or object:IsA("Light") or object:IsA("SelectionBox")
    end

    local function createRainbowSequence()
        return ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
            ColorSequenceKeypoint.new(0.2, Color3.fromHSV(0.2, 1, 1)),
            ColorSequenceKeypoint.new(0.4, Color3.fromHSV(0.4, 1, 1)),
            ColorSequenceKeypoint.new(0.6, Color3.fromHSV(0.6, 1, 1)),
            ColorSequenceKeypoint.new(0.8, Color3.fromHSV(0.8, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
        })
    end

    local function applyGlowProps(object)
        if DConfiguration.Visual.ModifyCosmetics.BrightnessEnabled then
            local targetGlow = DConfiguration.Visual.ModifyCosmetics.Brightness
            pcall(function()
                if object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam") then
                    if not originalGlow[object] then
                        originalGlow[object] = object.LightEmission
                    end
                    object.LightEmission = targetGlow
                elseif object:IsA("Light") then
                    if not originalGlow[object] then
                        originalGlow[object] = object.Brightness
                    end
                    object.Brightness = targetGlow
                end
            end)
        end
    end

    local function applyThickness(object, multiplier)
        pcall(function()
            if object:IsA("Trail") or object:IsA("Beam") then
                if not originalSizes[object] then
                    originalSizes[object] = {w0 = object.Width0, w1 = object.Width1}
                end
                object.Width0 = originalSizes[object].w0 * multiplier
                object.Width1 = originalSizes[object].w1 * multiplier
            elseif object:IsA("ParticleEmitter") then
                if not originalSizes[object] then
                    originalSizes[object] = {size = object.Size}
                end
                if typeof(originalSizes[object].size) == "NumberSequence" then
                    local keypoints = {}
                    table.foreachi(originalSizes[object].size.Keypoints, function(_, kp)
                        table.insert(keypoints, NumberSequenceKeypoint.new(kp.Time, math.clamp(kp.Value * multiplier, 0, 100)))
                    end)
                    object.Size = NumberSequence.new(keypoints)
                else
                    object.Size = originalSizes[object].size * multiplier
                end
            end
        end)
    end

    local function applySingleDynamic(newColor, sequence, _, object)
        if object and object.Parent then
            pcall(function()
                if object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam") then
                    object.Color = sequence
                else
                    object.Color = newColor
                end
            end)
            applyThickness(object, DConfiguration.Visual.ModifyCosmetics.Thickness)
            applyGlowProps(object)
        end
    end

    local function applyDynamicRainbow(newColor)
        local sequence = ColorSequence.new(newColor)
        table.foreachi(affectedObjects, function(index, object)
            applySingleDynamic(newColor, sequence, index, object)
        end)
    end

    local function checkAndApplyStatic(object)
        if isVisualEffect(object) or object:IsA("BasePart") then
            if not object:IsA("BasePart") or (object:IsA("BasePart") and not object.Parent:IsA("Model") and object.Name ~= "HumanoidRootPart") then
                table.insert(affectedObjects, object)
                if not originalColors[object] then
                    originalColors[object] = object.Color
                end

                pcall(function()
                    if object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam") then
                        object.Color = createRainbowSequence()
                    else
                        object.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                    end
                end)
                applyThickness(object, DConfiguration.Visual.ModifyCosmetics.Thickness)
                applyGlowProps(object)
            end
        end
    end

    local function checkAndApplyNormal(object)
        if isVisualEffect(object) or object:IsA("BasePart") then
            if not object:IsA("BasePart") or (object:IsA("BasePart") and not object.Parent:IsA("Model") and object.Name ~= "HumanoidRootPart") then
                table.insert(affectedObjects, object)
                if not originalColors[object] then
                    originalColors[object] = object.Color
                end

                pcall(function()
                    if object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam") then
                        object.Color = ColorSequence.new(DConfiguration.Visual.ModifyCosmetics.SelectedColor)
                    else
                        object.Color = DConfiguration.Visual.ModifyCosmetics.SelectedColor
                    end
                end)
                applyThickness(object, DConfiguration.Visual.ModifyCosmetics.Thickness)
                applyGlowProps(object)
            end
        end
    end

    local function cacheOnly(object)
        if isVisualEffect(object) or object:IsA("BasePart") then
            if not object:IsA("BasePart") or (object:IsA("BasePart") and not object.Parent:IsA("Model") and object.Name ~= "HumanoidRootPart") then
                table.insert(affectedObjects, object)
                if not originalColors[object] then
                    originalColors[object] = object.Color
                end
            end
        end
    end

    local function updateObjectsWithAction(character, actionFunc)
        table.clear(affectedObjects)
        if not character then return end
        table.foreachi(character:GetDescendants(), function(_, obj) actionFunc(obj) end)
    end

    local function stopDynamicRainbow()
        if rainbowConnection then
            rainbowConnection:Disconnect()
            rainbowConnection = nil
        end
    end

    local function startDynamicRainbow()
        stopDynamicRainbow()
        updateObjectsWithAction(LocalPlayer.Character, cacheOnly)
        
        rainbowConnection = RunService.Heartbeat:Connect(function(deltaTime)
            if DConfiguration.Visual.ModifyCosmetics.ToggleEnabled and DConfiguration.Visual.ModifyCosmetics.DynamicRainbowEnabled then
                hue = (hue + deltaTime * (rainbowSpeed * 0.1)) % 1
                applyDynamicRainbow(Color3.fromHSV(hue, 1, 1))
            end
        end)
    end

    local function refreshVisuals()
        stopDynamicRainbow()
        if not DConfiguration.Visual.ModifyCosmetics.ToggleEnabled then
            table.foreach(originalColors, function(obj, col) 
                pcall(function() if obj and obj.Parent then obj.Color = col end end) 
            end)
            table.foreach(originalSizes, function(obj, sizeData)
                pcall(function()
                    if obj and obj.Parent then
                        if obj:IsA("Trail") or obj:IsA("Beam") then
                            obj.Width0 = sizeData.w0
                            obj.Width1 = sizeData.w1
                        elseif obj:IsA("ParticleEmitter") then
                            obj.Size = sizeData.size
                        end
                    end
                end)
            end)
            table.foreach(originalGlow, function(obj, glowVal)
                pcall(function()
                    if obj and obj.Parent then
                        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                            obj.LightEmission = glowVal
                        elseif obj:IsA("Light") then
                            obj.Brightness = glowVal
                        end
                    end
                end)
            end)
            table.clear(originalColors)
            table.clear(originalSizes)
            table.clear(originalGlow)
            table.clear(affectedObjects)
            return
        end

        if DConfiguration.Visual.ModifyCosmetics.DynamicRainbowEnabled then
            startDynamicRainbow()
        elseif DConfiguration.Visual.ModifyCosmetics.StaticRainbowEnabled then
            updateObjectsWithAction(LocalPlayer.Character, checkAndApplyStatic)
        else
            updateObjectsWithAction(LocalPlayer.Character, checkAndApplyNormal)
        end
    end

    LocalPlayer.CharacterAdded:Connect(function(character)
        if DConfiguration.Visual.ModifyCosmetics.ToggleEnabled then
            task.wait(0.5)
            refreshVisuals()
        end
    end)

    Tabs.Visual:AddToggle("CosmeticsToggle", {
        Title = "Enable Custom Color",
        Default = false,
        Callback = function(Value)
            DConfiguration.Visual.ModifyCosmetics.ToggleEnabled = Value
            refreshVisuals()
        end
    })

    Tabs.Visual:AddColorpicker("EffectColor", {
        Title = "Effect Color",
        Default = DConfiguration.Visual.ModifyCosmetics.SelectedColor,
        Callback = function(Value)
            DConfiguration.Visual.ModifyCosmetics.SelectedColor = Value
            if DConfiguration.Visual.ModifyCosmetics.ToggleEnabled and not DConfiguration.Visual.ModifyCosmetics.StaticRainbowEnabled and not DConfiguration.Visual.ModifyCosmetics.DynamicRainbowEnabled then
                refreshVisuals()
            end
        end
    })

    Tabs.Visual:AddInput("ThicknessInput", {
        Title = "Effects Size",
        Default = "1",
        Placeholder = "1",
        Numeric = true,
        Finished = false,
        Callback = function(Value)
            local num = tonumber(Value)
            if num then
                DConfiguration.Visual.ModifyCosmetics.Thickness = num
                if DConfiguration.Visual.ModifyCosmetics.ToggleEnabled then
                    refreshVisuals()
                end
            end
        end
    })

    Tabs.Visual:AddToggle("StaticRainbowToggle", {
        Title = "Static Rainbow (No Lag)",
        Default = false,
        Callback = function(Value)
            DConfiguration.Visual.ModifyCosmetics.StaticRainbowEnabled = Value
            if Value then
                DConfiguration.Visual.ModifyCosmetics.DynamicRainbowEnabled = false
            end
            refreshVisuals()
        end
    })

    Tabs.Visual:AddToggle("DynamicRainbowToggle", {
        Title = "Dynamic Rainbow (Laggy)",
        Default = false,
        Callback = function(Value)
            DConfiguration.Visual.ModifyCosmetics.DynamicRainbowEnabled = Value
            if Value then
                DConfiguration.Visual.ModifyCosmetics.StaticRainbowEnabled = false
            end
            refreshVisuals()
        end
    })

    Tabs.Visual:AddInput("RainbowSpeedInput", {
        Title = "Rainbow Speed",
        Default = "1",
        Placeholder = "",
        Numeric = true,
        Finished = false,
        Callback = function(Value)
            local num = tonumber(Value)
            if num then
                rainbowSpeed = num
            end
        end
    })
end

Tabs.Visual:AddSection("Emote Changer")

Tabs.Visual:AddInput("O_E1", {
    Title = "Current Emote 1",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.OriginalEmotes.Emote1 = Value
    end
})

Tabs.Visual:AddInput("O_E2", {
    Title = "Current Emote 2",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.OriginalEmotes.Emote2 = Value
    end
})

Tabs.Visual:AddInput("O_E3", {
    Title = "Current Emote 3",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.OriginalEmotes.Emote3 = Value
    end
})

Tabs.Visual:AddInput("O_E4", {
    Title = "Current Emote 4",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.OriginalEmotes.Emote4 = Value
    end
})

Tabs.Visual:AddInput("O_E5", {
    Title = "Current Emote 5",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.OriginalEmotes.Emote5 = Value
    end
})

Tabs.Visual:AddInput("O_E6", {
    Title = "Current Emote 6",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.OriginalEmotes.Emote6 = Value
    end
})

Tabs.Visual:AddInput("O_E7", {
    Title = "Current Emote 7",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.OriginalEmotes.Emote7 = Value
    end
})

Tabs.Visual:AddInput("O_E8", {
    Title = "Current Emote 8",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.OriginalEmotes.Emote8 = Value
    end
})

Tabs.Visual:AddInput("O_E9", {
    Title = "Current Emote 9",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.OriginalEmotes.Emote9 = Value
    end
})

Tabs.Visual:AddInput("O_E10", {
    Title = "Current Emote 10",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.OriginalEmotes.Emote10 = Value
    end
})

Tabs.Visual:AddInput("O_E11", {
    Title = "Current Emote 11",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.OriginalEmotes.Emote11 = Value
    end
})

Tabs.Visual:AddInput("O_E12", {
    Title = "Current Emote 12",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.OriginalEmotes.Emote12 = Value
    end
})

Tabs.Visual:AddParagraph({
    Title = " ",
    Content = ""
})

Tabs.Visual:AddInput("M_E1", {
    Title = "Select Emote 1",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.ModifyEmotes.Emote1 = Value
    end
})

Tabs.Visual:AddInput("M_E2", {
    Title = "Select Emote 2",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.ModifyEmotes.Emote2 = Value
    end
})

Tabs.Visual:AddInput("M_E3", {
    Title = "Select Emote 3",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.ModifyEmotes.Emote3 = Value
    end
})

Tabs.Visual:AddInput("M_E4", {
    Title = "Select Emote 4",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.ModifyEmotes.Emote4 = Value
    end
})

Tabs.Visual:AddInput("M_E5", {
    Title = "Select Emote 5",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.ModifyEmotes.Emote5 = Value
    end
})

Tabs.Visual:AddInput("M_E6", {
    Title = "Select Emote 6",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.ModifyEmotes.Emote6 = Value
    end
})

Tabs.Visual:AddInput("M_E7", {
    Title = "Select Emote 7",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.ModifyEmotes.Emote7 = Value
    end
})

Tabs.Visual:AddInput("M_E8", {
    Title = "Select Emote 8",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.ModifyEmotes.Emote8 = Value
    end
})

Tabs.Visual:AddInput("M_E9", {
    Title = "Select Emote 9",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.ModifyEmotes.Emote9 = Value
    end
})

Tabs.Visual:AddInput("M_E10", {
    Title = "Select Emote 10",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.ModifyEmotes.Emote10 = Value
    end
})

Tabs.Visual:AddInput("M_E11", {
    Title = "Select Emote 11",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.ModifyEmotes.Emote11 = Value
    end
})

Tabs.Visual:AddInput("M_E12", {
    Title = "Select Emote 12",
    Default = "",
    Placeholder = "",
    Numeric = false,
    Finished = false,
    Callback = function(Value)
        DConfiguration.Visual.ModifyEmotes.Emote12 = Value
    end
})

local Dropdown = Tabs.Visual:AddDropdown("EmoteOption", {
    Title = "Select Animation Type",
    Values = {"A", "B", "C", "D"},
    Multi = false,
    Default = 1,
})

Dropdown:OnChanged(function(Value)
    SelectedVersion = Value
end)

Tabs.Visual:AddButton({
    Title = "Change Emotes",
    Description = "",
    Callback = function()
        task.spawn(function()
            DFunctions.ResetEmoteChanges() 
            task.wait(0.1)
            DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote1, DConfiguration.Visual.ModifyEmotes.Emote1)
            DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote2, DConfiguration.Visual.ModifyEmotes.Emote2)
            DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote3, DConfiguration.Visual.ModifyEmotes.Emote3)
            DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote4, DConfiguration.Visual.ModifyEmotes.Emote4)
            DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote5, DConfiguration.Visual.ModifyEmotes.Emote5)
            DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote6, DConfiguration.Visual.ModifyEmotes.Emote6)
            DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote7, DConfiguration.Visual.ModifyEmotes.Emote7)
            DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote8, DConfiguration.Visual.ModifyEmotes.Emote8)
            DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote9, DConfiguration.Visual.ModifyEmotes.Emote9)
            DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote10, DConfiguration.Visual.ModifyEmotes.Emote10)
            DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote11, DConfiguration.Visual.ModifyEmotes.Emote11)
            DFunctions.ChangeEmotes(DConfiguration.Visual.OriginalEmotes.Emote12, DConfiguration.Visual.ModifyEmotes.Emote12)
        end)
    end
})

Tabs.Visual:AddButton({
    Title = "Restore Emotes",
    Description = "Having Trouble?",
    Callback = function()
        DFunctions.ResetEmoteChanges() 
    end
})
    
-- info

Tabs.Info:AddParagraph({
        Title = "PhantomWyrm Hub X / Overhaul Script",
        Content = "Created By Carey"
    })
    
Tabs.Info:AddParagraph({
        Title = "Adjustments / Movement Modification",
        Content = "Created By Carey"
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

-- Extension 

Tabs.Extension:AddSection("Character Extension")

Tabs.Extension:AddToggle("KorbloxRToggle", {
    Title = "Korblox (Right)",
    Default = false,
    Callback = function(Value)
        DFunctions.KorbloxR = Value
        DFunctions.UpdateVisuals()
    end
})

Tabs.Extension:AddToggle("KorbloxLToggle", {
    Title = "Korblox (Left)",
    Default = false,
    Callback = function(Value)
        DFunctions.KorbloxL = Value
        DFunctions.UpdateVisuals()
    end
})

Tabs.Extension:AddToggle("HeadlessToggle", {
    Title = "Headless",
    Default = false,
    Callback = function(Value)
        DFunctions.Headless = Value
        DFunctions.UpdateVisuals()
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
    
do 
    Tabs.Extension:AddToggle("RemoveAccs", {Title = "Remove Accessories", Default = false})

    task.spawn(function()
        while task.wait(0.2) do
            if Fluent.Options.RemoveAccs.Value then
                local lp = game:GetService("Players").LocalPlayer
                if lp and lp.Character then
                    for _, v in ipairs(lp.Character:GetChildren()) do
                        if v:IsA("Accessory") then
                            v:Destroy()
                        end
                    end
                end
            end
        end
    end)
end

Tabs.Extension:AddButton({
    Title = "AvatarChanger",
    Description = "",
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

        
Tabs.Extension:AddSection("Ambient Extension")

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

do
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
end


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
                -- made by guesttester_1 (pls credit to me)
                -- i forgot to add remove textures script

                setfpscap(900) -- normal fps cap for other executors

                setfflag("TaskSchedulerTargetFps", "900") -- for setfpscap unc missing or unsupported for executors

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
                    --    removeEffects()
                    --    removeExplosions()
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
SaveManager:SetFolder("PhantomWyrmXUniversal/Evade")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

-- Auto Load Configuration
SaveManager:LoadAutoloadConfig()

-- ⬇ ️Heart PhantomWyrmHub ⬇ ️

local IsPCMode = false

LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
    if child.Name == "Shared" then
        IsCurrentPlaying = true
    end
end)

if UserInputService.TouchEnabled then
    local returnValues = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Character"):WaitForChild("CharacterTable"):WaitForChild("CharacterController"):WaitForChild("Local"):WaitForChild("Movement"):WaitForChild("returnValues"))
	local old = returnValues.new        
        
	returnValues.new = function(...)
		local result = {old(...)}
		
		task.delay(1, function()
			table.clear(CurrentAdjustment)

			local unpacked = table.unpack(result)
			for i, v in pairs(unpacked) do
				if i == "overrideMovementStats" or i == "defaultMovementStats" then
					table.insert(CurrentAdjustment, v)
				end
			end

			if #CurrentAdjustment > 0 then
				DFunctions.SetPreviousAdjustment()
			end
		end)

		return table.unpack(result)
	end
else
	IsPCMode = true
end

local lastRespawn = 0
local debounceDuration = 1

LocalPlayer.CharacterAdded:Connect(function(character)
	lastRespawn = tick()
	IsCurrentPlaying = true

	task.delay(3, function()
		if IsPCMode and LocalPlayer.Character then
			table.clear(CurrentAdjustment)
			DFunctions.GetAdjustments()
			task.wait(1)
			if #CurrentAdjustment > 0 then
				DFunctions.SetPreviousAdjustment()
			end
		end

		if tick() - lastRespawn >= debounceDuration then
		    repeat task.wait(1) until LocalPlayer.PlayerGui:FindFirstChild("Shared")
		    DFunctions.RestoreEmoteChanges()
		end
	end)

	character.Destroying:Connect(function()
		if IsCurrentPlaying then
			IsCurrentPlaying = false
			DFunctions.ResetEmoteChanges()
		end
	end)
end)

if LocalPlayer.Character then
    DFunctions.GetAdjustments()
    IsCurrentPlaying = true
end

spawn(function()
	local wasHolding = false

	while task.wait(0.1) do
		if #CurrentAdjustment > 0 then
			DFunctions.setTSpeed(DConfiguration.Misc.PlayerAdjustment.Update.Speed)
			DFunctions.setStrafeAcceleration(DConfiguration.Misc.PlayerAdjustment.Update.AirStrafe)
			DFunctions.setTJump(DConfiguration.Misc.PlayerAdjustment.Update.JumpHeight)
			DFunctions.setTJumpCap(DConfiguration.Misc.PlayerAdjustment.Update.JumpCap)
			DFunctions.setTFriction(DConfiguration.Misc.PlayerAdjustment.Update.GroundAcceleration)
			DFunctions.setTJumpAcceleration(DConfiguration.Misc.PlayerAdjustment.Update.JumpAcceleration)
		end
		
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			wasHolding = true
			DConfiguration.Misc.MovementModification.BHOP.Enabled = true
			task.spawn(DFunctions.BHOPFunction)
		else
			if wasHolding then
				wasHolding = false
				DConfiguration.Misc.MovementModification.BHOP.Enabled = false
				task.spawn(DFunctions.ResetBHOP)
			end
		end
	end
end)
