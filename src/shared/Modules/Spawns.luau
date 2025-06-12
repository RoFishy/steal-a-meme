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
		Spawns = {
			["Rick Roll"] = {
				Price = 1000,
				Income = 10,
			},
			["Giga Chad"] = {
				Price = 1500,
				Income = 15,
			},
			["Pepe"] = {
				Price = 2500,
				Income = 25,
			},
			["Sad Spongebob"] = {
				Price = 5000,
				Income = 50,
			},
			["The Rock"] = {
				Price = 7500,
				Income = 75,
			},
		},
	},
	["Epic"] = {
		Rarity = 15,
		Spawns = {
			["Floppa"] = {
				Price = 12500,
				Income = 125,
			},
			["Nyan Cat"] = {
				Price = 15000,
				Income = 150,
			},
			["Sigma"] = {
				Price = 25000,
				Income = 250,
			},
			["Capybara"] = {
				Price = 45000,
				Income = 450,
			},
		},
	},
	["Legendary"] = {
		Rarity = 2,
		Spawns = {
			["John Pork"] = {
				Price = 120000,
				Income = 1200,
			},
			["Walter"] = {
				Price = 215000,
				Income = 2150,
			},
			["Smurf Cat"] = {
				Price = 300000,
				Income = 3000,
			},
			["El Gato"] = {
				Price = 375000,
				Income = 3750,
			},
		},
	},
	["Mythical"] = {
		Rarity = 0.5,
		Spawns = {
			["Tim Cheese"] = {
				Price = 700000,
				Income = 5000,
			},
			["Sprunki"] = {
				Price = 1000000,
				Income = 7500,
			},
			["Hampter"] = {
				Price = 1750000,
				Income = 12500,
			},
		},
	},
	["Omega"] = {
		Rarity = 0.25,
		Spawns = {
			["Turi ip ip ip"] = {
				Price = 3000000,
				Income = 20000,
			},
			["Gegagedigedagedago"] = {
				Price = 5000000,
				Income = 35000,
			},
			["Tung Tung"] = {
				Price = 10000000,
				Income = 80000,
			},
		},
	},
	["SECRET???"] = {
		Rarity = 0.05,
		Spawns = {
			["Chicken Jockey"] = {
				Price = 99000000,
				Income = 200000,
			},
		},
	},
	["ROBUX"] = {
		Rarity = 0,
		Spawns = {
			["Shrek"] = {
				Price = 0,
				Income = 250_000,
			},
			["DaBaby Car"] = {
				Price = 0,
				Income = 500_000,
			},
		},
	},
} :: { [string]: Types.Spawn }
