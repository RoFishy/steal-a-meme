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
		Chance = 40,
		Text = "$500",
		ClaimFunction = function(Player)
			local ServerScriptService = game:GetService("ServerScriptService")
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)

			DataUtil:IncrementCash(Player, 500)
		end,
	},

	[2] = {

		Image = "rbxassetid://81389192039217",
		Chance = 20,
		Text = "$1k",
		ClaimFunction = function(Player)
			local ServerScriptService = game:GetService("ServerScriptService")
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)

			DataUtil:IncrementCash(Player, 1_000)
		end,
	},

	[3] = {

		Image = "rbxassetid://81389192039217",
		Chance = 15,
		Text = "$2.5K",
		ClaimFunction = function(Player)
			local ServerScriptService = game:GetService("ServerScriptService")
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)

			DataUtil:IncrementCash(Player, 2500)
		end,
	},

	[4] = {

		Image = "rbxassetid://81389192039217",
		Chance = 7,
		Text = "$10K",
		ClaimFunction = function(Player)
			local ServerScriptService = game:GetService("ServerScriptService")
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)

			DataUtil:IncrementCash(Player, 10000)
		end,
	},

	[5] = {

		Image = "rbxassetid://81389192039217",
		Chance = 5,
		Text = "$50k",
		ClaimFunction = function(Player)
			local ServerScriptService = game:GetService("ServerScriptService")
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)

			DataUtil:IncrementCash(Player, 50000)
		end,
	},

	[6] = {

		Image = "rbxassetid://117363268823396",
		Chance = 4,
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

	[7] = {

		Image = "rbxassetid://81389192039217",
		Chance = 5,
		Text = "$250k",
		ClaimFunction = function(Player)
			local ServerScriptService = game:GetService("ServerScriptService")
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)

			DataUtil:IncrementCash(Player, 250_000)
		end,
	},

	[8] = {

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

	[9] = {

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

	[10] = {

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

	[11] = {

		Image = "rbxassetid://81389192039217",
		Chance = 0.7,
		Text = "$1M",
		ClaimFunction = function(Player)
			local ServerScriptService = game:GetService("ServerScriptService")
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)

			DataUtil:IncrementCash(Player, 5_000_000)
		end,
	},

	[13] = {

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
