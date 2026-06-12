-- Place your Discord server invite code here local InviteCode="Invite Code"


local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local InviteCode = "scriptblox-954089188825894943"
local DiscordApi = "https://discord.com/api/v10/invites/" .. InviteCode .. "?with_counts=true&with_expiration=true"

local ReqFunc = (syn and syn.request) or (http and http.request) or http_request or request

local function FetchDiscordData()
    local Success, Result = pcall(function()
        if ReqFunc then
            local Res = ReqFunc({
                Url = DiscordApi,
                Method = "GET",
                Headers = {
                    ["User-Agent"] = "RobloxBot/1.0",
                    ["Accept"] = "application/json"
                }
            })
            if Res and Res.Body and #Res.Body > 2 then
                return HttpService:JSONDecode(Res.Body)
            end
        end
        local Remote = game:GetService("ReplicatedStorage"):FindFirstChild("GetDiscordInviteData")
        if Remote then return Remote:InvokeServer(InviteCode) end
    end)
    return Success, Result
end

local function LoadServerIcon(GuildId, IconHash, IconImg, IconBg, FallbackText)
    if not GuildId or not IconHash or IconHash == "" then return end
    task.spawn(function()
        local IconUrl = "https://cdn.discordapp.com/icons/" .. tostring(GuildId) .. "/" .. IconHash .. ".png?size=128"
        local FileName = "discord_icon_" .. tostring(GuildId) .. ".png"

        local Ok = pcall(function()
            if not ReqFunc then error("no request func") end

            local Res = ReqFunc({
                Url = IconUrl,
                Method = "GET",
                Headers = {
                    ["User-Agent"] = "Mozilla/5.0",
                    ["Accept"] = "image/png"
                }
            })

            if not Res or not Res.Body or #Res.Body < 100 then
                error("bad response")
            end

            writefile(FileName, Res.Body)

            local AssetUrl = getcustomasset(FileName)

            IconImg.Image = AssetUrl
            IconBg.BackgroundTransparency = 1
            if FallbackText then FallbackText.Visible = false end
        end)

        if not Ok then
            IconBg.BackgroundTransparency = 0
            IconImg.Image = ""
            if FallbackText then FallbackText.Visible = true end
        end
    end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DiscordWidget"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Wrap = Instance.new("Frame")
Wrap.Size = UDim2.fromOffset(300, 72)
Wrap.Position = UDim2.new(0.5, -150, 0.5, -36)
Wrap.BackgroundColor3 = Color3.fromRGB(30, 31, 34)
Wrap.BackgroundTransparency = 0.1
Wrap.BorderSizePixel = 0
Wrap.Parent = ScreenGui
Wrap:SetAttribute("Locked", false)

Instance.new("UICorner", Wrap).CornerRadius = UDim.new(0, 10)

local Stroke = Instance.new("UIStroke", Wrap)
Stroke.Thickness = 1
Stroke.Transparency = 0.5
Stroke.Color = Color3.fromRGB(60, 63, 70)

local IconBg = Instance.new("Frame")
IconBg.Size = UDim2.fromOffset(48, 48)
IconBg.Position = UDim2.new(0, 10, 0.5, 0)
IconBg.AnchorPoint = Vector2.new(0, 0.5)
IconBg.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
IconBg.BorderSizePixel = 0
IconBg.Parent = Wrap

Instance.new("UICorner", IconBg).CornerRadius = UDim.new(0, 10)

local IconImg = Instance.new("ImageLabel")
IconImg.Size = UDim2.fromScale(1, 1)
IconImg.BackgroundTransparency = 1
IconImg.Image = ""
IconImg.ScaleType = Enum.ScaleType.Fit
IconImg.Parent = IconBg

Instance.new("UICorner", IconImg).CornerRadius = UDim.new(0, 10)

local FallbackText = Instance.new("TextLabel")
FallbackText.Size = UDim2.fromScale(1, 1)
FallbackText.BackgroundTransparency = 1
FallbackText.Text = "DC"
FallbackText.TextColor3 = Color3.fromRGB(255, 255, 255)
FallbackText.TextSize = 18
FallbackText.Font = Enum.Font.GothamBold
FallbackText.Visible = true
FallbackText.Parent = IconBg

local NameLabel = Instance.new("TextLabel")
NameLabel.Size = UDim2.new(1, -130, 0, 16)
NameLabel.Position = UDim2.new(0, 66, 0, 14)
NameLabel.BackgroundTransparency = 1
NameLabel.Text = "Loading..."
NameLabel.TextColor3 = Color3.fromRGB(242, 243, 245)
NameLabel.TextSize = 13
NameLabel.Font = Enum.Font.GothamBold
NameLabel.TextXAlignment = Enum.TextXAlignment.Left
NameLabel.Parent = Wrap

local MemberLabel = Instance.new("TextLabel")
MemberLabel.Size = UDim2.new(1, -130, 0, 13)
MemberLabel.Position = UDim2.new(0, 66, 0, 31)
MemberLabel.BackgroundTransparency = 1
MemberLabel.Text = "Loading..."
MemberLabel.TextColor3 = Color3.fromRGB(148, 155, 164)
MemberLabel.TextSize = 11
MemberLabel.Font = Enum.Font.Gotham
MemberLabel.TextXAlignment = Enum.TextXAlignment.Left
MemberLabel.Parent = Wrap

local OnlineDot = Instance.new("Frame")
OnlineDot.Size = UDim2.fromOffset(7, 7)
OnlineDot.Position = UDim2.new(0, 66, 0, 49)
OnlineDot.BackgroundColor3 = Color3.fromRGB(67, 181, 129)
OnlineDot.BorderSizePixel = 0
OnlineDot.Parent = Wrap

Instance.new("UICorner", OnlineDot).CornerRadius = UDim.new(1, 0)

local OnlineLabel = Instance.new("TextLabel")
OnlineLabel.Size = UDim2.new(1, -90, 0, 12)
OnlineLabel.Position = UDim2.new(0, 78, 0, 45)
OnlineLabel.BackgroundTransparency = 1
OnlineLabel.Text = ""
OnlineLabel.TextColor3 = Color3.fromRGB(148, 155, 164)
OnlineLabel.TextSize = 10
OnlineLabel.Font = Enum.Font.Gotham
OnlineLabel.TextXAlignment = Enum.TextXAlignment.Left
OnlineLabel.Parent = Wrap

local JoinBtn = Instance.new("TextButton")
JoinBtn.Size = UDim2.fromOffset(50, 26)
JoinBtn.Position = UDim2.new(1, -10, 0.5, 0)
JoinBtn.AnchorPoint = Vector2.new(1, 0.5)
JoinBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
JoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
JoinBtn.Text = "Join"
JoinBtn.TextSize = 12
JoinBtn.Font = Enum.Font.GothamBold
JoinBtn.BorderSizePixel = 0
JoinBtn.Parent = Wrap

Instance.new("UICorner", JoinBtn).CornerRadius = UDim.new(0, 6)

JoinBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://discord.gg/" .. InviteCode) end)
    JoinBtn.Text = "Copied!"
    task.delay(2, function() JoinBtn.Text = "Join" end)
end)

local LockIndicator = Instance.new("TextLabel")
LockIndicator.Size = UDim2.fromOffset(14, 14)
LockIndicator.Position = UDim2.new(1, -20, 0, 5)
LockIndicator.BackgroundTransparency = 1
LockIndicator.Text = "[ ]"
LockIndicator.TextColor3 = Color3.fromRGB(255, 255, 255)
LockIndicator.TextSize = 12
LockIndicator.Font = Enum.Font.Gotham
LockIndicator.Parent = Wrap

local function UpdateLockIndicator()
    local isLocked = Wrap:GetAttribute("Locked")
    if isLocked then
        LockIndicator.Text = "[X]"
        LockIndicator.TextColor3 = Color3.fromRGB(67, 181, 129)
    else
        LockIndicator.Text = "[ ]"
        LockIndicator.TextColor3 = Color3.fromRGB(240, 71, 71)
    end
end

UpdateLockIndicator()

local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil
local holdTime = 2
local holdToken = 0
local holding = false

Wrap.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Wrap.Position
        holding = true
        holdToken = holdToken + 1
        local token = holdToken
        
        task.delay(holdTime, function()
            if holding and token == holdToken then
                local newState = not Wrap:GetAttribute("Locked")
                Wrap:SetAttribute("Locked", newState)
                UpdateLockIndicator()
                local originalBg = Wrap.BackgroundTransparency
                Wrap.BackgroundTransparency = 0.3
                task.delay(0.2, function()
                    Wrap.BackgroundTransparency = originalBg
                end)
                holding = false
            end
        end)
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                holding = false
            end
        end)
    end
end)

Wrap.InputChanged:Connect(function(input)
    if not dragStart then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging and not Wrap:GetAttribute("Locked") then
        local delta = input.Position - dragStart
        Wrap.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

task.spawn(function()
    local Success, Result = FetchDiscordData()
    if Success and Result and Result.guild then
        local Guild = Result.guild
        NameLabel.Text = Guild.name or "Unknown Server"
        FallbackText.Text = string.upper(string.sub(Guild.name or "DC", 1, 2))
        MemberLabel.Text = tostring(Result.approximate_member_count or 0) .. " members"
        OnlineLabel.Text = tostring(Result.approximate_presence_count or 0) .. " online"
        OnlineDot.BackgroundColor3 = Color3.fromRGB(67, 181, 129)
        LoadServerIcon(Guild.id, Guild.icon, IconImg, IconBg, FallbackText)
    else
        MemberLabel.Text = "Failed to load"
        OnlineDot.BackgroundColor3 = Color3.fromRGB(240, 71, 71)
    end
end)
