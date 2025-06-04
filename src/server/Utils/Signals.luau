-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Packages
local Packages = ReplicatedStorage.Packages
local Signal = require(Packages.Signal)

return {
	BypassLockCooldown = Signal.new(),
}
