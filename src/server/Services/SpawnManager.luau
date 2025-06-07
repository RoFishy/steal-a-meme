-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- // Modules
local Modules = ReplicatedStorage.Modules
local Spawns = require(Modules.Spawns)

-- // Remotes
local Remotes = ReplicatedStorage.Remotes
local ShowNotification = Remotes.ShowNotification

-- // Utils
local Utils = script.Parent.Parent.Utils
local Meme = require(Utils.Meme)
local Signals = require(Utils.Signals)

-- // Objects
local ConveyorSystem = workspace.ConveyorSystem

local StartPart = ConveyorSystem.Spawn
local EndPart = ConveyorSystem.End

local TimersScreen = workspace.Spawn.Timers.Screen

local GuaranteedRequirements = {
	Mythical = 900,
	Legendary = 300,
	Omega = 1800,
	["SECRET???"] = 3600,
}

-- // Const
local SPAWN_INTERVAL = 3

-- // Variables
local CurrentMemes = {}
local CurrentServerLuck = 1
local CurrentRarity = nil

-- // local function
local function IndexDictionary(Dictionary, Index)
	local i = 0
	for _, value in pairs(Dictionary) do
		i = i + 1
		if i == Index then
			return value
		end
	end
end

local function GetDictionaryLength(Dictionary)
	local counter = 0
	for _, _ in pairs(Dictionary) do
		counter = counter + 1
	end
	return counter
end

local function GetNameFromValue(Dictionary, Value)
	for key, value in pairs(Dictionary) do
		if value == Value then
			return key
		end
	end
end

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

-- // Init
local SpawnManager = {}

function SpawnManager.Init()
	SpawnManager.Sum = 0

	for _, v in pairs(Spawns) do
		SpawnManager.Sum += v.Rarity
	end
end

function SpawnManager:Start()
	EndPart.Touched:Connect(function(Hit)
		if not Hit.Parent then
			return
		end
		if Hit.Parent:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(Hit.Parent) then
			local Id = Hit.Parent:GetAttribute("ID")
			CurrentMemes[Id]:Destroy()
			CurrentMemes[Id] = nil
		end
	end)

	Signals.IncreaseServerLuck:Connect(function()
		CurrentServerLuck *= 2
	end)
	Signals.ResetServerLuck:Connect(function()
		CurrentServerLuck = 1
	end)

	for Name, DropTime in GuaranteedRequirements do
		local TextLabel = TimersScreen[Name].SurfaceGui.timer
		local Time = DropTime
		task.spawn(function()
			while task.wait() do
				while Time > 0 do
					TextLabel.Text = `Guaranteed {Name} in: {convertToMS(Time)}`
					task.wait(1)
					Time -= 1
				end
				TextLabel.Text = `Guaranteed {Name} dropping NOW!`
				repeat
					task.wait()
				until not CurrentRarity
				CurrentRarity = Name
				task.wait(2)
				Time = DropTime
			end
		end)
	end

	while task.wait(SPAWN_INTERVAL) do
		local Rarity = CurrentRarity or self:GetRandomRarity(CurrentServerLuck)
		CurrentRarity = nil
		--local Rarity = "Common"
		local RandomSpawn =
			IndexDictionary(Spawns[Rarity]["Spawns"], math.random(1, GetDictionaryLength(Spawns[Rarity]["Spawns"])))

		local ModelId = HttpService:GenerateGUID(false)
		CurrentMemes[ModelId] =
			Meme.new(GetNameFromValue(Spawns[Rarity]["Spawns"], RandomSpawn), Rarity, StartPart.CFrame)
		CurrentMemes[ModelId].Model:SetAttribute("ID", ModelId)

		if Rarity == "Mythical" or Rarity == "Omega" or Rarity == "SECRET???" then
			ShowNotification:FireAllClients(`A {Rarity} Meme has spawned!`, Color3.fromRGB(255, 230, 0))
		end
	end
end

function SpawnManager:GetCurrentMemes()
	return CurrentMemes
end

function SpawnManager:GetRandomRarity(LuckMultiplier: number?)
	LuckMultiplier = LuckMultiplier or 1
	local adjustedSpawns = {}
	for name, value in pairs(Spawns) do
		adjustedSpawns[name] = {
			Rarity = value.Rarity,
			Spawns = value.Spawns,
		}

		if name == "Rare" then
			adjustedSpawns[name].Rarity = value.Rarity * math.min(LuckMultiplier, 2)
		elseif name == "Mythical" then
			adjustedSpawns[name].Rarity = value.Rarity * LuckMultiplier
		elseif name == "Omega" or name == "SECRET???" then
			adjustedSpawns[name].Rarity = value.Rarity * (LuckMultiplier * 1.5)
		end
	end

	local adjustedSum = 0
	for _, value in pairs(adjustedSpawns) do
		adjustedSum = adjustedSum + value.Rarity
	end

	local RandomNumber = math.random(adjustedSum)
	for Name, Value in pairs(adjustedSpawns) do
		if RandomNumber <= Value.Rarity then
			return Name
		else
			RandomNumber = RandomNumber - Value.Rarity
		end
	end
end

return SpawnManager
