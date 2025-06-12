-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Packages
local Packages = ReplicatedStorage.Packages
local Signal = require(Packages.Signal)

return {
	BypassLockCooldown = Signal.new(),
	AddMemeToPlayer = Signal.new(),
	RemoveMemeFromPlayer = Signal.new(),
	IncrementCash = Signal.new(),

	PlayerCollectedCash = Signal.new(),

	-- // luck
	ResetServerLuck = Signal.new(),
	IncreaseServerLuck = Signal.new(),

	-- // Memes
	RobuxBuyMeme = Signal.new(),
}
