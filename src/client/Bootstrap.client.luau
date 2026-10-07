local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Shared.Config)
local CreatureCatalog = require(ReplicatedStorage.Shared.CreatureCatalog)
local player = Players.LocalPlayer

print(string.format("[%s] Client booted v%s", Config.GAME_NAME, Config.VERSION))

local palette = {
	ink = Color3.fromRGB(100, 241, 215),
	white = Color3.fromRGB(245, 248, 255),
	muted = Color3.fromRGB(170, 190, 219),
	coral = Color3.fromRGB(255, 136, 130),
	gold = Color3.fromRGB(255, 208, 113),
	panel = Color3.fromRGB(21, 28, 52),
}

local gui = Instance.new("ScreenGui")
gui.Name = "RiftRunnersHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 10
gui.Parent = player:WaitForChild("PlayerGui")

local card = Instance.new("Frame")
card.Name = "ExpeditionPanel"
card.AnchorPoint = Vector2.new(0.5, 0)
card.Position = UDim2.new(0.5, 0, 0, 14)
card.Size = UDim2.new(0.94, 0, 0, 178)
card.BackgroundColor3 = palette.panel
card.BackgroundTransparency = 0.08
card.Parent = gui
local sizeConstraint = Instance.new("UISizeConstraint")
sizeConstraint.MinSize = Vector2.new(290, 178)
sizeConstraint.MaxSize = Vector2.new(440, 178)
sizeConstraint.Parent = card
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 20)
corner.Parent = card
local stroke = Instance.new("UIStroke")
stroke.Color = palette.ink
stroke.Transparency = 0.3
stroke.Thickness = 1.5
stroke.Parent = card
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(31, 43, 74)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(17, 23, 42)),
})
gradient.Rotation = 90
gradient.Parent = card

local function makeLabel(name, position, size, fontSize, color, bold)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Position = position
	label.Size = size
	label.BackgroundTransparency = 1
	label.Font = bold and Enum.Font.GothamBold or Enum.Font.GothamMedium
	label.TextColor3 = color
	label.TextSize = fontSize
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = card
	return label
end

local title = makeLabel("Title", UDim2.fromOffset(18, 12), UDim2.new(1, -36, 0, 25), 20, palette.ink, true)
title.Text = "RIFT RUNNERS"
local subtitle = makeLabel("Subtitle", UDim2.fromOffset(19, 35), UDim2.new(1, -38, 0, 18), 10, palette.muted, true)
subtitle.Text = "COLLECT THE ODD. MAKE IT HOME."
subtitle.TextTransparency = 0.15

local phase = makeLabel("Phase", UDim2.fromOffset(18, 60), UDim2.new(0.58, 0, 0, 25), 14, palette.gold, true)
local timer = makeLabel("Timer", UDim2.new(1, -95, 0, 57), UDim2.fromOffset(77, 30), 20, palette.white, true)
timer.TextXAlignment = Enum.TextXAlignment.Right

local divider = Instance.new("Frame")
divider.Position = UDim2.fromOffset(18, 92)
divider.Size = UDim2.new(1, -36, 0, 1)
divider.BackgroundColor3 = Color3.fromRGB(101, 125, 168)
divider.BackgroundTransparency = 0.62
divider.BorderSizePixel = 0
divider.Parent = card

local bag = makeLabel("Bag", UDim2.fromOffset(18, 101), UDim2.new(0.62, -18, 0, 24), 14, palette.white, true)
local coins = makeLabel("Coins", UDim2.new(0.62, 0, 0, 101), UDim2.new(0.38, -18, 0, 24), 14, palette.gold, true)
coins.TextXAlignment = Enum.TextXAlignment.Right
local collection = Instance.new("TextButton")
collection.Name = "Collection"
collection.Position = UDim2.fromOffset(18, 127)
collection.Size = UDim2.new(0.58, -18, 0, 20)
collection.BackgroundTransparency = 1
collection.Font = Enum.Font.GothamMedium
collection.TextColor3 = palette.muted
collection.TextSize = 12
collection.TextXAlignment = Enum.TextXAlignment.Left
collection.Parent = card
local shopButton = Instance.new("TextButton")
shopButton.Name = "Shop"
shopButton.Position = UDim2.new(0.62, 0, 0, 126)
shopButton.Size = UDim2.new(0.38, -18, 0, 22)
shopButton.BackgroundColor3 = Color3.fromRGB(66, 61, 103)
shopButton.BackgroundTransparency = 0.12
shopButton.Font = Enum.Font.GothamBold
shopButton.Text = "RELIC SHOP"
shopButton.TextColor3 = palette.gold
shopButton.TextSize = 11
shopButton.AutoButtonColor = true
shopButton.Parent = card
local shopButtonCorner = Instance.new("UICorner")
shopButtonCorner.CornerRadius = UDim.new(0, 8)
shopButtonCorner.Parent = shopButton
local shopButtonStroke = Instance.new("UIStroke")
shopButtonStroke.Color = palette.gold
shopButtonStroke.Transparency = 0.62
shopButtonStroke.Parent = shopButton
local hint = makeLabel("Hint", UDim2.fromOffset(18, 149), UDim2.new(1, -36, 0, 20), 11, Color3.fromRGB(197, 211, 237), false)
hint.TextWrapped = true

local book = Instance.new("Frame")
book.Name = "CollectionBook"
book.AnchorPoint = Vector2.new(0.5, 0.5)
book.Position = UDim2.fromScale(0.5, 0.52)
book.Size = UDim2.new(0.92, 0, 0, 390)
book.BackgroundColor3 = palette.panel
book.Visible = false
book.ZIndex = 20
book.Parent = gui
local bookConstraint = Instance.new("UISizeConstraint")
bookConstraint.MaxSize = Vector2.new(440, 390)
bookConstraint.MinSize = Vector2.new(290, 320)
bookConstraint.Parent = book
local bookCorner = Instance.new("UICorner")
bookCorner.CornerRadius = UDim.new(0, 18)
bookCorner.Parent = book
local bookStroke = Instance.new("UIStroke")
bookStroke.Color = palette.ink
bookStroke.Transparency = 0.2
bookStroke.Parent = book
local bookTitle = Instance.new("TextLabel")
bookTitle.BackgroundTransparency = 1
bookTitle.Position = UDim2.fromOffset(18, 12)
bookTitle.Size = UDim2.new(1, -72, 0, 32)
bookTitle.Font = Enum.Font.GothamBold
bookTitle.Text = "RIFTLING FIELD GUIDE"
bookTitle.TextColor3 = palette.ink
bookTitle.TextSize = 18
bookTitle.TextXAlignment = Enum.TextXAlignment.Left
bookTitle.ZIndex = 21
bookTitle.Parent = book
local closeBook = Instance.new("TextButton")
closeBook.BackgroundTransparency = 1
closeBook.Position = UDim2.new(1, -48, 0, 8)
closeBook.Size = UDim2.fromOffset(36, 36)
closeBook.Font = Enum.Font.GothamBold
closeBook.Text = "×"
closeBook.TextColor3 = palette.white
closeBook.TextSize = 26
closeBook.ZIndex = 21
closeBook.Parent = book
local guideList = Instance.new("ScrollingFrame")
guideList.Name = "CreatureList"
guideList.Position = UDim2.fromOffset(14, 54)
guideList.Size = UDim2.new(1, -28, 1, -68)
guideList.BackgroundTransparency = 1
guideList.BorderSizePixel = 0
guideList.ScrollBarThickness = 4
guideList.CanvasSize = UDim2.new(0, 0, 0, #CreatureCatalog.Species * 54)
guideList.ZIndex = 21
guideList.Parent = book
local guideLayout = Instance.new("UIListLayout")
guideLayout.Padding = UDim.new(0, 5)
guideLayout.SortOrder = Enum.SortOrder.LayoutOrder
guideLayout.Parent = guideList
local guideRows = {}
local rarityColors = {
	Common = Color3.fromRGB(140, 231, 190), Uncommon = Color3.fromRGB(100, 208, 245),
	Rare = Color3.fromRGB(174, 129, 255), Epic = Color3.fromRGB(255, 118, 211),
	Mythic = Color3.fromRGB(255, 205, 91),
}
for index, creature in CreatureCatalog.Species do
	local row = Instance.new("TextLabel")
	row.Name = creature.Id
	row.LayoutOrder = index
	row.Size = UDim2.new(1, -4, 0, 48)
	row.BackgroundColor3 = Color3.fromRGB(31, 41, 67)
	row.BackgroundTransparency = 0.15
	row.Font = Enum.Font.GothamMedium
	row.TextColor3 = palette.white
	row.TextSize = 13
	row.TextXAlignment = Enum.TextXAlignment.Left
	row.ZIndex = 22
	row.Parent = guideList
	local rowCorner = Instance.new("UICorner")
	rowCorner.CornerRadius = UDim.new(0, 10)
	rowCorner.Parent = row
	guideRows[creature.Id] = { Label = row, Data = creature }
end
local function refreshGuide()
	local counts = {}
	local encoded = player:GetAttribute("CollectionData")
	if type(encoded) == "string" then
		local ok, decoded = pcall(function() return HttpService:JSONDecode(encoded) end)
		if ok and type(decoded) == "table" then counts = decoded end
	end
	local discovered = 0
	for id, entry in guideRows do
		local count = counts[id] or 0
		if count > 0 then discovered += 1 end
		entry.Label.TextColor3 = entry.Data.Color
		entry.Label.Text = string.format("  %s  •  %s", entry.Data.Rarity, count > 0 and (entry.Data.Name .. "  ×" .. count) or "???  •  Not discovered")
	end
	bookTitle.Text = string.format("RIFTLING FIELD GUIDE  •  %d/%d", discovered, #CreatureCatalog.Species)
end
collection.Activated:Connect(function()
	refreshGuide()
	book.Visible = not book.Visible
end)
closeBook.Activated:Connect(function() book.Visible = false end)
player:GetAttributeChangedSignal("CollectionData"):Connect(refreshGuide)

local toast = Instance.new("TextLabel")
toast.Name = "EventToast"
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, 204)
toast.Size = UDim2.new(0.9, 0, 0, 50)
toast.BackgroundColor3 = Color3.fromRGB(22, 29, 53)
toast.BackgroundTransparency = 0.05
toast.Font = Enum.Font.GothamBold
toast.TextColor3 = palette.white
toast.TextSize = 16
toast.TextWrapped = true
toast.Visible = false
toast.Parent = gui
local toastConstraint = Instance.new("UISizeConstraint")
toastConstraint.MaxSize = Vector2.new(440, 50)
toastConstraint.Parent = toast
local toastCorner = Instance.new("UICorner")
toastCorner.CornerRadius = UDim.new(0, 14)
toastCorner.Parent = toast
local toastStroke = Instance.new("UIStroke")
toastStroke.Color = palette.ink
toastStroke.Transparency = 0.3
toastStroke.Thickness = 1
toastStroke.Parent = toast

local toastId = 0
local function showToast(message, color)
	toastId += 1
	local currentId = toastId
	toast.Text = message
	toast.TextColor3 = color
	toast.Visible = true
	task.delay(3.5, function()
		if currentId == toastId then toast.Visible = false end
	end)
end

local function formatTime(seconds)
	seconds = math.max(0, seconds or 0)
	return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

local compassPoints = { "↑", "↗", "→", "↘", "↓", "↙", "←", "↖" }

local function directionGlyph(fromPosition, toPosition)
	local camera = Workspace.CurrentCamera
	if not camera then return "" end
	local offset = Vector3.new(toPosition.X - fromPosition.X, 0, toPosition.Z - fromPosition.Z)
	if offset.Magnitude < 1 then return "•" end
	local forward = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
	local right = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z)
	if forward.Magnitude < 0.01 or right.Magnitude < 0.01 then return "" end
	forward = forward.Unit
	right = right.Unit
	local angle = math.atan2(right:Dot(offset.Unit), forward:Dot(offset.Unit))
	local index = (math.floor(angle / (math.pi / 4) + 0.5) % #compassPoints) + 1
	return compassPoints[index]
end

local function getNavigationHint()
	local currentPhase = player:GetAttribute("Phase") or "HOME"
	if currentPhase ~= "RIFT_RUN" then return nil end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return "FIND RIFTLINGS AND FOLLOW THE WAYFINDER LIGHTS" end

	local bagCount = player:GetAttribute("BagCount") or 0
	local targetPosition
	local targetName
	if bagCount > 0 then
		targetPosition = Vector3.zero
		targetName = "PORTAL"
		local distance = (Vector2.new(root.Position.X, root.Position.Z) - Vector2.zero).Magnitude
		if distance <= Config.SAFE_RADIUS then
			return "PORTAL CLOSE  •  STEP IN TO SECURE YOUR SATCHEL"
		end
	else
		local world = Workspace:FindFirstChild("RiftRunnersWorld")
		local pickups = world and world:FindFirstChild("WildRiftlings")
		local nearestDistance = math.huge
		for _, model in pickups and pickups:GetChildren() or {} do
			local part = model:IsA("Model") and model.PrimaryPart
			if part then
				local distance = (Vector2.new(root.Position.X, root.Position.Z) - Vector2.new(part.Position.X, part.Position.Z)).Magnitude
				if distance < nearestDistance then
					nearestDistance = distance
					targetPosition = part.Position
				end
			end
		end
		if not targetPosition then return "NO RIFTLINGS LEFT  •  HEAD BACK TO THE PORTAL" end
		targetName = "NEAREST RIFTLING"
	end

	local offset = targetPosition - root.Position
	local distance = math.floor(Vector2.new(offset.X, offset.Z).Magnitude + 0.5)
	return string.format("%s  •  %d AWAY  •  %s", targetName, distance, directionGlyph(root.Position, targetPosition))
end

local function refresh()
	local currentPhase = player:GetAttribute("Phase") or "HOME"
	local remaining = player:GetAttribute("RoundTime") or 0
	if currentPhase == "RIFT_RUN" then
		phase.Text = "RIFT RUN"
		phase.TextColor3 = palette.coral
		hint.Text = "Find Riftlings. Bank them at the portal before the rift closes."
	elseif currentPhase == "RIFT_SURGE" then
		phase.Text = "RIFT SURGE"
		phase.TextColor3 = palette.ink
		hint.Text = "The rift closed. Your banked finds are safe. Next run soon."
	else
		phase.Text = "HOME PORTAL • NEXT RUN"
		phase.TextColor3 = palette.gold
		hint.Text = "Find up to 6. Return to the glowing portal to bank them."
	end
	local navigationHint = getNavigationHint()
	if navigationHint then hint.Text = navigationHint end
	timer.Text = formatTime(remaining)
	local count = player:GetAttribute("BagCount") or 0
	bag.Text = string.format("BAG  %d/%d  •  %d at risk", count, 6, player:GetAttribute("BagValue") or 0)
	coins.Text = string.format("%d COINS", player:GetAttribute("Coins") or 0)
	collection.Text = string.format("GUIDE %d  •  %d RUNS", player:GetAttribute("CollectionCount") or 0, player:GetAttribute("Expeditions") or 0)
end

local function applyResponsiveScale()
	local camera = workspace.CurrentCamera
	if not camera then return end
	local compact = camera.ViewportSize.X < 430
	bag.TextSize = compact and 12 or 14
	coins.TextSize = compact and 12 or 14
	collection.TextSize = compact and 9 or 11
	shopButton.TextSize = compact and 9 or 11
	hint.TextSize = compact and 9 or 11
	phase.TextSize = compact and 12 or 14
	timer.TextSize = compact and 18 or 20
end

applyResponsiveScale()
if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveScale)
end

for _, attribute in { "Phase", "RoundTime", "BagCount", "BagValue", "Coins", "CollectionCount", "Expeditions" } do
	player:GetAttributeChangedSignal(attribute):Connect(refresh)
end

player:GetAttributeChangedSignal("LastCaughtNonce"):Connect(function()
	local name = player:GetAttribute("LastCaughtName") or "Riftling"
	local rarity = player:GetAttribute("LastCaughtRarity") or "Common"
	local colors = { Common = palette.ink, Uncommon = Color3.fromRGB(108, 209, 245), Rare = Color3.fromRGB(187, 151, 255), Epic = Color3.fromRGB(255, 131, 218), Mythic = palette.gold }
	showToast(string.upper(rarity) .. " FOUND!  •  " .. name .. "  •  Get it home!", colors[rarity] or palette.white)
end)

player:GetAttributeChangedSignal("LastBankValue"):Connect(function()
	local value = player:GetAttribute("LastBankValue") or 0
	if value > 0 then
		local count = player:GetAttribute("LastBankCount") or 0
		showToast(string.format("COLLECTION SECURED  •  %d Riftling(s)  •  +%d coins", count, value), palette.ink)
	end
end)

player:GetAttributeChangedSignal("LastLostNonce"):Connect(function()
	local count = player:GetAttribute("LastLostCount") or 0
	if count > 0 then showToast(string.format("SATCHEL LOST  •  %d Riftling(s) left behind", count), palette.coral) end
end)

player:GetAttributeChangedSignal("RoundWarning"):Connect(function()
	if player:GetAttribute("RoundWarning") == "WARDEN_ALERT" then
		showToast("THE WARDEN HEARD THE RIFT. RUN!", palette.coral)
	end
end)

player:GetAttributeChangedSignal("BagFullNonce"):Connect(function()
	showToast("SATCHEL FULL  •  Return to the portal to secure your finds", palette.gold)
end)

player:GetAttributeChangedSignal("RunSummaryNonce"):Connect(function()
	local secured = player:GetAttribute("RunSummarySecured") or 0
	local lost = player:GetAttribute("RunSummaryLost") or 0
	local coinsEarned = player:GetAttribute("RunSummaryCoins") or 0
	showToast(string.format("RUN REPORT  •  %d secured  •  %d lost  •  +%d coins", secured, lost, coinsEarned), palette.ink)
end)

local function showPersistenceNotice()
	if player:GetAttribute("PersistenceStatus") == "SESSION_ONLY" then
		showToast("SAVE UNAVAILABLE  •  Progress may not persist after you leave", palette.gold)
	end
end
player:GetAttributeChangedSignal("PersistenceStatus"):Connect(showPersistenceNotice)

player:GetAttributeChangedSignal("WardenHitNonce"):Connect(function()
	showToast("THE WARDEN CAUGHT UP! KEEP MOVING!", palette.coral)
end)

refresh()
showPersistenceNotice()
print("[Rift Runners] HUD ready (English)")

task.spawn(function()
	local trackedPickupFolder
	local pickupRemovedConnection
	while gui.Parent do
		if player:GetAttribute("Phase") == "RIFT_RUN" then
			local world = Workspace:FindFirstChild("RiftRunnersWorld")
			local pickups = world and world:FindFirstChild("WildRiftlings")
			if pickups ~= trackedPickupFolder then
				if pickupRemovedConnection then pickupRemovedConnection:Disconnect() end
				trackedPickupFolder = pickups
				pickupRemovedConnection = if pickups then pickups.ChildRemoved:Connect(function()
					if player:GetAttribute("Phase") == "RIFT_RUN" then task.defer(refresh) end
				end) else nil
			end
			refresh()
		else
			if pickupRemovedConnection then pickupRemovedConnection:Disconnect() end
			pickupRemovedConnection = nil
			trackedPickupFolder = nil
		end
		task.wait(1)
	end
end)
