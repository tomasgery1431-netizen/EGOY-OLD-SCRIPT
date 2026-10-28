--[[
    ZONE V1 — UI ONLY
    Original standalone interface scaffold.
    UI BY: ZONE

    This file intentionally contains no game automation, item stealing,
    anti-cheat bypass, integrity spoofing, remote abuse, or movement exploits.
    Feature toggles are UI state only until connected to authorized game logic.

    Run as a LocalScript in Roblox Studio. Config file persistence is enabled
    only in environments that provide readfile/writefile/isfile; otherwise
    Save/Load uses the current session and reports that limitation.
]]

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
if not player then
    warn("[ZONE V1] This UI must run on the client.")
    return
end

local CONFIG_DIR = "ZONE"
local CONFIG_PATH = CONFIG_DIR .. "/config.json"

local Theme = {
    Background = Color3.fromRGB(13, 16, 24),
    Panel = Color3.fromRGB(21, 25, 36),
    PanelAlt = Color3.fromRGB(28, 33, 47),
    Border = Color3.fromRGB(48, 57, 77),
    Accent = Color3.fromRGB(111, 92, 255),
    AccentSoft = Color3.fromRGB(55, 47, 108),
    Text = Color3.fromRGB(241, 244, 255),
    Muted = Color3.fromRGB(151, 161, 184),
    Good = Color3.fromRGB(79, 201, 145),
    Warn = Color3.fromRGB(255, 190, 92),
    Bad = Color3.fromRGB(255, 105, 125),
}

local RARITIES = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret" }

local Config = {
    Version = 1,
    Toggles = {
        AutoFarm = false,
        AutoSell = false,
        Notifications = true,
        CompactMode = false,
    },
    Rarities = {
        Common = false,
        Uncommon = false,
        Rare = true,
        Epic = true,
        Legendary = true,
        Mythic = true,
        Secret = true,
    },
}

local featureDescriptions = {
    AutoFarm = "UI placeholder — connect only to game logic you own or are authorized to use.",
    AutoSell = "UI placeholder — connect only to game logic you own or are authorized to use.",
    Notifications = "Show or hide local interface notifications.",
    CompactMode = "Reduce spacing in the interface.",
}

local function make(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

local function corner(parent, radius)
    make("UICorner", { CornerRadius = UDim.new(0, radius or 10) }, parent)
end

local function stroke(parent, color, thickness)
    make("UIStroke", {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        Transparency = 0.15,
    }, parent)
end

local function pad(parent, amount)
    make("UIPadding", {
        PaddingTop = UDim.new(0, amount),
        PaddingBottom = UDim.new(0, amount),
        PaddingLeft = UDim.new(0, amount),
        PaddingRight = UDim.new(0, amount),
    }, parent)
end

local gui = make("ScreenGui", {
    Name = "ZONE_V1_UI",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, player:WaitForChild("PlayerGui"))

local root = make("Frame", {
    Name = "Window",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(780, 500),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
}, gui)
corner(root, 16)
stroke(root, Theme.Border, 1)

local scale = make("UIScale", { Scale = 1 }, root)
local function updateScale()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    scale.Scale = math.clamp(math.min(viewport.X / 900, viewport.Y / 620), 0.65, 1)
end
updateScale()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

local top = make("Frame", {
    Name = "Topbar",
    Size = UDim2.new(1, 0, 0, 66),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
}, root)
corner(top, 16)
make("Frame", {
    Position = UDim2.new(0, 0, 1, -16),
    Size = UDim2.new(1, 0, 0, 16),
    BackgroundColor3 = Theme.Panel,
    BorderSizePixel = 0,
}, top)

local logo = make("Frame", {
    Position = UDim2.fromOffset(18, 14),
    Size = UDim2.fromOffset(38, 38),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
}, top)
corner(logo, 11)
make("TextLabel", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    Font = Enum.Font.GothamBlack,
    Text = "Z",
    TextSize = 23,
    TextColor3 = Color3.new(1, 1, 1),
}, logo)

make("TextLabel", {
    Position = UDim2.fromOffset(68, 13),
    Size = UDim2.fromOffset(260, 25),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "ZONE V1",
    TextSize = 19,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = Theme.Text,
}, top)
make("TextLabel", {
    Position = UDim2.fromOffset(69, 37),
    Size = UDim2.fromOffset(290, 16),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "UI BY: ZONE  •  CONFIGURABLE INTERFACE",
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = Theme.Muted,
}, top)

local status = make("TextLabel", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -56, 0.5, 0),
    Size = UDim2.fromOffset(180, 26),
    BackgroundColor3 = Color3.fromRGB(27, 54, 48),
    Text = "●  UI READY",
    Font = Enum.Font.GothamSemibold,
    TextSize = 10,
    TextColor3 = Theme.Good,
    BorderSizePixel = 0,
}, top)
corner(status, 8)

local close = make("TextButton", {
    Name = "Close",
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -15, 0.5, 0),
    Size = UDim2.fromOffset(27, 27),
    BackgroundColor3 = Color3.fromRGB(61, 38, 52),
    Text = "×",
    Font = Enum.Font.GothamBold,
    TextSize = 19,
    TextColor3 = Theme.Bad,
    BorderSizePixel = 0,
}, top)
corner(close, 8)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

local sidebar = make("Frame", {
    Position = UDim2.fromOffset(14, 80),
    Size = UDim2.new(0, 166, 1, -96),
    BackgroundTransparency = 1,
}, root)
local navLayout = make("UIListLayout", {
    Padding = UDim.new(0, 7),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, sidebar)

local content = make("Frame", {
    Position = UDim2.fromOffset(194, 82),
    Size = UDim2.new(1, -210, 1, -98),
    BackgroundTransparency = 1,
}, root)

local pages = {}
local navButtons = {}
local currentPage = nil
local toggleRenderers = {}
local rarityRenderers = {}
local function setStatus(message, good)
    status.Text = "●  " .. message
    status.TextColor3 = good == false and Theme.Warn or Theme.Good
    status.BackgroundColor3 = good == false and Color3.fromRGB(62, 48, 30) or Color3.fromRGB(27, 54, 48)
end

local function createPage(name)
    local page = make("ScrollingFrame", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, content)
    make("UIListLayout", {
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, page)
    pad(page, 2)
    pages[name] = page
    return page
end

local function showPage(name)
    currentPage = name
    for pageName, page in pairs(pages) do page.Visible = pageName == name end
    for pageName, button in pairs(navButtons) do
        local selected = pageName == name
        button.BackgroundColor3 = selected and Theme.AccentSoft or Theme.Panel
        button.TextColor3 = selected and Theme.Text or Theme.Muted
    end
end

local function addNav(name, iconText, order)
    local button = make("TextButton", {
        Name = name .. "Nav",
        LayoutOrder = order,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Panel,
        Text = "   " .. iconText .. "    " .. name,
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme.Muted,
        BorderSizePixel = 0,
        AutoButtonColor = false,
    }, sidebar)
    corner(button, 9)
    button.MouseButton1Click:Connect(function() showPage(name) end)
    navButtons[name] = button
end

local function heading(parent, title, subtitle)
    local wrap = make("Frame", {
        Size = UDim2.new(1, -4, 0, subtitle and 55 or 32),
        BackgroundTransparency = 1,
    }, parent)
    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 27),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextSize = 20,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme.Text,
    }, wrap)
    if subtitle then
        make("TextLabel", {
            Position = UDim2.fromOffset(1, 29),
            Size = UDim2.new(1, -5, 0, 22),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = subtitle,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Theme.Muted,
        }, wrap)
    end
    return wrap
end

local function section(parent, title, description)
    local box = make("Frame", {
        Size = UDim2.new(1, -4, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Panel,
        BorderSizePixel = 0,
    }, parent)
    corner(box, 12)
    stroke(box, Theme.Border, 1)
    pad(box, 14)
    make("UIListLayout", {
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, box)
    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme.Text,
        LayoutOrder = 1,
    }, box)
    if description then
        make("TextLabel", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = description,
            TextWrapped = true,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Theme.Muted,
            LayoutOrder = 2,
        }, box)
    end
    return box
end

local function addToggle(parent, label, key, description, order)
    local row = make("Frame", {
        LayoutOrder = order or 10,
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Theme.PanelAlt,
        BorderSizePixel = 0,
    }, parent)
    corner(row, 9)
    local title = make("TextLabel", {
        Position = UDim2.fromOffset(11, 5),
        Size = UDim2.new(1, -76, 0, 19),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Text = label,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme.Text,
    }, row)
    if description then
        make("TextLabel", {
            Position = UDim2.fromOffset(11, 25),
            Size = UDim2.new(1, -80, 0, 15),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = description,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Theme.Muted,
        }, row)
    end
    local toggle = make("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(43, 23),
        BackgroundColor3 = Config.Toggles[key] and Theme.Accent or Theme.Border,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
    }, row)
    corner(toggle, 12)
    local knob = make("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = Config.Toggles[key] and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(17, 17),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
    }, toggle)
    corner(knob, 10)
    local function render()
        local enabled = Config.Toggles[key] == true
        TweenService:Create(toggle, TweenInfo.new(0.12), {
            BackgroundColor3 = enabled and Theme.Accent or Theme.Border,
        }):Play()
        TweenService:Create(knob, TweenInfo.new(0.12), {
            Position = enabled and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        }):Play()
    end
    toggleRenderers[key] = render
    toggle.MouseButton1Click:Connect(function()
        Config.Toggles[key] = not Config.Toggles[key]
        render()
        if key == "CompactMode" then
            setStatus("SETTING UPDATED", true)
        elseif key == "Notifications" then
            setStatus(Config.Toggles[key] and "NOTIFICATIONS ON" or "NOTIFICATIONS OFF", true)
        else
            setStatus("UI STATE UPDATED", true)
        end
    end)
    return row
end

local function addRarity(parent, rarity, order)
    local row = make("TextButton", {
        LayoutOrder = order,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme.PanelAlt,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
    }, parent)
    corner(row, 8)
    local dot = make("Frame", {
        Position = UDim2.fromOffset(10, 13),
        Size = UDim2.fromOffset(10, 10),
        BackgroundColor3 = Config.Rarities[rarity] and Theme.Accent or Theme.Border,
        BorderSizePixel = 0,
    }, row)
    corner(dot, 5)
    make("TextLabel", {
        Position = UDim2.fromOffset(29, 0),
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamSemibold,
        Text = rarity,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme.Text,
    }, row)
    local function render()
        dot.BackgroundColor3 = Config.Rarities[rarity] and Theme.Accent or Theme.Border
        row.BackgroundColor3 = Config.Rarities[rarity] and Theme.AccentSoft or Theme.PanelAlt
    end
    render()
    rarityRenderers[rarity] = render
    row.MouseButton1Click:Connect(function()
        Config.Rarities[rarity] = not Config.Rarities[rarity]
        render()
        setStatus("RARITY FILTER UPDATED", true)
    end)
    return row
end

addNav("Dashboard", "◈", 1)
addNav("Features", "◉", 2)
addNav("Rarity Filter", "◇", 3)
addNav("Config", "⚙", 4)

local dashboard = createPage("Dashboard")
heading(dashboard, "Dashboard", "Welcome to ZONE V1. Your interface is ready.")
local overview = section(dashboard, "Workspace overview", "A clean control center for your local UI preferences.")
local stats = make("Frame", {
    LayoutOrder = 3,
    Size = UDim2.new(1, 0, 0, 72),
    BackgroundTransparency = 1,
}, overview)
local statsLayout = make("UIGridLayout", {
    CellSize = UDim2.new(0.32, 0, 1, 0),
    CellPadding = UDim2.new(0.02, 0, 0, 0),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, stats)
for i, item in ipairs({{"VERSION", "V1.0"}, {"FILTERS", tostring(#RARITIES)}, {"STATUS", "READY"}}) do
    local tile = make("Frame", {
        LayoutOrder = i,
        BackgroundColor3 = Theme.PanelAlt,
        BorderSizePixel = 0,
    }, stats)
    corner(tile, 9)
    make("TextLabel", {
        Position = UDim2.fromOffset(8, 10),
        Size = UDim2.new(1, -16, 0, 15),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = item[1],
        TextSize = 9,
        TextColor3 = Theme.Muted,
    }, tile)
    make("TextLabel", {
        Position = UDim2.fromOffset(8, 30),
        Size = UDim2.new(1, -16, 0, 25),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = item[2],
        TextSize = 16,
        TextColor3 = Theme.Text,
    }, tile)
end
local note = section(dashboard, "Feature status", "This package is a UI scaffold, not a game automation script.")
make("TextLabel", {
    LayoutOrder = 3,
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "Feature switches and rarity selections are functional UI state. They do not control or exploit a game.",
    TextWrapped = true,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = Theme.Muted,
}, note)

local features = createPage("Features")
heading(features, "Features", "Local interface settings and safe placeholders.")
local featureBox = section(features, "Feature controls", "Automation labels are placeholders and are not connected to game actions.")
addToggle(featureBox, "Auto Farm", "AutoFarm", featureDescriptions.AutoFarm, 3)
addToggle(featureBox, "Auto Sell", "AutoSell", featureDescriptions.AutoSell, 4)
addToggle(featureBox, "Notifications", "Notifications", featureDescriptions.Notifications, 5)
addToggle(featureBox, "Compact Mode", "CompactMode", featureDescriptions.CompactMode, 6)

local rarityPage = createPage("Rarity Filter")
heading(rarityPage, "Rarity Filter", "Click a rarity to include or exclude it from your saved filter.")
local rarityBox = section(rarityPage, "Allowed rarities", "Selected rarities are highlighted. These selections are configuration only.")
for i, rarity in ipairs(RARITIES) do addRarity(rarityBox, rarity, i + 2) end
local rarityActions = make("Frame", {
    LayoutOrder = 2,
    Size = UDim2.new(1, -4, 0, 38),
    BackgroundTransparency = 1,
}, rarityPage)
local function smallButton(parent, text, x, width, callback)
    local b = make("TextButton", {
        Position = UDim2.new(0, x, 0, 0),
        Size = UDim2.new(0, width, 0, 34),
        BackgroundColor3 = Theme.PanelAlt,
        Text = text,
        Font = Enum.Font.GothamSemibold,
        TextSize = 10,
        TextColor3 = Theme.Text,
        BorderSizePixel = 0,
    }, parent)
    corner(b, 8)
    b.MouseButton1Click:Connect(callback)
    return b
end
smallButton(rarityActions, "SELECT ALL", 0, 105, function()
    for _, rarity in ipairs(RARITIES) do Config.Rarities[rarity] = true end
    for _, rarity in ipairs(RARITIES) do
        if rarityRenderers[rarity] then rarityRenderers[rarity]() end
    end
    setStatus("ALL RARITIES SELECTED", true)
end)
smallButton(rarityActions, "CLEAR ALL", 114, 105, function()
    for _, rarity in ipairs(RARITIES) do Config.Rarities[rarity] = false end
    for _, rarity in ipairs(RARITIES) do
        if rarityRenderers[rarity] then rarityRenderers[rarity]() end
    end
    setStatus("RARITY FILTER CLEARED", true)
end)

local configPage = createPage("Config")
heading(configPage, "Configuration", "Save your preferences or restore a saved configuration.")
local configBox = section(configPage, "Config manager", "Uses a JSON config file when the runtime supports file APIs.")
local configInfo = make("TextLabel", {
    LayoutOrder = 3,
    Size = UDim2.new(1, 0, 0, 42),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "Path: " .. CONFIG_PATH .. "\nRoblox Studio LocalScripts do not have arbitrary file access.",
    TextWrapped = true,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextColor3 = Theme.Muted,
}, configBox)

local function fileApi(name)
    local fn = rawget(_G, name)
    if type(fn) == "function" then return fn end
    return nil
end

local function saveConfig()
    local payload = HttpService:JSONEncode(Config)
    local makefolderFn = fileApi("makefolder")
    local isfolderFn = fileApi("isfolder")
    local writefileFn = fileApi("writefile")
    if not writefileFn then
        setStatus("FILE SAVE UNSUPPORTED", false)
        configInfo.Text = "File save is unavailable in this runtime. Your settings remain active for this session."
        return
    end
    pcall(function()
        if makefolderFn and (not isfolderFn or not isfolderFn(CONFIG_DIR)) then
            makefolderFn(CONFIG_DIR)
        end
        writefileFn(CONFIG_PATH, payload)
    end)
    local isfileFn = fileApi("isfile")
    if isfileFn and isfileFn(CONFIG_PATH) then
        setStatus("CONFIG SAVED", true)
        configInfo.Text = "Saved to: " .. CONFIG_PATH
    else
        setStatus("SAVE FAILED", false)
        configInfo.Text = "Could not verify the config file. Check your runtime's file API permissions."
    end
end

local function applyLoadedConfig(data)
    if type(data) ~= "table" then error("Invalid config data") end
    if type(data.Toggles) == "table" then
        for key in pairs(Config.Toggles) do
            if type(data.Toggles[key]) == "boolean" then Config.Toggles[key] = data.Toggles[key] end
        end
    end
    if type(data.Rarities) == "table" then
        for _, rarity in ipairs(RARITIES) do
            if type(data.Rarities[rarity]) == "boolean" then
                Config.Rarities[rarity] = data.Rarities[rarity]
            end
        end
    end
    -- Refresh every visible control so loaded values match the saved state.
    for _, render in pairs(toggleRenderers) do render() end
    for _, render in pairs(rarityRenderers) do render() end
    setStatus("CONFIG LOADED", true)
    configInfo.Text = "Configuration loaded from: " .. CONFIG_PATH
end

local function loadConfig()
    local readfileFn = fileApi("readfile")
    local isfileFn = fileApi("isfile")
    if not readfileFn or (isfileFn and not isfileFn(CONFIG_PATH)) then
        setStatus("CONFIG NOT FOUND", false)
        configInfo.Text = "No readable config file found. Save a config first or use a runtime with file APIs."
        return
    end
    local ok, result = pcall(function()
        return HttpService:JSONDecode(readfileFn(CONFIG_PATH))
    end)
    if not ok then
        setStatus("CONFIG INVALID", false)
        configInfo.Text = "The config file could not be parsed as JSON."
        return
    end
    local applied, err = pcall(applyLoadedConfig, result)
    if not applied then
        setStatus("CONFIG INVALID", false)
        configInfo.Text = tostring(err)
    end
end

smallButton(configBox, "SAVE CONFIG", 0, 120, saveConfig)
smallButton(configBox, "LOAD CONFIG", 130, 120, loadConfig)
smallButton(configBox, "RESET DEFAULTS", 260, 130, function()
    Config.Toggles = { AutoFarm = false, AutoSell = false, Notifications = true, CompactMode = false }
    Config.Rarities = { Common = false, Uncommon = false, Rare = true, Epic = true, Legendary = true, Mythic = true, Secret = true }
    for _, render in pairs(toggleRenderers) do render() end
    for _, render in pairs(rarityRenderers) do render() end
    setStatus("DEFAULTS RESET", true)
    configInfo.Text = "Defaults reset in memory. Save the config to persist these settings."
end)

-- Drag the window from the top bar.
do
    local dragging, dragInput, dragStart, startPos
    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = root.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    top.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

showPage("Dashboard")
setStatus("UI READY", true)
print("[ZONE V1] UI loaded. UI BY: ZONE.")
