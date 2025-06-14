-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

-- // Player
local LocalPlayer = Players.LocalPlayer

-- // Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- // Objects

-- // Init
local PlayerHandler = {}

function PlayerHandler:Start()

	local StealAnim = nil
	LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
		local isStealing = LocalPlayer:GetAttribute("Stealing")

		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, not isStealing)

		if StealAnim then
			pcall(function()
				StealAnim:Stop()
				StealAnim:Destroy()
				StealAnim = nil
			end)
		end

		if isStealing and LocalPlayer.Character then
			LocalPlayer.Character.Humanoid:UnequipTools()

			local Animator: Animator = LocalPlayer.Character.Humanoid.Animator
			StealAnim = Animator:LoadAnimation(ReplicatedStorage.Objects.StealAnim)

			StealAnim:Play()
		end
	end)
end

return PlayerHandler