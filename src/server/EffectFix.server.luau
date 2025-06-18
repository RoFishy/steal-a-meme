if game.TextChatService:FindFirstChild("Folder") then
	if game.TextChatService.Folder:FindFirstChild("Music") then
		game.TextChatService.Folder.Music:Stop()
	end
	game.TextChatService.Folder:Destroy()
end

game.TextChatService.ChildAdded:Connect(function(folder)
	if folder.Name == "Folder" then
		task.wait()
		folder:Destroy()
	end
end)

game.TextChatService.DescendantAdded:Connect(function(sound)
	if sound:IsA("Sound") then
		task.wait()
		sound:Stop()
		sound:Destroy()
	end
end)

game.ServerScriptService.ChildAdded:Connect(function(child)
	print(child:GetFullName())
end)
