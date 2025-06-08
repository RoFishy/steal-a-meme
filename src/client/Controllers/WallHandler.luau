-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- // Player
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- // Modules
local Modules = ReplicatedStorage:WaitForChild("Modules")
local DistanceFade = require(Modules.DistanceFade)

-- // Objects
local Barriers = workspace:WaitForChild("Barriers")

-- // Settings
local Settings = {
	["DistanceOuter"] = 32,
	["DistanceInner"] = 16,
	["EffectRadius"] = 8,
	["EffectRadiusMin"] = 4,
	["EdgeDistanceCalculations"] = true,
	["Texture"] = "rbxassetid://1508034221",
	["TextureTransparency"] = 0.1,
	["BackgroundTransparency"] = 0.8,
	["TextureColor"] = Color3.fromRGB(112, 112, 112),
	["BackgroundColor"] = Color3.fromRGB(0, 0, 0),
	["TextureSize"] = Vector2.new(5, 4),
	["TextureOffset"] = Vector2.new(0, 0.5),
	["Brightness"] = 1,
}

local baseOffsetsX = {
	["1"] = -3,
	["2"] = -2,
	["3"] = -1,
	["4"] = 0,
	["5"] = 1,
	["6"] = 2,
	["7"] = 3,
}

-- // Wall Handler
local WallHandler = {}

function WallHandler.Init()
	WallHandler.Fade = DistanceFade.new()
	WallHandler.Fade:UpdateSettings(Settings)
	WallHandler.Parts = {}
end

function WallHandler:Start()
	task.wait(2)
	for _, Part in Barriers:GetChildren() do
		table.insert(self.Parts, Part)
		self.Fade:AddFace(Part, Enum.NormalId.Right)
		self.Fade:AddFace(Part, Enum.NormalId.Left)
	end

	local TweenValue = Instance.new("Vector3Value")
	TweenValue.Parent = script

	TweenService:Create(
		TweenValue,
		TweenInfo.new(6, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false),
		{ Value = Vector3.new(-6, 5.5) }
	):Play()

	local connection
	connection = RunService.Heartbeat:Connect(function(_)
		if not Character then
			connection:Disconnect()
			return
		end

		for _, v in self.Parts do
			local offsetX = baseOffsetsX[v.Name]
			local offsetY = TweenValue.Value.Y
			local newOffset = offsetX
			if offsetX then
				newOffset = -offsetX
			end
			self.Fade:UpdateFaceSettings(v, Enum.NormalId.Right, { ["TextureOffset"] = Vector2.new(offsetX, offsetY) })
			self.Fade:UpdateFaceSettings(v, Enum.NormalId.Left, { ["TextureOffset"] = Vector2.new(newOffset, offsetY) })
		end

		self.Fade:Step()
	end)
end

return WallHandler
