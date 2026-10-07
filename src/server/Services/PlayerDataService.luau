local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CreatureCatalog = require(ReplicatedStorage.Shared.CreatureCatalog)
local CosmeticCatalog = require(ReplicatedStorage.Shared.CosmeticCatalog)

local PlayerDataService = {}
local cache = {}
local saveInProgress = {}
local store

local ok, result = pcall(function()
	return DataStoreService:GetDataStore("RiftRunners_PlayerData_v1")
end)
if ok then
	store = result
else
	warn("[Rift Runners] DataStore unavailable; progress is session-only: " .. tostring(result))
end

local DEFAULT_DATA = {
	SchemaVersion = 3,
	Coins = 0,
	Collection = {},
	Expeditions = 0,
	TotalSecured = 0,
	OwnedCosmetics = {},
	EquippedCosmetic = "",
}

local function countCollection(collection)
	local total = 0
	for _, count in collection do
		total += count
	end
	return total
end

local function encodeCollection(collection)
	local snapshot = {}
	for _, creature in CreatureCatalog.Species do
		snapshot[creature.Id] = collection[creature.Id] or 0
	end
	return HttpService:JSONEncode(snapshot)
end

local function encodeOwnedCosmetics(owned)
	local snapshot = {}
	for _, item in CosmeticCatalog.Items do
		snapshot[item.Id] = owned[item.Id] == true
	end
	return HttpService:JSONEncode(snapshot)
end

local function sanitizeNumber(value, minimum, maximum)
	if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
		return minimum
	end
	return math.floor(math.clamp(value, minimum, maximum))
end

local function loadData(player)
	local data = table.clone(DEFAULT_DATA)
	data.Collection = {}
	data.OwnedCosmetics = {}
	if not store then return data, false end

	local success, saved = pcall(function()
		return store:GetAsync(tostring(player.UserId))
	end)
	if not success then
		warn("[Rift Runners] Data load failed for " .. player.UserId .. ": " .. tostring(saved))
		return data, false
	end
	if type(saved) ~= "table" then return data, true end

	data.Coins = sanitizeNumber(saved.Coins, 0, 1_000_000_000)
	data.SchemaVersion = 3
	data.Expeditions = sanitizeNumber(saved.Expeditions, 0, 10_000_000)
	data.TotalSecured = sanitizeNumber(saved.TotalSecured, 0, 1_000_000_000_000)
	if type(saved.Collection) == "table" then
		for id, count in saved.Collection do
			if type(id) == "string" and #id <= 40 and type(count) == "number" then
				data.Collection[id] = sanitizeNumber(count, 0, 1_000_000)
			end
		end
	end
	if type(saved.OwnedCosmetics) == "table" then
		for id, isOwned in saved.OwnedCosmetics do
			if type(id) == "string" and isOwned == true and CosmeticCatalog.Get(id) then
				data.OwnedCosmetics[id] = true
			end
		end
	end
	if type(saved.EquippedCosmetic) == "string"
		and data.OwnedCosmetics[saved.EquippedCosmetic]
		and CosmeticCatalog.Get(saved.EquippedCosmetic)
	then
		data.EquippedCosmetic = saved.EquippedCosmetic
	end
	return data, true
end

local function makeSnapshot(data)
	local collection = {}
	for id, count in data.Collection do
		collection[id] = count
	end
	return {
		SchemaVersion = 3,
		Coins = data.Coins,
		Collection = collection,
		Expeditions = data.Expeditions,
		TotalSecured = data.TotalSecured,
		OwnedCosmetics = table.clone(data.OwnedCosmetics),
		EquippedCosmetic = data.EquippedCosmetic,
	}
end

local function save(player)
	local data = cache[player]
	if not data or not data.CanSave or not store then return end
	while saveInProgress[player] do task.wait(0.1) end
	saveInProgress[player] = true
	local payload = makeSnapshot(data)
	local success, err = pcall(function()
		store:UpdateAsync(tostring(player.UserId), function()
			return payload
		end)
	end)
	saveInProgress[player] = nil
	if not success then
		warn("[Rift Runners] Data save failed for " .. player.UserId .. ": " .. tostring(err))
	end
end

function PlayerDataService:Get(player)
	return cache[player]
end

function PlayerDataService:AddCoins(player, amount)
	local data = cache[player]
	if not data then return 0 end
	amount = sanitizeNumber(amount, 0, 1_000_000_000)
	data.Coins = math.min(1_000_000_000, data.Coins + amount)
	player:SetAttribute("Coins", data.Coins)
	local stats = player:FindFirstChild("leaderstats")
	local coinsValue = stats and stats:FindFirstChild("Coins")
	if coinsValue then coinsValue.Value = data.Coins end
	return data.Coins
end

local function updateCosmeticAttributes(player, data)
	player:SetAttribute("OwnedCosmetics", encodeOwnedCosmetics(data.OwnedCosmetics))
	player:SetAttribute("EquippedCosmetic", data.EquippedCosmetic or "")
end

function PlayerDataService:GetCosmeticState(player)
	local data = cache[player]
	if not data then return nil end
	return {
		Coins = data.Coins,
		Owned = table.clone(data.OwnedCosmetics),
		Equipped = data.EquippedCosmetic,
	}
end

function PlayerDataService:BuyCosmetic(player, itemId)
	local data = cache[player]
	local item = type(itemId) == "string" and CosmeticCatalog.Get(itemId) or nil
	if not data or not item then return false, "INVALID_ITEM" end
	if data.OwnedCosmetics[item.Id] then return false, "ALREADY_OWNED" end
	if data.Coins < item.Price then return false, "NOT_ENOUGH_COINS" end

	-- No yielding between checking the balance and charging it: concurrent requests
	-- from a single player cannot buy the same item twice or overspend the cache.
	data.Coins -= item.Price
	data.OwnedCosmetics[item.Id] = true
	data.EquippedCosmetic = item.Id
	player:SetAttribute("Coins", data.Coins)
	local stats = player:FindFirstChild("leaderstats")
	local coinsValue = stats and stats:FindFirstChild("Coins")
	if coinsValue then coinsValue.Value = data.Coins end
	updateCosmeticAttributes(player, data)
	return true, "PURCHASED"
end

function PlayerDataService:EquipCosmetic(player, itemId)
	local data = cache[player]
	if not data then return false, "DATA_NOT_READY" end
	if itemId == "" or itemId == nil then
		data.EquippedCosmetic = ""
		updateCosmeticAttributes(player, data)
		return true, "UNEQUIPPED"
	end
	if type(itemId) ~= "string" or not CosmeticCatalog.Get(itemId) then
		return false, "INVALID_ITEM"
	end
	if not data.OwnedCosmetics[itemId] then return false, "NOT_OWNED" end
	data.EquippedCosmetic = itemId
	updateCosmeticAttributes(player, data)
	return true, "EQUIPPED"
end

function PlayerDataService:AddCreature(player, creature)
	local data = cache[player]
	if not data or type(creature) ~= "table" or type(creature.Id) ~= "string" then return end
	data.Collection[creature.Id] = (data.Collection[creature.Id] or 0) + 1
	player:SetAttribute("CollectionCount", countCollection(data.Collection))
	player:SetAttribute("CollectionData", encodeCollection(data.Collection))
	local stats = player:FindFirstChild("leaderstats")
	local collectionValue = stats and stats:FindFirstChild("Critters")
	if collectionValue then collectionValue.Value = countCollection(data.Collection) end
end

function PlayerDataService:CompleteExpedition(player, totalSecured, countExpedition)
	local data = cache[player]
	if not data then return end
	if countExpedition ~= false then
		data.Expeditions += 1
		player:SetAttribute("Expeditions", data.Expeditions)
	end
	data.TotalSecured += sanitizeNumber(totalSecured, 0, 1_000_000_000)
	player:SetAttribute("TotalSecured", data.TotalSecured)
end

function PlayerDataService:InitPlayer(player)
	local data, canSave = loadData(player)
	data.CanSave = canSave
	cache[player] = data
	local data = cache[player]
	player:SetAttribute("PersistenceStatus", canSave and "SAVED" or "SESSION_ONLY")
	player:SetAttribute("Coins", data.Coins)
	player:SetAttribute("CollectionCount", countCollection(data.Collection))
	player:SetAttribute("CollectionData", encodeCollection(data.Collection))
	player:SetAttribute("Expeditions", data.Expeditions)
	player:SetAttribute("TotalSecured", data.TotalSecured)
	updateCosmeticAttributes(player, data)

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player
	local coinsValue = Instance.new("IntValue")
	coinsValue.Name = "Coins"
	coinsValue.Value = data.Coins
	coinsValue.Parent = leaderstats
	local crittersValue = Instance.new("IntValue")
	crittersValue.Name = "Critters"
	crittersValue.Value = countCollection(data.Collection)
	crittersValue.Parent = leaderstats
	player:SetAttribute("DataReady", true)
end

function PlayerDataService:RemovePlayer(player)
	save(player)
	cache[player] = nil
end

function PlayerDataService:Init()
	Players.PlayerAdded:Connect(function(player)
		self:InitPlayer(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		self:RemovePlayer(player)
	end)
	for _, player in Players:GetPlayers() do
		self:InitPlayer(player)
	end

	task.spawn(function()
		while true do
			task.wait(90)
			for _, player in Players:GetPlayers() do
				task.spawn(save, player)
			end
		end
	end)

	game:BindToClose(function()
		local pending = 0
		for _, player in Players:GetPlayers() do
			pending += 1
			task.spawn(function()
				save(player)
				pending -= 1
			end)
		end
		local deadline = os.clock() + 25
		while pending > 0 and os.clock() < deadline do task.wait(0.1) end
	end)
end

return PlayerDataService
