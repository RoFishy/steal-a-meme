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
local GEARS_CANVAS_POSITION = Vector2.new(0, 305)
local PASSES_CANVAS_POSITION = Vector2.new(0, 600)
local MONEY_CANVAS_POSITION = Vector2.new(0, 1055.574)

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
