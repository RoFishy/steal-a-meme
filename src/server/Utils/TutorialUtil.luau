-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Remotes
local Remotes = ReplicatedStorage.Remotes
local ShowTutorialFrame = Remotes.ShowTutorialFrame
local HideTutorialFrame = Remotes.HideTutorialFrame
local ShowBeam = Remotes.ShowBeam
local HideBeam = Remotes.HideBeam

-- // Managers
local SpawnManager = require(script.Parent.Parent.Services.SpawnManager)
local BaseManager = require(script.Parent.Parent.Services.BaseManager)

-- // Signals
local Utils = script.Parent
local Signals = require(Utils.Signals)

-- // Init
local TutorialUtil = {}

function TutorialUtil.new(Player: Player)
	local Noob
	repeat
		task.wait()
		Noob = TutorialUtil:GetNoob()
	until Noob ~= nil
	local Model = Noob.Model
	ShowTutorialFrame:FireClient(Player, `Buy a {Noob.Name} from the conveyor!`)
	ShowBeam:FireClient(Player, Player.Character.HumanoidRootPart, Model.HumanoidRootPart)

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

	task.wait(3)

	local PlayerBase = BaseManager:GetBaseNameFromPlayer(Player)
	local twoDone = false
	local NoobSlot
	for _, Slot in workspace.Bases[PlayerBase].Slots:GetChildren() do
		if Slot:GetAttribute("Meme") == "Noob" then
			NoobSlot = Slot
		end
	end
	ShowTutorialFrame:FireClient(Player, `Collect your cash from the {Noob.Name}!`)
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
	task.wait(3)

	ShowTutorialFrame:FireClient(
		Player,
		"That's all for this tutorial! Go steal from others, collect cash, and have fun!"
	)
end

function TutorialUtil:GetNoob()
	for _, Spawns in SpawnManager:GetCurrentMemes() do
		if Spawns.Name == "Noob" or Spawns.Name == "Among Us" or Spawns.Name == "Troll Face" then
			return Spawns
		end
	end
	return nil
end

return TutorialUtil
