local PlayerDataService = require(script.Parent.PlayerDataService)
local Config = require(game:GetService("ReplicatedStorage").Shared.Config)

local CurrencyService = {}

function CurrencyService:Add(player, amount)
	if amount <= 0 then return end
	local data = PlayerDataService:Get(player)
	if not data then return end
	amount = math.min(amount, Config.MAX_CASH - data.Cash)
	if amount <= 0 then return end
	PlayerDataService:AddCash(player, amount)
end

function CurrencyService:Get(player)
	local data = PlayerDataService:Get(player)
	return data and data.Cash or 0
end

return CurrencyService
