local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local CreatureCatalog = require(ReplicatedStorage.Shared.CreatureCatalog)
local PlayerDataService = require(script.Parent.PlayerDataService)
local CurrencyService = require(script.Parent.CurrencyService)

local RiftService = {}
local rng = Random.new()
local active = false
local wardenAwake = false
local wardenWakePending = false
local secondsRemaining = 0
local world
local salvageFolder
local warden
local wardenEyes
local bankTrigger
local bags = {}
local baseWalkSpeeds = {}
local roundSummary = {}
local lastFullNotice = setmetatable({}, { __mode = "k" })
local lastHitAt = setmetatable({}, { __mode = "k" })
local MAX_BAG = 6
local BAG_SPEED_PENALTY = 0.55
local WARDEN_HOME = Vector3.new(0, 11, -252)
local SAFE_CENTER = Vector3.new(0, 0, 0)

local RARITY_COLORS = {
	Common = Color3.fromRGB(140, 231, 190),
	Uncommon = Color3.fromRGB(100, 208, 245),
	Rare = Color3.fromRGB(174, 129, 255),
	Epic = Color3.fromRGB(255, 118, 211),
	Mythic = Color3.fromRGB(255, 205, 91),
}

local function makePart(parent, name, size, position, color, material, shape)
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.Position = position
	item.Anchored = true
	item.Color = color
	item.Material = material or Enum.Material.SmoothPlastic
	item.TopSurface = Enum.SurfaceType.Smooth
	item.BottomSurface = Enum.SurfaceType.Smooth
	item.CastShadow = true
	if shape then item.Shape = shape end
	item.Parent = parent
	return item
end

local function addLight(parent, color, range, brightness)
	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = range
	light.Brightness = brightness
	light.Shadows = false
	light.Parent = parent
	return light
end

local function createAlienPlant(parent, position, scale, tint)
	local stem = makePart(parent, "RibbonStem", Vector3.new(1.1, 7, 1.1) * scale, position + Vector3.new(0, 3.5 * scale, 0), Color3.fromRGB(56, 104, 114), Enum.Material.SmoothPlastic)
	stem.CanCollide = false
	for index = 1, 3 do
		local angle = (index - 1) * math.pi * 2 / 3
		local leaf = makePart(parent, "GlowLeaf", Vector3.new(4, 2, 3) * scale, position + Vector3.new(math.cos(angle) * 2 * scale, (5 + index * 1.1) * scale, math.sin(angle) * 2 * scale), tint, Enum.Material.Neon, Enum.PartType.Ball)
		leaf.CanCollide = false
	end
end

local function createRiftOutcrop(parent, position, accent, scale)
	local rock = makePart(parent, "RiftStone", Vector3.new(10, 4, 9) * scale, position + Vector3.new(0, 1.7 * scale, 0), Color3.fromRGB(50, 66, 95), Enum.Material.Slate, Enum.PartType.Ball)
	rock.CanCollide = false
	rock.CanTouch = false
	rock.CanQuery = false
	local height = rng:NextNumber(9, 16) * scale
	local shard = makePart(parent, "GlowShard", Vector3.new(2.1, height, 2.1) * scale, position + Vector3.new(rng:NextNumber(-2, 2) * scale, height / 2 + 2 * scale, rng:NextNumber(-2, 2) * scale), accent, Enum.Material.Neon, Enum.PartType.Ball)
	shard.CanCollide = false
	shard.CanTouch = false
	shard.CanQuery = false
	local second = makePart(parent, "GlowShard", Vector3.new(1.4, height * 0.72, 1.4) * scale, position + Vector3.new(3 * scale, height * 0.37 + 2 * scale, -2 * scale), accent:Lerp(Color3.new(1, 1, 1), 0.24), Enum.Material.Neon, Enum.PartType.Ball)
	second.CanCollide = false
	second.CanTouch = false
	second.CanQuery = false
end

local function buildWorld()
	local previous = Workspace:FindFirstChild("RiftRunnersWorld")
	if previous then previous:Destroy() end
	for _, name in { "SpawnLocation", "Baseplate" } do
		local old = Workspace:FindFirstChild(name)
		if old then old:Destroy() end
	end

	world = Instance.new("Folder")
	world.Name = "RiftRunnersWorld"
	world.Parent = Workspace

	Lighting.ClockTime = 14.2
	Lighting.Brightness = 2.1
	Lighting.Ambient = Color3.fromRGB(103, 111, 150)
	Lighting.OutdoorAmbient = Color3.fromRGB(122, 132, 175)
	Lighting.FogColor = Color3.fromRGB(117, 142, 176)
	Lighting.FogStart = 280
	Lighting.FogEnd = 720
	Lighting.GlobalShadows = true

	local atmosphere = Lighting:FindFirstChild("RiftRunnersAtmosphere") or Instance.new("Atmosphere")
	atmosphere.Name = "RiftRunnersAtmosphere"
	atmosphere.Density = 0.22
	atmosphere.Offset = 0.08
	atmosphere.Color = Color3.fromRGB(192, 202, 255)
	atmosphere.Decay = Color3.fromRGB(97, 120, 171)
	atmosphere.Glare = 0.12
	atmosphere.Haze = 1.2
	atmosphere.Parent = Lighting

	local bloom = Lighting:FindFirstChild("RiftRunnersBloom") or Instance.new("BloomEffect")
	bloom.Name = "RiftRunnersBloom"
	bloom.Intensity = 0.18
	bloom.Size = 18
	bloom.Threshold = 1.2
	bloom.Parent = Lighting

	makePart(world, "RiftworldFloor", Vector3.new(620, 10, 620), Vector3.new(0, -5, 0), Color3.fromRGB(37, 48, 78), Enum.Material.Slate)

	local hub = makePart(world, "HomePlatform", Vector3.new(2, 76, 76), Vector3.new(0, 1, 0), Color3.fromRGB(55, 69, 107), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
	hub.Orientation = Vector3.new(0, 0, 90)
	hub:SetAttribute("SafeZone", true)
	local trim = makePart(world, "HomePlatformTrim", Vector3.new(0.6, 80, 80), Vector3.new(0, 0.2, 0), Color3.fromRGB(88, 227, 229), Enum.Material.Neon, Enum.PartType.Cylinder)
	trim.Orientation = hub.Orientation
	trim.CanCollide = false
	trim.Transparency = 0.58
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "RiftRunnersSpawn"
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.Position = Vector3.new(0, 2.5, 0)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Color = Color3.fromRGB(82, 190, 194)
	spawn.Material = Enum.Material.SmoothPlastic
	spawn.Transparency = 0.08
	spawn.Parent = world

	-- The return portal is visible above the central safe platform from every route.
	for _, x in { -17, 17 } do
		local pillar = makePart(world, "GatePillar", Vector3.new(4, 20, 4), Vector3.new(x, 12, -20), Color3.fromRGB(93, 139, 173), Enum.Material.Metal)
		local cap = makePart(world, "GateCap", Vector3.new(5, 3, 5), Vector3.new(x, 23, -20), Color3.fromRGB(105, 243, 220), Enum.Material.Neon)
		cap.CanCollide = false
		addLight(cap, cap.Color, 22, 0.8)
	end
	local gateTop = makePart(world, "GateTop", Vector3.new(38, 3, 4), Vector3.new(0, 23, -20), Color3.fromRGB(75, 216, 215), Enum.Material.Neon)
	gateTop.CanCollide = false
	local gateCore = makePart(world, "GateCore", Vector3.new(9, 9, 3), Vector3.new(0, 12, -20), Color3.fromRGB(187, 125, 255), Enum.Material.Neon, Enum.PartType.Ball)
	gateCore.CanCollide = false
	addLight(gateCore, gateCore.Color, 38, 1.3)
	for index = 1, 24 do
		local angle = index * math.pi * 2 / 24
		local marker = makePart(world, "PortalMarker", Vector3.new(1.3, 2.2, 1.3), Vector3.new(math.cos(angle) * 35, 2.3, math.sin(angle) * 35), Color3.fromRGB(98, 221, 217), Enum.Material.Neon)
		marker.CanCollide = false
	end

	bankTrigger = makePart(world, "CollectionPortal", Vector3.new(78, 12, 78), Vector3.new(0, 6, 0), Color3.fromRGB(66, 231, 220), Enum.Material.SmoothPlastic)
	bankTrigger.Transparency = 1
	bankTrigger.CanCollide = false
	bankTrigger.CanTouch = true

	-- Four luminous landmarks make it easy to navigate back without a minimap.
	local landmarkColors = {
		Color3.fromRGB(98, 229, 191), Color3.fromRGB(94, 187, 255),
		Color3.fromRGB(244, 140, 219), Color3.fromRGB(255, 199, 106),
	}
	for index = 1, 4 do
		local angle = (index - 1) * math.pi / 2 + math.pi / 4
		local x, z = math.cos(angle) * 178, math.sin(angle) * 178
		local pad = makePart(world, "RiftGarden", Vector3.new(2, 50, 50), Vector3.new(x, 1, z), Color3.fromRGB(65, 74, 112), Enum.Material.Slate, Enum.PartType.Cylinder)
		pad.Orientation = Vector3.new(0, 0, 90)
		local spire = makePart(world, "WayfinderSpire", Vector3.new(4, 29, 4), Vector3.new(x, 16, z), landmarkColors[index], Enum.Material.Neon)
		spire.CanCollide = false
		addLight(spire, spire.Color, 44, 1.1)
		local crown = makePart(world, "WayfinderCrown", Vector3.new(10, 10, 10), Vector3.new(x, 34, z), landmarkColors[index], Enum.Material.Neon, Enum.PartType.Ball)
		crown.CanCollide = false
		addLight(crown, crown.Color, 32, 1)
		for plantIndex = 1, 5 do
			local offset = Vector3.new(rng:NextNumber(-20, 20), 0, rng:NextNumber(-20, 20))
			createAlienPlant(world, Vector3.new(x, 2, z) + offset, rng:NextNumber(0.65, 1.05), landmarkColors[index])
		end
		for markerIndex = 1, 4 do
			local radius = 58 + markerIndex * 27
			local markerX, markerZ = math.cos(angle) * radius, math.sin(angle) * radius
			local trail = makePart(world, "WayfinderTrail", Vector3.new(0.8, 9, 9), Vector3.new(markerX, 0.4, markerZ), landmarkColors[index], Enum.Material.Slate, Enum.PartType.Cylinder)
			trail.Orientation = Vector3.new(0, 0, 90)
			trail.Transparency = 0.28
			trail.CanCollide = false
			trail.CanTouch = false
			trail.CanQuery = false
			local markerLight = makePart(world, "TrailBeacon", Vector3.new(2, 2, 2), Vector3.new(markerX, 2.2, markerZ), landmarkColors[index], Enum.Material.Neon, Enum.PartType.Ball)
			markerLight.CanCollide = false
			markerLight.CanTouch = false
			markerLight.CanQuery = false
		end
	end

	-- Scatter compact glowstone clusters through the open routes so the void reads as a place, not an empty plate.
	for index = 1, 30 do
		local angle = rng:NextNumber(0, math.pi * 2)
		local radius = rng:NextNumber(92, 252)
		local position = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
		local quadrant = math.floor(((angle + math.pi / 4) % (math.pi * 2)) / (math.pi / 2)) + 1
		createRiftOutcrop(world, position, landmarkColors[quadrant], rng:NextNumber(0.55, 1.05))
	end

	local wardenModel = Instance.new("Model")
	wardenModel.Name = "TheWarden"
	wardenModel.Parent = world
	warden = makePart(wardenModel, "WardenCore", Vector3.new(11, 11, 11), WARDEN_HOME, Color3.fromRGB(53, 44, 96), Enum.Material.Neon, Enum.PartType.Ball)
	warden.CanCollide = false
	warden.Transparency = 0.08
	wardenModel.PrimaryPart = warden
	wardenEyes = makePart(wardenModel, "WardenEyes", Vector3.new(4.8, 1.1, 1.2), warden.Position + Vector3.new(0, 0.5, -5), Color3.fromRGB(255, 132, 116), Enum.Material.Neon)
	wardenEyes.CanCollide = false
	addLight(warden, Color3.fromRGB(200, 125, 255), 26, 0.8)
	local wardenHighlight = Instance.new("Highlight")
	wardenHighlight.FillTransparency = 0.82
	wardenHighlight.OutlineColor = Color3.fromRGB(255, 154, 121)
	wardenHighlight.OutlineTransparency = 0.15
	wardenHighlight.Parent = wardenModel
	wardenModel.PrimaryPart = warden

	bankTrigger.Touched:Connect(function(hit)
		local character = hit:FindFirstAncestorOfClass("Model")
		local player = character and Players:GetPlayerFromCharacter(character)
		if player then RiftService:BankBag(player) end
	end)
end

local function createCreatureVisual(creature, position, parent, onTouch)
	local model = Instance.new("Model")
	model.Name = "Riftling_" .. creature.Id
	model:SetAttribute("CreatureId", creature.Id)
	model:SetAttribute("Rarity", creature.Rarity)
	model.Parent = parent

	local body = makePart(model, "Body", Vector3.new(3.5, 3.5, 3.5), position, creature.Color, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	body.CanCollide = false
	body.CanTouch = true
	model.PrimaryPart = body

	local eyeColor = Color3.fromRGB(31, 43, 63)
	for _, x in { -0.75, 0.75 } do
		local eye = makePart(model, "Eye", Vector3.new(0.45, 0.58, 0.28), position + Vector3.new(x, 0.2, -1.55), eyeColor, Enum.Material.SmoothPlastic, Enum.PartType.Ball)
		eye.CanCollide = false
		eye.CanTouch = false
	end

	local shape = creature.Shape
	if shape == "Ears" or shape == "Crown" then
		for _, x in { -0.95, 0.95 } do
			local ear = makePart(model, "Ear", Vector3.new(1.1, 1.6, 0.8), position + Vector3.new(x, 1.75, 0), creature.Color:Lerp(Color3.new(1, 1, 1), 0.25), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
			ear.CanCollide = false
			ear.CanTouch = false
		end
	elseif shape == "Fin" then
		local fin = makePart(model, "Fin", Vector3.new(0.8, 1.7, 2.3), position + Vector3.new(0, 0, 2), creature.Color:Lerp(Color3.new(1, 1, 1), 0.25), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
		fin.CanCollide = false
		fin.CanTouch = false
	elseif shape == "Sprout" then
		local stem = makePart(model, "Sprout", Vector3.new(0.35, 1.5, 0.35), position + Vector3.new(0, 2.1, 0), Color3.fromRGB(116, 230, 159), Enum.Material.SmoothPlastic)
		stem.CanCollide = false
		stem.CanTouch = false
		local leaf = makePart(model, "SproutLeaf", Vector3.new(1, 0.6, 0.8), position + Vector3.new(0.65, 2.5, 0), Color3.fromRGB(153, 252, 171), Enum.Material.Neon, Enum.PartType.Ball)
		leaf.CanCollide = false
		leaf.CanTouch = false
	end

	local highlight = Instance.new("Highlight")
	highlight.Adornee = model
	highlight.FillColor = creature.Color
	highlight.OutlineColor = creature.Color
	highlight.FillTransparency = 0.86
	highlight.OutlineTransparency = creature.Rarity == "Common" and 0.65 or 0.1
	highlight.Parent = model

	if creature.Rarity ~= "Common" then
		addLight(body, creature.Color, creature.Rarity == "Mythic" and 22 or 14, creature.Rarity == "Mythic" and 1.1 or 0.55)
	end
	if creature.Rarity == "Epic" or creature.Rarity == "Mythic" then
		local beam = Instance.new("Beam")
		local top = Instance.new("Attachment")
		top.Position = Vector3.new(0, 1.8, 0)
		top.Parent = body
		local skyAnchor = Instance.new("Part")
		skyAnchor.Name = "RarityBeaconAnchor"
		skyAnchor.Anchored = true
		skyAnchor.CanCollide = false
		skyAnchor.CanQuery = false
		skyAnchor.CanTouch = false
		skyAnchor.Transparency = 1
		skyAnchor.Size = Vector3.one
		skyAnchor.Position = position + Vector3.new(0, 42, 0)
		skyAnchor.Parent = model
		local bottom = Instance.new("Attachment")
		bottom.Parent = skyAnchor
		beam.Attachment0 = top
		beam.Attachment1 = bottom
		beam.Color = ColorSequence.new(creature.Color)
		beam.Width0 = creature.Rarity == "Mythic" and 1.1 or 0.65
		beam.Width1 = 0.1
		beam.LightEmission = 0.75
		beam.Transparency = NumberSequence.new(0.25)
		beam.Parent = body
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "Nameplate"
	billboard.Size = UDim2.fromOffset(164, 42)
	billboard.StudsOffset = Vector3.new(0, 2.7, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 125
	billboard.Parent = body
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.Text = string.upper(creature.Rarity) .. "  •  " .. creature.Name
	label.TextColor3 = RARITY_COLORS[creature.Rarity] or Color3.new(1, 1, 1)
	label.TextStrokeColor3 = Color3.fromRGB(29, 35, 55)
	label.TextStrokeTransparency = 0.35
	label.TextScaled = true
	label.Parent = billboard

	body.Touched:Connect(onTouch)
	return model
end

local function clearBag(player)
	bags[player] = {}
	player:SetAttribute("BagCount", 0)
	player:SetAttribute("BagValue", 0)
	player:SetAttribute("BagPreview", "Empty")
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = baseWalkSpeeds[player] or 16
	end
end

local function updateBag(player)
	local bag = bags[player] or {}
	local total = 0
	local names = {}
	for index, creature in bag do
		total += creature.Value
		if index <= 2 then table.insert(names, creature.Name) end
	end
	local preview = #names > 0 and table.concat(names, ", ") or "Empty"
	if #bag > 2 then preview ..= " +" .. tostring(#bag - 2) end
	player:SetAttribute("BagCount", #bag)
	player:SetAttribute("BagValue", total)
	player:SetAttribute("BagPreview", preview)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local baseSpeed = baseWalkSpeeds[player] or humanoid.WalkSpeed
		humanoid.WalkSpeed = math.max(12, baseSpeed - #bag * BAG_SPEED_PENALTY)
	end
end

local function addToBag(player, creature)
	if not active then return false end
	local bag = bags[player] or {}
	if #bag >= MAX_BAG then
		if os.clock() - (lastFullNotice[player] or 0) >= 2 then
			lastFullNotice[player] = os.clock()
			player:SetAttribute("BagFullNonce", (player:GetAttribute("BagFullNonce") or 0) + 1)
		end
		return false
	end
	table.insert(bag, creature)
	bags[player] = bag
	updateBag(player)
	player:SetAttribute("LastCaughtName", creature.Name)
	player:SetAttribute("LastCaughtRarity", creature.Rarity)
	player:SetAttribute("LastCaughtNonce", (player:GetAttribute("LastCaughtNonce") or 0) + 1)
	if not wardenAwake and not wardenWakePending then
		wardenWakePending = true
		for _, expeditionPlayer in Players:GetPlayers() do
			expeditionPlayer:SetAttribute("RoundWarning", "WARDEN_ALERT")
		end
		task.delay(4, function()
			if active then wardenAwake = true end
		end)
	end
	return true
end

local function spawnCreatures()
	if salvageFolder then salvageFolder:Destroy() end
	salvageFolder = Instance.new("Folder")
	salvageFolder.Name = "WildRiftlings"
	salvageFolder.Parent = world
	local reserved = { Vector2.new(0, -96) }

	for index = 1, Config.PICKUP_COUNT do
		local x, z
		if index == 1 then
			x, z = 0, -96
		else
			local found = false
			for _ = 1, 30 do
				local angle = rng:NextNumber(0, math.pi * 2)
				local radius = rng:NextNumber(94, Config.WORLD_RADIUS)
				local candidate = Vector2.new(math.cos(angle) * radius, math.sin(angle) * radius)
				local clear = true
				for _, other in reserved do
					if (candidate - other).Magnitude < 22 then clear = false break end
				end
				if clear then
					x, z = candidate.X, candidate.Y
					table.insert(reserved, candidate)
					found = true
					break
				end
			end
			if not found then
				local angle = rng:NextNumber(0, math.pi * 2)
				local radius = rng:NextNumber(110, Config.WORLD_RADIUS)
				x, z = math.cos(angle) * radius, math.sin(angle) * radius
			end
		end

		local creature
		if index == 1 then
			creature = CreatureCatalog.Get("Mossmote")
		elseif index == Config.PICKUP_COUNT then
			creature = CreatureCatalog.RollOfRarity("Epic", rng)
		else
			creature = CreatureCatalog.Roll(rng)
		end
		local claimed = false
		local creatureModel
		creatureModel = createCreatureVisual(creature, Vector3.new(x, 4.2, z), salvageFolder, function(hit)
			if claimed or not active then return end
			local character = hit:FindFirstAncestorOfClass("Model")
			local player = character and Players:GetPlayerFromCharacter(character)
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if not player or not humanoid or humanoid.Health <= 0 then return end
			if not player:GetAttribute("DataReady") then return end
			if not addToBag(player, creature) then return end
			claimed = true
			if creatureModel and creatureModel.Parent then creatureModel:Destroy() end
		end)
	end
end

function RiftService:BankBag(player)
	if not active then return false end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return false end
	local horizontalDistance = (Vector2.new(root.Position.X, root.Position.Z) - Vector2.new(SAFE_CENTER.X, SAFE_CENTER.Z)).Magnitude
	if horizontalDistance > Config.SAFE_RADIUS then return false end
	local bag = bags[player] or {}
	if #bag == 0 then return false end

	local value = 0
	for _, creature in bag do
		value += creature.Value
		PlayerDataService:AddCreature(player, creature)
	end
	CurrencyService:Add(player, value)
	local summary = roundSummary[player]
	-- A run may bank several times. Count its expedition once, while every
	-- successful bank still adds to lifetime secured totals and run recap.
	PlayerDataService:CompleteExpedition(player, value, not summary or summary.Secured == 0)
	if summary then
		summary.Secured += #bag
		summary.Coins += value
	end
	player:SetAttribute("LastBankCount", #bag)
	player:SetAttribute("LastBankValue", value)
	clearBag(player)
	return true
end

local function updateWarden(timeLeft)
	if not warden or not warden.Parent then return end
	local targetPlayer, targetRoot
	if wardenAwake then
		for _, player in Players:GetPlayers() do
			local bag = bags[player]
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			local offset = root and Vector2.new(root.Position.X, root.Position.Z)
			local distanceToHub = offset and offset.Magnitude or math.huge
			if bag and #bag > 0 and root and distanceToHub > Config.SAFE_RADIUS then
				if not targetRoot or (root.Position - warden.Position).Magnitude < (targetRoot.Position - warden.Position).Magnitude then
					targetPlayer, targetRoot = player, root
				end
			end
		end
	end

	if targetRoot then
		local delta = targetRoot.Position - warden.Position
		local humanoid = targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid")
		local playerSpeed = humanoid and humanoid.WalkSpeed or 16
		local elapsed = 1 - math.clamp(timeLeft / Config.ROUND_SECONDS, 0, 1)
		local speedRatio = 0.74 + elapsed * 0.16
		local speed = math.min(playerSpeed * speedRatio, 15)
		if delta.Magnitude > 0 then
			warden.Position += delta.Unit * math.min(speed, delta.Magnitude)
		end
		local facing = Vector3.new(targetRoot.Position.X, warden.Position.Y, targetRoot.Position.Z)
		if (facing - warden.Position).Magnitude > 0.1 then
			warden.CFrame = CFrame.lookAt(warden.Position, facing)
		end
		if wardenEyes then wardenEyes.CFrame = warden.CFrame * CFrame.new(0, 0.5, -5) end
		if delta.Magnitude < 9 and os.clock() - (lastHitAt[targetPlayer] or 0) >= 1.8 then
			local targetHumanoid = targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid")
			if targetHumanoid then
				targetHumanoid:TakeDamage(14)
				lastHitAt[targetPlayer] = os.clock()
				targetPlayer:SetAttribute("WardenHitNonce", (targetPlayer:GetAttribute("WardenHitNonce") or 0) + 1)
			end
		end
	else
		warden.Position = warden.Position:Lerp(WARDEN_HOME, 0.12)
		local facing = Vector3.new(0, warden.Position.Y, 0)
		if (facing - warden.Position).Magnitude > 0.1 then
			warden.CFrame = CFrame.lookAt(warden.Position, facing)
		end
		if wardenEyes then wardenEyes.CFrame = warden.CFrame * CFrame.new(0, 0.5, -5) end
	end
end

local function resetRound()
	active = false
	wardenAwake = false
	wardenWakePending = false
	for _, player in Players:GetPlayers() do player:SetAttribute("RoundWarning", "") end
	if warden and warden.Parent then
		warden.CFrame = CFrame.lookAt(WARDEN_HOME, Vector3.new(0, WARDEN_HOME.Y, 0))
	end
	if wardenEyes then wardenEyes.CFrame = warden.CFrame * CFrame.new(0, 0.5, -5) end
	for _, player in Players:GetPlayers() do
		local bag = bags[player] or {}
		if #bag > 0 then
			local summary = roundSummary[player]
			if summary then summary.Lost += #bag end
			player:SetAttribute("LastLostCount", #bag)
			player:SetAttribute("LastLostNonce", (player:GetAttribute("LastLostNonce") or 0) + 1)
			clearBag(player)
		end
	end
end

local function preparePlayer(player)
	bags[player] = {}
	roundSummary[player] = { Secured = 0, Lost = 0, Coins = 0 }
	player:SetAttribute("Phase", active and "RIFT_RUN" or "HOME")
	player:SetAttribute("RoundTime", active and secondsRemaining or 0)
	player:SetAttribute("RoundWarning", wardenWakePending and "WARDEN_ALERT" or wardenAwake and "WARDEN_ACTIVE" or "")
	player:SetAttribute("DataReady", PlayerDataService:Get(player) ~= nil)
	player:SetAttribute("BagCount", 0)
	player:SetAttribute("BagValue", 0)
	player:SetAttribute("BagPreview", "Empty")
	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid", 10)
		if humanoid then
			baseWalkSpeeds[player] = humanoid.WalkSpeed
			humanoid.Died:Connect(function()
				local bag = bags[player] or {}
				if #bag > 0 then
					local summary = roundSummary[player]
					if summary then summary.Lost += #bag end
					player:SetAttribute("LastLostCount", #bag)
					player:SetAttribute("LastLostNonce", (player:GetAttribute("LastLostNonce") or 0) + 1)
					clearBag(player)
				end
			end)
		end
	end)
	if player.Character then
		task.spawn(function()
			local humanoid = player.Character:WaitForChild("Humanoid", 10)
			if humanoid then baseWalkSpeeds[player] = humanoid.WalkSpeed end
		end)
	end
end

local function runLoop()
	while true do
		resetRound()
		for seconds = Config.BREAK_SECONDS, 1, -1 do
			secondsRemaining = seconds
			for _, player in Players:GetPlayers() do
				player:SetAttribute("Phase", "HOME")
				player:SetAttribute("RoundTime", seconds)
			end
			task.wait(1)
		end

		spawnCreatures()
		active = true
		for _, player in Players:GetPlayers() do
			roundSummary[player] = { Secured = 0, Lost = 0, Coins = 0 }
			clearBag(player)
			player:SetAttribute("RoundWarning", "")
		end
		for seconds = Config.ROUND_SECONDS, 0, -1 do
			secondsRemaining = seconds
			for _, player in Players:GetPlayers() do
				player:SetAttribute("Phase", "RIFT_RUN")
				player:SetAttribute("RoundTime", seconds)
				if #(bags[player] or {}) > 0 then
					RiftService:BankBag(player)
				end
			end
			updateWarden(seconds)
			task.wait(1)
		end

		resetRound()
		for _, player in Players:GetPlayers() do
			player:SetAttribute("Phase", "RIFT_SURGE")
			player:SetAttribute("RoundTime", 0)
			local summary = roundSummary[player] or { Secured = 0, Lost = 0, Coins = 0 }
			player:SetAttribute("RunSummarySecured", summary.Secured)
			player:SetAttribute("RunSummaryLost", summary.Lost)
			player:SetAttribute("RunSummaryCoins", summary.Coins)
			player:SetAttribute("RunSummaryNonce", (player:GetAttribute("RunSummaryNonce") or 0) + 1)
		end
		if salvageFolder then salvageFolder:Destroy(); salvageFolder = nil end
		task.wait(4)
	end
end

function RiftService:Init()
	buildWorld()
	for _, player in Players:GetPlayers() do preparePlayer(player) end
	Players.PlayerAdded:Connect(preparePlayer)
	Players.PlayerRemoving:Connect(function(player)
		bags[player] = nil
		roundSummary[player] = nil
		baseWalkSpeeds[player] = nil
		lastHitAt[player] = nil
		lastFullNotice[player] = nil
	end)
	task.spawn(runLoop)
	print("[Rift Runners] Rift service ready")
end

return RiftService
