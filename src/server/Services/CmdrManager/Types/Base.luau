return function(registry)
	registry:RegisterType(
		"base",
		registry.Cmdr.Util.MakeEnumType(
			"Base",
			{ "Base1", "Base2", "Base3", "Base4", "Base5", "Base6", "Base7", "Base8" }
		)
	)
end
