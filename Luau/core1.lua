local CoreUi = {}
CoreUi.Options = {}
CoreUi.Connections = {}
CoreUi.Version = "2.0"

local cloneref = (cloneref or clonereference or function(i) return i end)
local RunServiceI = cloneref(game:GetService("RunService"))
local HttpServiceI = cloneref(game:GetService("HttpService"))

local function Get(url)
    if writefile and game.HttpGet then
        return game:HttpGet(url)
    else
        return HttpServiceI:GetAsync(url)
    end
end

local IconModule = {
    IconsType = "lucide",
    New = nil,
    IconThemeTag = nil,
    Icons = {},
}

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
        local ok, result = pcall(function()
            return loadstring(Get(url))()
        end)
        if ok and type(result) == "table" then
            IconModule.Icons[name] = result
        end
    end
end

local function parseIconString(iconString)
    if type(iconString) == "string" then
        local col = iconString:find(":")
        if col then
            return iconString:sub(1, col - 1), iconString:sub(col + 1)
        end
        local sl = iconString:find("/")
        if sl then
            return iconString:sub(1, sl - 1), iconString:sub(sl + 1)
        end
    end
    return nil, iconString
end

function IconModule.SetIconsType(t) IconModule.IconsType = t end

function IconModule.Init(New, tag)
    IconModule.New = New
    IconModule.IconThemeTag = tag
    return IconModule
end

function IconModule.AddIcons(packName, iconsData)
    if type(packName) ~= "string" or type(iconsData) ~= "table" then return end
    if not IconModule.Icons[packName] then
        IconModule.Icons[packName] = { Icons = {}, Spritesheets = {} }
    end
    for iconName, iconValue in pairs(iconsData) do
        if type(iconValue) == "number" or (type(iconValue) == "string" and iconValue:match("^rbxassetid://")) then
            local imageId = type(iconValue) == "number" and ("rbxassetid://" .. tostring(iconValue)) or iconValue
            IconModule.Icons[packName].Icons[iconName] = {
                Image = imageId,
                ImageRectSize = Vector2.new(0, 0),
                ImageRectPosition = Vector2.new(0, 0),
                Parts = nil,
            }
            IconModule.Icons[packName].Spritesheets[imageId] = imageId
        elseif type(iconValue) == "table" and iconValue.Image and iconValue.ImageRectSize and iconValue.ImageRectPosition then
            local imageId = type(iconValue.Image) == "number" and ("rbxassetid://" .. tostring(iconValue.Image)) or iconValue.Image
            IconModule.Icons[packName].Icons[iconName] = {
                Image = imageId,
                ImageRectSize = iconValue.ImageRectSize,
                ImageRectPosition = iconValue.ImageRectPosition,
                Parts = iconValue.Parts,
            }
            IconModule.Icons[packName].Spritesheets[imageId] = imageId
        end
    end
end

function IconModule.Icon(Icon, Type, DefaultFormat)
    DefaultFormat = DefaultFormat ~= false
    local iconType, iconName = parseIconString(Icon)
    local targetType = iconType or Type or IconModule.IconsType
    local iconSet = IconModule.Icons[targetType]
    if not iconSet then return nil end
    if iconSet.Icons and iconSet.Icons[iconName] then
        local ic = iconSet.Icons[iconName]
        local sheet = iconSet.Spritesheets and iconSet.Spritesheets[tostring(ic.Image)] or ic.Image
        return { sheet, ic }
    elseif iconSet[iconName] and type(iconSet[iconName]) == "string" and iconSet[iconName]:find("rbxassetid://") then
        if DefaultFormat then
            return { iconSet[iconName], { ImageRectSize = Vector2.new(0,0), ImageRectPosition = Vector2.new(0,0) } }
        end
        return iconSet[iconName]
    end
    return nil
end

function IconModule.GetIcon(Icon, Type) return IconModule.Icon(Icon, Type, false) end
function IconModule.Icon2(Icon, Type) return IconModule.Icon(Icon, Type, true) end

function IconModule.Image(IconConfig)
    local IconData = {
        Icon = IconConfig.Icon or nil,
        Type = IconConfig.Type,
        Colors = IconConfig.Colors or { (IconModule.IconThemeTag or Color3.new(1,1,1)), Color3.new(1,1,1) },
        Size = IconConfig.Size or UDim2.new(0, 24, 0, 24),
        IconFrame = nil,
    }
    local Colors = {}
    for i, color in next, IconData.Colors do
        Colors[i] = {
            ThemeTag = type(color) == "string" and color,
            Color = typeof(color) == "Color3" and color,
        }
    end
    local IconLabel = IconModule.Icon2(IconData.Icon, IconData.Type)
    if not IconLabel then return IconData end
    local isAsset = type(IconLabel) == "string" and IconLabel:find("rbxassetid://")
    local mkFrame = function(parent)
        local frame = Instance.new("ImageLabel")
        frame.Size = IconData.Size
        frame.BackgroundTransparency = 1
        frame.ImageColor3 = (Colors[1] and Colors[1].Color) or Color3.new(1,1,1)
        frame.Image = isAsset and IconLabel or IconLabel[1]
        frame.ImageRectSize = isAsset and Vector2.new(0,0) or IconLabel[2].ImageRectSize
        frame.ImageRectOffset = isAsset and Vector2.new(0,0) or IconLabel[2].ImageRectPosition
        if parent then frame.Parent = parent end
        if not isAsset and IconLabel[2] and IconLabel[2].Parts then
            for pi, part in next, IconLabel[2].Parts do
                local pl = IconModule.Icon(part, IconData.Type)
                if pl then
                    local pp = Instance.new("ImageLabel")
                    pp.Size = UDim2.new(1,0,1,0)
                    pp.BackgroundTransparency = 1
                    pp.ImageColor3 = (Colors[1+pi] and Colors[1+pi].Color) or Color3.new(1,1,1)
                    pp.Image = pl[1]
                    pp.ImageRectSize = pl[2].ImageRectSize
                    pp.ImageRectOffset = pl[2].ImageRectPosition
                    pp.Parent = frame
                end
            end
        end
        return frame
    end
    IconData.IconFrame = mkFrame(nil)
    return IconData
end

local function ResolveIcon(icon)
    if type(icon) ~= "string" then return nil end
    if icon:find("^rbxassetid://") or icon:find("^rbxthumb://") or icon:find("^http") then
        return icon
    end
    local iconType, iconName = parseIconString(icon)
    local targetType = iconType or IconModule.IconsType
    local iconSet = IconModule.Icons[targetType]
    if iconSet then
        if iconSet.Icons and iconSet.Icons[iconName] then
            return iconSet.Icons[iconName].Image
        elseif iconSet[iconName] then
            local v = iconSet[iconName]
            if type(v) == "number" then return "rbxassetid://" .. tostring(v) end
            if type(v) == "string" then return v end
        end
    end
    return icon
end

CoreUi.IconModule = IconModule

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local RobloxGui = CoreGui:WaitForChild("RobloxGui")

local Shield do
    local clip = RobloxGui:FindFirstChild("SettingsClippingShield")
    if clip then
        Shield = clip:WaitForChild("SettingsShield")
    else
        Shield = RobloxGui:FindFirstChild("SettingsShield")
            or RobloxGui:WaitForChild("SettingsClippingShield"):WaitForChild("SettingsShield")
    end
end

local MenuContainer = Shield:WaitForChild("MenuContainer")

local Page do
    local p = MenuContainer:FindFirstChild("Page")
    if p then
        Page = p
    else
        Page = MenuContainer:WaitForChild("Page")
    end
end

local HubBar = Page:WaitForChild("HubBar")

local TabContainer do
    local thc = HubBar:FindFirstChild("TabHeaderContainer")
    if thc then
        local hbc = thc:FindFirstChild("HubBarContainer")
        TabContainer = hbc or thc
    else
        TabContainer = HubBar:FindFirstChild("HubBarContainer") or HubBar
    end
end

do
    local layout = TabContainer:FindFirstChildOfClass("UIListLayout")
    if layout then
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    end
end

local PageViewClipper = Page:WaitForChild("PageViewClipper")
local PageScroll = PageViewClipper:WaitForChild("PageView")

local PageInner do
    local pif = PageScroll:FindFirstChild("PageViewInnerFrame")
    if pif then
        PageInner = pif
    else
        PageInner = PageScroll:WaitForChild("PageViewInnerFrame")
    end
end

local OverlayRoot = Shield

local T = {
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(175, 175, 192),
    Accent = Color3.fromRGB(0, 162, 255),
    AccentDark = Color3.fromRGB(0, 120, 200),
    ElemBg = Color3.fromRGB(255, 255, 255),
    ElemBgT = 0.93,
    ElemHoverT = 0.88,
    Border = Color3.fromRGB(255, 255, 255),
    BorderT = 0.84,
    Indicator = Color3.fromRGB(255, 255, 255),
    ToggleOff = Color3.fromRGB(100, 100, 122),
    SliderRail = Color3.fromRGB(210, 210, 230),
    SliderRailT = 0.65,
    SectionLabel = Color3.fromRGB(185, 185, 205),
    DividerColor = Color3.fromRGB(255, 255, 255),
    DividerT = 0.87,
    DropBg = Color3.fromRGB(30, 30, 44),
    DropBgT = 0.04,
    InputBg = Color3.fromRGB(255, 255, 255),
    InputBgT = 0.88,
    KeyBg = Color3.fromRGB(255, 255, 255),
    KeyBgT = 0.88,
    ScrollBar = Color3.fromRGB(255, 255, 255),
    ScrollBarT = 0.7,
}
CoreUi._T = T

local ExistingTabMap = {}

local CustomTabPages = {}
local CustomTabButtons = {}
local NativeTabs = {}
local CustomTabOrder = 0
local NativePages = {}
local CurrentActiveTabType = "native"
local CurrentActiveTabName = nil

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
        if k ~= "Parent" then
            pcall(function() obj[k] = v end)
        end
    end
    for _, c in next, children or {} do
        if c then c.Parent = obj end
    end
    if props and props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function Tween(inst, t, goals, style, dir)
    TweenService:Create(
        inst,
        TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        goals
    ):Play()
end

local function RoundUICorner(r)
    return New("UICorner", { CornerRadius = UDim.new(0, r or 8) })
end

local function Stroke(color, trans, thick)
    return New("UIStroke", {
        Color = color or T.Border,
        Transparency = trans or T.BorderT,
        Thickness = thick or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local TAB_INACTIVE_TRANS = 0.7
local TAB_ACTIVE_TRANS = 0
local SetTabAppearance

local function RefreshNativePagesList()
    NativePages = {}
    for _, child in next, PageInner:GetChildren() do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") and not child:IsA("UICanvasGroup") then
            local name = child.Name
            if not name:find("^CoreUi_") and not name:find("^InnerCanvasGroup") then
                table.insert(NativePages, child)
            end
        end
    end
end

local function ShowNativePages()
    for _, page in next, NativePages do
        pcall(function() page.Visible = true end)
    end
end

local function HideNativePages()
    for _, page in next, NativePages do
        pcall(function() page.Visible = false end)
    end
end

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
        local tabLabel = nt:FindFirstChild("TabLabel")
        if tabLabel then
            local title = tabLabel:FindFirstChild("Title")
            if title then Tween(title, 0.15, { TextTransparency = TAB_INACTIVE_TRANS }) end
            local icon = tabLabel:FindFirstChild("Icon")
            if icon then
                if icon:IsA("ImageLabel") then
                    Tween(icon, 0.15, { ImageTransparency = TAB_INACTIVE_TRANS })
                elseif icon:IsA("TextLabel") then
                    Tween(icon, 0.15, { TextTransparency = TAB_INACTIVE_TRANS })
                end
            end
        end
    end
end

local function ActivateNativeTab(activeNative)
    CurrentActiveTabType = "native"
    CurrentActiveTabName = nil
    ShowNativePages()
    for n, pg in next, CustomTabPages do
        pg.Visible = false
        pg.Position = UDim2.new(2, 0, 0, 0)
    end
    for n, btn in next, CustomTabButtons do
        SetTabAppearance(btn, false)
    end
    for _, nt in next, NativeTabs do
        local isActive = nt == activeNative
        local sel = nt:FindFirstChild("TabSelection")
        if sel then sel.Visible = isActive end
        local tabLabel = nt:FindFirstChild("TabLabel")
        if tabLabel then
            local title = tabLabel:FindFirstChild("Title")
            if title then
                Tween(title, 0.15, { TextTransparency = isActive and TAB_ACTIVE_TRANS or TAB_INACTIVE_TRANS })
            end
            local icon = tabLabel:FindFirstChild("Icon")
            if icon then
                if icon:IsA("ImageLabel") then
                    Tween(icon, 0.15, { ImageTransparency = isActive and TAB_ACTIVE_TRANS or TAB_INACTIVE_TRANS })
                elseif icon:IsA("TextLabel") then
                    Tween(icon, 0.15, { TextTransparency = isActive and TAB_ACTIVE_TRANS or TAB_INACTIVE_TRANS })
                end
            end
        end
    end
end

AddConn(MenuContainer:GetPropertyChangedSignal("Visible"):Connect(function()
    if not MenuContainer.Visible then
        for n, pg in next, CustomTabPages do
            pcall(function() pg.Visible = false end)
            pcall(function() pg.Position = UDim2.new(2, 0, 0, 0) end)
        end
        ShowNativePages()
        CurrentActiveTabType = "native"
        CurrentActiveTabName = nil
    end
end))

AddConn(TabContainer.ChildAdded:Connect(function(c)
    if c:IsA("TextButton") and not CustomTabButtons[c.Name] then
        table.insert(NativeTabs, c)
        c.LayoutOrder = #NativeTabs
        AddConn(c.MouseButton1Click:Connect(function()
            ActivateNativeTab(c)
        end))
    end
end))

for _, nt in next, NativeTabs do
    local ntRef = nt
    AddConn(nt.MouseButton1Click:Connect(function()
        ActivateNativeTab(ntRef)
    end))
end

SetTabAppearance = function(btn, active)
    local trans = active and TAB_ACTIVE_TRANS or TAB_INACTIVE_TRANS
    local tabLabel = btn:FindFirstChild("TabLabel")
    if tabLabel then
        local title = tabLabel:FindFirstChild("Title")
        if title then
            Tween(title, 0.15, { TextTransparency = trans })
        end
        local icon = tabLabel:FindFirstChild("Icon")
        if icon then
            if icon:IsA("ImageLabel") then
                Tween(icon, 0.15, { ImageTransparency = trans })
            elseif icon:IsA("TextLabel") then
                Tween(icon, 0.15, { TextTransparency = trans })
            end
        end
    end
    local sel = btn:FindFirstChild("TabSelection")
    if sel then sel.Visible = active end
end

AddConn(PageInner.ChildAdded:Connect(function(child)
    if not child:IsA("UIListLayout") and not child:IsA("UIPadding") and not child:IsA("UICanvasGroup") then
        local name = child.Name
        if not name:find("^CoreUi_") and not name:find("^InnerCanvasGroup") then
            table.insert(NativePages, child)
            if CurrentActiveTabType ~= "native" then
                pcall(function() child.Visible = false end)
            end
        end
    end
end))

task.defer(function()
    RefreshNativePagesList()
    ActivateNativeTab(NativeTabs[1])
end)

local function RebuildTabSizes()
    local nativeCount = #NativeTabs
    local customCount = 0
    for _ in next, CustomTabButtons do customCount = customCount + 1 end
    local total = math.max(nativeCount + customCount, 1)
    local share = 1 / total

    for _, nt in next, NativeTabs do
        nt.Size = UDim2.new(share, 0, 1, 0)
        nt.AutomaticSize = Enum.AutomaticSize.None
    end
    for _, btn in next, CustomTabButtons do
        btn.Size = UDim2.new(share, 0, 1, 0)
        btn.AutomaticSize = Enum.AutomaticSize.None
    end
end

local function BuildTabButton(name, title, icon)
    local existing = TabContainer:FindFirstChild(name)
    if existing then existing:Destroy() end

    local resolvedIcon = ResolveIcon(icon)
    CustomTabOrder = CustomTabOrder + 1

    local iconEl
    if resolvedIcon then
        if resolvedIcon:find("^rbxassetid://") or resolvedIcon:find("^rbxthumb://") or resolvedIcon:find("^http") then
            iconEl = New("ImageLabel", {
                Name = "Icon",
                Size = UDim2.fromOffset(24, 24),
                BackgroundTransparency = 1,
                Image = resolvedIcon,
                ImageColor3 = T.Text,
                ImageTransparency = TAB_INACTIVE_TRANS,
                ZIndex = 3,
                LayoutOrder = 1,
            }, { New("UIAspectRatioConstraint", {}) })
        else
            iconEl = New("TextLabel", {
                Name = "Icon",
                Size = UDim2.fromOffset(24, 24),
                BackgroundTransparency = 1,
                Text = resolvedIcon,
                Font = Enum.Font.Unknown,
                TextSize = 8,
                TextScaled = true,
                TextWrapped = true,
                TextColor3 = T.Text,
                TextTransparency = TAB_INACTIVE_TRANS,
                ZIndex = 3,
                LayoutOrder = 1,
            }, { New("UIAspectRatioConstraint", {}) })
        end
    end

    local btn = New("TextButton", {
        Name = name,
        Size = UDim2.new(0.2, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Font = Enum.Font.Legacy,
        TextSize = 8,
        BorderSizePixel = 0,
        ZIndex = 3,
        LayoutOrder = 1000 + CustomTabOrder,
        Selectable = false,
        Parent = TabContainer,
    }, {
        New("ImageLabel", {
            Name = "TabSelection",
            Size = UDim2.new(1, -2, 0, 2),
            Position = UDim2.new(0, 3, 1, -2),
            BackgroundColor3 = T.Indicator,
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
                Padding = UDim.new(0, resolvedIcon and 10 or 0),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            iconEl,
            New("TextLabel", {
                Name = "Title",
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundTransparency = 1,
                Text = title,
                Font = Enum.Font.BuilderSansMedium,
                TextSize = 19,
                TextColor3 = T.Text,
                TextTransparency = TAB_INACTIVE_TRANS,
                ZIndex = 3,
                LayoutOrder = 2,
            }),
        }),
    })

    CustomTabButtons[name] = btn
    btn.MouseButton1Click:Connect(function()
        ActivateCustomTab(name)
    end)

    SetTabAppearance(btn, false)
    RebuildTabSizes()
    return btn
end

local function BuildCustomPage(name)
    local existing = PageInner:FindFirstChild("CoreUi_" .. name)
    if existing then existing:Destroy() end

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
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 11),
            PaddingBottom = UDim.new(0, 20),
        }),
    })

    CustomTabPages[name] = pageFrame
    return pageFrame, pageFrame
end

local function BuildExistingTabPage(tabInfo)
    local pageFrame = PageInner:FindFirstChild(tabInfo.page)
    if not pageFrame then
        pageFrame = PageInner:WaitForChild(tabInfo.page, 12)
    end
    if not pageFrame then return nil, nil end

    for _, child in next, pageFrame:GetChildren() do
        pcall(function() child.Visible = false end)
    end

    AddConn(pageFrame.ChildAdded:Connect(function(child)
        if child.Name ~= "CoreUiScroll" then
            task.defer(function()
                pcall(function() child.Visible = false end)
            end)
        end
    end))

    local scroll = New("ScrollingFrame", {
        Name = "CoreUiScroll",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.ScrollBar,
        ScrollBarImageTransparency = T.ScrollBarT,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = pageFrame,
    }, {
        New("UIListLayout", {
            Name = "Layout",
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDim.new(0, 8),
        }),
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 16),
            PaddingRight = UDim.new(0, 16),
            PaddingTop = UDim.new(0, 14),
            PaddingBottom = UDim.new(0, 20),
        }),
    })

    return pageFrame, scroll
end

local ActiveOverlay = nil

local function CloseActiveOverlay()
    if ActiveOverlay then
        ActiveOverlay:Destroy()
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
    dimmer.MouseButton1Click:Connect(function()
        CloseActiveOverlay()
    end)

    local content = buildFn(dimmer)
    ActiveOverlay = dimmer
    return content, dimmer
end

local function ElemFrame(parent, height)
    return New("ImageButton", {
        Size = UDim2.new(1, 0, 0, height or 50),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(35, 37, 39),
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        BorderSizePixel = 0,
        ZIndex = 2,
        Image = "rbxasset://textures/ui/VR/rectBackgroundWhite.png",
        ImageColor3 = Color3.fromRGB(35, 37, 39),
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(2, 2, 18, 18),
        Parent = parent,
    }, {
        New("UICorner", { CornerRadius = UDim.new(0, 8) }),
    })
end

local function TitleDesc(frame, title, desc, rightPad)
    rightPad = rightPad or 0
    local hasDesc = desc and desc ~= ""

    local titleLabel = New("TextLabel", {
        Name = "TitleLabel",
        Size = UDim2.new(0.4, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = title,
        Font = Enum.Font.BuilderSansMedium,
        TextSize = 17,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
        ZIndex = 3,
        Parent = frame,
    }, {
        New("UIPadding", {
            PaddingTop = UDim.new(0, 10),
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
            TextColor3 = T.SubText,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            ZIndex = 3,
            Parent = frame,
        })
    end

    return titleLabel
end

local function HoverEffect(frame)
    frame.MouseEnter:Connect(function()
        Tween(frame, 0.15, { BackgroundTransparency = T.ElemHoverT })
    end)
    frame.MouseLeave:Connect(function()
        Tween(frame, 0.15, { BackgroundTransparency = T.ElemBgT })
    end)
end

local Elements = {}

function Elements.Button(container, config)
    assert(config.Title, "Button: Title required")
    local frame = ElemFrame(container, 50)
    TitleDesc(frame, config.Title, config.Description)

    local arrowHolder = New("ImageButton", {
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
        Parent = arrowHolder,
    })

    frame.MouseButton1Click:Connect(function()
        SafeCall(config.Callback)
    end)
    arrowHolder.MouseButton1Click:Connect(function()
        SafeCall(config.Callback)
    end)

    return { Frame = frame }
end

function Elements.Toggle(container, idx, config, library)
    assert(config.Title, "Toggle: Title required")
    local frame = ElemFrame(container, 50)
    TitleDesc(frame, config.Title, config.Description)

    local val = not not (config.Default)

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
        BackgroundColor3 = val and T.Accent or T.ToggleOff,
        BackgroundTransparency = 0,
        ZIndex = 3,
        Parent = selector,
    }, { New("UICorner", { CornerRadius = UDim.new(0, 15) }) })

    local circle = New("Frame", {
        Name = "Circle",
        Size = UDim2.fromOffset(22, 22),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, val and 25 or 3, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        ZIndex = 4,
        Parent = track,
    }, { New("UICorner", { CornerRadius = UDim.new(0, 11) }) })

    local toggle = {
        Value = val,
        Type = "Toggle",
        Callback = config.Callback or function() end,
    }

    local function SetValue(v)
        v = not not v
        toggle.Value = v
        Tween(track, 0.18, { BackgroundColor3 = v and T.Accent or T.ToggleOff })
        Tween(circle, 0.18, { Position = UDim2.new(0, v and 25 or 3, 0.5, 0) })
        SafeCall(toggle.Callback, v)
        if toggle.Changed then SafeCall(toggle.Changed, v) end
    end

    toggle.SetValue = SetValue
    toggle.OnChanged = function(self, f) self.Changed = f; f(self.Value) end
    toggle.Destroy = function(self)
        frame:Destroy()
        if library then library.Options[idx] = nil end
    end

    selector.MouseButton1Click:Connect(function()
        SetValue(not toggle.Value)
    end)
    frame.MouseButton1Click:Connect(function()
        SetValue(not toggle.Value)
    end)

    if library then library.Options[idx] = toggle end
    return toggle
end

function Elements.Slider(container, idx, config, library)
    assert(config.Title, "Slider: Title required")
    assert(config.Min ~= nil, "Slider: Min required")
    assert(config.Max ~= nil, "Slider: Max required")
    assert(config.Default ~= nil, "Slider: Default required")

    local rounding = config.Rounding or 1
    local STEPS = 10
    local dragging = false

    local frame = ElemFrame(container, 50)
    TitleDesc(frame, config.Title, config.Description)

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
            Size = UDim2.new(0, 30, 0, 30),
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
            Size = UDim2.new(0, 30, 0, 30),
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
            Size = UDim2.new(1/STEPS, -4, 0, 24),
            Position = UDim2.new((s-1)/STEPS, 2, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Color3.fromRGB(217, 217, 217),
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            Image = "",
            ZIndex = 3,
            Parent = stepsContainer,
        }, {
            New("UICorner", { CornerRadius = UDim.new(0, 8) }),
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
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 5,
        Parent = stepsContainer,
    })

    local slider = {
        Value = config.Default,
        Min = config.Min,
        Max = config.Max,
        Rounding = rounding,
        Type = "Slider",
        Callback = config.Callback or function() end,
    }

    local function UpdateSteps(pct)
        local filled = math.floor(pct * STEPS + 0.5)
        for s = 1, STEPS do
            local active = s <= filled
            stepFrames[s].BackgroundColor3 = active and T.Accent or Color3.fromRGB(217, 217, 217)
            stepFrames[s].BackgroundTransparency = active and 0 or 0.0
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
    slider.Destroy = function(self)
        frame:Destroy()
        if library then library.Options[idx] = nil end
    end

    local stepSize = (config.Max - config.Min) / STEPS
    leftBtn.MouseButton1Click:Connect(function()
        SetValue(slider.Value - stepSize)
    end)
    rightBtn.MouseButton1Click:Connect(function()
        SetValue(slider.Value + stepSize)
    end)

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

    local frame = ElemFrame(container, 50)
    TitleDesc(frame, config.Title, config.Description)

    local dropdown = {
        Values = config.Values,
        Value = config.Default or (not config.Multi and config.Values[1]),
        Multi = config.Multi or false,
        Selected = {},
        Opened = false,
        Type = "Dropdown",
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
        New("UICorner", { CornerRadius = UDim.new(0, 8) }),
        New("UIStroke", {
            Thickness = 1,
            Transparency = 0.8,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
            Color = Color3.fromRGB(255, 255, 255),
        }),
    })

    local displayLabel = New("TextLabel", {
        Name = "DropDownFrameTextLabel",
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Text = (function()
            if config.Multi then return "None"
            elseif dropdown.Value then return tostring(dropdown.Value)
            else return "Select..." end
        end)(),
        Font = Enum.Font.BuilderSansMedium,
        TextSize = 17,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 4,
        Parent = inner,
    })

    local chevron = New("ImageLabel", {
        Name = "DropDownImage",
        Size = UDim2.fromOffset(15, 10),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
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
    dropdown.Destroy = function(self)
        frame:Destroy()
        if library then library.Options[idx] = nil end
    end

    local function OpenList()
        if dropdown.Opened then CloseActiveOverlay(); dropdown.Opened = false; chevron.Rotation = 0; return end
        dropdown.Opened = true
        chevron.Rotation = 180

        local absPos = inner.AbsolutePosition
        local absSize = inner.AbsoluteSize
        local screenH = PageViewClipper.AbsoluteSize.Y

        OpenOverlay(function(dimmer)
            local listHeight = math.min(#dropdown.Values * 32 + 8, 200)
            local openUp = (absPos.Y + absSize.Y + listHeight) > (OverlayRoot.AbsolutePosition.Y + OverlayRoot.AbsoluteSize.Y - 20)
            local listY = openUp and (absPos.Y - listHeight - 2) or (absPos.Y + absSize.Y + 2)

            local list = New("ScrollingFrame", {
                Name = "CoreUiDropList",
                Position = UDim2.fromOffset(absPos.X, listY - OverlayRoot.AbsolutePosition.Y),
                Size = UDim2.fromOffset(absSize.X, listHeight),
                BackgroundColor3 = T.DropBg,
                BackgroundTransparency = T.DropBgT,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = T.ScrollBar,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                BorderSizePixel = 0,
                ZIndex = 22,
                Parent = dimmer,
            }, {
                RoundUICorner(8),
                Stroke(T.Border, T.BorderT, 1),
                New("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2),
                }),
                New("UIPadding", {
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4),
                    PaddingLeft = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4),
                }),
            })

            for i, opt in next, dropdown.Values do
                local isSelected = dropdown.Multi and dropdown.Selected[opt] or dropdown.Value == opt
                local item = New("TextButton", {
                    Name = "Option_" .. i,
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = isSelected and T.Accent or T.ElemBg,
                    BackgroundTransparency = isSelected and 0.7 or 0.96,
                    Text = "",
                    ZIndex = 23,
                    Parent = list,
                }, { RoundUICorner(6) })

                New("TextLabel", {
                    Size = UDim2.new(1, -16, 1, 0),
                    Position = UDim2.fromOffset(10, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(opt),
                    Font = Enum.Font.BuilderSans,
                    TextSize = 13,
                    TextColor3 = isSelected and T.Text or T.SubText,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 24,
                    Parent = item,
                })

                item.MouseButton1Click:Connect(function()
                    SetValue(opt)
                    if not dropdown.Multi then
                        CloseActiveOverlay()
                        dropdown.Opened = false
                        Tween(chevron, 0.15, { Rotation = 0 })
                    else
                        local selColor = dropdown.Selected[opt] and T.Accent or T.ElemBg
                        local selTrans = dropdown.Selected[opt] and 0.7 or 0.96
                        Tween(item, 0.1, { BackgroundColor3 = selColor, BackgroundTransparency = selTrans })
                    end
                end)
            end
            return list
        end)

        ActiveOverlay.AncestryChanged:Connect(function()
            dropdown.Opened = false
            Tween(chevron, 0.15, { Rotation = 0 })
        end)
    end

    inner.MouseButton1Click:Connect(OpenList)
    frame.MouseButton1Click:Connect(OpenList)
    HoverEffect(frame)

    UpdateDisplay()
    if library then library.Options[idx] = dropdown end
    return dropdown
end

function Elements.Input(container, idx, config, library)
    assert(config.Title, "Input: Title required")
    local frame = ElemFrame(container, 50)
    TitleDesc(frame, config.Title, config.Description)

    local input = {
        Value = config.Default or "",
        Numeric = config.Numeric or false,
        Finished = config.Finished or false,
        Type = "Input",
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
        New("UICorner", { CornerRadius = UDim.new(0, 8) }),
        New("UIStroke", {
            Thickness = 1,
            Transparency = 0.8,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
            Color = Color3.fromRGB(255, 255, 255),
        }),
        New("UIPadding", {
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
        }),
    })

    local box = New("TextBox", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = config.Default or "",
        PlaceholderText = config.Placeholder or "",
        PlaceholderColor3 = T.SubText,
        Font = Enum.Font.BuilderSansMedium,
        TextSize = 17,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 4,
        Parent = boxFrame,
    })

    local function SetValue(text)
        if config.MaxLength and #text > config.MaxLength then
            text = text:sub(1, config.MaxLength)
        end
        if input.Numeric and not tonumber(text) and #text > 0 then
            text = input.Value
        end
        input.Value = text
        box.Text = text
        SafeCall(input.Callback, text)
        if input.Changed then SafeCall(input.Changed, text) end
    end

    input.SetValue = SetValue
    input.OnChanged = function(self, f) self.Changed = f; f(self.Value) end
    input.Destroy = function(self)
        frame:Destroy()
        if library then library.Options[idx] = nil end
    end

    if input.Finished then
        box.FocusLost:Connect(function(enter)
            if enter then SetValue(box.Text) end
        end)
    else
        box:GetPropertyChangedSignal("Text"):Connect(function()
            SetValue(box.Text)
        end)
    end

    if library then library.Options[idx] = input end
    return input
end

function Elements.Keybind(container, idx, config, library)
    assert(config.Title, "Keybind: Title required")
    assert(config.Default, "Keybind: Default required")

    local frame = ElemFrame(container, 50)
    TitleDesc(frame, config.Title, config.Description)

    local keybind = {
        Value = config.Default,
        Mode = config.Mode or "Toggle",
        Toggled = false,
        Picking = false,
        Type = "Keybind",
        Callback = config.Callback or function() end,
        ChangedCallback = config.ChangedCallback or function() end,
    }

    local keyLabel = New("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.fromOffset(0, 20),
        BackgroundTransparency = 1,
        Text = config.Default,
        Font = Enum.Font.BuilderSansMedium,
        TextSize = 17,
        TextColor3 = T.Text,
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
        New("UICorner", { CornerRadius = UDim.new(0, 8) }),
        New("UIStroke", {
            Thickness = 1,
            Transparency = 0.8,
            ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
            Color = Color3.fromRGB(255, 255, 255),
        }),
        New("UIListLayout", {
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Center,
        }),
        keyLabel,
    })

    local function SetValue(key, mode)
        keybind.Value = key or keybind.Value
        keybind.Mode = mode or keybind.Mode
        keyLabel.Text = keybind.Value
    end

    keybind.SetValue = SetValue
    keybind.GetState = function()
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
    keybind.DoClick = function()
        SafeCall(keybind.Callback, keybind.Toggled)
        if keybind.Clicked then SafeCall(keybind.Clicked, keybind.Toggled) end
    end
    keybind.OnClick = function(self, f) self.Clicked = f end
    keybind.OnChanged = function(self, f) self.Changed = f; f(self.Value) end
    keybind.Destroy = function(self)
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
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        key = input.KeyCode.Name
                    elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                        key = "MouseLeft"
                    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                        key = "MouseRight"
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
    assert(config.Default, "Colorpicker: Default required")

    local frame = ElemFrame(container, 50)
    TitleDesc(frame, config.Title, config.Description)

    local cp = {
        Value = config.Default,
        Transparency = config.Transparency or 0,
        Type = "Colorpicker",
        Callback = config.Callback or function() end,
    }

    local h, s, v = Color3.toHSV(config.Default)
    cp.Hue, cp.Sat, cp.Vib = h, s, v

    local swatchHolder = New("Frame", {
        Size = UDim2.new(0.6, 0, 0, 50),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = frame,
    })

    local displayBg = New("ImageLabel", {
        Size = UDim2.fromOffset(36, 36),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Image = "http://www.roblox.com/asset/?id=14204231522",
        ImageTransparency = 0.4,
        ScaleType = Enum.ScaleType.Tile,
        TileSize = UDim2.fromOffset(36, 36),
        ZIndex = 3,
        Parent = swatchHolder,
    }, {
        New("UICorner", { CornerRadius = UDim.new(0, 8) }),
    })

    local displayColor = New("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = cp.Value,
        ZIndex = 4,
        Parent = displayBg,
    }, {
        New("UICorner", { CornerRadius = UDim.new(0, 8) }),
    })

    local function SetValue(color, trans)
        cp.Value = color
        if trans then cp.Transparency = trans end
        h, s, v = Color3.toHSV(color)
        cp.Hue, cp.Sat, cp.Vib = h, s, v
        displayColor.BackgroundColor3 = color
        SafeCall(cp.Callback, color, cp.Transparency)
        if cp.Changed then SafeCall(cp.Changed, color, cp.Transparency) end
    end

    cp.SetValue = SetValue
    cp.SetValueRGB = SetValue
    cp.OnChanged = function(self, f) self.Changed = f; f(self.Value, self.Transparency) end
    cp.Destroy = function(self)
        frame:Destroy()
        if library then library.Options[idx] = nil end
    end

    local function OpenPicker()
        OpenOverlay(function(dimmer)
            local absPos = displayBg.AbsolutePosition
            local panelW, panelH = 280, 220

            local panel = New("Frame", {
                Name = "CoreUiColorPanel",
                Position = UDim2.fromOffset(
                    math.clamp(absPos.X - panelW + 30, 0, OverlayRoot.AbsoluteSize.X - panelW),
                    math.clamp(absPos.Y - panelH - 4, 0, OverlayRoot.AbsoluteSize.Y - panelH)
                ),
                Size = UDim2.fromOffset(panelW, panelH),
                BackgroundColor3 = T.DropBg,
                BackgroundTransparency = 0.04,
                ZIndex = 22,
                Parent = dimmer,
            }, {
                RoundUICorner(10),
                Stroke(T.Border, T.BorderT, 1),
                New("UIPadding", {
                    PaddingTop = UDim.new(0, 8),
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 8),
                    PaddingBottom = UDim.new(0, 8),
                }),
            })

            local svAreaH = 140
            local svArea = New("ImageLabel", {
                Name = "SVArea",
                Size = UDim2.new(1, 0, 0, svAreaH),
                Position = UDim2.fromOffset(0, 0),
                BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                ZIndex = 23,
                Parent = panel,
            }, { RoundUICorner(6) })

            local whiteFade = New("ImageLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                Image = "rbxasset://textures/ui/Slider/SliderBar.png",
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                ZIndex = 24,
                Parent = svArea,
            })

            local blackFade = New("ImageLabel", {
                Size = UDim2.new(1, 0, 1, 0),
                Image = "rbxasset://textures/ui/Slider/SliderBarInverted.png",
                ImageColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 0,
                ZIndex = 25,
                Parent = svArea,
            })

            local svDot = New("Frame", {
                Size = UDim2.fromOffset(12, 12),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(s, 0, 1 - v, 0),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                ZIndex = 26,
                Parent = svArea,
            }, {
                RoundUICorner(10),
                Stroke(Color3.fromRGB(0, 0, 0), 0.4, 2),
            })

            local hueBarH = 16
            local hueBar = New("ImageLabel", {
                Name = "HueBar",
                Size = UDim2.new(1, 0, 0, hueBarH),
                Position = UDim2.fromOffset(0, svAreaH + 8),
                Image = "rbxasset://textures/ui/Settings/MenuBarAssets/MenuButton.png",
                ZIndex = 23,
                Parent = panel,
            }, { RoundUICorner(6) })

            for i = 0, 9 do
                New("Frame", {
                    Size = UDim2.new(0.1, 0, 1, 0),
                    Position = UDim2.new(i * 0.1, 0, 0, 0),
                    BackgroundColor3 = Color3.fromHSV(i / 10, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 24,
                    Parent = hueBar,
                })
            end

            local hueDot = New("Frame", {
                Size = UDim2.fromOffset(6, hueBarH),
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(h, 0, 0, 0),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                ZIndex = 25,
                Parent = hueBar,
            }, { RoundUICorner(3), Stroke(Color3.fromRGB(0, 0, 0), 0.5, 1) })

            local hexLabel = New("TextLabel", {
                Position = UDim2.fromOffset(0, svAreaH + 8 + hueBarH + 8),
                Size = UDim2.new(0.4, 0, 0, 22),
                BackgroundColor3 = T.InputBg,
                BackgroundTransparency = T.InputBgT,
                Text = "#" .. cp.Value:ToHex():upper(),
                Font = Enum.Font.BuilderSans,
                TextSize = 12,
                TextColor3 = T.Text,
                ZIndex = 23,
                Parent = panel,
            }, { RoundUICorner(5) })

            local function UpdateColor()
                local newH = cp.Hue
                local newS = cp.Sat
                local newV = cp.Vib
                local color = Color3.fromHSV(newH, newS, newV)
                svArea.BackgroundColor3 = Color3.fromHSV(newH, 1, 1)
                svDot.Position = UDim2.new(newS, 0, 1 - newV, 0)
                hueDot.Position = UDim2.new(newH, 0, 0, 0)
                hexLabel.Text = "#" .. color:ToHex():upper()
                SetValue(color)
            end

            local svDrag, hueDrag = false, false

            svArea.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    svDrag = true
                    local ax, ay = svArea.AbsolutePosition.X, svArea.AbsolutePosition.Y
                    local aw, ah = svArea.AbsoluteSize.X, svArea.AbsoluteSize.Y
                    cp.Sat = math.clamp((inp.Position.X - ax) / aw, 0, 1)
                    cp.Vib = 1 - math.clamp((inp.Position.Y - ay) / ah, 0, 1)
                    UpdateColor()
                end
            end)
            svArea.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then svDrag = false end
            end)

            hueBar.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                    hueDrag = true
                    cp.Hue = math.clamp((inp.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                    UpdateColor()
                end
            end)
            hueBar.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 then hueDrag = false end
            end)

            AddConn(UserInputService.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement then
                    if svDrag then
                        local ax, ay = svArea.AbsolutePosition.X, svArea.AbsolutePosition.Y
                        local aw, ah = svArea.AbsoluteSize.X, svArea.AbsoluteSize.Y
                        cp.Sat = math.clamp((inp.Position.X - ax) / aw, 0, 1)
                        cp.Vib = 1 - math.clamp((inp.Position.Y - ay) / ah, 0, 1)
                        UpdateColor()
                    elseif hueDrag then
                        cp.Hue = math.clamp((inp.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                        UpdateColor()
                    end
                end
            end))

            return panel
        end)
    end

    displayBg.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then OpenPicker() end
    end)

    if library then library.Options[idx] = cp end
    return cp
end

function Elements.Paragraph(container, config)
    assert(config.Title, "Paragraph: Title required")
    local frame = ElemFrame(container)
    frame.AutoButtonColor = false
    frame.BackgroundTransparency = T.ElemBgT + 0.02

    New("TextLabel", {
        Name = "Title",
        Position = UDim2.fromOffset(12, 10),
        Size = UDim2.new(1, -24, 0, 16),
        BackgroundTransparency = 1,
        Text = config.Title,
        Font = Enum.Font.BuilderSansMedium,
        TextSize = 13,
        TextColor3 = T.SubText,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = frame,
    })

    local body = New("TextLabel", {
        Name = "Body",
        Position = UDim2.fromOffset(12, 28),
        Size = UDim2.new(1, -24, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = config.Content or "",
        Font = Enum.Font.BuilderSans,
        TextSize = 13,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 3,
        Parent = frame,
    })

    local pad = New("Frame", {
        Size = UDim2.fromOffset(0, 10),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = frame,
        Position = UDim2.new(0, 0, 1, 0),
    })

    frame.AutomaticSize = Enum.AutomaticSize.Y

    local para = { Frame = frame }
    para.SetContent = function(self, text)
        body.Text = text
    end
    para.SetTitle = function(self, text)
        frame:FindFirstChild("Title").Text = text
    end
    return para
end

function Elements.Divider(container, config)
    local holder = New("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = container,
    })
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = T.DividerColor,
        BackgroundTransparency = T.DividerT,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = holder,
    })
    return { Frame = holder }
end

function Elements.Section(container, title)
    local holder = New("Frame", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = container,
    })
    New("TextLabel", {
        Size = UDim2.new(1, -6, 1, 0),
        Position = UDim2.fromOffset(6, 0),
        BackgroundTransparency = 1,
        Text = title or "",
        Font = Enum.Font.BuilderSansMedium,
        TextSize = 12,
        TextColor3 = T.SectionLabel,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Bottom,
        ZIndex = 3,
        Parent = holder,
    })
    return holder
end

function Elements.Group(container, config, library)
    local gap = config and config.Gap or 6
    local groupFrame = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ZIndex = 2,
        Parent = container,
    }, {
        New("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Padding = UDim.new(0, gap),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
    })

    local group = { ElementFrame = groupFrame, Elements = {}, __type = "Group" }

    local function Resize()
        local stretchable = {}
        for _, e in next, group.Elements do
            table.insert(stretchable, e)
        end
        local n = #stretchable
        if n == 0 then return end
        local totalGap = gap * (n - 1)
        for i, e in next, stretchable do
            if e.Frame then
                e.Frame.Size = UDim2.new(1 / n, -totalGap / n, 0, e.Frame.AbsoluteSize.Y or 40)
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
        if e.Frame then
            e.Frame.Size = UDim2.new(0.5, -gap / 2, 0, e.Frame.AbsoluteSize.Y or 40)
        end
        table.insert(self.Elements, { Frame = library and library.Options[i] and library.Options[i].Frame })
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
    function target:Button(cfg)
        return Elements.Button(container, cfg)
    end
    function target:Toggle(idx, cfg)
        return Elements.Toggle(container, idx, cfg, library)
    end
    function target:Slider(idx, cfg)
        return Elements.Slider(container, idx, cfg, library)
    end
    function target:Dropdown(idx, cfg)
        return Elements.Dropdown(container, idx, cfg, library)
    end
    function target:Input(idx, cfg)
        return Elements.Input(container, idx, cfg, library)
    end
    function target:Keybind(idx, cfg)
        return Elements.Keybind(container, idx, cfg, library)
    end
    function target:Colorpicker(idx, cfg)
        return Elements.Colorpicker(container, idx, cfg, library)
    end
    function target:Paragraph(cfg)
        return Elements.Paragraph(container, cfg)
    end
    function target:Divider(cfg)
        return Elements.Divider(container, cfg)
    end
    function target:Group(cfg)
        return Elements.Group(container, cfg, library)
    end
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
    local icon = config.Icon

    local pageFrame, scroll

    local existingInfo = ExistingTabMap[section]
    if existingInfo then
        pageFrame, scroll = BuildExistingTabPage(existingInfo)
        if not scroll then
            warn("[CoreUi] Could not find page for tab: " .. section)
            return {}
        end
    else
        BuildTabButton(section, title, icon)
        pageFrame, scroll = BuildCustomPage(section)
        local isFirst = true
        for n in next, CustomTabPages do
            if n ~= section then isFirst = false; break end
        end
        if isFirst then
            ActivateCustomTab(section)
        end
    end

    local container = scroll
    local tab = {}
    BindMethods(tab, container, self)

    tab._scroll = scroll
    tab._page = pageFrame
    tab._section = section
    tab.IsCustom = not existingInfo

    return tab
end

CoreUi.SaveManager = {} do
    local SM = CoreUi.SaveManager
    SM.Folder = "CoreUiSettings"
    SM.Ignore = {}
    SM.Options = CoreUi.Options

    local Parser = {
        Toggle = {
            Save = function(idx, o) return { type = "Toggle", idx = idx, value = o.Value } end,
            Load = function(idx, d)
                if SM.Options[idx] then SM.Options[idx]:SetValue(d.value) end
            end,
        },
        Slider = {
            Save = function(idx, o) return { type = "Slider", idx = idx, value = tostring(o.Value) } end,
            Load = function(idx, d)
                if SM.Options[idx] then SM.Options[idx]:SetValue(tonumber(d.value)) end
            end,
        },
        Dropdown = {
            Save = function(idx, o) return { type = "Dropdown", idx = idx, value = o.Value, multi = o.Multi } end,
            Load = function(idx, d)
                if SM.Options[idx] then SM.Options[idx]:SetValue(d.value) end
            end,
        },
        Colorpicker = {
            Save = function(idx, o) return { type = "Colorpicker", idx = idx, value = o.Value:ToHex(), transparency = o.Transparency } end,
            Load = function(idx, d)
                if SM.Options[idx] then SM.Options[idx]:SetValueRGB(Color3.fromHex(d.value), d.transparency) end
            end,
        },
        Keybind = {
            Save = function(idx, o) return { type = "Keybind", idx = idx, mode = o.Mode, key = o.Value } end,
            Load = function(idx, d)
                if SM.Options[idx] then SM.Options[idx]:SetValue(d.key, d.mode) end
            end,
        },
        Input = {
            Save = function(idx, o) return { type = "Input", idx = idx, text = o.Value } end,
            Load = function(idx, d)
                if SM.Options[idx] and type(d.text) == "string" then SM.Options[idx]:SetValue(d.text) end
            end,
        },
    }

    function SM:SetOptions(opts)
        self.Options = opts
    end

    function SM:SetFolder(folder)
        self.Folder = folder
        self:BuildFolderTree()
    end

    function SM:SetIgnoreIndexes(list)
        for _, k in next, list do self.Ignore[k] = true end
    end

    function SM:BuildFolderTree()
        local parts = self.Folder:split("/")
        for i = 1, #parts do
            local path = table.concat(parts, "/", 1, i)
            if not isfolder(path) then makefolder(path) end
        end
        if not isfolder(self.Folder .. "/configs") then makefolder(self.Folder .. "/configs") end
    end

    function SM:Save(name)
        self:BuildFolderTree()
        local data = {}
        for idx, obj in next, self.Options do
            if not self.Ignore[idx] and obj.Type and Parser[obj.Type] then
                data[idx] = Parser[obj.Type].Save(idx, obj)
            end
        end
        local path = self.Folder .. "/configs/" .. name .. ".json"
        writefile(path, HttpServiceI:JSONEncode(data))
    end

    function SM:Load(name)
        local path = self.Folder .. "/configs/" .. name .. ".json"
        if not isfile(path) then warn("[CoreUi] Config not found: " .. name); return end
        local ok, data = pcall(function()
            return HttpServiceI:JSONDecode(readfile(path))
        end)
        if not ok or type(data) ~= "table" then warn("[CoreUi] Failed to load config: " .. name); return end
        for idx, d in next, data do
            if Parser[d.type] then Parser[d.type].Load(idx, d) end
        end
    end

    function SM:GetConfigList()
        self:BuildFolderTree()
        local list = {}
        for _, f in next, listfiles(self.Folder .. "/configs") do
            local name = f:match("([^/\\]+)%.json$")
            if name then table.insert(list, name) end
        end
        return list
    end

    function SM:Delete(name)
        local path = self.Folder .. "/configs/" .. name .. ".json"
        if isfile(path) then delfile(path) end
    end
end

CoreUi.InterfaceManager = {} do
    local IM = CoreUi.InterfaceManager
    IM.Folder = "CoreUiSettings"
    IM.Settings = {
        MenuKeybind = "LeftControl",
        Theme = "Dark",
        WindowFont = "BuilderSansMedium",
        WindowTransparency = 0,
        AccentColor = "0,162,255",
    }

    local Themes = {
        Dark = {
            Text = Color3.fromRGB(255, 255, 255),
            SubText = Color3.fromRGB(175, 175, 192),
            Accent = Color3.fromRGB(0, 162, 255),
            AccentDark = Color3.fromRGB(0, 120, 200),
            ElemBg = Color3.fromRGB(255, 255, 255),
            ElemBgT = 0.93,
            ElemHoverT = 0.88,
            Border = Color3.fromRGB(255, 255, 255),
            BorderT = 0.84,
            Indicator = Color3.fromRGB(255, 255, 255),
            ToggleOff = Color3.fromRGB(100, 100, 122),
            SliderRail = Color3.fromRGB(210, 210, 230),
            SliderRailT = 0.65,
            SectionLabel = Color3.fromRGB(185, 185, 205),
            DividerColor = Color3.fromRGB(255, 255, 255),
            DividerT = 0.87,
            DropBg = Color3.fromRGB(30, 30, 44),
            DropBgT = 0.04,
            InputBg = Color3.fromRGB(255, 255, 255),
            InputBgT = 0.88,
            KeyBg = Color3.fromRGB(255, 255, 255),
            KeyBgT = 0.88,
            ScrollBar = Color3.fromRGB(255, 255, 255),
            ScrollBarT = 0.7,
        },
        Light = {
            Text = Color3.fromRGB(20, 20, 30),
            SubText = Color3.fromRGB(80, 80, 100),
            Accent = Color3.fromRGB(0, 120, 220),
            AccentDark = Color3.fromRGB(0, 90, 180),
            ElemBg = Color3.fromRGB(0, 0, 0),
            ElemBgT = 0.92,
            ElemHoverT = 0.85,
            Border = Color3.fromRGB(0, 0, 0),
            BorderT = 0.82,
            Indicator = Color3.fromRGB(0, 0, 0),
            ToggleOff = Color3.fromRGB(160, 160, 180),
            SliderRail = Color3.fromRGB(100, 100, 120),
            SliderRailT = 0.7,
            SectionLabel = Color3.fromRGB(80, 80, 110),
            DividerColor = Color3.fromRGB(0, 0, 0),
            DividerT = 0.85,
            DropBg = Color3.fromRGB(230, 230, 245),
            DropBgT = 0.04,
            InputBg = Color3.fromRGB(0, 0, 0),
            InputBgT = 0.88,
            KeyBg = Color3.fromRGB(0, 0, 0),
            KeyBgT = 0.88,
            ScrollBar = Color3.fromRGB(0, 0, 0),
            ScrollBarT = 0.7,
        },
        Midnight = {
            Text = Color3.fromRGB(200, 200, 220),
            SubText = Color3.fromRGB(130, 130, 160),
            Accent = Color3.fromRGB(130, 80, 255),
            AccentDark = Color3.fromRGB(100, 55, 210),
            ElemBg = Color3.fromRGB(255, 255, 255),
            ElemBgT = 0.95,
            ElemHoverT = 0.9,
            Border = Color3.fromRGB(255, 255, 255),
            BorderT = 0.86,
            Indicator = Color3.fromRGB(130, 80, 255),
            ToggleOff = Color3.fromRGB(70, 70, 95),
            SliderRail = Color3.fromRGB(160, 160, 200),
            SliderRailT = 0.7,
            SectionLabel = Color3.fromRGB(140, 140, 170),
            DividerColor = Color3.fromRGB(255, 255, 255),
            DividerT = 0.88,
            DropBg = Color3.fromRGB(20, 18, 40),
            DropBgT = 0.04,
            InputBg = Color3.fromRGB(255, 255, 255),
            InputBgT = 0.9,
            KeyBg = Color3.fromRGB(255, 255, 255),
            KeyBgT = 0.9,
            ScrollBar = Color3.fromRGB(130, 80, 255),
            ScrollBarT = 0.5,
        },
    }

    local FontMap = {
        BuilderSansMedium = Enum.Font.BuilderSansMedium,
        GothamMedium = Enum.Font.GothamMedium,
        Gotham = Enum.Font.Gotham,
        SourceSans = Enum.Font.SourceSans,
        SourceSansBold = Enum.Font.SourceSansBold,
        Roboto = Enum.Font.Roboto,
        RobotoMono = Enum.Font.RobotoMono,
    }

    IM.Themes = Themes
    IM.FontMap = FontMap

    function IM:SetFolder(folder)
        self.Folder = folder
        if not isfolder(folder) then makefolder(folder) end
    end

    function IM:SaveSettings()
        writefile(self.Folder .. "/interface.json", HttpServiceI:JSONEncode(self.Settings))
    end

    function IM:LoadSettings()
        local path = self.Folder .. "/interface.json"
        if isfile(path) then
            local ok, data = pcall(function() return HttpServiceI:JSONDecode(readfile(path)) end)
            if ok and type(data) == "table" then
                for k, v in next, data do self.Settings[k] = v end
            end
        end
    end

    function IM:ApplyTheme(themeName)
        local theme = Themes[themeName]
        if not theme then return end
        self.Settings.Theme = themeName
        local T = CoreUi._T
        for k, v in next, theme do
            T[k] = v
        end
    end

    function IM:ApplyAccent(r, g, b)
        local T = CoreUi._T
        T.Accent = Color3.fromRGB(r, g, b)
        T.AccentDark = Color3.fromRGB(math.floor(r*0.75), math.floor(g*0.75), math.floor(b*0.75))
        self.Settings.AccentColor = r .. "," .. g .. "," .. b
    end

    function IM:ApplyFont(fontName)
        local f = FontMap[fontName]
        if not f then return end
        self.Settings.WindowFont = fontName
    end

    function IM:ApplyTransparency(val)
        val = math.clamp(val, 0, 0.95)
        local T = CoreUi._T
        self.Settings.WindowTransparency = val
        T.ElemBgT = 0.93 + val * 0.07
        T.BorderT = 0.84 + val * 0.1
        T.InputBgT = 0.88 + val * 0.08
        T.DropBgT = 0.04 + val * 0.2
    end

    function IM:ApplyAll()
        self:ApplyTheme(self.Settings.Theme or "Dark")
        self:ApplyFont(self.Settings.WindowFont or "BuilderSansMedium")
        self:ApplyTransparency(self.Settings.WindowTransparency or 0)
        local acc = self.Settings.AccentColor
        if acc and acc:find(",") then
            local parts = acc:split(",")
            self:ApplyAccent(tonumber(parts[1]) or 0, tonumber(parts[2]) or 162, tonumber(parts[3]) or 255)
        end
    end
end

function CoreUi:BuildManagerTab(section, config)
    config = config or {}
    local tab = self:Tab(section, { Title = config.Title or "Manager" })
    local SM = self.SaveManager
    local IM = self.InterfaceManager

    IM:LoadSettings()
    IM:ApplyAll()
    SM.Options = self.Options

    do
        tab:AddSection("Save Manager")

        local configName = tab:Input("_CoreUi_ConfigName", {
            Title = "Config Name",
            Placeholder = "my_config",
        })

        local configList = {}
        if SM.GetConfigList then
            configList = SM:GetConfigList()
        end

        if #configList > 0 then
            tab:Dropdown("_CoreUi_ConfigList", {
                Title = "Saved Configs",
                Values = configList,
                Default = configList[1],
                Callback = function(val)
                    if self.Options["_CoreUi_ConfigName"] then
                        self.Options["_CoreUi_ConfigName"]:SetValue(val)
                    end
                end,
            })
        end

        local grpSave = tab:Group({ Gap = 6 })

        grpSave:Button({
            Title = "Save",
            Callback = function()
                local name = self.Options["_CoreUi_ConfigName"] and self.Options["_CoreUi_ConfigName"].Value or ""
                if name == "" then name = "default" end
                SM:Save(name)
            end,
        })

        grpSave:Button({
            Title = "Load",
            Callback = function()
                local name = self.Options["_CoreUi_ConfigName"] and self.Options["_CoreUi_ConfigName"].Value or ""
                if name == "" then name = "default" end
                SM:Load(name)
            end,
        })

        grpSave:Button({
            Title = "Delete",
            Callback = function()
                local name = self.Options["_CoreUi_ConfigName"] and self.Options["_CoreUi_ConfigName"].Value or ""
                if name ~= "" then SM:Delete(name) end
            end,
        })
    end

    do
        tab:AddSection("Interface")

        local menuBind = tab:Keybind("_CoreUi_MenuBind", {
            Title = "Menu Keybind",
            Default = IM.Settings.MenuKeybind,
        })
        menuBind:OnChanged(function()
            IM.Settings.MenuKeybind = menuBind.Value
            IM:SaveSettings()
        end)

        tab:Dropdown("_CoreUi_Theme", {
            Title = "Theme",
            Values = { "Dark", "Light", "Midnight" },
            Default = IM.Settings.Theme or "Dark",
            Callback = function(val)
                IM:ApplyTheme(val)
                IM:SaveSettings()
            end,
        })

        local fontNames = {}
        for k in next, IM.FontMap do table.insert(fontNames, k) end
        table.sort(fontNames)

        tab:Dropdown("_CoreUi_Font", {
            Title = "Window Font",
            Values = fontNames,
            Default = IM.Settings.WindowFont or "BuilderSansMedium",
            Callback = function(val)
                IM:ApplyFont(val)
                IM:SaveSettings()
            end,
        })

        tab:Slider("_CoreUi_Transparency", {
            Title = "Window Transparency",
            Min = 0,
            Max = 0.95,
            Default = IM.Settings.WindowTransparency or 0,
            Rounding = 2,
            Callback = function(val)
                IM:ApplyTransparency(val)
                IM:SaveSettings()
            end,
        })

        tab:Colorpicker("_CoreUi_Accent", {
            Title = "Accent Color",
            Default = T.Accent,
            Callback = function(color)
                IM:ApplyAccent(
                    math.floor(color.R * 255),
                    math.floor(color.G * 255),
                    math.floor(color.B * 255)
                )
                IM:SaveSettings()
            end,
        })
    end

    return tab
end

function CoreUi:Unload()
    for _, conn in next, self.Connections do
        pcall(function() conn:Disconnect() end)
    end
    self.Connections = {}

    CloseActiveOverlay()
    ShowNativePages()

    for name, page in next, CustomTabPages do
        pcall(function() page:Destroy() end)
    end
    for name, btn in next, CustomTabButtons do
        pcall(function() btn:Destroy() end)
    end

    CustomTabPages = {}
    CustomTabButtons = {}
    CustomTabOrder = 0

    for _, nt in next, NativeTabs do
        pcall(function()
            nt.Size = UDim2.new(0.2, 0, 1, 0)
            nt.AutomaticSize = Enum.AutomaticSize.None
            local tabLabel = nt:FindFirstChild("TabLabel")
            if tabLabel then
                local title = tabLabel:FindFirstChild("Title")
                if title then title.TextTransparency = 0 end
                local icon = tabLabel:FindFirstChild("Icon")
                if icon then
                    if icon:IsA("ImageLabel") then icon.ImageTransparency = 0
                    elseif icon:IsA("TextLabel") then icon.TextTransparency = 0 end
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
                if nt.Name == customStartPage then
                    ActivateNativeTab(nt)
                    break
                end
            end
        end
    end
end

function Api:ToggleVisibility()
    MenuContainer.Visible = not MenuContainer.Visible
end

function Api:GetVisibility()
    return MenuContainer.Visible
end

function Api:SwitchToPage(pageName, ignoreStack)
    if CustomTabPages[pageName] then
        ActivateCustomTab(pageName)
    else
        for _, nt in next, NativeTabs do
            if nt.Name == pageName then
                ActivateNativeTab(nt)
                break
            end
        end
    end
end

function Api:GetCurrentTab()
    return CurrentActiveTabType, CurrentActiveTabName
end

Api.Instance = CoreUi

if VRHub and VRHub.RegisterModule then
    local moduleApiTable = {}
    moduleApiTable.ModuleName = "CoreUi"
    moduleApiTable.KeepVRTopbarOpen = true
    moduleApiTable.VRIsExclusive = true
    moduleApiTable.VRClosesNonExclusive = true
    VRHub:RegisterModule(moduleApiTable)

    VRHub.ModuleOpened.Event:connect(function(moduleName)
        if moduleName ~= moduleApiTable.ModuleName then
            local module = VRHub:GetModule(moduleName)
            if module.VRIsExclusive then
                moduleApiTable:SetVisibility(false)
            end
        end
    end)

    function moduleApiTable:SetVisibility(visible, noAnimation, customStartPage, switchedFromGamepadInput)
        Api:SetVisibility(visible, noAnimation, customStartPage)
    end

    function moduleApiTable:ToggleVisibility(switchedFromGamepadInput)
        Api:ToggleVisibility()
    end

    function moduleApiTable:SwitchToPage(pageToSwitchTo, ignoreStack)
        Api:SwitchToPage(pageToSwitchTo, ignoreStack)
    end

    function moduleApiTable:GetVisibility()
        return Api:GetVisibility()
    end

    function moduleApiTable:ShowShield()
        Shield.Visible = true
    end

    function moduleApiTable:HideShield()
        Shield.Visible = false
    end

    moduleApiTable.SettingsShowSignal = MenuContainer:GetPropertyChangedSignal("Visible")
    moduleApiTable.Instance = CoreUi

    CoreUi.VRModule = moduleApiTable
end

CoreUi.Api = Api

return CoreUi