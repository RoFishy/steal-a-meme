-- // Services
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- // Modules
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Products = require(Modules.Products)

-- // Util
local Button = require(script.Parent.Parent.Utils.Button)

-- // Module
local UIManager = require(script.Parent.Parent)

-- // UI
local MainUI = PlayerGui:WaitForChild("UI")

local Frame = MainUI:WaitForChild("Frames"):WaitForChild("OfflineCash")

-- // Vars
local CurrentAmount = 0

-- // Constants
local NUMBER_SUFFIX = { "K", "M", "B", "T", "q", "Q", "s", "S", "O", "N", "d", "U", "D" }

-- // Local Functions
local function FormatNumber(n)
	if not tonumber(n) then
		return n
	end
	if n < 1000 then
		return math.floor(n)
	end
	local d = math.floor(math.log10(n) / 3) * 3
	local s = tostring(n / (10 ^ d)):sub(1, 5)
	return s .. tostring(NUMBER_SUFFIX[math.floor(d / 3)])
end

-- // Init
local OfflineCash = {}

function OfflineCash.Init()
	OfflineCash.Junk = {}

	Remotes.DoubleCashFrame.OnClientEvent:Connect(function(_CurrentAmount: number)
		CurrentAmount = _CurrentAmount
		UIManager:OpenFrame("OfflineCash")
	end)
end

function OfflineCash:Start()
	table.insert(
		self.Junk,
		Button(Frame.Top.close, function()
			UIManager:CloseAllFrames()
		end)
	)
	table.insert(
		self.Junk,
		Button(Frame.Buy, function()
			MarketplaceService:PromptProductPurchase(LocalPlayer, Products["Double Offline Cash"].ProductId)
		end)
	)

	task.spawn(function()
		for i = 120, 0, -1 do
			Frame.Timer.Text = `{i} seconds`
			task.wait(1)
		end
		UIManager:CloseAllFrames()
	end)
	Frame.Generated.amount.Text = `{FormatNumber(CurrentAmount)} CASH`
	Frame.Doubled.amount.Text = `{FormatNumber(CurrentAmount * 2)} CASH`
end

function OfflineCash:Stop()
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

return OfflineCash
