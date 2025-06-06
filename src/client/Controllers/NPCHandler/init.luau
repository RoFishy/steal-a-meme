-- // Objects
local ShopNPCCharacter = workspace:WaitForChild("ShopNPC")
local RobuxShopNPCCharacter = workspace:WaitForChild("RobuxShopNPC")

-- // Utils
local Signals = require(script.Parent.Utils.Signals)

-- //Modules
local NPC = require(script.NPC)
local UIManager = require(script.Parent.UIHandler)

-- // Module
local NPCManager = {}

function NPCManager:Start()
	local ShopNPC
	ShopNPC = NPC.new(ShopNPCCharacter, {
		[1] = {
			Option = "Open Shop",
			Callback = function()
				ShopNPC:Say("Computing!")
				UIManager:OpenFrame("ItemShop")
				Signals.ClosedFrame:Wait()
			end,
		},
		[2] = {
			Option = "Goodbye!",
		},
	}, "How can I help you?", "Buy NPC")
	local RobuxShopNPC
	RobuxShopNPC = NPC.new(RobuxShopNPCCharacter, {
		[1] = {
			Option = "Open Shop",
			Callback = function()
				RobuxShopNPC:Say("Computing!")
				UIManager:OpenFrame("Shop")
				Signals.ClosedFrame:Wait()
			end,
		},
		[2] = {
			Option = "Goodbye!",
		},
	}, "How can I help you?", "Buy NPC")
end

return NPCManager
