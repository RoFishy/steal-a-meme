-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

-- // Modules
local Modules = ReplicatedStorage.Modules
local Spawns = require(Modules.Spawns)
local Rebirths = require(Modules.Rebirths)

-- // Packages
local Packages = ReplicatedStorage.Packages
local ZonePlus = require(Packages.ZonePlus)

-- // Remotes
local Remotes = ReplicatedStorage.Remotes
local TogglePrompt = Remotes.TogglePrompt
local EditPrompt = Remotes.EditPrompt
local ShowNotification = Remotes.ShowNotification
local SmackPlayer = Remotes.SmackPlayer

-- // Utils
local Utils = script.Parent
local Signal = require(Utils.Signals)

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
	if n < 1000 then
		return math.floor(n)
	end
	local d = math.floor(math.log10(n) / 3) * 3
	local s = tostring(n / (10 ^ d)):sub(1, 5)
	return s .. tostring(NUMBER_SUFFIX[math.floor(d / 3)])
end

local function GetPlayerBase(Player: Player): Model
	for _, Base in BasesFolder:GetChildren() do
		if Base:GetAttribute("Owner") == Player.Name then
			return Base
		end
	end
end

-- // Init
local Meme = {}
Meme.__index = Meme

function Meme.new(Name: string, Type: string, SpawnLocation: CFrame, CustomInfo: {}?)
	local MemeInfo
	if CustomInfo then
		Type = CustomInfo.Rarity
		MemeInfo = CustomInfo.Info
	else
		MemeInfo = Spawns[Type]["Spawns"][Name]
	end
	local RarityFolder = SpawnsFolder:FindFirstChild(Type)
	assert(RarityFolder, "Rarity folder not found")

	local MemeModel = RarityFolder:FindFirstChild(Name)
	assert(MemeModel, `Meme {Name} not found in {Type} folder`)

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
	self.Rarity = Type
	self.BeingStolen = false
	self.Redirects = true
	self.CashConnection = false

	if not self.Model.PrimaryPart then
		self.Model.PrimaryPart = self.Model.HumanoidRootPart
	end

	self.Model.Humanoid.WalkSpeed = 6

	self:SetCollisionGroup("Meme")

	self.Model.Parent = workspace
	self.Model:PivotTo(SpawnLocation)

	self:MoveTo(workspace.ConveyorSystem.End.Position)

	self:SetupDisplayInfo()
	self:SetupConnections()

	self.DestroyConn = self.Model.Destroying:Once(function()
		self:Destroy()
	end)

	return self
end

function Meme:SetCollisionGroup(NewGroup: string)
	for _, Item: BasePart in self.Model:GetDescendants() do
		if Item:IsA("BasePart") then
			Item.CollisionGroup = NewGroup
		end
	end
end

function Meme:GetSlotByIndex(Index: number, Slots: Folder)
	for _, Slot in Slots:GetChildren() do
		if string.find(Slot.Name, tostring(Index)) then
			return Slot
		end
	end
end

function Meme:GetOpenSlot(Slots: Folder)
	for i = 1, #Slots:GetChildren() do
		local CurrentSlot = self:GetSlotByIndex(i, Slots)
		if CurrentSlot:GetAttribute("Meme") then
			continue
		end
		return CurrentSlot
	end
	--[[
		for _, Slot in Slots:GetChildren() do
		if Slot:GetAttribute("Meme") then
			continue
		end
		return Slot
	end
	]]
	--
	return nil
end

function Meme:GetNewPrompt()
	local ProximityPrompt = Instance.new("ProximityPrompt")
	ProximityPrompt.Parent = self.Model.HumanoidRootPart
	ProximityPrompt.RequiresLineOfSight = false
	ProximityPrompt.HoldDuration = 1
	ProximityPrompt.MaxActivationDistance = 6

	return ProximityPrompt
end

function Meme:Steal(StealPlayer: Player)
	local _StealPlayerBase = GetPlayerBase(StealPlayer)
	local _OpenSlot = self:GetOpenSlot(_StealPlayerBase.Slots)
	if not _OpenSlot then
		ShowNotification:FireClient(StealPlayer, "You do not have any open slots!")
		return
	end

	if not self.PurchasePlayer then
		return
	end

	local OriginalPlayer = self.PurchasePlayer
	local OriginalPlayerBase = GetPlayerBase(OriginalPlayer)

	if StealPlayer:GetAttribute("Stealing") then
		ShowNotification:FireClient(StealPlayer, "You're already stealing a meme!")
		return
	end

	local StealSound = SoundService.Steal:Clone()
	StealSound.Parent = self.Model.HumanoidRootPart
	StealSound:Play()
	StealSound.Ended:Once(function()
		StealSound:Destroy()
	end)

	ShowNotification:FireClient(
		self.PurchasePlayer,
		`{StealPlayer.Name} is stealing your {self.Name}!`,
		Color3.fromRGB(255, 0, 0)
	)
	self:Cleanup()
	StealPlayer:SetAttribute("Stealing", true)
	local OGWalkSpeed = StealPlayer.Character.Humanoid.WalkSpeed
	StealPlayer.Character.Humanoid.WalkSpeed /= 1.5
	self.BeingStolen = true
	Signal.RemoveMemeFromPlayer:Fire(OriginalPlayer, self)
	pcall(function()
		local collectAt = self.CurrentStand.Collect.Attachment
		local offlineAt = self.CurrentStand.Collect.OfflineAttachment
		offlineAt.Billboard.Frame.Visible = false
		collectAt.Billboard.Frame.amount.Text = "$0"
	end)
	TogglePrompt:FireAllClients(self.Prompt, false)

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

	local StealPlayerBase = GetPlayerBase(StealPlayer)

	local BaseComponents = StealPlayerBase.Components
	local BaseCollectZone = BaseComponents.CollectZone.CollectPart

	local CollectZone = ZonePlus.new(BaseCollectZone)

	table.insert(
		self.Connections,
		SmackPlayer.Event:Connect(function(_: Player, OtherPlayer: Player)
			if OtherPlayer == StealPlayer then
				self.PurchasePlayer = OriginalPlayer
				StealPlayer:SetAttribute("Stealing", nil)

				local Sound = SoundService.Bruh:Clone()
				Sound.Parent = self.Model.HumanoidRootPart
				Sound:Play()
				Sound.Ended:Once(function()
					Sound:Destroy()
				end)

				local PurchasePlayerBase = GetPlayerBase(OriginalPlayer)
				local Slots = PurchasePlayerBase.Slots
				local OpenSlot = self:GetOpenSlot(Slots)
				OpenSlot:SetAttribute("Meme", self.Name)
				for _, Part: BasePart in self.Model:GetChildren() do
					if not Part:IsA("BasePart") then
						continue
					end
					Part.CanCollide = true
					Part.Anchored = true
				end
				Weld:Destroy()
				self.CurrentStand = OpenSlot
				TogglePrompt:FireAllClients(self.Prompt, true)
				self.BeingStolen = false
				StealPlayer.Character.Humanoid.WalkSpeed = OGWalkSpeed

				self:AddToSlot(OpenSlot)
			end
		end)
	)

	--local db = false
	table.insert(self.Connections, {
		Disconnect = function()
			CollectZone:destroy()
		end,
	})
	CollectZone.playerEntered:Connect(function(Player: Player)
		if Player == StealPlayer then
			--db = true
			--task.delay(4, function()
			--db = false
			--end)
			pcall(function()
				EditPrompt:FireAllClients("Steal", self.Name)
			end)

			local DataUtil = require(Utils.DataUtil)
			StealPlayer:SetAttribute("Stealing", nil)

			local Slots = StealPlayerBase.Slots
			local OpenSlot = self:GetOpenSlot(Slots)
			if not OpenSlot then
				return
			end
			OpenSlot:SetAttribute("Meme", self.Name)

			self.PurchasePlayer = StealPlayer
			self.CurrentStand = OpenSlot
			for _, Part: BasePart in self.Model:GetChildren() do
				if not Part:IsA("BasePart") then
					continue
				end
				Part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				Part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
				Part.CanCollide = true
				Part.Anchored = true
			end
			Weld:Destroy()
			self.BeingStolen = false
			self:AddToSlot(OpenSlot)
			DataUtil:IncrementSteals(StealPlayer, 1)
			StealPlayer.Character.Humanoid.WalkSpeed = OGWalkSpeed

			TogglePrompt:FireAllClients(self.Prompt, true)
		end
	end)

	table.insert(
		self.Connections,
		Players.PlayerRemoving:Connect(function(player)
			if player == StealPlayer then
				pcall(function()
					EditPrompt:FireAllClients("Steal", self.Name)
				end)

				local Slots = OriginalPlayerBase.Slots
				local OpenSlot = self:GetOpenSlot(Slots)
				if not OpenSlot then
					return
				end
				OpenSlot:SetAttribute("Meme", self.Name)

				self.PurchasePlayer = OriginalPlayer
				self.CurrentStand = OpenSlot
				for _, Part: BasePart in self.Model:GetChildren() do
					if not Part:IsA("BasePart") then
						continue
					end
					Part.Anchored = true
					Part.CanCollide = true
				end
				Weld:Destroy()
				self.BeingStolen = false
				self:AddToSlot(OpenSlot)
				TogglePrompt:FireAllClients(self.Prompt, true)
			end
		end)
	)

	table.insert(
		self.Connections,
		StealPlayer.Character.Humanoid.Died:Connect(function()
			pcall(function()
				EditPrompt:FireAllClients("Steal", self.Name)
			end)

			StealPlayer:SetAttribute("Stealing", nil)

			local Slots = OriginalPlayerBase.Slots
			local OpenSlot = self:GetOpenSlot(Slots)
			if not OpenSlot then
				return
			end
			OpenSlot:SetAttribute("Meme", self.Name)

			self.PurchasePlayer = OriginalPlayer
			self.CurrentStand = OpenSlot
			for _, Part: BasePart in self.Model:GetChildren() do
				if not Part:IsA("BasePart") then
					continue
				end
				Part.Anchored = true
				Part.CanCollide = true
			end
			Weld:Destroy()
			self.BeingStolen = false
			self:AddToSlot(OpenSlot)
			TogglePrompt:FireAllClients(self.Prompt, true)
		end)
	)
end

function Meme:AddToSlot(Slot: Model, LoadData: boolean?, OfflineIncome: number?, value: boolean?)
	if not self.PurchasePlayer then
		self.PurchasePlayer = Players:FindFirstChild(Slot.Parent.Parent:GetAttribute("Owner"))
	end

	self:CleanupConnects()
	if self.BeingStolen then
		return
	end
	self.CurrentStand = Slot

	Slot:SetAttribute("Meme", self.Name)
	if LoadData == nil then
		Signal.AddMemeToPlayer:Fire(self.PurchasePlayer, self)
	end
	for _, Part in self.Model:GetChildren() do
		if not Part:IsA("BasePart") then
			continue
		end
		Part.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		Part.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
		Part.Anchored = false
	end

	self.Model:PivotTo((Slot.Stand.CFrame + Vector3.new(0, 5, 0)) * CFrame.fromEulerAngles(0, math.rad(-90), 0))

	task.delay(0.5, function()
		for _, Part: BasePart in self.Model:GetChildren() do
			if not Part:IsA("BasePart") then
				continue
			end
			Part.Anchored = true
		end
	end)

	pcall(function()
		for _, Connection in self.Connections do
			Connection:Disconnect()
		end
	end)

	local SellPrice = math.ceil(self.Info.Price * 0.5)
	if LoadData == nil and value == nil then
		task.wait(1)
		TogglePrompt:FireClient(self.PurchasePlayer, self.Prompt, true)
	end
	self.Prompt.ObjectText = self.Name
	self.Prompt.ActionText = "Steal"
	self.Prompt.HoldDuration = 3
	if LoadData then
		task.delay(5, function()
			EditPrompt:FireClient(self.PurchasePlayer, self.Prompt, "Sell", `Sell ${self.Name} for ${SellPrice}`, nil)
		end)
	else
		task.delay(1, function()
			EditPrompt:FireClient(self.PurchasePlayer, self.Prompt, "Sell", `Sell ${self.Name} for ${SellPrice}`, nil)
		end)
	end

	local CollectButton: Part = Slot.Collect

	if OfflineIncome then
		self.CurrentEarned += OfflineIncome
		local OfflineAttachment = CollectButton.OfflineAttachment
		OfflineAttachment.Billboard.Frame.offline.Text = `Offline Cash: ${FormatNumber(OfflineIncome)}`
		OfflineAttachment.Billboard.Frame.Visible = true
	end

	local CollectMultiplier

	local leaderstats = self.PurchasePlayer:WaitForChild("leaderstats")
	local PlayerRebirths = leaderstats.Rebirths

	if PlayerRebirths.Value > 0 then
		CollectMultiplier = Rebirths[PlayerRebirths.Value].Rewards.Multiplier
	else
		CollectMultiplier = 1
	end

	if self.PurchasePlayer:GetAttribute("2xCash") then
		CollectMultiplier *= 2
	end
	local TouchDebounce = false
	table.insert(
		self.Connections,
		CollectButton.Touched:Connect(function(Hit: Part)
			local Player = Players:GetPlayerFromCharacter(Hit.Parent)
			if Player and Player == self.PurchasePlayer and not TouchDebounce then
				TouchDebounce = true
				task.delay(0.5, function()
					TouchDebounce = false
				end)
				task.spawn(function()
					local Sound = SoundService.CashCollect:Clone()
					Sound.Parent = Player.PlayerGui
					Sound:Play()
					Sound.Ended:Once(function()
						Sound:Destroy()
					end)
				end)
				Signal.PlayerCollectedCash:Fire(self.PurchasePlayer)
				Signal.IncrementCash:Fire(Player, self.CurrentEarned)
				self.CurrentEarned = 0
				CollectButton.Attachment.Billboard.Frame.amount.Text = `${FormatNumber(self.CurrentEarned)}`
				CollectButton.OfflineAttachment.Billboard.Frame.offline.Text = `Offline Cash: $0`
				CollectButton.OfflineAttachment.Billboard.Frame.Visible = false
			end
		end)
	)
	if not self.CashConnection then
		table.insert(
			self.Threads,
			task.spawn(function()
				self.CashConnection = true
				while task.wait(1) do
					self.CurrentEarned += (self.Info.Income * CollectMultiplier)

					CollectButton.Attachment.Billboard.Frame.amount.Text = `${FormatNumber(self.CurrentEarned)}`
				end
			end)
		)
	end

	self.Prompt.Triggered:Once(function(Player: Player)
		if Player == self.PurchasePlayer then
			Signal.IncrementCash:Fire(Player, SellPrice)
			Signal.RemoveMemeFromPlayer:Fire(self.PurchasePlayer, self)
			local sound = SoundService.CashCollect:Clone()
			sound.Parent = self.Model.HumanoidRootPart
			sound:Play()
			sound.Ended:Once(function()
				sound:Destroy()
			end)
			self:Destroy()
		else
			if Player:GetAttribute("Stealing") then
				return
			else
				self.CashConnection = false
				self:Steal(Player)
			end
		end
		CollectButton.Attachment.Billboard.Frame.amount.Text = `$0`
		CollectButton.OfflineAttachment.Billboard.Frame.offline.Text = `Offline Cash: $0`
	end)
end

function Meme:SetupConnections()
	local ProximityPrompt = self:GetNewPrompt()
	ProximityPrompt.ActionText = "Buy"
	ProximityPrompt.ObjectText = self.Name .. " $" .. self.Info.Price
	ProximityPrompt.HoldDuration = 0.5

	self.Prompt = ProximityPrompt
	local humConnect
	table.insert(
		self.Connections,
		ProximityPrompt.Triggered:Connect(function(Player: Player)
			local BeingRedirected = false
			if self.PurchasePlayer then
				if self.Redirects then
					BeingRedirected = true
					TogglePrompt:FireAllClients(ProximityPrompt, true)
					self.CurrentStand:SetAttribute("Meme", nil)
					humConnect:Disconnect()
				else
					ShowNotification:FireClient(Player, "This meme is not able to be redirected!")
					return
				end
				--self.CurrentStand:SetAttribute("Meme", nil)
			end
			local Cash = Player.leaderstats.Cash.Value

			local PlayerBase = GetPlayerBase(Player)

			if not self:GetOpenSlot(PlayerBase.Slots) then
				local err = SoundService.Error:Clone()
				err.Parent = Player.PlayerGui
				err:Play()
				err.Ended:Once(function()
					err:Destroy()
				end)
				return ShowNotification:FireClient(Player, "You do not have any open slots!")
			end

			if Cash >= self.Info.Price then
				local Slots = PlayerBase.Slots
				local OpenSlot = self:GetOpenSlot(Slots)
				OpenSlot:SetAttribute("Meme", self.Name)
				self.CurrentStand = OpenSlot
				Signal.IncrementCash:Fire(Player, -self.Info.Price)

				TogglePrompt:FireClient(Player, ProximityPrompt, false)

				if BeingRedirected then
					local Sound = SoundService.Nope:Clone()
					Sound.Parent = self.Model.HumanoidRootPart
					Sound:Play()
					Sound.Ended:Once(function()
						Sound:Destroy()
					end)
				else
					local sound = SoundService.Success:Clone()
					sound.Parent = Player.PlayerGui
					sound:Play()
					sound.Ended:Once(function()
						sound:Destroy()
					end)
				end

				self.Model.Humanoid.WalkSpeed = 10
				self:MoveTo(PlayerBase.Components.CollectZone.CollectPart.PrimaryPart.Position)
				self.PurchasePlayer = Player

				local CollectZone = ZonePlus.new(PlayerBase.Components.CollectZone.CollectPart)

				CollectZone.itemEntered:Connect(function(item)
					if item.Parent == self.Model or item == self.Model then
						if Player.Parent ~= Players then
							self:Destroy()
							return
						end
						task.cancel(self.CurrentMove)
						self.CurrentStand = OpenSlot
						self:AddToSlot(OpenSlot)
						humConnect:Disconnect()
					end
				end)
				CollectZone:trackItem(self.Model)
				for _, part in self.Model:GetChildren() do
					if not part:IsA("BasePart") then
						continue
					end
					CollectZone:trackItem(part)
				end

				humConnect = {
					Disconnect = function()
						CollectZone:destroy()
					end,
				}
				--[[
								humConnect = PlayerBase.Components.CollectZone.CollectPart.Touched:Connect(function(Hit: Part)
					if Hit.Parent == self.Model then
						task.cancel(self.CurrentMove)
						self.CurrentStand = OpenSlot
						self:AddToSlot(OpenSlot)
						humConnect:Disconnect()
					end
				end)
				]]
				--
			else
				local err = SoundService.Error:Clone()
				err.Parent = self.Model.PrimaryPart
				err:Play()
				err.Ended:Once(function()
					err:Destroy()
				end)
				ShowNotification:FireClient(Player, "You do not have enough cash to purchase this meme!")
				return
			end
		end)
	)
end

function Meme:SetupDisplayInfo()
	local Price = self.Info.Price
	local Income = self.Info.Income

	local DisplayAttachment = self.Model.HumanoidRootPart.Attachment
	local MainFrame = DisplayAttachment.Billboard.Main

	MainFrame.Money.Text = `${FormatNumber(Income)}/s`
	MainFrame.Price.Text = `${FormatNumber(Price)}`
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
			until (self.Model.HumanoidRootPart.Position - Position).magnitude < 5
			if self.CurrentMove then
				coroutine.yield(self.CurrentMove)
				coroutine.close(self.CurrentMove)
			end
		end)
	end
end

function Meme:CleanupConnects()
	pcall(function()
		for _, Connection in self.Connections do
			Connection:Disconnect()
		end
		table.clear(self.Connections)

		for _, Thread in self.Threads do
			task.cancel(Thread)
		end
		table.clear(self.Threads)
	end)
end

function Meme:Cleanup()
	pcall(function()
		task.cancel(self.CurrentMove)
	end)
	if self.PurchasePlayer then
		self.PurchasePlayer = nil
		self.CurrentStand:SetAttribute("Meme", nil)
		local CollectButton = self.CurrentStand.Collect
		CollectButton.Attachment.Billboard.Frame.amount.Text = `$0`
		CollectButton.OfflineAttachment.Billboard.Frame.Visible = false

		self.CurrentStand = nil
		self.CurrentEarned = 0
	end
	self:CleanupConnects()
end

function Meme:Destroy()
	self.DestroyConn:Disconnect()
	self:Cleanup()
	self.Model:Destroy()
end

return Meme
