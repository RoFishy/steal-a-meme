-- // Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

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

-- // Const
local SPECIAL_CANVAS_POSITION = Vector2.new(0, 0)
local GEARS_CANVAS_POSITION = Vector2.new(0, 300)
local PASSES_CANVAS_POSITION = Vector2.new(0, 580)
local MONEY_CANVAS_POSITION = Vector2.new(0, 1055.574)

-- // Luck stuff
local CurrentLuck = ReplicatedStorage.CurrentLuck

-- // UI
local MainUI = PlayerGui:WaitForChild("UI")
local ShopFrame = MainUI:WaitForChild("Frames"):WaitForChild("Shop")

local ScrollingFrame = ShopFrame.ScrollingFrame
local CashHolder = ScrollingFrame.Cash.holder
local GearsHolder = ScrollingFrame.Gears.holder
local PassesHolder = ScrollingFrame.Passes.holder

local CloseButton = ShopFrame.Top.close

-- // Init
local Shop = {}

function Shop.Init()
	Shop.Junk = {}

	CurrentLuck:GetPropertyChangedSignal("Value"):Connect(function()
		local info = Shop:GetRobuxProductInfo(Products[`x{CurrentLuck.Value * 2} Luck`].ProductId)
		if CurrentLuck.Value == 16 then
			ScrollingFrame.Luck.before.Text = "MAX"
			ScrollingFrame.Luck.after.Text = "MAX"
			ScrollingFrame.Luck.buy.price.Text = "MAX"
			return
		end
		ScrollingFrame.Luck.Buy.price.Text = "" .. info.PriceInRobux
		ScrollingFrame.Luck.before.Text = tostring(CurrentLuck.Value) .. "x"
		ScrollingFrame.Luck.after.Text = tostring(CurrentLuck.Value * 2) .. "x"
	end)
end

function Shop:Start()
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
