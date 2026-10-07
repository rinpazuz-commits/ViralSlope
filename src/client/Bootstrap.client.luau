local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

print(string.format("[%s] Client booted v%s", Config.GAME_NAME, Config.VERSION))