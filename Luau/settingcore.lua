local CoreUi = {}
CoreUi.Options = {}
CoreUi.Connections = {}
CoreUi.Version = "3.0"

local cloneref = (cloneref or clonereference or function(i) return i end)
local RunServiceI = cloneref(game:GetService("RunService"))
local HttpServiceI = cloneref(game:GetService("HttpService"))

local function Get(url)
	if game.HttpGet then
		return game:HttpGet(url)
	else
		return HttpServiceI:GetAsync(url)
	end
end

local IconModule = {
	IconsType = "lucide",
	Icons = {},
}

do
	local packs = {
		lucide       = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/lucide/dist/Icons.lua",
		solar        = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/solar/dist/Icons.lua",
		craft        = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/craft/dist/Icons.lua",
		geist        = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/geist/dist/Icons.lua",
		sfsymbols    = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/sfsymbols/dist/Icons.lua",
		gravity      = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/gravity/dist/Icons.lua",
		googlematerial = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/GoogleMaterialIcons/dist/Icons.lua",
		hero         = "https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/hero/dist/Icons.lua",
	}
	for name, url in next, packs do
		local ok, result = pcall(function() return loadstring(Get(url))() end)
		if ok and type(result) == "table" then
			IconModule.Icons[name] = result
		end
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
	if not IconModule.Icons[packName] then
		IconModule.Icons[packName] = { Icons = {}, Spritesheets = {} }
	end
	for iconName, iconValue in pairs(iconsData) do
		if type(iconValue) == "number" or (type(iconValue) == "string" and iconValue:match("^rbxassetid://")) then
			local id = type(iconValue) == "number" and ("rbxassetid://" .. tostring(iconValue)) or iconValue
			IconModule.Icons[packName].Icons[iconName] = {
				Image = id, ImageRectSize = Vector2.new(0, 0), ImageRectPosition = Vector2.new(0, 0),
			}
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

local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players         = game:GetService("Players")
local CoreGui         = game:GetService("CoreGui")
local RobloxGui       = CoreGui:WaitForChild("RobloxGui")

local Shield do
	local clip = RobloxGui:FindFirstChild("SettingsClippingShield")
	Shield = clip and clip:WaitForChild("SettingsShield")
		or RobloxGui:FindFirstChild("SettingsShield")
		or RobloxGui:WaitForChild("SettingsClippingShield"):WaitForChild("SettingsShield")
end

local MenuContainer = Shield:WaitForChild("MenuContainer")

local Page do
	Page = MenuContainer:FindFirstChild("Page") or MenuContainer:WaitForChild("Page")
end

local HubBar = Page:WaitForChild("HubBar")

local TabContainer do
	local thc = HubBar:FindFirstChild("TabHeaderContainer")
	if thc then
		TabContainer = thc:FindFirstChild("HubBarContainer") or thc
	else
		TabContainer = HubBar:FindFirstChild("HubBarContainer") or HubBar
	end
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

for _, child in next, TabContainer:GetChildren() do
	if child:IsA("TextButton") and child ~= TabScroller then
		child.Parent = TabScroller
	end
end

local oldLayout = TabContainer:FindFirstChildOfClass("UIListLayout")
if oldLayout then oldLayout:Destroy() end

local PageViewClipper = Page:WaitForChild("PageViewClipper")
local PageScroll      = PageViewClipper:WaitForChild("PageView")
local PageInner do
	PageInner = PageScroll:FindFirstChild("PageViewInnerFrame")
		or PageScroll:WaitForChild("PageViewInnerFrame")
end

local OverlayRoot = Shield

local NativeTabs              = {}
local NativePages             = {}
local NativeScrollbars        = {}
local CustomTabPages          = {}
local CustomTabButtons        = {}
local CustomTabOrder          = 0
local CurrentActiveTabType    = "native"
local CurrentActiveTabName    = nil

local TAB_INACTIVE_TRANS      = 0.7
local TAB_ACTIVE_TRANS        = 0
local ActiveOverlay           = nil

local function AddConn(c)
	table.insert(CoreUi.Connections, c)
	return c
end

local function SafeCall(f, ...)
	if type(f) ~= "function" then return end
	local ok, err = pcall(f, ...)
	if not ok then warn("[CoreUi] " .. tostring(err)) end
end

local function Round(n, d)
	local m = 10 ^ (d or 0)
	return math.floor(n * m + 0.5) / m
end

local function New(cls, props, children)
	local obj = Instance.new(cls)
	for k, v in next, props or {} do
		if k ~= "Parent" then pcall(function() obj[k] = v end) end
	end
	for _, c in next, children or {} do
		if c then c.Parent = obj end
	end
	if props and props.Parent then obj.Parent = props.Parent end
	return obj
end

local function Tween(inst, t, goals, style, dir)
	TweenService:Create(
		inst,
		TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
		goals
	):Play()
end

local function HubCorner(r) return New("UICorner", { CornerRadius = UDim.new(0, r or 8) }) end
local function HubStroke(col, trans, thick)
	return New("UIStroke", {
		Color = col or Color3.fromRGB(255, 255, 255),
		Transparency = trans or 0.84,
		Thickness = thick or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function CloseActiveOverlay()
	if ActiveOverlay then
		pcall(function() ActiveOverlay:Destroy() end)
		ActiveOverlay = nil
	end
end

local function OpenOverlay(buildFn)
	CloseActiveOverlay()
	local dimmer = New("ImageButton", {
		Name = "CoreUiOverlayDimmer",
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		ZIndex = 20,
		Image = "",
		Parent = OverlayRoot,
	})
	dimmer.MouseButton1Click:Connect(CloseActiveOverlay)
	buildFn(dimmer)
	ActiveOverlay = dimmer
	return dimmer
end

local function RefreshNativePagesList()
	NativePages = {}
	NativeScrollbars = {}
	for _, child in next, PageInner:GetChildren() do
		if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
			local n = child.Name
			if not n:find("^CoreUi_") then
				table.insert(NativePages, child)
				local sc = child:FindFirstChildOfClass("ScrollingFrame") or child:FindFirstChild("CoreUiScroll")
				if sc and sc:IsA("ScrollingFrame") then
					NativeScrollbars[child] = { scroll = sc, thickness = sc.ScrollBarThickness }
				end
			end
		end
	end
end

local function ShowNativePages()
	for _, page in next, NativePages do pcall(function() page.Visible = true end) end
	for _, data in next, NativeScrollbars do
		if data.scroll then data.scroll.ScrollBarThickness = data.thickness end
	end
end

local function HideNativePages()
	for _, page in next, NativePages do pcall(function() page.Visible = false end) end
	for _, data in next, NativeScrollbars do
		if data.scroll then data.scroll.ScrollBarThickness = 0 end
	end
end

local SetTabAppearance

local function ActivateCustomTab(name)
	CurrentActiveTabType = "custom"
	CurrentActiveTabName = name
	HideNativePages()
	for n, pg in next, CustomTabPages do
		pg.Visible = (n == name)
		pg.Position = (n == name) and UDim2.new(0, 0, 0, 0) or UDim2.new(2, 0, 0, 0)
	end
	for n, btn in next, CustomTabButtons do
		SetTabAppearance(btn, n == name)
	end
	for _, nt in next, NativeTabs do
		local sel = nt:FindFirstChild("TabSelection")
		if sel then sel.Visible = false end
		local tl = nt:FindFirstChild("TabLabel")
		if tl then
			local ti = tl:FindFirstChild("Title")
			if ti then Tween(ti, 0.15, { TextTransparency = TAB_INACTIVE_TRANS }) end
			local ic = tl:FindFirstChild("Icon")
			if ic then
				if ic:IsA("ImageLabel") then Tween(ic, 0.15, { ImageTransparency = TAB_INACTIVE_TRANS })
				elseif ic:IsA("TextLabel") then Tween(ic, 0.15, { TextTransparency = TAB_INACTIVE_TRANS }) end
			end
		end
	end
end

local function ActivateNativeTab(activeNative)
	CurrentActiveTabType = "native"
	CurrentActiveTabName = nil
	ShowNativePages()
	for _, pg in next, CustomTabPages do
		pg.Visible = false
		pg.Position = UDim2.new(2, 0, 0, 0)
	end
	for _, btn in next, CustomTabButtons do
		SetTabAppearance(btn, false)
	end
	for _, nt in next, NativeTabs do
		local isActive = nt == activeNative
		local sel = nt:FindFirstChild("TabSelection")
		if sel then sel.Visible = isActive end
		local tl = nt:FindFirstChild("TabLabel")
		if tl then
			local ti = tl:FindFirstChild("Title")
			if ti then Tween(ti, 0.15, { TextTransparency = isActive and TAB_ACTIVE_TRANS or TAB_INACTIVE_TRANS }) end
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
		if CurrentActiveTabType == "custom" and CurrentActiveTabName then
			task.defer(function()
				ActivateCustomTab(CurrentActiveTabName)
			end)
		end
	else
		for _, pg in next, CustomTabPages do
			pcall(function() pg.Visible = false end)
		end
	end
end))

AddConn(TabScroller.ChildAdded:Connect(function(c)
	if c:IsA("TextButton") and not CustomTabButtons[c.Name] then
		table.insert(NativeTabs, c)
		c.LayoutOrder = #NativeTabs
		AddConn(c.MouseButton1Click:Connect(function() ActivateNativeTab(c) end))
	end
end))

for _, child in next, TabScroller:GetChildren() do
	if child:IsA("TextButton") then
		table.insert(NativeTabs, child)
		child.LayoutOrder = #NativeTabs
		AddConn(child.MouseButton1Click:Connect(function() ActivateNativeTab(child) end))
	end
end

SetTabAppearance = function(btn, active)
	local trans = active and TAB_ACTIVE_TRANS or TAB_INACTIVE_TRANS
	local tl = btn:FindFirstChild("TabLabel")
	if tl then
		local ti = tl:FindFirstChild("Title")
		if ti then Tween(ti, 0.15, { TextTransparency = trans }) end
		local ic = tl:FindFirstChild("Icon")
		if ic then
			if ic:IsA("ImageLabel") then Tween(ic, 0.15, { ImageTransparency = trans })
			elseif ic:IsA("TextLabel") then Tween(ic, 0.15, { TextTransparency = trans }) end
		end
	end
	local sel = btn:FindFirstChild("TabSelection")
	if sel then sel.Visible = active end
end

AddConn(PageInner.ChildAdded:Connect(function(child)
	if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
		local n = child.Name
		if not n:find("^CoreUi_") then
			table.insert(NativePages, child)
			local sc = child:FindFirstChildOfClass("ScrollingFrame") or child:FindFirstChild("CoreUiScroll")
			if sc and sc:IsA("ScrollingFrame") then
				NativeScrollbars[child] = { scroll = sc, thickness = sc.ScrollBarThickness }
			end
			if CurrentActiveTabType == "custom" then
				pcall(function() child.Visible = false end)
				local data = NativeScrollbars[child]
				if data and data.scroll then data.scroll.ScrollBarThickness = 0 end
			end
		end
	end
end))

task.defer(function()
	RefreshNativePagesList()
	if #NativeTabs > 0 then ActivateNativeTab(NativeTabs[1]) end
end)

local function RebuildTabSizes()
	for _, nt in next, NativeTabs do
		nt.Size = UDim2.new(0, 120, 1, 0)
		nt.AutomaticSize = Enum.AutomaticSize.None
	end
	for _, btn in next, CustomTabButtons do
		btn.Size = UDim2.new(0, 120, 1, 0)
		btn.AutomaticSize = Enum.AutomaticSize.None
	end
end

local function BuildTabButton(name, title, icon)
	local existing = TabScroller:FindFirstChild(name)
	if existing then existing:Destroy() end

	CustomTabOrder = CustomTabOrder + 1

	local iconAsset, iconData = ResolveIconAsset(icon)

	local iconEl
	if iconAsset then
		if iconAsset:find("^rbxassetid://") or iconAsset:find("^rbxthumb://") then
			iconEl = New("ImageLabel", {
				Name = "Icon",
				Size = UDim2.fromOffset(24, 24),
				BackgroundTransparency = 1,
				Image = iconAsset,
				ImageColor3 = Color3.fromRGB(255, 255, 255),
				ImageTransparency = TAB_INACTIVE_TRANS,
				ZIndex = 3,
				LayoutOrder = 1,
			}, { New("UIAspectRatioConstraint", {}) })
		else
			iconEl = New("TextLabel", {
				Name = "Icon",
				Size = UDim2.fromOffset(24, 24),
				BackgroundTransparency = 1,
				Text = iconAsset,
				Font = Enum.Font.Unknown,
				TextSize = 8,
				TextScaled = true,
				TextWrapped = true,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextTransparency = TAB_INACTIVE_TRANS,
				ZIndex = 3,
				LayoutOrder = 1,
			}, { New("UIAspectRatioConstraint", {}) })
		end
	end

	local btn = New("TextButton", {
		Name = name,
		Size = UDim2.new(0, 120, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		Font = Enum.Font.Legacy,
		TextSize = 8,
		BorderSizePixel = 0,
		ZIndex = 3,
		LayoutOrder = 1000 + CustomTabOrder,
		Selectable = false,
		Parent = TabScroller,
	}, {
		New("ImageLabel", {
			Name = "TabSelection",
			Size = UDim2.new(1, -2, 0, 2),
			Position = UDim2.new(0, 3, 1, -2),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			ZIndex = 4,
			Image = "",
			Visible = false,
		}),
		New("Frame", {
			Name = "TabLabel",
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			ZIndex = 3,
		}, {
			New("UIListLayout", {
				Name = "Layout",
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = UDim.new(0, iconEl and 8 or 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
			iconEl,
			New("TextLabel", {
				Name = "Title",
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				Text = title,
				Font = Enum.Font.BuilderSansMedium,
				TextSize = 17,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextTransparency = TAB_INACTIVE_TRANS,
				ZIndex = 3,
				LayoutOrder = 2,
			}),
		}),
	})

	CustomTabButtons[name] = btn
	btn.MouseButton1Click:Connect(function() ActivateCustomTab(name) end)
	SetTabAppearance(btn, false)
	RebuildTabSizes()
	return btn
end

local function BuildCustomPage(name)
	local ex = PageInner:FindFirstChild("CoreUi_" .. name)
	if ex then ex:Destroy() end

	local pageFrame = New("Frame", {
		Name = "CoreUi_" .. name,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(2, 0, 0, 0),
		BackgroundTransparency = 1,
		ZIndex = 5,
		Parent = PageInner,
	}, {
		New("UIListLayout", {
			Name = "RowListLayout",
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Padding = UDim.new(0, 0),
		}),
		New("UIPadding", {
			PaddingLeft  = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 11),
			PaddingBottom = UDim.new(0, 20),
		}),
	})

	CustomTabPages[name] = pageFrame
	return pageFrame, pageFrame
end

function CoreUi:Tab(section, config)
	config = config or {}
	local title = config.Title or section
	local icon  = config.Icon

	BuildTabButton(section, title, icon)
	local pageFrame, scroll = BuildCustomPage(section)

	local isFirst = true
	for n in next, CustomTabPages do
		if n ~= section then isFirst = false; break end
	end
	if isFirst then ActivateCustomTab(section) end

	local tab = {
		_scroll  = scroll,
		_page    = pageFrame,
		_section = section,
		IsCustom = true,
	}
	return tab
end

function CoreUi:Unload()
	for _, conn in next, self.Connections do pcall(function() conn:Disconnect() end) end
	self.Connections = {}
	CloseActiveOverlay()
	ShowNativePages()
	for _, page in next, CustomTabPages do pcall(function() page:Destroy() end) end
	for _, btn  in next, CustomTabButtons do pcall(function() btn:Destroy() end) end
	CustomTabPages   = {}
	CustomTabButtons = {}
	CustomTabOrder   = 0
	for _, nt in next, NativeTabs do
		pcall(function()
			nt.Size = UDim2.new(0, 120, 1, 0)
			nt.AutomaticSize = Enum.AutomaticSize.None
			local tl = nt:FindFirstChild("TabLabel")
			if tl then
				local ti = tl:FindFirstChild("Title")
				if ti then ti.TextTransparency = 0 end
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
		if CustomTabPages[customStartPage] then
			ActivateCustomTab(customStartPage)
		else
			for _, nt in next, NativeTabs do
				if nt.Name == customStartPage then ActivateNativeTab(nt); break end
			end
		end
	end
end
function Api:ToggleVisibility() MenuContainer.Visible = not MenuContainer.Visible end
function Api:GetVisibility()    return MenuContainer.Visible end
function Api:SwitchToPage(pageName)
	if CustomTabPages[pageName] then
		ActivateCustomTab(pageName)
	else
		for _, nt in next, NativeTabs do
			if nt.Name == pageName then ActivateNativeTab(nt); break end
		end
	end
end
function Api:GetCurrentTab()
	return CurrentActiveTabType, CurrentActiveTabName
end
Api.Instance = CoreUi
CoreUi.Api   = Api

return CoreUi