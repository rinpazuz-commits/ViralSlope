local Services = script.Parent.Services

local PlayerDataService = require(Services.PlayerDataService)
local ExpeditionService = require(Services.ExpeditionService)

PlayerDataService:Init()
ExpeditionService:Init()

print("[Nightshift Salvage] Server booted")
