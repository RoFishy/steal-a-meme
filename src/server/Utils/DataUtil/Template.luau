-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules
local Types = require(Modules.Types)

local DataTemplate: Types.UserData = {
	Cash = 0,
	Slots = {},
}

return DataTemplate
