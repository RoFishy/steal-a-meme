-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Remotes
local Remotes = ReplicatedStorage.Remotes
local ShowTutorialFrame = Remotes.ShowTutorialFrame
local HideTutorialFrame = Remotes.HideTutorialFrame
local ShowBeam = Remotes.ShowBeam
local HideBeam = Remotes.HideBeam

-- // Managers
local BaseManager = require(script.Parent.Parent.Services.BaseManager)

-- // Signals
local Utils = script.Parent
local Signals = require(Utils.Signals)

-- // Init
local TutorialUtil = {}

function TutorialUtil.new(Player: Player)
	ShowTutorialFrame:FireClient(Player, `Buy a Meme from the conveyor!`)
	ShowBeam:FireClient(Player, Player.Character.HumanoidRootPart, workspace.ConveyorSystem.Spawn)

	local oneDone = false

	Signals.AddMemeToPlayer:Connect(function(_Player: Player, _)
		if _Player == Player then
			HideBeam:FireClient(Player)
			HideTutorialFrame:FireClient(Player)
			oneDone = true
		end
	end)

	repeat
		task.wait()
	until oneDone

	task.wait(1.5)

	local PlayerBase = BaseManager:GetBaseNameFromPlayer(Player)
	local twoDone = false
	local NoobSlot
	for _, Slot in workspace.Bases[PlayerBase].Slots:GetChildren() do
		if Slot:GetAttribute("Meme") then
			NoobSlot = Slot
		end
	end
	ShowTutorialFrame:FireClient(Player, `Collect your cash from the Meme!`)
	ShowBeam:FireClient(Player, Player.Character.HumanoidRootPart, NoobSlot.Collect)

	Signals.PlayerCollectedCash:Connect(function(_Player: Player)
		if _Player == Player then
			HideBeam:FireClient(Player)
			HideTutorialFrame:FireClient(Player)
			twoDone = true
		end
	end)

	repeat
		task.wait()
	until twoDone
	task.wait(1.5)

	ShowTutorialFrame:FireClient(
		Player,
		"That's all for this tutorial! Go steal from others, collect cash, and have fun!"
	)
end

return TutorialUtil
