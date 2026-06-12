local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer

local baseZIndex = 300
local buttonImage = "rbxasset://textures/ui/Settings/MenuBarAssets/MenuButton.png"
local buttonSelectedImage = "rbxasset://textures/ui/Settings/MenuBarAssets/MenuButtonSelected.png"
local tabBarImage = "rbxasset://textures/ui/Settings/MenuBarAssets/MenuBackground.png"
local tabSelectionImage = "rbxasset://textures/ui/Settings/MenuBarAssets/MenuSelection.png"
local dropDownImage = "rbxasset://textures/ui/Settings/DropDown/DropDown.png"
local sliderBarLeftImage = "rbxasset://textures/ui/Settings/Slider/BarLeft.png"
local sliderBarRightImage = "rbxasset://textures/ui/Settings/Slider/BarRight.png"
local sliderSelectedLeftImage = "rbxasset://textures/ui/Settings/Slider/SelectedBarLeft.png"
local sliderSelectedRightImage = "rbxasset://textures/ui/Settings/Slider/SelectedBarRight.png"
local dialogWhiteImage = "rbxasset://textures/ui/dialog_white.png"
local checkmarkImage = "rbxasset://textures/ui/Settings/Checkmark.png"
local radioButtonImage = "rbxasset://textures/ui/Settings/RadioButton.png"
local radioButtonSelectedImage = "rbxasset://textures/ui/Settings/RadioButtonSelected.png"
local closeButtonImage = "rbxasset://textures/ui/Settings/MenuBarAssets/MenuButton.png"
local discordIconImage = "rbxasset://textures/ui/Settings/MenuBarIcons/HelpTab.png"
local reportIconImage = "rbxasset://textures/ui/Settings/MenuBarIcons/ReportAbuseTab.png"

local lucideIcons = {}
pcall(function()
        local iconModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/StyearX/Icons/refs/heads/main/lucide/dist/Icons.lua"))()
        if type(iconModule) == "table" then
                lucideIcons = iconModule
        end
end)

local function getIcon(name)
        return lucideIcons[name] or ""
end

local function create(class, props)
        local obj = Instance.new(class)
        for k, v in pairs(props or {}) do
                obj[k] = v
        end
        return obj
end

local function lerp(a, b, t)
        return a + (b - a) * t
end

local function lerpColor(a, b, t)
        return Color3.new(lerp(a.R, b.R, t), lerp(a.G, b.G, t), lerp(a.B, b.B, t))
end

local function tweenProperty(obj, props, duration, style, direction)
        style = style or Enum.EasingStyle.Quad
        direction = direction or Enum.EasingDirection.Out
        local info = TweenInfo.new(duration or 0.15, style, direction)
        local tween = TweenService:Create(obj, info, props)
        tween:Play()
        return tween
end

local function makeStyledButton(parent, text, size, position, callback)
        local btn = create("ImageButton", {
                Parent = parent,
                Image = buttonImage,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(8, 6, 46, 44),
                ImageColor3 = Color3.fromRGB(10, 10, 10),
                ImageTransparency = 0.35,
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = size,
                Position = position or UDim2.new(0, 0, 0, 0),
                ZIndex = baseZIndex + 4,
        })
        local label = create("TextLabel", {
                Parent = btn,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.SourceSansBold,
                TextSize = 22,
                TextColor3 = Color3.new(1, 1, 1),
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
                Text = text,
                ZIndex = baseZIndex + 5,
        })
        btn.MouseEnter:Connect(function()
                btn.Image = buttonSelectedImage
                btn.ImageTransparency = 0.2
        end)
        btn.MouseLeave:Connect(function()
                btn.Image = buttonImage
                btn.ImageTransparency = 0.35
        end)
        if callback then
                btn.MouseButton1Click:Connect(callback)
        end
        return btn, label
end

local UILibrary = {}
UILibrary.__index = UILibrary

function UILibrary.new(config)
        config = config or {}
        local self = setmetatable({}, UILibrary)

        self.title = config.Title or "Hub"
        self.toggleKey = config.Key or Enum.KeyCode.RightShift
        self.visible = false
        self.tabs = {}
        self.currentTab = nil
        self.connections = {}
        self.objects = {}

        for _, existing in pairs(CoreGui:GetChildren()) do
                if existing.Name == "UILibraryScreenGui" then
                        existing:Destroy()
                end
        end

        self.screenGui = create("ScreenGui", {
                Name = "UILibraryScreenGui",
                Parent = CoreGui,
                IgnoreGuiInset = true,
                ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                DisplayOrder = 9000,
                Enabled = false,
                ResetOnSpawn = false,
        })
        table.insert(self.objects, self.screenGui)

        self.overlay = create("Frame", {
                Name = "Overlay",
                Parent = self.screenGui,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Color3.new(0, 0, 0),
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                ZIndex = baseZIndex,
        })

        local sidebarWidth = 60
        local contentWidth = 780
        local totalWidth = sidebarWidth + contentWidth
        local totalHeight = 480

        self.mainFrame = create("Frame", {
                Name = "MainFrame",
                Parent = self.overlay,
                Size = UDim2.new(0, totalWidth, 0, totalHeight),
                Position = UDim2.new(0.5, -totalWidth / 2, 0.5, -totalHeight / 2),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = baseZIndex + 1,
        })

        self.sidebarFrame = create("ImageLabel", {
                Name = "Sidebar",
                Parent = self.mainFrame,
                Image = tabBarImage,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(4, 4, 6, 6),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, sidebarWidth, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                ZIndex = baseZIndex + 2,
        })

        self.sidebarTitle = create("TextLabel", {
                Name = "SidebarTitle",
                Parent = self.sidebarFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 50),
                Position = UDim2.new(0, 0, 0, 0),
                Font = Enum.Font.SourceSansBold,
                TextSize = 11,
                TextColor3 = Color3.new(1, 1, 1),
                TextTransparency = 0.5,
                Text = self.title,
                TextWrapped = true,
                ZIndex = baseZIndex + 3,
        })

        self.sidebarIconList = create("Frame", {
                Name = "IconList",
                Parent = self.sidebarFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, -50),
                Position = UDim2.new(0, 0, 0, 50),
                ZIndex = baseZIndex + 3,
        })

        local iconListLayout = create("UIListLayout", {
                Parent = self.sidebarIconList,
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                Padding = UDim.new(0, 4),
        })

        self.contentFrame = create("ImageLabel", {
                Name = "ContentFrame",
                Parent = self.mainFrame,
                Image = tabBarImage,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(4, 4, 6, 6),
                BackgroundTransparency = 1,
                Size = UDim2.new(0, contentWidth, 1, 0),
                Position = UDim2.new(0, sidebarWidth, 0, 0),
                ZIndex = baseZIndex + 2,
        })

        self.contentHeader = create("Frame", {
                Name = "ContentHeader",
                Parent = self.contentFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 50),
                Position = UDim2.new(0, 0, 0, 0),
                ZIndex = baseZIndex + 3,
        })

        self.contentTitle = create("TextLabel", {
                Name = "ContentTitle",
                Parent = self.contentHeader,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 16, 0, 0),
                Font = Enum.Font.SourceSansBold,
                TextSize = 26,
                TextColor3 = Color3.new(1, 1, 1),
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "",
                ZIndex = baseZIndex + 4,
        })

        local closeBtn, _ = makeStyledButton(
                self.contentHeader,
                "X",
                UDim2.new(0, 44, 0, 36),
                UDim2.new(1, -50, 0.5, -18),
                function()
                        self:SetVisible(false)
                end
        )

        self.dividerLine = create("Frame", {
                Name = "HeaderDivider",
                Parent = self.contentFrame,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 0.85,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -16, 0, 1),
                Position = UDim2.new(0, 8, 0, 50),
                ZIndex = baseZIndex + 3,
        })

        self.pageClipper = create("Frame", {
                Name = "PageClipper",
                Parent = self.contentFrame,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Size = UDim2.new(1, 0, 1, -52),
                Position = UDim2.new(0, 0, 0, 52),
                ZIndex = baseZIndex + 3,
        })

        self.pageView = create("ScrollingFrame", {
                Name = "PageView",
                Parent = self.pageClipper,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 5,
                ScrollBarImageColor3 = Color3.new(1, 1, 1),
                ScrollBarImageTransparency = 0.6,
                ZIndex = baseZIndex + 3,
        })

        local conn = UserInputService.InputBegan:Connect(function(input, processed)
                if processed then return end
                if input.KeyCode == self.toggleKey then
                        self:SetVisible(not self.visible)
                end
        end)
        table.insert(self.connections, conn)

        return self
end

function UILibrary:SetVisible(state)
        self.visible = state
        self.screenGui.Enabled = state
end

function UILibrary:Destroy()
        for _, c in pairs(self.connections) do
                pcall(function() c:Disconnect() end)
        end
        for _, o in pairs(self.objects) do
                pcall(function() o:Destroy() end)
        end
end

function UILibrary:AddTab(name, iconName)
        local tab = {
                name = name,
                iconName = iconName or "",
                sections = {},
                elements = {},
                pageFrame = nil,
                iconButton = nil,
                hub = self,
        }

        local pageFrame = create("Frame", {
                Name = name .. "Page",
                Parent = self.pageView,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                Visible = false,
                ZIndex = baseZIndex + 4,
        })

        local pageLayout = create("UIListLayout", {
                Parent = pageFrame,
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0, 6),
        })

        local pagePadding = create("UIPadding", {
                Parent = pageFrame,
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10),
        })

        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                pageFrame.Size = UDim2.new(1, 0, 0, pageLayout.AbsoluteContentSize.Y + 20)
                if self.currentTab and self.currentTab.pageFrame == pageFrame then
                        self.pageView.CanvasSize = UDim2.new(0, 0, 0, math.max(pageFrame.AbsoluteSize.Y, self.pageClipper.AbsoluteSize.Y))
                end
        end)

        tab.pageFrame = pageFrame
        tab.pageLayout = pageLayout

        local iconSize = 44
        local iconBtn = create("ImageButton", {
                Name = name .. "IconButton",
                Parent = self.sidebarIconList,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, iconSize, 0, iconSize),
                AutoButtonColor = false,
                ZIndex = baseZIndex + 4,
                LayoutOrder = #self.tabs + 1,
        })

        local iconImage = getIcon(iconName or "")
        local iconLabel = create("ImageLabel", {
                Name = "Icon",
                Parent = iconBtn,
                BackgroundTransparency = 1,
                Image = iconImage ~= "" and iconImage or discordIconImage,
                ImageTransparency = 0.5,
                Size = UDim2.new(0, 28, 0, 28),
                Position = UDim2.new(0.5, -14, 0.5, -14),
                ZIndex = baseZIndex + 5,
        })

        local selectionBar = create("Frame", {
                Name = "SelectionBar",
                Parent = iconBtn,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 3, 1, -8),
                Position = UDim2.new(1, -3, 0, 4),
                ZIndex = baseZIndex + 5,
        })

        local tooltip = create("TextLabel", {
                Name = "Tooltip",
                Parent = iconBtn,
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                BackgroundTransparency = 0.1,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 0, 0, 24),
                Position = UDim2.new(1, 6, 0.5, -12),
                Font = Enum.Font.SourceSansBold,
                TextSize = 16,
                TextColor3 = Color3.new(1, 1, 1),
                Text = name,
                ZIndex = baseZIndex + 10,
                Visible = false,
                ClipsDescendants = false,
        })
        create("UIPadding", {
                Parent = tooltip,
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6),
        })
        create("UICorner", {
                Parent = tooltip,
                CornerRadius = UDim.new(0, 4),
        })

        iconBtn.MouseEnter:Connect(function()
                iconLabel.ImageTransparency = 0.1
                tooltip.Visible = true
                local ts = game:GetService("TextService")
                local textSize = ts:GetTextSize(name, 16, Enum.Font.SourceSansBold, Vector2.new(200, 24))
                tooltip.Size = UDim2.new(0, textSize.X + 12, 0, 24)
        end)

        iconBtn.MouseLeave:Connect(function()
                iconLabel.ImageTransparency = 0.5
                tooltip.Visible = false
        end)

        iconBtn.MouseButton1Click:Connect(function()
                self:SwitchToTab(tab)
        end)

        tab.iconButton = iconBtn
        tab.iconLabel = iconLabel
        tab.selectionBar = selectionBar

        table.insert(self.tabs, tab)

        if #self.tabs == 1 then
                self:SwitchToTab(tab)
        end

        local tabObj = setmetatable({}, {__index = tab})

        function tabObj:AddSection(sectionName)
                return self.hub:_addSection(tab, sectionName)
        end

        function tabObj:AddButton(config)
                local defaultSection = self.hub:_getOrCreateDefaultSection(tab)
                return defaultSection:AddButton(config)
        end

        function tabObj:AddToggle(config)
                local defaultSection = self.hub:_getOrCreateDefaultSection(tab)
                return defaultSection:AddToggle(config)
        end

        function tabObj:AddSlider(config)
                local defaultSection = self.hub:_getOrCreateDefaultSection(tab)
                return defaultSection:AddSlider(config)
        end

        function tabObj:AddDropdown(config)
                local defaultSection = self.hub:_getOrCreateDefaultSection(tab)
                return defaultSection:AddDropdown(config)
        end

        function tabObj:AddTextBox(config)
                local defaultSection = self.hub:_getOrCreateDefaultSection(tab)
                return defaultSection:AddTextBox(config)
        end

        function tabObj:AddLabel(config)
                local defaultSection = self.hub:_getOrCreateDefaultSection(tab)
                return defaultSection:AddLabel(config)
        end

        function tabObj:AddDivider()
                local defaultSection = self.hub:_getOrCreateDefaultSection(tab)
                return defaultSection:AddDivider()
        end

        function tabObj:AddSpace(height)
                local defaultSection = self.hub:_getOrCreateDefaultSection(tab)
                return defaultSection:AddSpace(height)
        end

        function tabObj:AddDiscord(config)
                local defaultSection = self.hub:_getOrCreateDefaultSection(tab)
                return defaultSection:AddDiscord(config)
        end

        function tabObj:AddDropdownOutsidePage(config)
                local defaultSection = self.hub:_getOrCreateDefaultSection(tab)
                return defaultSection:AddDropdownOutsidePage(config)
        end

        return tabObj
end

function UILibrary:SwitchToTab(tab)
        for _, t in pairs(self.tabs) do
                if t.pageFrame then
                        t.pageFrame.Visible = false
                end
                if t.iconLabel then
                        t.iconLabel.ImageTransparency = 0.5
                end
                if t.selectionBar then
                        t.selectionBar.BackgroundTransparency = 1
                end
        end

        tab.pageFrame.Visible = true
        tab.iconLabel.ImageTransparency = 0
        tab.selectionBar.BackgroundTransparency = 0
        self.contentTitle.Text = tab.name
        self.currentTab = tab
        self.pageView.CanvasPosition = Vector2.new(0, 0)
        self.pageView.CanvasSize = UDim2.new(0, 0, 0, math.max(tab.pageFrame.AbsoluteSize.Y, self.pageClipper.AbsoluteSize.Y))
end

function UILibrary:_addSection(tab, sectionName)
        local sectionFrame = create("Frame", {
                Name = sectionName .. "Section",
                Parent = tab.pageFrame,
                BackgroundColor3 = Color3.fromRGB(25, 25, 25),
                BackgroundTransparency = 0.3,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 0),
                ZIndex = baseZIndex + 4,
                LayoutOrder = #tab.sections + 1,
        })

        create("UICorner", {
                Parent = sectionFrame,
                CornerRadius = UDim.new(0, 6),
        })

        local sectionHeader = create("Frame", {
                Name = "SectionHeader",
                Parent = sectionFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 32),
                Position = UDim2.new(0, 0, 0, 0),
                ZIndex = baseZIndex + 5,
        })

        local headerLine = create("Frame", {
                Name = "HeaderLine",
                Parent = sectionHeader,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 0.75,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -16, 0, 1),
                Position = UDim2.new(0, 8, 1, -1),
                ZIndex = baseZIndex + 6,
        })

        local headerIconImage = getIcon("layers")
        local headerIcon = create("ImageLabel", {
                Name = "SectionIcon",
                Parent = sectionHeader,
                BackgroundTransparency = 1,
                Image = headerIconImage ~= "" and headerIconImage or "",
                ImageTransparency = 0.3,
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 10, 0.5, -9),
                ZIndex = baseZIndex + 6,
        })

        create("TextLabel", {
                Name = "SectionTitle",
                Parent = sectionHeader,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 32, 0, 0),
                Font = Enum.Font.SourceSansBold,
                TextSize = 18,
                TextColor3 = Color3.new(1, 1, 1),
                TextTransparency = 0.3,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = sectionName,
                ZIndex = baseZIndex + 6,
        })

        local elementsFrame = create("Frame", {
                Name = "Elements",
                Parent = sectionFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 33),
                ZIndex = baseZIndex + 5,
        })

        local elementsLayout = create("UIListLayout", {
                Parent = elementsFrame,
                SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Vertical,
                Padding = UDim.new(0, 0),
        })

        local function updateSectionSize()
                local contentHeight = elementsLayout.AbsoluteContentSize.Y
                elementsFrame.Size = UDim2.new(1, 0, 0, contentHeight)
                sectionFrame.Size = UDim2.new(1, 0, 0, 33 + contentHeight + 6)
        end

        elementsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSectionSize)

        local section = {
                name = sectionName,
                frame = sectionFrame,
                elementsFrame = elementsFrame,
                elementsLayout = elementsLayout,
                hub = self,
                tab = tab,
                orderIndex = 0,
        }

        table.insert(tab.sections, section)

        local sectionMeta = {}

        local function nextOrder()
                section.orderIndex = section.orderIndex + 1
                return section.orderIndex
        end

        function sectionMeta:AddButton(config)
                config = config or {}
                local text = config.Text or "Button"
                local callback = config.Callback or function() end
                local iconName = config.Icon or "mouse-pointer-click"
                local order = nextOrder()

                local row = create("Frame", {
                        Name = "ButtonRow",
                        Parent = elementsFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 46),
                        ZIndex = baseZIndex + 5,
                        LayoutOrder = order,
                })

                local iconImg = getIcon(iconName)
                if iconImg ~= "" then
                        create("ImageLabel", {
                                Name = "Icon",
                                Parent = row,
                                BackgroundTransparency = 1,
                                Image = iconImg,
                                ImageTransparency = 0.2,
                                Size = UDim2.new(0, 20, 0, 20),
                                Position = UDim2.new(0, 12, 0.5, -10),
                                ZIndex = baseZIndex + 6,
                        })
                end

                create("TextLabel", {
                        Name = "Label",
                        Parent = row,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -170, 1, 0),
                        Position = UDim2.new(0, 40, 0, 0),
                        Font = Enum.Font.SourceSans,
                        TextSize = 22,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = text,
                        ZIndex = baseZIndex + 6,
                })

                local btn, _ = makeStyledButton(row, "Execute", UDim2.new(0, 120, 0, 34), UDim2.new(1, -130, 0.5, -17), callback)
                return row
        end

        function sectionMeta:AddToggle(config)
                config = config or {}
                local text = config.Text or "Toggle"
                local default = config.Default or false
                local callback = config.Callback or function() end
                local iconName = config.Icon or "toggle-right"
                local order = nextOrder()
                local toggled = default

                local row = create("Frame", {
                        Name = "ToggleRow",
                        Parent = elementsFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 46),
                        ZIndex = baseZIndex + 5,
                        LayoutOrder = order,
                })

                local iconImg = getIcon(iconName)
                if iconImg ~= "" then
                        create("ImageLabel", {
                                Name = "Icon",
                                Parent = row,
                                BackgroundTransparency = 1,
                                Image = iconImg,
                                ImageTransparency = 0.2,
                                Size = UDim2.new(0, 20, 0, 20),
                                Position = UDim2.new(0, 12, 0.5, -10),
                                ZIndex = baseZIndex + 6,
                        })
                end

                create("TextLabel", {
                        Name = "Label",
                        Parent = row,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -100, 1, 0),
                        Position = UDim2.new(0, 40, 0, 0),
                        Font = Enum.Font.SourceSans,
                        TextSize = 22,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = text,
                        ZIndex = baseZIndex + 6,
                })

                local trackWidth = 50
                local trackHeight = 26
                local knobSize = 20

                local track = create("Frame", {
                        Name = "Track",
                        Parent = row,
                        BackgroundColor3 = toggled and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(80, 80, 80),
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, trackWidth, 0, trackHeight),
                        Position = UDim2.new(1, -(trackWidth + 14), 0.5, -trackHeight / 2),
                        ZIndex = baseZIndex + 6,
                })
                create("UICorner", {Parent = track, CornerRadius = UDim.new(1, 0)})

                local knob = create("Frame", {
                        Name = "Knob",
                        Parent = track,
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, knobSize, 0, knobSize),
                        Position = toggled and UDim2.new(1, -(knobSize + 3), 0.5, -knobSize / 2) or UDim2.new(0, 3, 0.5, -knobSize / 2),
                        ZIndex = baseZIndex + 7,
                })
                create("UICorner", {Parent = knob, CornerRadius = UDim.new(1, 0)})

                local clickBtn = create("TextButton", {
                        Name = "ClickArea",
                        Parent = row,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Text = "",
                        ZIndex = baseZIndex + 8,
                })

                local function setToggle(value)
                        toggled = value
                        tweenProperty(track, {BackgroundColor3 = toggled and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(80, 80, 80)}, 0.15)
                        tweenProperty(knob, {Position = toggled and UDim2.new(1, -(knobSize + 3), 0.5, -knobSize / 2) or UDim2.new(0, 3, 0.5, -knobSize / 2)}, 0.15)
                        callback(toggled)
                end

                clickBtn.MouseButton1Click:Connect(function()
                        setToggle(not toggled)
                end)

                local api = {
                        Set = function(_, value) setToggle(value) end,
                        Get = function() return toggled end,
                }
                return api
        end

        function sectionMeta:AddSlider(config)
                config = config or {}
                local text = config.Text or "Slider"
                local min = config.Min or 0
                local max = config.Max or 100
                local default = config.Default or min
                local callback = config.Callback or function() end
                local iconName = config.Icon or "sliders-horizontal"
                local order = nextOrder()
                local current = math.clamp(default, min, max)

                local row = create("Frame", {
                        Name = "SliderRow",
                        Parent = elementsFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 60),
                        ZIndex = baseZIndex + 5,
                        LayoutOrder = order,
                })

                local iconImg = getIcon(iconName)
                if iconImg ~= "" then
                        create("ImageLabel", {
                                Name = "Icon",
                                Parent = row,
                                BackgroundTransparency = 1,
                                Image = iconImg,
                                ImageTransparency = 0.2,
                                Size = UDim2.new(0, 20, 0, 20),
                                Position = UDim2.new(0, 12, 0, 8),
                                ZIndex = baseZIndex + 6,
                        })
                end

                create("TextLabel", {
                        Name = "Label",
                        Parent = row,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0.6, -40, 0, 28),
                        Position = UDim2.new(0, 40, 0, 4),
                        Font = Enum.Font.SourceSans,
                        TextSize = 22,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = text,
                        ZIndex = baseZIndex + 6,
                })

                local valueLabel = create("TextLabel", {
                        Name = "Value",
                        Parent = row,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0.4, -10, 0, 28),
                        Position = UDim2.new(0.6, 0, 0, 4),
                        Font = Enum.Font.SourceSansBold,
                        TextSize = 20,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Text = tostring(current),
                        ZIndex = baseZIndex + 6,
                })

                local sliderBarHeight = 18
                local sliderY = 34

                local barLeft = create("ImageLabel", {
                        Name = "BarLeft",
                        Parent = row,
                        Image = sliderBarLeftImage,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 6, 0, sliderBarHeight),
                        Position = UDim2.new(0, 12, 0, sliderY),
                        ZIndex = baseZIndex + 6,
                })

                local barRight = create("ImageLabel", {
                        Name = "BarRight",
                        Parent = row,
                        Image = sliderBarRightImage,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 6, 0, sliderBarHeight),
                        Position = UDim2.new(1, -18, 0, sliderY),
                        ZIndex = baseZIndex + 6,
                })

                local barMiddle = create("Frame", {
                        Name = "BarMiddle",
                        Parent = row,
                        BackgroundColor3 = Color3.fromRGB(80, 80, 80),
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, -36, 0, sliderBarHeight),
                        Position = UDim2.new(0, 18, 0, sliderY),
                        ZIndex = baseZIndex + 5,
                })

                local fraction = (current - min) / math.max(1, max - min)

                local filledLeft = create("ImageLabel", {
                        Name = "FilledLeft",
                        Parent = barMiddle,
                        Image = sliderSelectedLeftImage,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 6, 1, 0),
                        Position = UDim2.new(0, 0, 0, 0),
                        ZIndex = baseZIndex + 6,
                })

                local filledMiddle = create("Frame", {
                        Name = "FilledMiddle",
                        Parent = barMiddle,
                        BackgroundColor3 = Color3.fromRGB(0, 162, 255),
                        BorderSizePixel = 0,
                        Size = UDim2.new(fraction, -6, 1, 0),
                        Position = UDim2.new(0, 6, 0, 0),
                        ZIndex = baseZIndex + 6,
                })

                local knob = create("Frame", {
                        Name = "SliderKnob",
                        Parent = barMiddle,
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 14, 0, 14),
                        Position = UDim2.new(fraction, -7, 0.5, -7),
                        ZIndex = baseZIndex + 7,
                })
                create("UICorner", {Parent = knob, CornerRadius = UDim.new(1, 0)})

                local clickArea = create("TextButton", {
                        Name = "ClickArea",
                        Parent = barMiddle,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 10),
                        Position = UDim2.new(0, 0, 0, -5),
                        Text = "",
                        ZIndex = baseZIndex + 8,
                })

                local dragging = false

                local function updateSlider(x)
                        local abs = barMiddle.AbsolutePosition.X
                        local width = barMiddle.AbsoluteSize.X
                        local pct = math.clamp((x - abs) / width, 0, 1)
                        current = math.floor(min + pct * (max - min) + 0.5)
                        pct = (current - min) / math.max(1, max - min)
                        filledMiddle.Size = UDim2.new(pct, -6, 1, 0)
                        knob.Position = UDim2.new(pct, -7, 0.5, -7)
                        valueLabel.Text = tostring(current)
                        callback(current)
                end

                clickArea.MouseButton1Down:Connect(function(x, y)
                        dragging = true
                        updateSlider(x)
                end)

                local moveConn
                moveConn = UserInputService.InputChanged:Connect(function(input)
                        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                                updateSlider(input.Position.X)
                        end
                end)

                UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                dragging = false
                        end
                end)

                local api = {
                        Set = function(_, value)
                                current = math.clamp(value, min, max)
                                local pct = (current - min) / math.max(1, max - min)
                                filledMiddle.Size = UDim2.new(pct, -6, 1, 0)
                                knob.Position = UDim2.new(pct, -7, 0.5, -7)
                                valueLabel.Text = tostring(current)
                        end,
                        Get = function() return current end,
                }
                return api
        end

        function sectionMeta:AddDropdown(config)
                config = config or {}
                local text = config.Text or "Dropdown"
                local options = config.Options or {}
                local default = config.Default or (options[1] or "")
                local callback = config.Callback or function() end
                local iconName = config.Icon or "chevrons-up-down"
                local order = nextOrder()
                local selected = default
                local open = false

                local rowHeight = 46
                local optionHeight = 34

                local row = create("Frame", {
                        Name = "DropdownRow",
                        Parent = elementsFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, rowHeight),
                        ZIndex = baseZIndex + 5,
                        LayoutOrder = order,
                        ClipsDescendants = false,
                })

                local iconImg = getIcon(iconName)
                if iconImg ~= "" then
                        create("ImageLabel", {
                                Name = "Icon",
                                Parent = row,
                                BackgroundTransparency = 1,
                                Image = iconImg,
                                ImageTransparency = 0.2,
                                Size = UDim2.new(0, 20, 0, 20),
                                Position = UDim2.new(0, 12, 0.5, -10),
                                ZIndex = baseZIndex + 6,
                        })
                end

                create("TextLabel", {
                        Name = "Label",
                        Parent = row,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0.4, 0, 1, 0),
                        Position = UDim2.new(0, 40, 0, 0),
                        Font = Enum.Font.SourceSans,
                        TextSize = 22,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = text,
                        ZIndex = baseZIndex + 6,
                })

                local dropBtn = create("ImageButton", {
                        Name = "DropBtn",
                        Parent = row,
                        Image = dropDownImage,
                        ScaleType = Enum.ScaleType.Slice,
                        SliceCenter = Rect.new(5, 5, 55, 25),
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0.55, -10, 0, 34),
                        Position = UDim2.new(0.45, 0, 0.5, -17),
                        ZIndex = baseZIndex + 6,
                        AutoButtonColor = false,
                })

                local selectedLabel = create("TextLabel", {
                        Name = "Selected",
                        Parent = dropBtn,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -30, 1, 0),
                        Position = UDim2.new(0, 8, 0, 0),
                        Font = Enum.Font.SourceSans,
                        TextSize = 20,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = selected,
                        ZIndex = baseZIndex + 7,
                })

                local arrowImg = getIcon("chevron-down")
                create("ImageLabel", {
                        Name = "Arrow",
                        Parent = dropBtn,
                        BackgroundTransparency = 1,
                        Image = arrowImg ~= "" and arrowImg or dropDownImage,
                        ImageTransparency = 0.3,
                        Size = UDim2.new(0, 18, 0, 18),
                        Position = UDim2.new(1, -24, 0.5, -9),
                        ZIndex = baseZIndex + 7,
                })

                local optionsList = create("Frame", {
                        Name = "OptionsList",
                        Parent = row,
                        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                        BackgroundTransparency = 0.05,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0.55, -10, 0, 0),
                        Position = UDim2.new(0.45, 0, 1, 2),
                        ZIndex = baseZIndex + 9,
                        Visible = false,
                        ClipsDescendants = true,
                })
                create("UICorner", {Parent = optionsList, CornerRadius = UDim.new(0, 6)})

                local optionLayout = create("UIListLayout", {
                        Parent = optionsList,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        FillDirection = Enum.FillDirection.Vertical,
                        Padding = UDim.new(0, 0),
                })

                local function closeDropdown()
                        open = false
                        tweenProperty(optionsList, {Size = UDim2.new(0.55, -10, 0, 0)}, 0.1)
                        task.delay(0.1, function()
                                optionsList.Visible = false
                        end)
                end

                local function addOption(opt)
                        local optBtn = create("TextButton", {
                                Name = "Option_" .. opt,
                                Parent = optionsList,
                                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                                BackgroundTransparency = 1,
                                BorderSizePixel = 0,
                                Size = UDim2.new(1, 0, 0, optionHeight),
                                Font = Enum.Font.SourceSans,
                                TextSize = 20,
                                TextColor3 = Color3.new(1, 1, 1),
                                Text = opt,
                                ZIndex = baseZIndex + 10,
                        })
                        optBtn.MouseEnter:Connect(function()
                                optBtn.BackgroundTransparency = 0.7
                        end)
                        optBtn.MouseLeave:Connect(function()
                                optBtn.BackgroundTransparency = 1
                        end)
                        optBtn.MouseButton1Click:Connect(function()
                                selected = opt
                                selectedLabel.Text = opt
                                callback(opt)
                                closeDropdown()
                        end)
                end

                for _, opt in ipairs(options) do
                        addOption(opt)
                end

                dropBtn.MouseButton1Click:Connect(function()
                        if open then
                                closeDropdown()
                        else
                                open = true
                                optionsList.Visible = true
                                local totalH = #options * optionHeight
                                tweenProperty(optionsList, {Size = UDim2.new(0.55, -10, 0, totalH)}, 0.12)
                        end
                end)

                local api = {
                        Set = function(_, value)
                                selected = value
                                selectedLabel.Text = value
                        end,
                        Get = function() return selected end,
                        AddOption = function(_, opt)
                                table.insert(options, opt)
                                addOption(opt)
                        end,
                }
                return api
        end

        function sectionMeta:AddTextBox(config)
                config = config or {}
                local text = config.Text or "Input"
                local placeholder = config.Placeholder or "Type here..."
                local callback = config.Callback or function() end
                local iconName = config.Icon or "pencil"
                local order = nextOrder()

                local row = create("Frame", {
                        Name = "TextBoxRow",
                        Parent = elementsFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 46),
                        ZIndex = baseZIndex + 5,
                        LayoutOrder = order,
                })

                local iconImg = getIcon(iconName)
                if iconImg ~= "" then
                        create("ImageLabel", {
                                Name = "Icon",
                                Parent = row,
                                BackgroundTransparency = 1,
                                Image = iconImg,
                                ImageTransparency = 0.2,
                                Size = UDim2.new(0, 20, 0, 20),
                                Position = UDim2.new(0, 12, 0.5, -10),
                                ZIndex = baseZIndex + 6,
                        })
                end

                create("TextLabel", {
                        Name = "Label",
                        Parent = row,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0.35, -40, 1, 0),
                        Position = UDim2.new(0, 40, 0, 0),
                        Font = Enum.Font.SourceSans,
                        TextSize = 22,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = text,
                        ZIndex = baseZIndex + 6,
                })

                local inputBg = create("Frame", {
                        Name = "InputBg",
                        Parent = row,
                        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                        BackgroundTransparency = 0.3,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0.6, -10, 0, 32),
                        Position = UDim2.new(0.4, 0, 0.5, -16),
                        ZIndex = baseZIndex + 6,
                })
                create("UICorner", {Parent = inputBg, CornerRadius = UDim.new(0, 5)})

                local inputBox = create("TextBox", {
                        Name = "Input",
                        Parent = inputBg,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -12, 1, 0),
                        Position = UDim2.new(0, 6, 0, 0),
                        Font = Enum.Font.SourceSans,
                        TextSize = 20,
                        TextColor3 = Color3.new(1, 1, 1),
                        PlaceholderText = placeholder,
                        PlaceholderColor3 = Color3.fromRGB(180, 180, 180),
                        Text = "",
                        ClearTextOnFocus = false,
                        ZIndex = baseZIndex + 7,
                })

                inputBox.FocusLost:Connect(function(enter)
                        if enter then
                                callback(inputBox.Text)
                        end
                end)

                local api = {
                        Get = function() return inputBox.Text end,
                        Set = function(_, value) inputBox.Text = value end,
                }
                return api
        end

        function sectionMeta:AddLabel(config)
                config = config or {}
                local text = config.Text or ""
                local iconName = config.Icon or "info"
                local order = nextOrder()

                local row = create("Frame", {
                        Name = "LabelRow",
                        Parent = elementsFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 38),
                        ZIndex = baseZIndex + 5,
                        LayoutOrder = order,
                })

                local iconImg = getIcon(iconName)
                if iconImg ~= "" then
                        create("ImageLabel", {
                                Name = "Icon",
                                Parent = row,
                                BackgroundTransparency = 1,
                                Image = iconImg,
                                ImageTransparency = 0.3,
                                Size = UDim2.new(0, 18, 0, 18),
                                Position = UDim2.new(0, 12, 0.5, -9),
                                ZIndex = baseZIndex + 6,
                        })
                end

                local label = create("TextLabel", {
                        Name = "Label",
                        Parent = row,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -40, 1, 0),
                        Position = UDim2.new(0, 38, 0, 0),
                        Font = Enum.Font.SourceSans,
                        TextSize = 20,
                        TextColor3 = Color3.fromRGB(200, 200, 200),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextWrapped = true,
                        Text = text,
                        ZIndex = baseZIndex + 6,
                })

                local api = {
                        Set = function(_, value) label.Text = value end,
                        Get = function() return label.Text end,
                }
                return api
        end

        function sectionMeta:AddDivider()
                local order = nextOrder()

                local row = create("Frame", {
                        Name = "DividerRow",
                        Parent = elementsFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 18),
                        ZIndex = baseZIndex + 5,
                        LayoutOrder = order,
                })

                create("Frame", {
                        Name = "Line",
                        Parent = row,
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BackgroundTransparency = 0.8,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, -20, 0, 1),
                        Position = UDim2.new(0, 10, 0.5, 0),
                        ZIndex = baseZIndex + 6,
                })

                return row
        end

        function sectionMeta:AddSpace(height)
                height = height or 16
                local order = nextOrder()

                local row = create("Frame", {
                        Name = "SpaceRow",
                        Parent = elementsFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, height),
                        ZIndex = baseZIndex + 5,
                        LayoutOrder = order,
                })

                return row
        end

        function sectionMeta:AddDiscord(config)
                config = config or {}
                local inviteCode = config.Invite or ""
                local callback = config.Callback or function() end
                local order = nextOrder()

                local cardHeight = 90

                local card = create("Frame", {
                        Name = "DiscordCard",
                        Parent = elementsFrame,
                        BackgroundColor3 = Color3.fromRGB(30, 33, 36),
                        BackgroundTransparency = 0.05,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, cardHeight),
                        ZIndex = baseZIndex + 5,
                        LayoutOrder = order,
                })
                create("UICorner", {Parent = card, CornerRadius = UDim.new(0, 8)})

                local accentBar = create("Frame", {
                        Name = "AccentBar",
                        Parent = card,
                        BackgroundColor3 = Color3.fromRGB(88, 101, 242),
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 4, 1, 0),
                        Position = UDim2.new(0, 0, 0, 0),
                        ZIndex = baseZIndex + 6,
                })
                create("UICorner", {Parent = accentBar, CornerRadius = UDim.new(0, 4)})

                local serverIconBg = create("Frame", {
                        Name = "ServerIconBg",
                        Parent = card,
                        BackgroundColor3 = Color3.fromRGB(88, 101, 242),
                        BackgroundTransparency = 0.5,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 56, 0, 56),
                        Position = UDim2.new(0, 16, 0.5, -28),
                        ZIndex = baseZIndex + 6,
                })
                create("UICorner", {Parent = serverIconBg, CornerRadius = UDim.new(0, 12)})

                local serverIcon = create("ImageLabel", {
                        Name = "ServerIcon",
                        Parent = serverIconBg,
                        BackgroundTransparency = 1,
                        Image = discordIconImage,
                        ImageColor3 = Color3.fromRGB(88, 101, 242),
                        Size = UDim2.new(1, 0, 1, 0),
                        ZIndex = baseZIndex + 7,
                })
                create("UICorner", {Parent = serverIcon, CornerRadius = UDim.new(0, 12)})

                local infoFrame = create("Frame", {
                        Name = "InfoFrame",
                        Parent = card,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -210, 1, 0),
                        Position = UDim2.new(0, 84, 0, 0),
                        ZIndex = baseZIndex + 6,
                })

                local serverNameLabel = create("TextLabel", {
                        Name = "ServerName",
                        Parent = infoFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 28),
                        Position = UDim2.new(0, 0, 0, 14),
                        Font = Enum.Font.SourceSansBold,
                        TextSize = 22,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = "Loading...",
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        ZIndex = baseZIndex + 7,
                })

                local statsFrame = create("Frame", {
                        Name = "StatsFrame",
                        Parent = infoFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 22),
                        Position = UDim2.new(0, 0, 0, 46),
                        ZIndex = baseZIndex + 6,
                })

                local onlineDot = create("Frame", {
                        Name = "OnlineDot",
                        Parent = statsFrame,
                        BackgroundColor3 = Color3.fromRGB(59, 165, 93),
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 8, 0, 8),
                        Position = UDim2.new(0, 0, 0.5, -4),
                        ZIndex = baseZIndex + 7,
                })
                create("UICorner", {Parent = onlineDot, CornerRadius = UDim.new(1, 0)})

                local onlineLabel = create("TextLabel", {
                        Name = "OnlineLabel",
                        Parent = statsFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 100, 1, 0),
                        Position = UDim2.new(0, 14, 0, 0),
                        Font = Enum.Font.SourceSans,
                        TextSize = 18,
                        TextColor3 = Color3.fromRGB(180, 180, 180),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = "-- Online",
                        ZIndex = baseZIndex + 7,
                })

                local totalDot = create("Frame", {
                        Name = "TotalDot",
                        Parent = statsFrame,
                        BackgroundColor3 = Color3.fromRGB(130, 130, 130),
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 8, 0, 8),
                        Position = UDim2.new(0, 120, 0.5, -4),
                        ZIndex = baseZIndex + 7,
                })
                create("UICorner", {Parent = totalDot, CornerRadius = UDim.new(1, 0)})

                local totalLabel = create("TextLabel", {
                        Name = "TotalLabel",
                        Parent = statsFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 120, 1, 0),
                        Position = UDim2.new(0, 134, 0, 0),
                        Font = Enum.Font.SourceSans,
                        TextSize = 18,
                        TextColor3 = Color3.fromRGB(180, 180, 180),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = "-- Members",
                        ZIndex = baseZIndex + 7,
                })

                local rightFrame = create("Frame", {
                        Name = "RightFrame",
                        Parent = card,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0, 110, 1, 0),
                        Position = UDim2.new(1, -118, 0, 0),
                        ZIndex = baseZIndex + 6,
                })

                local inviteLabel = create("TextLabel", {
                        Name = "InviteCode",
                        Parent = rightFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 20),
                        Position = UDim2.new(0, 0, 0, 14),
                        Font = Enum.Font.SourceSans,
                        TextSize = 15,
                        TextColor3 = Color3.fromRGB(88, 101, 242),
                        TextXAlignment = Enum.TextXAlignment.Center,
                        Text = inviteCode ~= "" and ("discord.gg/" .. inviteCode) or "",
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        ZIndex = baseZIndex + 7,
                })

                local joinBtn, joinLabel = makeStyledButton(
                        rightFrame,
                        "Join Server",
                        UDim2.new(1, -8, 0, 32),
                        UDim2.new(0, 4, 1, -46),
                        function()
                                if inviteCode ~= "" then
                                        pcall(function() setclipboard("https://discord.gg/" .. inviteCode) end)
                                end
                                callback(inviteCode)
                        end
                )
                joinLabel.TextSize = 17

                local HttpService = game:GetService("HttpService")

                local function formatCount(n)
                        if n >= 1000000 then
                                return string.format("%.1fM", n / 1000000)
                        elseif n >= 1000 then
                                return string.format("%.1fK", n / 1000)
                        end
                        return tostring(n)
                end

                task.spawn(function()
                        if inviteCode == "" then
                                serverNameLabel.Text = "No invite set"
                                return
                        end

                        local reqFunc = (syn and syn.request) or (http and http.request) or (http_request) or (request)
                        if not reqFunc then
                                serverNameLabel.Text = "No HTTP access"
                                return
                        end

                        local apiUrl = "https://discord.com/api/v10/invites/" .. inviteCode .. "?with_counts=true&with_expiration=true"

                        local success, result = pcall(function()
                                local res = reqFunc({
                                        Url = apiUrl,
                                        Method = "GET",
                                        Headers = {
                                                ["User-Agent"] = "RobloxBot/1.0",
                                                ["Accept"] = "application/json",
                                        },
                                })
                                if res and res.Body and #res.Body > 2 then
                                        return HttpService:JSONDecode(res.Body)
                                end
                        end)

                        if not success or not result or not result.guild then
                                serverNameLabel.Text = "Failed to load"
                                onlineLabel.Text = "-- Online"
                                totalLabel.Text = "-- Members"
                                return
                        end

                        local guild = result.guild
                        serverNameLabel.Text = guild.name or "Unknown Server"
                        onlineLabel.Text = formatCount(result.approximate_presence_count or 0) .. " Online"
                        totalLabel.Text = formatCount(result.approximate_member_count or 0) .. " Members"

                        if guild.icon and guild.icon ~= "" and guild.id then
                                local iconUrl = "https://cdn.discordapp.com/icons/" .. tostring(guild.id) .. "/" .. guild.icon .. ".png?size=128"
                                local iconSuccess, iconRes = pcall(function()
                                        return reqFunc({
                                                Url = iconUrl,
                                                Method = "GET",
                                                Headers = {
                                                        ["User-Agent"] = "Mozilla/5.0",
                                                        ["Accept"] = "image/png",
                                                },
                                        })
                                end)
                                if iconSuccess and iconRes and iconRes.Body and #iconRes.Body > 100 then
                                        local fileName = "discord_icon_" .. tostring(guild.id) .. ".png"
                                        pcall(function()
                                                writefile(fileName, iconRes.Body)
                                                local asset = getcustomasset(fileName)
                                                if asset and asset ~= "" then
                                                        serverIcon.Image = asset
                                                        serverIcon.ImageColor3 = Color3.new(1, 1, 1)
                                                        serverIconBg.BackgroundTransparency = 1
                                                end
                                        end)
                                end
                        end
                end)

                return card
        end

        function sectionMeta:AddDropdownOutsidePage(config)
                config = config or {}
                local text = config.Text or "Dropdown"
                local options = config.Options or {}
                local default = config.Default or (options[1] or "")
                local callback = config.Callback or function() end
                local iconName = config.Icon or "list"
                local order = nextOrder()
                local selected = default
                local open = false

                local rowHeight = 46
                local optionHeight = 34

                local row = create("Frame", {
                        Name = "DropdownOutsideRow",
                        Parent = elementsFrame,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, rowHeight),
                        ZIndex = baseZIndex + 5,
                        LayoutOrder = order,
                        ClipsDescendants = false,
                })

                local iconImg = getIcon(iconName)
                if iconImg ~= "" then
                        create("ImageLabel", {
                                Name = "Icon",
                                Parent = row,
                                BackgroundTransparency = 1,
                                Image = iconImg,
                                ImageTransparency = 0.2,
                                Size = UDim2.new(0, 20, 0, 20),
                                Position = UDim2.new(0, 12, 0.5, -10),
                                ZIndex = baseZIndex + 6,
                        })
                end

                create("TextLabel", {
                        Name = "Label",
                        Parent = row,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0.4, 0, 1, 0),
                        Position = UDim2.new(0, 40, 0, 0),
                        Font = Enum.Font.SourceSans,
                        TextSize = 22,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = text,
                        ZIndex = baseZIndex + 6,
                })

                local dropBtn = create("ImageButton", {
                        Name = "DropBtn",
                        Parent = row,
                        Image = dropDownImage,
                        ScaleType = Enum.ScaleType.Slice,
                        SliceCenter = Rect.new(5, 5, 55, 25),
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0.55, -10, 0, 34),
                        Position = UDim2.new(0.45, 0, 0.5, -17),
                        ZIndex = baseZIndex + 6,
                        AutoButtonColor = false,
                })

                local selectedLabel = create("TextLabel", {
                        Name = "Selected",
                        Parent = dropBtn,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -30, 1, 0),
                        Position = UDim2.new(0, 8, 0, 0),
                        Font = Enum.Font.SourceSans,
                        TextSize = 20,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = selected,
                        ZIndex = baseZIndex + 7,
                })

                local arrowImg = getIcon("chevron-down")
                create("ImageLabel", {
                        Name = "Arrow",
                        Parent = dropBtn,
                        BackgroundTransparency = 1,
                        Image = arrowImg ~= "" and arrowImg or dropDownImage,
                        ImageTransparency = 0.3,
                        Size = UDim2.new(0, 18, 0, 18),
                        Position = UDim2.new(1, -24, 0.5, -9),
                        ZIndex = baseZIndex + 7,
                })

                local floatingList = create("Frame", {
                        Name = "FloatingOptionsList",
                        Parent = self.screenGui,
                        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                        BackgroundTransparency = 0.05,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 200, 0, 0),
                        ZIndex = baseZIndex + 20,
                        Visible = false,
                        ClipsDescendants = true,
                })
                create("UICorner", {Parent = floatingList, CornerRadius = UDim.new(0, 6)})

                local floatLayout = create("UIListLayout", {
                        Parent = floatingList,
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        FillDirection = Enum.FillDirection.Vertical,
                        Padding = UDim.new(0, 0),
                })

                local function closeFloating()
                        open = false
                        tweenProperty(floatingList, {Size = UDim2.new(0, 200, 0, 0)}, 0.1)
                        task.delay(0.1, function()
                                floatingList.Visible = false
                        end)
                end

                local function addFloatingOption(opt)
                        local optBtn = create("TextButton", {
                                Name = "Option_" .. opt,
                                Parent = floatingList,
                                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                                BackgroundTransparency = 1,
                                BorderSizePixel = 0,
                                Size = UDim2.new(1, 0, 0, optionHeight),
                                Font = Enum.Font.SourceSans,
                                TextSize = 20,
                                TextColor3 = Color3.new(1, 1, 1),
                                Text = opt,
                                ZIndex = baseZIndex + 21,
                        })
                        optBtn.MouseEnter:Connect(function()
                                optBtn.BackgroundTransparency = 0.7
                        end)
                        optBtn.MouseLeave:Connect(function()
                                optBtn.BackgroundTransparency = 1
                        end)
                        optBtn.MouseButton1Click:Connect(function()
                                selected = opt
                                selectedLabel.Text = opt
                                callback(opt)
                                closeFloating()
                        end)
                end

                for _, opt in ipairs(options) do
                        addFloatingOption(opt)
                end

                dropBtn.MouseButton1Click:Connect(function()
                        if open then
                                closeFloating()
                        else
                                open = true
                                local absPos = dropBtn.AbsolutePosition
                                local absSize = dropBtn.AbsoluteSize
                                local totalH = #options * optionHeight
                                floatingList.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 4)
                                floatingList.Size = UDim2.new(0, absSize.X, 0, 0)
                                floatingList.Visible = true
                                tweenProperty(floatingList, {Size = UDim2.new(0, absSize.X, 0, totalH)}, 0.12)
                        end
                end)

                local api = {
                        Set = function(_, value)
                                selected = value
                                selectedLabel.Text = value
                        end,
                        Get = function() return selected end,
                        AddOption = function(_, opt)
                                table.insert(options, opt)
                                addFloatingOption(opt)
                        end,
                }
                return api
        end

        return sectionMeta
end

function UILibrary:_getOrCreateDefaultSection(tab)
        if tab._defaultSection then
                return tab._defaultSection
        end
        local sec = self:_addSection(tab, "General")
        tab._defaultSection = sec
        return sec
end

return UILibrary
