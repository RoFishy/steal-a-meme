-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local MarketplaceService = game:GetService("MarketplaceService")
--local StarterGui = game:GetService("StarterGui")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local leaderstats = LocalPlayer:WaitForChild("leaderstats")
local Cash = leaderstats.Cash

local Camera = workspace.CurrentCamera

-- // obj
local Objects = ReplicatedStorage:WaitForChild("Objects")
local Beam = Objects.Beam

-- // Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local ShowNotification = Remotes.ShowNotification

local ShowTutorialFrame = Remotes.ShowTutorialFrame
local HideTutorialFrame = Remotes.HideTutorialFrame

local ShowBeam = Remotes.ShowBeam
local HideBeam = Remotes.HideBeam

-- // Luck stuff
local CurrentLuck = ReplicatedStorage.CurrentLuck
local LuckTime = ReplicatedStorage.LuckTime

-- // Types
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Types = require(Modules.Types)
local Gamepasses = require(Modules.Gamepasses)
local Products = require(Modules.Products)

-- // Utils
local Utils = script.Parent.Utils
local Signals = require(Utils.Signals)

-- // Lighting
local Blur = Lighting:WaitForChild("Blur")

-- // GUI
local MainUI = PlayerGui:WaitForChild("UI")

local HUD = MainUI:WaitForChild("Hud")

local Top = HUD.Top
local TpButton = Top.Tp

local LeftButtons = HUD.Left
local ShopButton = LeftButtons.Shop
local RebirthButton = LeftButtons.Rebirth
local IndexButton = LeftButtons.Index

local RightButtons = HUD.Right
local FreeButton = RightButtons.Free
local InviteButton = RightButtons.Invite

local StatsHolder = HUD.Stats
local CashLabel = StatsHolder.coins
local LuckLabel = StatsHolder.luck

local MusicButton = HUD.Music

local Frames = MainUI:WaitForChild("Frames")

local MiscUI = MainUI:WaitForChild("Misc")
local BlackFrame = MiscUI.Black
local NotificationHolder = MiscUI.NotificationHolder
local NotificationTemplate = NotificationHolder.NotificationTemplate

local DialogueList = MiscUI:WaitForChild("DialogueList")
local DialogueOptionTemplate = MiscUI:WaitForChild("DialogueOptionTemplate")

local TutorialFrame = HUD.Tutorial

-- // Utils
local UIUtils = script.Utils
local Button = require(UIUtils.Button)

local FrameModules = script.Frames

-- // Constants
local DEFAULT_FOV = 70
local ZOOMED_IN_FOV = 50
--local MAX_RETRIES = 8

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

local function Format(Int)
	return string.format("%02i", Int)
end

local function convertToMS(Seconds)
	local Minutes = (Seconds - Seconds % 60) / 60
	Seconds = Seconds - Minutes * 60
	local Hours = (Minutes - Minutes % 60) / 60
	Minutes = Minutes - Hours * 60
	return Format(Minutes) .. ":" .. Format(Seconds)
end

--[[
function coreCall(method, ...)
	local result = {}
	for _ = 1, MAX_RETRIES do
		result = { pcall(StarterGui[method], StarterGui, ...) }
		if result[1] then
			break
		end
		RunService.Stepped:Wait()
	end
	return unpack(result)
end
]]
--

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
	Button(FreeButton, function()
		UIHandler:OpenFrame("Free")
	end)
	Button(InviteButton, function()
		if SocialService:CanSendCallInviteAsync(LocalPlayer) then
			SocialService:PromptGameInvite(LocalPlayer)
		end
	end)
	Button(HUD.Starter, function()
		MarketplaceService:PromptGamePassPurchase(LocalPlayer, Gamepasses["Starter Pack"].Id)
	end)
	Button(TpButton, function()
		MarketplaceService:PromptProductPurchase(LocalPlayer, Products["Teleport To Base"].ProductId)
	end)
end

function UIHandler:Start()
	--coreCall("SetCore", "ResetButtonCallback", false)

	Remotes.CloseAllFrames.OnClientEvent:Connect(function()
		self:CloseAllFrames()
	end)

	-- // signals
	Signals.ToggleNPCDialogue:Connect(function(Options: Types.NPCDialogueOptions)
		self:ToggleNPCDialogue(Options)
	end)

	-- // UI stroke stuff
	self:SetupUIStrokes()
	PlayerGui.DescendantAdded:Connect(function(Child)
		if Child:IsA("UIStroke") then
			table.insert(UIStrokes, Child)
		end
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
		Color = Color or Color3.fromRGB(255, 255, 255)
		self:ShowNotification(Text, Color)
	end)

	-- // tutorial
	ShowTutorialFrame.OnClientEvent:Connect(function(Text: string)
		TutorialFrame.Visible = true
		TutorialFrame.desc.Text = Text
		TweenService:Create(TutorialFrame.UIScale, TweenInfo.new(0.3), { Scale = 1 }):Play()
	end)
	HideTutorialFrame.OnClientEvent:Connect(function()
		TweenService:Create(TutorialFrame.UIScale, TweenInfo.new(0.3), { Scale = 0 }):Play()
		task.wait(0.3)
		TutorialFrame.Visible = false
	end)

	local currentBeamStuff = {}
	ShowBeam.OnClientEvent:Connect(function(part1, part2)
		local BeamClone = Beam:Clone()
		BeamClone.Parent = part1
		local a0, a1 = Instance.new("Attachment"), Instance.new("Attachment")
		a0.Parent = part1
		a1.Parent = part2
		BeamClone.Attachment0 = a0
		BeamClone.Attachment1 = a1
		table.insert(currentBeamStuff, BeamClone)
		table.insert(currentBeamStuff, a0)
		table.insert(currentBeamStuff, a1)
	end)
	HideBeam.OnClientEvent:Connect(function()
		for _, v in currentBeamStuff do
			v:Destroy()
		end
	end)

	Button(TutorialFrame.close, function()
		TweenService:Create(TutorialFrame.UIScale, TweenInfo.new(0.3), { Scale = 0 }):Play()
		task.wait(0.3)
		TutorialFrame.Visible = false
	end)

	-- // Luck stuff
	LuckLabel.Visible = false
	StatsHolder.luckimg.Visible = false
	LuckTime:GetPropertyChangedSignal("Value"):Connect(function()
		if LuckTime.Value > 0 then
			StatsHolder.luckimg.Visible = true
			LuckLabel.Visible = true
			local Time = convertToMS(LuckTime.Value)
			LuckLabel.Text = `x{tostring(CurrentLuck.Value)} Server Luck: {Time}`
		else
			StatsHolder.luckimg.Visible = false
			LuckLabel.Visible = false
		end
	end)

	-- // music
	local musicOn = true
	Button(MusicButton, function()
		local Music = workspace.Music
		if musicOn then
			musicOn = false
			Music.Volume = 0
		else
			musicOn = true
			Music.Volume = 0.3
		end
	end)

	-- // e
	RunService.RenderStepped:Connect(function()
		self:HandleUIStroke()
	end)
end

function UIHandler:ToggleNPCDialogue(Options: Types.NPCDialogueOptions)
	for Number, Option in Options do
		local OptionFrame = DialogueOptionTemplate:Clone()
		OptionFrame.Number.Text = "#" .. tostring(Number)
		OptionFrame.Text.Text = Option.Option
		OptionFrame.Visible = true
		OptionFrame.Parent = DialogueList

		Button(OptionFrame, function()
			self:NPCDialogueHandler(Option)
		end)

		local UIScale = OptionFrame:WaitForChild("UIScale")
		UIScale.Scale = 0
		local Tween = TweenService:Create(UIScale, TweenInfo.new(0.2), { Scale = 1 })
		Tween:Play()
		Tween.Completed:Wait()
	end
end

function UIHandler:NPCDialogueHandler(Option: Types.NPCDialogueOption)
	for _, OptionFrame in DialogueList:GetChildren() do
		if not OptionFrame:IsA("Frame") then
			continue
		end
		OptionFrame:Destroy()
	end
	if Option.Callback then
		Option.Callback()
	end
	TweenService:Create(Camera, TweenInfo.new(0.2), { FieldOfView = DEFAULT_FOV }):Play()
	Signals.NPCInteractionEnded:Fire()
end

function UIHandler:ShowNotification(Text: string, Color: Color3?)
	for _, Notification in NotificationHolder:GetChildren() do
		if not Notification:IsA("TextLabel") then
			continue
		end
		if Notification.Text == Text or string.find(Notification.Text, Text) then
			local CurrentIndex = tonumber(Notification.Name)
			CurrentIndex += 1
			Notification.Text = `{Text} ({CurrentIndex})`
			Notification.Name = tostring(CurrentIndex)
			return
		end
	end

	local NotificationClone: TextLabel = NotificationTemplate:Clone()
	NotificationClone.Parent = NotificationHolder
	NotificationClone.Text = Text
	NotificationClone.Visible = true
	NotificationClone.TextColor3 = Color or Color3.fromRGB(255, 255, 255)
	NotificationClone.Name = "0"

	TweenService:Create(NotificationClone.UIScale, TweenInfo.new(0.1), { Scale = 1 }):Play()

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
			Signals.ClosedFrame:Fire()
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
