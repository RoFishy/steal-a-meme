-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules
local Types = require(Modules.Types)

local DataTemplate: Types.UserData = {
	Cash = 400,
	Rebirths = 0,
	Steals = 0,
	LockTime = 60,
	Slots = {},
	LastJoin = nil,
	Index = {
		Normal = {},
		Golden = {},
		Diamond = {},

		-- // Weather events
		Flaming = {},
	},
	NewPlayer = true,
	ClaimedVIPPet = true,
	ClaimedFreePet = false,
	ForeverPack = {},
	LastForeverPackReset = 0,
	Quests = {
		LebronPortal = {
			StolenMemes = 0,
		},
	},
}

return DataTemplate
