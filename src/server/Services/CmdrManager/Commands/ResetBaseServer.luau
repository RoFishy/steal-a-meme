local BaseManager = require(script.Parent.Parent.Parent.BaseManager)

return function(_, Base: string)
	BaseManager:ResetBase(Base)
	return "Reset Base"
end
