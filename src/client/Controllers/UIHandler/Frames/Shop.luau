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
local ShopFrame = MainUI:WaitForChild("Frames"):WaitForChild("Shop")

-- // Init
local Shop = {}

function Shop.Init() end

function Shop:Start() end

function Shop:Stop() end

return Shop
