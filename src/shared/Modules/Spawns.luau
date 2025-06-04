-- // Types
local Types = require(script.Parent.Types)

return {
	["Common"] = {
		Rarity = 50, -- 50% spawn chance
		Spawns = {
			["Noob"] = {
				Price = 100,
				Income = 1,
			},
			["Among Us"] = {
				Price = 200,
				Income = 2,
			},
			["Troll Face"] = {
				Price = 250,
				Income = 3,
			},
			["Doge"] = {
				Price = 500,
				Income = 5,
			},
			["Steve"] = {
				Price = 750,
				Income = 7,
			},
		},
	},
	["Rare"] = {
		Rarity = 30,
		Spawns = {},
	},
	["Epic"] = {
		Rarity = 10,
		Spawns = {},
	},
	["Legendary"] = {
		Rarity = 5,
		Spawns = {},
	},
	["Mythical"] = {
		Rarity = 3,
		Spawns = {},
	},
	["Omega"] = {
		Rarity = 1.5,
		Spawns = {},
	},
	["SECRET???"] = {
		Rarity = 0.5,
		Spawns = {},
	},
} :: { [string]: Types.Spawn }
