-- // Services
local Players = game:GetService("Players")
local PhysicsService = game:GetService("PhysicsService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Modules
local Modules = ReplicatedStorage.Modules
local Products = require(Modules.Products)

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
local LOCK_TIME = 60
local LOCK_COOLDOWN = 30
local BYPASS_COOLDOWN_PRODUCT = Products.BypassLockCooldown.ProductId

-- // Module
local BaseManager = {}

function BaseManager.Init()
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
	for _, Base in BasesFolder:GetChildren() do
		BaseManager.Bases[Base.Name] = {
			Owner = nil,
			Locked = false,
			CooldownThread = nil,
		}
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

		LockButton.Touched:Connect(function(Hit: Part)
			local Player = Players:GetPlayerFromCharacter(Hit.Parent)
			if Player then
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
						`You have locked your base for {LOCK_TIME} seconds!`,
						Color3.fromRGB(0, 255, 0)
					)
				end
			end
		end)
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

function BaseManager:LockBase(Base: string)
	Base = BasesFolder[Base]

	self.Bases[Base.Name].Locked = true

	local Components = Base.Components
	local Locks = Components.Lock

	task.spawn(function()
		for i = LOCK_TIME, 0, -1 do
			Components.LockButton.Attachment.Billboard.Frame.TextUpper.Text = `Locked for: {i}`
			Components.LockButton.Attachment.Billboard.Frame.TextUpper.Stroke.Text = `Locked for: {i}`
			task.wait(1)
		end
		self:UnlockBase(Base.Name)
	end)

	Locks.Wall.CanCollide = true
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

function BaseManager:UnlockBase(Base: string)
	Base = BasesFolder[Base]

	self.Bases[Base.Name].Locked = false

	local Components = Base.Components
	local Locks = Components.Lock
	self.Bases[Base.Name].CooldownThread = task.spawn(function()
		for i = LOCK_COOLDOWN, 0, -1 do
			Components.LockButton.Attachment.Billboard.Frame.TextUpper.Text = `Cooldown: {i}`
			Components.LockButton.Attachment.Billboard.Frame.TextUpper.Stroke.Text = `Cooldown: {i}`
			task.wait(1)
		end
		Components.LockButton.Attachment.Billboard.Frame.TextUpper.Text = "Lock Base"
		Components.LockButton.Attachment.Billboard.Frame.TextUpper.Stroke.Text = "Lock Base"
	end)

	Locks.Wall.CanCollide = false
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

function BaseManager:AssignBase(Player: Player)
	if self:GetBaseNameFromPlayer(Player) then
		return
	end

	local BaseName = self:GetEmptyBaseName()
	assert(BaseName, "No available bases! (Server size limit too high?)")

	self.Bases[BaseName].Owner = Player

	local BaseModel = BasesFolder[BaseName]

	local Components = BaseModel.Components
	local Sign = Components.Sign
	local SignGui = Sign.Main.Sign.SurfaceGui

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
	Base = BasesFolder[Base] or BasesFolder[self:GetBaseNameFromPlayer(Player)]

	local Components = Base.Components
	local SpawnPart = Components.SpawnPart

	local Character = Player.Character or Player.CharacterAdded:Wait()
	Character:PivotTo(SpawnPart.CFrame)
end

function BaseManager:ResetBase(Base: string)
	local DataUtil = require(Utils.DataUtil)

	local CurrentMemes = DataUtil:GetCurrentMemes(self.Bases[Base].Owner)

	self.Bases[Base].Owner = nil
	Base = BasesFolder[Base]
	local Components = Base.Components
	local Sign = Components.Sign
	local SignGui = Sign.Main.Sign.SurfaceGui

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
					_Meme:Destroy()
				end
			end
		end
	end
end

return BaseManager
