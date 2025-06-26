-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local StealBackMeme = Remotes.StealBackMeme

-- // Util
local Button = require(script.Parent.Parent.Utils.Button)

-- // Module
local UIManager = require(script.Parent.Parent)

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Products = require(Modules.Products)

-- // UI
local MainUI = PlayerGui:WaitForChild("UI")

local Frame = MainUI:WaitForChild("Frames"):WaitForChild("StealBack")

-- // Init
local StealBack = {}

function StealBack.Init()
	StealBack.Junk = {}
	StealBackMeme.OnClientEvent:Connect(function()
		UIManager:OpenFrame("StealBack")
	end)
end

function StealBack:Start()
	table.insert(
		self.Junk,
		Button(Frame.close, function()
			Remotes.StealBackMeme:FireServer()
			UIManager:CloseAllFrames()
		end)
	)
	table.insert(
		self.Junk,
		Button(Frame.buy, function()
			MarketplaceService:PromptProductPurchase(LocalPlayer, Products["Steal Back Meme"].ProductId)
		end)
	)

	task.spawn(function()
		for i = 15, 0, -1 do
			Frame.timer.Text = `Expires in {i}`
			task.wait(1)
		end
		Remotes.StealBackMeme:FireServer()
		UIManager:CloseAllFrames()
	end)
end

function StealBack:Stop()
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

return StealBack
