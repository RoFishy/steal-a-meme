-- // Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local ForeverPack = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ForeverPack"))

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // Util
local Button = require(script.Parent.Parent.Utils.Button)

-- // Module
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Products = require(Modules.Products)
local Gamepasses = require(Modules.Gamepasses)

local UIManager = require(script.Parent.Parent)

-- // Luck stuff
local CurrentLuck = ReplicatedStorage.CurrentLuck

-- // Packages
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Replica = require(Packages.Replica)

-- // UI
local MainUI = PlayerGui:WaitForChild("UI")
local ShopFrame = MainUI:WaitForChild("Frames"):WaitForChild("Shop")

local ScrollingFrame: ScrollingFrame = ShopFrame.ScrollingFrame
local CashHolder = ScrollingFrame.Cash.holder
local GearsHolder = ScrollingFrame.Gears.holder
local PassesHolder = ScrollingFrame.Passes.holder

local CloseButton = ShopFrame.Top.close

-- // Const
local SPECIAL_CANVAS_POSITION = Vector2.new(0, 0)
local GEARS_CANVAS_POSITION = Vector2.new(0, ScrollingFrame.AbsoluteCanvasSize.Y * 0.225)
local PASSES_CANVAS_POSITION = Vector2.new(0, ScrollingFrame.AbsoluteCanvasSize.Y * 0.45)
local MONEY_CANVAS_POSITION = Vector2.new(0, ScrollingFrame.AbsoluteCanvasSize.Y * 1)

local FOREVER_PACK_PURCHASE = Color3.fromRGB(101, 232, 0)
local FOREVER_PACK_NEXT = Color3.fromRGB(129, 129, 129)

-- // Local func
local function GetLowestIndex(Table: {}): number
	local CurrentLowest
	for index, _ in Table do
		if not CurrentLowest then
			CurrentLowest = index
		else
			if index < CurrentLowest then
				CurrentLowest = index
			end
		end
	end
	return tonumber(CurrentLowest) or CurrentLowest
end

-- // Init
local Shop = {}

function Shop.Init()
	Shop.Junk = {}

	CurrentLuck:GetPropertyChangedSignal("Value"):Connect(function()
		if CurrentLuck.Value == 16 then
			ScrollingFrame.Luck.before.Text = "MAX"
			ScrollingFrame.Luck.after.Text = "MAX"
			ScrollingFrame.Luck.Buy.price.Text = "MAX"
			return
		end
		local info = Shop:GetRobuxProductInfo(Products[`x{CurrentLuck.Value * 2} Luck`].ProductId)
		ScrollingFrame.Luck.Buy.price.Text = "" .. info.PriceInRobux
		ScrollingFrame.Luck.before.Text = tostring(CurrentLuck.Value) .. "x"
		ScrollingFrame.Luck.after.Text = tostring(CurrentLuck.Value * 2) .. "x"
	end)
end

local LastForeverPackReset = 0

local ButtonShit = {}
Shop.UpdateForeverPack = function(ForeverPackTable)
	local ForeverPackHolder: Frame = ShopFrame.ScrollingFrame.ForeverPack

	for index, v in ButtonShit do
		v()
		table.remove(ButtonShit, index)
	end

	for _, v: Frame in ForeverPackHolder.Main:GetChildren() do
		if v:IsA("Frame") and v.Visible then
			v:Destroy()
		end
	end

	local LowestIndex = GetLowestIndex(ForeverPackTable)

	for Index, Data in ForeverPackTable do
		Index = tonumber(Index)
		local RewardIndex = Data.RewardIndex

		local new: Frame = ForeverPackHolder.Main:FindFirstChild(Index) or ForeverPackHolder.Main.Template:Clone()
		new.Name = Index
		new.LayoutOrder = Index
		new.ClaimBtn.price.Text = tonumber(ForeverPack.GetPriceFromIndex(tonumber(Index)))
				and utf8.char(0xE002) .. MarketplaceService:GetProductInfo(
					ForeverPack.GetPriceFromIndex(tonumber(Index)),
					Enum.InfoType.Product
				).PriceInRobux
			or "FREE"
		new.Visible = true

		if Index == LowestIndex then
			new.ClaimBtn.BackgroundColor3 = FOREVER_PACK_PURCHASE
		else
			new.ClaimBtn.BackgroundColor3 = FOREVER_PACK_NEXT
		end

		table.insert(
			ButtonShit,
			Button(new.ClaimBtn, function()
				local Updated = ReplicatedStorage.Remotes.ClaimForeverPack:InvokeServer()

				if Updated then
					for index, v in ButtonShit do
						v()
						table.remove(ButtonShit, index)
					end
					Shop.UpdateForeverPack(Updated)
				end
			end)
		)
		--[[
				new.ClaimBtn.MouseButton1Up:Connect(function()
			local Updated = ReplicatedStorage.Remotes.ClaimForeverPack:InvokeServer()

			if Updated then
				Shop.UpdateForeverPack(Updated)
			end
		end)
		]]
		--
		new.RewardLabel.Text = ForeverPack.Rewards[RewardIndex].Text
		new.ImageLabel.Image = ForeverPack.Rewards[RewardIndex].Image
		new.Parent = ForeverPackHolder.Main
	end
end

function Shop:Start()
	task.spawn(function()
		while task.wait(1) do
			local TimeLeft = 21600 - (workspace:GetServerTimeNow() - LastForeverPackReset)

			if TimeLeft > 0 then
				local hours = math.floor(TimeLeft / 3600)
				local minutes = math.floor((TimeLeft % 3600) / 60)
				local seconds = TimeLeft % 60

				ShopFrame.ScrollingFrame.ForeverPack.RefreshLabel.Text =
					string.format("Refreshes in %02d:%02d:%02d", hours, minutes, seconds)
			else
				ShopFrame.ScrollingFrame.ForeverPack.RefreshLabel.Text = "Refreshing Soon..."
			end
		end
	end)

	Replica.OnNew("PlayerData", function(_replica)
		Shop.UpdateForeverPack(_replica.Data.ForeverPack)
		LastForeverPackReset = _replica.Data.LastForeverPackReset
		_replica:OnSet({ "ForeverPack" }, function(new_value)
			Shop.UpdateForeverPack(new_value)
		end)

		_replica:OnSet({ "LastForeverPackReset" }, function(new_value)
			LastForeverPackReset = new_value
		end)
	end)
	Replica.RequestData()

	-- // close btn

	table.insert(
		self.Junk,
		Button(CloseButton, function()
			UIManager:CloseAllFrames()
		end)
	)

	-- // Scrolling Buttons
	table.insert(
		self.Junk,
		Button(ShopFrame.Gears, function()
			TweenService:Create(ScrollingFrame, TweenInfo.new(0.2), { CanvasPosition = GEARS_CANVAS_POSITION }):Play()
		end)
	)
	table.insert(
		self.Junk,
		Button(ShopFrame.Passes, function()
			TweenService:Create(ScrollingFrame, TweenInfo.new(0.2), { CanvasPosition = PASSES_CANVAS_POSITION }):Play()
		end)
	)
	table.insert(
		self.Junk,
		Button(ShopFrame.Money, function()
			TweenService:Create(ScrollingFrame, TweenInfo.new(0.2), { CanvasPosition = MONEY_CANVAS_POSITION }):Play()
		end)
	)
	table.insert(
		self.Junk,
		Button(ShopFrame.Special, function()
			TweenService:Create(ScrollingFrame, TweenInfo.new(0.2), { CanvasPosition = SPECIAL_CANVAS_POSITION }):Play()
		end)
	)

	-- // Money Shop Stuff
	for _, CashFrame in CashHolder:GetChildren() do
		if not CashFrame:FindFirstChild("buy") then
			continue
		end
		local BuyButton = CashFrame.buy
		table.insert(
			self.Junk,
			Button(BuyButton, function()
				local Product = self:GetCashProductInfo(CashFrame.Name)
				if Product then
					MarketplaceService:PromptProductPurchase(LocalPlayer, Product.ProductId)
				end
			end)
		)
	end

	for _, GearFrame in GearsHolder:GetChildren() do
		if not GearFrame:FindFirstChild("buy") then
			continue
		end
		local BuyButton = GearFrame.buy
		table.insert(
			self.Junk,
			Button(BuyButton, function()
				local Product = Gamepasses[GearFrame.Name]
				if Product then
					MarketplaceService:PromptGamePassPurchase(LocalPlayer, Product.Id)
				end
			end)
		)
	end

	for _, Pass in PassesHolder:GetChildren() do
		if not Pass:FindFirstChild("buy") and not Pass:FindFirstChild("Buy") then
			continue
		end
		local BuyButton = Pass:FindFirstChild("buy") or Pass:FindFirstChild("Buy")
		table.insert(
			self.Junk,
			Button(BuyButton, function()
				local Product = Gamepasses[Pass.Name]
				if Product then
					MarketplaceService:PromptGamePassPurchase(LocalPlayer, Product.Id)
				end
			end)
		)
	end

	table.insert(
		self.Junk,
		Button(ScrollingFrame.Pack.Buy, function()
			local Product = Gamepasses["Starter Pack"]
			if Product then
				MarketplaceService:PromptGamePassPurchase(LocalPlayer, Product.Id)
			end
		end)
	)
	table.insert(
		self.Junk,
		Button(ScrollingFrame.Luck.Buy, function()
			if ReplicatedStorage.CurrentLuck.Value == 16 then
				return
			end
			local Product = Products[`x{CurrentLuck.Value * 2} Luck`]
			if Product then
				MarketplaceService:PromptProductPurchase(LocalPlayer, Product.ProductId)
			end
		end)
	)
end

function Shop:GetRobuxProductInfo(ProductId: number)
	local success, response = pcall(function()
		return MarketplaceService:GetProductInfo(ProductId, Enum.InfoType.Product)
	end)

	if success then
		return response
	end
end

function Shop:GetCashProductInfo(_Name: string)
	for Name, Product in Products do
		if string.find(Name, _Name) then
			return Product
		end
	end
end

function Shop:Stop()
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

return Shop
