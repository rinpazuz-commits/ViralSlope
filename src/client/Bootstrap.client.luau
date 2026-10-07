local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

print(string.format("[%s] Client booted v%s", Config.GAME_NAME, Config.VERSION))

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "ViralSlopeHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local card = Instance.new("Frame")
card.Name = "StatsCard"
card.Size = UDim2.fromOffset(260, 108)
card.Position = UDim2.new(0, 24, 0, 24)
card.BackgroundColor3 = Color3.fromRGB(18, 25, 40)
card.BackgroundTransparency = 0.12
card.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = card

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -24, 0, 28)
title.Position = UDim2.fromOffset(12, 8)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "VIRALSLOPE"
title.TextColor3 = Color3.fromRGB(87, 235, 190)
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = card

local stats = Instance.new("TextLabel")
stats.Name = "Stats"
stats.Size = UDim2.new(1, -24, 0, 56)
stats.Position = UDim2.fromOffset(12, 42)
stats.BackgroundTransparency = 1
stats.Font = Enum.Font.GothamMedium
stats.TextColor3 = Color3.fromRGB(245, 248, 255)
stats.TextSize = 16
stats.TextXAlignment = Enum.TextXAlignment.Left
stats.TextYAlignment = Enum.TextYAlignment.Top
stats.Parent = card

local function refresh()
	stats.Text = string.format("Distance  %d studs\nBest  %d     Cash  $%d", player:GetAttribute("RunDistance") or 0, player:GetAttribute("BestDistance") or 0, player:GetAttribute("Cash") or 0)
end

for _, attribute in {"RunDistance", "BestDistance", "Cash"} do
	player:GetAttributeChangedSignal(attribute):Connect(refresh)
end
refresh()
