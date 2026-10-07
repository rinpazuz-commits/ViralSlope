local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local PlayerDataService = require(script.Parent.PlayerDataService)
local CurrencyService = require(script.Parent.CurrencyService)

local RunService = {}
local START = Vector3.new(0, 48, 0)
local FINISH_Z = 1400
local CASH_PER_STUD = 0.5

local function makePart(parent, name, size, cframe, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function buildSlope()
	local old = Workspace:FindFirstChild("ViralSlopeWorld")
	if old then old:Destroy() end

	local world = Instance.new("Folder")
	world.Name = "ViralSlopeWorld"
	world.Parent = Workspace

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "SlopeStart"
	spawn.Size = Vector3.new(34, 2, 34)
	spawn.CFrame = CFrame.new(START - Vector3.new(0, 4, 0))
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Color = Color3.fromRGB(55, 220, 170)
	spawn.Material = Enum.Material.Neon
	spawn.Parent = world

	local angle = math.rad(-12)
	local direction = CFrame.Angles(angle, 0, 0)
	for index = 0, 19 do
		local z = 35 + index * 70
		local centerY = START.Y - math.tan(math.rad(12)) * z
		local deck = makePart(world, "SlopeSegment", Vector3.new(64, 4, 74), CFrame.new(0, centerY, z) * direction, Color3.fromRGB(42, 54, 80), Enum.Material.Slate)
		deck:SetAttribute("Segment", index + 1)

		makePart(world, "LeftRail", Vector3.new(3, 8, 74), CFrame.new(-34, centerY + 4, z) * direction, Color3.fromRGB(70, 95, 130), Enum.Material.Metal)
		makePart(world, "RightRail", Vector3.new(3, 8, 74), CFrame.new(34, centerY + 4, z) * direction, Color3.fromRGB(70, 95, 130), Enum.Material.Metal)

		if index % 2 == 0 then
			local side = (index % 4 == 0) and -14 or 14
			local hazard = makePart(world, "Bumper", Vector3.new(14, 5, 8), CFrame.new(side, centerY + 5, z + 12), Color3.fromRGB(255, 92, 100), Enum.Material.Neon)
			hazard:SetAttribute("Hazard", true)
			hazard.Touched:Connect(function(hit)
				local character = hit:FindFirstAncestorOfClass("Model")
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if humanoid then humanoid.Health = 0 end
			end)
		end

		if index > 0 and index % 5 == 0 then
			local checkpoint = makePart(world, "Checkpoint", Vector3.new(28, 1, 8), CFrame.new(0, centerY + 3, z - 25), Color3.fromRGB(65, 190, 255), Enum.Material.Neon)
			checkpoint:SetAttribute("CheckpointZ", z)
		end
	end

	local finishY = START.Y - math.tan(math.rad(12)) * FINISH_Z
	local finish = makePart(world, "Finish", Vector3.new(62, 2, 14), CFrame.new(0, finishY + 3, FINISH_Z), Color3.fromRGB(255, 216, 80), Enum.Material.Neon)
	finish.Touched:Connect(function(hit)
		local character = hit:FindFirstAncestorOfClass("Model")
		local player = character and Players:GetPlayerFromCharacter(character)
		if not player or player:GetAttribute("RunFinished") then return end
		player:SetAttribute("RunFinished", true)
		local distance = math.max(0, math.floor(FINISH_Z - START.Z))
		local reward = math.floor(distance * CASH_PER_STUD)
		PlayerDataService:AddBestDistance(player, distance)
		CurrencyService:Add(player, reward)
		player:SetAttribute("LastRunReward", reward)
		task.delay(3, function()
			if player.Parent then
				player:SetAttribute("RunFinished", false)
				player:LoadCharacter()
			end
		end)
	end)

	local killPlane = makePart(world, "FallReset", Vector3.new(500, 4, FINISH_Z + 500), CFrame.new(0, -110, FINISH_Z / 2), Color3.fromRGB(255, 0, 0))
	killPlane.Transparency = 1
	killPlane.Touched:Connect(function(hit)
		local character = hit:FindFirstAncestorOfClass("Model")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid.Health = 0 end
	end)
end

local function trackPlayer(player)
	player:SetAttribute("RunFinished", false)
	player:SetAttribute("RunDistance", 0)
	player:SetAttribute("LastRunReward", 0)
	player.CharacterAdded:Connect(function(character)
		player:SetAttribute("RunFinished", false)
		local root = character:WaitForChild("HumanoidRootPart", 10)
		if not root then return end
		local startZ = root.Position.Z
		while character.Parent and root.Parent do
			local distance = math.max(0, math.floor(root.Position.Z - startZ))
			player:SetAttribute("RunDistance", distance)
			local data = PlayerDataService:Get(player)
			if data then PlayerDataService:AddBestDistance(player, distance) end
			task.wait(0.25)
		end
	end)
end

function RunService:Init()
	buildSlope()
	for _, player in Players:GetPlayers() do trackPlayer(player) end
	Players.PlayerAdded:Connect(trackPlayer)
	print("[ViralSlope] Downhill run ready")
end

return RunService
