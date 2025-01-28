--[[
    Client Entry Point
    Initializes the Galaxy framework and configures core systems
]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Dependencies
local Galaxy = require(ReplicatedStorage.Packages.Galaxy)

-- Framework Configuration
local MODULES = {
    ReplicatedStorage.Packages,
    ReplicatedStorage.Shared,
}

local SYSTEMS = {
    script:WaitForChild("systems"),
}

local CONFIG = {
    AllowDuplicates = true,
}

-- Initialize Galaxy Framework
Galaxy.Launch({
    Modules = MODULES,
    Systems = SYSTEMS, 
    Config = CONFIG
})