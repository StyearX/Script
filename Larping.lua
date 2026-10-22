--nostrict
--[[
   This Script/luau write by StyearX (https://github.com/StyearX)
   October 22, 2026, if the script does not work, there is a possibility that this script is outdated
   This script is client only, which means only you can see the effects of this script and other players and the server cannot see the effects of this script. This script also does not give you real ownership from the items provided by this script
]]
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Env = getgenv()

if Env.LarpingUnload then
	pcall(Env.LarpingUnload)
end

local Defaults = {Korblox = true, Headless = true, Threshold = 0.8, Debounce = 0.3}
Env.LarpingConfig = Env.LarpingConfig or {}
local Config = Env.LarpingConfig
for Key, Value in pairs(Defaults) do
	if Config[Key] == nil then Config[Key] = Value end
end

local Tracked = {}
local GlobalLinks = {}
local ReferenceModel
local ReferenceSet
local ReferenceCount = 0

local function IsAvatar(Model)
	local Leg = Model:FindFirstChild("Right Leg")
	return Leg ~= nil and Leg:IsA("BasePart") and (Model:FindFirstChild("Torso") ~= nil or Model:FindFirstChild("Head") ~= nil)
end

local function IsMine(Model)
	return Model == LocalPlayer.Character or Model.Name == LocalPlayer.Name or Model.Name == LocalPlayer.DisplayName
end

local function GetSignature(Model)
	local Set, Count = {}, 0
	local function Add(Key)
		if not Set[Key] then
			Set[Key] = true
			Count += 1
		end
	end

	for _, Child in ipairs(Model:GetChildren()) do
		if Child:IsA("Shirt") then
			if Child.ShirtTemplate ~= "" then Add("Shirt:" .. Child.ShirtTemplate) end
		elseif Child:IsA("Pants") then
			if Child.PantsTemplate ~= "" then Add("Pants:" .. Child.PantsTemplate) end
		elseif Child:IsA("ShirtGraphic") then
			if Child.Graphic ~= "" then Add("Tee:" .. Child.Graphic) end
		elseif Child:IsA("Accessory") then
			local Handle = Child:FindFirstChild("Handle")
			local Id = ""
			if Handle then
				if Handle:IsA("MeshPart") then
					Id = Handle.MeshId .. "|" .. Handle.TextureID
				else
					local Mesh = Handle:FindFirstChildOfClass("SpecialMesh")
					if Mesh then Id = Mesh.MeshId .. "|" .. Mesh.TextureId end
				end
			end
			Add("Acc:" .. Child.Name .. "|" .. Id)
		end
	end

	return Set, Count
end

local function GetSimilarity(SetA, CountA, SetB, CountB)
	if CountA == 0 or CountB == 0 then return 0 end
	local Shared = 0
	for Key in pairs(SetA) do
		if SetB[Key] then Shared += 1 end
	end
	return Shared / (CountA + CountB - Shared)
end

local function ApplyKorblox(Entry)
	local Leg = Entry.Leg
	if Entry.LegColor == nil then
		Entry.LegColor = Leg.BrickColor
		Entry.LegTransparency = Leg.Transparency
	end
	if not Leg:FindFirstChild("KorbloxMesh") then
		local Mesh = Instance.new("SpecialMesh")
		Mesh.Name = "KorbloxMesh"
		Mesh.MeshType = Enum.MeshType.FileMesh
		Mesh.MeshId = "rbxassetid://101851696"
		Mesh.TextureId = "rbxassetid://101851254"
		Mesh.Parent = Leg
	end
	if Leg.BrickColor ~= BrickColor.new("Really black") then
		Leg.BrickColor = BrickColor.new("Really black")
	end
	if Leg.Transparency ~= 0.1 then
		Leg.Transparency = 0.1
	end
end

local function RemoveKorblox(Entry)
	local Leg = Entry.Leg
	if not Leg then return end
	local Mesh = Leg:FindFirstChild("KorbloxMesh")
	if Mesh then Mesh:Destroy() end
	if Entry.LegColor ~= nil then
		Leg.BrickColor = Entry.LegColor
		Leg.Transparency = Entry.LegTransparency
		Entry.LegColor = nil
		Entry.LegTransparency = nil
	end
end

local function ApplyHeadless(Entry)
	local Head = Entry.Head
	if Entry.HeadTransparency == nil then
		Entry.HeadTransparency = Head.Transparency
	end
	if Head.Transparency ~= 1 then
		Head.Transparency = 1
	end
	local Face = Head:FindFirstChild("face")
	if Face then
		if Entry.Face then
			Face:Destroy()
		else
			Entry.Face = Face
			Face.Parent = nil
		end
	end
end

local function RemoveHeadless(Entry)
	local Head = Entry.Head
	if Head then
		if Entry.HeadTransparency ~= nil then
			Head.Transparency = Entry.HeadTransparency
		end
		if Entry.Face then
			Entry.Face.Parent = Head
		end
	end
	Entry.HeadTransparency = nil
	Entry.Face = nil
end

local function Sync(Entry)
	if Entry.Leg then
		if Config.Korblox then ApplyKorblox(Entry) else RemoveKorblox(Entry) end
	end
	if Entry.Head then
		if Config.Headless then ApplyHeadless(Entry) else RemoveHeadless(Entry) end
	end
end

local function Unwatch(Entry)
	for _, Connection in ipairs(Entry.Watchers) do
		Connection:Disconnect()
	end
	table.clear(Entry.Watchers)
end

local function Watch(Entry)
	local function Reapply() Sync(Entry) end
	if Entry.Leg and Config.Korblox then
		table.insert(Entry.Watchers, Entry.Leg:GetPropertyChangedSignal("Transparency"):Connect(Reapply))
		table.insert(Entry.Watchers, Entry.Leg:GetPropertyChangedSignal("BrickColor"):Connect(Reapply))
		table.insert(Entry.Watchers, Entry.Leg.ChildRemoved:Connect(Reapply))
	end
	if Entry.Head and Config.Headless then
		table.insert(Entry.Watchers, Entry.Head:GetPropertyChangedSignal("Transparency"):Connect(Reapply))
		table.insert(Entry.Watchers, Entry.Head.ChildAdded:Connect(Reapply))
	end
end

local function Enable(Entry, Model)
	Unwatch(Entry)
	Entry.Leg = Model:FindFirstChild("Right Leg")
	Entry.Head = Model:FindFirstChild("Head")
	Sync(Entry)
	Watch(Entry)
end

local function Disable(Entry)
	Unwatch(Entry)
	RemoveKorblox(Entry)
	RemoveHeadless(Entry)
	Entry.Leg = nil
	Entry.Head = nil
end

local Schedule

local function ScheduleOthers()
	for Model in pairs(Tracked) do
		if not IsMine(Model) then Schedule(Model) end
	end
end

local function Evaluate(Model)
	local Entry = Tracked[Model]
	if not Entry then return end
	Entry.Pending = false

	if not IsAvatar(Model) then
		Disable(Entry)
		return
	end

	local Set, Count = GetSignature(Model)

	if IsMine(Model) then
		if Model == ReferenceModel or Count > ReferenceCount then
			local Changed = Count ~= ReferenceCount or Model ~= ReferenceModel
			ReferenceModel, ReferenceSet, ReferenceCount = Model, Set, Count
			if Changed then ScheduleOthers() end
		end
		Enable(Entry, Model)
		return
	end

	if ReferenceSet and GetSimilarity(ReferenceSet, ReferenceCount, Set, Count) >= Config.Threshold then
		Enable(Entry, Model)
	else
		Disable(Entry)
	end
end

function Schedule(Model)
	local Entry = Tracked[Model]
	if not Entry or Entry.Pending then return end
	Entry.Pending = true
	task.delay(Config.Debounce, Evaluate, Model)
end

local function Untrack(Model)
	local Entry = Tracked[Model]
	if not Entry then return end
	Disable(Entry)
	for _, Connection in ipairs(Entry.Links) do
		Connection:Disconnect()
	end
	Tracked[Model] = nil
	if Model == ReferenceModel then
		ReferenceModel, ReferenceSet, ReferenceCount = nil, nil, 0
	end
end

local function Track(Leg)
	local Model = Leg.Parent
	if not Model or not Model:IsA("Model") or Tracked[Model] then return end

	local Entry = {Watchers = {}, Links = {}, Pending = false}
	Tracked[Model] = Entry

	local function OnChange() Schedule(Model) end
	table.insert(Entry.Links, Model.ChildAdded:Connect(OnChange))
	table.insert(Entry.Links, Model.ChildRemoved:Connect(OnChange))
	table.insert(Entry.Links, Model.AncestryChanged:Connect(function(_, Parent)
		if not Parent then Untrack(Model) end
	end))

	Schedule(Model)
end

for _, Descendant in ipairs(workspace:GetDescendants()) do
	if Descendant.Name == "Right Leg" and Descendant:IsA("BasePart") then
		Track(Descendant)
	end
end

table.insert(GlobalLinks, workspace.DescendantAdded:Connect(function(Descendant)
	if Descendant.Name == "Right Leg" and Descendant:IsA("BasePart") then
		Track(Descendant)
	end
end))

Env.LarpingRefresh = function()
	for Model in pairs(Tracked) do
		Schedule(Model)
	end
end

Env.LarpingUnload = function()
	for _, Connection in ipairs(GlobalLinks) do
		Connection:Disconnect()
	end
	for Model in pairs(Tracked) do
		Untrack(Model)
	end
	Env.LarpingRefresh = nil
	Env.LarpingUnload = nil
end