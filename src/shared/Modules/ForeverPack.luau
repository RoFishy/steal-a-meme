-- // local funcs
local function GetPlayerBase(Player: Player)
	for _, Base in workspace.Bases:GetChildren() do
		if Base:GetAttribute("Owner") == Player.Name then
			return Base
		end
	end
end

local function GetRandomIndexFromDictionary(dictionary)
	local indexes = {} -- table of all indexes in the dictionary
	for i, _ in pairs(dictionary) do -- insert all of the indexes into the table
		indexes[#indexes + 1] = i
	end
	return indexes[math.random(1, #indexes)]
end

local ForeverPackModule = {}

ForeverPackModule.Rewards = {

	[1] = {

		Image = "rbxassetid://81389192039217",
		Chance = 30,
		Text = "$500",
		ClaimFunction = function(Player)
			local ServerScriptService = game:GetService("ServerScriptService")
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)

			DataUtil:IncrementCash(Player, 500)
		end,
	},

	[2] = {
		Image = "",
		Chance = 27,
		Text = "Grapple Hook",
		ClaimFunction = function(Player)
			-- // Services
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local Tools = ReplicatedStorage.Tools

			local GrappleHook = Tools["Grapple Hook"]:Clone()
			GrappleHook.Parent = Player.Backpack
		end,
	},

	[3] = {

		Image = "rbxassetid://81389192039217",
		Chance = 25,
		Text = "$1k",
		ClaimFunction = function(Player)
			local ServerScriptService = game:GetService("ServerScriptService")
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)

			DataUtil:IncrementCash(Player, 1_000)
		end,
	},

	[4] = {
		Image = "rbxassetid://107284806145292",
		Chance = 23.5,
		Text = "Lock Base (15m)",
		ClaimFunction = function(Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			local BaseManager = require(ServerScriptService.Services.BaseManager)
			BaseManager:LockBase(BaseManager:GetBaseNameFromPlayer(Player), 900)
			return
		end,
	},

	[5] = {
		Image = "rbxassetid://138539972309868",
		Chance = 21,
		Text = "Meme Crate",
		ClaimFunction = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local HttpService = game:GetService("HttpService")

			local Spawns = {
				["Epic"] = {
					Rarity = 65,
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
					Rarity = 30,
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
					Rarity = 6,
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
					Rarity = 3,
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
					Rarity = 1,
					Spawns = {
						["Chicken Jockey"] = {
							Price = 99000000,
							Income = 200000,
						},
					},
				},
			}

			local function GetRandomRarity(LuckMultiplier: number?)
				LuckMultiplier = LuckMultiplier or 1
				local adjustedSpawns = {}
				for name, value in pairs(Spawns) do
					adjustedSpawns[name] = {
						Rarity = value.Rarity,
						Spawns = value.Spawns,
					}

					if name == "Epic" then
						adjustedSpawns[name].Rarity = value.Rarity * math.min(LuckMultiplier, 2)
					elseif name == "Mythical" then
						adjustedSpawns[name].Rarity = value.Rarity * LuckMultiplier
					elseif name == "Omega" or name == "SECRET???" then
						adjustedSpawns[name].Rarity = value.Rarity * (LuckMultiplier * 1.5)
					end
				end

				local adjustedSum = 0
				for _, value in pairs(adjustedSpawns) do
					adjustedSum = adjustedSum + value.Rarity
				end

				local RandomNumber = math.random(adjustedSum)
				for Name, Value in pairs(adjustedSpawns) do
					if RandomNumber <= Value.Rarity then
						return Name
					else
						RandomNumber = RandomNumber - Value.Rarity
					end
				end
			end

			local ChosenRarity = GetRandomRarity()
			local RandomSpawn = GetRandomIndexFromDictionary(Spawns[ChosenRarity].Spawns)

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Meme = require(Utils.Meme)

			local PlayerBase = GetPlayerBase(Player)

			local OpenSlot = Meme:GetOpenSlot(PlayerBase.Slots)
			if not OpenSlot then
				ReplicatedStorage.Remotes.ShowNotification:FireClient(
					Player,
					"You do not have any open slots available!"
				)
				return
			end

			ReplicatedStorage.Remotes.ShowNotification:FireAllClients(
				`{Player.Name} has received a {ChosenRarity} {RandomSpawn} from the meme crate!`,
				Color3.fromRGB(255, 0, 0)
			)

			OpenSlot:SetAttribute("Meme", RandomSpawn)
			local _meme = Meme.new(RandomSpawn, ChosenRarity, CFrame.new(0, 0, 0))
			_meme.Model:SetAttribute("ID", HttpService:GenerateGUID(false))
			_meme.PurchasePlayer = Player
			_meme.CurrentStand = OpenSlot
			task.cancel(_meme.CurrentMove)
			_meme:AddToSlot(OpenSlot)
		end,
	},

	[6] = {
		Image = "rbxassetid://78187867501276",
		Chance = 20,
		Text = "Speed Coil (SERVER)",
		ClaimFunction = function(Player)
			-- // Services
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local Tools = ReplicatedStorage.Tools

			local SpeedCoil = Tools["Speed Coil"]:Clone()
			SpeedCoil.Parent = Player.Backpack
		end,
	},

	[7] = {

		Image = "rbxassetid://81389192039217",
		Chance = 15,
		Text = "$10K",
		ClaimFunction = function(Player)
			local ServerScriptService = game:GetService("ServerScriptService")
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)

			DataUtil:IncrementCash(Player, 10000)
		end,
	},

	[8] = {

		Image = "rbxassetid://124328756821715",
		Chance = 5,
		Text = "Epic Meme",
		ClaimFunction = function(Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local HttpService = game:GetService("HttpService")

			local Spawns = require(script.Parent.Spawns)
			local RandomEpic = GetRandomIndexFromDictionary(Spawns["Epic"]["Spawns"])

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Meme = require(Utils.Meme)

			local PlayerBase = GetPlayerBase(Player)

			local OpenSlot = Meme:GetOpenSlot(PlayerBase.Slots)
			if not OpenSlot then
				ReplicatedStorage.Remotes.ShowNotification:FireClient(
					Player,
					"You do not have any open slots available!"
				)
				return
			end

			ReplicatedStorage.Remotes.ShowNotification:FireClient(
				Player,
				`You have received an EPIC {RandomEpic}! It has been added to your base.`,
				Color3.fromRGB(195, 0, 255)
			)

			OpenSlot:SetAttribute("Meme", RandomEpic)
			local _meme = Meme.new(RandomEpic, "Epic", CFrame.new(0, 0, 0))
			_meme.Model:SetAttribute("ID", HttpService:GenerateGUID(false))
			_meme.PurchasePlayer = Player
			_meme.CurrentStand = OpenSlot
			task.cancel(_meme.CurrentMove)
			_meme:AddToSlot(OpenSlot)
		end,
	},

	[9] = {

		Image = "rbxassetid://81389192039217",
		Chance = 7,
		Text = "$50k",
		ClaimFunction = function(Player)
			local ServerScriptService = game:GetService("ServerScriptService")
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)

			DataUtil:IncrementCash(Player, 50000)
		end,
	},

	[10] = {

		Image = "rbxassetid://117363268823396",
		Chance = 3,
		Text = "Legendary Meme",
		ClaimFunction = function(Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local HttpService = game:GetService("HttpService")

			local Spawns = require(script.Parent.Spawns)
			local RandomLegendary = GetRandomIndexFromDictionary(Spawns["Legendary"]["Spawns"])

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Meme = require(Utils.Meme)

			local PlayerBase = GetPlayerBase(Player)

			local OpenSlot = Meme:GetOpenSlot(PlayerBase.Slots)
			if not OpenSlot then
				ReplicatedStorage.Remotes.ShowNotification:FireClient(
					Player,
					"You do not have any open slots available!"
				)
				return
			end

			ReplicatedStorage.Remotes.ShowNotification:FireClient(
				Player,
				`You have received a LEGENDARY {RandomLegendary}! It has been added to your base.`,
				Color3.fromRGB(255, 123, 0)
			)

			OpenSlot:SetAttribute("Meme", RandomLegendary)
			local _meme = Meme.new(RandomLegendary, "Legendary", CFrame.new(0, 0, 0))
			_meme.Model:SetAttribute("ID", HttpService:GenerateGUID(false))
			_meme.PurchasePlayer = Player
			_meme.CurrentStand = OpenSlot
			task.cancel(_meme.CurrentMove)
			_meme:AddToSlot(OpenSlot)
		end,
	},

	[11] = {

		Image = "rbxassetid://81389192039217",
		Chance = 3.5,
		Text = "$250k",
		ClaimFunction = function(Player)
			local ServerScriptService = game:GetService("ServerScriptService")
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)

			DataUtil:IncrementCash(Player, 250_000)
		end,
	},

	[12] = {

		Image = "rbxassetid://81389192039217",
		Chance = 2.5,
		Text = "$500k",
		ClaimFunction = function(Player)
			local ServerScriptService = game:GetService("ServerScriptService")
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)

			DataUtil:IncrementCash(Player, 500_000)
		end,
	},

	[13] = {

		Image = "rbxassetid://89110194837705",
		Chance = 2,
		Text = "Mythical Meme",
		ClaimFunction = function(Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local HttpService = game:GetService("HttpService")

			local Spawns = require(script.Parent.Spawns)
			local RandomMythical = GetRandomIndexFromDictionary(Spawns["Mythical"]["Spawns"])

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Meme = require(Utils.Meme)

			local PlayerBase = GetPlayerBase(Player)

			local OpenSlot = Meme:GetOpenSlot(PlayerBase.Slots)
			if not OpenSlot then
				ReplicatedStorage.Remotes.ShowNotification:FireClient(
					Player,
					"You do not have any open slots available!"
				)
				return
			end

			ReplicatedStorage.Remotes.ShowNotification:FireClient(
				Player,
				`You have received a MYTHICAL {RandomMythical}! It has been added to your base.`,
				Color3.fromRGB(255, 0, 0)
			)

			OpenSlot:SetAttribute("Meme", RandomMythical)
			local _meme = Meme.new(RandomMythical, "Mythical", CFrame.new(0, 0, 0))
			_meme.Model:SetAttribute("ID", HttpService:GenerateGUID(false))
			_meme.PurchasePlayer = Player
			_meme.CurrentStand = OpenSlot
			task.cancel(_meme.CurrentMove)
			_meme:AddToSlot(OpenSlot)
		end,
	},

	[14] = {
		Image = "rbxassetid://75681193975883",
		Chance = 1.75,
		Text = "Killer Bee Launcher (SERVER)",
		ClaimFunction = function(Player)
			-- // Services
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local Tools = ReplicatedStorage.Tools

			local Tool = Tools["Killer Bee Launcher"]:Clone()
			Tool.Parent = Player.Backpack
		end,
	},

	[15] = {

		Image = "rbxassetid://81389192039217",
		Chance = 1.5,
		Text = "$1M",
		ClaimFunction = function(Player)
			local ServerScriptService = game:GetService("ServerScriptService")
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)

			DataUtil:IncrementCash(Player, 1_000_000)
		end,
	},

	[16] = {

		Image = "rbxassetid://81389192039217",
		Chance = 0.7,
		Text = "$5M",
		ClaimFunction = function(Player)
			local ServerScriptService = game:GetService("ServerScriptService")
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)

			DataUtil:IncrementCash(Player, 5_000_000)
		end,
	},

	[17] = {

		Image = "rbxassetid://76192884409679",
		Chance = 0.3,
		Text = "Omega Meme",
		ClaimFunction = function(Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local HttpService = game:GetService("HttpService")

			local Spawns = require(script.Parent.Spawns)
			local RandomOmega = GetRandomIndexFromDictionary(Spawns["Omega"]["Spawns"])

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Meme = require(Utils.Meme)

			local PlayerBase = GetPlayerBase(Player)

			local OpenSlot = Meme:GetOpenSlot(PlayerBase.Slots)
			if not OpenSlot then
				ReplicatedStorage.Remotes.ShowNotification:FireClient(
					Player,
					"You do not have any open slots available!"
				)
				return
			end

			ReplicatedStorage.Remotes.ShowNotification:FireClient(
				Player,
				`You have received an OMEGA {RandomOmega}! It has been added to your base.`,
				Color3.fromRGB(255, 0, 0)
			)

			OpenSlot:SetAttribute("Meme", RandomOmega)
			local _meme = Meme.new(RandomOmega, "Omega", CFrame.new(0, 0, 0))
			_meme.Model:SetAttribute("ID", HttpService:GenerateGUID(false))
			_meme.PurchasePlayer = Player
			_meme.CurrentStand = OpenSlot
			task.cancel(_meme.CurrentMove)
			_meme:AddToSlot(OpenSlot)
		end,
	},
}

ForeverPackModule.PriceGap = {
	[5] = 3312923714, -- 19
	[10] = 3312923870, -- 39
	[15] = 3312923925, -- 99
	[20] = 3312923968, -- 149
	[25] = 3312924078, -- 259
}

ForeverPackModule.GetPriceFromIndex = function(Index)
	if Index % 5 ~= 0 then
		return "Free"
	else
		return ForeverPackModule.PriceGap[Index] and ForeverPackModule.PriceGap[Index] or ForeverPackModule.PriceGap[25]
	end
end

ForeverPackModule.GetNextIndex = function(ForeverPackTable)
	local NextTableIndex = nil

	for index in pairs(ForeverPackTable) do
		local numIndex = tonumber(index)
		if numIndex then
			if not NextTableIndex or numIndex < NextTableIndex then
				NextTableIndex = numIndex
			end
		end
	end

	return NextTableIndex
end

ForeverPackModule.PickRandomRewardIndex = function()
	local total = 0
	for _, r in ipairs(ForeverPackModule.Rewards) do
		total = total + r.Chance
	end
	local roll = math.random() * total
	local acc = 0
	for i, r in ipairs(ForeverPackModule.Rewards) do
		acc = acc + r.Chance
		if roll <= acc then
			return i
		end
	end
end
return ForeverPackModule
