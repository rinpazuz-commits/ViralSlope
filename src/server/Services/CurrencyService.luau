local PlayerDataService = require(script.Parent.PlayerDataService)

local CurrencyService = {}

function CurrencyService:Add(player, amount)
	if type(amount) ~= "number" or amount <= 0 then return end
	PlayerDataService:AddCoins(player, amount)
end

function CurrencyService:Get(player)
	local data = PlayerDataService:Get(player)
	return data and data.Coins or 0
end

return CurrencyService
