-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- // Player
local LocalPlayer = Players.LocalPlayer

-- // Remotes
local Remotes = ReplicatedStorage.Remotes
local TogglePrompt = Remotes.TogglePrompt
local EditPrompt = Remotes.EditPrompt

-- // Init
local PromptHandler = {}

function PromptHandler:Start()
	TogglePrompt.OnClientEvent:Connect(function(Prompt: ProximityPrompt)
		Prompt.Enabled = not Prompt.Enabled
	end)
	EditPrompt.OnClientEvent:Connect(
		function(Prompt: ProximityPrompt, ActionText: string, ObjectText: string, IgnorePlayer: Player)
			if IgnorePlayer == LocalPlayer then
				return
			end

			Prompt.ActionText = ActionText
			Prompt.ObjectText = ObjectText
		end
	)
end

return PromptHandler
