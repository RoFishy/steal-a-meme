-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- // Modules
local Modules = ReplicatedStorage.Modules
local Spawns = require(Modules.Spawns)

-- // Packages
local Packages = ReplicatedStorage.Packages
local ZonePlus = require(Packages.ZonePlus)

-- // Remotes
local Remotes = ReplicatedStorage.Remotes
local TogglePrompt = Remotes.TogglePrompt
local EditPrompt = Remotes.EditPrompt

-- // Utils
local Utils = script.Parent
local DataUtil = require(Utils.DataUtil)

-- // Managers
local BaseManager = require(script.Parent.Parent.Services.BaseManager)

-- // Objects
local SpawnsFolder = ReplicatedStorage.Spawns
local BasesFolder = workspace.Bases

-- // Constants
local NUMBER_SUFFIX = { "K", "M", "B", "T", "q", "Q", "s", "S", "O", "N", "d", "U", "D" }

-- // Local Functions
local function FormatNumber(n)
	if not tonumber(n) then
		return n
	end
	if n < 10000 then
		return math.floor(n)
	end
	local d = math.floor(math.log10(n) / 3) * 3
	local s = tostring(n / (10 ^ d)):sub(1, 5)
	return s .. " " .. tostring(NUMBER_SUFFIX[math.floor(d / 3)])
end

-- // Init
local Meme = {}
Meme.__index = Meme

function Meme.new(Name: string, Type: string, SpawnLocation: CFrame)
	local RarityFolder = SpawnsFolder:FindFirstChild(Type)
	assert(RarityFolder, "Rarity folder not found")

	local MemeModel = RarityFolder:FindFirstChild(Name)
	assert(Meme, "Meme not found")

	local MemeInfo = Spawns[Type]["Spawns"][Name]

	local self = setmetatable({}, Meme)
	self.Model = MemeModel:Clone()
	self.Name = Name
	self.Info = MemeInfo
	self.PurchasePlayer = nil
	self.CurrentEarned = 0
	self.Connections = {}
	self.Threads = {}
	self.CurrentStand = nil
	self.Prompt = nil
	self.CurrentMove = nil

	if not self.Model.PrimaryPart then
		self.Model.PrimaryPart = self.Model.HumanoidRootPart
	end

	self.Model.Humanoid.WalkSpeed = 12

	self:SetCollisionGroup("Meme")

	self.Model.Parent = workspace
	self.Model:PivotTo(SpawnLocation)

	self:MoveTo(workspace.ConveyorSystem.End.Position)

	self:SetupDisplayInfo()
	self:SetupConnections()

	return self
end

function Meme:SetCollisionGroup(NewGroup: string)
	for _, Item: BasePart in self.Model:GetDescendants() do
		if Item:IsA("BasePart") then
			Item.CollisionGroup = NewGroup
		end
	end
end

function Meme:GetOpenSlot(Slots: Folder)
	for _, Slot in Slots:GetChildren() do
		if Slot:GetAttribute("Meme") == nil then
			return Slot
		end
	end
end

function Meme:GetNewPrompt()
	local ProximityPrompt = Instance.new("ProximityPrompt")
	ProximityPrompt.Parent = self.Model.HumanoidRootPart
	ProximityPrompt.RequiresLineOfSight = false
	ProximityPrompt.HoldDuration = 1

	return ProximityPrompt
end

function Meme:Steal(StealPlayer: Player)
	self:Cleanup()
	TogglePrompt:FireAllClients(self.Prompt)

	for _, Part: BasePart in self.Model:GetChildren() do
		if not Part:IsA("BasePart") then
			continue
		end
		Part.Anchored = false
		Part.CanCollide = false
		Part.Massless = true
	end

	self.Model:PivotTo(
		StealPlayer.Character.HumanoidRootPart.CFrame
			+ (StealPlayer.Character.HumanoidRootPart.CFrame.LookVector * 3)
			+ (StealPlayer.Character.HumanoidRootPart.CFrame.UpVector * 3)
	)

	local Weld = Instance.new("WeldConstraint")
	Weld.Parent = StealPlayer.Character.HumanoidRootPart
	Weld.Part0 = StealPlayer.Character.HumanoidRootPart
	Weld.Part1 = self.Model.PrimaryPart

	local StealPlayerBase = BaseManager:GetBaseNameFromPlayer(StealPlayer)
	StealPlayerBase = BasesFolder[StealPlayerBase]

	local BaseComponents = StealPlayerBase.Components
	local BaseCollectZone = BaseComponents.CollectZone.CollectPart

	local CollectZone = ZonePlus.new(BaseCollectZone)
	CollectZone.playerEntered:Connect(function(Player: Player)
		local Slots = StealPlayerBase.Slots
		local OpenSlot = self:GetOpenSlot(Slots)

		if not OpenSlot then
			return
		end

		OpenSlot:SetAttribute("Meme", self.Name)

		if Player == StealPlayer then
			self.PurchasePlayer = StealPlayer
			self.CurrentStand = OpenSlot
			Weld:Destroy()
			for _, Part: BasePart in self.Model:GetChildren() do
				if not Part:IsA("BasePart") then
					continue
				end
				Part.CanCollide = true
			end
			self:AddToSlot(OpenSlot)
		end
	end)
end

function Meme:AddToSlot(Slot: Model)
	self.Model:PivotTo((Slot.Stand.CFrame + Vector3.new(0, 5, 0)) * CFrame.fromEulerAngles(0, math.rad(-90), 0))

	task.delay(1, function()
		for _, Part: BasePart in self.Model:GetChildren() do
			if not Part:IsA("BasePart") then
				continue
			end
			Part.Anchored = true
		end
	end)

	for _, Connection in self.Connections do
		Connection:Disconnect()
	end

	local SellPrice = math.ceil(self.Info.Price * 0.5)

	TogglePrompt:FireClient(self.PurchasePlayer, self.Prompt)
	self.Prompt.ObjectText = `Sell ${self.Name} for ${SellPrice}`
	self.Prompt.ActionText = "Sell"
	EditPrompt:FireAllClients(self.Prompt, "Steal", self.Name, self.PurchasePlayer)

	local CollectButton: Part = Slot.Collect
	table.insert(
		self.Connections,
		CollectButton.Touched:Connect(function(Hit: Part)
			local Player = Players:GetPlayerFromCharacter(Hit.Parent)
			if Player and Player == self.PurchasePlayer then
				DataUtil:IncrementCash(Player, self.CurrentEarned)
				self.CurrentEarned = 0
				CollectButton.Attachment.Billboard.Frame.amount.Text = `${FormatNumber(self.CurrentEarned)}`
			end
		end)
	)
	table.insert(
		self.Threads,
		task.spawn(function()
			while task.wait(1) do
				self.CurrentEarned += self.Info.Income

				CollectButton.Attachment.Billboard.Frame.amount.Text = `${FormatNumber(self.CurrentEarned)}`
			end
		end)
	)
	table.insert(
		self.Connections,
		self.Prompt.Triggered:Connect(function(Player: Player)
			if Player == self.PurchasePlayer then
				DataUtil:IncrementCash(Player, SellPrice)
				self:Destroy()
			else
				self:Steal(Player)
			end
			CollectButton.Attachment.Billboard.Frame.amount.Text = `$0`
		end)
	)
end

function Meme:SetupConnections()
	local ProximityPrompt = self:GetNewPrompt()
	ProximityPrompt.ActionText = "Buy"
	ProximityPrompt.ObjectText = self.Name .. " $" .. self.Info.Price

	self.Prompt = ProximityPrompt

	local humConnection
	table.insert(
		self.Connections,
		ProximityPrompt.Triggered:Connect(function(Player: Player)
			if self.PurchasePlayer then
				humConnection:Disconnect()
			end
			local Profile = DataUtil:GetData(Player)
			local Cash = Profile.Cash

			local PlayerBase = BaseManager:GetBaseNameFromPlayer(Player)
			PlayerBase = BasesFolder[PlayerBase]

			if not self:GetOpenSlot(PlayerBase.Slots) then
				return
			end

			if Cash >= self.Info.Price then
				DataUtil:IncrementCash(Player, -self.Info.Price)
				TogglePrompt:FireClient(Player, ProximityPrompt)

				self:SetCollisionGroup("Meme")
				local Slots = PlayerBase.Slots
				local OpenSlot = self:GetOpenSlot(Slots)

				OpenSlot:SetAttribute("Meme", self.Name)

				self:MoveTo(PlayerBase.Components.CollectZone.CollectPart.Position)
				self.PurchasePlayer = Player

				local Humanoid = self.Model.Humanoid :: Humanoid
				humConnection = Humanoid.MoveToFinished:Connect(function()
					task.cancel(self.CurrentMove)
					self.CurrentStand = OpenSlot
					self:AddToSlot(OpenSlot)
				end)
			end
		end)
	)
end

function Meme:SetupDisplayInfo()
	local Price = self.Info.Price
	local Income = self.Info.Income

	local DisplayAttachment = self.Model.HumanoidRootPart.Attachment
	local MainFrame = DisplayAttachment.Billboard.Main

	MainFrame.Money.Text = `${Income}/s`
	MainFrame.Price.Text = `${Price}`
	MainFrame:FindFirstChild("Name").Text = self.Name
end

function Meme:MoveTo(Position: Vector3)
	local Humanoid = self.Model:FindFirstChild("Humanoid")

	if self.CurrentMove then
		task.cancel(self.CurrentMove)
	end

	if Humanoid then
		self.CurrentMove = task.spawn(function()
			repeat
				task.wait()
				Humanoid:MoveTo(Position)
			until (self.Model.HumanoidRootPart.Position - Position).magnitude < 2
			task.cancel(self.CurrentMove)
		end)
	end
end

function Meme:Cleanup()
	for _, Connection in self.Connections do
		Connection:Disconnect()
	end
	for _, Thread in self.Threads do
		task.cancel(Thread)
	end
	self.PurchasePlayer = nil
	self.CurrentStand:SetAttribute("Meme", nil)
	self.CurrentStand = nil
	self.CurrentEarned = 0
end

function Meme:Destroy()
	self:Cleanup()
	self.Model:Destroy()
end

return Meme
