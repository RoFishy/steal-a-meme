-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Modules
local Modules = ReplicatedStorage.Modules
local Tools = require(Modules.Tools)

-- // folder
local ToolsFolder = ReplicatedStorage.Tools

-- // utils
local Utils = script.Parent.Parent.Utils
local DataUtil = require(Utils.DataUtil)

-- // Remotes
local Remotes = ReplicatedStorage.Remotes
local PurchaseTool = Remotes.PurchaseTool

-- // Init
local ToolManager = {}

function ToolManager:Start()
	PurchaseTool.OnServerEvent:Connect(function(Player: Player, ToolName: string)
		local PlayerData = DataUtil:GetData(Player)
		local ToolInfo = Tools[ToolName]
		if PlayerData.Cash >= ToolInfo.Price and PlayerData.Rebirths >= ToolInfo.RebirthsRequired then
			DataUtil:IncrementCash(Player, -ToolInfo.Price)
			local ToolModel = ToolsFolder[ToolName]:Clone()
			ToolModel.Parent = Player.Backpack
		end
	end)
end

return ToolManager
