local Services = script.Parent.Services

local PlayerDataService = require(Services.PlayerDataService)
local RunService = require(Services.RunService)

PlayerDataService:Init()
RunService:Init()

print("[ViralSlope] Server booted")
