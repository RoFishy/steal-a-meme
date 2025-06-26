-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Packages
local Packages = ReplicatedStorage.Packages
local Replica = require(Packages.Replica)

-- // obj
local LebronPortal = workspace:WaitForChild("LebronPortal")

-- // init
local QuestHandler = {}

function QuestHandler:Start()
	Replica.OnNew("PlayerData", function(replica)
		replica:OnSet({ "QuestData" }, function(new_value)
			print(new_value)
			-- //Lebron quest
			local lebronQuestData = new_value["LebronPortal"]
			local StolenMemes = lebronQuestData["StolenMemes"]
			LebronPortal.prompt.amount.Billboard.Main:FindFirstChild("Name").Text = `{StolenMemes}/10`
		end)
	end)
end

return QuestHandler
