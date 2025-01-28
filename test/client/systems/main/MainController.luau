--[[
    MainController
    Core controller that handles controller initialization and requests
]]

-- Dependencies
---------------
local log = shared("log")

-- Interface
------------
local MainController = {}

--[[ Lifecycle Methods ]]

--- Handles controller startup
function MainController:onStart()
    log.info("MainController started")
end

--- Performs initial setup
function MainController:onInit()
    log.info("MainController initialized") 
end

--- Processes requests from other services
--- @param otherController string Name of requesting service
function MainController:onRequest(otherController: string)
    log.info(`MainController requested by {otherController}`)
end

return MainController