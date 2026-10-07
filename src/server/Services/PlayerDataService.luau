local Players = game:GetService("Players")

local PlayerDataService = {}
local cache = {}

local DEFAULT_DATA = {
	Cash = 0,
	BestDistance = 0,
	Wins = 0,
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

function PlayerDataService:InitPlayer(player)
	cache[player] = table.clone(DEFAULT_DATA)
	player:SetAttribute("Cash", DEFAULT_DATA.Cash)
	player:SetAttribute("BestDistance", DEFAULT_DATA.BestDistance)
end

function PlayerDataService:RemovePlayer(player)
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
end

return PlayerDataService
