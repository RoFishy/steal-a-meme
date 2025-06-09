-- // Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

-- // Modules
local Modules = ReplicatedStorage.Modules
local Gamepasses = require(Modules.Gamepasses)

-- // Init
local PassManager = {}

function PassManager:Start()
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(
		function(Player: Player, GamePassId: number, Success: boolean)
			if Success then
				if not MarketplaceService:UserOwnsGamePassAsync(Player.UserId, GamePassId) then
					if not RunService:IsStudio() then
						return
					end
				end
				for _, Data in Gamepasses do
					if GamePassId == Data.Id then
						Data.Callback(Player)
						local sound = SoundService.Success:Clone()
						sound.Parent = Player.Character.HumanoidRootPart
						sound:Play()
						task.delay(3, function()
							sound:Destroy()
						end)
					end
				end
			end
		end
	)
end

function PassManager:LoadPlayerPasses(Player: Player)
	for _, Data in Gamepasses do
		if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, Data.Id) or Player.Name == "xRo_Fishy" then
			Data.Callback(Player)
		end
	end
end

return PassManager
