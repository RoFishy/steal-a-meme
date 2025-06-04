-- // Start
local StartTime = os.clock()

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- // Utils
local Modules = ReplicatedStorage.Modules
local Loader = require(Modules.Loader)

-- // Folders
local Services = ServerScriptService.Services

print("-------[SERVER]-------")

print("-- // Services")
Loader.Init(Services:GetChildren())
Loader.Start()

local EndTime = os.clock() - StartTime
print(("✅ | Server loading complete, took %.2f seconds"):format(EndTime))
