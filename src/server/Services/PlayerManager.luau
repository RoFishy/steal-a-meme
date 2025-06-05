-- // Services
local Players = game:GetService("Players")

-- // managers
local BaseManager = require(script.Parent.BaseManager)

-- // Utils
local Utils = script.Parent.Parent.Utils
local DataUtil = require(Utils.DataUtil)
local Signals = require(Utils.Signals)

-- // Module
local PlayerManager = {}

function PlayerManager:Start()
	Players.PlayerAdded:Connect(function(Player: Player)
		task.spawn(function()
			DataUtil.new(Player)
		end)
		BaseManager:AssignBase(Player)
	end)
	Players.PlayerRemoving:Connect(function(Player)
		local Base = BaseManager:GetBaseNameFromPlayer(Player)
		if Base then
			BaseManager:ResetBase(Base)
		end
		DataUtil:CleanupProfile(Player)
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
