-- // Services
local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")

-- // Init
local TextHandler = {}

function TextHandler:Start()
	TextChatService.OnIncomingMessage = function(Message: TextChatMessage)
		if not Message.TextSource then
			return
		end

		local Properties = Instance.new("TextChatMessageProperties")
		local Player = Players:GetPlayerByUserId(Message.TextSource.UserId)
		local HasVIP = Player:GetAttribute("VIP")
		if HasVIP then
			Properties.PrefixText = `<font color = "#ffaa00">[VIP]</font> {Message.PrefixText}`
		end

		return Properties
	end
end

return TextHandler
