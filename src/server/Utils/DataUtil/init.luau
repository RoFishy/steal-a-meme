-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // shared modules
local Modules = ReplicatedStorage.Modules
local Types = require(Modules.Types)

-- // Modules
local DataTemplate = require(script.Template)
local ProfileStore = require(script.ProfileStore)

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

function DataUtil:GetProfile(Player: Player): Types.UserData
	if self:IsProfileLoaded(Player) then
		return Profiles[Player]
	else
		return "Profile not loaded"
	end
end

function DataUtil:CleanupProfile(Player: Player)
	if Profiles[Player] then
		Profiles[Player]:EndSession()
	end
end

return DataUtil
