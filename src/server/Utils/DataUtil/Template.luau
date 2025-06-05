-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules
local Types = require(Modules.Types)

local DataTemplate: Types.UserData = {
	Cash = 250,
	Slots = {},
	LastJoin = nil,
	Index = {},
}

return DataTemplate
