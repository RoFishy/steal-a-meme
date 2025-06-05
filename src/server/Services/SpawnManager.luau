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

-- // Objects
local ConveyorSystem = workspace.ConveyorSystem

local StartPart = ConveyorSystem.Spawn
local EndPart = ConveyorSystem.End

-- // Const
local SPAWN_INTERVAL = 3

-- // Variables
local CurrentMemes = {}

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

	while task.wait(SPAWN_INTERVAL) do
		local Rarity = self:GetRandomRarity()
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

function SpawnManager:GetRandomRarity()
	local RandomNumber = math.random(self.Sum)
	for Name, Value in pairs(Spawns) do
		if RandomNumber <= Value.Rarity then
			return Name
		else
			RandomNumber -= Value.Rarity
		end
	end
end

return SpawnManager
