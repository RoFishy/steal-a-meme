return function(registry)
	registry:RegisterType("weatherEvent", registry.Cmdr.Util.MakeEnumType("Weather Event", { "Flaming" }))
end
