-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BadgeService = game:GetService("BadgeService")
local ServerStorage = game:GetService("ServerStorage")

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

-- // folder
local ItemTools = ServerStorage.ItemTools

-- // const
local JOIN_BADGES = {
	754605630599465, -- E
	2402115111693328, -- M
	4092411003650709, -- E
	3081929432379574, -- M
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
		for i = 1, #JOIN_BADGES do
			local BadgeId = JOIN_BADGES[i]
			BadgeService:AwardBadge(Player.UserId, BadgeId)
		end

		local character

		local con

		local function Reconnect()
			character = Player.Character or Player.CharacterAdded:Wait()
			con = character:WaitForChild("Humanoid").Died:Connect(function()
				for _, item in ipairs(Player.Backpack:GetChildren()) do
					if item:IsA("Tool") and item.Name ~= "DefaultBat" then
						local PlayerItemFolder = ItemTools:FindFirstChild(Player.Name) or Instance.new("Folder")
						PlayerItemFolder.Parent = ItemTools
						PlayerItemFolder.Name = Player.Name
						item:Clone().Parent = PlayerItemFolder
					end
				end
				for _, item in Player.Character:GetChildren() do
					if item:IsA("Tool") and item.Name ~= "DefaultBat" then
						local PlayerItemFolder = ItemTools:FindFirstChild(Player.Name) or Instance.new("Folder")
						PlayerItemFolder.Parent = ItemTools
						PlayerItemFolder.Name = Player.Name
						item:Clone().Parent = PlayerItemFolder
					end
				end
			end)
		end

		Reconnect()

		Player.CharacterAdded:Connect(function()
			if ItemTools:FindFirstChild(Player.Name) then
				for _, item in ItemTools[Player.Name]:GetChildren() do
					item.Parent = Player:WaitForChild("Backpack")
				end

				con:Disconnect()
				Reconnect()

				BaseManager:TeleportPlayerToBase(Player)
			end
		end)
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
