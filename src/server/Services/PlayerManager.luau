-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BadgeService = game:GetService("BadgeService")

-- // managers
local BaseManager = require(script.Parent.BaseManager)
local PassManager = require(script.Parent.PassManager)

-- // Utils
local Utils = script.Parent.Parent.Utils
local DataUtil = require(Utils.DataUtil)
local Signals = require(Utils.Signals)
local TutorialUtil = require(Utils.TutorialUtil)

-- // Packages
local Packages = ReplicatedStorage.Packages
local Replica = require(Packages.Replica)

-- // const
local JOIN_BADGES = {
	2402115111693328,
	754605630599465,
	3081929432379574,
	4092411003650709,
}

-- // Module
local PlayerManager = {}

function PlayerManager:Start()
	Players.PlayerAdded:Connect(function(Player: Player)
		task.spawn(function()
			DataUtil.new(Player)
		end)
		BaseManager:AssignBase(Player)
		task.delay(1, function()
			if DataUtil:FirstTimePlayer(Player) then
				TutorialUtil.new(Player)
			end
			PassManager:LoadPlayerPasses(Player)
		end)
		for _, BadgeId in JOIN_BADGES do
			BadgeService:AwardBadge(Player.UserId, BadgeId)
		end
	end)
	Players.PlayerRemoving:Connect(function(Player)
		local Base = BaseManager:GetBaseNameFromPlayer(Player)
		if Base then
			BaseManager:ResetBase(Base)
		end
		DataUtil:CleanupProfile(Player)
	end)
	Replica.NewReadyPlayer:Connect(function(Player: Player)
		DataUtil:SetupReplica(Player)
	end)
	Signals.IncrementCash:Connect(function(Player: Player, Cash: number)
		DataUtil:IncrementCash(Player, Cash)
	end)
	Signals.AddMemeToPlayer:Connect(function(Player: Player, MemeObj)
		DataUtil:AddMemeToPlayer(Player, MemeObj)
	end)
	Signals.RemoveMemeFromPlayer:Connect(function(Player: Player, MemeObj)
		DataUtil:RemoveMemeFromPlayer(Player, MemeObj)
	end)
end

return PlayerManager
