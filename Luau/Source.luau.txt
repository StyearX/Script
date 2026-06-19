-- lmao making ui code not ugly is hard without a ui framework
-- i tried to make this as readable as i could
-- github.com/lxte

if (not game:IsLoaded()) then
	game.Loaded:Wait()
end

-- Services
local InsertService = game:GetService("InsertService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- UI
local PlayerGui = Players.LocalPlayer.PlayerGui
local Parent = (function()
	local Success, Result = pcall(function()
		return game:GetService("CoreGui")
	end)

	if (not Success or not Result) then
		Result = PlayerGui
	end

	return Result
end)()

-- Functions
local SetProperty = function(Object: Instance, Property: string, Value: any)
	if (Value == nil) then
		return
	end

	Object[Property] = Value
end

local Tween = function(Object: Instance, Info: { [string]: any }, Properties: { [string]: any })
	for Property, Value in next, Properties do
		if (typeof(Value) == "boolean") then
			table.remove(Properties, table.find(Properties, Property))
			task.delay(0.5, function()
				SetProperty(Object, Property, Value)
			end)
		end
	end

	local Result = TweenService:Create(Object, TweenInfo.new(table.unpack(Info)), Properties)
	Result:Play()

	return Result
end

local MultiTween = function(Info: { [string]: any }, Properties: { [Instance]: { [string]: any } })
	for Object, Properties in next, Properties do
		local Success, Result = pcall(function()
			return Tween(Object, Info, Properties)
		end)

		if (not Success) then
			return warn(Result, Object, Properties)
		end
	end
end

-- Types
export type Configuration = {
	Title: string,
	Description: string?,
	Image: string?,
	Duration: number?,
}

export type EditOptions = {
	BackgroundColor: Color3?,
	TitleColor: Color3?,
	DescriptionColor: Color3,
	Mode: "Dark" | "Light" | nil,
	VerticalPosition: "Top" | "Bottom" | nil,
	HorizontalPosition: "Left" | "Right" | nil,	

	-- this shouldnt be updated
	UI: typeof(script.Parent),
	Order: number,
}

-- Init
local Notification = ({})
Notification.__index = Notification
type Self = typeof(Notification)

Notification.New = function(self: Self, Configuration: EditOptions)	
	Configuration.Order = 0
	Configuration.UI = (function()
		if (RunService:IsStudio()) then
			return script.Parent
		end

		return InsertService:LoadLocalAsset("rbxassetid://110156283814694")
	end)()

	local Holder = Configuration.UI.Holder

	Holder.Position = UDim2.fromScale((Configuration.HorizontalPosition == "Left" and 0) or 1)
	Holder.AnchorPoint = (Configuration.HorizontalPosition == "Left" and Vector2.zero) or Vector2.new(1, 0)
	Holder.UIListLayout.VerticalAlignment = Enum.VerticalAlignment[Configuration.VerticalPosition or "Top"]
	Holder.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment[Configuration.HorizontalPosition]
	Configuration.UI.IgnoreGuiInset = (Configuration.HorizontalPosition == "Right")
	Configuration.UI.Parent = Parent

	return setmetatable(Configuration, Notification)
end

Notification.Create = function(self: typeof(Notification:New()), Configuration: Configuration)
	self.Order -= 1

	-- Setup
	local UI = self.UI
	local Sizer = UI.Template:Clone()
	local Notification = Sizer.Notification
	local Properties = ({
		[Sizer] = ({ Parent = UI.Holder, LayoutOrder = self.Order, ZIndex = -self.Order }),
		[Notification] = ({ BackgroundColor3 = self.BackgroundColor, Visible = false, ZIndex = -self.Order }),
		[Notification.TextHolder.Title] = ({ TextColor3 = self.TitleColor, Text = Configuration.Title }),
		[Notification.TextHolder.Description] = ({ TextColor3 = self.DescriptionColor, Text = Configuration.Description }),
		[Notification.Icon] = ({ Image = Configuration.Image, BackgroundColor3 = (self.Mode == "Light" and Color3.fromRGB()) or Color3.fromRGB(255, 255, 255) }),
		[Notification.Light] = ({ Transparency = (self.Mode == "Light" and 0) or 0.7 })
	})

	for Object, Properties in next, Properties do
		for Property, Value in next, Properties do
			SetProperty(Object, Property, Value)
		end
	end

	if (not Configuration.Image) then
		Notification.Icon.Visible = false
		Notification.TextHolder.Size = UDim2.new(1, -30, 1, 0)
	end

	local Destroyed = false
	local OriginalSize = Notification.AbsoluteSize

	-- Functions
	local Animate = function(Shown: boolean)
		local Size = UDim2.fromOffset(OriginalSize.X, OriginalSize.Y)
		local NotificationPosition = (function()
			local Vertical = UDim2.new(0, 0, 0, ((self.VerticalPosition == "Top" and -20) or 20))
			local Horizontal = (self.HorizontalPosition == "Left" and UDim2.new(-1, -20, 0, 0)) or UDim2.new(1, 20, 0, 0)
			return Vertical + Horizontal
		end)()

		Tween(Sizer, { 0.5, Enum.EasingStyle.Quint }, { Size = (Shown and Size) or UDim2.fromOffset(250, 0) })

		return ({
			[Notification] = ({ 
				Size = Size, 
				BackgroundTransparency = (Shown and 0.15) or 1,
				Position = (Shown and UDim2.fromOffset(0, 0)) or NotificationPosition
			}),	
			[Notification.TextHolder] = ({ Visible = Shown }),
			[Notification.Icon] = ({ ImageTransparency = (Shown and 0) or 1, BackgroundTransparency = (Shown and 0.9) or 1 }),
			[Notification.Light] = ({ Transparency = (Shown and 0.8) or 1 }),
			[Notification.Dark] = ({ Transparency = (Shown and 0) or 1 }),
		})
	end

	local Remove = function()
		if (not Destroyed) then
			Destroyed = true
			MultiTween({ 0.75, Enum.EasingStyle.Quint }, Animate(false))
			task.wait(0.6)
			Sizer:Destroy()
		end
	end

	-- Rest
	Notification.AutomaticSize = Enum.AutomaticSize.None
	MultiTween({ 0, Enum.EasingStyle.Quint }, Animate(false)) task.wait()
	MultiTween({ 0.75, Enum.EasingStyle.Quint }, Animate(true))
	Notification.Visible = true
	Notification.Ignore.Close.MouseButton1Click:Connect(Remove)

	task.delay(Configuration.Duration or 5, function()
		Remove()
	end)
end

return Notification
