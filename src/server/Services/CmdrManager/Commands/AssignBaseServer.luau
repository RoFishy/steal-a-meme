local BaseManager = require(script.Parent.Parent.Parent.BaseManager)

return function(_, Players: Player, Base: string)
	for _, Player in Players do
		BaseManager:AssignBase(Player, Base)
	end
	return "Assigned Base"
end
