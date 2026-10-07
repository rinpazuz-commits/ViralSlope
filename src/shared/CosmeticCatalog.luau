local CosmeticCatalog = {}

CosmeticCatalog.Items = {
	{
		Id = "AURORA_CROWN",
		Name = "Aurora Crown",
		Category = "HEADGEAR",
		Price = 450,
		Description = "A prism ring crowned with six floating rift shards.",
		Color = Color3.fromRGB(113, 244, 235),
		Accent = Color3.fromRGB(220, 153, 255),
	},
	{
		Id = "MOTES_TRAIL",
		Name = "Stardust Wake",
		Category = "TRAIL",
		Price = 850,
		Description = "Leave a short-lived ribbon of aurora light in your path.",
		Color = Color3.fromRGB(102, 212, 255),
		Accent = Color3.fromRGB(239, 148, 255),
	},
	{
		Id = "POCKET_RIFTLING",
		Name = "Pocket Glimmer",
		Category = "COMPANION",
		Price = 1600,
		Description = "A tiny curious Riftling that follows every expedition.",
		Color = Color3.fromRGB(255, 196, 111),
		Accent = Color3.fromRGB(255, 129, 193),
	},
}

local byId = {}
for _, item in CosmeticCatalog.Items do
	byId[item.Id] = item
end

function CosmeticCatalog.Get(id)
	local item = byId[id]
	return item and table.clone(item) or nil
end

return CosmeticCatalog
