-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GamepassItems = ReplicatedStorage.GamepassItems
local Tools = ReplicatedStorage.Tools

local function GetPlayerBase(Player: Player)
	for _, Base in workspace.Bases:GetChildren() do
		if Base:GetAttribute("Owner") == Player.Name then
			return Base
		end
	end
end

return {
	["Cloud"] = {
		Id = 1246323898,
		Callback = function(Player: Player)
			local Tool = GamepassItems["Flying Cloud"]:Clone()
			Tool.Parent = Player.Backpack

			return
		end,
	},
	["Sledgehammer"] = {
		Id = 1244387266,
		Callback = function(Player: Player)
			local Tool = GamepassItems.Sledgehammer:Clone()
			Tool.Parent = Player.Backpack

			return
		end,
	},
	--[[
	["Admin"] = {
		Id = 1244393091,
		Callback = function(Player: Player)
			local hdMain = require(game:GetService("ReplicatedStorage"):WaitForChild("HDAdminSetup")):GetMain()
			local hd = hdMain:GetModule("API")
			local plrRankId = hd:GetRank(Player)
			local rank = "VIP"
			local rankType = "Server"
			local rankId = tonumber(rank) or hd:GetRankId(rank)
			if plrRankId > rankId then
				return
			end
			hd:SetRank(Player, rankId, rankType)
		end,
	},
	]]
	--
	["Galaxy Bat"] = {
		Id = 1244447495,
		Callback = function(Player: Player)
			local bat = GamepassItems["Galaxy Bat"]:Clone()
			bat.Parent = Player.Backpack
		end,
	},
	["Remote Lock"] = {
		Id = 1245956074,
		Callback = function(Player: Player)
			local Tool = GamepassItems["Remote Lock"]:Clone()
			Tool.Parent = Player.Backpack
		end,
	},
	["VIP"] = {
		Id = 1244153811,
		Callback = function(Player: Player)
			Player:SetAttribute("VIP", true)
			Player.Character.Humanoid.WalkSpeed *= 1.25
		end,
	},
	["Laser Gun"] = {
		Id = 1248083905,
		Callback = function(Player: Player)
			local Tool = GamepassItems["Laser Gun"]:Clone()
			Tool.Parent = Player.Backpack

			return
		end,
	},
	["x2 Cash"] = {
		Id = 1244580681,
		Callback = function(Player: Player)
			Player:SetAttribute("2xCash", true)
		end,
	},
	["x2 Speed"] = {
		Id = 1245248277,
		Callback = function(Player: Player)
			Player.Character.Humanoid.WalkSpeed *= 2
		end,
	},
	["Starter Pack"] = {
		Id = 1243804235,
		Callback = function(Player: Player)
			local Meme = require(game:GetService("ServerScriptService").Utils.Meme)
			local dataUtil = require(game:GetService("ServerScriptService").Utils.DataUtil)
			dataUtil:IncrementCash(Player, 2_500)

			local tool = Tools["Speed Coil"]:Clone()
			tool.Parent = Player.Backpack

			local bat = GamepassItems["Galaxy Bat"]:Clone()
			bat.Parent = Player.Backpack

			local PlayerBase = GetPlayerBase(Player)
			local OpenSlot = Meme:GetOpenSlot(PlayerBase.Slots)
			if not OpenSlot then
				return
			end
			local data = dataUtil:GetData(Player)
			if data.ClaimedVIPPet ~= true then
				local _meme = Meme.new("John Pork", "Legendary", CFrame.new(0, 0, 0))
				_meme.Model:SetAttribute("ID", game:GetService("HttpService"):GenerateGUID(false))
				_meme.PurchasePlayer = Player
				_meme.CurrentStand = OpenSlot
				task.cancel(_meme.CurrentMove)
				_meme:AddToSlot(OpenSlot)
				dataUtil:SetVIPPetClaimed(Player)
			end
		end,
	},
}
