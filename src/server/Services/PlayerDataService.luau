local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local PlayerDataService = {}
local cache = {}
local storeAvailable, store = pcall(function()
	return DataStoreService:GetDataStore("NightshiftSalvage_PlayerData_v1")
end)
if not storeAvailable then
	store = nil
	warn("[Nightshift Salvage] Persistence is unavailable until this place is published; session data will still work.")
end

local DEFAULT_DATA = {
	Cash = 0,
	BestDistance = 0,
	Wins = 0,
	Extractions = 0,
	TotalRecovered = 0,
}

function PlayerDataService:Get(player)
	return cache[player]
end

function PlayerDataService:AddCash(player, amount)
	local data = cache[player]
	if not data then return end
	data.Cash += amount
	player:SetAttribute("Cash", data.Cash)
	return data.Cash
end

function PlayerDataService:AddBestDistance(player, distance)
	local data = cache[player]
	if not data then return end
	if distance > data.BestDistance then
		data.BestDistance = distance
		player:SetAttribute("BestDistance", distance)
	end
end

function PlayerDataService:AddExtraction(player, amount)
	local data = cache[player]
	if not data then return end
	data.Extractions += 1
	data.TotalRecovered += amount
	player:SetAttribute("Extractions", data.Extractions)
	player:SetAttribute("TotalRecovered", data.TotalRecovered)
end

local function save(player)
	local data = cache[player]
	if not data or not store then return end
	local payload = table.clone(data)
	local ok, err = pcall(function()
		store:UpdateAsync(tostring(player.UserId), function()
			return payload
		end)
	end)
	if not ok then warn("[Nightshift Salvage] Data save failed for " .. tostring(player.UserId) .. ": " .. tostring(err)) end
end

function PlayerDataService:InitPlayer(player)
	cache[player] = table.clone(DEFAULT_DATA)
	local data = cache[player]
	local ok, saved = false, nil
	if store then
		ok, saved = pcall(function()
			return store:GetAsync(tostring(player.UserId))
		end)
	end
	if ok and type(saved) == "table" then
		for key, value in saved do
			if data[key] ~= nil and type(value) == "number" then data[key] = value end
		end
	elseif store and not ok then
		warn("[Nightshift Salvage] Data load failed for " .. tostring(player.UserId) .. ": " .. tostring(saved))
	end
	player:SetAttribute("Cash", data.Cash)
	player:SetAttribute("BestDistance", data.BestDistance)
	player:SetAttribute("Extractions", data.Extractions)
	player:SetAttribute("TotalRecovered", data.TotalRecovered)
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
