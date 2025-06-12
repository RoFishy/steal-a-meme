-- // Services
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Modules
local Modules = ReplicatedStorage.Modules
local Products = require(Modules.Products)
local Rebirths = require(Modules.Rebirths)

-- // Remotes
local Remotes = ReplicatedStorage.Remotes
local SetupBaseDisplay = Remotes.SetupBaseDisplay
local ShowNotification = Remotes.ShowNotification
local ToggleCollision = Remotes.ToggleCollision

-- // Utils
local Utils = script.Parent.Parent.Utils
local Signals = require(Utils.Signals)

-- // Objects
local BasesFolder = workspace.Bases
local Floor = workspace.Floor

-- // Constants
--local LOCK_COOLDOWN = 30
local BYPASS_COOLDOWN_PRODUCT = Products.BypassLockCooldown.ProductId

-- // Local Functions
function Format(Int)
	return string.format("%02i", Int)
end

function convertToMS(Seconds)
	local Minutes = (Seconds - Seconds % 60) / 60
	Seconds = Seconds - Minutes * 60
	local Hours = (Minutes - Minutes % 60) / 60
	Minutes = Minutes - Hours * 60
	return Format(Minutes) .. ":" .. Format(Seconds)
end

-- // Module
local BaseManager = {}

function BaseManager.Init()
	BaseManager.Junk = {}
	-- // Meme init
	PhysicsService:RegisterCollisionGroup("Meme")
	PhysicsService:CollisionGroupSetCollidable("Meme", "Meme", false)
	PhysicsService:RegisterCollisionGroup("Floor")
	PhysicsService:CollisionGroupSetCollidable("Meme", "Default", false)
	PhysicsService:CollisionGroupSetCollidable("Meme", "Floor", true)
	Floor.CollisionGroup = "Floor"

	PhysicsService:RegisterCollisionGroup("Player")
	PhysicsService:CollisionGroupSetCollidable("Meme", "Player", false)

	-- // Init bases
	BaseManager.Bases = {}
	BaseManager.PlayersTryingToUnlock = {}
	for _, Base in BasesFolder:GetChildren() do
		BaseManager.Bases[Base.Name] = {
			Owner = nil,
			Locked = false,
			CooldownThread = nil,
		}
		BaseManager.PlayersTryingToUnlock[Base.Name] = {}
		BaseManager:ResetBase(Base.Name)

		-- // physics stuff
		for _, Slot: BasePart in Base.Slots:GetDescendants() do
			if Slot:IsA("BasePart") then
				Slot.CollisionGroup = "Floor"
			end
		end
	end
end

function BaseManager:Start()
	Signals.BypassLockCooldown:Connect(function(Player: Player)
		local BaseData = self.Bases[self:GetBaseNameFromPlayer(Player)]
		if BaseData.CooldownThread then
			task.cancel(BaseData.CooldownThread)
			self:LockBase(self:GetBaseNameFromPlayer(Player))
		end
	end)

	for _, Base in BasesFolder:GetChildren() do
		local Components = Base.Components
		local LockButton: Part = Components.LockButton
		local RobuxLockButton: Part = Components.LockButtonRBX

		LockButton.Touched:Connect(function(Hit: Part)
			local Player = Players:GetPlayerFromCharacter(Hit.Parent)
			local DataUtil = require(script.Parent.Parent.Utils.DataUtil)
			if Player then
				local LockTime = DataUtil:GetData(Player).LockTime
				local BaseData = self.Bases[Base.Name]
				if BaseData.Owner and BaseData.Owner == Player then
					if BaseData.Locked == true then
						return
					end
					if LockButton.Attachment.Billboard.Frame.TextUpper.Text ~= "Lock Base" then -- its o n cooldown
						return MarketplaceService:PromptProductPurchase(Player, BYPASS_COOLDOWN_PRODUCT)
					end
					self:LockBase(Base.Name)
					ShowNotification:FireClient(
						Player,
						`You have locked your base for {LockTime} seconds!`,
						Color3.fromRGB(0, 255, 0)
					)
				end
			end
		end)

		RobuxLockButton.Touched:Connect(function(Hit: Part)
			local Player = Players:GetPlayerFromCharacter(Hit.Parent)
			if Player then
				local BaseData = self.Bases[Base.Name]
				if BaseData.Owner and BaseData.Owner == Player then
					if BaseData.Locked == true then
						return
					end
					MarketplaceService:PromptProductPurchase(Player, Products["Lock Base 15 Minutes"].ProductId)
				end
			end
		end)
	end
end

function BaseManager:RemoteLock(Player: Player)
	local Base = BasesFolder[self:GetBaseNameFromPlayer(Player)]
	local Components = Base.Components
	local LockButton: Part = Components.LockButton
	local DataUtil = require(script.Parent.Parent.Utils.DataUtil)

	local LockTime = DataUtil:GetData(Player).LockTime
	local BaseData = self.Bases[Base.Name]
	if BaseData.Owner and BaseData.Owner == Player then
		if BaseData.Locked then
			return
		end
		if LockButton.Attachment.Billboard.Frame.TextUpper.Text ~= "Lock Base" then -- its o n cooldown
			return MarketplaceService:PromptProductPurchase(Player, BYPASS_COOLDOWN_PRODUCT)
		end
		self:LockBase(Base.Name)
		ShowNotification:FireClient(
			Player,
			`You have locked your base for {LockTime} seconds!`,
			Color3.fromRGB(0, 255, 0)
		)
	end
end

function BaseManager:GetBaseNameFromPlayer(Player: Player): string?
	for Name, Base in self.Bases do
		if Base.Owner == Player then
			return Name
		end
	end
	return nil
end

function BaseManager:LockBase(Base: string, Time: number?)
	Base = BasesFolder[Base]

	self.Bases[Base.Name].Locked = true

	local DataUtil = require(script.Parent.Parent.Utils.DataUtil)
	local PlayerData = DataUtil:GetData(self.Bases[Base.Name].Owner)
	local LockTime = PlayerData.LockTime

	local Components = Base.Components
	local Locks = Components.Lock

	local _LockTime = Time or LockTime

	task.spawn(function()
		for i = _LockTime, 0, -1 do
			Components.LockButton.Attachment.Billboard.Frame.TextUpper.Text = `Locked for: {convertToMS(i)}`
			Components.LockButton.Attachment.Billboard.Frame.TextUpper.Stroke.Text = `Locked for: {convertToMS(i)}`
			task.wait(1)
		end
		self:UnlockBase(Base.Name)
	end)

	Locks.Wall.CanCollide = true

	local Attachment = Instance.new("Attachment")
	Attachment.Parent = Locks.Wall
	Attachment.CFrame = Attachment.CFrame * CFrame.new(0, -5, 0)

	local ProximityPrompt = Instance.new("ProximityPrompt")
	ProximityPrompt.RequiresLineOfSight = false
	ProximityPrompt.Parent = Attachment
	ProximityPrompt.ActionText = "Unlock Base"
	ProximityPrompt.ObjectText = "R$39"

	ProximityPrompt.Triggered:Connect(function(playerWhoTriggered)
		if playerWhoTriggered ~= self.Bases[Base.Name].Owner then
			for _Base, _Players in self.PlayersTryingToUnlock do
				if table.find(_Players, playerWhoTriggered) then
					table.remove(
						self.PlayersTryingToUnlock[_Base],
						table.find(self.PlayersTryingToUnlock[_Base], playerWhoTriggered)
					)
				end
			end
			table.insert(self.PlayersTryingToUnlock[Base.Name], playerWhoTriggered)
			MarketplaceService:PromptProductPurchase(playerWhoTriggered, Products.UnlockBase.ProductId)
		end
	end)

	ToggleCollision:FireAllClients(Locks.Wall, true)
	ToggleCollision:FireClient(self.Bases[Base.Name].Owner, Locks.Wall, false)

	for _, Lock in Locks:GetDescendants() do
		if Lock:IsA("BasePart") then
			if Lock.Name == "Wall" then
				continue
			end
			Lock.Transparency = 0
		end
	end
end

function BaseManager:UnlockForPlayer(Player: Player)
	for _Base, _Players in self.PlayersTryingToUnlock do
		if table.find(_Players, Player) then
			table.remove(self.PlayersTryingToUnlock[_Base], table.find(self.PlayersTryingToUnlock[_Base], Player))

			local Base = BasesFolder:FindFirstChild(_Base)
			local Components = Base.Components
			local Locks = Components.Lock

			ToggleCollision:FireClient(Player, Locks.Wall, false)

			ShowNotification:FireClient(
				Player,
				`You have unlocked {Base:GetAttribute("Owner")}'s base! Go inside and have fun!`,
				Color3.fromRGB(0, 255, 0)
			)
			ShowNotification:FireClient(
				Players:FindFirstChild(Base:GetAttribute("Owner")),
				`Your base has been unlocked by {Player.Name}! Be careful!`,
				Color3.fromRGB(255, 0, 0)
			)
		end
	end
end

function BaseManager:UnlockBase(Base: string)
	Base = BasesFolder[Base]

	self.Bases[Base.Name].Locked = false

	local Components = Base.Components
	local Locks = Components.Lock
	--[[
		self.Bases[Base.Name].CooldownThread = task.spawn(function()
		for i = LOCK_COOLDOWN, 0, -1 do
			Components.LockButton.Attachment.Billboard.Frame.TextUpper.Text = `Cooldown: {i}`
			Components.LockButton.Attachment.Billboard.Frame.TextUpper.Stroke.Text = `Cooldown: {i}`
			task.wait(1)
		end
		Components.LockButton.Attachment.Billboard.Frame.TextUpper.Text = "Lock Base"
		Components.LockButton.Attachment.Billboard.Frame.TextUpper.Stroke.Text = "Lock Base"
	end)
	]]
	--
	Components.LockButton.Attachment.Billboard.Frame.TextUpper.Text = "Lock Base"
	Components.LockButton.Attachment.Billboard.Frame.TextUpper.Stroke.Text = "Lock Base"
	Locks.Wall.CanCollide = false

	local attachment = Locks.Wall:FindFirstChildOfClass("Attachment")
	if attachment then
		attachment:Destroy()
	end
	for _, Lock in Locks:GetDescendants() do
		if Lock:IsA("BasePart") then
			if Lock.Name == "Wall" then
				continue
			end
			Lock.Transparency = 1
		end
	end
end

function BaseManager:GetEmptyBaseName(): string
	for Name, Base in self.Bases do
		if Base.Owner == nil then
			return Name
		end
	end
	return nil
end

function BaseManager:AssignBase(Player: Player, Base: string)
	self.Junk[Player] = {}
	if self:GetBaseNameFromPlayer(Player) then
		return
	end

	local BaseName = Base or self:GetEmptyBaseName()
	assert(BaseName, "No available bases! (Server size limit too high?)")

	self.Bases[BaseName].Owner = Player

	local BaseModel = BasesFolder[BaseName]
	BaseModel:SetAttribute("Owner", Player.Name)

	local Components = BaseModel.Components
	local Sign = Components.Sign
	local SignGui = Sign.Main.Sign.SurfaceGui
	local CashMultiText = Components.CashMulti.Attachment.Billboard.Frame.TextLow

	local leaderstats = Player:WaitForChild("leaderstats")
	local PlayerRebirths = leaderstats.Rebirths

	local Multiplier = Rebirths[PlayerRebirths.Value] and Rebirths[PlayerRebirths.Value].Rewards.Multiplier or 1
	CashMultiText.Text = `Cash Multiplier: {Multiplier}x`

	PlayerRebirths:GetPropertyChangedSignal("Value"):Connect(function()
		Multiplier = Rebirths[PlayerRebirths.Value].Rewards.Multiplier or 1
		CashMultiText.Text = `Cash Multiplier: {Multiplier}x`
	end)

	SignGui:FindFirstChildOfClass("TextLabel").Text = `{Player.Name}'s Base`
	self:TeleportPlayerToBase(Player, BaseName)

	-- // Physics
	local Character = Player.Character or Player.CharacterAdded:Wait()
	for _, Item: BasePart in Character:GetDescendants() do
		if Item:IsA("BasePart") then
			Item.CollisionGroup = "Player"
		end
	end

	SetupBaseDisplay:FireClient(Player, BaseName)
end

function BaseManager:TeleportPlayerToBase(Player: Player, Base: string?)
	Base = Base or self:GetBaseNameFromPlayer(Player)
	Base = BasesFolder[Base]

	local Components = Base.Components
	local SpawnPart = Components.SpawnPart

	local Character = Player.Character or Player.CharacterAdded:Wait()
	Character:PivotTo(SpawnPart.CFrame)
end

function BaseManager:ResetBase(Base: string)
	if BaseManager.Bases[Base].Locked then
		self:UnlockBase(Base)
	end
	local DataUtil = require(Utils.DataUtil)

	local CurrentMemes = DataUtil:GetCurrentMemes(self.Bases[Base].Owner)

	if self.Bases[Base].Owner then
		for _, obj in self.Junk[self.Bases[Base].Owner] do
			obj:Disconnect()
		end
	end

	self.Bases[Base].Owner = nil
	Base = BasesFolder[Base]
	Base:SetAttribute("Owner", nil)
	local Components = Base.Components
	local Sign = Components.Sign
	local SignGui = Sign.Main.Sign.SurfaceGui
	local CashMultiText = Components.CashMulti.Attachment.Billboard.Frame.TextLow

	CashMultiText.Text = "Cash Multiplier: 1x"

	for _, Slot in Base.Slots:GetChildren() do
		local collectAt = Slot.Collect.Attachment
		local offlineAt = Slot.Collect.OfflineAttachment
		offlineAt.Billboard.Frame.Visible = false
		collectAt.Billboard.Frame.amount.Text = "$0"
	end

	SignGui:FindFirstChildOfClass("TextLabel").Text = `Unclaimed Base`
	if not CurrentMemes then
		return
	end
	for ID, Meme in CurrentMemes do
		local Name = Meme.Name
		local Stand = Meme.Stand
		Base.Slots[Stand]:SetAttribute("Meme", nil)
		for _, _Meme in workspace:GetChildren() do
			if _Meme.Name == Name then
				if _Meme:GetAttribute("ID") == ID then
					task.spawn(function()
						pcall(function()
							_Meme:Destroy()
						end)
					end)
				end
			end
		end
	end
end

return BaseManager
