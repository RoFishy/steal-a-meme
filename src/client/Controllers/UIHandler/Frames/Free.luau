-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ClaimFreePet = Remotes.ClaimFreePet

-- // Util
local Button = require(script.Parent.Parent.Utils.Button)

-- // Module
local UIManager = require(script.Parent.Parent)

-- // UI
local MainUI = PlayerGui:WaitForChild("UI")

local Frame = MainUI:WaitForChild("Frames"):WaitForChild("Free")

-- // Init
local Free = {}

function Free.Init()
	Free.Junk = {}
end

function Free:Start()
	table.insert(
		self.Junk,
		Button(Frame.Top.close, function()
			UIManager:CloseAllFrames()
		end)
	)

	table.insert(
		self.Junk,
		Button(Frame.buy, function()
			ClaimFreePet:FireServer()
		end)
	)
end

function Free:Stop()
	for _, v in pairs(self.Junk) do
		if typeof(v) == "RBXScriptConnection" then
			v:Disconnect()
		elseif typeof(v) == "function" then
			v()
		else
			v:Destroy()
		end
	end
end

return Free
