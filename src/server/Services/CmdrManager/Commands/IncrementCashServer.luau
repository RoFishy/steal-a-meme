local DataUtil = require(script.Parent.Parent.Parent.Parent.Utils.DataUtil)

return function(_, Players: Player, Amount: number)
	for _, Player in Players do
		DataUtil:IncrementCash(Player, Amount)
	end
	return "Incremented Cash"
end
