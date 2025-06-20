-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

-- // Events
local Remotes = ReplicatedStorage.Remotes
local ShowNotification = Remotes.ShowNotification

-- // obj
local MainLighting = Lighting.Main
local WeatherValues = ReplicatedStorage.WeatherEvents

-- // Const
local WEATHER_EVENTS = {
	Flaming = {
		Duration = 600, -- lasts for this duration
		Interval = 3600, -- happens every 1 hour
		Color = Color3.fromRGB(255, 0, 0), -- color of the notification and shi
		SoundId = 8406997653, -- Sound that will play when the event starts
	},
}

-- // Local Functions
function Format(Int)
	return string.format("%02i", Int)
end

function convertToMS(Seconds)
	local Minutes = (Seconds - Seconds % 60) / 60
	Seconds = Seconds - Minutes * 60
	local Hours = (Minutes - Minutes % 60) / 60
	Minutes = Minutes - Hours * 60
	return `{Format(Minutes)}m {Seconds}s`
end

-- // Init
local WeatherManager = {}

function WeatherManager.Init()
	WeatherManager:ResetLighting()
	WeatherManager:SetDefaultLighting()
end

function WeatherManager:Start()
	for Name, Event in WEATHER_EVENTS do
		local EventValues = WeatherValues:FindFirstChild(Name)
		assert(EventValues, "Event values not found")
		task.spawn(function()
			while true do
				local TimerString = EventValues.TimerString

				EventValues.StartingIn.Value = Event.Interval
				while EventValues.StartingIn.Value > 0 do
					task.wait(1)
					EventValues.StartingIn.Value -= 1
					TimerString.Value = convertToMS(EventValues.StartingIn.Value)
				end

				TimerString.Value = ""
				EventValues.Active.Value = true
				EventValues.TimeLeft.Value = Event.Duration

				self:SetLighting(Name)
				task.spawn(function()
					local Sound = Instance.new("Sound")
					Sound.Parent = workspace
					Sound.SoundId = "rbxassetid://" .. Event.SoundId
					Sound.Volume = 1.5
					Sound:Play()
					Sound.Ended:Once(function()
						Sound:Destroy()
					end)
				end)
				ShowNotification:FireAllClients(`The {Name} event has started!`, Event.Color)

				while EventValues.TimeLeft.Value > 0 do
					task.wait(1)
					EventValues.TimeLeft.Value -= 1
				end
				EventValues.Active.Values = false
				ShowNotification:FireAllClients(`The {Name} event has ended!`)
			end
		end)
	end
end

function WeatherManager:ResetLighting()
	for _, Item in Lighting:GetChildren() do
		if Item:IsA("Folder") then
			continue
		end
		Item:Destroy()
	end
end

function WeatherManager:SetDefaultLighting()
	for _, Item in MainLighting:GetChildren() do
		Item:Clone().Parent = Lighting
	end
end

function WeatherManager:SetLighting(Event: string)
	local LightingFolder = Lighting:FindFirstChild(Event)
	assert(LightingFolder, "Lighting folder not found")

	self:ResetLighting()

	for _, Item in LightingFolder:GetChildren() do
		if Item:IsA("Folder") then
			continue
		end
		Item:Clone().Parent = Lighting
	end
end

return WeatherManager
