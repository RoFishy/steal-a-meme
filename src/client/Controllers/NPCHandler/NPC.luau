-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- // Camera
local Camera = workspace.CurrentCamera

-- // Objects
local Objects = ReplicatedStorage:WaitForChild("Objects")
local NPCHighlight = Objects.NPCHighlight
local NPCOverhead = Objects.NPCOverhead

-- // Types
local Types = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Types"))

-- // Constants
local ZOOMED_IN_FOV = 50

-- // Utils
local Utils = script.Parent.Parent.Utils
local Signals = require(Utils.Signals)

-- // Local Functions
local function Typewrite(Object, Text)
	for i = 1, #Text, 1 do
		Object.Text = string.sub(Text, 1, i)
		task.wait(0.025)
	end
end

-- // NPC
local NPC = {}
NPC.__index = NPC

function NPC.new(
	Character: Model,
	DialogueOptions: Types.NPCDialogueOptions,
	OriginalQuestion: string,
	NPCName: string?
)
	local self = setmetatable({}, NPC)

	self.Character = Character
	self.DialogueOptions = DialogueOptions
	self.OriginalQuestion = OriginalQuestion
	self.NPCName = NPCName or "NPC"

	self:Init()

	return self
end

function NPC:Init()
	local ProximityPrompt = Instance.new("ProximityPrompt")
	ProximityPrompt.Parent = self.Character:WaitForChild("Torso")
	ProximityPrompt.ActionText = "Talk to NPC"
	ProximityPrompt.RequiresLineOfSight = false
	ProximityPrompt.ObjectText = self.NPCName

	local NPCHighlightClone = nil
	self.NPCOverheadClone = nil
	ProximityPrompt.PromptShown:Connect(function()
		NPCHighlightClone = NPCHighlight:Clone()
		NPCHighlightClone.Parent = self.Character
	end)
	ProximityPrompt.PromptHidden:Connect(function()
		if NPCHighlightClone then
			NPCHighlightClone:Destroy()
		end
	end)
	ProximityPrompt.Triggered:Connect(function()
		ProximityPrompt.Enabled = false
		TweenService:Create(Camera, TweenInfo.new(0.75), { FieldOfView = ZOOMED_IN_FOV }):Play()
		self.NPCOverheadClone = NPCOverhead:Clone()
		self.NPCOverheadClone.Parent = self.Character.Head
		Typewrite(self.NPCOverheadClone.Frame.TextLabel, self.OriginalQuestion)
		Signals.ToggleNPCDialogue:Fire(self.DialogueOptions)
	end)

	Signals.NPCInteractionEnded:Connect(function()
		if self.NPCOverheadClone and self.NPCOverheadClone:FindFirstChild("Frame") then
			Typewrite(self.NPCOverheadClone.Frame.TextLabel, "Goodbye!")
			task.delay(1, function()
				self.NPCOverheadClone:Destroy()
				ProximityPrompt.Enabled = true
			end)
		end
	end)
end

function NPC:Say(Text: string)
	if self.NPCOverheadClone then
		Typewrite(self.NPCOverheadClone.Frame.TextLabel, Text)
	end
end

return NPC
