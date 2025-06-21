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

-- // other
local speedConn = nil

return {
	-- // Bases
	BypassLockCooldown = {
		ProductId = 3299780200,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)
			return Signals.BypassLockCooldown:Fire(Player)
		end,
	},

	["Unlock Base"] = {
		ProductId = 3304667372,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			local BaseManager = require(ServerScriptService.Services.BaseManager)
			BaseManager:UnlockForPlayer(Player)
			return
		end,
	},

	["Teleport To Base"] = {
		ProductId = 3306101611,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			local BaseManager = require(ServerScriptService.Services.BaseManager)

			BaseManager:TeleportPlayerToBase(Player)
			return
		end,
	},

	["Lock Base 15 Minutes"] = {
		ProductId = 3306061444,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			local BaseManager = require(ServerScriptService.Services.BaseManager)
			BaseManager:LockBase(BaseManager:GetBaseNameFromPlayer(Player), 900)
			return
		end,
	},

	-- // Conveyor SPeed
	["10m Conveyor Speed Boost"] = {
		ProductId = 3307238948,
		Callback = function(Player: Player)
			local ReplicatedStorage = game:GetService("ReplicatedStorage")

			ReplicatedStorage.SpeedTime.Value += 600
			ReplicatedStorage.Remotes.ShowNotification:FireAllClients(
				`{Player.Name} has purchased 2x conveyor speed for 10 minutes!`,
				Color3.fromRGB(0, 255, 0)
			)
			if not speedConn then
				speedConn = task.spawn(function()
					while ReplicatedStorage.SpeedTime.Value > 0 do
						task.wait(1)
						ReplicatedStorage.SpeedTime.Value -= 1
					end
					task.cancel(speedConn)
					speedConn = nil
				end)
			end
			return
		end,
	},
	["20m Conveyor Speed Boost"] = {
		ProductId = 3307239001,
		Callback = function(Player: Player)
			local ReplicatedStorage = game:GetService("ReplicatedStorage")

			ReplicatedStorage.SpeedTime.Value += 1200
			ReplicatedStorage.Remotes.ShowNotification:FireAllClients(
				`{Player.Name} has purchased 2x conveyor speed for 20 minutes!`,
				Color3.fromRGB(0, 255, 0)
			)
			if not speedConn then
				speedConn = task.spawn(function()
					while ReplicatedStorage.SpeedTime.Value > 0 do
						task.wait(1)
						ReplicatedStorage.SpeedTime.Value -= 1
					end
					task.cancel(speedConn)
					speedConn = nil
				end)
			end
			return
		end,
	},

	-- // Memes
	["Legendary Meme"] = {
		ProductId = 3305650625,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)

			Signals.RobuxBuyMeme:Fire(Player)
			return
		end,
	},

	["Mythical Meme"] = {
		ProductId = 3305650713,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)

			Signals.RobuxBuyMeme:Fire(Player)
			return
		end,
	},

	["Omega Meme"] = {
		ProductId = 3305650771,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)

			Signals.RobuxBuyMeme:Fire(Player)
			return
		end,
	},

	["SECRET??? Meme"] = {
		ProductId = 3305650843,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)

			Signals.RobuxBuyMeme:Fire(Player)
			return
		end,
	},

	-- // Robux-only memes
	["Shrek"] = {
		ProductId = 3306066042,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local HttpService = game:GetService("HttpService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
			OpenSlot:SetAttribute("Meme", "Shrek")
			local _meme = Meme.new("Shrek", "ROBUX", CFrame.new(0, 0, 0))
			_meme.Model:SetAttribute("ID", HttpService:GenerateGUID(false))
			_meme.PurchasePlayer = Player
			_meme.CurrentStand = OpenSlot
			task.cancel(_meme.CurrentMove)
			_meme:AddToSlot(OpenSlot)
		end,
	},

	["DaBaby Car"] = {
		ProductId = 3306066199,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")
			local HttpService = game:GetService("HttpService")

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
			OpenSlot:SetAttribute("Meme", "DaBaby Car")
			local _meme = Meme.new("DaBaby Car", "ROBUX", CFrame.new(0, 0, 0))
			_meme.Model:SetAttribute("ID", HttpService:GenerateGUID(false))
			_meme.PurchasePlayer = Player
			_meme.CurrentStand = OpenSlot
			task.cancel(_meme.CurrentMove)
			_meme:AddToSlot(OpenSlot)
		end,
	},

	-- // Chests/crates
	["Mythical Chest"] = {
		ProductId = 3306060731,
		Callback = function(Player: Player)
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

			ReplicatedStorage.Remotes.ShowNotification:FireAllClients(
				`{Player.Name} has received a MYTHICAL {RandomMythical} from the mythical chest!`,
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
	["Meme Crate"] = {
		ProductId = 3306060209,
		Callback = function(Player: Player)
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

	-- // Server luck
	["x2 Luck"] = {
		ProductId = 3302030360,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)

			ReplicatedStorage.LuckTime.Value = 600
			ReplicatedStorage.CurrentLuck.Value = 2

			task.spawn(function()
				while ReplicatedStorage.LuckTime.Value > 0 do
					task.wait(1)
					ReplicatedStorage.LuckTime.Value -= 1
				end
				Signals.ResetServerLuck:Fire()
				ReplicatedStorage.CurrentLuck.Value = 1
			end)
			ReplicatedStorage.Remotes.ShowNotification:FireAllClients(
				`{Player.Name} has purchased 2x luck for 10 minutes!`,
				Color3.fromRGB(0, 255, 0)
			)
			return Signals.IncreaseServerLuck:Fire()
		end,
	},

	["ForeverPack1"] = {
		ProductId = 3312923714,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)

			DataUtil.ClaimNextForeverPackReward(Player)

			return
		end,
	},

	["ForeverPack2"] = {
		ProductId = 3312923870,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)

			DataUtil.ClaimNextForeverPackReward(Player)

			return
		end,
	},

	["ForeverPack3"] = {
		ProductId = 3312923925,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)

			DataUtil.ClaimNextForeverPackReward(Player)

			return
		end,
	},

	["ForeverPack4"] = {
		ProductId = 3312923968,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)

			DataUtil.ClaimNextForeverPackReward(Player)

			return
		end,
	},

	["ForeverPack5"] = {
		ProductId = 3312924078,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)

			DataUtil.ClaimNextForeverPackReward(Player)

			return
		end,
	},

	["x4 Luck"] = {
		ProductId = 3302030707,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)

			ReplicatedStorage.LuckTime.Value = 600
			ReplicatedStorage.CurrentLuck.Value = 4
			ReplicatedStorage.Remotes.ShowNotification:FireAllClients(
				`{Player.Name} has purchased 4x luck for 10 minutes!`,
				Color3.fromRGB(0, 255, 0)
			)

			Signals.IncreaseServerLuck:Fire()
		end,
	},
	["x8 Luck"] = {
		ProductId = 3302030706,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)

			ReplicatedStorage.LuckTime.Value = 600
			ReplicatedStorage.CurrentLuck.Value = 8
			ReplicatedStorage.Remotes.ShowNotification:FireAllClients(
				`{Player.Name} has purchased 8x luck for 10 minutes!`,
				Color3.fromRGB(0, 255, 0)
			)

			Signals.IncreaseServerLuck:Fire()
		end,
	},
	["x16 Luck"] = {
		ProductId = 3302031086,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)

			ReplicatedStorage.LuckTime.Value = 600
			ReplicatedStorage.CurrentLuck.Value = 16
			ReplicatedStorage.Remotes.ShowNotification:FireAllClients(
				`{Player.Name} has purchased 16x luck for 10 minutes!`,
				Color3.fromRGB(0, 255, 0)
			)

			Signals.IncreaseServerLuck:Fire()
		end,
	},

	-- // Cash
	["Double Offline Cash"] = {
		ProductId = 3306164962,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)

			ReplicatedStorage.Remotes.CloseAllFrames:FireClient(Player)
			ReplicatedStorage.Remotes.ShowNotification:FireClient(
				Player,
				"You have doubled your offline cash successfully!",
				Color3.fromRGB(0, 255, 0)
			)

			Signals.DoubleOfflineCash:Fire(Player)
		end,
	},

	["Money Pack 1"] = {
		ProductId = 3301582459,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)
			DataUtil:IncrementCash(Player, 2_000)
		end,
	},
	["Money Pack 2"] = {
		ProductId = 3301582458,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)
			DataUtil:IncrementCash(Player, 20_000)
		end,
	},
	["Money Pack 3"] = {
		ProductId = 3301582457,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)
			DataUtil:IncrementCash(Player, 75_000)
		end,
	},
	["Money Pack 4 (MOST POPULAR)"] = {
		ProductId = 3301582456,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)
			DataUtil:IncrementCash(Player, 200_000)
		end,
	},
	["Money Pack 5 (BEST DEAL)"] = {
		ProductId = 3301583025,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)
			DataUtil:IncrementCash(Player, 1_500_000)
		end,
	},
}
