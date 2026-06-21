local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

------------------------------------------------
-- GUI (CLEAN VERSION)
------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "DevMenu"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 260)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 16, 24)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

Instance.new("UICorner", frame)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundColor3 = Color3.fromRGB(35, 25, 55)
title.BorderSizePixel = 0
title.Text = "Meow Meow V2"
title.TextColor3 = Color3.fromRGB(235, 200, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

Instance.new("UICorner", title)

local container = Instance.new("Frame")
container.Size = UDim2.new(1, -20, 1, -46)
container.Position = UDim2.new(0, 10, 0, 46)
container.BackgroundTransparency = 1
container.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.Parent = container

------------------------------------------------
-- INPUT
------------------------------------------------
local orbitSpeedBox = Instance.new("TextBox")
orbitSpeedBox.Size = UDim2.new(1, 0, 0, 30)
orbitSpeedBox.BackgroundColor3 = Color3.fromRGB(30, 28, 40)
orbitSpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
orbitSpeedBox.PlaceholderText = "Orbit Speed (1–10000)"
orbitSpeedBox.Text = "50"
orbitSpeedBox.Font = Enum.Font.Gotham
orbitSpeedBox.TextSize = 14
orbitSpeedBox.BorderSizePixel = 0
orbitSpeedBox.Parent = container

Instance.new("UICorner", orbitSpeedBox)

local function makeButton(text)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 32)
	b.BackgroundColor3 = Color3.fromRGB(45, 40, 60)
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamSemibold
	b.TextSize = 14
	b.Text = text
	b.BorderSizePixel = 0
	b.Parent = container

	Instance.new("UICorner", b)
	return b
end

local orbitBtn = makeButton("Hacker Orbit: OFF")
local noclipBtn = makeButton("Noclip: OFF")
local undergroundBtn = makeButton("Underground: OFF")

------------------------------------------------
-- STATE
------------------------------------------------
local orbitEnabled = false
local orbitAngle = 0
local jitterSeed = math.random(1, 999999)

local noclip = false
local underground = false
local undergroundOffset = 500

------------------------------------------------
-- F5 MENU TOGGLE (FIXED)
------------------------------------------------
local menuOpen = true

local function setMenu(state)
	menuOpen = state
	gui.Enabled = state
end

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end

	if input.KeyCode == Enum.KeyCode.F5 then
		setMenu(not menuOpen)
	end
end)

setMenu(true)

------------------------------------------------
-- HELPERS
------------------------------------------------
local function getRoot(char)
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function getEnemyTarget()
	local char = player.Character
	if not char then return end

	local root = getRoot(char)
	if not root then return end

	local closest, dist = nil, math.huge

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player and p.Character then
			local tRoot = getRoot(p.Character)
			if tRoot then
				local d = (tRoot.Position - root.Position).Magnitude
				if d < dist then
					dist = d
					closest = p.Character
				end
			end
		end
	end

	return closest
end

------------------------------------------------
-- TOGGLES
------------------------------------------------
orbitBtn.MouseButton1Click:Connect(function()
	orbitEnabled = not orbitEnabled
	orbitBtn.Text = orbitEnabled and "Hacker Orbit: ON" or "Hacker Orbit: OFF"
end)

noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipBtn.Text = noclip and "Noclip: ON" or "Noclip: OFF"
end)

undergroundBtn.MouseButton1Click:Connect(function()
	underground = not underground
	undergroundBtn.Text = underground and "Underground: ON" or "Underground: OFF"
end)

------------------------------------------------
-- NOCLIP
------------------------------------------------
RunService.Stepped:Connect(function()
	if not noclip then return end

	local char = player.Character
	if not char then return end

	for _, v in ipairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
end)

------------------------------------------------
-- ORBIT SYSTEM
------------------------------------------------
RunService.RenderStepped:Connect(function(dt)
	if not orbitEnabled then return end

	local char = player.Character
	local root = getRoot(char)
	if not root then return end

	local targetChar = getEnemyTarget()
	if not targetChar then return end

	local tRoot = getRoot(targetChar)
	if not tRoot then return end

	local speed = math.clamp(tonumber(orbitSpeedBox.Text) or 50, 1, 10000)

	orbitAngle += (speed * dt) * 0.8

	local radius = 10
	local t = tick()

	local x = math.cos(orbitAngle) * radius
	local z = math.sin(orbitAngle) * radius

	local upDown = math.sin(t * 10) * 4

	local jitterX = math.sin(t * 12 + jitterSeed) * 0.4
	local jitterZ = math.cos(t * 12 + jitterSeed) * 0.4

	local offset = Vector3.new(x + jitterX, 5 + upDown, z + jitterZ)

	local finalPos = tRoot.Position + offset

	if underground then
		finalPos -= Vector3.new(0, undergroundOffset, 0)
	end

	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	root.CFrame = CFrame.new(finalPos, tRoot.Position)
end)
