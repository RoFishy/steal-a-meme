local SpawnManager = require(script.Parent.Parent.Parent.SpawnManager)

return function(_, NextRarity: string)
	SpawnManager.CurrentRarity = NextRarity
	return "Set next spawn rarity"
end
