return {
	BypassLockCooldown = {
		ProductId = 3299780200,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)
			return Signals.BypassLockCooldown:Fire(Player)
		end,
	},

	-- // Cash
	["Money Pack 1"] = {
		ProductId = 3301582459,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)
			DataUtil:IncrementCash(Player, 2_000)
		end,
	},
	["Money Pack 2"] = {
		ProductId = 3301582458,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)
			DataUtil:IncrementCash(Player, 20_000)
		end,
	},
	["Money Pack 3"] = {
		ProductId = 3301582457,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)
			DataUtil:IncrementCash(Player, 75_000)
		end,
	},
	["Money Pack 4 (MOST POPULAR)"] = {
		ProductId = 3301582456,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)
			DataUtil:IncrementCash(Player, 200_000)
		end,
	},
	["Money Pack 5 (BEST DEAL)"] = {
		ProductId = 3301583025,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local DataUtil = require(Utils.DataUtil)
			DataUtil:IncrementCash(Player, 1_500_000)
		end,
	},
}
