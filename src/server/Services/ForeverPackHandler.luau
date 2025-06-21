-- // services
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ForeverPack = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ForeverPack"))

-- // Util
local Utils = script.Parent.Parent.Utils
local DataUtil = require(Utils.DataUtil)

-- // Remotes
local Remotes = ReplicatedStorage.Remotes
local RewardRemote = Remotes.ClaimForeverPack

-- // Init
local ForeverPackHandler = {}

function ForeverPackHandler:Start()
	RewardRemote.OnServerInvoke = function(Player)
		local PlayerData = DataUtil:GetData(Player)

		if PlayerData then
			local NextIndex = ForeverPack.GetNextIndex(PlayerData.ForeverPack)

			local Cost = ForeverPack.GetPriceFromIndex(NextIndex)

			if not tonumber(Cost) then
				DataUtil.ClaimNextForeverPackReward(Player)

				return PlayerData.ForeverPack
			else
				MarketplaceService:PromptProductPurchase(Player, Cost)
			end
		end
	end
end

return ForeverPackHandler
