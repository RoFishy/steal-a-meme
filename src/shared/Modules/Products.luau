-- // Services
local ServerScriptService = game:GetService("ServerScriptService")

-- // Utils
local Utils = ServerScriptService.Utils
local Signals = require(Utils.Signals)

return {
	BypassLockCooldown = {
		ProductId = 3299780200,
		Callback = function(Player: Player)
			return Signals.BypassLockCooldown:Fire(Player)
		end,
	},
}
