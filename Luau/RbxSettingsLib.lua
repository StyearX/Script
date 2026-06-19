local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")

local Spawn, Wait = task.spawn, task.wait
local Insert = table.insert
local Clamp, Floor = math.clamp, math.floor

local Theme = {
	Background = Color3.fromRGB(18, 18, 20),
	Surface = Color3.fromRGB(28, 28, 32),
	SurfaceAlt = Color3.fromRGB(35, 37, 41),
	Row = Color3.fromRGB(35, 37, 39),
	RowHover = Color3.fromRGB(48, 50, 55),
	TabActive = Color3.fromRGB(42, 44, 50),
	Accent = Color3.fromRGB(180, 0, 0),
	AccentHover = Color3.fromRGB(210, 20, 20),
	AccentDim = Color3.fromRGB(120, 0, 0),
	TextPrimary = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(190, 192, 200),
	TextMuted = Color3.fromRGB(110, 114, 124),
	Divider = Color3.fromRGB(50, 52, 58),
	Overlay = Color3.fromRGB(0, 0, 0),
	Slider = Color3.fromRGB(70, 74, 84),
	Corner = UDim.new(0, 8),
	CornerLarge = UDim.new(0, 12),
	CornerFull = UDim.new(0.5, 0),
	FontRegular = Enum.Font.BuilderSans,
	FontMedium = Enum.Font.BuilderSansMedium,
	SizeRow = 17,
	SizeTab = 14,
	SizeSection = 13,
	SizeLarge = 22,
	RowHeight = 52,
	SectionHeight = 38,
	ZBase = 200,
}

local LucideData = nil

local function FetchRaw(Url)
	local Raw
	pcall(function() Raw = game:HttpGet(Url) end)
	if not Raw or Raw == "" then
		pcall(function() Raw = HttpService:GetAsync(Url) end)
	end
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
		LucideData = { Icons = Result.Icons, Sprites = Result.Spritesheets }
	else
		LucideData = { Flat = Result }
	end
end

local function PascalToKebab(Name)
	Name = Name:gsub("(%l)(%u)", "%1-%2")
	Name = Name:gsub("(%a)(%d)", "%1-%2")
	Name = Name:gsub("(%d)(%a)", "%1-%2")
	return Name:lower()
end

local function GetIcon(Name)
	if not LucideData or not Name then return nil end
	local Kebab = PascalToKebab(Name)
	if LucideData.Icons then
		local Entry = LucideData.Icons[Kebab] or LucideData.Icons[Name]
		if not Entry then return nil end
		local Key = Entry.Image
		local Id = LucideData.Sprites[Key] or tostring(Key)
		if type(Id) == "number" then Id = "rbxassetid://" .. tostring(Id)
		elseif not tostring(Id):match("^rbxasset") then Id = "rbxassetid://" .. tostring(Id) end
		return { Id, Entry.ImageRectSize, Entry.ImageRectPosition }
	elseif LucideData.Flat then
		local Entry = LucideData.Flat[Kebab] or LucideData.Flat[Name]
		if type(Entry) == "string" then
			return { Entry, Vector2.new(0, 0), Vector2.new(0, 0) }
		elseif type(Entry) == "table" and Entry.Image then
			local Id = tostring(Entry.Image)
			if not Id:match("^rbxasset") then Id = "rbxassetid://" .. Id end
			return { Id, Entry.ImageRectSize or Vector2.new(0, 0), Entry.ImageRectPosition or Vector2.new(0, 0) }
		end
	end
	return nil
end

local function New(Class, Props)
	local Obj = Instance.new(Class)
	for K, V in next, (Props or {}) do
		Obj[K] = V
	end
	return Obj
end

local function Corner(Parent, Radius)
	New("UICorner", { Parent = Parent, CornerRadius = Radius or Theme.Corner })
end

local function Stroke(Parent, Color, Thickness)
	New("UIStroke", { Parent = Parent, Color = Color or Theme.Divider, Thickness = Thickness or 1 })
end

local function Padding(Parent, Top, Bottom, Left, Right)
	New("UIPadding", {
		Parent = Parent,
		PaddingTop = UDim.new(0, Top or 0),
		PaddingBottom = UDim.new(0, Bottom or 0),
		PaddingLeft = UDim.new(0, Left or 0),
		PaddingRight = UDim.new(0, Right or 0),
	})
end

local function ApplyIcon(Label, IconName, Color)
	if not Label or not IconName then return end
	local Data = GetIcon(IconName)
	if not Data then return end
	Label.Image = Data[1]
	if type(Data[2]) == "userdata" then Label.ImageRectSize = Data[2] end
	if type(Data[3]) == "userdata" then Label.ImageRectOffset = Data[3] end
	if Color then Label.ImageColor3 = Color end
end

local Tweens = {}
local function LerpPos(Obj, Target, Frames)
	Tweens[Obj] = (Tweens[Obj] or 0) + 1
	local Id = Tweens[Obj]
	Spawn(function()
		local Start = Obj.Position
		for I = 1, Frames do
			if not Obj.Parent or Tweens[Obj] ~= Id then return end
			local A = I / Frames
			A = 1 - (1 - A) * (1 - A)
			Obj.Position = Start:Lerp(Target, A)
			Wait()
		end
		if Tweens[Obj] == Id then Obj.Position = Target end
	end)
end

local function TweenPos(Obj, Target, Dir, Style, Time, Cb)
	Tweens[Obj] = (Tweens[Obj] or 0) + 1
	local Id = Tweens[Obj]
	local Ok = pcall(function()
		Obj:TweenPosition(Target, Dir, Style, Time, true, function()
			if Tweens[Obj] ~= Id then return end
			Obj.Position = Target
			if Cb then Cb() end
		end)
	end)
	if not Ok then LerpPos(Obj, Target, math.max(1, Floor((Time or 0.15) * 60))) end
end

local ColorTweens = {}
local function TweenColor(Obj, Target, IsImage)
	ColorTweens[Obj] = (ColorTweens[Obj] or 0) + 1
	local Id = ColorTweens[Obj]
	Spawn(function()
		local Start = IsImage and Obj.ImageColor3 or Obj.BackgroundColor3
		for I = 1, 6 do
			if not Obj.Parent or ColorTweens[Obj] ~= Id then return end
			local C = Start:Lerp(Target, I / 6)
			if IsImage then Obj.ImageColor3 = C else Obj.BackgroundColor3 = C end
			Wait()
		end
	end)
end

local function MakeIconLabel(Parent, IconName, Color, Size, Anchor, Pos)
	local Ico = New("ImageLabel", {
		Parent = Parent,
		BackgroundTransparency = 1,
		Size = Size or UDim2.new(0, 18, 0, 18),
		AnchorPoint = Anchor or Vector2.new(0, 0.5),
		Position = Pos or UDim2.new(0, 0, 0.5, 0),
		Image = "",
		ImageColor3 = Color or Theme.TextMuted,
		ZIndex = (Parent and Parent.ZIndex or Theme.ZBase) + 1,
	})
	if IconName then ApplyIcon(Ico, IconName, Color) end
	return Ico
end

local Lib = {}

function Lib.CreateHub(Options)
	Options = Options or {}

	local Connections = {}
	local Objects = {}

	if getgenv().RbxSettingsHubData then
		for _, C in next, (getgenv().RbxSettingsHubData.Connections or {}) do
			pcall(function() C:Disconnect() end)
		end
		for _, O in next, (getgenv().RbxSettingsHubData.Objects or {}) do
			pcall(function() O:Destroy() end)
		end
	end
	getgenv().RbxSettingsHubData = { Connections = Connections, Objects = Objects }

	local function Connect(Signal, Callback)
		local C = Signal:Connect(Callback)
		Insert(Connections, C)
		return C
	end

	local function Protect(Fn)
		return pcall(Fn)
	end

	for _, Child in next, CoreGui:GetChildren() do
		if Child.Name == "RbxSettingsHubGui" then Child:Destroy() end
	end

	local Screen = New("ScreenGui", {
		Name = "RbxSettingsHubGui",
		Parent = CoreGui,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 9001,
		Enabled = true,
	})
	Insert(Objects, Screen)

	local Overlay = New("TextButton", {
		Name = "Overlay",
		Parent = Screen,
		BackgroundColor3 = Theme.Overlay,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Modal = true,
		Active = true,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = Theme.ZBase,
		Visible = false,
	})

	local Container = New("Frame", {
		Name = "HubContainer",
		Parent = Screen,
		BackgroundColor3 = Theme.Background,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 840, 0, 540),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		ZIndex = Theme.ZBase + 1,
		Visible = false,
	})
	Corner(Container, Theme.CornerLarge)
	Stroke(Container, Theme.Divider, 1)

	local HubBar = New("Frame", {
		Name = "HubBar",
		Parent = Container,
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 52),
		ZIndex = Theme.ZBase + 2,
	})
	Corner(HubBar, Theme.CornerLarge)
	New("Frame", {
		Parent = HubBar,
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 12),
		Position = UDim2.new(0, 0, 1, -12),
		ZIndex = Theme.ZBase + 2,
	})
	New("Frame", {
		Name = "BottomDivider",
		Parent = HubBar,
		BackgroundColor3 = Theme.Divider,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1),
		ZIndex = Theme.ZBase + 3,
	})

	local TabHolder = New("Frame", {
		Name = "TabHolder",
		Parent = HubBar,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -110, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		ZIndex = Theme.ZBase + 3,
	})
	New("UIListLayout", {
		Parent = TabHolder,
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
	})
	Padding(TabHolder, 0, 0, 8, 0)

	local TitleLabel = New("TextLabel", {
		Name = "TitleLabel",
		Parent = HubBar,
		BackgroundTransparency = 1,
		Font = Theme.FontMedium,
		TextSize = 16,
		TextColor3 = Theme.TextMuted,
		Text = Options.Title or "Settings",
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(0, 100, 1, 0),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -50, 0, 0),
		ZIndex = Theme.ZBase + 3,
	})

	local CloseBtn = New("ImageButton", {
		Name = "CloseBtn",
		Parent = HubBar,
		BackgroundColor3 = Color3.fromRGB(180, 40, 40),
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 26, 0, 26),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Image = "",
		AutoButtonColor = false,
		ZIndex = Theme.ZBase + 4,
	})
	Corner(CloseBtn, Theme.CornerFull)
	New("TextLabel", {
		Parent = CloseBtn,
		BackgroundTransparency = 1,
		Font = Theme.FontMedium,
		TextSize = 14,
		TextColor3 = Theme.TextPrimary,
		Text = "X",
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = Theme.ZBase + 5,
	})
	Connect(CloseBtn.MouseEnter, function() TweenColor(CloseBtn, Color3.fromRGB(220, 55, 55)) end)
	Connect(CloseBtn.MouseLeave, function() TweenColor(CloseBtn, Color3.fromRGB(180, 40, 40)) end)

	local PageClipper = New("Frame", {
		Name = "PageClipper",
		Parent = Container,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -52 - 58),
		Position = UDim2.new(0, 0, 0, 52),
		ClipsDescendants = true,
		ZIndex = Theme.ZBase + 2,
	})

	local PageView = New("ScrollingFrame", {
		Name = "PageView",
		Parent = PageClipper,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Divider,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ZIndex = Theme.ZBase + 2,
	})

	local BottomBar = New("Frame", {
		Name = "BottomBar",
		Parent = Container,
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 58),
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		ZIndex = Theme.ZBase + 2,
	})
	Corner(BottomBar, Theme.CornerLarge)
	New("Frame", {
		Parent = BottomBar,
		BackgroundColor3 = Theme.Surface,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 12),
		ZIndex = Theme.ZBase + 2,
	})
	New("Frame", {
		Name = "TopDivider",
		Parent = BottomBar,
		BackgroundColor3 = Theme.Divider,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = Theme.ZBase + 3,
	})
	New("UIListLayout", {
		Parent = BottomBar,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
	})
	Padding(BottomBar, 8, 8, 8, 8)

	local function Resize()
		local Vp = Screen.AbsoluteSize
		if Vp.X <= 0 or Vp.Y <= 0 then
			local Cam = workspace.CurrentCamera
			Vp = Cam and Cam.ViewportSize or Vector2.new(1280, 720)
		end
		local W = Clamp(Vp.X - 60, 560, 860)
		local H = Clamp(Vp.Y - 120, 380, 560)
		Container.Size = UDim2.new(0, W, 0, H)
		PageClipper.Size = UDim2.new(1, 0, 1, -52 - 58)
	end
	Resize()
	Connect(Screen:GetPropertyChangedSignal("AbsoluteSize"), Resize)
	Connect(workspace:GetPropertyChangedSignal("CurrentCamera"), Resize)
	Protect(function()
		Connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), Resize)
	end)

	local Hub = {
		Visible = false,
		Pages = {},
		CurrentPage = nil,
		MenuStack = {},
		NativeTarget = nil,
		SuppressUntil = 0,
	}

	local SwitchToPage
	local SetVisible
	local ActiveAlert = nil

	local function MakeTabButton(Page, DisplayName, IconName)
		local Tab = New("TextButton", {
			Name = Page.Name .. "Tab",
			Parent = TabHolder,
			BackgroundColor3 = Theme.Row,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = "",
			Size = UDim2.new(0, 0, 1, -10),
			AutomaticSize = Enum.AutomaticSize.X,
			LayoutOrder = #Hub.Pages + 1,
			ZIndex = Theme.ZBase + 4,
		})
		Corner(Tab)
		Padding(Tab, 0, 0, 10, 12)
		New("UIListLayout", {
			Parent = Tab,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
		})

		local TabIcon = MakeIconLabel(Tab, IconName, Theme.TextMuted, UDim2.new(0, 16, 0, 16), Vector2.new(0, 0.5))
		TabIcon.LayoutOrder = 1
		TabIcon.ZIndex = Theme.ZBase + 5

		local TabLabel = New("TextLabel", {
			Name = "Label",
			Parent = Tab,
			BackgroundTransparency = 1,
			Font = Theme.FontMedium,
			TextSize = Theme.SizeTab,
			TextColor3 = Theme.TextMuted,
			Text = DisplayName,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			LayoutOrder = 2,
			ZIndex = Theme.ZBase + 5,
		})

		local ActiveIndicator = New("Frame", {
			Name = "ActiveIndicator",
			Parent = Tab,
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 2),
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 0, 1, 5),
			ZIndex = Theme.ZBase + 5,
		})
		Corner(ActiveIndicator, UDim.new(1, 0))

		Page.Tab = Tab
		Page.TabIcon = TabIcon
		Page.TabLabel = TabLabel
		Page.ActiveIndicator = ActiveIndicator

		Connect(Tab.MouseEnter, function()
			if Hub.CurrentPage ~= Page then
				TweenColor(Tab, Theme.SurfaceAlt)
				Tab.BackgroundTransparency = 0
			end
		end)
		Connect(Tab.MouseLeave, function()
			if Hub.CurrentPage ~= Page then
				Tab.BackgroundTransparency = 1
			end
		end)
		Connect(Tab.MouseButton1Click, function()
			SwitchToPage(Page)
		end)
	end

	SwitchToPage = function(Page, NoStack, NoAnim)
		if not Page then return end
		local Old = Hub.CurrentPage
		local OldFrame = Old and Old.Frame

		for _, P in next, Hub.Pages do
			if P ~= Page then
				if P.Frame then P.Frame.Visible = false end
				if P.Tab then P.Tab.BackgroundTransparency = 1 end
				if P.TabLabel then P.TabLabel.TextColor3 = Theme.TextMuted end
				if P.TabIcon then P.TabIcon.ImageColor3 = Theme.TextMuted end
				if P.ActiveIndicator then P.ActiveIndicator.BackgroundTransparency = 1 end
			end
		end

		Page.Frame.Parent = PageView
		Page.Frame.Visible = true

		local PageW = PageClipper.AbsoluteSize.X
		if not NoAnim and OldFrame and OldFrame ~= Page.Frame and OldFrame.Visible then
			local Dir = (Page.LayoutOrder >= (Old and Old.LayoutOrder or 1)) and 1 or -1
			Page.Frame.Position = UDim2.new(0, Dir * PageW, 0, 0)
			TweenPos(Page.Frame, UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.1)
			TweenPos(OldFrame, UDim2.new(0, -Dir * PageW, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1)
			task.delay(0.12, function()
				if Hub.CurrentPage ~= Old and OldFrame then OldFrame.Visible = false end
			end)
		else
			Page.Frame.Position = UDim2.new(0, 0, 0, 0)
			if OldFrame and OldFrame ~= Page.Frame then OldFrame.Visible = false end
		end

		PageView.CanvasPosition = Vector2.new(0, 0)
		PageView.CanvasSize = UDim2.new(0, 0, 0, math.max(Page.Frame.AbsoluteSize.Y, PageClipper.AbsoluteSize.Y))
		Hub.CurrentPage = Page

		if Page.Tab then
			TweenColor(Page.Tab, Theme.SurfaceAlt)
			Page.Tab.BackgroundTransparency = 0
		end
		if Page.TabLabel then Page.TabLabel.TextColor3 = Theme.TextPrimary end
		if Page.TabIcon then Page.TabIcon.ImageColor3 = Theme.Accent end
		if Page.ActiveIndicator then Page.ActiveIndicator.BackgroundTransparency = 0 end

		if not NoStack and Hub.MenuStack[#Hub.MenuStack] ~= Page then
			Insert(Hub.MenuStack, Page)
		end
	end

	local function HideNative()
		local RobloxGui = CoreGui:FindFirstChild("RobloxGui")
		local Shield = RobloxGui and RobloxGui:FindFirstChild("SettingsClippingShield")
		if Shield then
			local function HideObj(Obj)
				if not Obj:IsA("GuiObject") then return end
				pcall(function() Obj.Visible = false end)
				pcall(function() Obj.Active = false end)
				pcall(function() Obj.BackgroundTransparency = 1 end)
				pcall(function() Obj.ImageTransparency = 1 end)
				pcall(function() Obj.TextTransparency = 1 end)
			end
			HideObj(Shield)
			for _, D in next, Shield:GetDescendants() do HideObj(D) end
		end
	end

	local InputLockBound = false
	local InputLockNames = {}
	local SavedMouseBehavior = nil

	local function SinkInput()
		local Focused = nil
		Protect(function() Focused = UserInputService:GetFocusedTextBox() end)
		return Focused and Enum.ContextActionResult.Pass or Enum.ContextActionResult.Sink
	end

	local LockInputList = {}
	local function RegisterLockInput(EnumName, ItemName)
		Protect(function()
			local Item = Enum[EnumName][ItemName]
			if Item then Insert(LockInputList, Item) end
		end)
	end
	RegisterLockInput("PlayerActions", "CharacterForward")
	RegisterLockInput("PlayerActions", "CharacterBackward")
	RegisterLockInput("PlayerActions", "CharacterLeft")
	RegisterLockInput("PlayerActions", "CharacterRight")
	RegisterLockInput("PlayerActions", "CharacterJump")
	RegisterLockInput("KeyCode", "W"); RegisterLockInput("KeyCode", "A")
	RegisterLockInput("KeyCode", "S"); RegisterLockInput("KeyCode", "D")
	RegisterLockInput("KeyCode", "Space")
	RegisterLockInput("KeyCode", "LeftShift"); RegisterLockInput("KeyCode", "RightShift")
	RegisterLockInput("UserInputType", "MouseButton2")

	local function SetInputLocked(Locked)
		if InputLockBound == Locked then return end
		InputLockBound = Locked
		if Locked then
			Protect(function()
				SavedMouseBehavior = UserInputService.MouseBehavior
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				UserInputService.MouseIconEnabled = true
			end)
			InputLockNames = {}
			for I, Input in next, LockInputList do
				local ActionName = "RbxHubLock" .. tostring(I)
				local Ok = pcall(function()
					ContextActionService:BindCoreActionAtPriority(ActionName, SinkInput, false, 10000, Input)
				end)
				if not Ok then
					pcall(function() ContextActionService:BindCoreAction(ActionName, SinkInput, false, Input) end)
				end
				Insert(InputLockNames, ActionName)
			end
		else
			for _, Name in next, InputLockNames do
				pcall(function() ContextActionService:UnbindCoreAction(Name) end)
				pcall(function() ContextActionService:UnbindAction(Name) end)
			end
			InputLockNames = {}
			Protect(function()
				UserInputService.MouseBehavior = SavedMouseBehavior or Enum.MouseBehavior.Default
				SavedMouseBehavior = nil
			end)
		end
	end

	SetVisible = function(Visible, NoAnim, CustomPage)
		if Hub.Visible == Visible and not CustomPage then return end
		Hub.Visible = Visible
		Overlay.Visible = Visible

		if Visible then
			SetInputLocked(true)
			HideNative()
			Container.Visible = true
			HubBar.Visible = true
			BottomBar.Visible = true
			PageClipper.Visible = true
			if NoAnim then
				Container.Position = UDim2.new(0.5, 0, 0.5, 0)
			else
				Container.Position = UDim2.new(0.5, 0, 0.45, 0)
				TweenPos(Container, UDim2.new(0.5, 0, 0.5, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Back, 0.22)
			end
			SwitchToPage(CustomPage or Hub.Pages[1] or Hub.CurrentPage, true, NoAnim)
		else
			SetInputLocked(false)
			if NoAnim then
				Container.Visible = false
			else
				TweenPos(Container, UDim2.new(0.5, 0, 0.54, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quad, 0.16, function()
					if not Hub.Visible then Container.Visible = false end
				end)
			end
		end
	end

	local function MakeRow(Parent, Height, Order)
		local Row = New("ImageButton", {
			Name = "RowFrame",
			Parent = Parent,
			BackgroundColor3 = Theme.Row,
			BackgroundTransparency = 0.6,
			Image = "",
			AutoButtonColor = false,
			Selectable = false,
			Active = false,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, Height or Theme.RowHeight),
			LayoutOrder = Order or 0,
			ZIndex = Theme.ZBase + 3,
		})
		Corner(Row)
		return Row
	end

	local function MakeRowLabel(Row, Text, IconName)
		local LabelContainer = New("Frame", {
			Parent = Row,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.42, -14, 1, 0),
			Position = UDim2.new(0, 10, 0, 0),
			ZIndex = Row.ZIndex + 1,
		})
		if IconName then
			local Ico = MakeIconLabel(LabelContainer, IconName, Theme.Accent, UDim2.new(0, 16, 0, 16))
			Ico.Position = UDim2.new(0, 0, 0.5, 0)
			Ico.ZIndex = Row.ZIndex + 2
			New("TextLabel", {
				Parent = LabelContainer,
				BackgroundTransparency = 1,
				Font = Theme.FontMedium,
				TextSize = Theme.SizeRow,
				TextColor3 = Theme.TextPrimary,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = Text or "",
				Size = UDim2.new(1, -24, 1, 0),
				Position = UDim2.new(0, 22, 0, 0),
				ZIndex = Row.ZIndex + 2,
			})
		else
			New("TextLabel", {
				Parent = LabelContainer,
				BackgroundTransparency = 1,
				Font = Theme.FontMedium,
				TextSize = Theme.SizeRow,
				TextColor3 = Theme.TextPrimary,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = Text or "",
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = Row.ZIndex + 2,
			})
		end
	end

	local function BindHover(Row)
		Connect(Row.MouseEnter, function()
			TweenColor(Row, Theme.RowHover)
			Row.BackgroundTransparency = 0.4
		end)
		Connect(Row.MouseLeave, function()
			TweenColor(Row, Theme.Row)
			Row.BackgroundTransparency = 0.6
		end)
	end

	local function CreatePageFrame(Name)
		local PageFrame = New("Frame", {
			Name = Name .. "Page",
			Parent = PageView,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Visible = false,
			ZIndex = Theme.ZBase + 2,
		})
		New("UIListLayout", {
			Parent = PageFrame,
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 3),
		})
		Padding(PageFrame, 12, 14, 14, 14)
		return PageFrame
	end

	local function GetRowOrder(Frame)
		local Count = 0
		for _, C in next, Frame:GetChildren() do
			if not C:IsA("UIListLayout") and not C:IsA("UIPadding") then
				Count = Count + 1
			end
		end
		return Count + 1
	end

	local function AddSection(PageFrame, Title, IconName)
		local Order = GetRowOrder(PageFrame)
		local Sec = New("Frame", {
			Name = "Section_" .. Title,
			Parent = PageFrame,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, Theme.SectionHeight),
			LayoutOrder = Order,
			ZIndex = Theme.ZBase + 3,
		})
		if IconName then
			local Ico = MakeIconLabel(Sec, IconName, Theme.Accent, UDim2.new(0, 14, 0, 14))
			Ico.Position = UDim2.new(0, 2, 0.5, 0)
			Ico.ZIndex = Theme.ZBase + 4
			New("TextLabel", {
				Parent = Sec,
				BackgroundTransparency = 1,
				Font = Theme.FontMedium,
				TextSize = Theme.SizeSection,
				TextColor3 = Theme.Accent,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = Title:upper(),
				Size = UDim2.new(1, -24, 1, 0),
				Position = UDim2.new(0, 20, 0, 0),
				ZIndex = Theme.ZBase + 4,
			})
		else
			New("TextLabel", {
				Parent = Sec,
				BackgroundTransparency = 1,
				Font = Theme.FontMedium,
				TextSize = Theme.SizeSection,
				TextColor3 = Theme.Accent,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = Title:upper(),
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 2, 0, 0),
				ZIndex = Theme.ZBase + 4,
			})
		end
		New("Frame", {
			Parent = Sec,
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 0.8,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 1),
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 0, 1, 0),
			ZIndex = Theme.ZBase + 3,
		})
		return Sec
	end

	local function AddSelector(PageFrame, Label, Values, DefaultIndex, Callback, IconName)
		local Order = GetRowOrder(PageFrame)
		local CurrentIndex = DefaultIndex or 1
		local Row = MakeRow(PageFrame, Theme.RowHeight, Order)
		BindHover(Row)
		MakeRowLabel(Row, Label, IconName)

		local RightPart = New("Frame", {
			Name = "SelectorRight",
			Parent = Row,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.58, 0, 1, 0),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -8, 0, 0),
			ZIndex = Row.ZIndex + 1,
		})

		local LeftBtn = New("ImageButton", {
			Parent = RightPart,
			BackgroundTransparency = 1,
			Image = "",
			AutoButtonColor = false,
			Size = UDim2.new(0, 32, 1, 0),
			ZIndex = Row.ZIndex + 2,
		})
		MakeIconLabel(LeftBtn, "ChevronLeft", Theme.TextSecondary, UDim2.new(0, 14, 0, 14), Vector2.new(0.5, 0.5), UDim2.new(0.5, 0, 0.5, 0))

		local ValueLabel = New("TextLabel", {
			Name = "ValueText",
			Parent = RightPart,
			BackgroundTransparency = 1,
			Font = Theme.FontRegular,
			TextSize = Theme.SizeRow,
			TextColor3 = Theme.TextSecondary,
			Text = (Values and Values[CurrentIndex]) or "",
			Size = UDim2.new(1, -64, 1, 0),
			Position = UDim2.new(0, 32, 0, 0),
			ZIndex = Row.ZIndex + 2,
		})

		local RightBtn = New("ImageButton", {
			Parent = RightPart,
			BackgroundTransparency = 1,
			Image = "",
			AutoButtonColor = false,
			Size = UDim2.new(0, 32, 1, 0),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			ZIndex = Row.ZIndex + 2,
		})
		MakeIconLabel(RightBtn, "ChevronRight", Theme.TextSecondary, UDim2.new(0, 14, 0, 14), Vector2.new(0.5, 0.5), UDim2.new(0.5, 0, 0.5, 0))

		local OverrideLabel = New("TextLabel", {
			Name = "OverrideText",
			Parent = RightPart,
			BackgroundTransparency = 1,
			Font = Theme.FontRegular,
			TextSize = 15,
			TextColor3 = Theme.TextMuted,
			Text = "Set by Developer",
			Visible = false,
			Size = UDim2.new(1, -8, 1, 0),
			Position = UDim2.new(0, 4, 0, 0),
			ZIndex = Row.ZIndex + 2,
		})

		local Api = { Interactable = true, Row = Row, SelectorFrame = RightPart, RowFrame = Row, Selection = RightPart }
		Api.OverrideLabel = OverrideLabel

		local function Apply(Delta)
			if not Api.Interactable then return end
			CurrentIndex = CurrentIndex + Delta
			if CurrentIndex > #Values then CurrentIndex = 1
			elseif CurrentIndex < 1 then CurrentIndex = #Values end
			ValueLabel.Text = Values[CurrentIndex] or ""
			Api.CurrentIndex = CurrentIndex
			if Callback then Callback(CurrentIndex, Values[CurrentIndex]) end
		end

		Connect(LeftBtn.MouseButton1Click, function() Apply(-1) end)
		Connect(RightBtn.MouseButton1Click, function() Apply(1) end)
		Connect(Row.MouseButton1Click, function() Apply(1) end)

		function Api:SetSelectionIndex(Index, Fire)
			if not Index or not Values or #Values == 0 then return end
			CurrentIndex = Clamp(Index, 1, #Values)
			Api.CurrentIndex = CurrentIndex
			ValueLabel.Text = Values[CurrentIndex] or ""
			if Fire and Callback then Callback(CurrentIndex, Values[CurrentIndex]) end
		end
		function Api:GetSelectedIndex() return CurrentIndex end
		function Api:GetSelectedValue() return Values and Values[CurrentIndex] end
		function Api:SetInteractable(State)
			Api.Interactable = State
			ValueLabel.Visible = State
			OverrideLabel.Visible = not State
			LeftBtn.Visible = State
			RightBtn.Visible = State
		end
		function Api:UpdateDropDownList(NewValues)
			Values = NewValues
			CurrentIndex = Clamp(CurrentIndex or 1, 1, math.max(#Values, 1))
			ValueLabel.Text = (Values and Values[CurrentIndex]) or ""
			Api.CurrentIndex = CurrentIndex
		end
		function Api:SetPosition(Pos) RightPart.Position = Pos end
		function Api:SetSize(Size) RightPart.Size = Size end
		function Api:ResetSelectionIndex(Fire)
			CurrentIndex = 1
			Api.CurrentIndex = 1
			ValueLabel.Text = (Values and Values[1]) or ""
			if Fire and Callback then Callback(1, Values and Values[1]) end
		end

		Api.CurrentIndex = CurrentIndex
		return Api
	end

	local function AddSlider(PageFrame, Label, Steps, DefaultValue, Callback, MinStep, IconName)
		MinStep = MinStep or 0
		local Current = Clamp(DefaultValue or MinStep, MinStep, Steps)
		local Order = GetRowOrder(PageFrame)
		local Row = MakeRow(PageFrame, Theme.RowHeight, Order)
		BindHover(Row)
		MakeRowLabel(Row, Label, IconName)

		local RightPart = New("Frame", {
			Name = "SliderRight",
			Parent = Row,
			BackgroundTransparency = 1,
			Size = UDim2.new(0.58, 0, 1, 0),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -8, 0, 0),
			ZIndex = Row.ZIndex + 1,
		})

		local LeftBtn = New("ImageButton", {
			Parent = RightPart,
			BackgroundTransparency = 1,
			Image = "",
			AutoButtonColor = false,
			Size = UDim2.new(0, 32, 1, 0),
			ZIndex = Row.ZIndex + 2,
		})
		MakeIconLabel(LeftBtn, "ChevronLeft", Theme.TextSecondary, UDim2.new(0, 14, 0, 14), Vector2.new(0.5, 0.5), UDim2.new(0.5, 0, 0.5, 0))

		local SegHolder = New("Frame", {
			Parent = RightPart,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -64, 0, 24),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 32, 0.5, 0),
			ZIndex = Row.ZIndex + 2,
		})

		local RightBtn = New("ImageButton", {
			Parent = RightPart,
			BackgroundTransparency = 1,
			Image = "",
			AutoButtonColor = false,
			Size = UDim2.new(0, 32, 1, 0),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			ZIndex = Row.ZIndex + 2,
		})
		MakeIconLabel(RightBtn, "ChevronRight", Theme.TextSecondary, UDim2.new(0, 14, 0, 14), Vector2.new(0.5, 0.5), UDim2.new(0.5, 0, 0.5, 0))

		local Segments = {}
		for I = 1, Steps do
			local Seg = New("Frame", {
				Parent = SegHolder,
				BackgroundColor3 = Theme.Slider,
				BackgroundTransparency = 0.4,
				BorderSizePixel = 0,
				Size = UDim2.new(1 / Steps, -2, 1, 0),
				Position = UDim2.new((I - 1) / Steps, 1, 0, 0),
				ZIndex = Row.ZIndex + 3,
			})
			Corner(Seg, UDim.new(0, 4))
			Segments[I] = Seg
		end

		local Dragging = false
		local Api = { Interactable = true, SliderFrame = RightPart, RowFrame = Row, Selection = RightPart }

		local function Refresh()
			for I, Seg in next, Segments do
				local Active = Api.Interactable and I <= Current
				Seg.BackgroundColor3 = Active and Theme.Accent or Theme.Slider
				Seg.BackgroundTransparency = Active and 0 or 0.4
			end
			LeftBtn.Visible = Api.Interactable and Current > MinStep
			RightBtn.Visible = Api.Interactable and Current < Steps
		end

		local function SetVal(V)
			V = Clamp(V, MinStep, Steps)
			if Current == V then return end
			Current = V
			Refresh()
			if Callback then Callback(Current) end
		end

		local Capture = New("TextButton", {
			Parent = SegHolder,
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Active = true,
			Size = UDim2.new(1, 0, 2, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			ZIndex = Row.ZIndex + 4,
		})

		local function FromX(X)
			local AbsX = SegHolder.AbsolutePosition.X
			local AbsW = SegHolder.AbsoluteSize.X
			local Alpha = Clamp((X - AbsX) / math.max(AbsW, 1), 0, 1)
			SetVal(Clamp(Floor(Alpha * Steps + 0.5), MinStep, Steps))
		end

		Connect(Capture.InputBegan, function(I)
			if I.UserInputType == Enum.UserInputType.MouseButton1 or I.UserInputType == Enum.UserInputType.Touch then
				Dragging = true
				FromX(I.Position.X)
			end
		end)
		Connect(UserInputService.InputChanged, function(I)
			if Dragging and (I.UserInputType == Enum.UserInputType.MouseMovement or I.UserInputType == Enum.UserInputType.Touch) then
				FromX(I.Position.X)
			end
		end)
		Connect(UserInputService.InputEnded, function(I)
			if I.UserInputType == Enum.UserInputType.MouseButton1 or I.UserInputType == Enum.UserInputType.Touch then
				Dragging = false
			end
		end)
		Connect(LeftBtn.MouseButton1Click, function() if Api.Interactable then SetVal(Current - 1) end end)
		Connect(RightBtn.MouseButton1Click, function() if Api.Interactable then SetVal(Current + 1) end end)

		Refresh()

		function Api:SetValue(V) Current = Clamp(V, MinStep, Steps); Refresh() end
		function Api:GetValue() return Current end
		function Api:SetInteractable(State)
			Api.Interactable = State
			Capture.Active = State
			Refresh()
		end
		function Api:SetMinStep(NewMin)
			MinStep = Clamp(NewMin or 0, 0, Steps)
			Current = Clamp(Current, MinStep, Steps)
			Refresh()
		end

		return Api
	end

	local function AddDropdown(PageFrame, Label, Values, DefaultIndex, Callback, IconName)
		local Order = GetRowOrder(PageFrame)
		local Current = DefaultIndex
		local Row = MakeRow(PageFrame, Theme.RowHeight, Order)
		BindHover(Row)
		MakeRowLabel(Row, Label, IconName)

		local DdBtn = New("TextButton", {
			Parent = Row,
			BackgroundColor3 = Theme.SurfaceAlt,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Theme.FontRegular,
			TextSize = 15,
			TextColor3 = Theme.TextSecondary,
			Text = (Current and Values and Values[Current]) or "Select...",
			TextXAlignment = Enum.TextXAlignment.Left,
			ClipsDescendants = true,
			Size = UDim2.new(0.52, 0, 0, 34),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -8, 0.5, 0),
			ZIndex = Row.ZIndex + 2,
		})
		Corner(DdBtn, UDim.new(0, 6))
		Stroke(DdBtn, Theme.Divider)
		Padding(DdBtn, 0, 0, 10, 30)
		MakeIconLabel(DdBtn, "ChevronDown", Theme.TextMuted, UDim2.new(0, 14, 0, 14), Vector2.new(1, 0.5), UDim2.new(1, -8, 0.5, 0))

		local DdOverlay = New("TextButton", {
			Parent = Screen,
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = Theme.ZBase + 40,
			Visible = false,
		})

		local DdPanel = New("Frame", {
			Parent = Screen,
			BackgroundColor3 = Theme.Surface,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 280, 0, 200),
			ZIndex = Theme.ZBase + 41,
			Visible = false,
		})
		Corner(DdPanel, UDim.new(0, 8))
		Stroke(DdPanel, Theme.Divider)

		local DdScroll = New("ScrollingFrame", {
			Parent = DdPanel,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -8, 1, -8),
			Position = UDim2.new(0, 4, 0, 4),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Theme.Divider,
			ZIndex = Theme.ZBase + 42,
		})
		New("UIListLayout", {
			Parent = DdScroll,
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
		})

		local Api = { Interactable = true, Row = Row, DropDownFrame = DdBtn, Selection = DdBtn }

		local function SetSelection(Index, Fire)
			Current = Index
			Api.CurrentIndex = Index
			DdBtn.Text = (Index and Values and Values[Index]) or "Select..."
			DdPanel.Visible = false
			DdOverlay.Visible = false
			if Fire and Callback then Callback(Index, Index and Values and Values[Index]) end
		end

		local function Rebuild(NewVals)
			Values = NewVals or Values
			for _, C in next, DdScroll:GetChildren() do
				if C:IsA("TextButton") then C:Destroy() end
			end
			if not Values then return end
			for I, V in next, Values do
				local IsActive = I == Current
				local Opt = New("TextButton", {
					Parent = DdScroll,
					BackgroundColor3 = IsActive and Theme.SurfaceAlt or Theme.Row,
					BackgroundTransparency = IsActive and 0 or 0.7,
					BorderSizePixel = 0,
					AutoButtonColor = false,
					Font = Theme.FontRegular,
					TextSize = 15,
					TextColor3 = IsActive and Theme.TextPrimary or Theme.TextSecondary,
					TextXAlignment = Enum.TextXAlignment.Left,
					Text = V,
					Size = UDim2.new(1, 0, 0, 34),
					ZIndex = Theme.ZBase + 43,
					LayoutOrder = I,
				})
				Corner(Opt, UDim.new(0, 6))
				Padding(Opt, 0, 0, 10, 0)
				Connect(Opt.MouseEnter, function()
					if I ~= Current then TweenColor(Opt, Theme.RowHover); Opt.BackgroundTransparency = 0 end
				end)
				Connect(Opt.MouseLeave, function()
					if I ~= Current then Opt.BackgroundTransparency = 0.7 end
				end)
				Connect(Opt.MouseButton1Click, function() SetSelection(I, true) end)
			end
			DdScroll.CanvasSize = UDim2.new(0, 0, 0, #Values * 36)
			DdPanel.Size = UDim2.new(0, 280, 0, math.min(#Values * 36 + 10, 220))
			SetSelection(Current, false)
		end

		Connect(DdBtn.MouseButton1Click, function()
			if not Api.Interactable then return end
			local AbsPos = DdBtn.AbsolutePosition
			local AbsSize = DdBtn.AbsoluteSize
			DdPanel.Position = UDim2.new(0, AbsPos.X, 0, AbsPos.Y + AbsSize.Y + 4)
			DdPanel.Visible = not DdPanel.Visible
			DdOverlay.Visible = DdPanel.Visible
		end)
		Connect(DdOverlay.MouseButton1Click, function()
			DdPanel.Visible = false
			DdOverlay.Visible = false
		end)

		Rebuild(Values)

		function Api:UpdateDropDownList(NewVals) Rebuild(NewVals) end
		function Api:SetSelectionIndex(Index, Fire)
			if not Index or not Values or Index < 1 or Index > #Values then return false end
			SetSelection(Index, Fire)
			return true
		end
		function Api:SetSelectionByValue(Val, Fire)
			if not Values then return false end
			for I, V in next, Values do
				if V == Val then SetSelection(I, Fire); return true end
			end
			return false
		end
		function Api:ResetSelectionIndex(Fire) SetSelection(nil, Fire) end
		function Api:GetSelectedIndex() return Current end
		function Api:GetSelectedValue() return Current and Values and Values[Current] end
		function Api:SetInteractable(State)
			Api.Interactable = State
			DdBtn.TextTransparency = State and 0 or 0.55
			DdBtn.Active = State
		end

		Api.CurrentIndex = Current
		return Api
	end

	local function AddButton(PageFrame, Label, BtnText, Callback, IconName)
		local Order = GetRowOrder(PageFrame)
		local Row = MakeRow(PageFrame, Theme.RowHeight, Order)
		BindHover(Row)
		MakeRowLabel(Row, Label, IconName)

		local Btn = New("TextButton", {
			Parent = Row,
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Theme.FontMedium,
			TextSize = 15,
			TextColor3 = Theme.TextPrimary,
			Text = BtnText or "Open",
			Size = UDim2.new(0, 130, 0, 34),
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			ZIndex = Row.ZIndex + 2,
		})
		Corner(Btn, UDim.new(0, 6))
		Connect(Btn.MouseEnter, function() TweenColor(Btn, Theme.AccentHover) end)
		Connect(Btn.MouseLeave, function() TweenColor(Btn, Theme.Accent) end)
		if Callback then Connect(Btn.MouseButton1Click, Callback) end
		return Btn, Row
	end

	local function AddValue(PageFrame, Label, Value, IconName)
		local Order = GetRowOrder(PageFrame)
		local Row = MakeRow(PageFrame, Theme.RowHeight, Order)
		MakeRowLabel(Row, Label, IconName)
		local ValLabel = New("TextLabel", {
			Parent = Row,
			BackgroundTransparency = 1,
			Font = Theme.FontRegular,
			TextSize = 15,
			TextColor3 = Theme.TextSecondary,
			TextXAlignment = Enum.TextXAlignment.Right,
			Text = tostring(Value or ""),
			Size = UDim2.new(0.55, -10, 1, 0),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -10, 0, 0),
			ZIndex = Row.ZIndex + 2,
		})
		return ValLabel, Row
	end

	local function AddRawRow(PageFrame, Height)
		local Order = GetRowOrder(PageFrame)
		return MakeRow(PageFrame, Height or Theme.RowHeight, Order)
	end

	local function ShowAlert(Message, OkText, Cleanup)
		if ActiveAlert then ActiveAlert:Destroy(); ActiveAlert = nil end
		local WasVisible = Hub.Visible
		Container.Visible = false

		local AlertBg = New("Frame", {
			Name = "AlertBg",
			Parent = Screen,
			BackgroundColor3 = Theme.Overlay,
			BackgroundTransparency = 0.4,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = Theme.ZBase + 70,
		})
		local AlertBox = New("Frame", {
			Name = "AlertBox",
			Parent = Screen,
			BackgroundColor3 = Theme.Surface,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 460, 0, 260),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			ZIndex = Theme.ZBase + 71,
		})
		Corner(AlertBox, Theme.CornerLarge)
		Stroke(AlertBox, Theme.Divider)

		local Combined = Instance.new("Folder")
		AlertBg.Parent = Screen
		ActiveAlert = Combined

		New("TextLabel", {
			Parent = AlertBox,
			BackgroundTransparency = 1,
			Font = Theme.FontMedium,
			TextSize = 17,
			TextColor3 = Theme.TextPrimary,
			TextWrapped = true,
			Text = Message,
			Size = UDim2.new(1, -40, 0.65, 0),
			Position = UDim2.new(0, 20, 0.08, 0),
			ZIndex = Theme.ZBase + 72,
		})
		local OkBtn = New("TextButton", {
			Parent = AlertBox,
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Theme.FontMedium,
			TextSize = 16,
			TextColor3 = Theme.TextPrimary,
			Text = OkText or "Ok",
			Size = UDim2.new(0, 160, 0, 40),
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 1, -16),
			ZIndex = Theme.ZBase + 72,
		})
		Corner(OkBtn, UDim.new(0, 8))
		Connect(OkBtn.MouseEnter, function() TweenColor(OkBtn, Theme.AccentHover) end)
		Connect(OkBtn.MouseLeave, function() TweenColor(OkBtn, Theme.Accent) end)
		Connect(OkBtn.MouseButton1Click, function()
			AlertBg:Destroy()
			AlertBox:Destroy()
			ActiveAlert = nil
			if Cleanup then Cleanup()
			elseif WasVisible then Container.Visible = true end
		end)
	end

	local function AddBottomButton(Label, IconName, Callback, Order)
		local Btn = New("TextButton", {
			Name = Label .. "BottomBtn",
			Parent = BottomBar,
			BackgroundColor3 = Theme.SurfaceAlt,
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Font = Theme.FontMedium,
			TextSize = 14,
			TextColor3 = Theme.TextSecondary,
			Text = "",
			Size = UDim2.new(0, 170, 1, -16),
			LayoutOrder = Order or 1,
			ZIndex = Theme.ZBase + 3,
		})
		Corner(Btn, UDim.new(0, 8))
		New("UIListLayout", {
			Parent = Btn,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
		})
		if IconName then
			local Ico = MakeIconLabel(Btn, IconName, Theme.TextSecondary, UDim2.new(0, 15, 0, 15), Vector2.new(0, 0))
			Ico.LayoutOrder = 1
			Ico.ZIndex = Theme.ZBase + 4
		end
		New("TextLabel", {
			Parent = Btn,
			BackgroundTransparency = 1,
			Font = Theme.FontMedium,
			TextSize = 14,
			TextColor3 = Theme.TextSecondary,
			Text = Label,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			LayoutOrder = 2,
			ZIndex = Theme.ZBase + 4,
		})
		Connect(Btn.MouseEnter, function() TweenColor(Btn, Theme.RowHover) end)
		Connect(Btn.MouseLeave, function() TweenColor(Btn, Theme.SurfaceAlt) end)
		if Callback then Connect(Btn.MouseButton1Click, Callback) end
		return Btn
	end

	local function HookNative()
		local Hooked = {}

		local function NativeMenuOpened()
			HideNative()
			if tick() < Hub.SuppressUntil then return end
			SetVisible(Hub.NativeTarget ~= false and not Hub.Visible)
			Hub.NativeTarget = nil
		end

		local function HookObject(Obj)
			if not Obj or Hooked[Obj] or not Obj:IsA("GuiObject") then return end
			Hooked[Obj] = true
			Connect(Obj:GetPropertyChangedSignal("Visible"), function()
				if Obj.Visible then NativeMenuOpened() end
			end)
			if Obj.Visible then NativeMenuOpened() end
		end

		local RobloxGui = CoreGui:FindFirstChild("RobloxGui")
		local Shield = RobloxGui and RobloxGui:FindFirstChild("SettingsClippingShield")

		local function HookShield(S)
			if not S then return end
			Shield = S
			HideNative()
			for _, D in next, S:GetDescendants() do HookObject(D) end
		end

		HookShield(Shield)

		if RobloxGui then
			Connect(RobloxGui.DescendantAdded, function(D)
				if D.Name == "SettingsClippingShield" and D.Parent == RobloxGui then
					HookShield(D)
				elseif Shield and D:IsDescendantOf(Shield) then
					HookObject(D)
					if D:IsA("GuiObject") and D.Visible then NativeMenuOpened() end
				end
			end)
		end

		local TopBarApp = CoreGui:FindFirstChild("TopBarApp")
		TopBarApp = TopBarApp and TopBarApp:FindFirstChild("TopBarApp")
		local Holder = TopBarApp and TopBarApp:FindFirstChild("MenuIconHolder")
		local Hit = Holder and Holder:FindFirstChild("TriggerPoint") and Holder.TriggerPoint:FindFirstChild("IconHitArea")
		if Hit and Hit:IsA("GuiButton") then
			Connect(Hit.MouseButton1Click, function()
				Hub.NativeTarget = not Hub.Visible
				Spawn(function()
					Wait()
					SetVisible(Hub.NativeTarget or false)
					Hub.NativeTarget = nil
				end)
			end)
		end
	end

	Connect(CloseBtn.MouseButton1Click, function() SetVisible(false) end)
	Connect(Overlay.MouseButton1Click, function() SetVisible(false) end)

	local LastEsc = 0
	local function EscapeAction(_, State)
		if State ~= Enum.UserInputState.Begin then return Enum.ContextActionResult.Sink end
		local Now = tick()
		if (Now - LastEsc) < 0.15 then return Enum.ContextActionResult.Sink end
		LastEsc = Now
		HideNative()
		if Hub.Visible then
			Hub.SuppressUntil = Now + 0.8
		end
		SetVisible(not Hub.Visible)
		Spawn(function() Wait(); HideNative() end)
		return Enum.ContextActionResult.Sink
	end

	local Ok = pcall(function()
		ContextActionService:BindCoreActionAtPriority("RbxHubEscapeMenu", EscapeAction, false, 10000, Enum.KeyCode.Escape, Enum.KeyCode.ButtonStart)
	end)
	if not Ok then
		pcall(function()
			ContextActionService:BindCoreAction("RbxHubEscapeMenu", EscapeAction, false, Enum.KeyCode.Escape, Enum.KeyCode.ButtonStart)
		end)
	end

	Spawn(LoadLucide)

	local HubApi = {}

	function HubApi:AddPage(InternalName, IconName, DisplayName)
		local Page = {
			Name = InternalName,
			Frame = CreatePageFrame(InternalName),
			LayoutOrder = #Hub.Pages + 1,
		}
		Insert(Hub.Pages, Page)
		MakeTabButton(Page, DisplayName or InternalName, IconName)
		if #Hub.Pages == 1 then SwitchToPage(Page, true, true) end

		local PageApi = {}

		function PageApi:AddSection(Title, Icon)
			return AddSection(Page.Frame, Title, Icon)
		end
		function PageApi:AddSelector(Label, Values, Default, Cb, Icon)
			return AddSelector(Page.Frame, Label, Values, Default, Cb, Icon)
		end
		function PageApi:AddSlider(Label, Steps, Default, Cb, Min, Icon)
			return AddSlider(Page.Frame, Label, Steps, Default, Cb, Min, Icon)
		end
		function PageApi:AddDropdown(Label, Values, Default, Cb, Icon)
			return AddDropdown(Page.Frame, Label, Values, Default, Cb, Icon)
		end
		function PageApi:AddButton(Label, BtnText, Cb, Icon)
			return AddButton(Page.Frame, Label, BtnText, Cb, Icon)
		end
		function PageApi:AddValue(Label, Value, Icon)
			return AddValue(Page.Frame, Label, Value, Icon)
		end
		function PageApi:AddRaw(Height)
			return AddRawRow(Page.Frame, Height)
		end
		function PageApi:GetFrame()
			return Page.Frame
		end
		function PageApi:SwitchTo(NoAnim)
			SwitchToPage(Page, false, NoAnim)
		end
		function PageApi:PushTo()
			Insert(Hub.MenuStack, Hub.CurrentPage)
			HubBar.Visible = false
			BottomBar.Visible = false
			SwitchToPage(Page, true, true)
		end
		function PageApi:PopBack()
			HubBar.Visible = true
			BottomBar.Visible = true
			local Prev = Hub.MenuStack[#Hub.MenuStack]
			if Prev then
				table.remove(Hub.MenuStack, #Hub.MenuStack)
				SwitchToPage(Prev, true, true)
			end
		end

		return PageApi, Page
	end

	function HubApi:AddBottomButton(Label, IconName, Cb, Order)
		return AddBottomButton(Label, IconName, Cb, Order)
	end

	function HubApi:ShowAlert(Message, OkText, Cleanup)
		ShowAlert(Message, OkText, Cleanup)
	end

	function HubApi:SetVisible(Visible, NoAnim, CustomPage)
		SetVisible(Visible, NoAnim, CustomPage)
	end

	function HubApi:Toggle()
		SetVisible(not Hub.Visible)
	end

	function HubApi:IsVisible()
		return Hub.Visible
	end

	function HubApi:HookNative()
		Spawn(HookNative)
	end

	function HubApi:CloseAndDo(Callback, Delay)
		SetVisible(false)
		Spawn(function()
			Wait(Delay or 0.35)
			if Callback then Callback() end
		end)
	end

	function HubApi:GetHub()
		return Hub
	end

	function HubApi:GetHubBar()
		return HubBar
	end

	function HubApi:GetBottomBar()
		return BottomBar
	end

	function HubApi:GetPageView()
		return PageView
	end

	function HubApi:GetTheme()
		return Theme
	end

	function HubApi:GetNew()
		return New
	end

	function HubApi:GetConnect()
		return Connect
	end

	function HubApi:ApplyIcon(Label, IconName, Color)
		ApplyIcon(Label, IconName, Color)
	end

	return HubApi
end

return Lib
