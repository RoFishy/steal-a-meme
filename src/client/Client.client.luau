-- // Start
local StartTime = os.clock()

-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- // Utils
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Loader = require(Modules.Loader)

-- // Folders
local Controllers = script.Parent:WaitForChild("Controllers")
print("-------[CLIENT]-------")

print("-- // Controllers")
Loader.Init(Controllers:GetChildren())
Loader.Start()

local DeltaTime = os.clock() - StartTime
print(("✅ | Client loading complete, took %.2f seconds"):format(DeltaTime))
