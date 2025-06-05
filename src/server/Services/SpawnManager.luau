-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- // Modules
local Modules = ReplicatedStorage.Modules
local Spawns = require(Modules.Spawns)

-- // Utils
local Utils = script.Parent.Parent.Utils
local Meme = require(Utils.Meme)

-- // Objects
local ConveyorSystem = workspace.ConveyorSystem

local StartPart = ConveyorSystem.Spawn
local EndPart = ConveyorSystem.End

-- // Const
local SPAWN_INTERVAL = 1

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

function SpawnManager:Start()
	EndPart.Touched:Connect(function(Hit)
		if not Hit.Parent then
			return
		end
		if Hit.Parent:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(Hit.Parent) then
			Hit.Parent:Destroy()
		end
	end)

	while task.wait(SPAWN_INTERVAL) do
		--local rarity = self:GetRandomRarity()
		local Rarity = "Common"
		local RandomSpawn =
			IndexDictionary(Spawns[Rarity]["Spawns"], math.random(1, GetDictionaryLength(Spawns[Rarity]["Spawns"])))

		Meme.new(GetNameFromValue(Spawns[Rarity]["Spawns"], RandomSpawn), Rarity, StartPart.CFrame)
	end
end

function SpawnManager:GetRandomRarity()
	local RandomNumber = math.random(1, 1000)
	if RandomNumber >= 500 then
		return "Common"
	elseif RandomNumber >= 300 then
		return "Rare"
	elseif RandomNumber >= 100 then
		return "Epic"
	elseif RandomNumber >= 50 then
		return "Legendary"
	elseif RandomNumber >= 30 then
		return "Mythic"
	elseif RandomNumber >= 15 then
		return "Omega"
	else
		return "SECRET???"
	end
end

return SpawnManager
