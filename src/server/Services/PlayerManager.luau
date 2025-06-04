-- // Services
local Players = game:GetService("Players")

-- // managers
local BaseManager = require(script.Parent.BaseManager)

-- // Utils
local Utils = script.Parent.Parent.Utils
local DataUtil = require(Utils.DataUtil)

-- // Module
local PlayerManager = {}

function PlayerManager:Start()
	Players.PlayerAdded:Connect(function(Player: Player)
		DataUtil.new(Player)
		BaseManager:AssignBase(Player)
	end)
	Players.PlayerRemoving:Connect(function(Player)
		local Base = BaseManager:GetBaseNameFromPlayer(Player)
		if Base then
			BaseManager:ResetBase(Base)
		end
		DataUtil:CleanupProfile(Player)
	end)
end

return PlayerManager
