-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // shared modules
local Modules = ReplicatedStorage.Modules
local Types = require(Modules.Types)

-- // Modules
local DataTemplate = require(script.Template)
local ProfileStore = require(script.ProfileStore)

-- // Packages
local Packages = ReplicatedStorage.Packages
local Replica = require(Packages.Replica)

-- // Remotes
local Remotes = ReplicatedStorage.Remotes

-- // Utils
local Utils = script.Parent
local Meme = require(Utils.Meme)

-- // Store
local PlayerStore = ProfileStore.New("PlayerStore", DataTemplate)

-- // Const
local DATA_TOKEN = Replica.Token("PlayerData")

-- // Var
local Profiles = {} :: { [Player]: typeof(ProfileStore:StartSessionAsync()) }
local Replicas = {}

-- // local funcs
local function GetPlayerBase(Player: Player)
	for _, Base in workspace.Bases:GetChildren() do
		if Base:GetAttribute("Owner") == Player.Name then
			return Base
		end
	end
end

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

function DataUtil:SetupReplica(Player: Player)
	local Profile = Profiles[Player]
	if Player:IsDescendantOf(Players) and not Profile then
		repeat
			task.wait()
		until Profiles[Player]
		Profile = Profiles[Player]
	end
	local _replica = Replica.New({
		Token = DATA_TOKEN,
		Data = Profile.Data,
	})
	Replicas[Player] = _replica
	_replica:Subscribe(Player)
	_replica:Set({ "Index" }, Profile.Data.Index)
end

function DataUtil:FirstTimePlayer(Player: Player): boolean
	local Profile = Profiles[Player]
	if Profile then
		return Profile.Data.NewPlayer == true
	end
end

function DataUtil:_SetupLeaderstats(Player: Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = Player

	local Cash = Instance.new("IntValue")
	Cash.Name = "Cash"
	Cash.Parent = leaderstats

	local Steals = Instance.new("IntValue")
	Steals.Name = "Steals"
	Steals.Parent = leaderstats

	local Rebirths = Instance.new("IntValue")
	Rebirths.Name = "Rebirths"
	Rebirths.Parent = leaderstats

	local Profile = Profiles[Player]
	if Profile then
		Cash.Value = Profile.Data.Cash
		Steals.Value = Profile.Data.Steals
		Rebirths.Value = Profile.Data.Rebirths
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

function DataUtil:IncrementSteals(Player: Player, Amount: number)
	local Profile = Profiles[Player]
	if Profile then
		Profile.Data.Steals += Amount
		Player.leaderstats.Steals.Value = Profile.Data.Steals
	end
end

function DataUtil:IncrementRebirths(Player: Player, Amount: number)
	local Profile = Profiles[Player]
	if Profile then
		Profile.Data.Rebirths += Amount
		Player.leaderstats.Rebirths.Value = Profile.Data.Rebirths
	end
end

function DataUtil:IncrementLockTime(Player: Player, Amount: number)
	local Profile = Profiles[Player]
	if Profile then
		Profile.Data.LockTime += Amount
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

			-- // cleanup on game end:
			Model = MemeObj.Model,
		}
		if not table.find(Profile.Data.Index, MemeObj.Name) then
			local _replica = Replicas[Player]
			table.insert(Profile.Data.Index, MemeObj.Name)
			_replica:Set({ "Index" }, Profile.Data.Index)
			Remotes.ShowNotification:FireClient(
				Player,
				"You have discovered the " .. MemeObj.Name .. " Meme! It has been added to your Index.",
				Color3.fromRGB(0, 217, 255)
			)
		end
	end
end

function DataUtil:LoadMemes(Player: Player)
	local Profile = Profiles[Player]
	if Profile then
		local PlayerBase = GetPlayerBase(Player)

		local Slots = Profile.Data.Slots
		for ID, Slot in Slots do
			local OpenSlot = PlayerBase.Slots:FindFirstChild(Slot.Stand) or Meme:GetOpenSlot(PlayerBase.Slots)
			if OpenSlot:GetAttribute("Meme") then
				OpenSlot = Meme:GetOpenSlot(PlayerBase.Slots)
			end
			OpenSlot:SetAttribute("Meme", Slot.Name)
			local _meme = Meme.new(Slot.Name, "", CFrame.new(0, 0, 0), Slot)
			_meme.Model:SetAttribute("ID", ID)
			_meme.PurchasePlayer = Player
			_meme.CurrentStand = OpenSlot
			task.cancel(_meme.CurrentMove)
			local offlineEarnings = self:CalculateOfflineEarnings(Player, _meme)
			_meme:AddToSlot(OpenSlot, true, offlineEarnings)
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

function DataUtil:GetCurrentMemes(Player: Player)
	local Profile = Profiles[Player]
	if Profile then
		return Profile.Data.Slots
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
		for _, Slot in Profiles[Player].Data.Slots do
			if Slot.Model then
				Slot.Model = nil
			end
		end
		Profiles[Player].Data.LastJoin = tick()
		Profiles[Player].Data.NewPlayer = false
		Profiles[Player]:EndSession()
	end
end

return DataUtil
