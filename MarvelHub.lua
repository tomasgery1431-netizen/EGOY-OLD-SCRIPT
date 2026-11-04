--[[
	MARVEL HUB  -  animated mobile-size menu (single file, Luau)
	LocalScript / executor-friendly. Returns the Hub table.

	Art slots (optional): paste your own Roblox image asset IDs below.
	  LogoImage   -> shown in the header badge instead of the "M"
	  HeroImages  -> shown as the faded background art instead of the
	                 built-in silhouettes (up to 4 ids)
	Example:  LogoImage = "rbxassetid://123456789"
]]

local CONFIG = {
	Name       = "MARVEL HUB",
	Version    = "v2.0",
	LogoImage  = "",
	HeroImages = {},        -- e.g. { "rbxassetid://1", "rbxassetid://2" }
}

------------------------------------------------------------------ services
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

------------------------------------------------------------------ theme
local C = {
	Red    = Color3.fromRGB(236, 29, 36),
	RedD   = Color3.fromRGB(158, 11, 16),
	Gold   = Color3.fromRGB(246, 195, 67),
	Blue   = Color3.fromRGB(43, 108, 255),
	Panel  = Color3.fromRGB(18, 18, 28),
	Row    = Color3.fromRGB(26, 26, 40),
	Track  = Color3.fromRGB(48, 48, 66),
	Text   = Color3.fromRGB(244, 244, 247),
	Muted  = Color3.fromRGB(154, 154, 174),
	Green  = Color3.fromRGB(52, 210, 123),
}

------------------------------------------------------------------ your hooks
-- Put your own code inside these. They are called with the new state/value.
local Handlers = {
	Toggles = {
		["God Mode"]     = function(on) end,
		["Super Speed"]  = function(on) end,
		["Fly"]          = function(on) end,
		["Auto Aim"]     = function(on) end,
		["Auto Attack"]  = function(on) end,
		["Teleports"]    = function(on) end,
		["Show Players"] = function(on) end,
		["Full Bright"]  = function(on) end,
		["Notifications"]= function(on) end,
		["Anti-AFK"]     = function(on) end,
	},
	Sliders = {
		["Walk Speed"]    = function(v) end,
		["Reach"]         = function(v) end,
		["Field of View"] = function(v)
			local cam = Workspace.CurrentCamera
			if cam then cam.FieldOfView = v end
		end,
	},
	Buttons = {
		["APPLY POWERS"]  = function() end,
		["SAVE LOADOUT"]  = function() end,
		["SAVE POSITION"] = function() end,
		["RESET ALL"]     = function() end,
	},
	Chips = {
		["Shield"] = function() end, ["Hammer"] = function() end,
		["Repulsor"] = function() end, ["Claws"] = function() end,
	},
}

------------------------------------------------------------------ helpers
local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props or {}) do o[k] = v end
	if parent then o.Parent = parent end
	return o
end

local function tw(o, t, props, style, dir)
	local tween = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	tween:Play()
	return tween
end

local function corner(o, r) return new("UICorner", { CornerRadius = UDim.new(0, r) }, o) end
local function stroke(o, color, th, tr)
	return new("UIStroke", { Color = color, Thickness = th or 1, Transparency = tr or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, o)
end
local function gradient(o, a, b, rot)
	return new("UIGradient", { Color = ColorSequence.new(a, b), Rotation = rot or 90 }, o)
end
local function isPress(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end

------------------------------------------------------------------ root gui
local function getParent()
	local ok, ui = pcall(function() return (gethui and gethui()) or game:GetService("CoreGui") end)
	if ok and ui then return ui end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local parent = getParent()
local old = parent:FindFirstChild("MarvelHub")
if old then old:Destroy() end

local Gui = new("ScreenGui", {
	Name = "MarvelHub", ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999,
}, parent)

local view = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
local W = math.clamp(view.X - 24, 280, 360)
local H = math.clamp(view.Y - 40, 420, 640)

local Main = new("CanvasGroup", {
	Name = "Main", AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
	Size = UDim2.fromOffset(W * .85, H * .85), BackgroundColor3 = C.Panel,
	BorderSizePixel = 0, GroupTransparency = 1, ClipsDescendants = true,
}, Gui)
corner(Main, 22)
local mainStroke = stroke(Main, C.Red, 2, .15)

------------------------------------------------------------------ background art
local Bg = new("Frame", { Name = "Bg", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 1 }, Main)

local glow = new("Frame", { Size = UDim2.fromScale(1, .7), Position = UDim2.fromScale(0, .3), BorderSizePixel = 0, BackgroundColor3 = C.Red, ZIndex = 1 }, Bg)
new("UIGradient", {
	Rotation = 90,
	Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, .55) }),
}, glow)
local blue = new("Frame", { Size = UDim2.fromScale(.7, .5), Position = UDim2.fromScale(.4, 0), BorderSizePixel = 0, BackgroundColor3 = C.Blue, ZIndex = 1 }, Bg)
new("UIGradient", {
	Rotation = 200,
	Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, .8), NumberSequenceKeypoint.new(1, 1) }),
}, blue)

local function float(f, delay)
	task.delay(delay, function()
		if f.Parent then
			TweenService:Create(f, TweenInfo.new(3.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{ Position = f.Position - UDim2.fromOffset(0, 14) }):Play()
		end
	end)
end

local function silhouette(x, h, color, kind, delay)
	local w = h * .5
	local f = new("Frame", {
		BackgroundTransparency = 1, AnchorPoint = Vector2.new(.5, 1),
		Position = UDim2.new(x, 0, 1, 14), Size = UDim2.fromOffset(w, h), ZIndex = 2,
	}, Bg)
	local function part(px, py, pw, ph, r, rot, tr)
		local p = new("Frame", {
			AnchorPoint = Vector2.new(.5, 0), Position = UDim2.fromOffset(px, py), Size = UDim2.fromOffset(pw, ph),
			BackgroundColor3 = color, BackgroundTransparency = tr or .8, BorderSizePixel = 0, Rotation = rot or 0, ZIndex = 2,
		}, f)
		corner(p, r)
		return p
	end
	if kind == "cape" then part(w / 2, h * .17, w * 1.05, h * .7, h * .05, 0, .86) end
	part(w / 2, h * .03, h * .11, h * .11, h, 0)                 -- head
	part(w / 2, h * .15, w * .86, h * .36, h * .07)              -- torso
	part(w * .3, h * .5, w * .26, h * .5, h * .03)               -- leg
	part(w * .7, h * .5, w * .26, h * .5, h * .03)               -- leg
	part(w * .05, h * .17, w * .16, h * .34, h * .05, 8)         -- arm
	part(w * .95, h * .17, w * .16, h * .34, h * .05, -8)        -- arm
	if kind == "ears" then
		part(w * .44, h * .015, h * .04, h * .06, 2, -25)
		part(w * .56, h * .015, h * .04, h * .06, 2, 25)
	elseif kind == "core" then
		part(w / 2, h * .26, h * .07, h * .07, h, 0, .3)
	elseif kind == "shield" then
		local s = part(w * .5, h * .3, h * .3, h * .3, h, 0, .86)
		stroke(s, color, 3, .5)
	end
	float(f, delay)
end

if #CONFIG.HeroImages > 0 then
	for i, id in ipairs(CONFIG.HeroImages) do
		if i > 4 then break end
		local img = new("ImageLabel", {
			BackgroundTransparency = 1, Image = id, ImageTransparency = .72, ScaleType = Enum.ScaleType.Fit,
			AnchorPoint = Vector2.new(.5, 1), Position = UDim2.new((i - .5) / 4, 0, 1, 14),
			Size = UDim2.fromScale(.42, .8), ZIndex = 2,
		}, Bg)
		float(img, i * .7)
	end
else
	silhouette(.16, H * .5, C.Red, "core", 0)
	silhouette(.40, H * .62, C.Gold, "cape", .8)
	silhouette(.64, H * .46, C.Blue, "ears", 1.6)
	silhouette(.88, H * .56, C.Red, "shield", 2.4)
end

local scan = new("Frame", { Size = UDim2.new(1, 0, 0, 90), Position = UDim2.new(0, 0, 0, -90), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 3 }, Bg)
new("UIGradient", {
	Rotation = 90,
	Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(.5, .94), NumberSequenceKeypoint.new(1, 1) }),
}, scan)
task.spawn(function()
	while Gui.Parent do
		scan.Position = UDim2.new(0, 0, 0, -90)
		local t = tw(scan, 5, { Position = UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Linear)
		t.Completed:Wait()
	end
end)

new("Frame", {
	Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(10, 10, 16), BackgroundTransparency = .35,
	BorderSizePixel = 0, ZIndex = 4,
}, Bg)

------------------------------------------------------------------ header
local Header = new("Frame", { Size = UDim2.new(1, 0, 0, 68), BackgroundTransparency = 1, ZIndex = 10 }, Main)

local Badge = new("Frame", {
	Position = UDim2.fromOffset(16, 11), Size = UDim2.fromOffset(46, 46), BackgroundColor3 = C.Red, BorderSizePixel = 0, ZIndex = 11, ClipsDescendants = true,
}, Header)
corner(Badge, 10); gradient(Badge, C.Red, C.RedD, 135); stroke(Badge, Color3.new(1, 1, 1), 2, .75)
if CONFIG.LogoImage ~= "" then
	new("ImageLabel", { Size = UDim2.fromScale(.84, .84), Position = UDim2.fromScale(.08, .08), BackgroundTransparency = 1, Image = CONFIG.LogoImage, ZIndex = 12 }, Badge)
else
	new("TextLabel", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "M", Font = Enum.Font.GothamBlack,
		TextSize = 28, TextColor3 = Color3.new(1, 1, 1), ZIndex = 12,
	}, Badge)
end
local sheen = new("Frame", { Size = UDim2.new(0, 14, 1.6, 0), Position = UDim2.new(-.6, 0, -.3, 0), Rotation = 20, BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = .65, BorderSizePixel = 0, ZIndex = 13 }, Badge)
task.spawn(function()
	while Gui.Parent do
		sheen.Position = UDim2.new(-.6, 0, -.3, 0)
		tw(sheen, 1.1, { Position = UDim2.new(1.4, 0, -.3, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut).Completed:Wait()
		task.wait(2.2)
	end
end)

local Title = new("TextLabel", {
	Position = UDim2.fromOffset(74, 10), Size = UDim2.fromOffset(190, 30), BackgroundTransparency = 1,
	Text = CONFIG.Name, Font = Enum.Font.GothamBlack, TextSize = 24, TextXAlignment = Enum.TextXAlignment.Left,
	TextColor3 = Color3.new(1, 1, 1), ZIndex = 11,
}, Header)
local shine = new("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(.5, Color3.fromRGB(255, 150, 153)), ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
	}),
	Offset = Vector2.new(-1, 0),
}, Title)
task.spawn(function()
	while Gui.Parent do
		shine.Offset = Vector2.new(-1, 0)
		tw(shine, 2.6, { Offset = Vector2.new(1, 0) }, Enum.EasingStyle.Linear).Completed:Wait()
		task.wait(.8)
	end
end)

local dot = new("Frame", { Position = UDim2.fromOffset(75, 47), Size = UDim2.fromOffset(8, 8), BackgroundColor3 = C.Green, BorderSizePixel = 0, ZIndex = 11 }, Header)
corner(dot, 8)
task.spawn(function()
	while Gui.Parent do
		tw(dot, .8, { BackgroundTransparency = .6 }, Enum.EasingStyle.Sine).Completed:Wait()
		tw(dot, .8, { BackgroundTransparency = 0 }, Enum.EasingStyle.Sine).Completed:Wait()
	end
end)
new("TextLabel", {
	Position = UDim2.fromOffset(90, 41), Size = UDim2.fromOffset(160, 20), BackgroundTransparency = 1,
	Text = "Connected  -  " .. CONFIG.Version, Font = Enum.Font.Gotham, TextSize = 12,
	TextColor3 = C.Muted, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
}, Header)

local MinBtn = new("TextButton", {
	AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 17), Size = UDim2.fromOffset(34, 34),
	BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = .92, Text = "-", Font = Enum.Font.GothamBold,
	TextSize = 22, TextColor3 = C.Text, AutoButtonColor = false, ZIndex = 12,
}, Header)
corner(MinBtn, 10); stroke(MinBtn, Color3.new(1, 1, 1), 1, .85)

------------------------------------------------------------------ tabs + pages
local Tabs = new("Frame", { Position = UDim2.fromOffset(0, 68), Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, ZIndex = 10 }, Main)
new("Frame", { Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = .9, BorderSizePixel = 0, ZIndex = 10 }, Tabs)
local Underline = new("Frame", { Position = UDim2.new(0, 14, 1, -3), Size = UDim2.new(.25, -28, 0, 3), BackgroundColor3 = C.Red, BorderSizePixel = 0, ZIndex = 12 }, Tabs)
corner(Underline, 3)

local Content = new("Frame", { Position = UDim2.fromOffset(0, 108), Size = UDim2.new(1, 0, 1, -146), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 10 }, Main)

local pages, tabButtons, current = {}, {}, nil

local function newPage(name)
	local p = new("ScrollingFrame", {
		Name = name, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
		ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 10,
	}, Content)
	new("UIPadding", { PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14) }, p)
	new("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, p)
	pages[name] = p
	return p
end

local function showPage(name, idx)
	if current == name then return end
	current = name
	for n, p in pairs(pages) do p.Visible = false end
	local p = pages[name]
	p.Position = UDim2.fromOffset(22, 0)
	p.Visible = true
	tw(p, .3, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Back)
	tw(Underline, .3, { Position = UDim2.new((idx - 1) * .25, 14, 1, -3) }, Enum.EasingStyle.Back)
	for n, b in pairs(tabButtons) do
		tw(b, .2, { TextColor3 = (n == name) and Color3.new(1, 1, 1) or C.Muted })
	end
end

local tabOrder = { { "hero", "HERO" }, { "combat", "COMBAT" }, { "world", "WORLD" }, { "set", "SETTINGS" } }
for i, t in ipairs(tabOrder) do
	local b = new("TextButton", {
		Position = UDim2.fromScale((i - 1) * .25, 0), Size = UDim2.fromScale(.25, 1), BackgroundTransparency = 1,
		Text = t[2], Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = C.Muted, AutoButtonColor = false, ZIndex = 11,
	}, Tabs)
	tabButtons[t[1]] = b
	newPage(t[1])
	b.MouseButton1Click:Connect(function() showPage(t[1], i) end)
end

------------------------------------------------------------------ toast
local Toast = new("TextLabel", {
	AnchorPoint = Vector2.new(.5, 1), Position = UDim2.new(.5, 0, 1, -50), Size = UDim2.fromOffset(190, 32),
	BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1, TextTransparency = 1, Text = "",
	Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = Color3.fromRGB(17, 17, 17), ZIndex = 30,
}, Main)
corner(Toast, 16)
local toastId = 0
local function say(msg)
	toastId += 1
	local id = toastId
	Toast.Text = msg
	Toast.Position = UDim2.new(.5, 0, 1, -40)
	tw(Toast, .25, { BackgroundTransparency = 0, TextTransparency = 0, Position = UDim2.new(.5, 0, 1, -50) }, Enum.EasingStyle.Back)
	task.delay(1.6, function()
		if id == toastId then tw(Toast, .3, { BackgroundTransparency = 1, TextTransparency = 1 }) end
	end)
end

------------------------------------------------------------------ components
local function rowFrame(page, h, order)
	local r = new("Frame", { Size = UDim2.new(1, 0, 0, h), BackgroundColor3 = C.Row, BackgroundTransparency = .2, BorderSizePixel = 0, LayoutOrder = order, ZIndex = 10 }, page)
	corner(r, 14); stroke(r, Color3.new(1, 1, 1), 1, .9)
	return r
end

local order = 0
local function nextOrder() order += 1; return order end

local function iconBox(r, glyph)
	local b = new("Frame", { Position = UDim2.fromOffset(12, 13), Size = UDim2.fromOffset(36, 36), BackgroundColor3 = C.Red, BackgroundTransparency = .84, BorderSizePixel = 0, ZIndex = 11 }, r)
	corner(b, 10)
	new("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = glyph, TextSize = 18, Font = Enum.Font.GothamBold, TextColor3 = C.Red, ZIndex = 12 }, b)
end

local function labels(r, title, sub)
	new("TextLabel", {
		Position = UDim2.fromOffset(60, 12), Size = UDim2.new(1, -130, 0, 20), BackgroundTransparency = 1, Text = title,
		Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = C.Text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
	}, r)
	new("TextLabel", {
		Position = UDim2.fromOffset(60, 32), Size = UDim2.new(1, -130, 0, 18), BackgroundTransparency = 1, Text = sub,
		Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = C.Muted, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
	}, r)
end

local function addToggle(page, glyph, title, sub, default)
	local r = rowFrame(page, 62, nextOrder())
	iconBox(r, glyph); labels(r, title, sub)
	local sw = new("TextButton", {
		AnchorPoint = Vector2.new(1, .5), Position = UDim2.new(1, -14, .5, 0), Size = UDim2.fromOffset(46, 26),
		BackgroundColor3 = default and C.Red or C.Track, Text = "", AutoButtonColor = false, ZIndex = 11,
	}, r)
	corner(sw, 13)
	local knob = new("Frame", {
		Position = default and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3), Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 12,
	}, sw)
	corner(knob, 10)
	local on = default
	local h = Handlers.Toggles[title]
	sw.MouseButton1Click:Connect(function()
		on = not on
		tw(sw, .25, { BackgroundColor3 = on and C.Red or C.Track })
		tw(knob, .3, { Position = on and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3) }, Enum.EasingStyle.Back)
		say(title .. (on and " on" or " off"))
		if h then task.spawn(h, on) end
	end)
	if default and h then task.spawn(h, true) end
end

local function addSlider(page, title, min, max, default)
	local r = rowFrame(page, 74, nextOrder())
	new("TextLabel", {
		Position = UDim2.fromOffset(14, 10), Size = UDim2.new(1, -90, 0, 20), BackgroundTransparency = 1, Text = title,
		Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = C.Text, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
	}, r)
	local val = new("TextLabel", {
		AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 10), Size = UDim2.fromOffset(60, 20), BackgroundTransparency = 1,
		Text = tostring(default), Font = Enum.Font.GothamBlack, TextSize = 15, TextColor3 = C.Gold, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 11,
	}, r)
	local track = new("TextButton", {
		Position = UDim2.new(0, 14, 0, 48), Size = UDim2.new(1, -28, 0, 8), BackgroundColor3 = C.Track, Text = "", AutoButtonColor = false, ZIndex = 11,
	}, r)
	corner(track, 4)
	local a0 = (default - min) / (max - min)
	local fill = new("Frame", { Size = UDim2.fromScale(a0, 1), BackgroundColor3 = C.Red, BorderSizePixel = 0, ZIndex = 12 }, track)
	corner(fill, 4)
	local knob = new("Frame", {
		AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(a0, .5), Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 13,
	}, track)
	corner(knob, 10); stroke(knob, C.Red, 3, 0)

	local h, dragging, value = Handlers.Sliders[title], false, default
	local function setX(x)
		local a = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local v = math.floor(min + (max - min) * a + .5)
		fill.Size = UDim2.fromScale(a, 1)
		knob.Position = UDim2.fromScale(a, .5)
		val.Text = tostring(v)
		if v ~= value then value = v; if h then task.spawn(h, v) end end
	end
	track.InputBegan:Connect(function(i) if isPress(i) then dragging = true; setX(i.Position.X) end end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then setX(i.Position.X) end
	end)
	UserInputService.InputEnded:Connect(function(i) if isPress(i) then dragging = false end end)
end

local function addButton(page, text, alt)
	local b = new("TextButton", {
		Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = alt and C.Row or C.Red, BackgroundTransparency = alt and .2 or 0,
		Text = text, Font = Enum.Font.GothamBlack, TextSize = 15, TextColor3 = Color3.new(1, 1, 1),
		AutoButtonColor = false, ClipsDescendants = true, LayoutOrder = nextOrder(), ZIndex = 10,
	}, page)
	corner(b, 14)
	if alt then stroke(b, Color3.new(1, 1, 1), 1, .85) else gradient(b, C.Red, C.RedD, 135) end
	b.InputBegan:Connect(function(i)
		if not isPress(i) then return end
		local rip = new("Frame", {
			AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromOffset(i.Position.X - b.AbsolutePosition.X, i.Position.Y - b.AbsolutePosition.Y),
			Size = UDim2.fromOffset(8, 8), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = .55, BorderSizePixel = 0, ZIndex = 12,
		}, b)
		corner(rip, 100)
		tw(rip, .55, { Size = UDim2.fromOffset(420, 420), BackgroundTransparency = 1 }).Completed:Connect(function() rip:Destroy() end)
	end)
	local h = Handlers.Buttons[text]
	b.MouseButton1Click:Connect(function()
		say(text:sub(1, 1) .. text:sub(2):lower() .. " done")
		if h then task.spawn(h) end
	end)
end

local function addChips(page, names)
	local grid = new("Frame", { Size = UDim2.new(1, 0, 0, 98), BackgroundTransparency = 1, LayoutOrder = nextOrder(), ZIndex = 10 }, page)
	new("UIGridLayout", { CellSize = UDim2.new(.5, -5, 0, 44), CellPadding = UDim2.fromOffset(10, 10), SortOrder = Enum.SortOrder.LayoutOrder }, grid)
	local all = {}
	local function select(name, btn)
		for _, c in pairs(all) do
			local on = (c.btn == btn)
			tw(c.btn, .25, { BackgroundColor3 = on and C.Red or C.Row, BackgroundTransparency = on and .6 or .2 })
			tw(c.stroke, .25, { Color = on and C.Red or Color3.new(1, 1, 1), Transparency = on and 0 or .9 })
		end
	end
	for i, n in ipairs(names) do
		local btn = new("TextButton", {
			BackgroundColor3 = C.Row, BackgroundTransparency = .2, Text = n, Font = Enum.Font.GothamBold, TextSize = 14,
			TextColor3 = C.Text, AutoButtonColor = false, LayoutOrder = i, ZIndex = 11,
		}, grid)
		corner(btn, 12)
		local s = stroke(btn, Color3.new(1, 1, 1), 1, .9)
		all[i] = { btn = btn, stroke = s }
		btn.MouseButton1Click:Connect(function()
			select(n, btn); say(n .. " equipped")
			local h = Handlers.Chips[n]; if h then task.spawn(h) end
		end)
	end
	select(names[1], all[1].btn)
end

------------------------------------------------------------------ build pages
Handlers.Sliders["Menu Opacity"] = function(v) Main.GroupTransparency = 1 - v / 100 end
order = 0
local hero = pages.hero
addToggle(hero, "S", "God Mode", "Take no damage", false)
addToggle(hero, "Z", "Super Speed", "Move faster", true)
addToggle(hero, "F", "Fly", "Hover and glide", false)
addSlider(hero, "Walk Speed", 16, 120, 60)
addButton(hero, "APPLY POWERS")

order = 0
local combat = pages.combat
addToggle(combat, "A", "Auto Aim", "Lock onto targets", true)
addToggle(combat, "X", "Auto Attack", "Strike nearby enemies", false)
addSlider(combat, "Reach", 5, 60, 25)
addChips(combat, { "Shield", "Hammer", "Repulsor", "Claws" })
addButton(combat, "SAVE LOADOUT")

order = 0
local world = pages.world
addToggle(world, "T", "Teleports", "Jump to saved places", false)
addToggle(world, "P", "Show Players", "Mark everyone on screen", true)
addToggle(world, "B", "Full Bright", "Remove darkness", false)
addSlider(world, "Field of View", 40, 120, 70)
addButton(world, "SAVE POSITION", true)

order = 0
local set = pages.set
addToggle(set, "N", "Notifications", "Alert when actions finish", true)
addToggle(set, "K", "Anti-AFK", "Stay connected", true)
addSlider(set, "Menu Opacity", 40, 100, 100)
addButton(set, "RESET ALL", true)

------------------------------------------------------------------ footer
local Footer = new("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Color3.fromRGB(10, 10, 16), BackgroundTransparency = .3, BorderSizePixel = 0, ZIndex = 20 }, Main)
new("TextLabel", { Position = UDim2.fromOffset(16, 0), Size = UDim2.new(.5, 0, 1, 0), BackgroundTransparency = 1, Text = CONFIG.Name, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = C.Muted, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 21 }, Footer)
new("TextLabel", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 0), Size = UDim2.new(.5, 0, 1, 0), BackgroundTransparency = 1, Text = "Drag the top to move", Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = C.Muted, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 21 }, Footer)

------------------------------------------------------------------ open / minimize
local Fab = new("TextButton", {
	AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -20, 1, -90), Size = UDim2.fromOffset(0, 0),
	BackgroundColor3 = C.Red, Text = "M", Font = Enum.Font.GothamBlack, TextSize = 28, TextColor3 = Color3.new(1, 1, 1),
	AutoButtonColor = false, Visible = false, ZIndex = 50,
}, Gui)
corner(Fab, 16); gradient(Fab, C.Red, C.RedD, 135)
local fabStroke = stroke(Fab, Color3.new(1, 1, 1), 2, .5)
TweenService:Create(fabStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Transparency = 1 }):Play()

local isOpen = false
local function openMenu()
	isOpen = true
	tw(Fab, .2, { Size = UDim2.fromOffset(0, 0) }).Completed:Connect(function() if isOpen then Fab.Visible = false end end)
	Main.Visible = true
	tw(Main, .55, { Size = UDim2.fromOffset(W, H), GroupTransparency = 0 }, Enum.EasingStyle.Back)
end
local function closeMenu()
	isOpen = false
	tw(Main, .3, { Size = UDim2.fromOffset(W * .5, H * .5), GroupTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In).Completed:Connect(function()
		if not isOpen then Main.Visible = false end
	end)
	Fab.Visible = true
	tw(Fab, .45, { Size = UDim2.fromOffset(58, 58) }, Enum.EasingStyle.Back)
end
MinBtn.MouseButton1Click:Connect(closeMenu)
Fab.MouseButton1Click:Connect(openMenu)

------------------------------------------------------------------ drag (header)
do
	local dragging, startPos, startMouse = false, nil, nil
	Header.InputBegan:Connect(function(i)
		if isPress(i) then dragging = true; startMouse = i.Position; startPos = Main.Position end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - startMouse
			Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(i) if isPress(i) then dragging = false end end)
end

------------------------------------------------------------------ start
showPage("hero", 1)
openMenu()

local Hub = { Gui = Gui, Open = openMenu, Close = closeMenu, Toast = say, Config = CONFIG, Handlers = Handlers }
function Hub.Destroy() Gui:Destroy() end
return Hub
