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

	UnlockBase = {
		ProductId = 3304667372,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")

			local BaseManager = require(ServerScriptService.Services.BaseManager)
			BaseManager:UnlockForPlayer(Player)
			return
		end,
	},

	-- // Server luck
	["x2 Luck"] = {
		ProductId = 3302030360,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)

			ReplicatedStorage.LuckTime.Value = 600
			ReplicatedStorage.CurrentLuck.Value = 2

			task.spawn(function()
				while ReplicatedStorage.LuckTime.Value > 0 do
					task.wait(1)
					ReplicatedStorage.LuckTime.Value -= 1
				end
				Signals.ResetServerLuck:Fire()
				ReplicatedStorage.CurrentLuck.Value = 1
			end)
			ReplicatedStorage.Remotes.ShowNotification:FireAllClients(
				`{Player.Name} has purchased 2x luck for 10 minutes!`,
				Color3.fromRGB(0, 255, 0)
			)
			return Signals.IncreaseServerLuck:Fire()
		end,
	},
	["x4 Luck"] = {
		ProductId = 3302030707,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)

			ReplicatedStorage.LuckTime.Value = 600
			ReplicatedStorage.CurrentLuck.Value = 4
			ReplicatedStorage.Remotes.ShowNotification:FireAllClients(
				`{Player.Name} has purchased 4x luck for 10 minutes!`,
				Color3.fromRGB(0, 255, 0)
			)

			Signals.IncreaseServerLuck:Fire()
		end,
	},
	["x8 Luck"] = {
		ProductId = 3302030706,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)

			ReplicatedStorage.LuckTime.Value = 600
			ReplicatedStorage.CurrentLuck.Value = 8
			ReplicatedStorage.Remotes.ShowNotification:FireAllClients(
				`{Player.Name} has purchased 8x luck for 10 minutes!`,
				Color3.fromRGB(0, 255, 0)
			)

			Signals.IncreaseServerLuck:Fire()
		end,
	},
	["x16 Luck"] = {
		ProductId = 3302031086,
		Callback = function(Player: Player)
			-- // Services
			local ServerScriptService = game:GetService("ServerScriptService")
			local ReplicatedStorage = game:GetService("ReplicatedStorage")

			-- // Utils
			local Utils = ServerScriptService.Utils
			local Signals = require(Utils.Signals)

			ReplicatedStorage.LuckTime.Value = 600
			ReplicatedStorage.CurrentLuck.Value = 16
			ReplicatedStorage.Remotes.ShowNotification:FireAllClients(
				`{Player.Name} has purchased 16x luck for 10 minutes!`,
				Color3.fromRGB(0, 255, 0)
			)

			Signals.IncreaseServerLuck:Fire()
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
