-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local leaderstats = LocalPlayer:WaitForChild("leaderstats")
local PlayerRebirths = leaderstats.Rebirths
local Cash = leaderstats.Cash

-- // Modules
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Rebirths = require(Modules.Rebirths)
local Tools = require(Modules.Tools)

-- // Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RebirthRemote = Remotes.Rebirth

-- // Util
local Button = require(script.Parent.Parent.Utils.Button)

-- // Module
local UIManager = require(script.Parent.Parent)

-- // UI
local MainUI = PlayerGui:WaitForChild("UI")
local RebirthFrame = MainUI:WaitForChild("Frames"):WaitForChild("Rebirth")

local CashRequirement = RebirthFrame.CashRequirement

local RewardsHolder = RebirthFrame.Rewards

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
local Rebirth = {}

function Rebirth.Init()
	Rebirth.Junk = {}
end

function Rebirth:Start()
	table.insert(
		self.Junk,
		Button(RebirthFrame.Top.close, function()
			UIManager:CloseAllFrames()
		end)
	)

	if PlayerRebirths.Value == #Rebirths then
		CashRequirement.Text = "MAX REBIRTHS"
	else
		table.insert(
			self.Junk,
			Button(RebirthFrame.rebirth, function()
				if Rebirths[PlayerRebirths.Value + 1].Cost > Cash.Value then
					return UIManager:ShowNotification(
						"You do not have enough cash to rebirth!",
						Color3.fromRGB(255, 0, 255)
					)
				end
				SoundService:PlayLocalSound(SoundService.LeaveGiftOpen)
				RebirthRemote:FireServer()
			end)
		)

		self:UpdateRequirements()
		self:UpdateRewards()

		table.insert(
			self.Junk,
			Cash:GetPropertyChangedSignal("Value"):Connect(function()
				self:UpdateRequirements()
			end)
		)
		table.insert(
			self.Junk,
			PlayerRebirths:GetPropertyChangedSignal("Value"):Connect(function()
				if PlayerRebirths == #Rebirths then
					CashRequirement.Text = "MAX REBIRTHS"
				else
					self:UpdateRewards()
					self:UpdateRequirements()
				end
			end)
		)
	end
end

function Rebirth:UpdateRequirements()
	local Cost = FormatNumber(Rebirths[PlayerRebirths.Value + 1].Cost)
	local currentCash = FormatNumber(Cash.Value)
	CashRequirement.Text = `${currentCash}/${Cost}`
end

function Rebirth:UpdateRewards()
	local NewRewards = Rebirths[PlayerRebirths.Value + 1].Rewards
	local NewTools = NewRewards.NewTools
	local Multiplier = NewRewards.Multiplier
	local LockBoost = NewRewards.LockBoost

	RewardsHolder.Multiplier.rarity.Text = tostring(Multiplier) .. "x"
	RewardsHolder.Lock.rarity.Text = "+" .. tostring(LockBoost) .. " Sec"

	self:RemoveOldTools()
	local CurrentToolFrame = RewardsHolder.Tool
	local currentIndex = 1
	for _, ToolName in NewTools do
		CurrentToolFrame:FindFirstChild("name").Text = ToolName
		CurrentToolFrame.Icon.Image = Tools[ToolName].Image
		CurrentToolFrame = CurrentToolFrame:Clone()
		CurrentToolFrame.Parent = RewardsHolder
		CurrentToolFrame.Name = "Tool" .. currentIndex
		currentIndex += 1
	end
	local nameOccurrences = {}
	for _, ToolFrame in RewardsHolder:GetChildren() do
		if not ToolFrame:IsA("Frame") then
			continue
		end
		if table.find(nameOccurrences, ToolFrame.name.Text) then
			ToolFrame:Destroy()
			continue
		end
		table.insert(nameOccurrences, ToolFrame.name.Text)
	end
end

function Rebirth:RemoveOldTools()
	for _, ToolFrame in RewardsHolder:GetChildren() do
		if string.find(ToolFrame.Name, "Tool") and ToolFrame.Name ~= "Tool" then
			ToolFrame:Destroy()
		end
	end
end

function Rebirth:Stop()
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

return Rebirth
