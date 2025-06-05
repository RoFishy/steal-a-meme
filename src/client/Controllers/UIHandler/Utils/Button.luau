-- // Services
local TweenService = game:GetService("TweenService")

-- // Constants
local MOUSE_HOVER_SCALE = 1.15
local MOUSE_DOWN_SCALE = 0.8

-- // ButtonClass
local function ButtonHandler(Button: ImageButton | TextButton | Frame, Callback: () -> ()?)
	local ButtonConnections = {}

	local UIScale = Instance.new("UIScale")
	UIScale.Parent = Button

	table.insert(
		ButtonConnections,
		Button.Destroying:Connect(function()
			for _, Connection in ButtonConnections do
				Connection:Disconnect()
			end
		end)
	)

	if Button:IsA("Frame") then
		Button = Button:FindFirstChildOfClass("TextButton" or "ImageButton")
	end

	table.insert(
		ButtonConnections,
		Button.MouseEnter:Connect(function()
			TweenService:Create(UIScale, TweenInfo.new(0.2), { Scale = MOUSE_HOVER_SCALE }):Play()
		end)
	)
	table.insert(
		ButtonConnections,
		Button.MouseLeave:Connect(function()
			TweenService:Create(UIScale, TweenInfo.new(0.2), { Scale = 1 }):Play()
		end)
	)
	table.insert(
		ButtonConnections,
		Button.MouseButton1Down:Connect(function()
			TweenService:Create(UIScale, TweenInfo.new(0.2), { Scale = MOUSE_DOWN_SCALE }):Play()
		end)
	)
	table.insert(
		ButtonConnections,
		Button.MouseButton1Up:Connect(function()
			TweenService:Create(UIScale, TweenInfo.new(0.2), { Scale = MOUSE_HOVER_SCALE }):Play()
		end)
	)

	if Callback then
		table.insert(
			ButtonConnections,
			Button.MouseButton1Click:Connect(function()
				task.wait(0.15)
				Callback()
			end)
		)
	end

	return function()
		UIScale:Destroy()
		for _, Connection in ButtonConnections do
			Connection:Disconnect()
		end
	end
end

return ButtonHandler
