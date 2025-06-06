-- // Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // leaderstats
local leaderstats = LocalPlayer:WaitForChild("leaderstats")
local Rebirths = leaderstats.Rebirths
local Cash = leaderstats.Cash

-- // Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PurchaseTool = Remotes.PurchaseTool

-- // Util
local Button = require(script.Parent.Parent.Utils.Button)

-- // Module
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Tools = require(Modules.Tools)

local UIManager = require(script.Parent.Parent)

-- // UI
local MainUI = PlayerGui:WaitForChild("UI")
local ItemShopFrame = MainUI:WaitForChild("Frames"):WaitForChild("ItemShop")

local ItemHolder = ItemShopFrame.ScrollingFrame
local TemplateItem = ItemHolder.Template

local Top = ItemShopFrame.Top
local CloseButton = Top.close

-- // Init
local ToolShop = {}

function ToolShop.Init()
	ToolShop.Junk = {}
	ToolShop.PurchasedTools = {}
end

function ToolShop:Start()
	table.insert(
		self.Junk,
		Button(CloseButton, function()
			UIManager:CloseAllFrames()
		end)
	)

	self:SetupTools()
end

function ToolShop:GetToolIndex(Index: number)
	for Name, Info in Tools do
		if Info.LayoutOrder == Index then
			return Name, Info
		end
	end
end

function ToolShop:GetNumberOfTools()
	local Count = 0
	for _, _ in Tools do
		Count += 1
	end
	return Count
end

function ToolShop:SetupPurchaseButton(ToolName: string, _Button: ImageButton | TextButton)
	local btn
	btn = Button(_Button, function()
		if Cash.Value >= Tools[ToolName].Price then
			PurchaseTool:FireServer(ToolName)
			table.insert(self.PurchasedTools, ToolName)
			_Button.coins.Text = "Purchased"
			table.remove(self.Junk, table.find(self.Junk, btn))
			btn()
		else
			UIManager:ShowNotification(
				"You do not have enough cash to purchase this tool!",
				Color3.fromRGB(255, 0, 255)
			)
		end
	end)
	table.insert(self.Junk, btn)
end

function ToolShop:SetupTools()
	for i = 1, self:GetNumberOfTools() do
		local Name, Info = self:GetToolIndex(i)
		local ItemFrame = TemplateItem:Clone()
		ItemFrame.Name = Name
		ItemFrame.Parent = ItemHolder
		ItemFrame.LayoutOrder = Info.LayoutOrder

		ItemFrame.Title.Text = Name
		ItemFrame.Price.Text = "$" .. Info.Price
		ItemFrame.Description.Text = Info.Description
		ItemFrame.Icon.Image = Info.Image

		if Rebirths.Value < Info.RebirthsRequired then
			ItemFrame.RebirthOverlay.Visible = true
			ItemFrame.RebirthOverlay.TextLabel.Text = `{Info.RebirthsRequired} REBIRTH(S) REQUIRED`
		elseif table.find(self.PurchasedTools, Name) then
			ItemFrame.buy.coins.Text = "Purchased"
		else
			self:SetupPurchaseButton(Name, ItemFrame.buy)
		end
		ItemFrame.Visible = true
		local Tween = TweenService:Create(ItemFrame.UIScale, TweenInfo.new(0.2), { Scale = 1 })
		Tween:Play()
		Tween.Completed:Wait()
		table.insert(self.Junk, ItemFrame)
		i += 1
	end
end

function ToolShop:Stop()
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

return ToolShop
