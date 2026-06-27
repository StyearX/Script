local CoreUi = {}
CoreUi.Options = {}
CoreUi.Connections = {}
CoreUi.Version = "3.0"

local cloneref = (cloneref or clonereference or function(i) return i end)
local RunServiceI = cloneref(game:GetService("RunService"))
local HttpServiceI = cloneref(game:GetService("HttpService"))

local function Get(url)
	if game.HttpGet then return game:HttpGet(url) else return HttpServiceI:GetAsync(url) end
end

local IconModule = { IconsType = "lucide", Icons = {} }
do
	local packs = {
		lucide = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/lucide/dist/Icons.lua",
		solar = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/solar/dist/Icons.lua",
		craft = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/craft/dist/Icons.lua",
		geist = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/geist/dist/Icons.lua",
		sfsymbols = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/sfsymbols/dist/Icons.lua",
		gravity = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/gravity/dist/Icons.lua",
		googlematerial = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/GoogleMaterialIcons/dist/Icons.lua",
		hero = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/hero/dist/Icons.lua",
	}
	for name, url in next, packs do
		local ok, result = pcall(function() return loadstring(Get(url))() end)
		if ok and type(result) == "table" then IconModule.Icons[name] = result end
	end
end

local function ParseIconString(s)
	if type(s) ~= "string" then return nil, s end
	local c = s:find(":")
	if c then return s:sub(1, c - 1), s:sub(c + 1) end
	local sl = s:find("/")
	if sl then return s:sub(1, sl - 1), s:sub(sl + 1) end
	return nil, s
end

function IconModule.SetIconsType(t) IconModule.IconsType = t end
function IconModule.AddIcons(packName, iconsData)
	if type(packName) ~= "string" or type(iconsData) ~= "table" then return end
	if not IconModule.Icons[packName] then IconModule.Icons[packName] = { Icons = {}, Spritesheets = {} } end
	for iconName, iconValue in pairs(iconsData) do
		if type(iconValue) == "number" or (type(iconValue) == "string" and iconValue:match("^rbxassetid://")) then
			local id = type(iconValue) == "number" and ("rbxassetid://" .. tostring(iconValue)) or iconValue
			IconModule.Icons[packName].Icons[iconName] = { Image = id, ImageRectSize = Vector2.new(0, 0), ImageRectPosition = Vector2.new(0, 0) }
		elseif type(iconValue) == "table" and iconValue.Image then
			local id = type(iconValue.Image) == "number" and ("rbxassetid://" .. tostring(iconValue.Image)) or iconValue.Image
			IconModule.Icons[packName].Icons[iconName] = {
				Image = id,
				ImageRectSize = iconValue.ImageRectSize or Vector2.new(0, 0),
				ImageRectPosition = iconValue.ImageRectPosition or Vector2.new(0, 0),
				Parts = iconValue.Parts,
			}
		end
	end
end

local function ResolveIconAsset(icon)
	if type(icon) ~= "string" then return nil end
	if icon:find("^rbxassetid://") or icon:find("^rbxthumb://") or icon:find("^http") then return icon end
	local iconType, iconName = ParseIconString(icon)
	local targetType = iconType or IconModule.IconsType
	local iconSet = IconModule.Icons[targetType]
	if not iconSet then return nil end
	if iconSet.Icons and iconSet.Icons[iconName] then
		return iconSet.Icons[iconName].Image, iconSet.Icons[iconName]
	elseif iconSet[iconName] then
		local v = iconSet[iconName]
		if type(v) == "number" then return "rbxassetid://" .. tostring(v) end
		if type(v) == "string" then return v end
	end
	return nil
end
CoreUi.IconModule = IconModule

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")

local Shield do
	local clip = RobloxGui:FindFirstChild("SettingsClippingShield")
	Shield = clip and clip:WaitForChild("SettingsShield") or RobloxGui:FindFirstChild("SettingsShield") or RobloxGui:WaitForChild("SettingsClippingShield"):WaitForChild("SettingsShield")
end
local MenuContainer = Shield:WaitForChild("MenuContainer")
local Page = MenuContainer:FindFirstChild("Page") or MenuContainer:WaitForChild("Page")
local HubBar = Page:WaitForChild("HubBar")
local TabContainer do
	local thc = HubBar:FindFirstChild("TabHeaderContainer")
	if thc then TabContainer = thc:FindFirstChild("HubBarContainer") or thc else TabContainer = HubBar:FindFirstChild("HubBarContainer") or HubBar end
end
local TabScroller do
	local s = TabContainer:FindFirstChild("TabScroller")
	if not s then
		s = Instance.new("ScrollingFrame")
		s.Name = "TabScroller"
		s.Size = UDim2.new(1, 0, 1, 0)
		s.BackgroundTransparency = 1
		s.ScrollBarThickness = 0
		s.ScrollingDirection = Enum.ScrollingDirection.X
		s.AutomaticCanvasSize = Enum.AutomaticSize.X
		s.CanvasSize = UDim2.new(0, 0, 0, 0)
		s.ClipsDescendants = true
		s.BorderSizePixel = 0
		s.ZIndex = 2
		s.Parent = TabContainer
		local lay = Instance.new("UIListLayout")
		lay.FillDirection = Enum.FillDirection.Horizontal
		lay.HorizontalAlignment = Enum.HorizontalAlignment.Left
		lay.VerticalAlignment = Enum.VerticalAlignment.Center
		lay.Padding = UDim.new(0, 4)
		lay.SortOrder = Enum.SortOrder.LayoutOrder
		lay.Parent = s
		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 8)
		pad.PaddingRight = UDim.new(0, 8)
		pad.Parent = s
	end
	TabScroller = s
end
for _, child in next, TabContainer:GetChildren() do if child:IsA("TextButton") and child ~= TabScroller then child.Parent = TabScroller end end
local oldLayout = TabContainer:FindFirstChildOfClass("UIListLayout")
if oldLayout then oldLayout:Destroy() end
local PageViewClipper = Page:WaitForChild("PageViewClipper")
local PageScroll = PageViewClipper:WaitForChild("PageView")
local PageInner = PageScroll:FindFirstChild("PageViewInnerFrame") or PageScroll:WaitForChild("PageViewInnerFrame")
local OverlayRoot = Shield

local NativeTabs = {}
local NativePages = {}
local NativeScrollbars = {}
local CustomTabPages = {}
local CustomTabButtons = {}
local CustomTabOrder = 0
local CurrentActiveTabType = "native"
local CurrentActiveTabName = nil
local TAB_INACTIVE_TRANS = 0.7
local TAB_ACTIVE_TRANS = 0
local ActiveOverlay = nil

local function AddConn(c) table.insert(CoreUi.Connections, c); return c end
local function SafeCall(f, ...) if type(f) ~= "function" then return end local ok, err = pcall(f, ...) if not ok then warn("[CoreUi] " .. tostring(err)) end end
local function New(cls, props, children) local obj = Instance.new(cls) for k, v in next, props or {} do if k ~= "Parent" then pcall(function() obj[k] = v end) end end for _, c in next, children or {} do if c then c.Parent = obj end end if props and props.Parent then obj.Parent = props.Parent end return obj end
local function Tween(inst, t, goals, style, dir) TweenService:Create(inst, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), goals):Play() end
local function HubCorner(r) return New("UICorner", { CornerRadius = UDim.new(0, r or 8) }) end
local function HubStroke(col, trans, thick) return New("UIStroke", { Color = col or Color3.fromRGB(255,255,255), Transparency = trans or 0.84, Thickness = thick or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }) end
local function CloseActiveOverlay() if ActiveOverlay then pcall(function() ActiveOverlay:Destroy() end); ActiveOverlay = nil end end
local function OpenOverlay(buildFn) CloseActiveOverlay(); local dimmer = New("ImageButton", { Name = "CoreUiOverlayDimmer", Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), BackgroundTransparency = 1, ZIndex = 20, Image = "", Parent = OverlayRoot }); dimmer.MouseButton1Click:Connect(CloseActiveOverlay); buildFn(dimmer); ActiveOverlay = dimmer; return dimmer end
local function RefreshNativePagesList()
	NativePages = {}; NativeScrollbars = {}
	for _, child in next, PageInner:GetChildren() do
		if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
			local n = child.Name
			if not n:find("^CoreUi_") then
				table.insert(NativePages, child)
				local sc = child:FindFirstChildOfClass("ScrollingFrame") or child:FindFirstChild("CoreUiScroll")
				if sc and sc:IsA("ScrollingFrame") then NativeScrollbars[child] = { scroll = sc, thickness = sc.ScrollBarThickness } end
			end
		end
	end
end
local function ShowNativePages()
	for _, page in next, NativePages do pcall(function() page.Visible = true end) end
	for _, data in next, NativeScrollbars do if data.scroll then data.scroll.ScrollBarThickness = data.thickness end end
end
local function HideNativePages()
	for _, page in next, NativePages do pcall(function() page.Visible = false end) end
	for _, data in next, NativeScrollbars do if data.scroll then data.scroll.ScrollBarThickness = 0 end end
end
local SetTabAppearance
local function ActivateCustomTab(name)
	CurrentActiveTabType = "custom"; CurrentActiveTabName = name
	HideNativePages()
	for n, pg in next, CustomTabPages do pg.Visible = (n == name); pg.Position = (n == name) and UDim2.new(0,0,0,0) or UDim2.new(2,0,0,0) end
	for n, btn in next, CustomTabButtons do SetTabAppearance(btn, n == name) end
	for _, nt in next, NativeTabs do
		local sel = nt:FindFirstChild("TabSelection"); if sel then sel.Visible = false end
		local tl = nt:FindFirstChild("TabLabel")
		if tl then
			local ti = tl:FindFirstChild("Title"); if ti then Tween(ti, 0.15, { TextTransparency = TAB_INACTIVE_TRANS }) end
			local ic = tl:FindFirstChild("Icon")
			if ic then
				if ic:IsA("ImageLabel") then Tween(ic, 0.15, { ImageTransparency = TAB_INACTIVE_TRANS })
				elseif ic:IsA("TextLabel") then Tween(ic, 0.15, { TextTransparency = TAB_INACTIVE_TRANS }) end
			end
		end
	end
end
local function ActivateNativeTab(activeNative)
	CurrentActiveTabType = "native"; CurrentActiveTabName = nil
	ShowNativePages()
	for _, pg in next, CustomTabPages do pg.Visible = false; pg.Position = UDim2.new(2,0,0,0) end
	for _, btn in next, CustomTabButtons do SetTabAppearance(btn, false) end
	for _, nt in next, NativeTabs do
		local isActive = nt == activeNative
		local sel = nt:FindFirstChild("TabSelection"); if sel then sel.Visible = isActive end
		local tl = nt:FindFirstChild("TabLabel")
		if tl then
			local ti = tl:FindFirstChild("Title"); if ti then Tween(ti, 0.15, { TextTransparency = isActive and TAB_ACTIVE_TRANS or TAB_INACTIVE_TRANS }) end
			local ic = tl:FindFirstChild("Icon")
			if ic then
				if ic:IsA("ImageLabel") then Tween(ic, 0.15, { ImageTransparency = isActive and TAB_ACTIVE_TRANS or TAB_INACTIVE_TRANS })
				elseif ic:IsA("TextLabel") then Tween(ic, 0.15, { TextTransparency = isActive and TAB_ACTIVE_TRANS or TAB_INACTIVE_TRANS }) end
			end
		end
	end
end
AddConn(MenuContainer:GetPropertyChangedSignal("Visible"):Connect(function()
	if MenuContainer.Visible then
		if CurrentActiveTabType == "custom" and CurrentActiveTabName then task.defer(function() ActivateCustomTab(CurrentActiveTabName) end) end
	else
		for _, pg in next, CustomTabPages do pcall(function() pg.Visible = false end) end
	end
end))
AddConn(TabScroller.ChildAdded:Connect(function(c)
	if c:IsA("TextButton") and not CustomTabButtons[c.Name] then
		table.insert(NativeTabs, c); c.LayoutOrder = #NativeTabs
		AddConn(c.MouseButton1Click:Connect(function() ActivateNativeTab(c) end))
	end
end))
for _, child in next, TabScroller:GetChildren() do
	if child:IsA("TextButton") then
		table.insert(NativeTabs, child); child.LayoutOrder = #NativeTabs
		AddConn(child.MouseButton1Click:Connect(function() ActivateNativeTab(child) end))
	end
end
SetTabAppearance = function(btn, active)
	local trans = active and TAB_ACTIVE_TRANS or TAB_INACTIVE_TRANS
	local tl = btn:FindFirstChild("TabLabel")
	if tl then
		local ti = tl:FindFirstChild("Title"); if ti then Tween(ti, 0.15, { TextTransparency = trans }) end
		local ic = tl:FindFirstChild("Icon")
		if ic then
			if ic:IsA("ImageLabel") then Tween(ic, 0.15, { ImageTransparency = trans })
			elseif ic:IsA("TextLabel") then Tween(ic, 0.15, { TextTransparency = trans }) end
		end
	end
	local sel = btn:FindFirstChild("TabSelection"); if sel then sel.Visible = active end
end
AddConn(PageInner.ChildAdded:Connect(function(child)
	if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
		local n = child.Name
		if not n:find("^CoreUi_") then
			table.insert(NativePages, child)
			local sc = child:FindFirstChildOfClass("ScrollingFrame") or child:FindFirstChild("CoreUiScroll")
			if sc and sc:IsA("ScrollingFrame") then NativeScrollbars[child] = { scroll = sc, thickness = sc.ScrollBarThickness } end
			if CurrentActiveTabType == "custom" then
				pcall(function() child.Visible = false end)
				local data = NativeScrollbars[child]; if data and data.scroll then data.scroll.ScrollBarThickness = 0 end
			end
		end
	end
end))
task.defer(function() RefreshNativePagesList(); if #NativeTabs > 0 then ActivateNativeTab(NativeTabs[1]) end end)

local function RebuildTabSizes()
	for _, nt in next, NativeTabs do nt.Size = UDim2.new(0, 120, 1, 0); nt.AutomaticSize = Enum.AutomaticSize.None end
	for _, btn in next, CustomTabButtons do btn.Size = UDim2.new(0, 120, 1, 0); btn.AutomaticSize = Enum.AutomaticSize.None end
end

local function BuildTabButton(name, title, icon)
	local existing = TabScroller:FindFirstChild(name); if existing then existing:Destroy() end
	CustomTabOrder = CustomTabOrder + 1
	local iconAsset, iconData = ResolveIconAsset(icon)
	local iconEl
	if iconAsset then
		if iconAsset:find("^rbxassetid://") or iconAsset:find("^rbxthumb://") then
			iconEl = New("ImageLabel", { Name = "Icon", Size = UDim2.fromOffset(24, 24), BackgroundTransparency = 1, Image = iconAsset, ImageColor3 = Color3.fromRGB(255,255,255), ImageTransparency = TAB_INACTIVE_TRANS, ZIndex = 3, LayoutOrder = 1 }, { New("UIAspectRatioConstraint", {}) })
		else
			iconEl = New("TextLabel", { Name = "Icon", Size = UDim2.fromOffset(24, 24), BackgroundTransparency = 1, Text = iconAsset, Font = Enum.Font.Unknown, TextSize = 8, TextScaled = true, TextWrapped = true, TextColor3 = Color3.fromRGB(255,255,255), TextTransparency = TAB_INACTIVE_TRANS, ZIndex = 3, LayoutOrder = 1 }, { New("UIAspectRatioConstraint", {}) })
		end
	end
	local btn = New("TextButton", { Name = name, Size = UDim2.new(0, 120, 1, 0), BackgroundTransparency = 1, Text = "", Font = Enum.Font.Legacy, TextSize = 8, BorderSizePixel = 0, ZIndex = 3, LayoutOrder = 1000 + CustomTabOrder, Selectable = false, Parent = TabScroller }, {
		New("ImageLabel", { Name = "TabSelection", Size = UDim2.new(1, -2, 0, 2), Position = UDim2.new(0, 3, 1, -2), BackgroundColor3 = Color3.fromRGB(255,255,255), BackgroundTransparency = 0, BorderSizePixel = 0, ZIndex = 4, Image = "", Visible = false }),
		New("Frame", { Name = "TabLabel", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, ZIndex = 3 }, {
			New("UIListLayout", { Name = "Layout", FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, iconEl and 8 or 0), SortOrder = Enum.SortOrder.LayoutOrder }),
			iconEl,
			New("TextLabel", { Name = "Title", AutomaticSize = Enum.AutomaticSize.XY, BackgroundTransparency = 1, Text = title, Font = Enum.Font.BuilderSansMedium, TextSize = 17, TextColor3 = Color3.fromRGB(255,255,255), TextTransparency = TAB_INACTIVE_TRANS, ZIndex = 3, LayoutOrder = 2 }),
		}),
	})
	CustomTabButtons[name] = btn
	btn.MouseButton1Click:Connect(function() ActivateCustomTab(name) end)
	SetTabAppearance(btn, false)
	RebuildTabSizes()
	return btn
end

local function BuildCustomPage(name)
	local ex = PageInner:FindFirstChild("CoreUi_" .. name); if ex then ex:Destroy() end
	local pageFrame = New("Frame", { Name = "CoreUi_" .. name, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.new(2,0,0,0), BackgroundTransparency = 1, ZIndex = 5, Parent = PageInner }, {
		New("UIListLayout", { Name = "RowListLayout", SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Vertical, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Top, Padding = UDim.new(0, 0) }),
		New("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 11), PaddingBottom = UDim.new(0, 20) }),
	})
	CustomTabPages[name] = pageFrame
	return pageFrame, pageFrame
end

local function FadeText(label, transparency)
	task.spawn(function()
		local start = label.TextTransparency
		for i = 1, 6 do
			if not label.Parent then return end
			label.TextTransparency = start + ((transparency - start) * (i / 6))
			task.wait()
		end
	end)
end

local function MakeStyledButton(name, text, size, clicked)
	local button = New("ImageButton", {
		Name = name,
		Image = "rbxasset://textures/ui/Settings/MenuBarAssets/MenuButton.png",
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(8,6,46,44),
		ImageColor3 = Color3.fromRGB(10,10,10),
		ImageTransparency = 0.35,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = size,
		ZIndex = 6,
	})
	local label = New("TextLabel", {
		Name = name.."TextLabel",
		Parent = button,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1,0,1,-8),
		Position = UDim2.new(0,0,0,0),
		Font = Enum.Font.SourceSansBold,
		TextSize = 24,
		TextColor3 = Color3.new(1,1,1),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Text = text,
		TextWrapped = true,
		ZIndex = 7,
	})
	AddConn(button.MouseEnter:Connect(function()
		button.Image = "rbxasset://textures/ui/Settings/MenuBarAssets/MenuButtonSelected.png"
		button.ImageColor3 = Color3.fromRGB(10,10,10)
		button.ImageTransparency = 0.2
	end))
	AddConn(button.MouseLeave:Connect(function()
		button.Image = "rbxasset://textures/ui/Settings/MenuBarAssets/MenuButton.png"
		button.ImageColor3 = Color3.fromRGB(10,10,10)
		button.ImageTransparency = 0.35
	end))
	if clicked then AddConn(button.MouseButton1Click:Connect(clicked)) end
	return button, label
end

local function MakeRow(page, name, height)
	local row = New("ImageButton", {
		Name = name.."Row",
		Parent = page._page,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = "",
		Active = false,
		AutoButtonColor = false,
		Selectable = false,
		Size = UDim2.new(1,0,0,height or 50),
		ZIndex = 5,
	})
	New("TextLabel", {
		Name = name.."Label",
		Parent = row,
		BackgroundTransparency = 1,
		Font = Enum.Font.SourceSansBold,
		TextSize = 24,
		TextColor3 = Color3.new(1,1,1),
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = name,
		Size = UDim2.new(0,200,1,0),
		Position = UDim2.new(0,10,0,0),
		ZIndex = 6,
	})
	return row
end

local function MakeSelector(page, name, values, index, changed)
	local currentIndex = index or 1
	local row = MakeRow(page, name)
	local selectorFrame = New("ImageButton", {
		Parent = row,
		BackgroundTransparency = 1,
		Image = "",
		AutoButtonColor = false,
		Size = UDim2.new(0,502,0,50),
		Position = UDim2.new(1,-502,0.5,-25),
		ZIndex = 6,
	})
	local left = New("ImageButton", {
		Parent = selectorFrame,
		BackgroundTransparency = 1,
		Image = "",
		Size = UDim2.new(0,60,0,50),
		Position = UDim2.new(0,-10,0.5,-25),
		ZIndex = 7,
	})
	New("ImageLabel", {
		Parent = left,
		BackgroundTransparency = 1,
		Image = "rbxasset://textures/ui/Settings/Slider/Left.png",
		Size = UDim2.new(0,18,0,30),
		Position = UDim2.new(1,-24,0.5,-15),
		ZIndex = 8,
	})
	local right = New("ImageButton", {
		Parent = selectorFrame,
		BackgroundTransparency = 1,
		Image = "",
		Size = UDim2.new(0,50,0,50),
		Position = UDim2.new(1,-50,0.5,-25),
		ZIndex = 7,
	})
	New("ImageLabel", {
		Parent = right,
		BackgroundTransparency = 1,
		Image = "rbxasset://textures/ui/Settings/Slider/Right.png",
		Size = UDim2.new(0,18,0,30),
		Position = UDim2.new(0,6,0.5,-15),
		ZIndex = 8,
	})
	local label = New("TextLabel", {
		Parent = selectorFrame,
		Name = "Selection",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1,-120,1,0),
		Position = UDim2.new(0,60,0,0),
		TextColor3 = Color3.new(1,1,1),
		TextTransparency = 0.2,
		TextYAlignment = Enum.TextYAlignment.Center,
		Font = Enum.Font.SourceSans,
		TextSize = 24,
		Text = values[currentIndex],
		ZIndex = 7,
	})
	local api = { CurrentIndex = currentIndex, Interactable = true, SelectorFrame = selectorFrame, TextLabel = label }
	local function setText(text, dir)
		label.Text = text
		label.Position = UDim2.new(0,60+((dir or 0)*16),0,0)
		label.TextTransparency = 0.75
		Tween(label, 0.15, { Position = UDim2.new(0,60,0,0) })
		FadeText(label, 0.2)
	end
	local function apply(delta)
		if not api.Interactable then return end
		currentIndex = currentIndex + delta
		if currentIndex > #values then currentIndex = 1 elseif currentIndex < 1 then currentIndex = #values end
		api.CurrentIndex = currentIndex
		setText(values[currentIndex], delta)
		if changed then changed(currentIndex, values[currentIndex]) end
	end
	AddConn(left.MouseButton1Click:Connect(function() apply(-1) end))
	AddConn(right.MouseButton1Click:Connect(function() apply(1) end))
	AddConn(selectorFrame.MouseButton1Click:Connect(function() apply(1) end))
	function api:SetSelectionIndex(newIndex, fireChanged)
		if not newIndex or #values == 0 then return end
		currentIndex = math.clamp(newIndex, 1, #values)
		api.CurrentIndex = currentIndex
		setText(values[currentIndex], 0)
		if changed and fireChanged then changed(currentIndex, values[currentIndex]) end
	end
	function api:SetInteractable(interactable)
		api.Interactable = interactable
		selectorFrame.ImageTransparency = interactable and 0 or 0.65
		label.TextTransparency = interactable and 0.2 or 0.65
		left.Visible = interactable
		right.Visible = interactable
	end
	function api:GetSelectedIndex() return currentIndex end
	function api:GetSelectedValue() return values[currentIndex] end
	return api
end

local function MakeSlider(page, name, steps, index, changed, minStep)
	minStep = minStep or 0
	local currentIndex = math.clamp(index or 1, minStep, steps)
	local row = MakeRow(page, name)
	local holder = New("Frame", {
		Parent = row,
		BackgroundTransparency = 1,
		Size = UDim2.new(0,502,0,50),
		Position = UDim2.new(1,-502,0.5,-25),
		Active = true,
		ZIndex = 6,
	})
	local left = New("ImageButton", {
		Parent = holder,
		BackgroundTransparency = 1,
		Image = "",
		Size = UDim2.new(0,60,0,50),
		Position = UDim2.new(0,-10,0.5,-25),
		ZIndex = 7,
	})
	New("ImageLabel", {
		Parent = left,
		BackgroundTransparency = 1,
		Image = "rbxasset://textures/ui/Settings/Slider/Left.png",
		Size = UDim2.new(0,18,0,30),
		Position = UDim2.new(1,-24,0.5,-15),
		ZIndex = 8,
	})
	local right = New("ImageButton", {
		Parent = holder,
		BackgroundTransparency = 1,
		Image = "",
		Size = UDim2.new(0,50,0,50),
		Position = UDim2.new(1,-50,0.5,-25),
		ZIndex = 7,
	})
	New("ImageLabel", {
		Parent = right,
		BackgroundTransparency = 1,
		Image = "rbxasset://textures/ui/Settings/Slider/Right.png",
		Size = UDim2.new(0,18,0,30),
		Position = UDim2.new(0,6,0.5,-15),
		ZIndex = 8,
	})
	local segments = {}
	local dragging = false
	local sliderApi = { Interactable = true }

	local function refresh(immediate)
		for i, seg in next, segments do
			local selected = sliderApi.Interactable and i <= currentIndex
			local color = selected and Color3.new(1,1,1) or Color3.fromRGB(80,80,80)
			if i == 1 or i == steps then
				seg.Image = selected and ((i == 1 and "rbxasset://textures/ui/Settings/Slider/SelectedBarLeft.png") or "rbxasset://textures/ui/Settings/Slider/SelectedBarRight.png") or ((i == 1 and "rbxasset://textures/ui/Settings/Slider/BarLeft.png") or "rbxasset://textures/ui/Settings/Slider/BarRight.png")
				seg.ImageTransparency = 0.36
				seg.BackgroundTransparency = 1
			else
				if immediate then seg.BackgroundColor3 = color else Tween(seg, 0.1, { BackgroundColor3 = color }) end
			end
		end
		left.Visible = sliderApi.Interactable and currentIndex > minStep
		right.Visible = sliderApi.Interactable and currentIndex < steps
	end

	local function setSliderValue(newIndex)
		newIndex = math.clamp(newIndex, minStep, steps)
		if currentIndex == newIndex then return end
		currentIndex = newIndex
		refresh()
		if changed then changed(currentIndex) end
	end

	local function setSliderFromX(x)
		if not sliderApi.Interactable then return end
		local first = segments[1]
		local last = segments[steps]
		if not first or not last then return end
		local startX = first.AbsolutePosition.X
		local endX = last.AbsolutePosition.X + last.AbsoluteSize.X
		local alpha = math.clamp((x - startX) / (endX - startX), 0, 1)
		if minStep > 0 then
			setSliderValue(math.clamp(math.floor((alpha * steps) + 1), minStep, steps))
		else
			setSliderValue(math.clamp(math.floor(alpha * (steps + 1)), 0, steps))
		end
	end

	for i = 1, steps do
		local seg = New("ImageButton", {
			Parent = holder,
			BackgroundColor3 = Color3.fromRGB(15,15,15),
			BackgroundTransparency = 0.36,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Image = "",
			ImageTransparency = 0.36,
			Size = UDim2.new(0,35,0,25),
			Position = UDim2.new(0,60+((i-1)*39),0.5,-12),
			ZIndex = 7,
		})
		if i == 1 or i == steps then
			seg.BackgroundTransparency = 1
			seg.ScaleType = Enum.ScaleType.Slice
			seg.SliceCenter = Rect.new(3,3,32,21)
		end
		segments[i] = seg
		AddConn(seg.MouseButton1Click:Connect(function() if sliderApi.Interactable then setSliderValue(i) end end))
	end

	local capture = New("TextButton", {
		Parent = holder,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Active = true,
		Size = UDim2.new(0,400,1,0),
		Position = UDim2.new(0,52,0,0),
		ZIndex = 9,
	})
	AddConn(capture.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setSliderFromX(input.Position.X)
		end
	end))
	AddConn(capture.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setSliderFromX(input.Position.X)
		end
	end))
	AddConn(UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setSliderFromX(input.Position.X)
		end
	end))
	AddConn(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))
	AddConn(left.MouseButton1Click:Connect(function() if sliderApi.Interactable then setSliderValue(currentIndex - 1) end end))
	AddConn(right.MouseButton1Click:Connect(function() if sliderApi.Interactable then setSliderValue(currentIndex + 1) end end))
	refresh(true)

	function sliderApi:SetValue(value)
		currentIndex = math.clamp(value, minStep, steps)
		refresh(true)
	end
	function sliderApi:GetValue() return currentIndex end
	function sliderApi:SetInteractable(interactable)
		sliderApi.Interactable = interactable
		holder.Active = interactable
		holder.ZIndex = interactable and 6 or 5
		for _, seg in next, segments do
			seg.Active = interactable; seg.Selectable = interactable; seg.ZIndex = interactable and 7 or 5
		end
		refresh(true)
	end
	return sliderApi
end

local function MakeDropDown(page, name, values, index, changed)
	local currentIndex = index
	local row = MakeRow(page, name)
	local btn, lbl = MakeStyledButton(name.."DropDown", values[currentIndex] or "Choose One", UDim2.new(0,300,0,44))
	btn.Parent = row
	btn.Position = UDim2.new(1,-350,0.5,-22)
	local arrow = New("ImageLabel", {
		Parent = btn,
		BackgroundTransparency = 1,
		Image = "rbxasset://textures/ui/Settings/DropDown/DropDown.png",
		Size = UDim2.new(0,15,0,10),
		Position = UDim2.new(1,-40,0.5,-7),
		ZIndex = 8,
	})
	local api = { CurrentIndex = currentIndex, Interactable = true, DropDownFrame = btn }
	local overlay = New("TextButton", {
		Parent = OverlayRoot,
		Name = name.."DropDownFullscreenFrame",
		Visible = false,
		BackgroundColor3 = Color3.new(0,0,0),
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Text = "",
		Size = UDim2.new(1,0,1,0),
		ZIndex = 20,
	})
	local panel = New("ImageLabel", {
		Parent = overlay,
		Image = "rbxasset://textures/ui/Settings/MenuBarAssets/MenuButton.png",
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(8,6,46,44),
		BackgroundTransparency = 1,
		ImageColor3 = Color3.fromRGB(20,20,20),
		ImageTransparency = 0.2,
		Size = UDim2.new(0,400,0.9,0),
		Position = UDim2.new(0.5,-200,0.05,0),
		ZIndex = 21,
	})
	local list = New("ScrollingFrame", {
		Parent = panel,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1,-20,1,-25),
		Position = UDim2.new(0,10,0,10),
		CanvasSize = UDim2.new(0,0,0,#values*51),
		ScrollBarThickness = 6,
		ZIndex = 21,
	})
	local function rebuild(newValues)
		values = newValues or values
		if currentIndex and currentIndex > #values then currentIndex = nil; api.CurrentIndex = nil end
		for _, child in next, list:GetChildren() do if child:IsA("TextButton") then child:Destroy() end end
		for i, val in next, values do
			local opt = New("TextButton", {
				Parent = list,
				Name = "Selection"..tostring(i),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Size = UDim2.new(1,-28,0,50),
				Position = UDim2.new(0,14,0,(i-1)*51),
				TextColor3 = (i == currentIndex and Color3.new(1,1,1)) or Color3.new(0.7,0.7,0.7),
				Font = Enum.Font.SourceSans,
				TextSize = 24,
				Text = val,
				ZIndex = 22,
			})
			AddConn(opt.MouseButton1Click:Connect(function()
				api:SetSelectionIndex(i, true)
				overlay.Visible = false
			end))
		end
		list.CanvasSize = UDim2.new(0,0,0,#values*51)
		if currentIndex then
			lbl.Text = values[currentIndex] or "Choose One"
		else
			lbl.Text = "Choose One"
		end
	end
	AddConn(btn.MouseButton1Click:Connect(function()
		if api.Interactable then overlay.Visible = true end
	end))
	AddConn(overlay.MouseButton1Click:Connect(function() overlay.Visible = false end))
	rebuild(values)
	function api:UpdateDropDownList(newValues) rebuild(newValues) end
	function api:SetSelectionIndex(newIndex, fireChanged)
		if not newIndex or newIndex < 1 or newIndex > #values then
			currentIndex = nil; api.CurrentIndex = nil
			lbl.Text = "Choose One"
			if changed and fireChanged then changed(nil, nil) end
			rebuild(values)
			return false
		end
		currentIndex = newIndex
		api.CurrentIndex = currentIndex
		lbl.Text = values[currentIndex]
		if changed and fireChanged then changed(currentIndex, values[currentIndex]) end
		rebuild(values)
		return true
	end
	function api:GetSelectedIndex() return currentIndex end
	function api:GetSelectedValue() return currentIndex and values[currentIndex] or nil end
	function api:SetInteractable(interactable)
		api.Interactable = interactable
		btn.ImageTransparency = interactable and 0 or 0.65
		btn.Active = interactable
		btn.Selectable = interactable
		if lbl then lbl.TextTransparency = interactable and 0 or 0.65 end
		if arrow then arrow.ImageTransparency = interactable and 0 or 0.65 end
	end
	return api
end

function CoreUi:Tab(section, config)
	config = config or {}
	local title = config.Title or section
	local icon = config.Icon
	BuildTabButton(section, title, icon)
	local pageFrame, scroll = BuildCustomPage(section)
	local tab = { _scroll = scroll, _page = pageFrame, _section = section, IsCustom = true }
	local isFirst = true
	for n in next, CustomTabPages do if n ~= section then isFirst = false; break end end
	if isFirst then ActivateCustomTab(section) end

	function tab:AddSection(config)
		config = config or {}
		local title = config.Title or "Section"
		local icon = config.Icon
		local desc = config.Description or ""
		local row = New("ImageButton", {
			Name = title.."Section",
			Parent = self._page,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = "",
			Active = false,
			AutoButtonColor = false,
			Selectable = false,
			Size = UDim2.new(1,0,0,desc ~= "" and 64 or 48),
			ZIndex = 5,
		})
		local iconAsset, iconData = ResolveIconAsset(icon)
		if iconAsset then
			local iconEl = New("ImageLabel", {
				Name = "Icon",
				Parent = row,
				BackgroundTransparency = 1,
				Image = iconAsset,
				ImageColor3 = Color3.fromRGB(190,210,255),
				Size = UDim2.new(0,28,0,28),
				Position = UDim2.new(0,10,0.5,-14),
				ZIndex = 6,
			})
		end
		local label = New("TextLabel", {
			Name = "Title",
			Parent = row,
			BackgroundTransparency = 1,
			Font = Enum.Font.SourceSansBold,
			TextSize = 28,
			TextColor3 = Color3.fromRGB(190,210,255),
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = title,
			Size = UDim2.new(1,-20,1,-10),
			Position = UDim2.new(0,icon and 44 or 10,0,10),
			ZIndex = 6,
		})
		if desc and desc ~= "" then
			local descLabel = New("TextLabel", {
				Name = "Description",
				Parent = row,
				BackgroundTransparency = 1,
				Font = Enum.Font.SourceSans,
				TextSize = 18,
				TextColor3 = Color3.fromRGB(160,180,200),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = desc,
				Size = UDim2.new(1,-20,0,24),
				Position = UDim2.new(0,icon and 44 or 10,0.5,8),
				ZIndex = 6,
			})
			row.Size = UDim2.new(1,0,0,64)
		end
		return row
	end

	function tab:AddToggle(config)
		config = config or {}
		local title = config.Title or "Toggle"
		local desc = config.Description or ""
		local default = config.Default or false
		local callback = config.Callback or function() end

		local row = MakeRow(self, title)
		if desc and desc ~= "" then
			New("TextLabel", {
				Parent = row,
				BackgroundTransparency = 1,
				Font = Enum.Font.SourceSans,
				TextSize = 18,
				TextColor3 = Color3.fromRGB(180,180,180),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = desc,
				Size = UDim2.new(1,-20,0,24),
				Position = UDim2.new(0,10,0.5,0),
				ZIndex = 6,
			})
			row.Size = UDim2.new(1,0,0,70)
		end

		local selector = MakeSelector(self, title.."_toggle", {"On", "Off"}, default and 1 or 2, function(index, value)
			callback(value == "On")
		end)
		return selector
	end

	function tab:AddSlider(config)
		config = config or {}
		local title = config.Title or "Slider"
		local desc = config.Description or ""
		local min = config.Min or 0
		local max = config.Max or 100
		local steps = config.Steps or 10
		local default = config.Default or min
		local callback = config.Callback or function() end

		local startIndex = math.clamp(math.floor((default - min) / ((max - min) / steps)) + 1, 1, steps)

		local row = MakeRow(self, title)
		if desc and desc ~= "" then
			New("TextLabel", {
				Parent = row,
				BackgroundTransparency = 1,
				Font = Enum.Font.SourceSans,
				TextSize = 18,
				TextColor3 = Color3.fromRGB(180,180,180),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = desc,
				Size = UDim2.new(1,-20,0,24),
				Position = UDim2.new(0,10,0.5,0),
				ZIndex = 6,
			})
			row.Size = UDim2.new(1,0,0,70)
		end

		local slider = MakeSlider(self, title.."_slider", steps, startIndex, function(value)
			local realValue = min + ((value - 1) * ((max - min) / steps))
			callback(realValue)
		end, 1)
		return slider
	end

	function tab:AddDropdown(config)
		config = config or {}
		local title = config.Title or "Dropdown"
		local desc = config.Description or ""
		local options = config.Options or {}
		local default = config.Default
		local callback = config.Callback or function() end

		local optLabels = {}
		local optValues = {}
		local defaultIndex = 1
		for i, opt in ipairs(options) do
			table.insert(optLabels, opt.Label)
			table.insert(optValues, opt.Value)
			if opt.Value == default then defaultIndex = i end
		end
		if #optLabels == 0 then return end

		local row = MakeRow(self, title)
		if desc and desc ~= "" then
			New("TextLabel", {
				Parent = row,
				BackgroundTransparency = 1,
				Font = Enum.Font.SourceSans,
				TextSize = 18,
				TextColor3 = Color3.fromRGB(180,180,180),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = desc,
				Size = UDim2.new(1,-20,0,24),
				Position = UDim2.new(0,10,0.5,0),
				ZIndex = 6,
			})
			row.Size = UDim2.new(1,0,0,70)
		end

		local dropdown = MakeDropDown(self, title.."_dropdown", optLabels, defaultIndex, function(index, label)
			if index then
				callback(optValues[index])
			else
				callback(nil)
			end
		end)
		return dropdown
	end

	function tab:AddButton(config)
		config = config or {}
		local title = config.Title or "Button"
		local desc = config.Description or ""
		local text = config.Text or "Click"
		local callback = config.Callback or function() end

		local row = MakeRow(self, title)
		if desc and desc ~= "" then
			New("TextLabel", {
				Parent = row,
				BackgroundTransparency = 1,
				Font = Enum.Font.SourceSans,
				TextSize = 18,
				TextColor3 = Color3.fromRGB(180,180,180),
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = desc,
				Size = UDim2.new(1,-20,0,24),
				Position = UDim2.new(0,10,0.5,0),
				ZIndex = 6,
			})
			row.Size = UDim2.new(1,0,0,70)
		end

		local btn, lbl = MakeStyledButton(title.."Button", text, UDim2.new(0,200,0,44), callback)
		btn.Parent = row
		btn.Position = UDim2.new(0.5, -100, 0.5, -22)
		return btn, lbl
	end

	return tab
end

function CoreUi:Unload()
	for _, conn in next, self.Connections do pcall(function() conn:Disconnect() end) end
	self.Connections = {}
	CloseActiveOverlay()
	ShowNativePages()
	for _, page in next, CustomTabPages do pcall(function() page:Destroy() end) end
	for _, btn in next, CustomTabButtons do pcall(function() btn:Destroy() end) end
	CustomTabPages = {}; CustomTabButtons = {}; CustomTabOrder = 0
	for _, nt in next, NativeTabs do
		pcall(function()
			nt.Size = UDim2.new(0, 120, 1, 0); nt.AutomaticSize = Enum.AutomaticSize.None
			local tl = nt:FindFirstChild("TabLabel")
			if tl then
				local ti = tl:FindFirstChild("Title"); if ti then ti.TextTransparency = 0 end
				local ic = tl:FindFirstChild("Icon")
				if ic then
					if ic:IsA("ImageLabel") then ic.ImageTransparency = 0
					elseif ic:IsA("TextLabel") then ic.TextTransparency = 0 end
				end
			end
		end)
	end
end

local Api = {}
function Api:SetVisibility(visible, noAnimation, customStartPage)
	MenuContainer.Visible = visible
	if visible and customStartPage then
		if CustomTabPages[customStartPage] then ActivateCustomTab(customStartPage)
		else for _, nt in next, NativeTabs do if nt.Name == customStartPage then ActivateNativeTab(nt); break end end end
	end
end
function Api:ToggleVisibility() MenuContainer.Visible = not MenuContainer.Visible end
function Api:GetVisibility() return MenuContainer.Visible end
function Api:SwitchToPage(pageName)
	if CustomTabPages[pageName] then ActivateCustomTab(pageName)
	else for _, nt in next, NativeTabs do if nt.Name == pageName then ActivateNativeTab(nt); break end end
	end
end
function Api:GetCurrentTab() return CurrentActiveTabType, CurrentActiveTabName end
Api.Instance = CoreUi
CoreUi.Api = Api

return CoreUi