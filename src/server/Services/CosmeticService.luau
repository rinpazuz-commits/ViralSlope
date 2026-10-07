local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local CosmeticCatalog = require(ReplicatedStorage.Shared.CosmeticCatalog)
local PlayerDataService = require(script.Parent.PlayerDataService)

local CosmeticService = {}
local lastRequestAt = setmetatable({}, { __mode = "k" })
local appliedAttachments = setmetatable({}, { __mode = "k" })
local remotesFolder
local requestRemote
local openRemote

local function getOrCreate(parent, className, name)
	local instance = parent:FindFirstChild(name)
	if instance and instance.ClassName == className then return instance end
	if instance then instance:Destroy() end
	instance = Instance.new(className)
	instance.Name = name
	instance.Parent = parent
	return instance
end

local function makePart(parent, name, size, cframe, color, material, shape)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material or Enum.Material.Neon
	part.Shape = shape or Enum.PartType.Block
	part.Anchored = false
	part.Massless = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Parent = parent
	return part
end

local function weld(part0, part1)
	local joint = Instance.new("WeldConstraint")
	joint.Part0 = part0
	joint.Part1 = part1
	joint.Parent = part1
	return joint
end

local function attachToRoot(model, root, name, size, color, localCFrame, material, shape)
	local part = makePart(model, name, size, root.CFrame * localCFrame, color, material, shape)
	weld(root, part)
	return part
end

local function makeShowpiece(parent, name, size, cframe, color, shape)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Anchored = true
	part.Massless = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.Material = Enum.Material.Neon
	part.Color = color
	if shape then part.Shape = shape end
	part.Parent = parent
	return part
end

local function createAuroraCrown(character, root, item)
	local model = Instance.new("Model")
	model.Name = "RiftRunnersCosmetic"
	model.Parent = character
	for index = 1, 8 do
		local angle = (index - 1) * math.pi / 4
		local radial = Vector3.new(math.cos(angle) * 1.35, 3.05, math.sin(angle) * 1.35)
		local segmentCFrame = CFrame.new(radial) * CFrame.Angles(0, -angle, 0)
		attachToRoot(model, root, "AuroraBand", Vector3.new(1.13, 0.24, 0.26), item.Color, segmentCFrame, Enum.Material.Neon)

		local gemCFrame = CFrame.new(radial + Vector3.new(0, 0.23, 0)) * CFrame.Angles(0, angle, math.rad(45))
		local gem = attachToRoot(model, root, "PrismShard", Vector3.new(0.42, 0.72, 0.42), index % 2 == 0 and item.Accent or item.Color, gemCFrame, Enum.Material.Neon, Enum.PartType.Ball)
		if index == 1 then
			local light = Instance.new("PointLight")
			light.Color = item.Color
			light.Brightness = 0.65
			light.Range = 10
			light.Shadows = false
			light.Parent = gem
		end
	end
	return model
end

local function createStardustTrail(character, root, item)
	local model = Instance.new("Model")
	model.Name = "RiftRunnersCosmetic"
	model.Parent = character
	local left = character:FindFirstChild("LeftFoot") or character:FindFirstChild("Left Leg") or character:FindFirstChild("LeftLowerLeg")
	local right = character:FindFirstChild("RightFoot") or character:FindFirstChild("Right Leg") or character:FindFirstChild("RightLowerLeg")
	left = left or root
	right = right or root

	local a0 = Instance.new("Attachment")
	a0.Name = "RiftCosmeticAttachmentA"
	a0.Position = Vector3.new(0, -math.max(0, left.Size.Y * 0.42), 0)
	a0.Parent = left
	local a1 = Instance.new("Attachment")
	a1.Name = "RiftCosmeticAttachmentB"
	a1.Position = Vector3.new(0, -math.max(0, right.Size.Y * 0.42), 0)
	a1.Parent = right
	local attachmentList = { a0 }
	appliedAttachments[character] = attachmentList
	table.insert(attachmentList, a1)

	local trail = Instance.new("Trail")
	trail.Name = "StardustWake"
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Color = ColorSequence.new(item.Color, item.Accent)
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.14),
		NumberSequenceKeypoint.new(0.7, 0.46),
		NumberSequenceKeypoint.new(1, 1),
	})
	trail.Lifetime = 0.48
	trail.MinLength = 0.08
	trail.LightEmission = 0.9
	trail.FaceCamera = true
	trail.Enabled = true
	trail.Parent = model
	return model
end

local function createPocketGlimmer(character, root, item)
	local model = Instance.new("Model")
	model.Name = "RiftRunnersCosmetic"
	model.Parent = character
	local body = makePart(model, "GlimmerBody", Vector3.new(1.25, 1.25, 1.25), root.CFrame * CFrame.new(2.05, 1.2, 0.5), item.Color, Enum.Material.Neon, Enum.PartType.Ball)
	local floatWeld = Instance.new("Weld")
	floatWeld.Name = "GlimmerFloat"
	floatWeld.Part0 = root
	floatWeld.Part1 = body
	floatWeld.C0 = CFrame.new(2.05, 1.2, 0.5)
	floatWeld.C1 = CFrame.identity
	floatWeld.Parent = body
	local bob = TweenService:Create(floatWeld, TweenInfo.new(0.95, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		C0 = CFrame.new(2.05, 1.52, 0.5),
	})
	bob:Play()

	for _, side in { -1, 1 } do
		local eye = makePart(model, "GlimmerEye", Vector3.new(0.2, 0.24, 0.12), body.CFrame * CFrame.new(side * 0.24, 0.08, -0.53), Color3.fromRGB(35, 43, 70), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
		weld(body, eye)
		local ear = makePart(model, "GlimmerFin", Vector3.new(0.24, 0.62, 0.34), body.CFrame * CFrame.new(side * 0.39, 0.61, 0.02) * CFrame.Angles(0, 0, side * math.rad(23)), item.Accent, Enum.Material.Neon, Enum.PartType.Ball)
		weld(body, ear)
	end
	local tail = makePart(model, "GlimmerTail", Vector3.new(0.33, 0.33, 0.9), body.CFrame * CFrame.new(0, -0.12, 0.82) * CFrame.Angles(math.rad(-20), 0, 0), item.Accent, Enum.Material.Neon, Enum.PartType.Ball)
	weld(body, tail)
	local glow = Instance.new("PointLight")
	glow.Color = item.Color
	glow.Brightness = 0.8
	glow.Range = 12
	glow.Shadows = false
	glow.Parent = body
	return model
end

local function removeApplied(character)
	if not character then return end
	local current = character:FindFirstChild("RiftRunnersCosmetic")
	if current then current:Destroy() end
	for _, attachment in appliedAttachments[character] or {} do
		if attachment.Parent then attachment:Destroy() end
	end
	appliedAttachments[character] = nil
end

local function applyEquipped(player, character)
	if not character or not character.Parent then return end
	removeApplied(character)
	local state = PlayerDataService:GetCosmeticState(player)
	if not state or state.Equipped == "" then return end
	local item = CosmeticCatalog.Get(state.Equipped)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not item or not root then return end
	if item.Id == "AURORA_CROWN" then
		createAuroraCrown(character, root, item)
	elseif item.Id == "MOTES_TRAIL" then
		createStardustTrail(character, root, item)
	elseif item.Id == "POCKET_RIFTLING" then
		createPocketGlimmer(character, root, item)
	end
end

local function buildShowcase()
	local old = Workspace:FindFirstChild("RiftRelicAtelier")
	if old then old:Destroy() end
	local root = Workspace:FindFirstChild("RiftRunnersWorld")
	if not root then return end
	local showcase = Instance.new("Model")
	showcase.Name = "RiftRelicAtelier"
	showcase.Parent = root

	local center = Vector3.new(23, 0, 19)
	local base = Instance.new("Part")
	base.Name = "AtelierBase"
	base.Size = Vector3.new(20, 1.2, 11)
	base.Position = center + Vector3.new(0, 0.6, 0)
	base.Anchored = true
	base.Color = Color3.fromRGB(28, 38, 68)
	base.Material = Enum.Material.Slate
	base.TopSurface = Enum.SurfaceType.Smooth
	base.BottomSurface = Enum.SurfaceType.Smooth
	base.Parent = showcase
	local rim = Instance.new("Part")
	rim.Name = "AtelierRim"
	rim.Size = Vector3.new(20.5, 0.24, 11.5)
	rim.Position = center + Vector3.new(0, 0.42, 0)
	rim.Anchored = true
	rim.CanCollide = false
	rim.Color = Color3.fromRGB(81, 225, 223)
	rim.Material = Enum.Material.Neon
	rim.Transparency = 0.32
	rim.Parent = showcase
	local signs = Instance.new("BillboardGui")
	signs.Name = "AtelierSign"
	signs.Size = UDim2.fromOffset(220, 38)
	signs.StudsOffset = Vector3.new(0, 6, 0)
	signs.AlwaysOnTop = false
	signs.MaxDistance = 75
	signs.Parent = base
	local signText = Instance.new("TextLabel")
	signText.Size = UDim2.fromScale(1, 1)
	signText.BackgroundTransparency = 1
	signText.Font = Enum.Font.GothamBold
	signText.Text = "RIFT RELIC ATELIER  •  COIN COSMETICS"
	signText.TextColor3 = Color3.fromRGB(169, 255, 239)
	signText.TextStrokeColor3 = Color3.fromRGB(17, 25, 48)
	signText.TextStrokeTransparency = 0.22
	signText.TextScaled = false
	signText.TextSize = 14
	signText.Parent = signs

	local displayPositions = { -6, 0, 6 }
	for index, item in CosmeticCatalog.Items do
		local x = center.X + displayPositions[index]
		local pedestal = Instance.new("Part")
		pedestal.Name = "RelicPedestal"
		pedestal.Size = Vector3.new(4.5, 1.1, 4.5)
		pedestal.Position = Vector3.new(x, 2, center.Z)
		pedestal.Anchored = true
		pedestal.Color = Color3.fromRGB(37, 48, 79)
		pedestal.Material = Enum.Material.Metal
		pedestal.Parent = showcase
		local jewel
		if item.Id == "AURORA_CROWN" then
			for shardIndex = 1, 8 do
				local angle = (shardIndex - 1) * math.pi / 4
				local point = Vector3.new(x + math.cos(angle) * 1.25, 4.2, center.Z + math.sin(angle) * 1.25)
				local segment = makeShowpiece(showcase, "CrownPrism", Vector3.new(0.96, 0.22, 0.24), CFrame.new(point) * CFrame.Angles(0, -angle, 0), item.Color)
				if shardIndex == 1 then jewel = segment end
				makeShowpiece(showcase, "CrownGem", Vector3.new(0.37, 0.65, 0.37), CFrame.new(point + Vector3.new(0, 0.28, 0)), shardIndex % 2 == 0 and item.Accent or item.Color, Enum.PartType.Ball)
			end
		elseif item.Id == "MOTES_TRAIL" then
			for moteIndex = 1, 9 do
				local t = (moteIndex - 1) / 8
				local point = Vector3.new(x + (t - 0.5) * 3.3, 3.35 + math.sin(t * math.pi * 2) * 0.4, center.Z + math.cos(t * math.pi * 2) * 0.55)
				local size = 0.22 + math.sin(t * math.pi) * 0.25
				local mote = makeShowpiece(showcase, "StardustMote", Vector3.new(size, size, size), CFrame.new(point), t < 0.5 and item.Color or item.Accent, Enum.PartType.Ball)
				if moteIndex == 5 then jewel = mote end
			end
		elseif item.Id == "POCKET_RIFTLING" then
			jewel = makeShowpiece(showcase, "GlimmerBody", Vector3.new(1.2, 1.2, 1.2), CFrame.new(x, 3.5, center.Z), item.Color, Enum.PartType.Ball)
			for _, side in { -1, 1 } do
				makeShowpiece(showcase, "GlimmerEye", Vector3.new(0.18, 0.22, 0.12), CFrame.new(x + side * 0.22, 3.58, center.Z - 0.5), Color3.fromRGB(35, 43, 70), Enum.PartType.Ball)
				makeShowpiece(showcase, "GlimmerFin", Vector3.new(0.28, 0.63, 0.3), CFrame.new(x + side * 0.35, 4.08, center.Z + 0.02) * CFrame.Angles(0, 0, side * math.rad(23)), item.Accent, Enum.PartType.Ball)
			end
			makeShowpiece(showcase, "GlimmerTail", Vector3.new(0.32, 0.32, 0.78), CFrame.new(x, 3.35, center.Z + 0.78) * CFrame.Angles(math.rad(-20), 0, 0), item.Accent, Enum.PartType.Ball)
		end
		local light = Instance.new("PointLight")
		light.Color = item.Color
		light.Range = 11
		light.Brightness = 0.5
		light.Shadows = false
		light.Parent = jewel
		local label = Instance.new("BillboardGui")
		label.Size = UDim2.fromOffset(130, 28)
		label.StudsOffset = Vector3.new(0, 1.5, 0)
		label.AlwaysOnTop = false
		label.MaxDistance = 55
		label.Parent = jewel
		local labelText = Instance.new("TextLabel")
		labelText.Size = UDim2.fromScale(1, 1)
		labelText.BackgroundTransparency = 1
		labelText.Font = Enum.Font.GothamBold
		labelText.Text = string.upper(item.Name)
		labelText.TextColor3 = item.Color
		labelText.TextStrokeTransparency = 0.3
		labelText.TextScaled = false
		labelText.TextSize = 13
		labelText.Parent = label
	end

	local promptHost = Instance.new("Part")
	promptHost.Name = "BrowsePromptHost"
	promptHost.Size = Vector3.one
	promptHost.CFrame = CFrame.new(center + Vector3.new(0, 4.8, 0))
	promptHost.Anchored = true
	promptHost.Transparency = 1
	promptHost.CanCollide = false
	promptHost.CanQuery = false
	promptHost.Parent = showcase
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Browse Relics"
	prompt.ObjectText = "Rift Relic Atelier"
	prompt.HoldDuration = 0.25
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = promptHost
	prompt.Triggered:Connect(function(player)
		openRemote:FireClient(player)
	end)
end

local function stateResponse(player, ok, status)
	return {
		Ok = ok,
		Status = status,
		State = PlayerDataService:GetCosmeticState(player),
	}
end

function CosmeticService:Init()
	remotesFolder = getOrCreate(ReplicatedStorage, "Folder", "RiftRemotes")
	requestRemote = getOrCreate(remotesFolder, "RemoteFunction", "CosmeticRequest")
	openRemote = getOrCreate(remotesFolder, "RemoteEvent", "OpenCosmeticShop")
	requestRemote.OnServerInvoke = function(player, action, itemId)
		if type(action) ~= "string" or #action > 16 then
			return stateResponse(player, false, "INVALID_REQUEST")
		end
		local now = os.clock()
		if now - (lastRequestAt[player] or 0) < 0.2 then
			return stateResponse(player, false, "TOO_FAST")
		end
		lastRequestAt[player] = now
		if not player:GetAttribute("DataReady") then
			return stateResponse(player, false, "DATA_NOT_READY")
		end
		if action == "GetState" then
			return stateResponse(player, true, "OK")
		elseif action == "Buy" then
			if type(itemId) ~= "string" or #itemId > 32 then
				return stateResponse(player, false, "INVALID_ITEM")
			end
			local success, status = PlayerDataService:BuyCosmetic(player, itemId)
			if success then applyEquipped(player, player.Character) end
			return stateResponse(player, success, status)
		elseif action == "Equip" then
			local success, status = PlayerDataService:EquipCosmetic(player, itemId)
			if success then applyEquipped(player, player.Character) end
			return stateResponse(player, success, status)
		end
		return stateResponse(player, false, "INVALID_REQUEST")
	end

	local function watchPlayer(player)
		player.CharacterAdded:Connect(function(character)
			character:WaitForChild("HumanoidRootPart", 10)
			task.wait(0.25)
			applyEquipped(player, character)
		end)
		player.CharacterRemoving:Connect(removeApplied)
		if player.Character then task.spawn(applyEquipped, player, player.Character) end
	end
	for _, player in Players:GetPlayers() do watchPlayer(player) end
	Players.PlayerAdded:Connect(watchPlayer)
	Players.PlayerRemoving:Connect(function(player)
		lastRequestAt[player] = nil
		if player.Character then removeApplied(player.Character) end
	end)
	buildShowcase()
	print("[Rift Runners] Cosmetic service ready")
end

return CosmeticService
