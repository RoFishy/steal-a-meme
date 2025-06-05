-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // shared modules
local Modules = ReplicatedStorage.Modules
local Types = require(Modules.Types)

-- // Modules
local DataTemplate = require(script.Template)
local ProfileStore = require(script.ProfileStore)

-- // Managers
local Services = script.Parent.Parent.Services
local BaseManager = require(Services.BaseManager)

-- // Utils
local Utils = script.Parent
local Meme = require(Utils.Meme)

-- // Store
local PlayerStore = ProfileStore.New("PlayerStore", DataTemplate)

-- // Var
local Profiles = {} :: { [Player]: typeof(ProfileStore:StartSessionAsync()) }

-- // Module
local DataUtil = {}

function DataUtil.new(Player: Player)
	local Profile = PlayerStore:StartSessionAsync(`{Player.UserId}`, {
		Cancel = function()
			return Player.Parent ~= Players
		end,
	})

	if Profile ~= nil then
		Profile:AddUserId(Player.UserId)
		Profile:Reconcile()

		Profile.OnSessionEnd:Connect(function()
			Profiles[Player] = nil
			Player:Kick("Profile session end - Please Rejoin")
		end)

		if Player.Parent == Players then
			Profiles[Player] = Profile
			DataUtil:_SetupLeaderstats(Player)
			DataUtil:LoadMemes(Player)
		else
			Profile:EndSession()
		end
	else
		Player:Kick(`Profile load fail - Please Rejoin`)
	end
end

function DataUtil:_SetupLeaderstats(Player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = Player

	local Cash = Instance.new("IntValue")
	Cash.Name = "Cash"
	Cash.Parent = leaderstats

	local Profile = Profiles[Player]
	if Profile then
		Cash.Value = Profile.Data.Cash
	end
end

function DataUtil:IsProfileLoaded(Player: Player)
	if Profiles[Player] then
		return true
	end
	return false
end

function DataUtil:IncrementCash(Player: Player, Amount: number)
	local Profile = Profiles[Player]
	if Profile then
		Profile.Data.Cash += Amount
		Player.leaderstats.Cash.Value = Profile.Data.Cash
	end
end

function DataUtil:AddMemeToPlayer(Player: Player, MemeObj)
	local Profile = Profiles[Player]
	if Profile then
		Profile.Data.Slots[MemeObj.Model:GetAttribute("ID")] = {
			Name = MemeObj.Name,
			Info = MemeObj.Info,
			Rarity = MemeObj.Rarity,
			Stand = MemeObj.CurrentStand.Name,
		}
	end
end

function DataUtil:LoadMemes(Player: Player)
	local Profile = Profiles[Player]
	if Profile then
		local PlayerBase = BaseManager:GetBaseNameFromPlayer(Player)
		PlayerBase = workspace.Bases:FindFirstChild(PlayerBase)

		local Slots = Profile.Data.Slots
		for ID, Slot in Slots do
			local OpenSlot = PlayerBase.Slots:FindFirstChild(Slot.Stand) or Meme:GetOpenSlot(PlayerBase.Slots)
			local _meme = Meme.new(Slot.Name, "", CFrame.new(0, 0, 0), Slot)
			_meme.Model:SetAttribute("ID", ID)
			_meme.PurchasePlayer = Player
			_meme.CurrentStand = OpenSlot
			task.cancel(_meme.CurrentMove)
			task.spawn(function()
				local offlineEarnings = self:CalculateOfflineEarnings(Player, _meme)
				_meme:AddToSlot(OpenSlot, false, offlineEarnings)
			end)
		end
	end
end

function DataUtil:CalculateOfflineEarnings(Player: Player, MemeObj): number?
	local Profile = Profiles[Player]
	if Profile then
		local LastJoin = Profile.Data.LastJoin
		if LastJoin then
			local Time = tick() - LastJoin
			local Income = MemeObj.Info.Income * Time

			return Income
		end
	end
	return nil
end

function DataUtil:RemoveMemeFromPlayer(Player: Player, MemeObj)
	local Profile = Profiles[Player]
	if Profile then
		Profile.Data.Slots[MemeObj.Model:GetAttribute("ID")] = nil
	end
end

function DataUtil:GetData(Player: Player): Types.UserData
	if self:IsProfileLoaded(Player) then
		return Profiles[Player].Data
	else
		return "Profile not loaded"
	end
end

function DataUtil:CleanupProfile(Player: Player)
	if Profiles[Player] then
		Profiles[Player].Data.LastJoin = tick()
		Profiles[Player]:EndSession()
	end
end

return DataUtil
