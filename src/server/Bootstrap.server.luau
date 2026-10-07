local Services = script.Parent.Services

local PlayerDataService = require(Services.PlayerDataService)
local RiftService = require(Services.RiftService)

PlayerDataService:Init()
RiftService:Init()

print("[Rift Runners] Server booted")
