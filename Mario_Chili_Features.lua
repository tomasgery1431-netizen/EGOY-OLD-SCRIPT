--[[
  Mario Mini Hub · Chili-style Features only
  Steal An Egg · Auto Steal, Place, Hatch, Sell, Anti Guard, FPS, etc.
  No WalkSpeed slider · features from Chili adapted clean
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProximityPromptService = game:GetService("ProximityPromptService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- clean old
local old = PlayerGui:FindFirstChild("MarioChiliHub")
if old then old:Destroy() end

-------------------------------------------------
-- STATE
-------------------------------------------------
local State = {
	AutoSteal = false,
	AutoPlace = false,
	AutoHatch = false,
	AutoSell = false,
	AutoClaim = false,
	AntiAFK = true,
	AntiTrap = true,
	AntiRagdoll = true,
	GodMode = false,
	Noclip = false,
	InfJump = false,
	FPSBoost = false,
	InstantPrompt = true,
	StealPriority = "Closest", -- Closest | Rarest | Value
	MinRarity = "None",
}

local RARITY_ORDER = {
	Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5,
	Mythic = 6, Cosmic = 7, Secret = 8, Eternal = 9, Divine = 10,
}

-------------------------------------------------
-- HELPERS
-------------------------------------------------
local function getHumanoid()
	local char = LocalPlayer.Character
	return char and char:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
	local char = LocalPlayer.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function notify(text)
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "Mario · Chili",
			Text = text,
			Duration = 3,
		})
	end)
end

-------------------------------------------------
-- GUI
-------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MarioChiliHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Card = Instance.new("Frame")
Card.Size = UDim2.new(0, 280, 0, 420)
Card.Position = UDim2.new(0, 18, 0.25, 0)
Card.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
Card.BorderSizePixel = 0
Card.Active = true
Card.Parent = ScreenGui
Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", Card)
stroke.Color = Color3.fromRGB(50, 50, 60)
stroke.Thickness = 1

-- title
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Card
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 14)
TitleFix.Position = UDim2.new(0, 0, 1, -14)
TitleFix.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Mario · Chili Features"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextColor3 = Color3.fromRGB(255, 90, 70)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 32, 0, 32)
Close.Position = UDim2.new(1, -34, 0, 2)
Close.BackgroundTransparency = 1
Close.Text = "×"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 20
Close.TextColor3 = Color3.fromRGB(160, 160, 170)
Close.Parent = TitleBar
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- scroll
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -16, 1, -48)
Scroll.Position = UDim2.new(0, 8, 0, 42)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Card

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 6)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Scroll

local function section(text)
	local f = Instance.new("TextLabel")
	f.Size = UDim2.new(1, 0, 0, 22)
	f.BackgroundTransparency = 1
	f.Text = text
	f.Font = Enum.Font.GothamBold
	f.TextSize = 12
	f.TextColor3 = Color3.fromRGB(255, 120, 90)
	f.TextXAlignment = Enum.TextXAlignment.Left
	f.Parent = Scroll
	return f
end

local function makeToggle(name, key, default)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 30)
	row.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
	row.BorderSizePixel = 0
	row.Parent = Scroll
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -56, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.Font = Enum.Font.Gotham
	label.TextSize = 13
	label.TextColor3 = Color3.fromRGB(220, 220, 230)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 42, 0, 22)
	btn.Position = UDim2.new(1, -48, 0.5, -11)
	btn.BackgroundColor3 = default and Color3.fromRGB(60, 140, 255) or Color3.fromRGB(50, 50, 58)
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = row
	Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
	knob.BackgroundColor3 = Color3.fromRGB(240, 240, 245)
	knob.BorderSizePixel = 0
	knob.Parent = btn
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	State[key] = default

	btn.MouseButton1Click:Connect(function()
		State[key] = not State[key]
		local on = State[key]
		TweenService:Create(btn, TweenInfo.new(0.12), {
			BackgroundColor3 = on and Color3.fromRGB(60, 140, 255) or Color3.fromRGB(50, 50, 58)
		}):Play()
		TweenService:Create(knob, TweenInfo.new(0.12), {
			Position = on and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
		}):Play()
		notify(name .. (on and " ON" or " OFF"))
	end)

	return row
end

-------------------------------------------------
-- BUILD UI
-------------------------------------------------
section("STEAL")
makeToggle("Auto Steal", "AutoSteal", false)
makeToggle("Instant Prompt", "InstantPrompt", true)

section("PLOT / EGGS")
makeToggle("Auto Place", "AutoPlace", false)
makeToggle("Auto Hatch", "AutoHatch", false)
makeToggle("Auto Sell", "AutoSell", false)
makeToggle("Auto Claim Index", "AutoClaim", false)

section("PROTECTION")
makeToggle("Anti AFK", "AntiAFK", true)
makeToggle("Anti Trap", "AntiTrap", true)
makeToggle("Anti Ragdoll", "AntiRagdoll", true)
makeToggle("God Mode", "GodMode", false)
makeToggle("Noclip", "Noclip", false)
makeToggle("Infinite Jump", "InfJump", false)

section("PERFORMANCE")
makeToggle("FPS Boost", "FPSBoost", false)

-------------------------------------------------
-- FEATURE LOGIC
-------------------------------------------------

-- Anti AFK
LocalPlayer.Idled:Connect(function()
	if State.AntiAFK then
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
	end
end)

-- Instant Prompt
ProximityPromptService.PromptButtonHoldBegan:Connect(function(prompt)
	if State.InstantPrompt and prompt and prompt.Parent then
		pcall(function()
			prompt.HoldDuration = 0
			fireproximityprompt(prompt)
		end)
	end
end)

-- Noclip
RunService.Stepped:Connect(function()
	if not State.Noclip then return end
	local char = LocalPlayer.Character
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
	if State.InfJump then
		local hum = getHumanoid()
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

-- God Mode (soft)
RunService.Heartbeat:Connect(function()
	if not State.GodMode then return end
	local hum = getHumanoid()
	if hum then
		if hum.Health < hum.MaxHealth * 0.9 then
			hum.Health = hum.MaxHealth
		end
		pcall(function()
			hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
			hum.BreakJointsOnDeath = false
		end)
	end
end)

-- Anti Ragdoll
RunService.Heartbeat:Connect(function()
	if not State.AntiRagdoll then return end
	local hum = getHumanoid()
	if hum and hum:GetState() == Enum.HumanoidStateType.Physics then
		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end)

-- Anti Trap (destroy common traps)
task.spawn(function()
	while task.wait(1.5) do
		if not State.AntiTrap then continue end
		for _, folderName in ipairs({"Transient", "__DEBRIS", "Traps"}) do
			local folder = workspace:FindFirstChild(folderName)
			if folder then
				for _, c in ipairs(folder:GetChildren()) do
					if c.Name:lower():find("trap") or c.Name == "PlayerTrap" then
						pcall(c.Destroy, c)
					end
				end
			end
		end
	end
end)

-- FPS Boost
local function applyFPS(on)
	pcall(function()
		if on then
			settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
			UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
			for _, v in ipairs(workspace:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
					v.Enabled = false
				elseif v:IsA("BasePart") and v.Material ~= Enum.Material.Plastic then
					-- leave structure, just flatten heavy materials later if needed
				end
			end
		else
			settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
		end
	end)
end

-- watch FPS toggle
task.spawn(function()
	local last = false
	while task.wait(0.5) do
		if State.FPSBoost ~= last then
			last = State.FPSBoost
			applyFPS(last)
		end
	end
end)

-- Auto Claim (simple attribute / button press attempt)
task.spawn(function()
	while task.wait(4) do
		if not State.AutoClaim then continue end
		pcall(function()
			local remotes = ReplicatedStorage:FindFirstChild("Shared")
			and ReplicatedStorage.Shared:FindFirstChild("Remotes")
			if remotes then
				for _, r in ipairs(remotes:GetDescendants()) do
					if r:IsA("RemoteEvent") and (r.Name:lower():find("claim") or r.Name:lower():find("index")) then
						pcall(r.FireServer, r)
					end
				end
			end
		end)
	end
end)

-- Auto Place / Hatch / Sell (best-effort via prompts & common remotes)
task.spawn(function()
	while task.wait(2.5) do
		if State.AutoPlace or State.AutoHatch or State.AutoSell then
			pcall(function()
				for _, prompt in ipairs(workspace:GetDescendants()) do
					if prompt:IsA("ProximityPrompt") and prompt.Enabled then
						local n = (prompt.Name .. (prompt.ActionText or "") .. (prompt.ObjectText or "")):lower()
						if State.AutoPlace and (n:find("place") or n:find("put")) then
							if State.InstantPrompt then prompt.HoldDuration = 0 end
							pcall(fireproximityprompt, prompt)
						elseif State.AutoHatch and (n:find("hatch") or n:find("open")) then
							if State.InstantPrompt then prompt.HoldDuration = 0 end
							pcall(fireproximityprompt, prompt)
						elseif State.AutoSell and (n:find("sell") or n:find("shop")) then
							if State.InstantPrompt then prompt.HoldDuration = 0 end
							pcall(fireproximityprompt, prompt)
						end
					end
				end
			end)
		end
	end
end)

-- Auto Steal (best-effort: find nearest egg prompt / part and hold it)
task.spawn(function()
	while task.wait(1.2) do
		if not State.AutoSteal then continue end
		local root = getRoot()
		if not root then continue end

		local best, bestDist
		for _, inst in ipairs(workspace:GetDescendants()) do
			if inst:IsA("ProximityPrompt") and inst.Enabled then
				local txt = ((inst.ActionText or "") .. (inst.ObjectText or "") .. inst.Name):lower()
				if txt:find("steal") or txt:find("egg") or txt:find("grab") or txt:find("pick") then
					local part = inst.Parent and (inst.Parent:IsA("BasePart") and inst.Parent or inst.Parent:FindFirstChildWhichIsA("BasePart"))
					if part then
						local d = (part.Position - root.Position).Magnitude
						if not bestDist or d < bestDist then
							best, bestDist = inst, d
						end
					end
				end
			end
		end

		if best and bestDist and bestDist < 120 then
			pcall(function()
				if State.InstantPrompt then best.HoldDuration = 0 end
				-- walk closer if needed
				if bestDist > 12 then
					local part = best.Parent:IsA("BasePart") and best.Parent or best.Parent:FindFirstChildWhichIsA("BasePart")
					if part then
						local hum = getHumanoid()
						if hum then
							hum:MoveTo(part.Position)
						end
					end
				end
				fireproximityprompt(best)
			end)
		end
	end
end)

-- drag card
local draggingCard, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingCard = true
		dragStart = input.Position
		startPos = Card.Position
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if draggingCard and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		Card.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingCard = false
	end
end)

notify("Mario · Chili Features loaded")
print("[Mario · Chili] Features hub loaded — Auto Steal / Place / Hatch / Sell / Anti / FPS")
