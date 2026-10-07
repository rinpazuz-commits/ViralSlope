local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local PlayerDataService = require(script.Parent.PlayerDataService)
local CurrencyService = require(script.Parent.CurrencyService)

local ExpeditionService = {}
local ROUND_SECONDS = 100
local BREAK_SECONDS = 12
local MAX_PICKUPS = 24
local rng = Random.new()
local active = false
local world
local echo
local echoEyes

local COLORS = {
	Color3.fromRGB(70, 239, 210),
	Color3.fromRGB(92, 169, 255),
	Color3.fromRGB(194, 112, 255),
}

local function part(parent, name, size, position, color, material, shape)
	local instance = Instance.new("Part")
	instance.Name = name
	instance.Size = size
	instance.Position = position
	instance.Anchored = true
	instance.Color = color
	instance.Material = material or Enum.Material.Slate
	instance.TopSurface = Enum.SurfaceType.Smooth
	instance.BottomSurface = Enum.SurfaceType.Smooth
	if shape then instance.Shape = shape end
	instance.Parent = parent
	return instance
end

local function makeTree(parent, x, z, scale)
	part(parent, "PineTrunk", Vector3.new(3, 15, 3) * scale, Vector3.new(x, 7.5 * scale, z), Color3.fromRGB(71, 53, 49), Enum.Material.Wood)
	for layer = 1, 3 do
		local foliage = part(parent, "PineCanopy", Vector3.new(14 - layer * 2, 13, 14 - layer * 2) * scale, Vector3.new(x, (14 + layer * 7) * scale, z), Color3.fromRGB(22, 63 + layer * 5, 66), Enum.Material.Grass, Enum.PartType.Ball)
		foliage.CanCollide = false
	end
end

local function setPhase(name, seconds)
	for _, player in Players:GetPlayers() do
		player:SetAttribute("Phase", name)
		player:SetAttribute("RoundTime", seconds or 0)
	end
end

local function clearHaul(player)
	player:SetAttribute("HaulItems", 0)
	player:SetAttribute("HaulValue", 0)
end

local function buildWorld()
	local old = Workspace:FindFirstChild("NightshiftWorld")
	if old then old:Destroy() end
	local defaultSpawn = Workspace:FindFirstChild("SpawnLocation")
	if defaultSpawn then defaultSpawn:Destroy() end
	local baseplate = Workspace:FindFirstChild("Baseplate")
	if baseplate then baseplate:Destroy() end

	world = Instance.new("Folder")
	world.Name = "NightshiftWorld"
	world.Parent = Workspace

	Lighting.ClockTime = 0.2
	Lighting.Brightness = 1.6
	Lighting.Ambient = Color3.fromRGB(39, 51, 66)
	Lighting.OutdoorAmbient = Color3.fromRGB(29, 40, 55)
	Lighting.FogColor = Color3.fromRGB(14, 26, 39)
	Lighting.FogStart = 110
	Lighting.FogEnd = 500

	local atmosphere = Lighting:FindFirstChild("NightshiftAtmosphere") or Instance.new("Atmosphere")
	atmosphere.Name = "NightshiftAtmosphere"
	atmosphere.Density = 0.34
	atmosphere.Offset = 0.08
	atmosphere.Color = Color3.fromRGB(115, 151, 185)
	atmosphere.Decay = Color3.fromRGB(35, 50, 72)
	atmosphere.Parent = Lighting

	part(world, "ForestFloor", Vector3.new(520, 8, 520), Vector3.new(0, -5, 0), Color3.fromRGB(26, 39, 42), Enum.Material.Grass)
	local shelter = part(world, "Shelter", Vector3.new(54, 2, 54), Vector3.new(0, 2, 0), Color3.fromRGB(48, 69, 77), Enum.Material.Metal)
	shelter:SetAttribute("SafeZone", true)
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "ShelterSpawn"
	spawn.Size = Vector3.new(18, 1, 18)
	spawn.Position = Vector3.new(0, 4, 0)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Color = Color3.fromRGB(63, 222, 196)
	spawn.Material = Enum.Material.Neon
	spawn.Parent = world

	local beacon = part(world, "SignalBeacon", Vector3.new(2, 12, 2), Vector3.new(21, 9, -18), Color3.fromRGB(78, 240, 210), Enum.Material.Neon)
	beacon.CanCollide = false
	local beaconLight = Instance.new("PointLight")
	beaconLight.Color = beacon.Color
	beaconLight.Range = 30
	beaconLight.Brightness = 0.8
	beaconLight.Parent = beacon

	for _, x in {-25, 25} do
		for _, z in {-25, 25} do
			local pillar = part(world, "ShelterPillar", Vector3.new(2, 20, 2), Vector3.new(x, 12, z), Color3.fromRGB(76, 102, 111), Enum.Material.Metal)
			pillar.CanCollide = true
		end
	end

	local extract = part(world, "ExtractionZone", Vector3.new(40, 1, 40), Vector3.new(0, 3.6, 0), Color3.fromRGB(57, 208, 186), Enum.Material.SmoothPlastic)
	extract.Transparency = 1
	extract.CanCollide = false
	for _, x in {-18, 18} do
		for _, z in {-18, 18} do
			local marker = part(world, "ShelterMarker", Vector3.new(1.2, 5, 1.2), Vector3.new(x, 5, z), Color3.fromRGB(77, 225, 195), Enum.Material.Neon)
			marker.CanCollide = false
			local markerLight = Instance.new("PointLight")
			markerLight.Color = marker.Color
			markerLight.Range = 10
			markerLight.Brightness = 0.45
			markerLight.Parent = marker
		end
	end
	extract.Touched:Connect(function(hit)
		local character = hit:FindFirstAncestorOfClass("Model")
		local player = character and Players:GetPlayerFromCharacter(character)
		if not active or not player then return end
		local root = character:FindFirstChild("HumanoidRootPart")
		if not root or (root.Position - extract.Position).Magnitude > 32 then return end
		local value = player:GetAttribute("HaulValue") or 0
		if value <= 0 then return end
		CurrencyService:Add(player, value)
		player:SetAttribute("LastDeposit", 0)
		player:SetAttribute("LastDeposit", value)
		PlayerDataService:AddExtraction(player, value)
		clearHaul(player)
	end)

	for index = 1, 52 do
		local angle = rng:NextNumber(0, math.pi * 2)
		local radius = rng:NextNumber(58, 235)
		makeTree(world, math.cos(angle) * radius, math.sin(angle) * radius, rng:NextNumber(0.75, 1.35))
	end

	for index = 1, 5 do
		local angle = index * math.pi * 2 / 5
		local x, z = math.cos(angle) * 160, math.sin(angle) * 160
		local cabin = part(world, "AbandonedRelay", Vector3.new(28, 18, 24), Vector3.new(x, 5, z), Color3.fromRGB(50, 61, 69), Enum.Material.Metal)
		local roof = part(world, "RelayRoof", Vector3.new(34, 3, 30), Vector3.new(x, 15, z), Color3.fromRGB(103, 75, 59), Enum.Material.WoodPlanks)
		local lamp = part(world, "BrokenSignal", Vector3.new(2, 6, 2), Vector3.new(x, 21, z), Color3.fromRGB(255, 124, 91), Enum.Material.Neon)
		lamp.CanCollide = false
		local light = Instance.new("PointLight")
		light.Color = lamp.Color
		light.Range = 22
		light.Brightness = 1.2
		light.Parent = lamp
		cabin:SetAttribute("Relay", index)
		roof.CanCollide = true
	end

	echo = part(world, "TheEcho", Vector3.new(10, 10, 10), Vector3.new(0, 8, -60), Color3.fromRGB(13, 18, 29), Enum.Material.Neon, Enum.PartType.Ball)
	echo.CanCollide = false
	echo.Transparency = 0.12
	echoEyes = part(world, "EchoEyes", Vector3.new(3, 0.8, 1), echo.Position + Vector3.new(0, 1, -4), Color3.fromRGB(255, 70, 94), Enum.Material.Neon)
	echoEyes.CanCollide = false
	local echoLight = Instance.new("PointLight")
	echoLight.Color = echoEyes.Color
	echoLight.Range = 15
	echoLight.Brightness = 1.4
	echoLight.Parent = echoEyes
end

local function spawnSalvage()
	local old = world:FindFirstChild("Salvage")
	if old then old:Destroy() end
	local folder = Instance.new("Folder")
	folder.Name = "Salvage"
	folder.Parent = world
	for index = 1, MAX_PICKUPS do
		local angle = rng:NextNumber(0, math.pi * 2)
		local radius = rng:NextNumber(65, 225)
		local x, z = math.cos(angle) * radius, math.sin(angle) * radius
		local rarity = rng:NextInteger(1, 3)
		local worth = ({10, 25, 60})[rarity]
		local crystal = part(folder, "SignalShard", Vector3.new(3, 4, 3), Vector3.new(x, 3, z), COLORS[rarity], Enum.Material.Neon, Enum.PartType.Ball)
		crystal:SetAttribute("Worth", worth)
		local light = Instance.new("PointLight")
		light.Color = COLORS[rarity]
		light.Range = 12 + rarity * 3
		light.Brightness = 0.8 + rarity * 0.5
		light.Parent = crystal
		local claimed = false
		crystal.Touched:Connect(function(hit)
			if claimed or not active then return end
			local character = hit:FindFirstAncestorOfClass("Model")
			local player = character and Players:GetPlayerFromCharacter(character)
			if not player then return end
			local root = character:FindFirstChild("HumanoidRootPart")
			if not root or (root.Position - crystal.Position).Magnitude > 10 then return end
			claimed = true
			player:SetAttribute("HaulItems", (player:GetAttribute("HaulItems") or 0) + 1)
			player:SetAttribute("HaulValue", (player:GetAttribute("HaulValue") or 0) + worth)
			crystal:Destroy()
		end)
	end
end

local function updateEcho()
	if not echo or not echo.Parent then return end
	local target, targetRoot
	for _, player in Players:GetPlayers() do
		if (player:GetAttribute("HaulValue") or 0) > 0 then
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if root and (not targetRoot or (root.Position - echo.Position).Magnitude < (targetRoot.Position - echo.Position).Magnitude) then
				target, targetRoot = player, root
			end
		end
	end
	if targetRoot then
		local delta = targetRoot.Position - echo.Position
		if delta.Magnitude > 0 then echo.Position += delta.Unit * math.min(8, delta.Magnitude) end
		if echoEyes then echoEyes.Position = echo.Position + Vector3.new(0, 1, -4) end
		if delta.Magnitude < 8 then
			local humanoid = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
			if humanoid then humanoid:TakeDamage(35) end
		end
	else
		echo.Position = echo.Position:Lerp(Vector3.new(0, 8, -60), 0.12)
		if echoEyes then echoEyes.Position = echo.Position + Vector3.new(0, 1, -4) end
	end
end

local function preparePlayer(player)
	player:SetAttribute("Phase", "REFUGE")
	player:SetAttribute("RoundTime", 0)
	clearHaul(player)
	player:SetAttribute("LastDeposit", 0)
	player:SetAttribute("LostValue", 0)
	player.CharacterAdded:Connect(function(character)
		clearHaul(player)
		local humanoid = character:WaitForChild("Humanoid", 10)
		if humanoid then
			humanoid.Died:Connect(function()
				if (player:GetAttribute("HaulItems") or 0) > 0 then
					player:SetAttribute("LostValue", player:GetAttribute("HaulValue") or 0)
					clearHaul(player)
				end
			end)
		end
	end)
end

local function runLoop()
	while true do
		active = false
		for seconds = BREAK_SECONDS, 1, -1 do
			setPhase("REFUGE", seconds)
			task.wait(1)
		end
		spawnSalvage()
		active = true
		for _, player in Players:GetPlayers() do clearHaul(player) end
		for seconds = ROUND_SECONDS, 0, -1 do
			setPhase("EXPEDITION", seconds)
			updateEcho()
			task.wait(1)
		end
		active = false
		for _, player in Players:GetPlayers() do
			if (player:GetAttribute("HaulValue") or 0) > 0 then
				player:SetAttribute("LostValue", 0)
				player:SetAttribute("LostValue", player:GetAttribute("HaulValue"))
				clearHaul(player)
			end
		end
		setPhase("NIGHTFALL", 0)
		task.wait(4)
	end
end

function ExpeditionService:Init()
	buildWorld()
	for _, player in Players:GetPlayers() do preparePlayer(player) end
	Players.PlayerAdded:Connect(preparePlayer)
	task.spawn(runLoop)
	print("[Nightshift Salvage] Expedition service ready")
end

return ExpeditionService
