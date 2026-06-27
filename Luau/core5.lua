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

local function HoverEffect(frame)
	frame.MouseEnter:Connect(function()
		Tween(frame, 0.12, { BackgroundTransparency = 0.88 })
	end)
	frame.MouseLeave:Connect(function()
		Tween(frame, 0.12, { BackgroundTransparency = 1 })
	end)
end

local function ElemRow(parent, height)
	local f = New("ImageButton", {
		Size = UDim2.new(1, 0, 0, height or 50),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(35, 37, 39),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Image = "rbxasset://textures/ui/VR/rectBackgroundWhite.png",
		ImageColor3 = Color3.fromRGB(35, 37, 39),
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(2, 2, 18, 18),
		ZIndex = 2,
		Parent = parent,
	}, { HubCorner(8) })
	HoverEffect(f)
	return f
end

local function RowLabel(frame, title, desc)
	local hasDesc = desc and desc ~= ""
	New("TextLabel", {
		Name = "TitleLabel",
		Size = UDim2.new(0.4, -20, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = title,
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 17,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextWrapped = true,
		ZIndex = 3,
		Parent = frame,
	}, {
		New("UIPadding", {
			PaddingTop    = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
		}),
	})
	if hasDesc then
		New("TextLabel", {
			Name = "DescLabel",
			Size = UDim2.new(0.4, -20, 0, 0),
			Position = UDim2.new(0, 10, 0, 28),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Text = desc,
			Font = Enum.Font.BuilderSans,
			TextSize = 13,
			TextColor3 = Color3.fromRGB(175, 175, 192),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			ZIndex = 3,
			Parent = frame,
		})
	end
end

local Elements = {}

function Elements.Button(container, config)
	assert(config.Title, "Button: Title required")
	local frame = ElemRow(container, 50)
	RowLabel(frame, config.Title, config.Description)

	local selector = New("ImageButton", {
		Name = "Selector",
		Size = UDim2.new(0.6, 0, 0, 50),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Image = "",
		AutoButtonColor = false,
		ZIndex = 2,
		Parent = frame,
	})
	New("TextLabel", {
		Text = "›",
		Font = Enum.Font.BuilderSansBold,
		TextSize = 28,
		TextColor3 = Color3.fromRGB(204, 204, 204),
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(20, 28),
		ZIndex = 3,
		Parent = selector,
	})

	frame.MouseButton1Click:Connect(function() SafeCall(config.Callback) end)
	selector.MouseButton1Click:Connect(function() SafeCall(config.Callback) end)
	return { Frame = frame }
end

function Elements.Toggle(container, idx, config, library)
	assert(config.Title, "Toggle: Title required")
	local frame = ElemRow(container, 50)
	RowLabel(frame, config.Title, config.Description)
	local val = not not config.Default

	local selector = New("ImageButton", {
		Name = "Selector",
		Size = UDim2.new(0.6, 0, 0, 50),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Image = "",
		AutoButtonColor = false,
		ZIndex = 2,
		Parent = frame,
	})

	local track = New("Frame", {
		Name = "Track",
		Size = UDim2.fromOffset(50, 30),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		BackgroundColor3 = val and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(100, 100, 122),
		ZIndex = 3,
		Parent = selector,
	}, {
		HubCorner(15),
		HubStroke(Color3.fromRGB(255, 255, 255), 0.3, 1),
	})

	local circle = New("Frame", {
		Name = "Circle",
		Size = UDim2.fromOffset(22, 22),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, val and 25 or 3, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		ZIndex = 4,
		Parent = track,
	}, {
		HubCorner(11),
		HubStroke(Color3.fromRGB(0, 0, 0), 0.1, 1),
	})

	local toggle = {
		Value    = val,
		Type     = "Toggle",
		Callback = config.Callback or function() end,
	}

	local function SetValue(v)
		v = not not v
		toggle.Value = v
		Tween(track, 0.18, { BackgroundColor3 = v and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(100, 100, 122) })
		Tween(circle, 0.18, { Position = UDim2.new(0, v and 25 or 3, 0.5, 0) })
		SafeCall(toggle.Callback, v)
		if toggle.Changed then SafeCall(toggle.Changed, v) end
	end

	toggle.SetValue = SetValue
	toggle.OnChanged = function(self, f) self.Changed = f; f(self.Value) end
	toggle.Destroy   = function(self)
		frame:Destroy()
		if library then library.Options[idx] = nil end
	end

	selector.MouseButton1Click:Connect(function() SetValue(not toggle.Value) end)
	frame.MouseButton1Click:Connect(function() SetValue(not toggle.Value) end)
	if library then library.Options[idx] = toggle end
	return toggle
end

function Elements.Switch(container, idx, config, library)
	assert(config.Title, "Switch: Title required")
	assert(config.Values and #config.Values == 2, "Switch: Values must be a table of exactly 2 strings")
	local frame = ElemRow(container, 50)
	RowLabel(frame, config.Title, config.Description)

	local val1 = config.Values[1]
	local val2 = config.Values[2]
	local currentVal = config.Default or val1

	local selector = New("ImageButton", {
		Name = "Selector",
		Size = UDim2.new(0.6, 0, 0, 50),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Image = "",
		AutoButtonColor = false,
		ZIndex = 2,
		Active = true,
		Parent = frame,
	})

	local leftBtn = New("ImageButton", {
		Name = "LeftButton",
		Size = UDim2.new(0, 32, 0, 50),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Image = "",
		ZIndex = 3,
		Active = true,
		Parent = selector,
	}, {
		New("ImageLabel", {
			Size = UDim2.new(0, 18, 0, 30),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxasset://textures/ui/Settings/Slider/Left.png",
			ImageColor3 = Color3.fromRGB(204, 204, 204),
			ZIndex = 4,
		}),
	})

	local rightBtn = New("ImageButton", {
		Name = "RightButton",
		Size = UDim2.new(0, 32, 0, 50),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Image = "",
		ZIndex = 3,
		Active = true,
		Parent = selector,
	}, {
		New("ImageLabel", {
			Size = UDim2.new(0, 18, 0, 30),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxasset://textures/ui/Settings/Slider/Right.png",
			ImageColor3 = Color3.fromRGB(204, 204, 204),
			ZIndex = 4,
		}),
	})

	local autoSelect = New("ImageButton", {
		Name = "AutoSelectButton",
		Size = UDim2.new(1, -64, 1, 0),
		Position = UDim2.new(0, 32, 0, 0),
		BackgroundTransparency = 1,
		Image = "",
		ZIndex = 2,
		Active = true,
		AutoButtonColor = true,
		Parent = selector,
	})

	local sel1Label = New("TextLabel", {
		Name = "Selection1",
		Size = UDim2.new(1, -64, 1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = val1,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 17,
		Font = Enum.Font.BuilderSans,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 2,
		Visible = currentVal == val1,
		Parent = selector,
	})

	local sel2Label = New("TextLabel", {
		Name = "Selection2",
		Size = UDim2.new(1, -64, 1, 0),
		Position = UDim2.new(0, 32, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = val2,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 17,
		Font = Enum.Font.BuilderSans,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 2,
		Visible = currentVal == val2,
		Parent = selector,
	})

	local sw = {
		Value    = currentVal,
		Values   = config.Values,
		Type     = "Switch",
		Callback = config.Callback or function() end,
	}

	local function SetValue(v)
		sw.Value = v
		sel1Label.Visible = (v == val1)
		sel2Label.Visible = (v == val2)
		SafeCall(sw.Callback, v)
		if sw.Changed then SafeCall(sw.Changed, v) end
	end

	sw.SetValue = SetValue
	sw.OnChanged = function(self, f) self.Changed = f; f(self.Value) end
	sw.Destroy   = function(self)
		frame:Destroy()
		if library then library.Options[idx] = nil end
	end

	leftBtn.MouseButton1Click:Connect(function() SetValue(val1) end)
	rightBtn.MouseButton1Click:Connect(function() SetValue(val2) end)
	autoSelect.MouseButton1Click:Connect(function()
		SetValue(sw.Value == val1 and val2 or val1)
	end)

	if library then library.Options[idx] = sw end
	return sw
end

function Elements.Slider(container, idx, config, library)
	assert(config.Title, "Slider: Title required")
	assert(config.Min ~= nil and config.Max ~= nil and config.Default ~= nil, "Slider: Min/Max/Default required")

	local rounding = config.Rounding or 1
	local STEPS = 10
	local dragging = false

	local frame = ElemRow(container, 50)
	RowLabel(frame, config.Title, config.Description)

	local selector = New("Frame", {
		Name = "Slider",
		Size = UDim2.new(0.6, 0, 0, 50),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = frame,
	})

	local leftBtn = New("ImageButton", {
		Name = "LeftButton",
		Size = UDim2.new(0, 32, 0, 50),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Image = "",
		ZIndex = 3,
		Parent = selector,
	}, {
		New("ImageLabel", {
			Size = UDim2.new(0, 18, 0, 30),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxasset://textures/ui/Settings/Slider/Left.png",
			ImageColor3 = Color3.fromRGB(204, 204, 204),
			ZIndex = 4,
		}),
	})

	local rightBtn = New("ImageButton", {
		Name = "RightButton",
		Size = UDim2.new(0, 32, 0, 50),
		Position = UDim2.new(1, 0, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Image = "",
		ZIndex = 3,
		Parent = selector,
	}, {
		New("ImageLabel", {
			Size = UDim2.new(0, 18, 0, 30),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = "rbxasset://textures/ui/Settings/Slider/Right.png",
			ImageColor3 = Color3.fromRGB(204, 204, 204),
			ZIndex = 4,
		}),
	})

	local stepsContainer = New("Frame", {
		Name = "StepsContainer",
		Size = UDim2.new(1, -100, 1, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 2,
		Parent = selector,
	})

	local stepFrames = {}
	for s = 1, STEPS do
		local sf = New("ImageButton", {
			Name = "Step" .. s,
			Size = UDim2.new(1 / STEPS, -4, 0, 24),
			Position = UDim2.new((s - 1) / STEPS, 2, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(217, 217, 217),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Image = "",
			ZIndex = 3,
			Parent = stepsContainer,
		}, {
			HubCorner(8),
			HubStroke(Color3.fromRGB(255, 255, 255), 0.2, 1),
		})
		stepFrames[s] = sf
	end

	local valLabel = New("TextLabel", {
		Name = "ValLabel",
		Size = UDim2.new(0, 40, 0, 20),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Text = tostring(config.Default),
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 5,
		Parent = stepsContainer,
	})

	local slider = {
		Value    = config.Default,
		Min      = config.Min,
		Max      = config.Max,
		Rounding = rounding,
		Type     = "Slider",
		Callback = config.Callback or function() end,
	}

	local function UpdateSteps(pct)
		local filled = math.floor(pct * STEPS + 0.5)
		for s = 1, STEPS do
			local active = s <= filled
			stepFrames[s].BackgroundColor3 = active and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(217, 217, 217)
		end
	end

	local function SetValue(v)
		v = Round(math.clamp(v, slider.Min, slider.Max), rounding)
		slider.Value = v
		local pct = (v - slider.Min) / (slider.Max - slider.Min)
		UpdateSteps(pct)
		valLabel.Text = tostring(v)
		SafeCall(slider.Callback, v)
		if slider.Changed then SafeCall(slider.Changed, v) end
	end

	slider.SetValue = SetValue
	slider.OnChanged = function(self, f) self.Changed = f; f(self.Value) end
	slider.Destroy   = function(self)
		frame:Destroy()
		if library then library.Options[idx] = nil end
	end

	local stepSize = (config.Max - config.Min) / STEPS
	leftBtn.MouseButton1Click:Connect(function() SetValue(slider.Value - stepSize) end)
	rightBtn.MouseButton1Click:Connect(function() SetValue(slider.Value + stepSize) end)

	stepsContainer.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			local pct = math.clamp((i.Position.X - stepsContainer.AbsolutePosition.X) / stepsContainer.AbsoluteSize.X, 0, 1)
			SetValue(slider.Min + (slider.Max - slider.Min) * pct)
		end
	end)
	stepsContainer.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	AddConn(UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local pct = math.clamp((i.Position.X - stepsContainer.AbsolutePosition.X) / stepsContainer.AbsoluteSize.X, 0, 1)
			SetValue(slider.Min + (slider.Max - slider.Min) * pct)
		end
	end))

	SetValue(config.Default)
	if library then library.Options[idx] = slider end
	return slider
end

function Elements.Dropdown(container, idx, config, library)
	assert(config.Title, "Dropdown: Title required")
	assert(config.Values, "Dropdown: Values required")

	local frame = ElemRow(container, 50)
	RowLabel(frame, config.Title, config.Description)

	local dropdown = {
		Values   = config.Values,
		Value    = config.Default or (not config.Multi and config.Values[1]),
		Multi    = config.Multi or false,
		Selected = {},
		Opened   = false,
		Type     = "Dropdown",
		Callback = config.Callback or function() end,
	}

	if config.Multi and config.Default then
		for _, v in next, config.Default do dropdown.Selected[v] = true end
	end

	local inner = New("ImageButton", {
		Name = "DropDownFrameButton",
		Size = UDim2.new(0.6, 0, 0, 40),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(35, 37, 39),
		BackgroundTransparency = 0,
		Image = "",
		AutoButtonColor = false,
		ZIndex = 3,
		Parent = frame,
	}, {
		HubCorner(8),
		HubStroke(Color3.fromRGB(255, 255, 255), 0.8, 1),
	})

	local displayLabel = New("TextLabel", {
		Name = "DropDownFrameTextLabel",
		Size = UDim2.new(1, -40, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Text = (function()
			if config.Multi then return "None"
			elseif dropdown.Value then return tostring(dropdown.Value)
			else return "Select..." end
		end)(),
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 17,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 4,
		Parent = inner,
	})

	New("ImageLabel", {
		Name = "DropDownImage",
		Size = UDim2.fromOffset(15, 10),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BackgroundTransparency = 1,
		Image = "rbxasset://textures/ui/Settings/DropDown/DropDown.png",
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		ZIndex = 4,
		Parent = inner,
	})

	local function UpdateDisplay()
		if dropdown.Multi then
			local sel = {}
			for k in next, dropdown.Selected do table.insert(sel, k) end
			displayLabel.Text = #sel > 0 and table.concat(sel, ", ") or "None"
		else
			displayLabel.Text = dropdown.Value and tostring(dropdown.Value) or "Select..."
		end
	end

	local function SetValue(v)
		if dropdown.Multi then
			if type(v) == "table" then
				dropdown.Selected = {}
				for _, item in next, v do dropdown.Selected[item] = true end
				dropdown.Value = v
			else
				dropdown.Selected[v] = not dropdown.Selected[v]
				local sel = {}
				for k in next, dropdown.Selected do table.insert(sel, k) end
				dropdown.Value = sel
			end
		else
			dropdown.Value = v
		end
		UpdateDisplay()
		SafeCall(dropdown.Callback, dropdown.Value)
		if dropdown.Changed then SafeCall(dropdown.Changed, dropdown.Value) end
	end

	dropdown.SetValue = SetValue
	dropdown.OnChanged = function(self, f) self.Changed = f; f(self.Value) end
	dropdown.Destroy   = function(self)
		frame:Destroy()
		if library then library.Options[idx] = nil end
	end

	local chevron = inner:FindFirstChild("DropDownImage")

	local function OpenList()
		if dropdown.Opened then
			CloseActiveOverlay()
			dropdown.Opened = false
			if chevron then Tween(chevron, 0.15, { Rotation = 0 }) end
			return
		end
		dropdown.Opened = true
		if chevron then Tween(chevron, 0.15, { Rotation = 180 }) end

		local absPos  = inner.AbsolutePosition
		local absSize = inner.AbsoluteSize

		OpenOverlay(function(dimmer)
			local listHeight = math.min(#dropdown.Values * 40 + 12, 200)
			local rootPos    = OverlayRoot.AbsolutePosition
			local rootSize   = OverlayRoot.AbsoluteSize
			local openUp     = (absPos.Y + absSize.Y + listHeight) > (rootPos.Y + rootSize.Y - 20)
			local listY      = openUp and (absPos.Y - listHeight - 2) or (absPos.Y + absSize.Y + 2)

			local list = New("ScrollingFrame", {
				Name = "CoreUiDropList",
				Position = UDim2.fromOffset(absPos.X - rootPos.X, listY - rootPos.Y),
				Size = UDim2.fromOffset(absSize.X, listHeight),
				BackgroundColor3 = Color3.fromRGB(27, 28, 33),
				BackgroundTransparency = 0,
				ScrollBarThickness = 3,
				ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
				ScrollBarImageTransparency = 0.7,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				BorderSizePixel = 0,
				ZIndex = 22,
				Parent = dimmer,
			}, {
				HubCorner(8),
				HubStroke(Color3.fromRGB(255, 255, 255), 0.84, 1),
				New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0) }),
				New("UIPadding", {
					PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
					PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
				}),
			})

			for i, opt in next, dropdown.Values do
				local isSel = dropdown.Multi and dropdown.Selected[opt] or dropdown.Value == opt
				local item = New("ImageButton", {
					Name = "Option_" .. i,
					Size = UDim2.new(1, 0, 0, 40),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundColor3 = isSel and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = isSel and 0.75 or 0.96,
					BorderSizePixel = 0,
					Image = "",
					AutoButtonColor = false,
					ZIndex = 23,
					Parent = list,
				}, { HubCorner(6) })

				New("TextLabel", {
					Size = UDim2.new(1, -48, 0, 40),
					Position = UDim2.fromOffset(12, 0),
					BackgroundTransparency = 1,
					Text = tostring(opt),
					Font = Enum.Font.BuilderSans,
					TextSize = 15,
					TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(213, 215, 221),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					ZIndex = 24,
					Parent = item,
				})

				if isSel then
					New("TextLabel", {
						Size = UDim2.fromOffset(24, 24),
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.new(1, -10, 0.5, 0),
						BackgroundTransparency = 1,
						Text = "check",
						Font = Enum.Font.Unknown,
						FontFace = Font.new("rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
						TextSize = 18,
						TextScaled = false,
						TextColor3 = Color3.fromRGB(0, 162, 255),
						TextXAlignment = Enum.TextXAlignment.Center,
						ZIndex = 25,
						Parent = item,
					})
				end

				if i < #dropdown.Values then
					New("Frame", {
						Size = UDim2.new(1, -16, 0, 1),
						Position = UDim2.new(0, 8, 1, 0),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 0.9,
						BorderSizePixel = 0,
						ZIndex = 24,
						Parent = item,
					})
				end

				item.MouseButton1Click:Connect(function()
					SetValue(opt)
					if not dropdown.Multi then
						CloseActiveOverlay()
						dropdown.Opened = false
						if chevron then Tween(chevron, 0.15, { Rotation = 0 }) end
					end
				end)
			end
		end)

		if ActiveOverlay then
			ActiveOverlay.AncestryChanged:Connect(function()
				dropdown.Opened = false
				if chevron then Tween(chevron, 0.15, { Rotation = 0 }) end
			end)
		end
	end

	inner.MouseButton1Click:Connect(OpenList)
	frame.MouseButton1Click:Connect(OpenList)
	UpdateDisplay()
	if library then library.Options[idx] = dropdown end
	return dropdown
end

function Elements.Input(container, idx, config, library)
	assert(config.Title, "Input: Title required")
	local frame = ElemRow(container, 50)
	RowLabel(frame, config.Title, config.Description)

	local input = {
		Value    = config.Default or "",
		Numeric  = config.Numeric or false,
		Finished = config.Finished or false,
		Type     = "Input",
		Callback = config.Callback or function() end,
	}

	local boxFrame = New("Frame", {
		Size = UDim2.new(0.6, 0, 0, 40),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		BackgroundColor3 = Color3.fromRGB(35, 37, 39),
		BackgroundTransparency = 0,
		ZIndex = 3,
		Parent = frame,
	}, {
		HubCorner(8),
		HubStroke(Color3.fromRGB(255, 255, 255), 0.8, 1),
		New("UIPadding", {
			PaddingLeft  = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
		}),
	})

	local box = New("TextBox", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = config.Default or "",
		PlaceholderText = config.Placeholder or "",
		PlaceholderColor3 = Color3.fromRGB(175, 175, 192),
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 17,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ZIndex = 4,
		Parent = boxFrame,
	})

	local function SetValue(text)
		if config.MaxLength and #text > config.MaxLength then text = text:sub(1, config.MaxLength) end
		if input.Numeric and not tonumber(text) and #text > 0 then text = input.Value end
		input.Value = text
		box.Text = text
		SafeCall(input.Callback, text)
		if input.Changed then SafeCall(input.Changed, text) end
	end

	input.SetValue = SetValue
	input.OnChanged = function(self, f) self.Changed = f; f(self.Value) end
	input.Destroy   = function(self)
		frame:Destroy()
		if library then library.Options[idx] = nil end
	end

	if input.Finished then
		box.FocusLost:Connect(function(enter) if enter then SetValue(box.Text) end end)
	else
		box:GetPropertyChangedSignal("Text"):Connect(function() SetValue(box.Text) end)
	end

	if library then library.Options[idx] = input end
	return input
end

function Elements.Keybind(container, idx, config, library)
	assert(config.Title, "Keybind: Title required")
	assert(config.Default, "Keybind: Default required")
	local frame = ElemRow(container, 50)
	RowLabel(frame, config.Title, config.Description)

	local keybind = {
		Value           = config.Default,
		Mode            = config.Mode or "Toggle",
		Toggled         = false,
		Picking         = false,
		Type            = "Keybind",
		Callback        = config.Callback or function() end,
		ChangedCallback = config.ChangedCallback or function() end,
	}

	local keyLabel = New("TextLabel", {
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 20),
		BackgroundTransparency = 1,
		Text = config.Default,
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 17,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 4,
	})

	local keyBox = New("TextButton", {
		Size = UDim2.new(0.6, 0, 0, 40),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		AutomaticSize = Enum.AutomaticSize.None,
		BackgroundColor3 = Color3.fromRGB(35, 37, 39),
		BackgroundTransparency = 0,
		Text = "",
		ZIndex = 3,
		Parent = frame,
	}, {
		HubCorner(8),
		HubStroke(Color3.fromRGB(255, 255, 255), 0.8, 1),
		New("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment   = Enum.VerticalAlignment.Center,
		}),
		keyLabel,
	})

	local function SetValue(key, mode)
		keybind.Value = key or keybind.Value
		keybind.Mode  = mode or keybind.Mode
		keyLabel.Text = keybind.Value
	end

	keybind.SetValue  = SetValue
	keybind.GetState  = function()
		if UserInputService:GetFocusedTextBox() and keybind.Mode ~= "Always" then return false end
		if keybind.Mode == "Always" then return true
		elseif keybind.Mode == "Hold" then
			if keybind.Value == "None" then return false end
			local k = keybind.Value
			if k == "MouseLeft" then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
			elseif k == "MouseRight" then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
			else return UserInputService:IsKeyDown(Enum.KeyCode[k]) end
		else return keybind.Toggled end
	end
	keybind.DoClick   = function()
		SafeCall(keybind.Callback, keybind.Toggled)
		if keybind.Clicked then SafeCall(keybind.Clicked, keybind.Toggled) end
	end
	keybind.OnClick   = function(self, f) self.Clicked = f end
	keybind.OnChanged = function(self, f) self.Changed = f; f(self.Value) end
	keybind.Destroy   = function(self)
		frame:Destroy()
		if library then library.Options[idx] = nil end
	end

	keyBox.InputBegan:Connect(function(inp)
		if (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) and not keybind.Picking then
			keybind.Picking = true
			keyLabel.Text = "..."
			task.delay(0.2, function()
				local ev
				ev = UserInputService.InputBegan:Connect(function(input)
					local key
					if input.UserInputType == Enum.UserInputType.Keyboard then key = input.KeyCode.Name
					elseif input.UserInputType == Enum.UserInputType.MouseButton1 then key = "MouseLeft"
					elseif input.UserInputType == Enum.UserInputType.MouseButton2 then key = "MouseRight"
					else return end
					keybind.Picking = false
					keybind.Value = key
					keyLabel.Text = key
					SafeCall(keybind.ChangedCallback, key)
					if keybind.Changed then SafeCall(keybind.Changed, key) end
					ev:Disconnect()
				end)
			end)
		end
	end)

	AddConn(UserInputService.InputBegan:Connect(function(inp)
		if not keybind.Picking and not UserInputService:GetFocusedTextBox() then
			if keybind.Mode == "Toggle" then
				local k = keybind.Value
				local matches = false
				if k == "MouseLeft" and inp.UserInputType == Enum.UserInputType.MouseButton1 then matches = true
				elseif k == "MouseRight" and inp.UserInputType == Enum.UserInputType.MouseButton2 then matches = true
				elseif inp.UserInputType == Enum.UserInputType.Keyboard and inp.KeyCode.Name == k then matches = true end
				if matches then
					keybind.Toggled = not keybind.Toggled
					keybind:DoClick()
				end
			end
		end
	end))

	if library then library.Options[idx] = keybind end
	return keybind
end

function Elements.Colorpicker(container, idx, config, library)
	assert(config.Title, "Colorpicker: Title required")
	local frame = ElemRow(container, 50)
	RowLabel(frame, config.Title, config.Description)

	local val   = config.Default or Color3.fromRGB(255, 255, 255)
	local trans = config.DefaultTransparency or 0

	local picker = {
		Value        = val,
		Transparency = trans,
		Type         = "Colorpicker",
		Callback     = config.Callback or function() end,
	}

	local swatch = New("Frame", {
		Name = "ColorSwatch",
		Size = UDim2.fromOffset(32, 32),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		BackgroundColor3 = val,
		BorderSizePixel = 0,
		ZIndex = 3,
		Parent = frame,
	}, {
		HubCorner(6),
		HubStroke(Color3.fromRGB(255, 255, 255), 0.6, 1),
	})

	local function SetValueRGB(color, transparency)
		picker.Value        = color
		picker.Transparency = transparency or picker.Transparency
		swatch.BackgroundColor3 = color
		SafeCall(picker.Callback, color)
		if picker.Changed then SafeCall(picker.Changed, color) end
	end

	picker.SetValue    = function(self, color) SetValueRGB(color, self.Transparency) end
	picker.SetValueRGB = SetValueRGB
	picker.OnChanged   = function(self, f) self.Changed = f; f(self.Value) end
	picker.Destroy     = function(self)
		frame:Destroy()
		if library then library.Options[idx] = nil end
	end

	if library then library.Options[idx] = picker end
	return picker
end

function Elements.Paragraph(container, config)
	assert(config.Title, "Paragraph: Title required")
	local frame = ElemRow(container, 0)
	frame.AutomaticSize = Enum.AutomaticSize.Y

	New("TextLabel", {
		Name = "TitleLabel",
		Size = UDim2.new(1, -24, 0, 0),
		Position = UDim2.fromOffset(12, 12),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = config.Title,
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 17,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		ZIndex = 3,
		Parent = frame,
	})
	New("TextLabel", {
		Name = "ContentLabel",
		Size = UDim2.new(1, -24, 0, 0),
		Position = UDim2.fromOffset(12, 34),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Text = config.Content or "",
		Font = Enum.Font.BuilderSans,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(175, 175, 192),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		ZIndex = 3,
		Parent = frame,
	})
	New("UIPadding", { PaddingBottom = UDim.new(0, 12), Parent = frame })
	return { Frame = frame }
end

function Elements.Divider(container, config)
	New("Frame", {
		Name = "Divider",
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 0.87,
		BorderSizePixel = 0,
		ZIndex = 2,
		Parent = container,
	})
end

function Elements.Section(container, title)
	New("TextLabel", {
		Name = "SectionLabel",
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		Text = title,
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 13,
		TextColor3 = Color3.fromRGB(185, 185, 205),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2,
		Parent = container,
	}, {
		New("UIPadding", { PaddingLeft = UDim.new(0, 4) }),
	})
end

function Elements.Group(container, config, library)
	local gap = (config and config.Gap) or 6
	local groupFrame = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = container,
	}, {
		New("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, gap),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	local group = { Elements = {} }

	local function Resize()
		local n = #group.Elements
		if n == 0 then return end
		for _, e in next, group.Elements do
			if e.Frame then
				e.Frame.Size = UDim2.new(1 / n, -gap * (n - 1) / n, 0, e.Frame.AbsoluteSize.Y or 40)
			end
		end
	end

	function group:Button(cfg)
		local e = Elements.Button(groupFrame, cfg)
		e.Frame.Size = UDim2.new(0.5, -gap / 2, 0, 40)
		table.insert(self.Elements, e)
		task.defer(Resize)
		return e
	end

	function group:Toggle(i, cfg)
		local e = Elements.Toggle(groupFrame, i, cfg, library)
		table.insert(self.Elements, { Frame = e.Frame })
		task.defer(Resize)
		return e
	end

	function group:Paragraph(cfg)
		local e = Elements.Paragraph(groupFrame, cfg)
		table.insert(self.Elements, e)
		task.defer(Resize)
		return e
	end

	return group
end

local function BindMethods(target, container, library)
	function target:Button(cfg)               return Elements.Button(container, cfg) end
	function target:Toggle(idx, cfg)          return Elements.Toggle(container, idx, cfg, library) end
	function target:Switch(idx, cfg)          return Elements.Switch(container, idx, cfg, library) end
	function target:Slider(idx, cfg)          return Elements.Slider(container, idx, cfg, library) end
	function target:Dropdown(idx, cfg)        return Elements.Dropdown(container, idx, cfg, library) end
	function target:Input(idx, cfg)           return Elements.Input(container, idx, cfg, library) end
	function target:Keybind(idx, cfg)         return Elements.Keybind(container, idx, cfg, library) end
	function target:Colorpicker(idx, cfg)     return Elements.Colorpicker(container, idx, cfg, library) end
	function target:Paragraph(cfg)            return Elements.Paragraph(container, cfg) end
	function target:Divider(cfg)              return Elements.Divider(container, cfg) end
	function target:Group(cfg)                return Elements.Group(container, cfg, library) end
	function target:AddSection(title)
		Elements.Section(container, title)
		local section = {}
		BindMethods(section, container, library)
		return section
	end
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

	local container = scroll
	local tab = {}
	BindMethods(tab, container, self)
	tab._scroll  = scroll
	tab._page    = pageFrame
	tab._section = section
	tab.IsCustom = true
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
