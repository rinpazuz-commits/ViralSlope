local Services = script.Parent.Services

local PlayerDataService = require(Services.PlayerDataService)
local RiftService = require(Services.RiftService)
local CosmeticService = require(Services.CosmeticService)

PlayerDataService:Init()
RiftService:Init()
CosmeticService:Init()

print("[Rift Runners] Server booted")
