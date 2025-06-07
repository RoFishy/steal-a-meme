-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Remotes
local Remotes = ReplicatedStorage.Remotes
local RebirthRemote = Remotes.Rebirth

-- // Modules
local Modules = ReplicatedStorage.Modules
local Rebirths = require(Modules.Rebirths)

-- // Utils
local Utils = script.Parent.Parent.Utils
local DataUtil = require(Utils.DataUtil)

-- // Init
local RebirthManager = {}

function RebirthManager:Start()
	RebirthRemote.OnServerEvent:Connect(function(Player: Player)
		local PlayerData = DataUtil:GetData(Player)
		if PlayerData.Cash >= Rebirths[PlayerData.Rebirths + 1].Cost then
			DataUtil:IncrementCash(Player, -PlayerData.Cash)
			DataUtil:IncrementCash(Player, 500)
			DataUtil:IncrementLockTime(Player, Rebirths[PlayerData.Rebirths + 1].Rewards.LockBoost)
			DataUtil:IncrementRebirths(Player, 1)

			local CurrentMemes = DataUtil:GetCurrentMemes(Player)
			print(CurrentMemes)
			for _, Meme in CurrentMemes do
				DataUtil:RemoveMemeFromPlayer(Player, Meme)
				Meme.Model:Destroy()
			end
		end
	end)
end

return RebirthManager
