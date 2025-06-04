-- // Init
local Loader = {}
local CachedModules = {}

-- // Functions
function Loader.Init(Scripts: { ModuleScript })
	for _, Module in Scripts do
		local StartTime = os.clock()
		if not Module:IsA("ModuleScript") then
			continue
		end
		local LoadedModule = require(Module)
		CachedModules[Module.Name] = LoadedModule
		if LoadedModule.Init then
			task.spawn(LoadedModule.Init)
		end
		local EndTime = os.clock() - StartTime
		print(("[%.2fms] %s Initialized"):format(EndTime, Module.Name))
	end
end

function Loader.Start()
	for Name, Module in CachedModules do
		local StartTime = os.clock()
		task.spawn(function()
			Module:Start()
		end)
		local EndTime = os.clock() - StartTime
		print(("[%.2fms] %s Started"):format(EndTime, Name))
	end
end

return Loader
