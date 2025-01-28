--[[
    MainService
    Core service that handles service initialization and requests on the server
]]

-- Dependencies
---------------
local log = shared("log")

-- Interface
------------
local MainService = {}

--[[ Lifecycle Methods ]]

--- Handles service startup
function MainService:onStart()
    log.info("MainService started")
end

--- Performs initial setup
function MainService:onInit()
    log.info("MainService initialized") 
end

--- Processes requests from other services
--- @param otherService string Name of requesting service
function MainService:onRequest(otherService: string)
    log.info(`MainService requested by {otherService}`)
end

return MainService