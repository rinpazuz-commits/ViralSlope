local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local player = Players.LocalPlayer

print(string.format("[%s] Client booted v%s", Config.GAME_NAME, Config.VERSION))

local gui = Instance.new("ScreenGui")
gui.Name = "NightshiftHUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local card = Instance.new("Frame")
card.Name = "ExpeditionCard"
card.Size = UDim2.fromOffset(344, 174)
card.Position = UDim2.new(0, 24, 0, 24)
card.BackgroundColor3 = Color3.fromRGB(13, 24, 34)
card.BackgroundTransparency = 0.08
card.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = card

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(65, 223, 198)
stroke.Transparency = 0.35
stroke.Thickness = 1.5
stroke.Parent = card

local function label(name, position, size, font, textSize, color)
	local item = Instance.new("TextLabel")
	item.Name = name
	item.Position = position
	item.Size = size
	item.BackgroundTransparency = 1
	item.Font = font
	item.TextColor3 = color
	item.TextSize = textSize
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.Parent = card
	return item
end

local title = label("Title", UDim2.fromOffset(18, 13), UDim2.new(1, -36, 0, 27), Enum.Font.GothamBold, 19, Color3.fromRGB(92, 240, 210))
title.Text = "NIGHTSHIFT SALVAGE"

local phase = label("Phase", UDim2.fromOffset(18, 46), UDim2.new(1, -36, 0, 25), Enum.Font.GothamBold, 16, Color3.fromRGB(255, 203, 112))
local timer = label("Timer", UDim2.new(1, -92, 0, 46), UDim2.fromOffset(74, 25), Enum.Font.GothamBold, 18, Color3.fromRGB(245, 248, 255))
timer.TextXAlignment = Enum.TextXAlignment.Right

local haul = label("Haul", UDim2.fromOffset(18, 79), UDim2.new(1, -36, 0, 24), Enum.Font.GothamMedium, 16, Color3.fromRGB(240, 246, 250))
local cash = label("Cash", UDim2.fromOffset(18, 108), UDim2.new(1, -36, 0, 22), Enum.Font.GothamMedium, 15, Color3.fromRGB(171, 197, 211))
local hint = label("Hint", UDim2.fromOffset(18, 140), UDim2.new(1, -36, 0, 22), Enum.Font.Gotham, 12, Color3.fromRGB(148, 174, 190))

local toast = Instance.new("TextLabel")
toast.Name = "RoundToast"
toast.Size = UDim2.fromOffset(420, 48)
toast.Position = UDim2.new(0.5, -210, 0, 26)
toast.BackgroundColor3 = Color3.fromRGB(13, 24, 34)
toast.BackgroundTransparency = 0.08
toast.Font = Enum.Font.GothamBold
toast.TextColor3 = Color3.fromRGB(255, 255, 255)
toast.TextSize = 18
toast.Visible = false
toast.Parent = gui
local toastCorner = Instance.new("UICorner")
toastCorner.CornerRadius = UDim.new(0, 14)
toastCorner.Parent = toast

local toastId = 0
local function showToast(message, color)
	toastId += 1
	local current = toastId
	toast.Text = message
	toast.TextColor3 = color
	toast.Visible = true
	task.delay(3, function()
		if toastId == current then toast.Visible = false end
	end)
end

local function formatTime(seconds)
	seconds = math.max(0, seconds or 0)
	return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

local function refresh()
	local currentPhase = player:GetAttribute("Phase") or "REFUGE"
	local remaining = player:GetAttribute("RoundTime") or 0
	phase.Text = currentPhase == "EXPEDITION" and "EXPÉDITION" or currentPhase == "NIGHTFALL" and "NUIT TOMBÉE" or "REFUGE • PROCHAIN DÉPART"
	phase.TextColor3 = currentPhase == "EXPEDITION" and Color3.fromRGB(255, 140, 119) or Color3.fromRGB(255, 203, 112)
	timer.Text = formatTime(remaining)
	haul.Text = string.format("Sac : %d relique(s)  •  valeur $%d", player:GetAttribute("HaulItems") or 0, player:GetAttribute("HaulValue") or 0)
	cash.Text = string.format("Réserve : $%d  •  expéditions : %d", player:GetAttribute("Cash") or 0, player:GetAttribute("Extractions") or 0)
	if currentPhase == "EXPEDITION" then
		hint.Text = "Ramasse les signaux. Reviens au refuge avant la nuit."
	else
		hint.Text = "WASD pour explorer • le refuge permet d'encaisser"
	end
end

for _, attribute in {"Phase", "RoundTime", "HaulItems", "HaulValue", "Cash", "Extractions"} do
	player:GetAttributeChangedSignal(attribute):Connect(refresh)
end
player:GetAttributeChangedSignal("LastDeposit"):Connect(function()
	local amount = player:GetAttribute("LastDeposit") or 0
	if amount > 0 then showToast(string.format("RELIQUES RAPPORTÉES  +$%d", amount), Color3.fromRGB(92, 240, 210)) end
end)
player:GetAttributeChangedSignal("LostValue"):Connect(function()
	local amount = player:GetAttribute("LostValue") or 0
	if amount > 0 then showToast(string.format("SIGNAL PERDU  •  $%d abandonnés", amount), Color3.fromRGB(255, 112, 124)) end
end)

refresh()
