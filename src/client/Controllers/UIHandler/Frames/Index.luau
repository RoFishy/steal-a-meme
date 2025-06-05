-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // Packages
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Replica = require(Packages.Replica)

-- // Util
local Button = require(script.Parent.Parent.Utils.Button)

-- // Module
local UIManager = require(script.Parent.Parent)

-- // UI
local MainUI = PlayerGui:WaitForChild("UI")
local IndexFrame = MainUI:WaitForChild("Frames"):WaitForChild("Index")

local MemeHolder = IndexFrame.ScrollingFrame

local TopHolder = IndexFrame.Top
local CloseButton = TopHolder.close
local AmountFound = TopHolder.amountfound

-- // Vars
local PlayerMemeIndex = {}

-- // Start
local Index = {}

function Index.Init()
	Index.Junk = {}

	-- // Data
	Replica.OnNew("PlayerData", function(_replica)
		_replica:OnSet({ "Index" }, function(new_value)
			PlayerMemeIndex = new_value
			Index:SetMemes()
		end)
	end)
	Replica.RequestData()
end

function Index:Start()
	table.insert(
		self.Junk,
		Button(CloseButton, function()
			UIManager:CloseAllFrames()
		end)
	)
end

function Index:SetMemes()
	for _, MemeFrame in MemeHolder:GetChildren() do
		if not MemeFrame:IsA("Frame") then
			continue
		end
		if table.find(PlayerMemeIndex, MemeFrame.Name) then
			MemeFrame.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
			MemeFrame.name.Text = MemeFrame.Name
		else
			MemeFrame.Icon.ImageColor3 = Color3.fromRGB(0, 0, 0)
			MemeFrame.name.Text = "???"
		end
	end
	AmountFound.Text = `{#PlayerMemeIndex}/25`
end

function Index:Stop()
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

return Index
