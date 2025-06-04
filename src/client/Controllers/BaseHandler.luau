-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- // Player
local LocalPlayer = Players.LocalPlayer

-- // Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local SetupBaseDisplay = Remotes.SetupBaseDisplay

-- // Objects
local BasesFolder = workspace:WaitForChild("Bases")

-- // Init
local BaseHandler = {}

function BaseHandler:Start()
	SetupBaseDisplay.OnClientEvent:Connect(function(BaseName: string)
		local Base = BasesFolder:FindFirstChild(BaseName)
		if Base then
			local Components = Base.Components
			local Display = Components.Display
			local MainDisplayGui = Display.Attachment.Billboard
			MainDisplayGui.Enabled = true

			local Thumbnail = Players:GetUserThumbnailAsync(
				LocalPlayer.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size420x420
			)
			MainDisplayGui.Frame.ImageLabel.Image = Thumbnail
		end
	end)
end

return BaseHandler
