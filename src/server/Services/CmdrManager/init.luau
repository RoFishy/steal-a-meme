-- // Services
local ServerStorage = game:GetService("ServerStorage")

-- // Packages
local Packages = ServerStorage:WaitForChild("Packages")
local Cmdr = require(Packages.cmdr)

local CmdrHandler = {}

function CmdrHandler:Start()
	Cmdr:RegisterDefaultCommands()
	Cmdr:RegisterCommandsIn(script.Commands)
	Cmdr:RegisterHooksIn(script.Hooks)
	Cmdr:RegisterTypesIn(script.Types)
end

return CmdrHandler
