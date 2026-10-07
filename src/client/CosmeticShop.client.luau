local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local CosmeticCatalog = require(ReplicatedStorage.Shared.CosmeticCatalog)
local remotes = ReplicatedStorage:WaitForChild("RiftRemotes")
local requestRemote = remotes:WaitForChild("CosmeticRequest")
local openRemote = remotes:WaitForChild("OpenCosmeticShop")
local gui = player:WaitForChild("PlayerGui"):WaitForChild("RiftRunnersHUD")
local expeditionPanel = gui:WaitForChild("ExpeditionPanel")
local openButton = expeditionPanel:WaitForChild("Shop")

local palette = {
	Panel = Color3.fromRGB(18, 25, 47),
	Card = Color3.fromRGB(31, 42, 68),
	White = Color3.fromRGB(245, 248, 255),
	Muted = Color3.fromRGB(177, 196, 223),
	Gold = Color3.fromRGB(255, 208, 113),
	Mint = Color3.fromRGB(100, 239, 211),
	Coral = Color3.fromRGB(255, 142, 133),
}

local overlay = Instance.new("Frame")
overlay.Name = "RelicShopOverlay"
overlay.Size = UDim2.fromScale(1, 1)
overlay.BackgroundColor3 = Color3.fromRGB(5, 9, 20)
overlay.BackgroundTransparency = 0.34
overlay.BorderSizePixel = 0
overlay.Visible = false
overlay.ZIndex = 30
overlay.Parent = gui

local panel = Instance.new("Frame")
panel.Name = "RelicShopPanel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.new(0.92, 0, 0.78, 0)
panel.BackgroundColor3 = palette.Panel
panel.BackgroundTransparency = 0.025
panel.BorderSizePixel = 0
panel.Visible = false
panel.ZIndex = 31
panel.Parent = overlay
local panelConstraint = Instance.new("UISizeConstraint")
panelConstraint.MinSize = Vector2.new(280, 300)
panelConstraint.MaxSize = Vector2.new(520, 510)
panelConstraint.Parent = panel
local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 18)
panelCorner.Parent = panel
local panelStroke = Instance.new("UIStroke")
panelStroke.Color = palette.Mint
panelStroke.Transparency = 0.3
panelStroke.Thickness = 1.5
panelStroke.Parent = panel
local panelGradient = Instance.new("UIGradient")
panelGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 39, 68)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 21, 41)),
})
panelGradient.Rotation = 90
panelGradient.Parent = panel

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Position = UDim2.fromOffset(16, 12)
title.Size = UDim2.new(1, -70, 0, 27)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "RIFT RELIC ATELIER"
title.TextColor3 = palette.Mint
title.TextSize = 19
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 32
title.Parent = panel

local balance = Instance.new("TextLabel")
balance.Name = "Balance"
balance.Position = UDim2.fromOffset(17, 40)
balance.Size = UDim2.new(1, -34, 0, 18)
balance.BackgroundTransparency = 1
balance.Font = Enum.Font.GothamMedium
balance.TextColor3 = palette.Gold
balance.TextSize = 12
balance.TextXAlignment = Enum.TextXAlignment.Left
balance.ZIndex = 32
balance.Parent = panel

local close = Instance.new("TextButton")
close.Name = "Close"
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.new(1, -10, 0, 8)
close.Size = UDim2.fromOffset(42, 42)
close.BackgroundColor3 = Color3.fromRGB(48, 59, 88)
close.Font = Enum.Font.GothamBold
close.Text = "×"
close.TextColor3 = palette.White
close.TextSize = 26
close.ZIndex = 34
close.Parent = panel
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 12)
closeCorner.Parent = close

local list = Instance.new("ScrollingFrame")
list.Name = "Cosmetics"
list.Position = UDim2.fromOffset(12, 66)
list.Size = UDim2.new(1, -24, 1, -112)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.ScrollBarImageColor3 = palette.Mint
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.CanvasSize = UDim2.new()
list.ZIndex = 32
list.Parent = panel
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

local status = Instance.new("TextLabel")
status.Name = "Status"
status.AnchorPoint = Vector2.new(0, 1)
status.Position = UDim2.new(0, 16, 1, -9)
status.Size = UDim2.new(1, -32, 0, 24)
status.BackgroundTransparency = 1
status.Font = Enum.Font.GothamMedium
status.Text = "Cosmetics are earned with expedition Coins."
status.TextColor3 = palette.Muted
status.TextSize = 11
status.TextWrapped = true
status.TextXAlignment = Enum.TextXAlignment.Left
status.ZIndex = 32
status.Parent = panel

local ownedState = {}
local equippedId = ""
local busy = false
local cards = {}

local function applyResponsiveLayout()
	local camera = workspace.CurrentCamera
	if not camera then return end
	local compact = camera.ViewportSize.X < 440
	for _, card in cards do
		card.Frame.Size = UDim2.new(1, -4, 0, compact and 122 or 104)
		card.Icon.Position = UDim2.fromOffset(10, compact and 10 or 14)
		card.Icon.Size = UDim2.fromOffset(compact and 46 or 54, compact and 46 or 54)
		card.Name.Position = UDim2.new(0, compact and 64 or 74, 0, compact and 9 or 11)
		card.Name.Size = UDim2.new(1, compact and -76 or -206, 0, 22)
		card.Name.TextSize = compact and 12 or 14
		card.Description.Position = UDim2.new(0, compact and 10 or 74, 0, compact and 57 or 34)
		card.Description.Size = UDim2.new(1, compact and -126 or -206, 0, compact and 58 or 52)
		card.Description.TextSize = compact and 10 or 11
		if compact then
			card.Button.AnchorPoint = Vector2.new(1, 0)
			card.Button.Position = UDim2.new(1, -8, 0, 68)
		else
			card.Button.AnchorPoint = Vector2.new(1, 0.5)
			card.Button.Position = UDim2.new(1, -8, 0.5, 0)
		end
		card.Button.Size = UDim2.fromOffset(compact and 102 or 112, 46)
		card.Button.TextSize = compact and 10 or 12
	end
end

local function setStatus(text, color)
	status.Text = text
	status.TextColor3 = color or palette.Muted
end

local function buttonText(item)
	if ownedState[item.Id] then
		if equippedId == item.Id then return "UNEQUIP", palette.Mint end
		return "EQUIP", palette.White
	end
	return string.format("BUY  •  %d", item.Price), palette.Gold
end

local function refresh()
	local coins = player:GetAttribute("Coins") or 0
	balance.Text = string.format("%d COINS  •  Earned by extracting Riftlings", coins)
	for _, item in CosmeticCatalog.Items do
		local card = cards[item.Id]
		if card then
			local label, color = buttonText(item)
			card.Button.Text = label
			card.Button.TextColor3 = color
			card.Button.BackgroundColor3 = ownedState[item.Id] and Color3.fromRGB(43, 58, 82) or Color3.fromRGB(68, 61, 98)
		end
	end
end

local function updateFromResponse(response)
	if type(response) ~= "table" then return end
	if type(response.State) == "table" then
		ownedState = response.State.Owned or {}
		equippedId = response.State.Equipped or ""
	end
	refresh()
	local messages = {
		PURCHASED = { "Relic secured and equipped!", palette.Mint },
		EQUIPPED = { "Relic equipped.", palette.Mint },
		UNEQUIPPED = { "Relic unequipped.", palette.Muted },
		ALREADY_OWNED = { "You already own this relic.", palette.Gold },
		NOT_ENOUGH_COINS = { "Not enough Coins yet. Extract more Riftlings!", palette.Coral },
		NOT_OWNED = { "Earn Coins and claim this relic first.", palette.Coral },
		INVALID_ITEM = { "That relic is unavailable.", palette.Coral },
		DATA_NOT_READY = { "Profile is still loading. Try again in a moment.", palette.Gold },
		TOO_FAST = { "One moment — your last request is still processing.", palette.Gold },
	}
	local message = messages[response.Status]
	if message then setStatus(message[1], message[2]) end
end

local function invoke(action, itemId)
	if busy then return end
	busy = true
	local ok, response = pcall(function()
		return requestRemote:InvokeServer(action, itemId)
	end)
	busy = false
	if ok then
		updateFromResponse(response)
	else
		setStatus("The relic stand could not reach the hub. Try again.", palette.Coral)
		warn("[Rift Runners] Cosmetic request failed: " .. tostring(response))
	end
	return ok and response or nil
end

local symbols = { HEADGEAR = "★", TRAIL = "〰", COMPANION = "◉" }
for index, item in CosmeticCatalog.Items do
	local card = Instance.new("Frame")
	card.Name = item.Id
	card.LayoutOrder = index
	card.Size = UDim2.new(1, -4, 0, 104)
	card.BackgroundColor3 = palette.Card
	card.BackgroundTransparency = 0.06
	card.BorderSizePixel = 0
	card.ZIndex = 33
	card.Parent = list
	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 13)
	cardCorner.Parent = card
	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = item.Color
	cardStroke.Transparency = 0.68
	cardStroke.Parent = card

	local icon = Instance.new("TextLabel")
	icon.Name = "RelicIcon"
	icon.Position = UDim2.fromOffset(10, 14)
	icon.Size = UDim2.fromOffset(54, 54)
	icon.BackgroundColor3 = item.Color
	icon.BackgroundTransparency = 0.76
	icon.Font = Enum.Font.GothamBold
	icon.Text = symbols[item.Category] or "✦"
	icon.TextColor3 = item.Color
	icon.TextSize = 27
	icon.ZIndex = 34
	icon.Parent = card
	local iconCorner = Instance.new("UICorner")
	iconCorner.CornerRadius = UDim.new(0, 15)
	iconCorner.Parent = icon

	local name = Instance.new("TextLabel")
	name.Name = "Name"
	name.Position = UDim2.new(0, 74, 0, 11)
	name.Size = UDim2.new(1, -206, 0, 22)
	name.BackgroundTransparency = 1
	name.Font = Enum.Font.GothamBold
	name.Text = item.Name
	name.TextColor3 = item.Color
	name.TextSize = 14
	name.TextXAlignment = Enum.TextXAlignment.Left
	name.ZIndex = 34
	name.Parent = card

	local description = Instance.new("TextLabel")
	description.Name = "Description"
	description.Position = UDim2.new(0, 74, 0, 34)
	description.Size = UDim2.new(1, -206, 0, 52)
	description.BackgroundTransparency = 1
	description.Font = Enum.Font.GothamMedium
	description.Text = item.Description
	description.TextColor3 = palette.Muted
	description.TextSize = 11
	description.TextWrapped = true
	description.TextXAlignment = Enum.TextXAlignment.Left
	description.TextYAlignment = Enum.TextYAlignment.Top
	description.ZIndex = 34
	description.Parent = card

	local action = Instance.new("TextButton")
	action.Name = "Action"
	action.AnchorPoint = Vector2.new(1, 0.5)
	action.Position = UDim2.new(1, -10, 0.5, 0)
	action.Size = UDim2.fromOffset(112, 46)
	action.BackgroundColor3 = Color3.fromRGB(68, 61, 98)
	action.Font = Enum.Font.GothamBold
	action.Text = string.format("BUY  •  %d", item.Price)
	action.TextColor3 = palette.Gold
	action.TextSize = 12
	action.TextWrapped = true
	action.AutoButtonColor = true
	action.ZIndex = 34
	action.Parent = card
	local actionCorner = Instance.new("UICorner")
	actionCorner.CornerRadius = UDim.new(0, 11)
	actionCorner.Parent = action
	action.Activated:Connect(function()
		if ownedState[item.Id] then
			if equippedId == item.Id then
				invoke("Equip", "")
			else
				invoke("Equip", item.Id)
			end
		else
			invoke("Buy", item.Id)
		end
	end)
	cards[item.Id] = { Frame = card, Icon = icon, Name = name, Description = description, Button = action }
end

local function openShop()
	overlay.Visible = true
	panel.Visible = true
	setStatus("Cosmetics are earned with expedition Coins.", palette.Muted)
	local response = invoke("GetState")
	if response and response.Status == "OK" then
		setStatus("No gameplay bonuses — just style for your next run.", palette.Muted)
	end
end

openButton.Activated:Connect(function()
	if overlay.Visible then
		overlay.Visible = false
		panel.Visible = false
	else
		openShop()
	end
end)
openRemote.OnClientEvent:Connect(openShop)
close.Activated:Connect(function()
	overlay.Visible = false
	panel.Visible = false
end)
overlay.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local position = input.Position
		local panelPosition = panel.AbsolutePosition
		local panelSize = panel.AbsoluteSize
		if position.X < panelPosition.X or position.X > panelPosition.X + panelSize.X
			or position.Y < panelPosition.Y or position.Y > panelPosition.Y + panelSize.Y
		then
			overlay.Visible = false
			panel.Visible = false
		end
	end
end)

player:GetAttributeChangedSignal("Coins"):Connect(refresh)
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveLayout)
end
applyResponsiveLayout()
refresh()
