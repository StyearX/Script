local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

local Spawn, Wait = task.spawn, task.wait
local Insert = table.insert
local Clamp, Floor = math.clamp, math.floor

local ColorWhite = Color3.fromRGB(255, 255, 255)
local ColorArrow = Color3.fromRGB(204, 204, 204)
local ColorRowHover = Color3.fromRGB(35, 37, 39)
local ColorAccent = Color3.fromRGB(0, 162, 255)
local ColorMuted = Color3.fromRGB(110, 115, 135)
local ColorDanger = Color3.fromRGB(220, 50, 50)
local ColorTrack = Color3.fromRGB(55, 58, 70)
local ColorInput = Color3.fromRGB(28, 30, 36)
local ColorInputBorder = Color3.fromRGB(60, 63, 75)

local BaseZIndex = 200

local LucideData = nil

local function FetchRaw(Url)
	local Raw = nil
	pcall(function() Raw = game:HttpGet(Url) end)
	if not Raw or Raw == "" then pcall(function() Raw = HttpService:GetAsync(Url) end) end
	return Raw
end

local function LoadLucide()
	local Raw = FetchRaw("https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/lucide/dist/Icons.lua")
	if not Raw or Raw == "" then return end
	local Ok, Fn = pcall(loadstring, Raw)
	if not Ok or type(Fn) ~= "function" then return end
	local Ok2, Result = pcall(Fn)
	if not Ok2 or type(Result) ~= "table" then return end
	if Result.Icons and Result.Spritesheets then
		LucideData = {Sprites = Result.Spritesheets, Icons = Result.Icons}
	else
		LucideData = {Flat = Result}
	end
end

local function PascalToKebab(Name)
	Name = Name:gsub("(%l)(%u)", "%1-%2")
	Name = Name:gsub("(%a)(%d)", "%1-%2")
	Name = Name:gsub("(%d)(%a)", "%1-%2")
	return Name:lower()
end

local function GetLucideIcon(IconName)
	if not LucideData then return nil end
	local Kebab = PascalToKebab(IconName)
	if LucideData.Icons then
		local Entry = LucideData.Icons[Kebab] or LucideData.Icons[IconName]
		if not Entry then return nil end
		local Key = Entry.Image
		local SheetId = LucideData.Sprites[Key] or LucideData.Sprites[tostring(Key)] or tostring(Key)
		if type(SheetId) == "number" then
			SheetId = "rbxassetid://" .. tostring(SheetId)
		elseif not tostring(SheetId):match("^rbxasset") then
			SheetId = "rbxassetid://" .. tostring(SheetId)
		end
		return {SheetId, {ImageRectSize = Entry.ImageRectSize, ImageRectPosition = Entry.ImageRectPosition}}
	elseif LucideData.Flat then
		local Entry = LucideData.Flat[Kebab] or LucideData.Flat[IconName]
		if not Entry then return nil end
		if type(Entry) == "string" then
			return {Entry, {ImageRectSize = Vector2.new(0, 0), ImageRectPosition = Vector2.new(0, 0)}}
		elseif type(Entry) == "table" and Entry.Image then
			local Id = tostring(Entry.Image)
			if not Id:match("^rbxasset") then Id = "rbxassetid://" .. Id end
			return {Id, {ImageRectSize = Entry.ImageRectSize or Vector2.new(0, 0), ImageRectPosition = Entry.ImageRectPosition or Vector2.new(0, 0)}}
		end
	end
	return nil
end

LoadLucide()

if getgenv().SettingHubData then
	for _, C in next, (getgenv().SettingHubData.Connections or {}) do pcall(function() C:Disconnect() end) end
	for _, O in next, (getgenv().SettingHubData.Objects or {}) do pcall(function() O:Destroy() end) end
end

local Data = {Connections = {}, Objects = {}}
getgenv().SettingHubData = Data

for _, O in next, CoreGui:GetChildren() do
	if O.Name == "SettingHubGui" then O:Destroy() end
end

local function Connect(Signal, Callback)
	local Conn = Signal:Connect(Callback)
	Insert(Data.Connections, Conn)
	return Conn
end

local function Create(Class, Props)
	local Obj = Instance.new(Class)
	for K, V in next, (Props or {}) do Obj[K] = V end
	return Obj
end

local function Protect(Fn) return pcall(Fn) end

local function ApplyLucideIcon(Img, IconName)
	local IconData = GetLucideIcon(IconName)
	if IconData then
		Img.Image = IconData[1]
		if IconData[2] then
			Img.ImageRectSize = IconData[2].ImageRectSize or Vector2.new(0, 0)
			Img.ImageRectOffset = IconData[2].ImageRectPosition or Vector2.new(0, 0)
		end
	end
end

local InputLocked = false
local function LockInput() InputLocked = true end
local function UnlockInput() InputLocked = false end

local Hub = {
	Visible = false,
	Pages = {},
	CurrentPage = nil,
	TabWidth = 800,
	CliHeight = 480,
}

local ScreenGui = Create("ScreenGui", {
	Name = "SettingHubGui",
	Parent = CoreGui,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 9000,
	Enabled = true,
	ResetOnSpawn = false,
})
Insert(Data.Objects, ScreenGui)

local Shield = Create("Frame", {
	Name = "Shield",
	Parent = ScreenGui,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0.5,
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = BaseZIndex,
	Active = true,
})

local ModalBtn = Create("TextButton", {
	Name = "Modal",
	Parent = Shield,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Text = "",
	ZIndex = BaseZIndex,
	Active = true,
	AutoButtonColor = false,
	Modal = true,
})

Hub.Container = Create("Frame", {
	Name = "MenuContainer",
	Parent = Shield,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 10),
	Size = UDim2.new(0, 0, 0, 0),
	AutomaticSize = Enum.AutomaticSize.XY,
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0.3,
	BorderSizePixel = 0,
	ZIndex = BaseZIndex + 1,
	ClipsDescendants = false,
})

Create("UIListLayout", {
	Parent = Hub.Container,
	SortOrder = Enum.SortOrder.LayoutOrder,
	FillDirection = Enum.FillDirection.Vertical,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	Padding = UDim.new(0, 0),
})

Hub.HubBar = Create("Frame", {
	Name = "HubBar",
	Parent = Hub.Container,
	Size = UDim2.new(0, 800, 0, 60),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	LayoutOrder = 0,
	ZIndex = BaseZIndex + 1,
})

Create("Frame", {
	Name = "Separator",
	Parent = Hub.HubBar,
	Size = UDim2.new(1, 0, 0, 1),
	Position = UDim2.new(0, 0, 1, -1),
	AnchorPoint = Vector2.new(0, 1),
	BackgroundColor3 = ColorWhite,
	BackgroundTransparency = 0.8,
	BorderSizePixel = 0,
	ZIndex = BaseZIndex + 2,
})

local TabHeaderContainer = Create("Frame", {
	Name = "TabHeaderContainer",
	Parent = Hub.HubBar,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ZIndex = BaseZIndex + 2,
})

Create("UIListLayout", {
	Parent = TabHeaderContainer,
	SortOrder = Enum.SortOrder.LayoutOrder,
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	Padding = UDim.new(0, 0),
})

Hub.HubBarContainer = Create("ImageLabel", {
	Name = "HubBarContainer",
	Parent = TabHeaderContainer,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	Image = "",
	ZIndex = BaseZIndex + 3,
	LayoutOrder = 0,
})

Create("UIListLayout", {
	Parent = Hub.HubBarContainer,
	SortOrder = Enum.SortOrder.LayoutOrder,
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Top,
	Padding = UDim.new(0, 0),
})

Hub.PageViewClipper = Create("Frame", {
	Name = "PageViewClipper",
	Parent = Hub.Container,
	Size = UDim2.new(0, 800, 0, 480),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	LayoutOrder = 1,
	ZIndex = BaseZIndex + 1,
})

Hub.PageView = Create("ScrollingFrame", {
	Name = "PageView",
	Parent = Hub.PageViewClipper,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = Color3.fromRGB(80, 83, 95),
	ScrollBarImageTransparency = 0.4,
	ZIndex = BaseZIndex + 1,
})

local function ResizeHub()
	local Viewport = ScreenGui.AbsoluteSize
	if Viewport.X <= 0 or Viewport.Y <= 0 then
		local Cam = workspace.CurrentCamera
		Viewport = (Cam and Cam.ViewportSize) or Vector2.new(1280, 720)
	end
	local W = Clamp(Viewport.X - 40, 480, 800)
	local H = Clamp(Viewport.Y - 180, 200, 480)
	Hub.HubBar.Size = UDim2.new(0, W, 0, 60)
	Hub.PageViewClipper.Size = UDim2.new(0, W, 0, H)
	Hub.TabWidth = W
	Hub.CliHeight = H
end

ResizeHub()
Connect(ScreenGui:GetPropertyChangedSignal("AbsoluteSize"), ResizeHub)
do
	local Cam = workspace.CurrentCamera
	if Cam then Connect(Cam:GetPropertyChangedSignal("ViewportSize"), ResizeHub) end
	Connect(workspace:GetPropertyChangedSignal("CurrentCamera"), function()
		local NewCam = workspace.CurrentCamera
		if NewCam then Connect(NewCam:GetPropertyChangedSignal("ViewportSize"), ResizeHub) end
		ResizeHub()
	end)
end

local SwitchToPage
local SetVisibility

local function MakePage(Name)
	local Page = {
		Name = Name,
		Frame = Create("Frame", {
			Name = Name .. "Page",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Visible = false,
			ZIndex = BaseZIndex + 2,
		}),
	}
	Create("UIListLayout", {
		Parent = Page.Frame,
		Name = "RowListLayout",
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 0),
	})
	Create("UIPadding", {
		Parent = Page.Frame,
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 11),
		PaddingTop = UDim.new(0, 0),
		PaddingBottom = UDim.new(0, 0),
	})
	Page.Frame.Parent = Hub.PageView
	return Page
end

local function MakeTab(Page, Title, IconName)
	local Tab = Create("TextButton", {
		Name = Page.Name .. "Tab",
		Parent = Hub.HubBarContainer,
		BackgroundTransparency = 1,
		Text = "",
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		ZIndex = BaseZIndex + 4,
		AutoButtonColor = false,
		Selectable = false,
	})
	local TabSelection = Create("ImageLabel", {
		Name = "TabSelection",
		Parent = Tab,
		Position = UDim2.new(0, 3, 1, -2),
		Size = UDim2.new(1, -6, 0, 2),
		AnchorPoint = Vector2.new(0, 0),
		BackgroundColor3 = ColorWhite,
		BackgroundTransparency = 1,
		Image = "",
		ZIndex = BaseZIndex + 5,
		BorderSizePixel = 0,
	})
	local TabLabel = Create("Frame", {
		Name = "TabLabel",
		Parent = Tab,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		ZIndex = BaseZIndex + 4,
	})
	Create("UIListLayout", {
		Parent = TabLabel,
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 10),
	})
	Create("UIPadding", {
		Parent = TabLabel,
		PaddingLeft = UDim.new(0, 16),
		PaddingRight = UDim.new(0, 16),
	})
	local IconData = GetLucideIcon(IconName)
	local Icon = Create("ImageLabel", {
		Name = "Icon",
		Parent = TabLabel,
		BackgroundTransparency = 1,
		Image = IconData and IconData[1] or "",
		ImageRectSize = IconData and IconData[2].ImageRectSize or Vector2.new(0, 0),
		ImageRectOffset = IconData and IconData[2].ImageRectPosition or Vector2.new(0, 0),
		ImageColor3 = ColorMuted,
		Size = UDim2.new(0, 20, 0, 20),
		ZIndex = BaseZIndex + 5,
		LayoutOrder = 0,
	})
	Create("UIAspectRatioConstraint", {
		Parent = Icon,
		AspectRatio = 1,
	})
	local TitleLabel = Create("TextLabel", {
		Name = "Title",
		Parent = TabLabel,
		BackgroundTransparency = 1,
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 19,
		TextColor3 = ColorMuted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Text = Title,
		Size = UDim2.new(0, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		ZIndex = BaseZIndex + 5,
		LayoutOrder = 1,
	})
	Page.Tab = Tab
	Page.TabIcon = Icon
	Page.TabTitle = TitleLabel
	Page.TabSelection = TabSelection
	Connect(Tab.MouseButton1Click, function() SwitchToPage(Page) end)
	Connect(Tab.MouseEnter, function()
		if TabSelection.BackgroundTransparency ~= 0 then
			TitleLabel.TextColor3 = ColorWhite
			Icon.ImageColor3 = ColorWhite
		end
	end)
	Connect(Tab.MouseLeave, function()
		if TabSelection.BackgroundTransparency ~= 0 then
			TitleLabel.TextColor3 = ColorMuted
			Icon.ImageColor3 = ColorMuted
		end
	end)
end

SwitchToPage = function(Page)
	if not Page then return end
	for _, P in next, Hub.Pages do
		if P.Frame then P.Frame.Visible = false end
		if P.TabSelection then
			P.TabSelection.BackgroundTransparency = 1
			if P.TabTitle then P.TabTitle.TextColor3 = ColorMuted end
			if P.TabIcon then P.TabIcon.ImageColor3 = ColorMuted end
		end
	end
	Page.Frame.Visible = true
	Hub.PageView.CanvasPosition = Vector2.new(0, 0)
	Hub.CurrentPage = Page
	if Page.TabSelection then
		Page.TabSelection.BackgroundTransparency = 0
		if Page.TabTitle then Page.TabTitle.TextColor3 = ColorWhite end
		if Page.TabIcon then Page.TabIcon.ImageColor3 = ColorAccent end
	end
end

local function AddPage(Page, Title, IconName)
	Insert(Hub.Pages, Page)
	if Title then MakeTab(Page, Title, IconName) end
end

local function MakeRow(PageFrame, LabelText)
	local Row = Create("ImageButton", {
		Name = LabelText ~= "" and (LabelText .. "Frame") or "RowFrame",
		Size = UDim2.new(1, 0, 0, 50),
		Image = "rbxasset://textures/ui/VR/rectBackgroundWhite.png",
		ImageColor3 = ColorRowHover,
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 18, 18),
		BackgroundColor3 = ColorRowHover,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Selectable = false,
		ZIndex = BaseZIndex + 2,
	})
	Create("UICorner", {
		Parent = Row,
		CornerRadius = UDim.new(0, 8),
	})
	if LabelText ~= "" then
		local Label = Create("TextLabel", {
			Name = LabelText .. "Label",
			Parent = Row,
			Position = UDim2.new(0, 10, 0, 0),
			Size = UDim2.new(0.4, -20, 1, 0),
			Text = LabelText,
			TextColor3 = ColorWhite,
			TextSize = 17,
			Font = Enum.Font.BuilderSansMedium,
			AutomaticSize = Enum.AutomaticSize.Y,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = BaseZIndex + 3,
		})
		Create("UIPadding", {
			Parent = Label,
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
		})
	end
	Connect(Row.MouseEnter, function() Row.ImageTransparency = 0 end)
	Connect(Row.MouseLeave, function() Row.ImageTransparency = 1 end)
	Row.Parent = PageFrame
	return Row
end

local function MakeSelectorWidget(Row, Options, DefaultIndex, Callback)
	local Index = Clamp(DefaultIndex or 1, 1, math.max(1, #Options))

	local Sel = Create("ImageButton", {
		Name = "Selector",
		Parent = Row,
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		Size = UDim2.new(0.6, 0, 0, 50),
		BackgroundTransparency = 1,
		Image = "",
		AutoButtonColor = false,
		Selectable = true,
		ZIndex = BaseZIndex + 3,
	})

	local LBtn = Create("ImageButton", {
		Name = "LeftButton",
		Parent = Sel,
		Size = UDim2.new(0, 32, 0, 50),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundTransparency = 1,
		Image = "",
		AutoButtonColor = true,
		Selectable = false,
		ZIndex = BaseZIndex + 4,
	})
	Create("ImageLabel", {
		Name = "LeftButton",
		Parent = LBtn,
		Image = "rbxasset://textures/ui/Settings/Slider/Left.png",
		ImageColor3 = ColorArrow,
		Size = UDim2.new(0, 18, 0, 30),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 1,
		ZIndex = BaseZIndex + 5,
	})

	local RBtn = Create("ImageButton", {
		Name = "RightButton",
		Parent = Sel,
		Size = UDim2.new(0, 32, 0, 50),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		BackgroundTransparency = 1,
		Image = "",
		AutoButtonColor = true,
		Selectable = false,
		ZIndex = BaseZIndex + 4,
	})
	Create("ImageLabel", {
		Name = "RightButton",
		Parent = RBtn,
		Image = "rbxasset://textures/ui/Settings/Slider/Right.png",
		ImageColor3 = ColorArrow,
		Size = UDim2.new(0, 18, 0, 30),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 1,
		ZIndex = BaseZIndex + 5,
	})

	local CenterBtn = Create("ImageButton", {
		Name = "AutoSelectButton",
		Parent = Sel,
		Position = UDim2.new(0, 32, 0, 0),
		Size = UDim2.new(1, -64, 1, 0),
		BackgroundTransparency = 1,
		Image = "",
		AutoButtonColor = true,
		Selectable = false,
		ZIndex = BaseZIndex + 4,
	})

	local ValLabel = Create("TextLabel", {
		Name = "ValueLabel",
		Parent = Sel,
		Position = UDim2.new(0, 32, 0, 0),
		Size = UDim2.new(1, -64, 1, 0),
		TextColor3 = ColorWhite,
		TextSize = 17,
		Font = Enum.Font.BuilderSans,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		BackgroundTransparency = 1,
		ZIndex = BaseZIndex + 5,
	})

	local function Refresh()
		ValLabel.Text = tostring(Options[Index] or "")
	end

	local function StepLeft()
		Index = Index - 1
		if Index < 1 then Index = #Options end
		Refresh()
		if Callback then Callback(Options[Index], Index) end
	end

	local function StepRight()
		Index = Index + 1
		if Index > #Options then Index = 1 end
		Refresh()
		if Callback then Callback(Options[Index], Index) end
	end

	Connect(LBtn.MouseButton1Click, StepLeft)
	Connect(RBtn.MouseButton1Click, StepRight)
	Connect(CenterBtn.MouseButton1Click, StepRight)
	Refresh()

	return {
		SetIndex = function(I)
			Index = Clamp(I, 1, #Options)
			Refresh()
		end,
		SetValue = function(Val)
			for I, V in next, Options do
				if V == Val then
					Index = I
					Refresh()
					return
				end
			end
		end,
		GetIndex = function() return Index end,
		GetValue = function() return Options[Index] end,
		SetOptions = function(NewOpts, NewIdx)
			Options = NewOpts
			Index = Clamp(NewIdx or 1, 1, math.max(1, #Options))
			Refresh()
		end,
	}
end

local function MakeSliderWidget(Row, Min, Max, Default, Step, Callback)
	Step = Step or 1
	local Value = Clamp(Default or Min, Min, Max)

	local SliderArea = Create("Frame", {
		Name = "SliderArea",
		Parent = Row,
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		Size = UDim2.new(0.6, 0, 0, 50),
		BackgroundTransparency = 1,
		ZIndex = BaseZIndex + 3,
	})

	local Track = Create("Frame", {
		Name = "Track",
		Parent = SliderArea,
		Position = UDim2.new(0, 32, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.new(1, -80, 0, 4),
		BackgroundColor3 = ColorTrack,
		BorderSizePixel = 0,
		ZIndex = BaseZIndex + 4,
	})
	Create("UICorner", {Parent = Track, CornerRadius = UDim.new(1, 0)})

	local Fill = Create("Frame", {
		Name = "Fill",
		Parent = Track,
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = ColorAccent,
		BorderSizePixel = 0,
		ZIndex = BaseZIndex + 5,
	})
	Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})

	local Knob = Create("Frame", {
		Name = "Knob",
		Parent = Track,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 14),
		BackgroundColor3 = ColorWhite,
		BorderSizePixel = 0,
		ZIndex = BaseZIndex + 6,
	})
	Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})

	local ValLabel = Create("TextLabel", {
		Name = "ValueLabel",
		Parent = SliderArea,
		Position = UDim2.new(1, -40, 0, 0),
		AnchorPoint = Vector2.new(0, 0),
		Size = UDim2.new(0, 40, 1, 0),
		TextColor3 = ColorWhite,
		TextSize = 17,
		Font = Enum.Font.BuilderSans,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		BackgroundTransparency = 1,
		ZIndex = BaseZIndex + 4,
	})

	local function UpdateVisual()
		local T = (Value - Min) / math.max(Max - Min, 0.0001)
		Fill.Size = UDim2.new(T, 0, 1, 0)
		Knob.Position = UDim2.new(T, 0, 0.5, 0)
		local Display = Step < 1 and string.format("%.1f", Value) or tostring(Floor(Value))
		ValLabel.Text = Display
	end

	local function SetValue(NewVal, Fire)
		NewVal = Clamp(NewVal, Min, Max)
		if Step > 0 then
			NewVal = Floor((NewVal - Min) / Step + 0.5) * Step + Min
			NewVal = Clamp(NewVal, Min, Max)
		end
		Value = NewVal
		UpdateVisual()
		if Fire and Callback then Callback(Value) end
	end

	UpdateVisual()

	local Dragging = false
	Connect(Track.InputBegan, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			local Abs = Track.AbsoluteSize.X
			local RelX = (Input.Position.X - Track.AbsolutePosition.X) / math.max(Abs, 1)
			SetValue(Min + RelX * (Max - Min), true)
		end
	end)
	Connect(UserInputService.InputChanged, function(Input)
		if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
			local Abs = Track.AbsoluteSize.X
			local RelX = (Input.Position.X - Track.AbsolutePosition.X) / math.max(Abs, 1)
			SetValue(Min + RelX * (Max - Min), true)
		end
	end)
	Connect(UserInputService.InputEnded, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = false
		end
	end)

	return {
		GetValue = function() return Value end,
		SetValue = function(V) SetValue(V, false) end,
	}
end

local function MakeToggleWidget(Row, DefaultState, Callback)
	local Options = {"Enabled", "Disabled"}
	local DefaultIndex = DefaultState and 1 or 2
	local Sel = MakeSelectorWidget(Row, Options, DefaultIndex, function(Val, Idx)
		if Callback then Callback(Idx == 1) end
	end)
	return {
		GetValue = function() return Sel.GetIndex() == 1 end,
		SetValue = function(V) Sel.SetIndex(V and 1 or 2) end,
	}
end

local function MakeButtonWidget(Row, BtnText, Callback)
	local BtnFrame = Create("ImageButton", {
		Name = "ButtonContainer",
		Parent = Row,
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		Size = UDim2.new(0.6, 0, 0, 32),
		BackgroundColor3 = ColorAccent,
		BackgroundTransparency = 0,
		Image = "",
		AutoButtonColor = false,
		ZIndex = BaseZIndex + 3,
	})
	Create("UICorner", {Parent = BtnFrame, CornerRadius = UDim.new(0, 8)})
	Create("TextLabel", {
		Name = "Label",
		Parent = BtnFrame,
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		TextColor3 = ColorWhite,
		TextSize = 15,
		Font = Enum.Font.BuilderSansMedium,
		Text = BtnText,
		TextXAlignment = Enum.TextXAlignment.Center,
		BackgroundTransparency = 1,
		ZIndex = BaseZIndex + 4,
	})
	Connect(BtnFrame.MouseEnter, function() BtnFrame.BackgroundColor3 = Color3.fromRGB(0, 140, 220) end)
	Connect(BtnFrame.MouseLeave, function() BtnFrame.BackgroundColor3 = ColorAccent end)
	Connect(BtnFrame.MouseButton1Click, function() if Callback then Callback() end end)
end

local function MakeValueWidget(Row, DefaultVal, Callback)
	local CurrentVal = tostring(DefaultVal or "")

	local InputBox = Create("TextBox", {
		Name = "ValueInput",
		Parent = Row,
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		Size = UDim2.new(0.6, 0, 0, 32),
		BackgroundColor3 = ColorInput,
		BorderSizePixel = 0,
		Text = CurrentVal,
		TextColor3 = ColorWhite,
		TextSize = 15,
		Font = Enum.Font.BuilderSans,
		ClearTextOnFocus = false,
		PlaceholderText = "",
		PlaceholderColor3 = ColorMuted,
		ZIndex = BaseZIndex + 3,
	})
	Create("UICorner", {Parent = InputBox, CornerRadius = UDim.new(0, 8)})
	Create("UIStroke", {Parent = InputBox, Color = ColorInputBorder, Thickness = 1})
	Create("UIPadding", {Parent = InputBox, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})

	Connect(InputBox.Focused, function() LockInput() end)
	Connect(InputBox.FocusLost, function(Enter)
		UnlockInput()
		CurrentVal = InputBox.Text
		if Callback then Callback(CurrentVal, Enter) end
	end)

	return {
		GetValue = function() return InputBox.Text end,
		SetValue = function(V) InputBox.Text = tostring(V) end,
	}
end

local function MakeDropDownWidget(Row, Options, DefaultIndex, Callback)
	local Index = Clamp(DefaultIndex or 1, 1, math.max(1, #Options))
	local DropOpen = false

	local DropBtn = Create("ImageButton", {
		Name = "DropDownButton",
		Parent = Row,
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		Size = UDim2.new(0.6, 0, 0, 32),
		BackgroundColor3 = ColorInput,
		BackgroundTransparency = 0,
		Image = "",
		AutoButtonColor = false,
		ZIndex = BaseZIndex + 3,
	})
	Create("UICorner", {Parent = DropBtn, CornerRadius = UDim.new(0, 8)})
	Create("UIStroke", {Parent = DropBtn, Color = ColorInputBorder, Thickness = 1})

	local DropLabel = Create("TextLabel", {
		Name = "Label",
		Parent = DropBtn,
		Position = UDim2.new(0, 8, 0, 0),
		Size = UDim2.new(1, -32, 1, 0),
		TextColor3 = ColorWhite,
		TextSize = 15,
		Font = Enum.Font.BuilderSans,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		ZIndex = BaseZIndex + 4,
	})

	local ChevronData = GetLucideIcon("ChevronDown")
	local Chevron = Create("ImageLabel", {
		Name = "Chevron",
		Parent = DropBtn,
		Position = UDim2.new(1, -24, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		Size = UDim2.new(0, 14, 0, 14),
		Image = ChevronData and ChevronData[1] or "",
		ImageRectSize = ChevronData and ChevronData[2].ImageRectSize or Vector2.new(0, 0),
		ImageRectOffset = ChevronData and ChevronData[2].ImageRectPosition or Vector2.new(0, 0),
		ImageColor3 = ColorMuted,
		BackgroundTransparency = 1,
		ZIndex = BaseZIndex + 4,
	})

	local DropList = Create("Frame", {
		Name = "DropList",
		Parent = Hub.Container,
		BackgroundColor3 = Color3.fromRGB(28, 30, 36),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = false,
		ZIndex = BaseZIndex + 20,
	})
	Create("UICorner", {Parent = DropList, CornerRadius = UDim.new(0, 8)})
	Create("UIStroke", {Parent = DropList, Color = ColorInputBorder, Thickness = 1})
	Create("UIListLayout", {
		Parent = DropList,
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 0),
	})

	local OptionBtns = {}

	local function RefreshLabel()
		DropLabel.Text = tostring(Options[Index] or "")
	end

	local function CloseList()
		DropOpen = false
		DropList.Visible = false
	end

	local function BuildList()
		for _, B in next, OptionBtns do B:Destroy() end
		OptionBtns = {}
		for I, Opt in next, Options do
			local OptBtn = Create("TextButton", {
				Name = "Option" .. I,
				Parent = DropList,
				Size = UDim2.new(0, 0, 0, 36),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Text = "",
				ZIndex = BaseZIndex + 21,
				AutoButtonColor = false,
				LayoutOrder = I,
			})
			Create("TextLabel", {
				Parent = OptBtn,
				Size = UDim2.new(1, 0, 1, 0),
				TextColor3 = ColorWhite,
				TextSize = 15,
				Font = Enum.Font.BuilderSans,
				Text = tostring(Opt),
				BackgroundTransparency = 1,
				ZIndex = BaseZIndex + 22,
			})
			Connect(OptBtn.MouseButton1Click, function()
				Index = I
				RefreshLabel()
				CloseList()
				if Callback then Callback(Options[Index], Index) end
			end)
			Insert(OptionBtns, OptBtn)
		end
	end

	BuildList()
	RefreshLabel()

	Connect(DropBtn.MouseButton1Click, function()
		if DropOpen then
			CloseList()
		else
			DropOpen = true
			local AbsPos = DropBtn.AbsolutePosition
			local AbsSize = DropBtn.AbsoluteSize
			local ContPos = Hub.Container.AbsolutePosition
			DropList.Position = UDim2.new(0, AbsPos.X - ContPos.X, 0, AbsPos.Y - ContPos.Y + AbsSize.Y + 4)
			DropList.Size = UDim2.new(0, AbsSize.X, 0, 0)
			DropList.Visible = true
		end
	end)

	Connect(ModalBtn.MouseButton1Click, function()
		if DropOpen then CloseList() end
	end)

	return {
		GetIndex = function() return Index end,
		GetValue = function() return Options[Index] end,
		SetIndex = function(I)
			Index = Clamp(I, 1, #Options)
			RefreshLabel()
		end,
		UpdateDropDownList = function(NewOpts, NewIdx)
			Options = NewOpts
			Index = Clamp(NewIdx or 1, 1, math.max(1, #Options))
			BuildList()
			RefreshLabel()
		end,
	}
end

local function MakeMultiDropDownWidget(Row, Options, Callback)
	local Selected = {}
	local DropOpen = false

	local DropBtn = Create("ImageButton", {
		Name = "MultiDropDownButton",
		Parent = Row,
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		Size = UDim2.new(0.6, 0, 0, 32),
		BackgroundColor3 = ColorInput,
		BackgroundTransparency = 0,
		Image = "",
		AutoButtonColor = false,
		ZIndex = BaseZIndex + 3,
	})
	Create("UICorner", {Parent = DropBtn, CornerRadius = UDim.new(0, 8)})
	Create("UIStroke", {Parent = DropBtn, Color = ColorInputBorder, Thickness = 1})

	local DropLabel = Create("TextLabel", {
		Name = "Label",
		Parent = DropBtn,
		Position = UDim2.new(0, 8, 0, 0),
		Size = UDim2.new(1, -32, 1, 0),
		TextColor3 = ColorWhite,
		TextSize = 15,
		Font = Enum.Font.BuilderSans,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		ZIndex = BaseZIndex + 4,
	})

	local ChevronData = GetLucideIcon("ChevronDown")
	Create("ImageLabel", {
		Name = "Chevron",
		Parent = DropBtn,
		Position = UDim2.new(1, -24, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		Size = UDim2.new(0, 14, 0, 14),
		Image = ChevronData and ChevronData[1] or "",
		ImageRectSize = ChevronData and ChevronData[2].ImageRectSize or Vector2.new(0, 0),
		ImageRectOffset = ChevronData and ChevronData[2].ImageRectPosition or Vector2.new(0, 0),
		ImageColor3 = ColorMuted,
		BackgroundTransparency = 1,
		ZIndex = BaseZIndex + 4,
	})

	local DropList = Create("Frame", {
		Name = "MultiDropList",
		Parent = Hub.Container,
		BackgroundColor3 = Color3.fromRGB(28, 30, 36),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = false,
		ZIndex = BaseZIndex + 20,
	})
	Create("UICorner", {Parent = DropList, CornerRadius = UDim.new(0, 8)})
	Create("UIStroke", {Parent = DropList, Color = ColorInputBorder, Thickness = 1})
	Create("UIListLayout", {
		Parent = DropList,
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 0),
	})

	local function RefreshLabel()
		local Count = 0
		for _ in next, Selected do Count = Count + 1 end
		if Count == 0 then
			DropLabel.Text = "None selected"
		elseif Count == 1 then
			for K in next, Selected do DropLabel.Text = tostring(K) return end
		else
			DropLabel.Text = Count .. " selected"
		end
	end

	local function CloseList()
		DropOpen = false
		DropList.Visible = false
	end

	local OptionBtns = {}

	local function BuildList()
		for _, B in next, OptionBtns do B:Destroy() end
		OptionBtns = {}
		for I, Opt in next, Options do
			local OptBtn = Create("TextButton", {
				Name = "Option" .. I,
				Parent = DropList,
				Size = UDim2.new(0, 0, 0, 36),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Text = "",
				ZIndex = BaseZIndex + 21,
				AutoButtonColor = false,
				LayoutOrder = I,
			})
			local Tick = Create("ImageLabel", {
				Name = "Tick",
				Parent = OptBtn,
				Size = UDim2.new(0, 16, 1, 0),
				BackgroundTransparency = 1,
				Image = "",
				ImageColor3 = ColorAccent,
				ZIndex = BaseZIndex + 23,
			})
			local OptLabel = Create("TextLabel", {
				Parent = OptBtn,
				Position = UDim2.new(0, 24, 0, 0),
				Size = UDim2.new(0, 0, 1, 0),
				AutomaticSize = Enum.AutomaticSize.X,
				TextColor3 = ColorWhite,
				TextSize = 15,
				Font = Enum.Font.BuilderSans,
				Text = tostring(Opt),
				BackgroundTransparency = 1,
				ZIndex = BaseZIndex + 22,
			})
			local CheckData = GetLucideIcon("Check")
			local function RefreshTick()
				if Selected[Opt] then
					Tick.Image = CheckData and CheckData[1] or ""
					if CheckData then
						Tick.ImageRectSize = CheckData[2].ImageRectSize or Vector2.new(0, 0)
						Tick.ImageRectOffset = CheckData[2].ImageRectPosition or Vector2.new(0, 0)
					end
					OptLabel.TextColor3 = ColorAccent
				else
					Tick.Image = ""
					OptLabel.TextColor3 = ColorWhite
				end
			end
			RefreshTick()
			Connect(OptBtn.MouseButton1Click, function()
				if Selected[Opt] then Selected[Opt] = nil else Selected[Opt] = true end
				RefreshTick()
				RefreshLabel()
				if Callback then
					local List = {}
					for K in next, Selected do Insert(List, K) end
					Callback(List)
				end
			end)
			Insert(OptionBtns, OptBtn)
		end
	end

	BuildList()
	RefreshLabel()

	Connect(DropBtn.MouseButton1Click, function()
		if DropOpen then
			CloseList()
		else
			DropOpen = true
			local AbsPos = DropBtn.AbsolutePosition
			local AbsSize = DropBtn.AbsoluteSize
			local ContPos = Hub.Container.AbsolutePosition
			DropList.Position = UDim2.new(0, AbsPos.X - ContPos.X, 0, AbsPos.Y - ContPos.Y + AbsSize.Y + 4)
			DropList.Size = UDim2.new(0, AbsSize.X, 0, 0)
			DropList.Visible = true
		end
	end)

	Connect(ModalBtn.MouseButton1Click, function()
		if DropOpen then CloseList() end
	end)

	return {
		GetSelected = function()
			local List = {}
			for K in next, Selected do Insert(List, K) end
			return List
		end,
		UpdateDropDownList = function(NewOpts)
			Options = NewOpts
			Selected = {}
			BuildList()
			RefreshLabel()
		end,
	}
end

local function MakeSectionHeader(PageFrame, Title, IconName, Order)
	local HeaderRow = Create("Frame", {
		Name = Title .. "Header",
		Parent = PageFrame,
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = BaseZIndex + 2,
		LayoutOrder = Order or 0,
	})
	Create("UIPadding", {
		Parent = HeaderRow,
		PaddingTop = UDim.new(0, 14),
		PaddingBottom = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4),
	})
	local HeaderLayout = Create("Frame", {
		Name = "Layout",
		Parent = HeaderRow,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
	})
	Create("UIListLayout", {
		Parent = HeaderLayout,
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	if IconName and IconName ~= "" then
		local IconData = GetLucideIcon(IconName)
		Create("ImageLabel", {
			Parent = HeaderLayout,
			Size = UDim2.new(0, 14, 0, 14),
			BackgroundTransparency = 1,
			Image = IconData and IconData[1] or "",
			ImageRectSize = IconData and IconData[2].ImageRectSize or Vector2.new(0, 0),
			ImageRectOffset = IconData and IconData[2].ImageRectPosition or Vector2.new(0, 0),
			ImageColor3 = ColorMuted,
			ZIndex = BaseZIndex + 3,
			LayoutOrder = 0,
		})
	end
	Create("TextLabel", {
		Name = "Title",
		Parent = HeaderLayout,
		Size = UDim2.new(0, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		TextColor3 = ColorMuted,
		TextSize = 13,
		Font = Enum.Font.BuilderSansMedium,
		Text = string.upper(Title),
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		ZIndex = BaseZIndex + 3,
		LayoutOrder = 1,
	})
	return HeaderRow
end

local PlayersPage = MakePage("Players")
local SettingsPage = MakePage("Settings")
local ReportPage = MakePage("Report")
local HelpPage = MakePage("Help")
local RecordPage = MakePage("Record")
local ResetPage = MakePage("Reset")
local LeavePage = MakePage("Leave")

AddPage(PlayersPage, "People", "Users")
AddPage(SettingsPage, "Settings", "Settings")
AddPage(ReportPage, "Report", "Flag")
AddPage(HelpPage, "Help", "LifeBuoy")
AddPage(RecordPage, "Record", "Video")
AddPage(ResetPage, "Reset", "RotateCcw")
AddPage(LeavePage, "Leave", "LogOut")

local function BuildPlayersPage()
	MakeSectionHeader(PlayersPage.Frame, "Players", "", 0)
	local function AddPlayerRow(Player)
		local Row = MakeRow(PlayersPage.Frame, Player.DisplayName ~= Player.Name and (Player.DisplayName .. " (@" .. Player.Name .. ")") or Player.Name)
		Row.LayoutOrder = 1
		local MuteBtn = Create("ImageButton", {
			Name = "MuteButton",
			Parent = Row,
			Position = UDim2.new(1, -8, 0.5, 0),
			AnchorPoint = Vector2.new(1, 0.5),
			Size = UDim2.new(0, 80, 0, 30),
			BackgroundColor3 = ColorInput,
			BackgroundTransparency = 0,
			Image = "",
			AutoButtonColor = false,
			ZIndex = BaseZIndex + 3,
		})
		Create("UICorner", {Parent = MuteBtn, CornerRadius = UDim.new(0, 8)})
		Create("TextLabel", {
			Parent = MuteBtn,
			Size = UDim2.new(1, 0, 1, 0),
			TextColor3 = ColorWhite,
			TextSize = 13,
			Font = Enum.Font.BuilderSans,
			Text = "Mute",
			BackgroundTransparency = 1,
			ZIndex = BaseZIndex + 4,
		})
		Connect(MuteBtn.MouseButton1Click, function()
			Protect(function()
				local VoiceChatService = game:GetService("VoiceChatService")
				VoiceChatService:SetMutedAsync(Player.UserId, true)
			end)
		end)
	end
	for _, P in next, Players:GetPlayers() do
		if P ~= LocalPlayer then
			AddPlayerRow(P)
		end
	end
	Connect(Players.PlayerAdded, function(P) if P ~= LocalPlayer then AddPlayerRow(P) end end)
end

local function BuildSettingsPage()
	MakeSectionHeader(SettingsPage.Frame, "Controls", "Gamepad2", 0)

	local ShiftRow = MakeRow(SettingsPage.Frame, "Shift Lock Switch")
	ShiftRow.LayoutOrder = 1
	local ShiftState = false
	Protect(function()
		ShiftState = UserSettings().GameSettings.ShiftLockMode ~= Enum.ShiftLockMode.Enabled and false or true
	end)
	MakeToggleWidget(ShiftRow, ShiftState, function(Val)
		Protect(function()
			if Val then
				UserSettings().GameSettings.ShiftLockMode = Enum.ShiftLockMode.Enabled
			else
				UserSettings().GameSettings.ShiftLockMode = Enum.ShiftLockMode.Disabled
			end
		end)
	end)

	local CameraRow = MakeRow(SettingsPage.Frame, "Camera Mode")
	CameraRow.LayoutOrder = 2
	local CamModes = {"Default", "Classic", "Follow"}
	local CamDefault = 1
	Protect(function()
		local Mode = UserSettings().GameSettings.CameraMode
		if Mode == Enum.CameraMode.Classic then CamDefault = 2 end
		if Mode == Enum.CameraMode.LockFirstPerson then CamDefault = 3 end
	end)
	MakeSelectorWidget(CameraRow, CamModes, CamDefault, function(Val)
		Protect(function()
			if Val == "Classic" then
				UserSettings().GameSettings.CameraMode = Enum.CameraMode.Classic
			else
				UserSettings().GameSettings.CameraMode = Enum.CameraMode.Default
			end
		end)
	end)

	MakeSectionHeader(SettingsPage.Frame, "Audio", "Volume2", 10)

	local VolRow = MakeRow(SettingsPage.Frame, "Master Volume")
	VolRow.LayoutOrder = 11
	local VolDefault = 1
	Protect(function() VolDefault = UserSettings().GameSettings.MasterVolume end)
	MakeSliderWidget(VolRow, 0, 1, VolDefault, 0.05, function(Val)
		Protect(function()
			UserSettings().GameSettings.MasterVolume = Val
			SoundService.Volume = Val
		end)
	end)

	MakeSectionHeader(SettingsPage.Frame, "Sensitivity", "Mouse", 20)

	local SensRow = MakeRow(SettingsPage.Frame, "Mouse Sensitivity")
	SensRow.LayoutOrder = 21
	local SensDefault = 0.5
	Protect(function() SensDefault = UserSettings().GameSettings.MouseSensitivity end)
	MakeSliderWidget(SensRow, 0, 1, SensDefault, 0.01, function(Val)
		Protect(function()
			UserSettings().GameSettings.MouseSensitivity = Val
			UserInputService.MouseDeltaSensitivity = Val
		end)
	end)

	MakeSectionHeader(SettingsPage.Frame, "Graphics", "Monitor", 30)

	local GfxRow = MakeRow(SettingsPage.Frame, "Graphics Quality")
	GfxRow.LayoutOrder = 31
	local GfxDefault = 1
	Protect(function() GfxDefault = settings().Rendering.QualityLevel end)
	MakeSliderWidget(GfxRow, 1, 21, GfxDefault, 1, function(Val)
		Protect(function() settings().Rendering.QualityLevel = Floor(Val) end)
	end)

	local FpsRow = MakeRow(SettingsPage.Frame, "Frame Rate Cap")
	FpsRow.LayoutOrder = 32
	local FpsModes = {"30", "60", "120", "240", "Unlimited"}
	MakeSelectorWidget(FpsRow, FpsModes, 2, function(Val)
		Protect(function()
			local Cap = tonumber(Val)
			if Cap then
				workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
			end
		end)
	end)
end

local function BuildReportPage()
	MakeSectionHeader(ReportPage.Frame, "Report Abuse", "Flag", 0)

	local TypeRow = MakeRow(ReportPage.Frame, "Report Type")
	TypeRow.LayoutOrder = 1
	MakeSelectorWidget(TypeRow, {"Player", "Game"}, 1, nil)

	local ReasonRow = MakeRow(ReportPage.Frame, "Reason")
	ReasonRow.LayoutOrder = 2
	local ReasonAbuse = {"Swearing", "Inappropriate Username", "Bullying", "Scamming", "Dating", "Cheating/Exploiting", "Personal Question", "Offsite Links"}
	local ReasonControl = MakeSelectorWidget(ReasonRow, ReasonAbuse, 1, nil)

	local DescRow = MakeRow(ReportPage.Frame, "Description")
	DescRow.LayoutOrder = 3
	MakeValueWidget(DescRow, "", nil)

	local SubmitRow = MakeRow(ReportPage.Frame, "")
	SubmitRow.LayoutOrder = 4
	MakeButtonWidget(SubmitRow, "Submit Report", function()
		local TargetPlayer = Hub.ReportTarget
		if TargetPlayer then
			Protect(function()
				game:GetService("ReportService"):ReportAbuseV3(TargetPlayer, ReasonControl.GetValue())
			end)
		end
	end)
end

local function BuildHelpPage()
	MakeSectionHeader(HelpPage.Frame, "Help", "LifeBuoy", 0)

	local HelpItems = {
		{Name = "Report a Player", Desc = "Use the Report tab to report inappropriate behavior."},
		{Name = "Reset Character", Desc = "Use the Reset tab to respawn your character."},
		{Name = "Leave Game", Desc = "Use the Leave tab to safely exit the game."},
		{Name = "Settings", Desc = "Use the Settings tab to customize your experience."},
	}

	for I, Item in next, HelpItems do
		local Row = MakeRow(HelpPage.Frame, Item.Name)
		Row.LayoutOrder = I
		Row.Size = UDim2.new(1, 0, 0, 64)
		Create("TextLabel", {
			Parent = Row,
			Position = UDim2.new(0, 10, 0, 28),
			Size = UDim2.new(0.85, -10, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			TextColor3 = ColorMuted,
			TextSize = 14,
			Font = Enum.Font.BuilderSans,
			Text = Item.Desc,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			ZIndex = BaseZIndex + 3,
		})
	end
end

local function BuildRecordPage()
	MakeSectionHeader(RecordPage.Frame, "Video Capture", "Video", 0)

	local RecordRow = MakeRow(RecordPage.Frame, "Record Gameplay")
	RecordRow.LayoutOrder = 1
	local Recording = false
	MakeButtonWidget(RecordRow, "Start Recording", function()
		Recording = not Recording
		Protect(function()
			if Recording then
				game:GetService("VideoUploadService"):PublishVideo(true)
			else
				game:GetService("VideoUploadService"):PublishVideo(false)
			end
		end)
	end)

	local ScreenshotRow = MakeRow(RecordPage.Frame, "Take Screenshot")
	ScreenshotRow.LayoutOrder = 2
	MakeButtonWidget(ScreenshotRow, "Screenshot", function()
		Protect(function()
			game:GetService("ScreenshotHud"):TakeScreenshot()
		end)
	end)
end

local function BuildResetPage()
	MakeSectionHeader(ResetPage.Frame, "Reset Character", "RotateCcw", 0)

	local InfoRow = MakeRow(ResetPage.Frame, "Confirm Reset")
	InfoRow.LayoutOrder = 1
	Create("TextLabel", {
		Parent = InfoRow,
		Position = UDim2.new(0, 10, 0, 28),
		Size = UDim2.new(0.85, -10, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextColor3 = ColorMuted,
		TextSize = 14,
		Font = Enum.Font.BuilderSans,
		Text = "Resetting will respawn your character at the last checkpoint.",
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		ZIndex = BaseZIndex + 3,
	})
	InfoRow.Size = UDim2.new(1, 0, 0, 64)

	local ResetBtnRow = MakeRow(ResetPage.Frame, "")
	ResetBtnRow.LayoutOrder = 2
	MakeButtonWidget(ResetBtnRow, "Reset Character", function()
		local Char = LocalPlayer.Character
		if Char then
			local Hum = Char:FindFirstChildOfClass("Humanoid")
			if Hum then Hum.Health = 0 end
		end
	end)
end

local function BuildLeavePage()
	MakeSectionHeader(LeavePage.Frame, "Leave Game", "LogOut", 0)

	local InfoRow = MakeRow(LeavePage.Frame, "Leave Game")
	InfoRow.LayoutOrder = 1
	InfoRow.Size = UDim2.new(1, 0, 0, 64)
	Create("TextLabel", {
		Parent = InfoRow,
		Position = UDim2.new(0, 10, 0, 28),
		Size = UDim2.new(0.85, -10, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		TextColor3 = ColorMuted,
		TextSize = 14,
		Font = Enum.Font.BuilderSans,
		Text = "You will be disconnected and returned to the Roblox home screen.",
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		ZIndex = BaseZIndex + 3,
	})

	local LeaveBtnRow = MakeRow(LeavePage.Frame, "")
	LeaveBtnRow.LayoutOrder = 2
	local LeaveBtn = Create("ImageButton", {
		Name = "LeaveButton",
		Parent = LeaveBtnRow,
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		Size = UDim2.new(0.6, 0, 0, 32),
		BackgroundColor3 = ColorDanger,
		BackgroundTransparency = 0,
		Image = "",
		AutoButtonColor = false,
		ZIndex = BaseZIndex + 3,
	})
	Create("UICorner", {Parent = LeaveBtn, CornerRadius = UDim.new(0, 8)})
	Create("TextLabel", {
		Parent = LeaveBtn,
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		TextColor3 = ColorWhite,
		TextSize = 15,
		Font = Enum.Font.BuilderSansMedium,
		Text = "Leave Game",
		TextXAlignment = Enum.TextXAlignment.Center,
		BackgroundTransparency = 1,
		ZIndex = BaseZIndex + 4,
	})
	Connect(LeaveBtn.MouseEnter, function() LeaveBtn.BackgroundColor3 = Color3.fromRGB(190, 35, 35) end)
	Connect(LeaveBtn.MouseLeave, function() LeaveBtn.BackgroundColor3 = ColorDanger end)
	Connect(LeaveBtn.MouseButton1Click, function()
		Protect(function() LocalPlayer:Kick("You left the game.") end)
		Protect(function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end)
	end)
end

BuildPlayersPage()
BuildSettingsPage()
BuildReportPage()
BuildHelpPage()
BuildRecordPage()
BuildResetPage()
BuildLeavePage()

SwitchToPage(SettingsPage, true)

SetVisibility = function(Val)
	if Val == Hub.Visible then return end
	Hub.Visible = Val
	Shield.Visible = Val
	if Val then
		SwitchToPage(Hub.CurrentPage or SettingsPage)
	end
end

local function ToggleVisibility()
	SetVisibility(not Hub.Visible)
end

local function GetVisibility()
	return Hub.Visible
end

Connect(ModalBtn.MouseButton1Click, function()
	SetVisibility(false)
end)

Connect(UserInputService.InputBegan, function(Input, Processed)
	if Processed or InputLocked then return end
	if Input.KeyCode == Enum.KeyCode.Escape then
		if Hub.Visible then
			SetVisibility(false)
		end
	end
end)

local function TryHookNativeMenu()
	Protect(function()
		local GS = GuiService
		Connect(GS.MenuOpened, function()
			SetVisibility(true)
			Protect(function() GS:SetMenuOpen(false) end)
		end)
	end)
end

TryHookNativeMenu()

local function MakeTabApi(Page)
	local RowOrder = 100
	local TabApi = {}

	function TabApi:AddSectionHeader(Title, IconName)
		RowOrder = RowOrder + 1
		MakeSectionHeader(Page.Frame, Title, IconName or "", RowOrder)
	end

	function TabApi:AddSlider(Name, Min, Max, Default, Step, Callback)
		RowOrder = RowOrder + 1
		local Row = MakeRow(Page.Frame, Name)
		Row.LayoutOrder = RowOrder
		return MakeSliderWidget(Row, Min, Max, Default, Step, Callback)
	end

	function TabApi:AddSelector(Name, Options, Default, Callback)
		RowOrder = RowOrder + 1
		local Row = MakeRow(Page.Frame, Name)
		Row.LayoutOrder = RowOrder
		local DefaultIndex = 1
		if type(Default) == "number" then
			DefaultIndex = Default
		elseif Default then
			for I, V in next, Options do
				if V == Default then DefaultIndex = I break end
			end
		end
		return MakeSelectorWidget(Row, Options, DefaultIndex, Callback)
	end

	function TabApi:AddToggle(Name, Default, Callback)
		RowOrder = RowOrder + 1
		local Row = MakeRow(Page.Frame, Name)
		Row.LayoutOrder = RowOrder
		return MakeToggleWidget(Row, Default, Callback)
	end

	function TabApi:AddButton(Name, ButtonText, Callback)
		RowOrder = RowOrder + 1
		local Row = MakeRow(Page.Frame, Name)
		Row.LayoutOrder = RowOrder
		MakeButtonWidget(Row, ButtonText or Name, Callback)
	end

	function TabApi:AddDropDown(Name, Options, Default, Callback)
		RowOrder = RowOrder + 1
		local Row = MakeRow(Page.Frame, Name)
		Row.LayoutOrder = RowOrder
		local DefaultIndex = 1
		if type(Default) == "number" then
			DefaultIndex = Default
		elseif Default then
			for I, V in next, Options do
				if V == Default then DefaultIndex = I break end
			end
		end
		return MakeDropDownWidget(Row, Options, DefaultIndex, Callback)
	end

	function TabApi:AddMultiDropDown(Name, Options, Callback)
		RowOrder = RowOrder + 1
		local Row = MakeRow(Page.Frame, Name)
		Row.LayoutOrder = RowOrder
		return MakeMultiDropDownWidget(Row, Options, Callback)
	end

	function TabApi:AddValue(Name, Default, Callback)
		RowOrder = RowOrder + 1
		local Row = MakeRow(Page.Frame, Name)
		Row.LayoutOrder = RowOrder
		return MakeValueWidget(Row, Default, Callback)
	end

	function TabApi:AddRow(CustomRow)
		RowOrder = RowOrder + 1
		CustomRow.LayoutOrder = RowOrder
		CustomRow.Parent = Page.Frame
	end

	return TabApi
end

local UserTabMap = {}

local Api = {}

function Api:Hijack(TabName)
	local TargetPage = nil
	for _, P in next, Hub.Pages do
		if P.Name:lower() == TabName:lower() then
			TargetPage = P
			break
		end
	end
	if not TargetPage then
		return Api:CreateTab(TabName, "Settings", nil)
	end
	if not UserTabMap[TargetPage.Name] then
		UserTabMap[TargetPage.Name] = MakeTabApi(TargetPage)
	end
	return UserTabMap[TargetPage.Name]
end

function Api:CreateTab(Name, IconName, Width)
	local ExistingPage = nil
	for _, P in next, Hub.Pages do
		if P.Name:lower() == Name:lower() then
			ExistingPage = P
			break
		end
	end
	if ExistingPage then
		if not UserTabMap[ExistingPage.Name] then
			UserTabMap[ExistingPage.Name] = MakeTabApi(ExistingPage)
		end
		return UserTabMap[ExistingPage.Name]
	end
	local NewPage = MakePage(Name)
	AddPage(NewPage, Name, IconName or "Settings")
	local TabApiInst = MakeTabApi(NewPage)
	UserTabMap[Name] = TabApiInst
	return TabApiInst
end

function Api:SetVisibility(Val)
	SetVisibility(Val)
end

function Api:ToggleVisibility()
	ToggleVisibility()
end

function Api:GetVisibility()
	return GetVisibility()
end

function Api:SwitchToTab(TabName)
	for _, P in next, Hub.Pages do
		if P.Name:lower() == TabName:lower() then
			SwitchToPage(P)
			return
		end
	end
end

function Api:ReportPlayer(Player)
	Hub.ReportTarget = Player
	SwitchToPage(ReportPage)
	SetVisibility(true)
end

getgenv().SettingHub = Api

return Api
