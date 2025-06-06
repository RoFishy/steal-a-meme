-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Types
local Types = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Types"))

-- // Packages
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Signal = require(Packages.Signal)

return {
	ToggleNPCDialogue = Signal.new() :: Signal.Signal<Types.NPCDialogueOptions>,
	NPCInteractionEnded = Signal.new(),
	ClosedFrame = Signal.new(),
}
