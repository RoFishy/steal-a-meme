local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WeatherEventsFolder = ReplicatedStorage.WeatherEvents

return function(_, Event: string)
	local EventFolder = WeatherEventsFolder:FindFirstChild(Event)
	if EventFolder then
		EventFolder.StartingIn.Value = 0
	end
	return "Set weather event"
end
