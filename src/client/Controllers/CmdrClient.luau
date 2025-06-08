-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // CMDR
local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))

local CmdrClient = {}

function CmdrClient:Start()
	task.spawn(function()
		Cmdr:SetActivationKeys({ Enum.KeyCode.F2 })
	end)
end

return CmdrClient
