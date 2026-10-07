local CreatureCatalog = {}

CreatureCatalog.Tiers = {
	{ Name = "Common", Weight = 62, Color = Color3.fromRGB(140, 231, 190), Value = 10 },
	{ Name = "Uncommon", Weight = 25, Color = Color3.fromRGB(100, 208, 245), Value = 20 },
	{ Name = "Rare", Weight = 8.8, Color = Color3.fromRGB(174, 129, 255), Value = 45 },
	{ Name = "Epic", Weight = 4, Color = Color3.fromRGB(255, 118, 211), Value = 110 },
	{ Name = "Mythic", Weight = 0.2, Color = Color3.fromRGB(255, 205, 91), Value = 280 },
}

CreatureCatalog.Species = {
	{ Id = "Pebblepuff", Name = "Pebblepuff", Rarity = "Common", Shape = "Round" },
	{ Id = "Mossmote", Name = "Mossmote", Rarity = "Common", Shape = "Sprout" },
	{ Id = "Bramblebun", Name = "Bramblebun", Rarity = "Common", Shape = "Ears" },
	{ Id = "Driftfin", Name = "Driftfin", Rarity = "Common", Shape = "Fin" },
	{ Id = "Glowkip", Name = "Glowkip", Rarity = "Uncommon", Shape = "Ears" },
	{ Id = "Cloudoodle", Name = "Cloudoodle", Rarity = "Uncommon", Shape = "Round" },
	{ Id = "Tumbletide", Name = "Tumbletide", Rarity = "Uncommon", Shape = "Fin" },
	{ Id = "Prismidge", Name = "Prismidge", Rarity = "Rare", Shape = "Sprout" },
	{ Id = "Velvetide", Name = "Velvetide", Rarity = "Rare", Shape = "Fin" },
	{ Id = "Starwhorl", Name = "Starwhorl", Rarity = "Epic", Shape = "Crown" },
	{ Id = "Cometcalf", Name = "Cometcalf", Rarity = "Epic", Shape = "Ears" },
	{ Id = "Aurorune", Name = "Aurorune", Rarity = "Mythic", Shape = "Crown" },
}

local tiersByName = {}
local speciesByTier = {}
local speciesById = {}
local totalWeight = 0

for _, tier in CreatureCatalog.Tiers do
	tiersByName[tier.Name] = tier
	totalWeight += tier.Weight
	speciesByTier[tier.Name] = {}
end

for _, species in CreatureCatalog.Species do
	local tier = tiersByName[species.Rarity]
	if tier then
		species.Color = tier.Color
		species.Value = tier.Value
		table.insert(speciesByTier[species.Rarity], species)
		speciesById[species.Id] = species
	end
end

local function rngOrDefault(rng)
	return rng or Random.new()
end

function CreatureCatalog.Roll(rng)
	rng = rngOrDefault(rng)
	local roll = rng:NextNumber(0, totalWeight)
	local cumulative = 0
	local selectedTier = CreatureCatalog.Tiers[1]
	for _, tier in CreatureCatalog.Tiers do
		cumulative += tier.Weight
		if roll <= cumulative then
			selectedTier = tier
			break
		end
	end
	local pool = speciesByTier[selectedTier.Name]
	local species = pool[rng:NextInteger(1, #pool)]
	return table.clone(species)
end

function CreatureCatalog.RollOfRarity(rarity, rng)
	local pool = speciesByTier[rarity]
	if not pool or #pool == 0 then return CreatureCatalog.Roll(rng) end
	rng = rngOrDefault(rng)
	return table.clone(pool[rng:NextInteger(1, #pool)])
end

function CreatureCatalog.Get(id)
	local species = speciesById[id]
	return species and table.clone(species) or nil
end

return CreatureCatalog
