-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local leaderstats = LocalPlayer:WaitForChild("leaderstats")
local Cash = leaderstats.Cash

local Camera = workspace.CurrentCamera

-- // Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ShowNotification = Remotes.ShowNotification

-- // Lighting
local Blur = Lighting:WaitForChild("Blur")

-- // GUI
local MainUI = PlayerGui:WaitForChild("UI")

local HUD = MainUI:WaitForChild("Hud")

local LeftButtons = HUD.Left
local ShopButton = LeftButtons.Shop
local RebirthButton = LeftButtons.Rebirth
local IndexButton = LeftButtons.Index

local StatsHolder = HUD.Stats
local CashLabel = StatsHolder.coins

local Frames = MainUI:WaitForChild("Frames")

local MiscUI = MainUI:WaitForChild("Misc")
local BlackFrame = MiscUI.Black
local NotificationHolder = MiscUI.NotificationHolder
local NotificationTemplate = NotificationHolder.NotificationTemplate

-- // Utils
local Utils = script.Utils
local Button = require(Utils.Button)

local FrameModules = script.Frames

-- // Constants
local DEFAULT_FOV = 70
local ZOOMED_IN_FOV = 50

-- // Vars
local Debounce = false
local UIStrokes = {}

-- // Local Functions
local function FormatCash(Amount: number): string
	local formatted = Amount
	while true do
		local k
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then
			break
		end
	end
	return formatted
end

-- // Init
local UIHandler = {}

function UIHandler.Init()
	Button(ShopButton, function()
		UIHandler:OpenFrame("Shop")
	end)
	Button(RebirthButton, function()
		UIHandler:OpenFrame("Rebirth")
	end)
	Button(IndexButton, function()
		UIHandler:OpenFrame("Index")
	end)
end

function UIHandler:Start()
	-- // UI stroke stuff
	self:SetupUIStrokes()
	PlayerGui.DescendantAdded:Connect(function(Child)
		if Child:IsA("UIStroke") then
			table.insert(UIStrokes, Child)
		end
	end)
	RunService.RenderStepped:Connect(function()
		self:HandleUIStroke()
	end)

	-- // Frames initializer
	for _, FrameModule in FrameModules:GetChildren() do
		local Frame = require(FrameModule)
		if Frame.Init then
			task.spawn(Frame.Init)
		end
	end

	-- // Cash updater
	self:UpdateCash()
	Cash:GetPropertyChangedSignal("Value"):Connect(function()
		self:UpdateCash()
	end)

	-- // Remotes
	ShowNotification.OnClientEvent:Connect(function(Text: string, Color: Color3?)
		self:ShowNotification(Text, Color)
	end)
end

function UIHandler:ShowNotification(Text: string, Color: Color3?)
	for _, Notification in NotificationHolder:GetChildren() do
		if not Notification:IsA("TextLabel") then
			continue
		end
		if Notification.Text == Text then
			local CurrentIndex = tonumber(Notification.Name)
			CurrentIndex += 1
			Notification.Text = `{Text} ({CurrentIndex})`
			Notification.Name = tostring(CurrentIndex)
		end
	end

	local NotificationClone: TextLabel = NotificationTemplate:Clone()
	NotificationClone.Parent = NotificationHolder
	NotificationClone.Text = Text
	NotificationClone.Visible = true
	NotificationClone.TextColor3 = Color or Color3.fromRGB(255, 255, 255)
	NotificationClone.Name = "0"

	TweenService:Create(NotificationClone.UIScale, TweenInfo.new(0.2), { Scale = 1 }):Play()

	task.delay(5, function()
		TweenService:Create(NotificationClone.UIScale, TweenInfo.new(0.2), { Scale = 0 }):Play()
		task.wait(0.2)
		NotificationClone:Destroy()
	end)
end

function UIHandler:UpdateCash()
	local CurrentCash = Cash.Value
	CashLabel.Text = `${FormatCash(CurrentCash)}`
end

function UIHandler:SetupUIStrokes()
	for _, Object in PlayerGui:GetDescendants() do
		if Object:IsA("UIStroke") then
			table.insert(UIStrokes, Object)
		end
	end
end

function UIHandler:HandleUIStroke()
	for _, UIStroke in UIStrokes do
		if not UIStroke:GetAttribute("DefaultThickness") then
			UIStroke:SetAttribute("DefaultThickness", UIStroke.Thickness)
		end
		local Thickness = UIStroke:GetAttribute("DefaultThickness")

		UIStroke.Thickness = Camera.ViewportSize.Magnitude / 1800 * Thickness
	end
end

function UIHandler:OpenFrame(Frame: string)
	if Debounce == true then
		return
	end
	for _, _Frame in Frames:GetChildren() do
		if _Frame.Visible == true and _Frame.Name ~= Frame then
			self:CloseAllFrames()
		end
	end

	Debounce = true
	TweenService:Create(Blur, TweenInfo.new(0.4), { Size = 25 }):Play()
	TweenService:Create(BlackFrame, TweenInfo.new(0.4), { BackgroundTransparency = 0.4 }):Play()
	TweenService:Create(Camera, TweenInfo.new(0.4), { FieldOfView = ZOOMED_IN_FOV }):Play()

	Frame = Frames:FindFirstChild(Frame) :: Frame
	if Frame then
		if Frame.Visible == true then
			Debounce = false
			self:CloseAllFrames()
			return
		else
			self:CloseAllFrames()
		end
		local FrameModule = FrameModules:FindFirstChild(Frame.Name)
		local OriginalPosition = Frame.Position
		Frame.Position = Frame.Position + UDim2.fromScale(0, 0.5)
		Frame.Visible = true
		TweenService:Create(Frame, TweenInfo.new(0.2), { Position = OriginalPosition }):Play()
		if FrameModule then
			FrameModule = require(FrameModule)
			FrameModule:Start()
		end
		Debounce = false
	else
		print("No frame found!")
		return
	end
end

function UIHandler:CloseAllFrames()
	if Debounce == true then
		return
	end
	Debounce = true
	for _, Frame in Frames:GetChildren() do
		if Frame.Visible == true then
			local OriginalPosition = Frame.Position
			local OutTween = TweenService:Create(
				Frame,
				TweenInfo.new(0.2),
				{ Position = OriginalPosition + UDim2.fromScale(0, 0.5) }
			)
			TweenService:Create(Camera, TweenInfo.new(0.2), { FieldOfView = DEFAULT_FOV }):Play()
			TweenService:Create(Blur, TweenInfo.new(0.2), { Size = 0 }):Play()
			TweenService:Create(BlackFrame, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play()
			OutTween:Play()
			OutTween.Completed:Wait()
			Frame.Visible = false
			Frame.Position = OriginalPosition
			Debounce = false
			local FrameModule = FrameModules:FindFirstChild(Frame.Name)
			if FrameModule then
				FrameModule = require(FrameModule)
				FrameModule:Stop()
			end
		else
			continue
		end
	end
end

return UIHandler
