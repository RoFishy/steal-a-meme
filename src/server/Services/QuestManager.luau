-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- // Utils
local Utils = game:GetService("ServerScriptService").Utils
local DataUtil = require(Utils.DataUtil)
local Meme = require(Utils.Meme)

-- // Objects
local LebronPortal = workspace:WaitForChild("LebronPortal")

-- // local funcs
local function GetPlayerBase(Player: Player)
	for _, Base in workspace.Bases:GetChildren() do
		if Base:GetAttribute("Owner") == Player.Name then
			return Base
		end
	end
end

local function GetMemeById(Id: string)
	for _, Model in workspace:GetDescendants() do
		if Model:GetAttribute("ID") and Model:GetAttribute("ID") == Id then
			return Model
		end
	end
end

-- // Vars
local Debounce = {}

-- // Init
local QuestManager = {}

function QuestManager:Start()
	LebronPortal.HitPart.Touched:Connect(function(hit: BasePart)
		local Player = Players:GetPlayerFromCharacter(hit.Parent)
		if Player then
			if Debounce[Player] then
				return
			end
			Debounce[Player] = true
			task.delay(4, function()
				Debounce[Player] = nil
			end)
			local StolenName = Player:GetAttribute("Stealing")
			if StolenName then
				Player:SetAttribute("Stealing", nil)
				local PlayerQuestData = DataUtil:GetQuestData(Player)
				local LebronQuestData = PlayerQuestData["LebronPortal"]

				if LebronQuestData["StolenMemes"] < 10 then
					local MemeModel = GetMemeById(StolenName)
					MemeModel:Destroy()
					local NewMemes = LebronQuestData["StolenMemes"] + 1
					DataUtil:UpdateQuestData(Player, "LebronPortal", "StolenMemes", NewMemes)
					ReplicatedStorage.Remotes.ShowNotification:FireClient(
						Player,
						"You have submitted a stolen meme to the portal!"
					)

					if NewMemes == 10 then
						ReplicatedStorage.Remotes.ShowNotification:FireClient(
							Player,
							"You have completed the Lebron Portal quest! Congrats!"
						)

						local PlayerBase = GetPlayerBase(Player)

						local OpenSlot = Meme:GetOpenSlot(PlayerBase.Slots)
						if not OpenSlot then
							ReplicatedStorage.Remotes.ShowNotification:FireClient(
								Player,
								"You do not have any open slots available!"
							)
							return
						end
						OpenSlot:SetAttribute("Meme", "Lebron")
						local _meme = Meme.new("Lebron", "QUEST", CFrame.new(0, 0, 0))
						_meme.Model:SetAttribute("ID", HttpService:GenerateGUID(false))
						_meme.PurchasePlayer = Player
						_meme.CurrentStand = OpenSlot
						task.cancel(_meme.CurrentMove)
						_meme:AddToSlot(OpenSlot)
					end
				else
					ReplicatedStorage.Remotes.ShowNotification:FireClient(
						Player,
						"You have already completed the Lebron Portal quest!"
					)
				end
			end
		end
	end)
end

return QuestManager
