-- // Services
local Players = game:GetService("Players")

-- // Player
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // Util
local Button = require(script.Parent.Parent.Utils.Button)

-- // Module
local UIManager = require(script.Parent.Parent)

-- // UI
local MainUI = PlayerGui:WaitForChild("UI")

-- // Init
local Rebirth = {}

function Rebirth.Init() end

function Rebirth:Start() end

function Rebirth:Stop() end

return Rebirth
