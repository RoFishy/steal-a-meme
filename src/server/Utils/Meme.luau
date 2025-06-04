-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Modules
local Modules = ReplicatedStorage.Modules
local Spawns = require(Modules.Spawns)

-- // Objects
local SpawnsFolder = ReplicatedStorage.Spawns

-- // Init
local Meme = {}
Meme.__index = Meme

function Meme.new(Name: string, Type: string, SpawnLocation: Vector3) end

return Meme
