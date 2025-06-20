-- // Services
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")

-- // Modules
local Modules = ReplicatedStorage.Modules
local Spawns = require(Modules.Spawns)
local Rebirths = require(Modules.Rebirths)
local Products = require(Modules.Products)

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

local SpecialFolder = ReplicatedStorage.Objects.Special

-- // Constants
local NUMBER_SUFFIX = { "K", "M", "B", "T", "q", "Q", "s", "S", "O", "N", "d", "U", "D" }
--local STEAL_ANIM_ID = "rbxassetid://76125639884956"

local SpecialInfo = {
	Golden = {
		IncomeMultiplier = 1.25,
		Color = Color3.fromRGB(255, 187, 0),
	},
	Diamond = {
		IncomeMultiplier = 1.5,
		Color = Color3.fromRGB(0, 174, 255),
	},
	Flaming = {
		IncomeMultiplier = 1.5,
		Color = Color3.fromRGB(255, 0, 0),
	},
}

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

--[[
Simple touch connection for models
usage:

	local zone = TouchZone(model)
	local connection = zone.playerTouched(function(player, character)

	end)
	connection:Disconnect()

	local connection = zone.memeTouched(function(meme)

	end)
	connection:Disconnect()

	zone:Destroy()
]]

local function TouchZone(model: Model)
	local playerTouched = {}
	local memeTouched = {}
	local nextTouch = {}
	local connections = {}

	local function Touched(hit: BasePart)
		local ancestor: Model? = hit:FindFirstAncestorOfClass("Model")
		local player: Player? = ancestor and Players:GetPlayerFromCharacter(ancestor)
		local now = time()

		if ancestor and (not nextTouch[ancestor] or nextTouch[ancestor] < now) then
			nextTouch[ancestor] = now + 1
			if player then
				for _, callback in pairs(playerTouched) do
					task.defer(callback, player, ancestor)
				end
			elseif ancestor:HasTag("MemeInstance") then
				for _, callback in pairs(memeTouched) do
					task.defer(callback, ancestor)
				end
			end
		end
	end

	if model:IsA("BasePart") then
		table.insert(connections, model.Touched:Connect(Touched))
	end

	for _, v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") then
			table.insert(connections, v.Touched:Connect(Touched))
		end
	end

	return {
		playerTouched = function(callback)
			table.insert(playerTouched, callback)
			return {
				Disconnect = function()
					local i = table.find(playerTouched, callback)
					if i then
						table.remove(playerTouched, i)
					end
				end,
			}
		end,
		memeTouched = function(callback)
			table.insert(memeTouched, callback)
			return {
				Disconnect = function()
					local i = table.find(memeTouched, callback)
					if i then
						table.remove(memeTouched, i)
					end
				end,
			}
		end,

		Destroy = function()
			for _, connection in pairs(connections) do
				if connection.Connected then
					connection:Disconnect()
				end
			end

			connections = {}
		end,
	}
end

-- // Init
local Meme = {}
Meme.__index = Meme

function Meme.new(Name: string, Type: string, SpawnLocation: CFrame, Special: string?, LoadData: boolean?)
	local MemeInfo = Spawns[Type]["Spawns"][Name]
	local RarityFolder = SpawnsFolder:FindFirstChild(Type)
	assert(RarityFolder, "Rarity folder not found")

	local MemeModel = RarityFolder:FindFirstChild(Name)
	assert(MemeModel, `Meme {Name} not found in {Type} folder`)

	local self = setmetatable({}, Meme)
	self.Model = MemeModel:Clone()
	self.Name = Name
	self.Info = table.clone(MemeInfo)
	self.Special = Special
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
	self.RootPart = self.Model.HumanoidRootPart

	self.RootPart.Anchored = false

	if not self.Model.PrimaryPart then
		self.Model.PrimaryPart = self.RootPart
	end

	self.Model.Humanoid.WalkSpeed = 6

	self:SetCollisionGroup("Meme")
	self.Model:AddTag("MemeInstance")

	self.Model.Parent = workspace
	self.Model:PivotTo(SpawnLocation)

	self:MoveTo(workspace.ConveyorSystem.End.Position)

	if Special then
		self:SetupSpecialMeme(LoadData)
	end

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

function Meme:SetupSpecialMeme(LoadData: boolean?)
	local Folder = SpecialFolder:FindFirstChild(self.Special)
	assert(Folder, "Special folder not found")

	local Multiplier = SpecialInfo[self.Special].IncomeMultiplier

	self.Info.Income = math.ceil(self.Info.Income * Multiplier)

	local DisplayAttachment = self.RootPart.Attachment
	local MainFrame = DisplayAttachment.Billboard.Main

	local SpecialText = Folder:FindFirstChild("Text"):Clone()
	SpecialText.Parent = MainFrame

	local VFX = Folder:FindFirstChild("VFX")
	for _, Effect in VFX:GetChildren() do
		Effect:Clone().Parent = self.RootPart
	end

	self.Model.Parent = workspace[self.Special .. "Memes"]

	if not LoadData then
		ShowNotification:FireAllClients(
			`A {string.upper(self.Special)} {self.Name} Meme has spawned!`,
			SpecialInfo[self.Special].Color
		)
	end
end

function Meme:GetSlotByIndex(Index: number, Slots: Folder)
	return Slots:FindFirstChild("Slot" .. Index)
end

function Meme:GetOpenSlot(Slots: Folder)
	local SlotSpaces = Slots:GetChildren()
	for i = 1, #SlotSpaces do
		local CurrentSlot = self:GetSlotByIndex(i, Slots)
		if CurrentSlot:GetAttribute("Meme") then
			continue
		end
		return CurrentSlot
	end
	return nil
end

function Meme:GetNewPrompt()
	local ProximityPrompt = Instance.new("ProximityPrompt")
	ProximityPrompt.Parent = self.RootPart
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
		warn("Attempted to steal Meme. No PurchasePlayer found", StealPlayer.Name)
		return
	end

	local OriginalPlayer = self.PurchasePlayer
	local OriginalPlayerBase = GetPlayerBase(OriginalPlayer)

	if StealPlayer:GetAttribute("Stealing") then
		ShowNotification:FireClient(StealPlayer, "You're already stealing a meme!")
		return
	end

	if self.RootPart and self.RootPart.Parent then
		local StealSound = SoundService.Steal:Clone()
		StealSound.Parent = self.RootPart
		StealSound:Play()
		StealSound.Ended:Once(function()
			StealSound:Destroy()
		end)
	end

	ShowNotification:FireClient(
		self.PurchasePlayer,
		`{StealPlayer.Name} is stealing your {self.Name}!`,
		Color3.fromRGB(255, 0, 0)
	)

	self:Cleanup()

	StealPlayer:SetAttribute("Stealing", true)
	local OGWalkSpeed = StealPlayer.Character.Humanoid.WalkSpeed
	local speedOffset = StealPlayer.Character.Humanoid:GetAttribute("SpeedAddition")
	if speedOffset then
		OGWalkSpeed -= speedOffset
	end

	StealPlayer.Character.Humanoid.WalkSpeed *= 0.8

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
		(
			StealPlayer.Character.HumanoidRootPart.CFrame
			--+ (StealPlayer.Character.HumanoidRootPart.CFrame.LookVector * 3)
			+ (StealPlayer.Character.HumanoidRootPart.CFrame.UpVector * 4)
		) * CFrame.Angles(math.rad(90), 0, 0)
	)

	local Weld = Instance.new("WeldConstraint")
	Weld.Parent = StealPlayer.Character.HumanoidRootPart
	Weld.Part0 = StealPlayer.Character.HumanoidRootPart
	Weld.Part1 = self.Model.PrimaryPart

	local StealPlayerBase = GetPlayerBase(StealPlayer)

	local BaseComponents = StealPlayerBase.Components
	local BaseCollectZone = BaseComponents.CollectZone.CollectPart

	local CollectZone = TouchZone(BaseCollectZone) -- ZonePlus.new(BaseCollectZone)

	task.delay(1, function()
		if StealPlayer.Character.Humanoid.Health <= 0 then
			local PurchasePlayerBase = GetPlayerBase(OriginalPlayer)
			if not PurchasePlayerBase then
				warn("SmackPlayer failed, Could not retrieve original player base")
				return
			end

			local Slots = PurchasePlayerBase.Slots
			local OpenSlot = self:GetOpenSlot(Slots)
			if not OpenSlot then
				warn("SmackPlayer failed, original player no longer has an open slot")
				return
			end

			-- LoadedAnimation:Stop()
			-- Animation:Destroy()

			self.PurchasePlayer = OriginalPlayer
			StealPlayer:SetAttribute("Stealing", nil)

			local Sound = SoundService.Bruh:Clone()
			Sound.Parent = self.RootPart
			Sound:Play()
			Sound.Ended:Once(function()
				Sound:Destroy()
			end)

			OpenSlot:SetAttribute("Meme", self.Name)

			self.RootPart.CanCollide = true
			self.RootPart.Anchored = true

			Weld:Destroy()
			self.CurrentStand = OpenSlot
			TogglePrompt:FireAllClients(self.Prompt, true)
			self.BeingStolen = false

			local _speedOffset = StealPlayer.Character.Humanoid:GetAttribute("SpeedAddition")

			if _speedOffset then
				StealPlayer.Character.Humanoid.WalkSpeed = OGWalkSpeed + _speedOffset
			else
				StealPlayer.Character.Humanoid.WalkSpeed = OGWalkSpeed
			end

			self:AddToSlot(OpenSlot)
		end
	end)

	table.insert(
		self.Connections,
		SmackPlayer.Event:Connect(function(_: Player, OtherPlayer: Player)
			if OtherPlayer == StealPlayer then
				if not OriginalPlayer or not OriginalPlayer.Parent then
					warn("SmackPlayer failed, original player left the game")
					return
				end

				local PurchasePlayerBase = GetPlayerBase(OriginalPlayer)
				if not PurchasePlayerBase then
					warn("SmackPlayer failed, Could not retrieve original player base")
					return
				end

				local Slots = PurchasePlayerBase.Slots
				local OpenSlot = self:GetOpenSlot(Slots)
				if not OpenSlot then
					warn("SmackPlayer failed, original player no longer has an open slot")
					return
				end

				-- LoadedAnimation:Stop()
				-- Animation:Destroy()

				self.PurchasePlayer = OriginalPlayer
				StealPlayer:SetAttribute("Stealing", nil)

				local Sound = SoundService.Bruh:Clone()
				Sound.Parent = self.RootPart
				Sound:Play()
				Sound.Ended:Once(function()
					Sound:Destroy()
				end)

				OpenSlot:SetAttribute("Meme", self.Name)

				self.RootPart.CanCollide = true
				self.RootPart.Anchored = true

				Weld:Destroy()
				self.CurrentStand = OpenSlot
				TogglePrompt:FireAllClients(self.Prompt, true)
				self.BeingStolen = false

				local _speedOffset = StealPlayer.Character.Humanoid:GetAttribute("SpeedAddition")
				if _speedOffset then
					StealPlayer.Character.Humanoid.WalkSpeed = OGWalkSpeed + _speedOffset
				else
					StealPlayer.Character.Humanoid.WalkSpeed = OGWalkSpeed
				end

				self:AddToSlot(OpenSlot)
			end
		end)
	)

	--local db = false
	table.insert(self.Connections, {
		Disconnect = function()
			CollectZone:Destroy()
		end,
	})
	CollectZone.playerTouched(function(Player: Player)
		if Player == StealPlayer then
			--db = true
			--task.delay(4, function()
			--db = false
			--end)
			-- LoadedAnimation:Stop()
			-- Animation:Destroy()
			pcall(function()
				EditPrompt:FireAllClients(self.Prompt, "Steal", self.Name)
			end)

			local Slots = StealPlayerBase.Slots
			local OpenSlot = self:GetOpenSlot(Slots)
			if not OpenSlot then
				ShowNotification:FireClient(StealPlayer, "You don't have a free spot!")
				return
			end

			StealPlayer:SetAttribute("Stealing", nil)
			OpenSlot:SetAttribute("Meme", self.Name)

			self.PurchasePlayer = StealPlayer
			self.CurrentStand = OpenSlot

			self.RootPart.Anchored = true
			self.RootPart.CanCollide = true
			self.RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			self.RootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			Weld:Destroy()

			self.BeingStolen = false
			self:AddToSlot(OpenSlot)

			local DataUtil = require(Utils.DataUtil)
			DataUtil:IncrementSteals(StealPlayer, 1)

			local _speedOffset = StealPlayer.Character.Humanoid:GetAttribute("SpeedAddition")
			if _speedOffset then
				StealPlayer.Character.Humanoid.WalkSpeed = OGWalkSpeed + _speedOffset
			else
				StealPlayer.Character.Humanoid.WalkSpeed = OGWalkSpeed
			end

			TogglePrompt:FireAllClients(self.Prompt, true)
		end
	end)

	table.insert(
		self.Connections,
		Players.PlayerRemoving:Connect(function(player)
			if player == StealPlayer then
				pcall(function()
					EditPrompt:FireAllClients(self.Prompt, "Steal", self.Name)
				end)
				-- LoadedAnimation:Stop()
				-- Animation:Destroy()

				local Slots = OriginalPlayerBase.Slots
				local OpenSlot = self:GetOpenSlot(Slots)
				if not OpenSlot then
					warn(
						"Could not return stolen meme to original player because they don't have an open slot. thief left"
					)
					self:Destroy()
					return
				end
				OpenSlot:SetAttribute("Meme", self.Name)

				self.PurchasePlayer = OriginalPlayer
				self.CurrentStand = OpenSlot
				self.RootPart.Anchored = true
				self.RootPart.CanCollide = true

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
				EditPrompt:FireAllClients(self.Prompt, "Steal", self.Name)
			end)
			-- LoadedAnimation:Stop()
			-- Animation:Destroy()
			StealPlayer:SetAttribute("Stealing", nil)

			local Slots = OriginalPlayerBase.Slots
			local OpenSlot = self:GetOpenSlot(Slots)
			if not OpenSlot then
				warn("Could not return stolen meme to original player because they don't have an open slot. thief died")
				self:Destroy()
				return
			end
			OpenSlot:SetAttribute("Meme", self.Name)

			self.PurchasePlayer = OriginalPlayer
			self.CurrentStand = OpenSlot
			self.RootPart.Anchored = true
			self.RootPart.CanCollide = true

			Weld:Destroy()
			self.BeingStolen = false
			self:AddToSlot(OpenSlot)
			TogglePrompt:FireAllClients(self.Prompt, true)
		end)
	)
end

function Meme:SetOfflineCash(AddAmount: number, FinalAmount: number)
	local Slot = self.CurrentStand

	local CollectButton: Part = Slot.Collect

	self.CurrentEarned += AddAmount
	local OfflineAttachment = CollectButton.OfflineAttachment
	OfflineAttachment.Billboard.Frame.offline.Text = `Offline Cash: ${FormatNumber(FinalAmount)}`
	OfflineAttachment.Billboard.Frame.Visible = true
end

function Meme:AddToSlot(Slot: Model, LoadData: boolean?, OfflineIncome: number?, value: boolean?)
	if not self.PurchasePlayer then
		self.PurchasePlayer = Players:FindFirstChild(Slot.Parent.Parent:GetAttribute("Owner"))
	end

	if not self.PurchasePlayer then
		local parts = workspace:GetPartsInPart(self.RootPart)
		for _, part in pairs(parts) do
			if part.Parent.Name == "CollectPart" then
				local base = part.Parent.Parent.Parent.Parent
				local owner = base:GetAttribute("Owner")
				local player = owner and Players:FindFirstChild(owner)
				if player then
					self.PurchasePlayer = player
				end
				break
			end
		end

		if not self.PurchasePlayer then
			warn("Could not add to slot because purchase player is invalid.", self.Name)
			self:Destroy()
		end
	end

	if self.BeingStolen then
		warn("Meme not added to slot because it's being stolen", self.PurchasePlayer)
		return
	end

	self:CleanupConnects()
	self.CurrentStand = Slot
	Slot:SetAttribute("Meme", self.Name)

	if LoadData == nil then
		Signal.AddMemeToPlayer:Fire(self.PurchasePlayer, self)
	end

	local cframe, size = self.Model:GetBoundingBox()
	local modelPivot = self.Model:GetPivot()

	local heightOffset = modelPivot.Position.Y - cframe.Position.Y + size.Y * 0.5
	local targetPivot = Slot.Stand.CFrame
		* CFrame.new(Vector3.new(0, Slot.Stand.Size.Y / 2, 0) + Vector3.new(0, heightOffset, 0))
		* CFrame.Angles(0, math.rad(-90), 0)

	self.RootPart.Anchored = false
	self.RootPart.AssemblyLinearVelocity = Vector3.zero
	self.RootPart.AssemblyAngularVelocity = Vector3.zero

	self.Model:PivotTo(targetPivot)

	task.delay(0.3, function()
		self.Model:PivotTo(targetPivot)
		self.RootPart.Anchored = true
		self.Model:PivotTo(targetPivot)
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
	self.Prompt.HoldDuration = 2
	if LoadData then
		task.delay(5, function()
			if self.PurchasePlayer then
				EditPrompt:FireClient(
					self.PurchasePlayer,
					self.Prompt,
					"Sell",
					`Sell ${self.Name} for ${SellPrice}`,
					nil
				)
			end
		end)
	else
		task.delay(1, function()
			if self.PurchasePlayer then
				EditPrompt:FireClient(
					self.PurchasePlayer,
					self.Prompt,
					"Sell",
					`Sell ${self.Name} for ${SellPrice}`,
					nil
				)
			end
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
			if SellPrice == 0 then
				ShowNotification:FireClient(Player, "You cannot sell a Robux meme!")
				return
			end
			Signal.IncrementCash:Fire(Player, SellPrice)
			Signal.RemoveMemeFromPlayer:Fire(self.PurchasePlayer, self)
			local sound = SoundService.CashCollect:Clone()
			sound.Parent = self.RootPart
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
	ProximityPrompt.HoldDuration = 0.25

	local DefaultWalkspeed = self.Model.Humanoid.WalkSpeed
	local FasterWalkspeed = DefaultWalkspeed * 2

	self.Prompt = ProximityPrompt
	local humConnect
	local moveConn

	table.insert(
		self.Connections,
		ReplicatedStorage.SpeedTime:GetPropertyChangedSignal("Value"):Connect(function()
			if ReplicatedStorage.SpeedTime.Value > 0 then
				self.Model.Humanoid.WalkSpeed = FasterWalkspeed
			else
				self.Model.Humanoid.WalkSpeed = DefaultWalkspeed
			end
		end)
	)

	self.CurrentPos = nil
	table.insert(
		self.Connections,
		Signal.RobuxBuyMeme:Connect(function(Player: Player)
			local DataUtil = require(script.Parent.DataUtil)
			local PlayersPurchasingMemes = DataUtil:GetPlayersPurchasingMemes()
			local NewTable = PlayersPurchasingMemes
			local CurrentId = self.Model:GetAttribute("ID")

			if not NewTable[CurrentId] then
				return
			end

			for _, _Player in NewTable[CurrentId] do
				if _Player == Player then
					table.remove(NewTable[CurrentId], table.find(NewTable[CurrentId], Player))

					local PlayerBase = GetPlayerBase(Player)
					local Slots = PlayerBase and PlayerBase.Slots
					if not Slots then
						warn("Slots/PlayerBase is invalid")
						return
					end

					if not self:GetOpenSlot(Slots) then
						local err = SoundService.Error:Clone()
						err.Parent = Player.PlayerGui
						err:Play()
						err.Ended:Once(function()
							err:Destroy()
						end)
						return ShowNotification:FireClient(Player, "You do not have any open slots!")
					end

					local OpenSlot = self:GetOpenSlot(Slots)
					OpenSlot:SetAttribute("Meme", self.Name)
					self.CurrentStand = OpenSlot

					TogglePrompt:FireClient(Player, ProximityPrompt, false)

					local BeingRedirected = false
					if BeingRedirected then
						local Sound = SoundService.Nope:Clone()
						Sound.Parent = self.RootPart
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

					local CollectZone = TouchZone(PlayerBase.Components.CollectZone.CollectPart) -- ZonePlus.new(PlayerBase.Components.CollectZone.CollectPart)

					moveConn = self.Model.Humanoid.MoveToFinished:Connect(function()
						local distance = (
							(
								self.Model.PrimaryPart.Position
								- PlayerBase.Components.CollectZone.CollectPart.PrimaryPart.Position
							) * Vector3.new(1, 0, 1)
						).Magnitude
						if distance < 3 then
							warn("Fallback triggered - meme close but not detected")
							self:AddToSlot(OpenSlot)
							humConnect:Disconnect()
						end
					end)

					CollectZone.memeTouched(function(meme)
						if meme == self.Model then
							if Player.Parent ~= Players then
								self:Destroy()
								return
							end
							pcall(function()
								task.cancel(self.CurrentMove)
							end)

							self.CurrentStand = OpenSlot
							self:AddToSlot(OpenSlot)
							humConnect:Disconnect()
							moveConn:Disconnect()
						end
					end)

					humConnect = {
						Disconnect = function()
							CollectZone:Destroy()
						end,
					}
				else
					return
				end
			end
			DataUtil:UpdatePlayersPurchasingMemes(NewTable)
		end)
	)
	table.insert(
		self.Connections,
		ProximityPrompt.Triggered:Connect(function(Player: Player)
			local Cash = Player.leaderstats.Cash.Value

			local PlayerBase = GetPlayerBase(Player)
			local Slots = PlayerBase and PlayerBase.Slots
			if not Slots then
				warn("Slots/PlayerBase is invalid")
				return
			end

			if not self:GetOpenSlot(Slots) then
				local err = SoundService.Error:Clone()
				err.Parent = Player.PlayerGui
				err:Play()
				err.Ended:Once(function()
					err:Destroy()
				end)
				return ShowNotification:FireClient(Player, "You do not have any open slots!")
			end

			local BeingRedirected = false
			if self.PurchasePlayer then
				if self.Redirects then
					BeingRedirected = true
					TogglePrompt:FireAllClients(ProximityPrompt, true)
					self.CurrentStand:SetAttribute("Meme", nil)
					humConnect:Disconnect()
					moveConn:Disconnect()
				else
					ShowNotification:FireClient(Player, "This meme is not able to be redirected!")
					return
				end
				--self.CurrentStand:SetAttribute("Meme", nil)
			end

			if Cash >= self.Info.Price then
				local OpenSlot = self:GetOpenSlot(Slots)
				OpenSlot:SetAttribute("Meme", self.Name)
				self.CurrentStand = OpenSlot
				Signal.IncrementCash:Fire(Player, -self.Info.Price)

				TogglePrompt:FireClient(Player, ProximityPrompt, false)

				if BeingRedirected then
					local Sound = SoundService.Nope:Clone()
					Sound.Parent = self.RootPart
					Sound:Play()
					Sound.Ended:Once(function()
						Sound:Destroy()
					end)
				else
					local sound
					if self.Info.Sound then
						sound = Instance.new("Sound")
						sound.Volume = 1.5
						sound.SoundId = "rbxassetid://" .. tostring(self.Info.Sound)
					else
						sound = SoundService.Success:Clone()
					end
					sound.Parent = self.RootPart
					sound:Play()
					if self.Info.SoundCutoff then
						task.delay(self.Info.SoundCutoff, function()
							sound:Destroy()
						end)
					else
						sound.Ended:Once(function()
							sound:Destroy()
						end)
					end
				end

				self.Model.Humanoid.WalkSpeed = 10

				self:MoveTo(PlayerBase.Components.CollectZone.CollectPart.PrimaryPart.Position)
				self.PurchasePlayer = Player

				local CollectZone = TouchZone(PlayerBase.Components.CollectZone.CollectPart) -- ZonePlus.new(PlayerBase.Components.CollectZone.CollectPart)

				moveConn = self.Model.Humanoid.MoveToFinished:Connect(function()
					local distance = (
						(
							self.Model.PrimaryPart.Position
							- PlayerBase.Components.CollectZone.CollectPart.PrimaryPart.Position
						) * Vector3.new(1, 0, 1)
					).Magnitude
					if distance < 3 then
						warn("Fallback triggered - meme close but not detected")
						self:AddToSlot(OpenSlot)
						humConnect:Disconnect()
					end
				end)

				CollectZone.memeTouched(function(meme)
					if meme == self.Model then
						if Player.Parent ~= Players then
							self:Destroy()
							return
						end
						pcall(function()
							task.cancel(self.CurrentMove)
						end)

						self.CurrentStand = OpenSlot
						self:AddToSlot(OpenSlot)
						humConnect:Disconnect()
						moveConn:Disconnect()
					end
				end)

				humConnect = {
					Disconnect = function()
						CollectZone:Destroy()
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
				if Products[self.Rarity .. " Meme"] then
					MarketplaceService:PromptProductPurchase(Player, Products[self.Rarity .. " Meme"].ProductId)
					local DataUtil = require(script.Parent.DataUtil)
					local PlayersPurchasingMemes = DataUtil:GetPlayersPurchasingMemes()
					local NewTable = PlayersPurchasingMemes
					for ID, _Players in NewTable do
						for _, _Player in _Players do
							if _Player == Player then
								table.remove(NewTable[ID], table.find(NewTable[ID], Player))
							end
						end
					end
					if not NewTable[self.Model:GetAttribute("ID")] then
						NewTable[self.Model:GetAttribute("ID")] = {}
					end
					table.insert(NewTable[self.Model:GetAttribute("ID")], Player)
					DataUtil:UpdatePlayersPurchasingMemes(NewTable)
				end

				return
			end
		end)
	)
end

function Meme:SetupDisplayInfo()
	local Price = self.Info.Price
	local Income = self.Info.Income

	local DisplayAttachment = self.RootPart.Attachment
	local MainFrame = DisplayAttachment.Billboard.Main

	MainFrame.Money.Text = `${FormatNumber(Income)}/s`
	if Price == 0 then
		MainFrame.Price.Text = "???"
	else
		MainFrame.Price.Text = `${FormatNumber(Price)}`
	end
	MainFrame:FindFirstChild("Name").Text = self.Name
end

function Meme:MoveTo(Position: Vector3)
	local Humanoid = self.Model:FindFirstChild("Humanoid")

	if self.CurrentMove and coroutine.status(self.CurrentMove) ~= "dead" then
		task.cancel(self.CurrentMove)
	end

	if Humanoid then
		self.CurrentMove = task.spawn(function()
			while (self.RootPart.Position - Position).magnitude > 5 do
				Humanoid:MoveTo(Position)
				task.wait(0.1)
			end
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

		self.BeingStolen = false
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
