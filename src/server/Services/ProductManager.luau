-- // Services
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

-- // Modules
local Modules = ReplicatedStorage.Modules
local Products = require(Modules.Products)

-- // Local Functions
local function GetProductNameById(ProductId: number)
	for Name, Data in Products do
		if Data.ProductId == ProductId then
			return Name
		end
	end
end

local function ProcessReceipt(ReceiptInfo: {
	PurchaseId: number,
	PlayerId: number,
	PlaceIdWherePurchased: number,
	CurrencySpent: number,
	CurrencyType: Enum.CurrencyType,
	ProductPurchaseChannel: Enum.ProductPurchaseChannel,
})
	local Product = Products[GetProductNameById(ReceiptInfo.ProductId)]
	if Product then
		Product.Callback(game.Players:GetPlayerByUserId(ReceiptInfo.PlayerId))
		local sound = SoundService.Success:Clone()
		sound.Parent = game.Players:GetPlayerByUserId(ReceiptInfo.PlayerId).Character.HumanoidRootPart
		sound:Play()
		task.delay(3, function()
			sound:Destroy()
		end)
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

-- // Module
local ProductManager = {}

function ProductManager:Start()
	MarketplaceService.ProcessReceipt = ProcessReceipt
end

return ProductManager
