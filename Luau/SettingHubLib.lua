local CoreGui = game:GetService("CoreGui")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")
local HttpService = game:GetService("HttpService")

local VirtualInputManager = nil
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)

local LocalPlayer = Players.LocalPlayer
local GameSettings = UserSettings().GameSettings
local RenderingSettings = settings().Rendering

local Spawn, Wait = task.spawn, task.wait
local Insert = table.insert
local Clamp, Floor = math.clamp, math.floor

local ColorBackground = Color3.fromRGB(18, 18, 21)
local ColorSurface = Color3.fromRGB(28, 30, 36)
local ColorHover = Color3.fromRGB(35, 38, 46)
local ColorBorder = Color3.fromRGB(45, 48, 58)
local ColorAccent = Color3.fromRGB(0, 162, 255)
local ColorWhite = Color3.fromRGB(247, 247, 248)
local ColorText = Color3.fromRGB(213, 215, 221)
local ColorMuted = Color3.fromRGB(110, 115, 135)
local ColorFill = Color3.fromRGB(0, 162, 255)
local ColorTrack = Color3.fromRGB(55, 58, 70)
local ColorDanger = Color3.fromRGB(200, 45, 45)

local BaseZIndex = 200
local PositionHidden = UDim2.new(0, 0, -1.2, 0)
local PositionShown = UDim2.new(0, 0, 0, 0)
local PagePad = 8

local DescPlaceholder = "Short Description (Optional)"
local DescFallback = "Report Reason"
local KeyF12 = 0x7B
local KeyPrint = 0x2C

local AbusePlayer = {"Swearing","Inappropriate Username","Bullying","Scamming","Dating","Cheating/Exploiting","Personal Question","Offsite Links"}
local AbuseGame = {"Inappropriate Content","Bad Model or Script","Offsite Link"}

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

local MoveTweens = {}

local function LerpUDim(A, B, T)
	return UDim.new(A.Scale + (B.Scale - A.Scale) * T, A.Offset + (B.Offset - A.Offset) * T)
end

local function LerpUDim2(A, B, T)
	return UDim2.new(LerpUDim(A.X, B.X, T), LerpUDim(A.Y, B.Y, T))
end

local function LerpColor(A, B, T)
	return Color3.new(A.R + (B.R - A.R) * T, A.G + (B.G - A.G) * T, A.B + (B.B - A.B) * T)
end

local function MoveTo(Obj, Pos, Cb, Frames)
	MoveTweens[Obj] = (MoveTweens[Obj] or 0) + 1
	local Id = MoveTweens[Obj]
	Spawn(function()
		local Start = Obj.Position
		Frames = Frames or 8
		for I = 1, Frames do
			if not Obj.Parent or MoveTweens[Obj] ~= Id then return end
			local A = I / Frames
			A = 1 - (1 - A) * (1 - A)
			Obj.Position = LerpUDim2(Start, Pos, A)
			Wait()
		end
		Obj.Position = Pos
		if Cb and MoveTweens[Obj] == Id then Cb() end
	end)
end

local function TweenTo(Obj, Pos, Dir, Style, Time, Cb)
	MoveTweens[Obj] = (MoveTweens[Obj] or 0) + 1
	local Id = MoveTweens[Obj]
	local Ok = Protect(function()
		Obj:TweenPosition(Pos, Dir, Style, Time, true, function()
			if MoveTweens[Obj] ~= Id then return end
			Obj.Position = Pos
			if Cb then Cb() end
		end)
	end)
	if not Ok then
		MoveTo(Obj, Pos, Cb, math.max(1, Floor((Time or 0.1) * 60)))
	end
end

local ColorTweens = {}
local function ColorTo(Obj, Color)
	ColorTweens[Obj] = (ColorTweens[Obj] or 0) + 1
	local Id = ColorTweens[Obj]
	Spawn(function()
		local Start = Obj.BackgroundColor3
		for I = 1, 6 do
			if not Obj.Parent or ColorTweens[Obj] ~= Id then return end
			Obj.BackgroundColor3 = LerpColor(Start, Color, I / 6)
			Wait()
		end
	end)
end

local function FadeText(Label, Target)
	Spawn(function()
		local Start = Label.TextTransparency
		for I = 1, 6 do
			if not Label.Parent then return end
			Label.TextTransparency = Start + (Target - Start) * (I / 6)
			Wait()
		end
	end)
end

local function SetMouseSensitivity(Value)
	Protect(function() UserSettings().GameSettings.MouseSensitivity = Value end)
	Protect(function() UserInputService.MouseDeltaSensitivity = Value end)
end

local function SetMasterVolume(Value)
	Protect(function() UserSettings().GameSettings.MasterVolume = Value end)
	Protect(function() SoundService.Volume = Value end)
end

local ScreenGui = Create("ScreenGui", {
	Name = "SettingHubGui",
	Parent = CoreGui,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 9000,
	Enabled = true,
})
Insert(Data.Objects, ScreenGui)

local VolumeSound = Create("Sound", {
	Parent = SoundService,
	SoundId = "rbxasset://sounds/uuhhh.mp3",
	Volume = 1,
})
Insert(Data.Objects, VolumeSound)

local function PlayVolumeSound()
	Protect(function() VolumeSound:Stop(); VolumeSound:Play() end)
end

local Hub = {
	Visible = false,
	Pages = {},
	MenuStack = {},
	CurrentPage = nil,
	NativeMenuTarget = nil,
	SuppressNativeOpenUntil = 0,
}

local ClippingShield = Create("Frame", {
	Name = "ClippingShield",
	Parent = ScreenGui,
	Size = UDim2.new(1, 0, 1, 0),
	Position = PositionShown,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	ZIndex = BaseZIndex,
})

local DarkenBg = Create("ImageButton", {
	Name = "DarkenBackground",
	Parent = ClippingShield,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0.5,
	Image = "",
	AutoButtonColor = false,
	Active = true,
	Modal = true,
	Visible = false,
	ZIndex = BaseZIndex,
})

Hub.Shield = Create("Frame", {
	Name = "SettingsShield",
	Parent = ClippingShield,
	Size = UDim2.new(1, 0, 1, 0),
	Position = PositionHidden,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Visible = false,
	ZIndex = BaseZIndex,
})

Hub.Modal = Create("TextButton", {
	Name = "Modal",
	Parent = Hub.Shield,
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0, 0),
	Size = UDim2.new(1, 0, 1, 0),
	Text = "",
	Active = true,
	AutoButtonColor = false,
	Modal = true,
	ZIndex = BaseZIndex,
})

Hub.Container = Create("ImageButton", {
	Name = "MenuContainer",
	Parent = Hub.Shield,
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 10),
	Size = UDim2.new(0, 0, 0, 0),
	AutomaticSize = Enum.AutomaticSize.XY,
	BackgroundColor3 = ColorBackground,
	BackgroundTransparency = 0,
	Image = "",
	AutoButtonColor = false,
	Active = false,
	Selectable = false,
	ZIndex = BaseZIndex + 1,
})
Create("UICorner", {Parent = Hub.Container, CornerRadius = UDim.new(0, 12)})
Create("UIStroke", {Parent = Hub.Container, Color = ColorBorder, Thickness = 1, Transparency = 0})
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
	Size = UDim2.new(0, 840, 0, 58),
	BackgroundColor3 = ColorBackground,
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	LayoutOrder = 0,
	ZIndex = BaseZIndex + 1,
})
Create("UICorner", {Parent = Hub.HubBar, CornerRadius = UDim.new(0, 12)})
Create("Frame", {
	Parent = Hub.HubBar,
	Size = UDim2.new(1, 0, 0, 1),
	Position = UDim2.new(0, 0, 1, -1),
	BackgroundColor3 = ColorBorder,
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	ZIndex = BaseZIndex + 2,
})

Hub.TabList = Create("Frame", {
	Name = "TabList",
	Parent = Hub.HubBar,
	Size = UDim2.new(1, -56, 1, 0),
	BackgroundTransparency = 1,
	ZIndex = BaseZIndex + 2,
})
Create("UIListLayout", {
	Parent = Hub.TabList,
	SortOrder = Enum.SortOrder.LayoutOrder,
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Left,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0, 0),
})
Create("UIPadding", {Parent = Hub.TabList, PaddingLeft = UDim.new(0, 8)})

local CloseBtn = Create("ImageButton", {
	Name = "CloseButton",
	Parent = Hub.HubBar,
	Size = UDim2.new(0, 32, 0, 32),
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -12, 0.5, 0),
	BackgroundColor3 = ColorHover,
	BackgroundTransparency = 0,
	Image = "",
	AutoButtonColor = false,
	ZIndex = BaseZIndex + 3,
})
Create("UICorner", {Parent = CloseBtn, CornerRadius = UDim.new(0, 8)})
Create("TextLabel", {
	Parent = CloseBtn,
	BackgroundTransparency = 1,
	Font = Enum.Font.BuilderSansMedium,
	TextSize = 16,
	TextColor3 = ColorText,
	Text = "x",
	Size = UDim2.new(1, 0, 1, 0),
	ZIndex = BaseZIndex + 4,
})
Connect(CloseBtn.MouseEnter, function() CloseBtn.BackgroundColor3 = ColorDanger end)
Connect(CloseBtn.MouseLeave, function() CloseBtn.BackgroundColor3 = ColorHover end)

Hub.PageClipper = Create("Frame", {
	Name = "PageClipper",
	Parent = Hub.Container,
	Size = UDim2.new(0, 840, 0, 480),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ClipsDescendants = true,
	LayoutOrder = 1,
	ZIndex = BaseZIndex + 1,
})

Hub.PageView = Create("ScrollingFrame", {
	Name = "PageView",
	Parent = Hub.PageClipper,
	Size = UDim2.new(1, 0, 1, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(0, 0, 0, 0),
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = ColorBorder,
	ZIndex = BaseZIndex + 1,
})

Hub.BottomBar = Create("Frame", {
	Name = "BottomBar",
	Parent = Hub.Container,
	Size = UDim2.new(0, 840, 0, 56),
	BackgroundColor3 = ColorBackground,
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	LayoutOrder = 2,
	ZIndex = BaseZIndex + 1,
})
Create("UICorner", {Parent = Hub.BottomBar, CornerRadius = UDim.new(0, 12)})
Create("Frame", {
	Parent = Hub.BottomBar,
	Size = UDim2.new(1, 0, 0, 1),
	Position = UDim2.new(0, 0, 0, 0),
	BackgroundColor3 = ColorBorder,
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	ZIndex = BaseZIndex + 2,
})
Create("UIListLayout", {
	Parent = Hub.BottomBar,
	SortOrder = Enum.SortOrder.LayoutOrder,
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0, 4),
})

local function ResizeHub()
	local Viewport = ScreenGui.AbsoluteSize
	if Viewport.X <= 0 or Viewport.Y <= 0 then
		local Cam = workspace.CurrentCamera
		Viewport = (Cam and Cam.ViewportSize) or Vector2.new(1280, 720)
	end
	local Width = Clamp(Viewport.X - 40, 520, 840)
	local Height = Clamp(Viewport.Y - 160, 200, 480)
	Hub.HubBar.Size = UDim2.new(0, Width, 0, 58)
	Hub.PageClipper.Size = UDim2.new(0, Width, 0, Height)
	Hub.BottomBar.Size = UDim2.new(0, Width, 0, 56)
end

ResizeHub()
Connect(ScreenGui:GetPropertyChangedSignal("AbsoluteSize"), ResizeHub)
Connect(workspace:GetPropertyChangedSignal("CurrentCamera"), ResizeHub)
if workspace.CurrentCamera then
	Connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), ResizeHub)
end

local SwitchToPage
local SetVisibility

local function MakePage(Name)
	local Page = {
		Name = Name,
		Rows = {},
		Frame = Create("Frame", {
			Name = Name .. "Page",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			Visible = false,
			ZIndex = BaseZIndex + 1,
		}),
	}
	local Layout = Create("UIListLayout", {
		Parent = Page.Frame,
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Padding = UDim.new(0, 0),
	})
	Create("UIPadding", {
		Parent = Page.Frame,
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
	})
	Connect(Layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		Page.Frame.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y + 20)
	end)
	function Page:AddRow(Row)
		Row.Parent = self.Frame
		Insert(self.Rows, Row)
	end
	return Page
end

local function MakeTab(Page, Title, IconName, Width)
	Width = Width or 120
	local Tab = Create("TextButton", {
		Name = Page.Name .. "Tab",
		Parent = Hub.TabList,
		BackgroundTransparency = 1,
		Text = "",
		Size = UDim2.new(0, Width, 1, 0),
		ZIndex = BaseZIndex + 3,
		AutoButtonColor = false,
	})
	local IconData = GetLucideIcon(IconName)
	local Icon = Create("ImageLabel", {
		Name = "Icon",
		Parent = Tab,
		BackgroundTransparency = 1,
		Image = IconData and IconData[1] or "",
		ImageRectSize = IconData and IconData[2].ImageRectSize or Vector2.new(0, 0),
		ImageRectOffset = IconData and IconData[2].ImageRectPosition or Vector2.new(0, 0),
		ImageColor3 = ColorMuted,
		Size = UDim2.new(0, 16, 0, 16),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		ZIndex = BaseZIndex + 4,
	})
	local TitleLabel = Create("TextLabel", {
		Name = "Title",
		Parent = Tab,
		BackgroundTransparency = 1,
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 13,
		TextColor3 = ColorMuted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = Title,
		Size = UDim2.new(1, -34, 1, 0),
		Position = UDim2.new(0, 34, 0, 0),
		ZIndex = BaseZIndex + 4,
	})
	local Underline = Create("Frame", {
		Name = "Underline",
		Parent = Tab,
		BackgroundColor3 = ColorAccent,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Visible = false,
		Size = UDim2.new(1, -20, 0, 2),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 0),
		ZIndex = BaseZIndex + 5,
	})
	Create("UICorner", {Parent = Underline, CornerRadius = UDim.new(1, 0)})
	Page.Tab = Tab
	Page.TabIcon = Icon
	Page.TabTitle = TitleLabel
	Page.TabUnderline = Underline
	Connect(Tab.MouseButton1Click, function() SwitchToPage(Page) end)
	Connect(Tab.MouseEnter, function()
		if not Underline.Visible then
			TitleLabel.TextColor3 = ColorText
			Icon.ImageColor3 = ColorText
		end
	end)
	Connect(Tab.MouseLeave, function()
		if not Underline.Visible then
			TitleLabel.TextColor3 = ColorMuted
			Icon.ImageColor3 = ColorMuted
		end
	end)
end

local function GetPageIndex(Page)
	for I, P in next, Hub.Pages do
		if P == Page then return I end
	end
	return 1
end

SwitchToPage = function(Page, NoStack, NoAnimation)
	if not Page then return end
	local OldPage = Hub.CurrentPage
	local OldFrame = OldPage and OldPage.Frame
	local Direction = (GetPageIndex(Page) >= GetPageIndex(OldPage) and 1) or -1
	for _, P in next, Hub.Pages do
		if P.Frame and P ~= Page and P ~= OldPage then
			P.Frame.Visible = false
		end
		if P.TabUnderline then
			P.TabUnderline.Visible = false
			if P.TabTitle then P.TabTitle.TextColor3 = ColorMuted end
			if P.TabIcon then P.TabIcon.ImageColor3 = ColorMuted end
		end
	end
	Page.Frame.Parent = Hub.PageView
	Page.Frame.Visible = true
	if OldFrame and OldFrame ~= Page.Frame and OldFrame.Parent == Hub.PageView and OldFrame.Visible and not NoAnimation then
		local PageWidth = math.max(Hub.PageClipper.AbsoluteSize.X, 840)
		Page.Frame.Position = UDim2.new(0, Direction * PageWidth, 0, PagePad)
		TweenTo(Page.Frame, UDim2.new(0, 0, 0, PagePad), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.1)
		TweenTo(OldFrame, UDim2.new(0, -Direction * PageWidth, 0, PagePad), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1)
		task.delay(0.12, function()
			if Hub.CurrentPage ~= OldPage and OldFrame then
				OldFrame.Visible = false
			end
		end)
	else
		Page.Frame.Position = UDim2.new(0, 0, 0, PagePad)
		if OldFrame and OldFrame ~= Page.Frame then OldFrame.Visible = false end
	end
	Hub.PageView.CanvasPosition = Vector2.new(0, 0)
	Hub.PageView.CanvasSize = UDim2.new(0, 0, 0, math.max(Page.Frame.Size.Y.Offset + PagePad, Hub.PageClipper.AbsoluteSize.Y))
	Hub.CurrentPage = Page
	if Page.TabUnderline then
		Page.TabUnderline.Visible = true
		if Page.TabTitle then Page.TabTitle.TextColor3 = ColorWhite end
		if Page.TabIcon then Page.TabIcon.ImageColor3 = ColorAccent end
	end
	if not NoStack and Hub.MenuStack[#Hub.MenuStack] ~= Page then
		Insert(Hub.MenuStack, Page)
	end
end

local function AddPage(Page, Title, IconName, Width)
	Insert(Hub.Pages, Page)
	if Title then MakeTab(Page, Title, IconName, Width) end
end

local function MakeRow(Page, Name, Height)
	local Row = Create("Frame", {
		Name = Name .. "Row",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, Height or 48),
		ZIndex = BaseZIndex + 2,
	})
	if Name ~= "" then
		Create("TextLabel", {
			Name = "NameLabel",
			Parent = Row,
			BackgroundTransparency = 1,
			Font = Enum.Font.BuilderSansMedium,
			TextSize = 15,
			TextColor3 = ColorText,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center,
			Text = Name,
			Size = UDim2.new(0.45, 0, 1, 0),
			ZIndex = BaseZIndex + 3,
		})
	end
	Create("Frame", {
		Name = "Divider",
		Parent = Row,
		BackgroundColor3 = ColorBorder,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		ZIndex = BaseZIndex + 2,
	})
	Page:AddRow(Row)
	return Row
end

local function MakeSectionHeader(Page, Title, IconName)
	local Row = Create("Frame", {
		Name = Title .. "Header",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 36),
		ZIndex = BaseZIndex + 2,
	})
	local IconData = GetLucideIcon(IconName)
	Create("ImageLabel", {
		Name = "Icon",
		Parent = Row,
		BackgroundTransparency = 1,
		Image = IconData and IconData[1] or "",
		ImageRectSize = IconData and IconData[2].ImageRectSize or Vector2.new(0, 0),
		ImageRectOffset = IconData and IconData[2].ImageRectPosition or Vector2.new(0, 0),
		ImageColor3 = ColorAccent,
		Size = UDim2.new(0, 14, 0, 14),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.72, 0),
		ZIndex = BaseZIndex + 3,
	})
	Create("TextLabel", {
		Name = "Title",
		Parent = Row,
		BackgroundTransparency = 1,
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 11,
		TextColor3 = ColorAccent,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Bottom,
		Text = Title:upper(),
		Size = UDim2.new(1, -22, 1, 0),
		Position = UDim2.new(0, 20, 0, 0),
		ZIndex = BaseZIndex + 3,
	})
	Page:AddRow(Row)
	return Row
end

local function MakeStyledButton(Name, Text, Size, Clicked)
	local Btn = Create("ImageButton", {
		Name = Name,
		BackgroundColor3 = ColorHover,
		BackgroundTransparency = 0,
		Image = "",
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Size = Size,
		ZIndex = BaseZIndex + 3,
	})
	Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 6)})
	local Lbl = Create("TextLabel", {
		Name = Name .. "Label",
		Parent = Btn,
		BackgroundTransparency = 1,
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 13,
		TextColor3 = ColorText,
		Text = Text,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = BaseZIndex + 4,
	})
	Connect(Btn.MouseEnter, function() ColorTo(Btn, Color3.fromRGB(50, 53, 64)) end)
	Connect(Btn.MouseLeave, function() ColorTo(Btn, ColorHover) end)
	if Clicked then Connect(Btn.MouseButton1Click, Clicked) end
	return Btn, Lbl
end

local function MakeValueRow(Page, Name, Value)
	local Row = MakeRow(Page, Name)
	local ValLabel = Create("TextLabel", {
		Name = "Value",
		Parent = Row,
		BackgroundTransparency = 1,
		Font = Enum.Font.BuilderSans,
		TextSize = 14,
		TextColor3 = ColorMuted,
		TextXAlignment = Enum.TextXAlignment.Right,
		Text = tostring(Value or "Unavailable"),
		AnchorPoint = Vector2.new(1, 0),
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		ZIndex = BaseZIndex + 3,
	})
	return ValLabel, Row
end

local function MakeButtonRow(Page, Name, Text, Clicked)
	local Row = MakeRow(Page, Name)
	local Btn, Lbl = MakeStyledButton(Name .. "Action", Text, UDim2.new(0, 120, 0, 30), Clicked)
	Btn.Parent = Row
	Btn.AnchorPoint = Vector2.new(1, 0.5)
	Btn.Position = UDim2.new(1, 0, 0.5, 0)
	return Btn, Row
end

local function MakeSelector(Page, Name, Values, Index, Changed)
	local CurrentIndex = Index or 1
	local Row = MakeRow(Page, Name)
	local Container = Create("Frame", {
		Name = "SelectorContainer",
		Parent = Row,
		BackgroundTransparency = 1,
		Size = UDim2.new(0.52, 0, 0, 34),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		ZIndex = BaseZIndex + 3,
	})
	local Left = Create("ImageButton", {
		Name = "Left",
		Parent = Container,
		BackgroundTransparency = 1,
		Image = "",
		Size = UDim2.new(0, 28, 1, 0),
		ZIndex = BaseZIndex + 4,
		AutoButtonColor = false,
	})
	Create("TextLabel", {
		Parent = Left,
		BackgroundTransparency = 1,
		Text = "<",
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 15,
		TextColor3 = ColorText,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = BaseZIndex + 5,
	})
	local SelLabel = Create("TextLabel", {
		Name = "Selection",
		Parent = Container,
		BackgroundTransparency = 1,
		Font = Enum.Font.BuilderSans,
		TextSize = 14,
		TextColor3 = ColorText,
		Text = Values and Values[CurrentIndex] or "",
		Size = UDim2.new(1, -56, 1, 0),
		Position = UDim2.new(0, 28, 0, 0),
		ZIndex = BaseZIndex + 4,
	})
	local Right = Create("ImageButton", {
		Name = "Right",
		Parent = Container,
		BackgroundTransparency = 1,
		Image = "",
		Size = UDim2.new(0, 28, 1, 0),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		ZIndex = BaseZIndex + 4,
		AutoButtonColor = false,
	})
	Create("TextLabel", {
		Parent = Right,
		BackgroundTransparency = 1,
		Text = ">",
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 15,
		TextColor3 = ColorText,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = BaseZIndex + 5,
	})
	local Api = {CurrentIndex = CurrentIndex, SelectorFrame = Container, Selection = Container, RowFrame = Row, TextLabel = SelLabel, Interactable = true}
	local function SetText(Text, Dir)
		SelLabel.Text = Text
		SelLabel.Position = UDim2.new(0, 28 + (Dir or 0) * 10, 0, 0)
		SelLabel.TextTransparency = 0.7
		MoveTo(SelLabel, UDim2.new(0, 28, 0, 0))
		FadeText(SelLabel, 0)
	end
	local function Apply(Delta)
		if not Api.Interactable then return end
		CurrentIndex = CurrentIndex + Delta
		if CurrentIndex > #Values then CurrentIndex = 1
		elseif CurrentIndex < 1 then CurrentIndex = #Values end
		Api.CurrentIndex = CurrentIndex
		SetText(Values[CurrentIndex], Delta)
		if Changed then Changed(CurrentIndex, Values[CurrentIndex]) end
	end
	Connect(Left.MouseButton1Click, function() Apply(-1) end)
	Connect(Right.MouseButton1Click, function() Apply(1) end)
	function Api:SetSelectionIndex(Idx, Fire)
		if not Idx or not Values or #Values == 0 then return end
		CurrentIndex = Clamp(Idx, 1, #Values)
		Api.CurrentIndex = CurrentIndex
		SetText(Values[CurrentIndex], 0)
		if Changed and Fire then Changed(CurrentIndex, Values[CurrentIndex]) end
	end
	function Api:SetInteractable(I)
		Api.Interactable = I
		SelLabel.TextTransparency = I and 0 or 0.6
		Left.Visible = I
		Right.Visible = I
	end
	function Api:SetPosition(Pos) Container.Position = Pos end
	function Api:SetSize(Sz) Container.Size = Sz end
	function Api:GetSelectedIndex() return CurrentIndex end
	function Api:GetSelectedValue() return Values and Values[CurrentIndex] or nil end
	function Api:UpdateDropDownList(NewValues)
		Values = NewValues
		if CurrentIndex and #Values > 0 and CurrentIndex > #Values then
			CurrentIndex = nil; Api.CurrentIndex = nil
		end
		SelLabel.Text = (CurrentIndex and Values[CurrentIndex]) or "Choose One"
	end
	function Api:ResetSelectionIndex(Fire)
		CurrentIndex = nil; Api.CurrentIndex = nil
		SelLabel.Text = "Choose One"
		if Changed and Fire then Changed(nil, nil) end
	end
	return Api
end

local function MakeSlider(Page, Name, Steps, Index, Changed, MinStep)
	MinStep = MinStep or 0
	local CurrentIndex = Clamp(Index or 1, MinStep, Steps)
	local Row = MakeRow(Page, Name)
	local Container = Create("Frame", {
		Name = "SliderContainer",
		Parent = Row,
		BackgroundTransparency = 1,
		Size = UDim2.new(0.52, 0, 0, 34),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Active = true,
		ZIndex = BaseZIndex + 3,
	})
	local Left = Create("ImageButton", {
		Name = "Left",
		Parent = Container,
		BackgroundTransparency = 1,
		Image = "",
		Size = UDim2.new(0, 26, 1, 0),
		ZIndex = BaseZIndex + 4,
		AutoButtonColor = false,
	})
	Create("TextLabel", {
		Parent = Left,
		BackgroundTransparency = 1,
		Text = "-",
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 20,
		TextColor3 = ColorText,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = BaseZIndex + 5,
	})
	local Track = Create("Frame", {
		Name = "Track",
		Parent = Container,
		BackgroundColor3 = ColorTrack,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -52, 0, 4),
		Position = UDim2.new(0, 26, 0.5, -2),
		ZIndex = BaseZIndex + 3,
	})
	Create("UICorner", {Parent = Track, CornerRadius = UDim.new(1, 0)})
	local Fill = Create("Frame", {
		Name = "Fill",
		Parent = Track,
		BackgroundColor3 = ColorFill,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.new(Steps > 0 and CurrentIndex / Steps or 0, 0, 1, 0),
		ZIndex = BaseZIndex + 4,
	})
	Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
	local Right = Create("ImageButton", {
		Name = "Right",
		Parent = Container,
		BackgroundTransparency = 1,
		Image = "",
		Size = UDim2.new(0, 26, 1, 0),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		ZIndex = BaseZIndex + 4,
		AutoButtonColor = false,
	})
	Create("TextLabel", {
		Parent = Right,
		BackgroundTransparency = 1,
		Text = "+",
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 20,
		TextColor3 = ColorText,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = BaseZIndex + 5,
	})
	local Dragging = false
	local Api = {SliderFrame = Container, Selection = Container, RowFrame = Row, Interactable = true}
	local function Refresh()
		local Ratio = Steps > 0 and (CurrentIndex / Steps) or 0
		Fill.Size = UDim2.new(Ratio, 0, 1, 0)
		Left.Visible = Api.Interactable and CurrentIndex > MinStep
		Right.Visible = Api.Interactable and CurrentIndex < Steps
	end
	local function SetSliderValue(NewIndex)
		NewIndex = Clamp(NewIndex, MinStep, Steps)
		if CurrentIndex == NewIndex then return end
		CurrentIndex = NewIndex
		Refresh()
		if Changed then Changed(CurrentIndex) end
	end
	local function SetFromX(X)
		if not Api.Interactable then return end
		local AbsPos = Track.AbsolutePosition.X
		local AbsSize = Track.AbsoluteSize.X
		if AbsSize == 0 then return end
		local Alpha = Clamp((X - AbsPos) / AbsSize, 0, 1)
		if MinStep > 0 then
			SetSliderValue(Clamp(Floor(Alpha * Steps + 1), MinStep, Steps))
		else
			SetSliderValue(Clamp(Floor(Alpha * (Steps + 1)), 0, Steps))
		end
	end
	local Capture = Create("TextButton", {
		Parent = Track,
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Active = true,
		Size = UDim2.new(1, 0, 0, 20),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		ZIndex = BaseZIndex + 6,
	})
	Connect(Capture.InputBegan, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true; SetFromX(Input.Position.X)
		end
	end)
	Connect(UserInputService.InputChanged, function(Input)
		if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
			SetFromX(Input.Position.X)
		end
	end)
	Connect(UserInputService.InputEnded, function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = false
		end
	end)
	Connect(Left.MouseButton1Click, function() if Api.Interactable then SetSliderValue(CurrentIndex - 1) end end)
	Connect(Right.MouseButton1Click, function() if Api.Interactable then SetSliderValue(CurrentIndex + 1) end end)
	Refresh()
	function Api:SetValue(V) CurrentIndex = Clamp(V, MinStep, Steps); Refresh() end
	function Api:GetValue() return CurrentIndex end
	function Api:SetInteractable(I)
		Api.Interactable = I
		Fill.BackgroundTransparency = I and 0 or 0.5
		Refresh()
	end
	function Api:SetMinStep(S)
		MinStep = Clamp(S or 0, 0, Steps)
		CurrentIndex = Clamp(CurrentIndex, MinStep, Steps)
		Refresh()
	end
	function Api:SetZIndex(Z) Container.ZIndex = Z end
	return Api
end

local function MakeDropDown(Page, Name, Values, Index, Changed)
	local CurrentIndex = Index
	local Row = MakeRow(Page, Name)
	local Btn, Lbl = MakeStyledButton(Name .. "Dropdown", (Values and Values[CurrentIndex]) or "Choose One", UDim2.new(0, 160, 0, 30))
	Btn.Parent = Row
	Btn.AnchorPoint = Vector2.new(1, 0.5)
	Btn.Position = UDim2.new(1, 0, 0.5, 0)
	local DropApi = {CurrentIndex = CurrentIndex, DropDownFrame = Btn, Selection = Btn, Interactable = true}
	local Overlay = Create("TextButton", {
		Parent = ScreenGui,
		Visible = false,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Text = "",
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = BaseZIndex + 20,
	})
	local Panel = Create("Frame", {
		Parent = Overlay,
		BackgroundColor3 = ColorSurface,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 300, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		ZIndex = BaseZIndex + 21,
	})
	Create("UICorner", {Parent = Panel, CornerRadius = UDim.new(0, 10)})
	Create("UIStroke", {Parent = Panel, Color = ColorBorder, Thickness = 1})
	local List = Create("ScrollingFrame", {
		Parent = Panel,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 4,
		ZIndex = BaseZIndex + 22,
	})
	Create("UIListLayout", {
		Parent = List,
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 0),
	})
	Create("UIPadding", {Parent = List, PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6)})
	local function SetSelection(Idx, Fire)
		CurrentIndex = Idx
		DropApi.CurrentIndex = CurrentIndex
		local Val = CurrentIndex and Values[CurrentIndex] or nil
		Lbl.Text = Val or "Choose One"
		if Changed and Fire then Changed(CurrentIndex, Val) end
	end
	local function Rebuild(NewValues)
		Values = NewValues or Values
		if CurrentIndex and Values and CurrentIndex > #Values then
			CurrentIndex = nil; DropApi.CurrentIndex = nil
		end
		for _, C in next, List:GetChildren() do
			if C:IsA("TextButton") then C:Destroy() end
		end
		for I, V in next, (Values or {}) do
			local IsActive = I == CurrentIndex
			local Opt = Create("TextButton", {
				Parent = List,
				Name = "Option" .. I,
				BackgroundColor3 = ColorAccent,
				BackgroundTransparency = IsActive and 0.85 or 1,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Size = UDim2.new(1, 0, 0, 38),
				Font = Enum.Font.BuilderSans,
				TextSize = 14,
				TextColor3 = IsActive and ColorWhite or ColorText,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = V,
				ZIndex = BaseZIndex + 23,
			})
			Create("UIPadding", {Parent = Opt, PaddingLeft = UDim.new(0, 14)})
			Connect(Opt.MouseEnter, function() Opt.BackgroundTransparency = 0.9 end)
			Connect(Opt.MouseLeave, function() Opt.BackgroundTransparency = IsActive and 0.85 or 1 end)
			Connect(Opt.MouseButton1Click, function()
				IsActive = true
				SetSelection(I, true)
				Overlay.Visible = false
			end)
		end
		List.CanvasSize = UDim2.new(0, 0, 0, #(Values or {}) * 38 + 12)
		SetSelection(CurrentIndex, false)
	end
	Connect(Btn.MouseButton1Click, function()
		if DropApi.Interactable then Overlay.Visible = true end
	end)
	Connect(Overlay.MouseButton1Click, function() Overlay.Visible = false end)
	Rebuild(Values or {})
	function DropApi:UpdateDropDownList(New) Rebuild(New) end
	function DropApi:SetSelectionIndex(Idx, Fire)
		if not Idx or not Values or Idx < 1 or Idx > #Values then SetSelection(nil, Fire); return false end
		SetSelection(Idx, Fire); return true
	end
	function DropApi:SetSelectionByValue(Val, Fire)
		for I, V in next, (Values or {}) do
			if V == Val then SetSelection(I, Fire); return true end
		end
		return false
	end
	function DropApi:ResetSelectionIndex(Fire) SetSelection(nil, Fire) end
	function DropApi:GetSelectedIndex() return CurrentIndex end
	function DropApi:GetSelectedValue() return CurrentIndex and Values and Values[CurrentIndex] or nil end
	function DropApi:SetInteractable(I)
		DropApi.Interactable = I
		Btn.BackgroundTransparency = I and 0 or 0.5
		Btn.Active = I
	end
	return DropApi
end

local function MakeMultiDropDown(Page, Name, Values, Changed)
	local Selected = {}
	local Row = MakeRow(Page, Name)
	local Btn, Lbl = MakeStyledButton(Name .. "MultiDD", "All Players", UDim2.new(0, 160, 0, 30))
	Btn.Parent = Row
	Btn.AnchorPoint = Vector2.new(1, 0.5)
	Btn.Position = UDim2.new(1, 0, 0.5, 0)
	local function UpdateLabel()
		local Count = 0
		for _ in next, Selected do Count = Count + 1 end
		Lbl.Text = Count == 0 and "All Players" or (Count .. " Selected")
	end
	local Overlay = Create("TextButton", {
		Parent = ScreenGui,
		Visible = false,
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Text = "",
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = BaseZIndex + 20,
	})
	local Panel = Create("Frame", {
		Parent = Overlay,
		BackgroundColor3 = ColorSurface,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 300, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		ZIndex = BaseZIndex + 21,
	})
	Create("UICorner", {Parent = Panel, CornerRadius = UDim.new(0, 10)})
	Create("UIStroke", {Parent = Panel, Color = ColorBorder, Thickness = 1})
	Create("TextLabel", {
		Parent = Panel,
		BackgroundTransparency = 1,
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 13,
		TextColor3 = ColorAccent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = Name,
		Size = UDim2.new(1, -24, 0, 36),
		Position = UDim2.new(0, 14, 0, 0),
		ZIndex = BaseZIndex + 22,
	})
	local List = Create("ScrollingFrame", {
		Parent = Panel,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(0, 0, 0, 40),
		AutomaticSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 4,
		ZIndex = BaseZIndex + 22,
	})
	Create("UIListLayout", {
		Parent = List,
		SortOrder = Enum.SortOrder.LayoutOrder,
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 0),
	})
	Create("UIPadding", {Parent = List, PaddingBottom = UDim.new(0, 6)})
	local MultiApi = {}
	local function Rebuild(NewValues)
		Values = NewValues or Values
		for _, C in next, List:GetChildren() do
			if C:IsA("TextButton") then C:Destroy() end
		end
		for I, V in next, (Values or {}) do
			local IsSel = Selected[V] == true
			local Opt = Create("TextButton", {
				Parent = List,
				Name = "MultiOpt" .. I,
				BackgroundColor3 = ColorAccent,
				BackgroundTransparency = IsSel and 0.85 or 1,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Size = UDim2.new(1, 0, 0, 38),
				Font = Enum.Font.BuilderSans,
				TextSize = 14,
				TextColor3 = IsSel and ColorWhite or ColorText,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = (IsSel and "[x]  " or "[  ]  ") .. V,
				ZIndex = BaseZIndex + 23,
			})
			Create("UIPadding", {Parent = Opt, PaddingLeft = UDim.new(0, 14)})
			Connect(Opt.MouseEnter, function()
				if not Selected[V] then Opt.BackgroundTransparency = 0.95 end
			end)
			Connect(Opt.MouseLeave, function()
				Opt.BackgroundTransparency = Selected[V] and 0.85 or 1
			end)
			Connect(Opt.MouseButton1Click, function()
				if Selected[V] then
					Selected[V] = nil
					Opt.BackgroundTransparency = 1
					Opt.TextColor3 = ColorText
					Opt.Text = "[  ]  " .. V
				else
					Selected[V] = true
					Opt.BackgroundTransparency = 0.85
					Opt.TextColor3 = ColorWhite
					Opt.Text = "[x]  " .. V
				end
				UpdateLabel()
				if Changed then Changed(Selected) end
			end)
		end
		List.CanvasSize = UDim2.new(0, 0, 0, #(Values or {}) * 38 + 6)
		UpdateLabel()
	end
	Connect(Btn.MouseButton1Click, function() Overlay.Visible = true end)
	Connect(Overlay.MouseButton1Click, function() Overlay.Visible = false end)
	function MultiApi:UpdateList(New) Rebuild(New) end
	function MultiApi:GetSelected() return Selected end
	Rebuild(Values or {})
	return MultiApi, Row
end

local ActiveAlert = nil
local function ShowAlert(Message, OkText, Cleanup)
	if ActiveAlert then ActiveAlert:Destroy(); ActiveAlert = nil end
	Hub.HubBar.Visible = false
	Hub.PageClipper.Visible = false
	Hub.BottomBar.Visible = false
	local AlertFrame = Create("Frame", {
		Parent = Hub.Shield,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 420, 0, 200),
		BackgroundColor3 = ColorSurface,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ZIndex = BaseZIndex + 30,
	})
	Create("UICorner", {Parent = AlertFrame, CornerRadius = UDim.new(0, 12)})
	Create("UIStroke", {Parent = AlertFrame, Color = ColorBorder, Thickness = 1})
	ActiveAlert = AlertFrame
	Create("TextLabel", {
		Parent = AlertFrame,
		BackgroundTransparency = 1,
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 14,
		TextColor3 = ColorText,
		Text = Message,
		TextWrapped = true,
		Size = UDim2.new(1, -32, 0, 120),
		Position = UDim2.new(0, 16, 0, 16),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		ZIndex = BaseZIndex + 31,
	})
	local OkBtn, OkLbl = MakeStyledButton("AlertOk", OkText or "Ok", UDim2.new(0, 110, 0, 34), function()
		if ActiveAlert then ActiveAlert:Destroy(); ActiveAlert = nil end
		if Cleanup then
			Cleanup()
		else
			Hub.HubBar.Visible = true
			Hub.PageClipper.Visible = true
			Hub.BottomBar.Visible = true
		end
	end)
	OkBtn.Parent = AlertFrame
	OkBtn.AnchorPoint = Vector2.new(0.5, 1)
	OkBtn.Position = UDim2.new(0.5, 0, 1, -14)
	OkBtn.BackgroundColor3 = ColorAccent
	OkLbl.TextColor3 = ColorWhite
	OkBtn.ZIndex = BaseZIndex + 31
end

local GetHeadshot = function(Player)
	return "http://www.roblox.com/Thumbs/Avatar.ashx?x=100&y=100&userId=" .. tostring(math.max(1, Player.UserId or 1))
end

local OpenReportPlayer

local function RunAfterClose(Cb)
	SetVisibility(false)
	Spawn(function() Wait(0.45); if Cb then Cb() end end)
end

local PlayersPage = MakePage("Players")
AddPage(PlayersPage, "Players", "Users", 120)

local function MakePlayerRow(Page, Player, Index)
	local Row = Create("Frame", {
		Name = "PlayerRow" .. Player.Name,
		Parent = Page.Frame,
		BackgroundColor3 = ColorSurface,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 54),
		ZIndex = BaseZIndex + 2,
		LayoutOrder = Index,
	})
	Create("UICorner", {Parent = Row, CornerRadius = UDim.new(0, 8)})
	local Headshot = Create("ImageLabel", {
		Parent = Row,
		BackgroundColor3 = ColorHover,
		BackgroundTransparency = 0,
		Image = GetHeadshot(Player),
		Size = UDim2.new(0, 34, 0, 34),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 8, 0.5, 0),
		ZIndex = BaseZIndex + 3,
	})
	Create("UICorner", {Parent = Headshot, CornerRadius = UDim.new(1, 0)})
	Create("TextLabel", {
		Parent = Row,
		BackgroundTransparency = 1,
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 14,
		TextColor3 = ColorText,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = Player.Name,
		Size = UDim2.new(0.4, 0, 1, 0),
		Position = UDim2.new(0, 50, 0, 0),
		ZIndex = BaseZIndex + 3,
	})
	Connect(Row.MouseEnter, function() Row.BackgroundTransparency = 0 end)
	Connect(Row.MouseLeave, function() Row.BackgroundTransparency = 1 end)
	local CanTarget = Player ~= LocalPlayer and (Player.UserId or 0) > 1
	if CanTarget then
		local ReportBtn, _ = MakeStyledButton("Report" .. Player.Name, "Report", UDim2.new(0, 80, 0, 28), function()
			if OpenReportPlayer then OpenReportPlayer(Player) end
		end)
		ReportBtn.Parent = Row
		ReportBtn.AnchorPoint = Vector2.new(1, 0.5)
		ReportBtn.Position = UDim2.new(1, -6, 0.5, 0)
		local ViewBtn, _ = MakeStyledButton("View" .. Player.Name, "Profile", UDim2.new(0, 80, 0, 28), function()
			local UserId = Player.UserId
			if not UserId or UserId <= 0 then return end
			RunAfterClose(function()
				local Ok = Protect(function() GuiService:InspectPlayerFromUserId(UserId) end)
				if not Ok then Protect(function() StarterGui:SetCore("InspectPlayerFromUserId", UserId) end) end
			end)
		end)
		ViewBtn.Parent = Row
		ViewBtn.AnchorPoint = Vector2.new(1, 0.5)
		ViewBtn.Position = UDim2.new(1, -94, 0.5, 0)
	end
	return Row
end

local function RebuildPlayersPage()
	for _, C in next, PlayersPage.Frame:GetChildren() do
		if C.Name:sub(1, 9) == "PlayerRow" then C:Destroy() end
	end
	local Sorted = Players:GetPlayers()
	table.sort(Sorted, function(A, B) return A.Name < B.Name end)
	for I, P in next, Sorted do MakePlayerRow(PlayersPage, P, I) end
end

RebuildPlayersPage()
Connect(Players.PlayerAdded, function() RebuildPlayersPage() end)
Connect(Players.PlayerRemoving, function() task.defer(RebuildPlayersPage) end)
Protect(function()
	Connect(LocalPlayer.FriendStatusChanged, function() RebuildPlayersPage() end)
end)

local GamePage = MakePage("GameSettings")
AddPage(GamePage, "Settings", "Settings", 115)

local IsTouchClient = UserInputService.TouchEnabled
local CameraDefaultString = IsTouchClient and "Default (Follow)" or "Default (Classic)"
local MovementDefaultString = IsTouchClient and "Default (Thumbstick)" or "Default (Keyboard)"
local ClickToMoveString = IsTouchClient and "Tap to Move" or "Click to Move"

local function GetSetting(Obj, Prop, Default)
	local Ok, Val = pcall(function() return Obj[Prop] end)
	if Ok and Val ~= nil then return Val end
	return Default
end

local function SetSetting(Obj, Prop, Val)
	Protect(function() Obj[Prop] = Val end)
end

local function MakeBoolSelector(Page, Name, Obj, Prop, OnText, OffText)
	local Current = GetSetting(Obj, Prop, false)
	local Start = ((Current == true or Current == 1) and 1) or 2
	return MakeSelector(Page, Name, {OnText or "On", OffText or "Off"}, Start, function(Index)
		SetSetting(Obj, Prop, Index == 1)
	end)
end

local function MakeOverrideText(Row)
	return Create("TextLabel", {
		Name = "DevOverrideLabel",
		Parent = Row,
		BackgroundTransparency = 1,
		Font = Enum.Font.BuilderSans,
		TextSize = 12,
		TextColor3 = ColorMuted,
		Text = "Set by Developer",
		Visible = false,
		AnchorPoint = Vector2.new(1, 0),
		Size = UDim2.new(0, 150, 1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		ZIndex = BaseZIndex + 3,
	})
end

local function SetChangerVisible(Changer, Override, Visible)
	if Changer then
		Changer:SetInteractable(Visible)
		Changer.SelectorFrame.Visible = Visible
	end
	if Override then Override.Visible = not Visible end
end

MakeSectionHeader(GamePage, "View & Controls", "Eye")

local ShiftLockMode, ShiftLockOverride = nil, nil
if UserInputService.MouseEnabled and UserInputService.KeyboardEnabled then
	ShiftLockMode = MakeSelector(GamePage, "Shift Lock Switch", {"On","Off"}, (GameSettings.ControlMode == Enum.ControlMode.MouseLockSwitch and 1) or 2, function(Index)
		Protect(function() GameSettings.ControlMode = (Index == 1 and Enum.ControlMode.MouseLockSwitch) or Enum.ControlMode.Classic end)
	end)
	ShiftLockOverride = MakeOverrideText(ShiftLockMode.RowFrame)
end

local CameraItems = (IsTouchClient and Enum.TouchCameraMovementMode or Enum.ComputerCameraMovementMode):GetEnumItems()
local CameraNames, CameraMap, CameraStart = {}, {}, 1
for I, Item in next, CameraItems do
	local N = (Item.Name == "Default" and CameraDefaultString) or Item.Name
	CameraNames[I] = N; CameraMap[N] = Item
	if (IsTouchClient and GameSettings.TouchCameraMovementMode == Item) or ((not IsTouchClient) and GameSettings.ComputerCameraMovementMode == Item) then
		CameraStart = I
	end
end
local CameraMode = MakeSelector(GamePage, "Camera Mode", CameraNames, CameraStart, function(_, V)
	Protect(function()
		if IsTouchClient then GameSettings.TouchCameraMovementMode = CameraMap[V]
		else GameSettings.ComputerCameraMovementMode = CameraMap[V] end
	end)
end)
local CameraOverride = MakeOverrideText(CameraMode.RowFrame)

local MoveItems = (IsTouchClient and Enum.TouchMovementMode or Enum.ComputerMovementMode):GetEnumItems()
local MoveNames, MoveMap, MoveStart = {}, {}, 1
for I, Item in next, MoveItems do
	local N = Item.Name
	if N == "Default" then N = MovementDefaultString
	elseif N == "KeyboardMouse" then N = "Keyboard + Mouse"
	elseif N == "ClickToMove" then N = ClickToMoveString end
	MoveNames[I] = N; MoveMap[N] = Item
	if (IsTouchClient and GameSettings.TouchMovementMode == Item) or ((not IsTouchClient) and GameSettings.ComputerMovementMode == Item) then
		MoveStart = I
	end
end
local MovementMode = MakeSelector(GamePage, "Movement Mode", MoveNames, MoveStart, function(_, V)
	Protect(function()
		if IsTouchClient then GameSettings.TouchMovementMode = MoveMap[V]
		else GameSettings.ComputerMovementMode = MoveMap[V] end
	end)
end)
local MovementOverride = MakeOverrideText(MovementMode.RowFrame)

local function UpdateDevSettings(Property)
	if ShiftLockMode and (not Property or Property == "DevEnableMouseLock") then
		local Can = true
		Protect(function() Can = LocalPlayer.DevEnableMouseLock end)
		SetChangerVisible(ShiftLockMode, ShiftLockOverride, Can)
	end
	if not Property or Property == "DevComputerCameraMode" or Property == "DevTouchCameraMode" then
		local Can = true
		Protect(function()
			Can = (IsTouchClient and LocalPlayer.DevTouchCameraMode == Enum.DevTouchCameraMovementMode.UserChoice) or ((not IsTouchClient) and LocalPlayer.DevComputerCameraMode == Enum.DevComputerCameraMovementMode.UserChoice)
		end)
		SetChangerVisible(CameraMode, CameraOverride, Can)
	end
	if not Property or Property == "DevComputerMovementMode" or Property == "DevTouchMovementMode" then
		local Can = true
		Protect(function()
			Can = (IsTouchClient and LocalPlayer.DevTouchMovementMode == Enum.DevTouchMovementMode.UserChoice) or ((not IsTouchClient) and LocalPlayer.DevComputerMovementMode == Enum.DevComputerMovementMode.UserChoice)
		end)
		SetChangerVisible(MovementMode, MovementOverride, Can)
	end
end
UpdateDevSettings()
Connect(LocalPlayer.Changed, UpdateDevSettings)

local MouseStart = Clamp(Floor((2/3) * (math.sqrt((75 * (GameSettings.MouseSensitivity or 1)) - 11) - 2)), 1, 10)
MakeSlider(GamePage, "Mouse Sensitivity", 10, MouseStart, function(Value)
	Value = Clamp(Value, 1, 10)
	SetMouseSensitivity((0.03 * (Value ^ 2)) + (0.08 * Value) + 0.2)
end, 1)
MakeBoolSelector(GamePage, "UI Navigation Toggle", GameSettings, "UiNavigationKeyBindEnabled")
MakeBoolSelector(GamePage, "Player Names", GameSettings, "PlayerNamesEnabled", "Show", "Hide")
MakeBoolSelector(GamePage, "Badges", GameSettings, "BadgeVisible", "Show", "Hide")

MakeSectionHeader(GamePage, "Audio", "Volume2")
MakeSlider(GamePage, "Volume", 10, Floor((GameSettings.MasterVolume or 1) * 10), function(Value)
	SetMasterVolume(Value / 10)
	PlayVolumeSound()
end)

MakeSectionHeader(GamePage, "Chat & Language", "MessageSquare")
MakeButtonRow(GamePage, "Translation Feedback", "Give Feedback", function()
	RunAfterClose(function()
		pcall(function() SocialService:PromptFeedbackSubmissionAsync() end)
	end)
end)
MakeBoolSelector(GamePage, "Chat Translation", GameSettings, "ChatTranslationEnabled")
MakeBoolSelector(GamePage, "Translation Language", GameSettings, "ChatTranslationToggleEnabled")
MakeBoolSelector(GamePage, "Untranslated Messages", GameSettings, "ChatTranslationFTUXShown")

MakeSectionHeader(GamePage, "Display & Graphics", "Monitor")
MakeSelector(GamePage, "Fullscreen", {"On","Off"}, (GameSettings:InFullScreen() and 1) or 2, function()
	Protect(function()
		local Ok = pcall(function() GuiService:ToggleFullscreen() end)
		if not Ok and keypress and keyrelease then keypress(0x7A); keyrelease(0x7A) end
	end)
end)
MakeBoolSelector(GamePage, "Performance Stats", GameSettings, "PerformanceStatsVisible")
MakeButtonRow(GamePage, "Developer Console", "Open", function()
	RunAfterClose(function()
		local Ok = Protect(function() game:GetService("StarterGui"):SetCore("DevConsoleVisible", true) end)
		if not Ok and keypress and keyrelease then keypress(0x78); keyrelease(0x78) end
	end)
end)

local QualityLevels = {Enum.QualityLevel.Level01,Enum.QualityLevel.Level04,Enum.QualityLevel.Level06,Enum.QualityLevel.Level08,Enum.QualityLevel.Level10,Enum.QualityLevel.Level12,Enum.QualityLevel.Level14,Enum.QualityLevel.Level16,Enum.QualityLevel.Level18,Enum.QualityLevel.Level21}
local SavedQualityLevels = {Enum.SavedQualitySetting.QualityLevel1,Enum.SavedQualitySetting.QualityLevel2,Enum.SavedQualitySetting.QualityLevel3,Enum.SavedQualitySetting.QualityLevel4,Enum.SavedQualitySetting.QualityLevel5,Enum.SavedQualitySetting.QualityLevel6,Enum.SavedQualitySetting.QualityLevel7,Enum.SavedQualitySetting.QualityLevel8,Enum.SavedQualitySetting.QualityLevel9,Enum.SavedQualitySetting.QualityLevel10}

local function GetGraphicsSliderStart()
	if type(GameSettings.SavedQualityLevel) == "number" then
		if GameSettings.SavedQualityLevel <= 0 then return 5 end
		return Clamp(GameSettings.SavedQualityLevel, 1, 10)
	end
	if GameSettings.SavedQualityLevel == Enum.SavedQualitySetting.Automatic or RenderingSettings.QualityLevel == Enum.QualityLevel.Automatic then return 5 end
	for I, Q in next, QualityLevels do
		if RenderingSettings.QualityLevel == Q then return I end
	end
	local Saved = tostring(GameSettings.SavedQualityLevel)
	local SavedIndex = tonumber(Saved:match("QualityLevel(%d+)$"))
	return Clamp(SavedIndex or 5, 1, 10)
end

local function GetEnumByValue(EnumType, Value)
	local Items = {}
	Protect(function() Items = EnumType:GetEnumItems() end)
	for _, Item in next, Items do
		if Item.Value == Value then return Item end
	end
	return nil
end

local function SetGraphicsQuality(NewValue, AutoAllowed)
	NewValue = tonumber(NewValue) or 0
	local MaxQuality = 21
	Protect(function() MaxQuality = RenderingSettings:GetMaxQualityLevel() end)
	local NewLevel = 0
	if NewValue > 0 or not AutoAllowed then
		local Pct = NewValue / 10
		NewLevel = Floor((MaxQuality - 1) * Pct)
		if NewLevel == 20 then NewLevel = 21
		elseif NewValue == 1 then NewLevel = 1
		elseif NewLevel > MaxQuality then NewLevel = MaxQuality - 1 end
	end
	local Saved = (NewValue <= 0 and AutoAllowed and Enum.SavedQualitySetting.Automatic) or GetEnumByValue(Enum.SavedQualitySetting, NewValue) or SavedQualityLevels[NewValue]
	local Render = (NewValue <= 0 and AutoAllowed and Enum.QualityLevel.Automatic) or GetEnumByValue(Enum.QualityLevel, NewLevel) or QualityLevels[NewValue]
	Protect(function() RenderingSettings.EnableFRM = true end)
	Protect(function() GameSettings.SavedQualityLevel = NewValue end)
	Protect(function() GameSettings.SavedQualityLevel = Saved end)
	Protect(function() RenderingSettings.QualityLevel = NewLevel end)
	Protect(function() RenderingSettings.QualityLevel = Render end)
	Protect(function() RenderingSettings.EditQualityLevel = NewLevel end)
	Protect(function() RenderingSettings.EditQualityLevel = Render end)
	Protect(function() RenderingSettings.AutoFRMLevel = NewLevel end)
end

local GraphicsSlider, GraphicsMode2 = nil, nil
Protect(function() RenderingSettings.EnableFRM = true end)

local function SetGraphicsToAuto()
	if GraphicsSlider then GraphicsSlider:SetInteractable(false) end
	SetGraphicsQuality(0, true)
end

local function SetGraphicsToManual(V)
	V = Clamp(V or GetGraphicsSliderStart(), 1, 10)
	if GraphicsSlider then GraphicsSlider:SetInteractable(true); GraphicsSlider:SetValue(V) end
	SetGraphicsQuality(V, false)
end

GraphicsMode2 = MakeSelector(GamePage, "Graphics Mode", {"Automatic","Manual"}, 1, function(Index)
	if Index == 1 then SetGraphicsToAuto()
	else SetGraphicsToManual((GraphicsSlider and GraphicsSlider:GetValue()) or GetGraphicsSliderStart()) end
end)
if GameSettings.SavedQualityLevel ~= Enum.SavedQualitySetting.Automatic and RenderingSettings.QualityLevel ~= Enum.QualityLevel.Automatic and GameSettings.SavedQualityLevel ~= 0 and RenderingSettings.QualityLevel ~= 0 then
	GraphicsMode2:SetSelectionIndex(2)
end

GraphicsSlider = MakeSlider(GamePage, "Graphics Quality", 10, GetGraphicsSliderStart(), function(Value)
	Value = Clamp(Value, 1, 10)
	GraphicsMode2:SetSelectionIndex(2)
	GraphicsSlider:SetInteractable(true)
	SetGraphicsQuality(Value, false)
end, 1)

Protect(function()
	Connect(game.GraphicsQualityChangeRequest, function(IsIncrease)
		if RenderingSettings.QualityLevel == Enum.QualityLevel.Automatic or RenderingSettings.QualityLevel == 0 then return end
		local V = Clamp(GraphicsSlider:GetValue() + (IsIncrease and 1 or -1), 1, 10)
		GraphicsMode2:SetSelectionIndex(2); GraphicsSlider:SetInteractable(true); GraphicsSlider:SetValue(V); SetGraphicsQuality(V, false)
	end)
end)

if GameSettings.SavedQualityLevel == Enum.SavedQualitySetting.Automatic or RenderingSettings.QualityLevel == Enum.QualityLevel.Automatic or GameSettings.SavedQualityLevel == 0 or RenderingSettings.QualityLevel == 0 then
	SetGraphicsToAuto()
else
	SetGraphicsToManual(GetGraphicsSliderStart())
end

MakeSelector(GamePage, "Haptics", {"On","Off"}, ((GetSetting(GameSettings, "HapticStrength", 1) or 0) > 0 and 1) or 2, function(I)
	SetSetting(GameSettings, "HapticStrength", (I == 1 and 1) or 0)
end)
MakeBoolSelector(GamePage, "Reduce Motion", GameSettings, "ReducedMotion")

local FpsValues = {"60","120","144","160","165","180","200","240"}
local FpsStart = 1
local CurrentFps = tostring(GetSetting(GameSettings, "FramerateCap", 60))
for I, V in next, FpsValues do if V == CurrentFps then FpsStart = I end end
MakeSelector(GamePage, "Max Frame Rate", FpsValues, FpsStart, function(_, V)
	local Cap = tonumber(V) or 60
	SetSetting(GameSettings, "FramerateCap", Cap)
	if setfpscap then Protect(function() setfpscap(Cap) end) end
end)
MakeBoolSelector(GamePage, "VR", GameSettings, "VREnabled")

local EspSettings = {Enabled=false,Rainbow=false,HighlightsEnabled=false,HighlightsRainbow=false,Boxes=false,Names=false,HealthBar=false,Distance=false,Tracers=false,Chams=false}
local EspTargets = {}
local EspDropDown = nil

MakeSectionHeader(GamePage, "ESP", "ScanEye")
EspDropDown = MakeMultiDropDown(GamePage, "Target Players", {}, function(Sel) EspTargets = Sel end)

Protect(function()
	local function RefreshEsp()
		local Names = {}
		for _, P in next, Players:GetPlayers() do
			if P ~= LocalPlayer then Insert(Names, P.Name) end
		end
		if EspDropDown then EspDropDown:UpdateList(Names) end
	end
	Connect(Players.PlayerAdded, RefreshEsp)
	Connect(Players.PlayerRemoving, function() task.defer(RefreshEsp) end)
	RefreshEsp()
end)

MakeSectionHeader(GamePage, "Visibility", "Eye")
MakeBoolSelector(GamePage, "ESP", EspSettings, "Enabled")
MakeBoolSelector(GamePage, "ESP Rainbow", EspSettings, "Rainbow")
MakeBoolSelector(GamePage, "Highlights", EspSettings, "HighlightsEnabled")
MakeBoolSelector(GamePage, "Rainbow Highlights", EspSettings, "HighlightsRainbow")
MakeSectionHeader(GamePage, "ESP Details", "ScanEye")
MakeBoolSelector(GamePage, "ESP Boxes", EspSettings, "Boxes")
MakeBoolSelector(GamePage, "ESP Names", EspSettings, "Names")
MakeBoolSelector(GamePage, "Health Bar", EspSettings, "HealthBar")
MakeBoolSelector(GamePage, "Distance", EspSettings, "Distance")
MakeBoolSelector(GamePage, "Tracers", EspSettings, "Tracers")
MakeBoolSelector(GamePage, "Chams", EspSettings, "Chams")

local ReportPage = MakePage("ReportAbuse")
AddPage(ReportPage, "Report", "Flag", 100)

local TypeOfAbuse = nil
local WhichPlayer = nil
local NameToPlayer = {}
local PlayerNamesList = {}
local SubmitBtn = nil
local SubmitLbl = nil
local Description = nil
local ReportModeSel = nil

local function SetSubmitActive(Active)
	if not SubmitBtn or not SubmitLbl then return end
	SubmitBtn.Active = Active
	SubmitBtn.BackgroundTransparency = Active and 0 or 0.5
	SubmitLbl.TextTransparency = Active and 0 or 0.55
end

local function GetReportDescription()
	local T = Description and Description.Text or ""
	if T == "" then return DescFallback end
	return T
end

local function CanSubmitReport(Mode)
	if not TypeOfAbuse or not Mode then return false end
	if not TypeOfAbuse:GetSelectedIndex() then return false end
	if Mode:GetSelectedIndex() == 2 and (not WhichPlayer or not WhichPlayer:GetSelectedValue()) then return false end
	return true
end

local function RefreshSubmitState(Mode)
	SetSubmitActive(CanSubmitReport(Mode))
end

ReportModeSel = MakeSelector(ReportPage, "Game or Player?", {"Game","Player"}, 1, function()
	if not TypeOfAbuse or not WhichPlayer then return end
	WhichPlayer:ResetSelectionIndex()
	TypeOfAbuse:ResetSelectionIndex()
	if ReportModeSel:GetSelectedIndex() == 1 then
		TypeOfAbuse:UpdateDropDownList(AbuseGame)
		WhichPlayer:SetInteractable(false)
	else
		TypeOfAbuse:UpdateDropDownList(AbusePlayer)
		WhichPlayer:SetInteractable(#PlayerNamesList > 0)
	end
	RefreshSubmitState(ReportModeSel)
end)

WhichPlayer = MakeDropDown(ReportPage, "Which Player?", PlayerNamesList, nil, function()
	RefreshSubmitState(ReportModeSel)
end)
WhichPlayer:SetInteractable(false)

local function RefreshReportPlayers()
	PlayerNamesList = {}; NameToPlayer = {}
	for _, P in next, Players:GetPlayers() do
		if P ~= LocalPlayer and (P.UserId or 0) > 0 then
			Insert(PlayerNamesList, P.Name); NameToPlayer[P.Name] = P
		end
	end
	WhichPlayer:UpdateDropDownList(PlayerNamesList)
	WhichPlayer:SetInteractable(ReportModeSel:GetSelectedIndex() == 2 and #PlayerNamesList > 0)
	if #PlayerNamesList == 0 and ReportModeSel:GetSelectedIndex() == 2 then
		ReportModeSel:SetSelectionIndex(1, true)
	end
	RefreshSubmitState(ReportModeSel)
end

OpenReportPlayer = function(Player)
	if Player and Player ~= LocalPlayer then
		RefreshReportPlayers()
		ReportModeSel:SetSelectionIndex(2, true)
		WhichPlayer:SetSelectionByValue(Player.Name, true)
		if Hub.Visible then SwitchToPage(ReportPage)
		else SetVisibility(true, false, ReportPage) end
	end
end

Connect(Players.PlayerAdded, RefreshReportPlayers)
Connect(Players.PlayerRemoving, function() task.defer(RefreshReportPlayers) end)

TypeOfAbuse = MakeDropDown(ReportPage, "Type Of Abuse", AbuseGame, nil, function()
	RefreshSubmitState(ReportModeSel)
end)

local DescRow = MakeRow(ReportPage, "", 88)
Description = Create("TextBox", {
	Parent = DescRow,
	BackgroundColor3 = ColorHover,
	BackgroundTransparency = 0,
	BorderSizePixel = 0,
	ClearTextOnFocus = false,
	Font = Enum.Font.BuilderSans,
	TextSize = 13,
	TextColor3 = ColorText,
	PlaceholderText = DescPlaceholder,
	PlaceholderColor3 = ColorMuted,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	TextWrapped = true,
	Text = "",
	Size = UDim2.new(1, 0, 1, -8),
	ZIndex = BaseZIndex + 3,
})
Create("UICorner", {Parent = Description, CornerRadius = UDim.new(0, 6)})
Create("UIPadding", {Parent = Description, PaddingLeft = UDim.new(0, 8), PaddingTop = UDim.new(0, 6)})

local SubmitRow = MakeRow(ReportPage, "", 46)
SubmitBtn, SubmitLbl = MakeStyledButton("SubmitReport", "Submit Report", UDim2.new(0, 150, 0, 32), function()
	if not CanSubmitReport(ReportModeSel) then return end
	local IsPlayer = ReportModeSel:GetSelectedIndex() == 2
	local Reason = ((IsPlayer and AbusePlayer) or AbuseGame)[TypeOfAbuse:GetSelectedIndex()]
	local Target = IsPlayer and NameToPlayer[WhichPlayer:GetSelectedValue()] or nil
	local Desc = GetReportDescription()
	if IsPlayer and not Target then RefreshSubmitState(ReportModeSel); return end
	local Ok = Protect(function() Players.ReportAbuse(LocalPlayer, Target, Reason, Desc) end)
	if not Ok then Ok = Protect(function() Players:ReportAbuse(Target, Reason, Desc) end) end
	local AlertText = "Thanks for your report. Our moderators will review it."
	if Reason == "Cheating/Exploiting" then AlertText = "Thanks for your report. We have recorded it for evaluation." end
	if not Ok then AlertText = "Report could not be submitted in this environment." end
	ShowAlert(AlertText, "Ok", function()
		ReportModeSel:SetSelectionIndex(1, true)
		WhichPlayer:ResetSelectionIndex()
		TypeOfAbuse:ResetSelectionIndex()
		Description.Text = ""
		SetVisibility(false)
	end)
end)
SubmitBtn.Parent = SubmitRow
SubmitBtn.AnchorPoint = Vector2.new(0.5, 0.5)
SubmitBtn.Position = UDim2.new(0.5, 0, 0.5, 0)
SubmitBtn.BackgroundColor3 = ColorAccent
SubmitLbl.TextColor3 = ColorWhite
SetSubmitActive(false)
RefreshReportPlayers()

local HelpPage = MakePage("Help")
AddPage(HelpPage, "Help", "Info", 95)

local function CreateHelpGroup(Title, Bindings)
	local Row = MakeRow(HelpPage, "", 24 + #Bindings * 34)
	Create("TextLabel", {
		Parent = Row,
		BackgroundTransparency = 1,
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 11,
		TextColor3 = ColorAccent,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Text = Title:upper(),
		Size = UDim2.new(1, 0, 0, 20),
		Position = UDim2.new(0, 0, 0, 4),
		ZIndex = BaseZIndex + 3,
	})
	for I, Binding in ipairs(Bindings) do
		local BRow = Create("Frame", {
			Parent = Row,
			BackgroundColor3 = ColorSurface,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 28),
			Position = UDim2.new(0, 0, 0, 20 + (I - 1) * 32),
			ZIndex = BaseZIndex + 3,
		})
		Create("UICorner", {Parent = BRow, CornerRadius = UDim.new(0, 5)})
		Create("TextLabel", {
			Parent = BRow,
			BackgroundTransparency = 1,
			Font = Enum.Font.BuilderSans,
			TextSize = 13,
			TextColor3 = ColorText,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = Binding[1],
			Size = UDim2.new(0.5, -8, 1, 0),
			Position = UDim2.new(0, 8, 0, 0),
			ZIndex = BaseZIndex + 4,
		})
		Create("TextLabel", {
			Parent = BRow,
			BackgroundTransparency = 1,
			Font = Enum.Font.BuilderSansMedium,
			TextSize = 13,
			TextColor3 = ColorWhite,
			TextXAlignment = Enum.TextXAlignment.Right,
			Text = Binding[2],
			Size = UDim2.new(0.5, -8, 1, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			ZIndex = BaseZIndex + 4,
		})
	end
	return Row
end

local IsOSX = UserInputService:GetPlatform() == Enum.Platform.OSX
CreateHelpGroup("Character Movement", {
	{"Move Forward","W / Up Arrow"},{"Move Backward","S / Down Arrow"},
	{"Move Left","A / Left Arrow"},{"Move Right","D / Right Arrow"},{"Jump","Space"},
})
CreateHelpGroup("Accessories", {
	{"Equip Tools","1,2,3..."},{"Drop Tool","Backspace"},{"Use Tool","Left Click"},
})
CreateHelpGroup("Camera", {
	{"Rotate","Right Mouse Button"},{"Zoom","Mouse Wheel"},{"Zoom In","I"},{"Zoom Out","O"},
})
CreateHelpGroup("Menu Items", {
	{"Roblox Menu","Escape"},{"Backpack","~"},{"Player List","Tab"},{"Chat","/"},
})
CreateHelpGroup("Misc", {
	{"Screenshot","Print Screen"},
	{"Record Video",IsOSX and "F12/fn+F12" or "F12"},
	{"Dev Console",IsOSX and "F9/fn+F9" or "F9"},
	{"Mouse Lock","Shift"},
	{"Fullscreen",IsOSX and "F11/fn+F11" or "F11"},
})

local RecordPage = nil
Protect(function()
	local Platform = UserInputService:GetPlatform()
	if Platform == Enum.Platform.Windows or Platform == Enum.Platform.OSX then
		RecordPage = MakePage("Record")
		AddPage(RecordPage, "Record", "Video", 110)
		local SsRow = MakeRow(RecordPage, "Screenshot", 54)
		local SsLbl = SsRow:FindFirstChild("NameLabel")
		if SsLbl then SsLbl.TextSize = 14 end
		Create("TextLabel", {
			Parent = SsRow,
			BackgroundTransparency = 1,
			Font = Enum.Font.BuilderSans,
			TextSize = 12,
			TextColor3 = ColorMuted,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			Text = "Closes menu and saves a screenshot to your computer.",
			Size = UDim2.new(0.5, 0, 1, -22),
			Position = UDim2.new(0, 0, 0, 22),
			ZIndex = BaseZIndex + 3,
		})
		local SsBtn, _ = MakeStyledButton("ScreenshotBtn", "Take Screenshot", UDim2.new(0, 148, 0, 30), function()
			RunAfterClose(function()
				pcall(function()
					if keypress and keyrelease then keypress(KeyPrint); keyrelease(KeyPrint)
					else StarterGui:SetCore("TakeScreenshot") end
				end)
			end)
		end)
		SsBtn.Parent = SsRow
		SsBtn.AnchorPoint = Vector2.new(1, 0.5)
		SsBtn.Position = UDim2.new(1, 0, 0.5, 0)
		local StartSetting = 2
		Protect(function()
			if GameSettings.VideoUploadPromptBehavior == Enum.UploadSetting.Never then StartSetting = 1 end
		end)
		MakeSelector(RecordPage, "Video Mode", {"Save To Disk","Upload to YouTube"}, StartSetting, function(Index)
			Protect(function() GameSettings.VideoUploadPromptBehavior = (Index == 1 and Enum.UploadSetting.Never) or Enum.UploadSetting.Always end)
		end)
		local RecRow = MakeRow(RecordPage, "Record Video", 48)
		local RecBtn, _ = MakeStyledButton("RecordBtn", "Record Video", UDim2.new(0, 148, 0, 30), function()
			RunAfterClose(function()
				pcall(function()
					if keypress and keyrelease then keypress(KeyF12); keyrelease(KeyF12)
					else StarterGui:SetCore("ToggleRecording") end
				end)
			end)
		end)
		RecBtn.Parent = RecRow
		RecBtn.AnchorPoint = Vector2.new(1, 0.5)
		RecBtn.Position = UDim2.new(1, 0, 0.5, 0)
	end
end)

local ResetPage = MakePage("ResetCharacter")
AddPage(ResetPage)

local ConfirmResetRow = MakeRow(ResetPage, "Reset your character?", 50)
local ResetNameLbl = ConfirmResetRow:FindFirstChild("NameLabel")
if ResetNameLbl then ResetNameLbl.TextSize = 15; ResetNameLbl.Size = UDim2.new(0.6, 0, 1, 0) end

local ResetCharacter = function()
	local Char = LocalPlayer.Character
	local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
	if Hum then Hum.Health = 0 end
	SetVisibility(false, true)
end

local ResetBtnRow = MakeRow(ResetPage, "", 46)
local ResetConfirmBtn, _ = MakeStyledButton("ConfirmReset", "Reset Character", UDim2.new(0, 148, 0, 32), ResetCharacter)
ResetConfirmBtn.Parent = ResetBtnRow
ResetConfirmBtn.BackgroundColor3 = ColorDanger
ResetConfirmBtn.AnchorPoint = Vector2.new(0, 0.5)
ResetConfirmBtn.Position = UDim2.new(0, 0, 0.5, 0)
local DontResetBtn, _ = MakeStyledButton("DontReset", "Cancel", UDim2.new(0, 100, 0, 32), function()
	Hub.HubBar.Visible = true
	Hub.BottomBar.Visible = true
	SwitchToPage(Hub.MenuStack[#Hub.MenuStack] or GamePage, true, true)
end)
DontResetBtn.Parent = ResetBtnRow
DontResetBtn.AnchorPoint = Vector2.new(0, 0.5)
DontResetBtn.Position = UDim2.new(0, 156, 0.5, 0)

local LeavePage = MakePage("LeaveGame")
AddPage(LeavePage)

local ConfirmLeaveRow = MakeRow(LeavePage, "Leave this game?", 50)
local LeaveNameLbl = ConfirmLeaveRow:FindFirstChild("NameLabel")
if LeaveNameLbl then LeaveNameLbl.TextSize = 15; LeaveNameLbl.Size = UDim2.new(0.6, 0, 1, 0) end

local LeaveGame = function() game:Shutdown() end

local LeaveBtnRow = MakeRow(LeavePage, "", 46)
local LeaveConfirmBtn, _ = MakeStyledButton("ConfirmLeave", "Leave Game", UDim2.new(0, 130, 0, 32), LeaveGame)
LeaveConfirmBtn.Parent = LeaveBtnRow
LeaveConfirmBtn.BackgroundColor3 = ColorDanger
LeaveConfirmBtn.AnchorPoint = Vector2.new(0, 0.5)
LeaveConfirmBtn.Position = UDim2.new(0, 0, 0.5, 0)
local DontLeaveBtn, _ = MakeStyledButton("DontLeave", "Cancel", UDim2.new(0, 100, 0, 32), function()
	Hub.HubBar.Visible = true
	Hub.BottomBar.Visible = true
	SwitchToPage(Hub.MenuStack[#Hub.MenuStack] or GamePage, true, true)
end)
DontLeaveBtn.Parent = LeaveBtnRow
DontLeaveBtn.AnchorPoint = Vector2.new(0, 0.5)
DontLeaveBtn.Position = UDim2.new(0, 138, 0.5, 0)

local function PushPage(Page)
	Insert(Hub.MenuStack, Hub.CurrentPage)
	Hub.HubBar.Visible = false
	Hub.BottomBar.Visible = false
	SwitchToPage(Page, true, true)
end

local function MakeBottomButton(Name, Text, IconName, Clicked)
	local Btn = Create("TextButton", {
		Name = Name .. "Btn",
		Parent = Hub.BottomBar,
		BackgroundTransparency = 1,
		Text = "",
		Size = UDim2.new(0, 192, 0, 44),
		AutoButtonColor = false,
		ZIndex = BaseZIndex + 2,
	})
	local IconData = GetLucideIcon(IconName)
	local Icon = Create("ImageLabel", {
		Parent = Btn,
		BackgroundTransparency = 1,
		Image = IconData and IconData[1] or "",
		ImageRectSize = IconData and IconData[2].ImageRectSize or Vector2.new(0, 0),
		ImageRectOffset = IconData and IconData[2].ImageRectPosition or Vector2.new(0, 0),
		ImageColor3 = ColorMuted,
		Size = UDim2.new(0, 15, 0, 15),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 20, 0.5, 0),
		ZIndex = BaseZIndex + 3,
	})
	Create("TextLabel", {
		Parent = Btn,
		BackgroundTransparency = 1,
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 13,
		TextColor3 = ColorText,
		Text = Text,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 40, 0.5, 0),
		Size = UDim2.new(1, -46, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = BaseZIndex + 3,
	})
	Connect(Btn.MouseEnter, function() Icon.ImageColor3 = ColorWhite end)
	Connect(Btn.MouseLeave, function() Icon.ImageColor3 = ColorMuted end)
	Connect(Btn.MouseButton1Click, Clicked)
	return Btn
end

MakeBottomButton("ResetCharacter", "Reset Character", "RefreshCw", function() PushPage(ResetPage) end)
MakeBottomButton("LeaveGame", "Leave Game", "LogOut", function() PushPage(LeavePage) end)
MakeBottomButton("Resume", "Resume Game", "Play", function() SetVisibility(false) end)

local function HideNativeMenu()
	local RobloxGui = CoreGui:FindFirstChild("RobloxGui")
	local Shield = RobloxGui and RobloxGui:FindFirstChild("SettingsClippingShield")
	if Shield then
		local function HideObj(Obj)
			if not Obj:IsA("GuiObject") then return end
			pcall(function() Obj.Visible = false end)
			pcall(function() Obj.Active = false end)
			pcall(function() Obj.Selectable = false end)
			pcall(function() Obj.AutoButtonColor = false end)
			pcall(function() Obj.BackgroundTransparency = 1 end)
			pcall(function() Obj.ImageTransparency = 1 end)
			pcall(function() Obj.TextTransparency = 1 end)
		end
		HideObj(Shield)
		for _, C in next, Shield:GetDescendants() do HideObj(C) end
	end
end

local InputLockBound = false
local InputLockInputs = {}
local InputLockActions = {}
local SavedMouseBehavior = nil
local WasRightMouseDown = false

local function AddInputLock(EnumName, Name)
	Protect(function()
		local EnumType = Enum[EnumName]
		local Item = EnumType and EnumType[Name]
		if Item then Insert(InputLockInputs, Item) end
	end)
end

AddInputLock("PlayerActions","CharacterForward")
AddInputLock("PlayerActions","CharacterBackward")
AddInputLock("PlayerActions","CharacterLeft")
AddInputLock("PlayerActions","CharacterRight")
AddInputLock("PlayerActions","CharacterJump")
AddInputLock("KeyCode","W")
AddInputLock("KeyCode","A")
AddInputLock("KeyCode","S")
AddInputLock("KeyCode","D")
AddInputLock("KeyCode","Space")
AddInputLock("KeyCode","LeftShift")
AddInputLock("KeyCode","RightShift")
AddInputLock("KeyCode","Thumbstick1")
AddInputLock("KeyCode","Thumbstick2")
AddInputLock("UserInputType","MouseButton2")

local function IsRightMouseDown()
	local Down = false
	Protect(function() Down = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end)
	return Down
end

local function ReleaseRightMouse()
	Protect(function() if mouse2release then mouse2release() end end)
	Protect(function()
		if VirtualInputManager then
			local Pos = UserInputService:GetMouseLocation()
			VirtualInputManager:SendMouseButtonEvent(Pos.X, Pos.Y, 1, false, game, 0)
		end
	end)
end

local function SinkInput()
	local Focused = nil
	Protect(function() Focused = UserInputService:GetFocusedTextBox() end)
	if Focused then return Enum.ContextActionResult.Pass end
	return Enum.ContextActionResult.Sink
end

local function SetInputLocked(Locked)
	if InputLockBound == Locked then
		if not Locked then
			for _, N in next, InputLockActions do
				Protect(function() ContextActionService:UnbindCoreAction(N) end)
				Protect(function() ContextActionService:UnbindAction(N) end)
			end
			InputLockActions = {}
			Protect(function() UserInputService.MouseBehavior = Enum.MouseBehavior.Default end)
		end
		return
	end
	InputLockBound = Locked
	if Locked then
		Protect(function()
			WasRightMouseDown = IsRightMouseDown()
			SavedMouseBehavior = UserInputService.MouseBehavior
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
		end)
		ReleaseRightMouse()
		InputLockActions = {}
		for I, Input in next, InputLockInputs do
			local AName = "SettingHubLock" .. I
			local Ok = Protect(function() ContextActionService:BindCoreActionAtPriority(AName, SinkInput, false, 10000, Input) end)
			if not Ok then Ok = Protect(function() ContextActionService:BindCoreAction(AName, SinkInput, false, Input) end) end
			if not Ok then Ok = Protect(function() ContextActionService:BindActionAtPriority(AName, SinkInput, false, 10000, Input) end) end
			if Ok then Insert(InputLockActions, AName) end
		end
	else
		for _, N in next, InputLockActions do
			Protect(function() ContextActionService:UnbindCoreAction(N) end)
			Protect(function() ContextActionService:UnbindAction(N) end)
		end
		InputLockActions = {}
		Protect(function()
			if SavedMouseBehavior and not (WasRightMouseDown and SavedMouseBehavior == Enum.MouseBehavior.LockCurrentPosition) then
				UserInputService.MouseBehavior = SavedMouseBehavior
			else
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			end
			SavedMouseBehavior = nil
			WasRightMouseDown = false
		end)
	end
end

local LastToggleTime = 0
SetVisibility = function(Visible, NoAnimation, CustomPage)
	local Now = tick()
	if Visible and (Now - LastToggleTime) < 2 and not NoAnimation then return end
	if not Visible then SetInputLocked(false) end
	if Hub.Visible == Visible and not CustomPage then return end
	if Visible then LastToggleTime = Now end
	Hub.Visible = Visible
	Hub.Modal.Visible = Visible
	if Visible then SetInputLocked(true) end
	if Visible then
		HideNativeMenu()
		Hub.Shield.Visible = true
		DarkenBg.Visible = true
		Hub.HubBar.Visible = true
		Hub.PageClipper.Visible = true
		Hub.BottomBar.Visible = true
		if NoAnimation then
			Hub.Shield.Position = PositionShown
		else
			Hub.Shield.Position = PositionHidden
			TweenTo(Hub.Shield, PositionShown, Enum.EasingDirection.InOut, Enum.EasingStyle.Quart, 0.45)
		end
		SwitchToPage(CustomPage or PlayersPage, true)
	else
		if NoAnimation then
			Hub.Shield.Position = PositionHidden
			Hub.Shield.Visible = false
			DarkenBg.Visible = false
		else
			TweenTo(Hub.Shield, PositionHidden, Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.35, function()
				if not Hub.Visible then
					Hub.Shield.Visible = false
					DarkenBg.Visible = false
				end
			end)
		end
	end
end

Connect(CloseBtn.MouseButton1Click, function() SetVisibility(false) end)

local function ToggleVisibility()
	SetVisibility(not Hub.Visible)
end

SwitchToPage(GamePage, true)

local LastEscapeTime = 0
local function EscapeAction(_, State)
	if State ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Sink end
	local Now = tick()
	if (Now - LastEscapeTime) < 0.15 then return Enum.ContextActionResult.Sink end
	LastEscapeTime = Now
	HideNativeMenu()
	local WasVisible = Hub.Visible
	if Hub.Visible and (Hub.CurrentPage == ResetPage or Hub.CurrentPage == LeavePage) then
		Hub.HubBar.Visible = true
		Hub.BottomBar.Visible = true
		SwitchToPage(Hub.MenuStack[#Hub.MenuStack] or GamePage, true, true)
	else
		if WasVisible then Hub.SuppressNativeOpenUntil = Now + 0.8 end
		ToggleVisibility()
	end
	Spawn(function() Wait(); HideNativeMenu() end)
	return Enum.ContextActionResult.Sink
end

Protect(function()
	local Ok = pcall(function()
		ContextActionService:BindCoreActionAtPriority("SettingHubEscape", EscapeAction, false, 10000, Enum.KeyCode.Escape, Enum.KeyCode.ButtonStart)
	end)
	if not Ok then
		ContextActionService:BindCoreAction("SettingHubEscape", EscapeAction, false, Enum.KeyCode.Escape, Enum.KeyCode.ButtonStart)
	end
end)

Connect(UserInputService.InputBegan, function(Input, Processed)
	if Processed and Input.KeyCode ~= Enum.KeyCode.Escape then return end
	if Input.KeyCode == Enum.KeyCode.Escape then
		EscapeAction(nil, Enum.UserInputState.Begin)
	elseif Hub.Visible and Input.KeyCode == Enum.KeyCode.R and Hub.CurrentPage ~= ResetPage and Hub.CurrentPage ~= LeavePage then
		PushPage(ResetPage)
	elseif Hub.Visible and Input.KeyCode == Enum.KeyCode.L and Hub.CurrentPage ~= ResetPage and Hub.CurrentPage ~= LeavePage then
		PushPage(LeavePage)
	elseif Hub.Visible and (Input.KeyCode == Enum.KeyCode.Return or Input.KeyCode == Enum.KeyCode.KeypadEnter) then
		if Hub.CurrentPage == ResetPage then ResetCharacter()
		elseif Hub.CurrentPage == LeavePage then LeaveGame() end
	end
end)

local function HookNativeMenu()
	local Hooked = {}
	local function GetNativeTarget()
		if Hub.NativeMenuTarget == nil then return true end
		return Hub.NativeMenuTarget
	end
	local function NativeOpened()
		HideNativeMenu()
		if tick() < Hub.SuppressNativeOpenUntil then return end
		SetVisibility(GetNativeTarget())
		Hub.NativeMenuTarget = nil
	end
	local function HookObj(Obj)
		if not Obj or Hooked[Obj] or not Obj:IsA("GuiObject") then return end
		Hooked[Obj] = true
		Connect(Obj:GetPropertyChangedSignal("Visible"), function()
			if Obj.Visible then NativeOpened() end
		end)
		if Obj.Visible then NativeOpened() end
	end
	local RobloxGui = CoreGui:FindFirstChild("RobloxGui")
	local Shield = RobloxGui and RobloxGui:FindFirstChild("SettingsClippingShield")
	local function HookContainer(NewShield)
		if not NewShield then return end
		Shield = NewShield
		HideNativeMenu()
		for _, Obj in next, NewShield:GetDescendants() do HookObj(Obj) end
	end
	HookContainer(Shield)
	if RobloxGui then
		Connect(RobloxGui.DescendantAdded, function(Desc)
			if Desc.Name == "SettingsClippingShield" and Desc.Parent == RobloxGui then
				HookContainer(Desc)
			elseif Shield and Desc:IsDescendantOf(Shield) then
				HookObj(Desc)
				if Desc:IsA("GuiObject") and Desc.Visible then NativeOpened() end
			end
		end)
	end
	local TopBarApp = CoreGui:FindFirstChild("TopBarApp")
	TopBarApp = TopBarApp and TopBarApp:FindFirstChild("TopBarApp")
	local Holder = TopBarApp and TopBarApp:FindFirstChild("MenuIconHolder")
	local Hit = Holder and Holder:FindFirstChild("TriggerPoint") and Holder.TriggerPoint:FindFirstChild("IconHitArea")
	if Hit and Hit:IsA("GuiButton") then
		Connect(Hit.MouseButton1Click, function()
			local Target = not Hub.Visible
			Hub.NativeMenuTarget = Target
			Spawn(function()
				Wait()
				SetVisibility(Target)
				if Hub.NativeMenuTarget == Target then Hub.NativeMenuTarget = nil end
			end)
		end)
	end
end

Spawn(HookNativeMenu)

local Api = {}

function Api:SetVisibility(Visible, NoAnimation, CustomPage)
	SetVisibility(Visible, NoAnimation, CustomPage)
end

function Api:ToggleVisibility()
	ToggleVisibility()
end

function Api:GetVisibility()
	return Hub.Visible
end

function Api:ReportPlayer(Player)
	if OpenReportPlayer then OpenReportPlayer(Player) end
end

Api.Instance = Hub
getgenv().SettingHub = Api

local LibraryPages = {
	Players = PlayersPage,
	Settings = GamePage,
	Report = ReportPage,
	Help = HelpPage,
}
if RecordPage then LibraryPages["Record"] = RecordPage end

local function BuildTabApi(Page)
	local Tab = {}

	function Tab:AddSectionHeader(Title, IconName)
		return MakeSectionHeader(Page, Title, IconName)
	end

	function Tab:AddSlider(Name, Steps, Default, Callback, MinStep)
		return MakeSlider(Page, Name, Steps, Default, Callback, MinStep)
	end

	function Tab:AddSelector(Name, Values, Default, Callback)
		return MakeSelector(Page, Name, Values, Default, Callback)
	end

	function Tab:AddToggle(Name, OnText, OffText, Default, Callback)
		local StartIndex = (Default == true or Default == 1) and 1 or 2
		return MakeSelector(Page, Name, {OnText or "On", OffText or "Off"}, StartIndex, function(Index)
			if Callback then Callback(Index == 1) end
		end)
	end

	function Tab:AddDropDown(Name, Values, Default, Callback)
		return MakeDropDown(Page, Name, Values, Default, Callback)
	end

	function Tab:AddMultiDropDown(Name, Values, Callback)
		return MakeMultiDropDown(Page, Name, Values, Callback)
	end

	function Tab:AddButton(Name, ButtonText, Callback)
		return MakeButtonRow(Page, Name, ButtonText, Callback)
	end

	function Tab:AddValue(Name, Value)
		return MakeValueRow(Page, Name, Value)
	end

	function Tab:AddRow(Name, Height)
		return MakeRow(Page, Name, Height)
	end

	Tab.Page = Page
	return Tab
end

function Api:Hijack(TabName)
	local Page = LibraryPages[TabName]
	if not Page then return nil end
	return BuildTabApi(Page)
end

function Api:CreateTab(Name, IconName, Width)
	local Page = MakePage(Name)
	AddPage(Page, Name, IconName, Width)
	LibraryPages[Name] = Page
	return BuildTabApi(Page)
end

function Api:GetTabNames()
	local Names = {}
	for N in next, LibraryPages do Insert(Names, N) end
	return Names
end

return Api
