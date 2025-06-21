-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

-- // shared modules
local ForeverPack = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ForeverPack"))
local Modules = ReplicatedStorage.Modules
local Types = require(Modules.Types)

-- // Modules
local DataTemplate = require(script.Template)
local ProfileStore = require(script.ProfileStore)

-- // Packages
local Packages = ReplicatedStorage.Packages
local Replica = require(Packages.Replica)

-- // Ordered DS
local StealsOrderedDS = DataStoreService:GetOrderedDataStore("OrderedSteals")
local CashOrderedDS = DataStoreService:GetOrderedDataStore("OrderedCash")

-- // Remotes
local Remotes = ReplicatedStorage.Remotes

-- // Utils
local Utils = script.Parent
local Meme = require(Utils.Meme)
local Signals = require(Utils.Signals)

-- // Store
local PlayerStore = ProfileStore.New("PlayerStore", DataTemplate)

-- // Const
local DATA_TOKEN = Replica.Token("PlayerData")
local MAX_OFFLINE_EARNINGS_TIME = 10800

-- // Var
local Profiles = {} :: { [Player]: typeof(ProfileStore:StartSessionAsync()) }
local MemeReferences = {}
local PlayersPurchasingMemes = {}
local Replicas = {}

-- // local funcs
local function GetPlayerBase(Player: Player)
	for _, Base in workspace.Bases:GetChildren() do
		if Base:GetAttribute("Owner") == Player.Name then
			return Base
		end
	end
end
local function GetDictionaryLength(Dictionary: {})
	local i = 0
	for _, _ in Dictionary do
		i += 1
	end
	return i
end

-- // Module
local DataUtil = {}

local PackResetTime = 21600

DataUtil.RefreshForeverPack = function(Player)
	local Profile = Profiles[Player]
	if Profile then
		Profile.Data.LastForeverPackReset = workspace:GetServerTimeNow()
		Profile.Data.ForeverPack = {}

		for i = 1, 5 do
			local ChosenRewardIndex = ForeverPack.PickRandomRewardIndex()

			Profile.Data.ForeverPack[tostring(i)] = {
				RewardIndex = ChosenRewardIndex,
			}
		end
	end

	local _replica = Replicas[Player]
	_replica:Set({ "ForeverPack" }, Profile.Data.ForeverPack)
	_replica:Set({ "LastForeverPackReset" }, Profile.Data.LastForeverPackReset)
end

DataUtil.ClaimNextForeverPackReward = function(Player)
	local Profile = Profiles[Player]
	if Profile then
		local NextTableIndex = ForeverPack.GetNextIndex(Profile.Data.ForeverPack)
		--print("Server: ", Profile.Data.ForeverPack, NextTableIndex)
		local RewardIndex = Profile.Data.ForeverPack[tostring(NextTableIndex)].RewardIndex

		task.spawn(function()
			ForeverPack.Rewards[RewardIndex].ClaimFunction(Player)
		end)

		Profile.Data.ForeverPack[tostring(NextTableIndex)] = nil

		local ChosenRewardIndex = ForeverPack.PickRandomRewardIndex()

		Profile.Data.ForeverPack[tostring(NextTableIndex + 5)] = {
			RewardIndex = ChosenRewardIndex,
		}

		local _replica = Replicas[Player]
		_replica:Set({ "ForeverPack" }, Profile.Data.ForeverPack)
		_replica:Set({ "LastForeverPackReset" }, Profile.Data.LastForeverPackReset)

		Remotes.ShowNotification:FireClient(Player, "Reward Claimed!", Color3.fromRGB(38, 255, 45))
	end
end

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
			if GetDictionaryLength(Profile.Data.Index) > 4 and GetDictionaryLength(Profile.Data.Index.Normal) == 0 then
				local normalTable = {}
				for index, value in Profile.Data.Index do
					if typeof(index) == "string" then
						continue
					end
					normalTable[index] = value
				end
				Profile.Data.Index = {}
				Profile.Data.Index["Normal"] = normalTable
				Profile.Data.Index.Golden = {}
				Profile.Data.Index.Diamond = {}
				Profile.Data.Index.Flaming = {}
			end
			if Profile.Data.Cash > 1_000_000_000_000 then
				Profile.Data.Cash = 500
			end
			if Profile.Data.Steals > 10_000 then
				Profile.Data.Steals = 0
			end

			DataUtil:_SetupLeaderstats(Player)
			DataUtil:LoadMemes(Player)

			if workspace:GetServerTimeNow() - Profile.Data.LastForeverPackReset >= PackResetTime then
				DataUtil.RefreshForeverPack(Player)
			end

			task.spawn(function()
				while Player and Player.Parent and Profiles[Player] do
					if workspace:GetServerTimeNow() - Profile.Data.LastForeverPackReset >= PackResetTime then
						DataUtil.RefreshForeverPack(Player)
					end

					task.wait(1)
				end
			end)
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

function DataUtil:SetFreePetClaimed(Player: Player)
	local Profile = Profiles[Player]
	if Profile then
		Profile.Data.ClaimedFreePet = true
	end
end

function DataUtil:SetVIPPetClaimed(Player: Player)
	local Profile = Profiles[Player]
	if Profile then
		Profile.Data.ClaimedVIPPet = true
	end
end

function DataUtil:IncrementLockTime(Player: Player, Amount: number)
	local Profile = Profiles[Player]
	if Profile then
		Profile.Data.LockTime += Amount
	end
end

function DataUtil:GetPlayersPurchasingMemes()
	return PlayersPurchasingMemes
end

function DataUtil:UpdatePlayersPurchasingMemes(NewTable: {})
	PlayersPurchasingMemes = NewTable
end

function DataUtil:AddMemeToPlayer(Player: Player, MemeObj)
	local Profile = Profiles[Player]
	if Profile then
		Profile.Data.Slots[MemeObj.Model:GetAttribute("ID")] = {
			Name = MemeObj.Name,
			--Info = MemeObj.Info,
			Rarity = MemeObj.Rarity,
			Stand = MemeObj.CurrentStand.Name,
			Special = MemeObj.Special,

			-- // cleanup on game end:
			--Model = MemeObj.Model,
		}
		MemeReferences[MemeObj.Model:GetAttribute("ID")] = MemeObj.Model

		local Table = Profile.Data.Index.Normal
		if MemeObj.Special then
			Table = Profile.Data.Index[MemeObj.Special]
		end
		if not table.find(Table, MemeObj.Name) then
			local _replica = Replicas[Player]
			table.insert(Table, MemeObj.Name)
			_replica:Set({ "Index" }, Profile.Data.Index)
			local Text = "You have discovered the " .. MemeObj.Name .. " Meme! It has been added to your Index."
			if MemeObj.Special then
				Text =
					`You have discovered the {string.upper(MemeObj.Special)} {MemeObj.Name}! It has been added to your {MemeObj.Special} Index.`
			end
			Remotes.ShowNotification:FireClient(Player, Text, Color3.fromRGB(0, 217, 255))
		end
	end
end

function DataUtil:LoadMemes(Player: Player)
	local Profile = Profiles[Player]
	if Profile then
		local PlayerBase = GetPlayerBase(Player)

		local Slots = Profile.Data.Slots
		local CurrentOfflineCash = 0
		for ID, Slot in Slots do
			local OpenSlot = PlayerBase.Slots:FindFirstChild(Slot.Stand) or Meme:GetOpenSlot(PlayerBase.Slots)
			if OpenSlot and OpenSlot:GetAttribute("Meme") then
				OpenSlot = Meme:GetOpenSlot(PlayerBase.Slots)
			end
			if not OpenSlot then
				continue
			end
			OpenSlot:SetAttribute("Meme", Slot.Name)
			local _meme = Meme.new(Slot.Name, Slot.Rarity, CFrame.new(0, 0, 0), Slot.Special, true)
			MemeReferences[ID] = _meme.Model
			_meme.Model:SetAttribute("ID", ID)
			_meme.PurchasePlayer = Player
			_meme.CurrentStand = OpenSlot
			--Profile.Data.Slots[ID].Model = _meme.Model
			task.cancel(_meme.CurrentMove)
			local offlineEarnings = self:CalculateOfflineEarnings(Player, _meme)
			CurrentOfflineCash += offlineEarnings
			_meme:AddToSlot(OpenSlot, true, offlineEarnings)

			Signals.DoubleOfflineCash:Connect(function(_Player: Player)
				if Player == _Player then
					_meme:SetOfflineCash(offlineEarnings, offlineEarnings * 2)
				end
			end)
		end
		task.delay(3, function()
			if CurrentOfflineCash > 0 then
				Remotes.DoubleCashFrame:FireClient(Player, CurrentOfflineCash)
			end
		end)
	end
end

function DataUtil:CalculateOfflineEarnings(Player: Player, MemeObj): number?
	local Profile = Profiles[Player]
	if Profile then
		local LastJoin = Profile.Data.LastJoin
		if LastJoin then
			local Time = tick() - LastJoin
			local Income = MemeObj.Info.Income
				* (Time < MAX_OFFLINE_EARNINGS_TIME and Time or MAX_OFFLINE_EARNINGS_TIME)

			return math.abs(math.ceil(Income / 2))
		end
	end
	return nil
end

function DataUtil:RemoveMemeFromPlayer(Player: Player, MemeObj, ID: string?)
	local Profile = Profiles[Player]
	if ID then
		Profile.Data.Slots[ID] = nil
	else
		if Profile and MemeObj.Model:GetAttribute("ID") then
			Profile.Data.Slots[MemeObj.Model:GetAttribute("ID")] = nil
		end
	end
end

function DataUtil:GetCurrentMemes(Player: Player)
	local Profile = Profiles[Player]
	if Profile then
		return Profile.Data.Slots
	end
end

function DataUtil:GetCurrentMemeReferences()
	return MemeReferences
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
		for ID, Slot in Profiles[Player].Data.Slots do
			if Slot.Model then
				Profiles[Player].Data.Slots[ID].Model = nil
			end
		end
		task.spawn(function()
			local data = Profiles[Player].Data
			CashOrderedDS:SetAsync(Player.UserId, math.ceil(data.Cash))
			StealsOrderedDS:SetAsync(Player.UserId, math.ceil(data.Steals))
		end)
		Profiles[Player].Data.LastJoin = tick()
		Profiles[Player].Data.NewPlayer = false
		Profiles[Player]:EndSession()
	end
end

return DataUtil
