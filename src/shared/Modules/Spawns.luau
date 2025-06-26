-- // Types
local Types = require(script.Parent.Types)

return {
	["Common"] = {
		Rarity = 50, -- 50% spawn chance
		Spawns = {
			["Noob"] = {
				Price = 100,
				Income = 1,

				Sound = 18404418062,
			},
			["Among Us"] = {
				Price = 200,
				Income = 2,

				Sound = 6425216149,
			},
			["Troll Face"] = {
				Price = 250,
				Income = 3,

				Sound = 84153865596533,
			},
			["Doge"] = {
				Price = 500,
				Income = 5,
			},
			["Steve"] = {
				Price = 750,
				Income = 7,

				Sound = 81783906468616,
			},
			["Burbaloni Lulliloli"] = {
				Price = 900,
				Income = 9,

				Sound = 103018359077643,
			},
		},
	},
	["Rare"] = {
		Rarity = 30,
		Spawns = {
			["Rick Roll"] = {
				Price = 1000,
				Income = 10,

				Sound = 7992960012,
				SoundCutoff = 2, -- play first 2 seconds
			},
			["Giga Chad"] = {
				Price = 1500,
				Income = 15,

				Sound = 14145620056,
				SoundCutoff = 3,
			},
			["Pepe"] = {
				Price = 2500,
				Income = 25,
			},
			["Sad Spongebob"] = {
				Price = 5000,
				Income = 50,

				Sound = 91052532296127,
				SoundCutoff = 3,
			},
			["The Rock"] = {
				Price = 7500,
				Income = 75,

				Sound = 92303459929151,
			},
			["Bombardilo Crocodilo"] = {
				Price = 10000,
				Income = 100,

				Sound = 73983736261439,
			},
		},
	},
	["Epic"] = {
		Rarity = 15,
		Spawns = {
			["Floppa"] = {
				Price = 12500,
				Income = 125,

				Sound = 1091083826,
			},
			["Nyan Cat"] = {
				Price = 15000,
				Income = 150,

				Sound = 9067256917,
				SoundCutoff = 3,
			},
			["Sigma"] = {
				Price = 25000,
				Income = 250,

				Sound = 17608357332,
			},
			["Capybara"] = {
				Price = 45000,
				Income = 450,
			},
			["BrrBrrPatapim"] = {
				Price = 75_000,
				Income = 750,

				Sound = 138952404452431,
			},
		},
	},
	["Legendary"] = {
		Rarity = 2,
		Spawns = {
			["John Pork"] = {
				Price = 120000,
				Income = 1200,

				Sound = 79620239797415,
				SoundCutoff = 3,
			},
			["Walter"] = {
				Price = 215000,
				Income = 2150,
			},
			["Smurf Cat"] = {
				Price = 300000,
				Income = 3000,

				Sound = 106284875582996,
				SoundCutoff = 3,
			},
			["El Gato"] = {
				Price = 375000,
				Income = 3750,

				Sound = 1091083826,
			},
			["Tralalero Tralala"] = {
				Price = 500_000,
				Income = 4250,

				Sound = 105044304109159,
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

				Sound = 112584886682038,
				SoundCutoff = 3,
			},
			["Hampter"] = {
				Price = 1750000,
				Income = 12500,
			},
			["Ballerina Cappuccina"] = {
				Price = 2_250_000,
				Income = 15000,

				Sound = 100354609007228,
			},
		},
	},
	["Omega"] = {
		Rarity = 0.25,
		Spawns = {
			["Turi ip ip ip"] = {
				Price = 3000000,
				Income = 20000,

				Sound = 79392217283957,
			},
			["Gegagedigedagedago"] = {
				Price = 5000000,
				Income = 35000,

				Sound = 91462550730140,
			},
			["Tung Tung"] = {
				Price = 10000000,
				Income = 80000,

				Sound = 93232405430010,
			},
			["Cappuccino Assassino"] = {
				Price = 40_000_000,
				Income = 110_000,

				Sound = 105211676664322,
			},
		},
	},
	["SECRET???"] = {
		Rarity = 0.05,
		Spawns = {
			["Chicken Jockey"] = {
				Price = 99_000_000,
				Income = 200000,

				Sound = 109689455115234,
			},
			["Chimpanzini Bananini"] = {
				Price = 250_000_000,
				Income = 300_000,

				Sound = 93643676391320,
			},
			["Skibidi Toilet"] = {
				Price = 400_000_000,
				Income = 400_000,
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
	["QUEST"] = {
		Rarity = 0,
		Spawns = {
			["Lebron"] = {
				Price = 0,
				Income = 25_000,
			},
		},
	},
} :: { [string]: Types.Spawn }
