--[[ 
    SecondaryService
    Handles secondary game systems and interfaces with MainService on the server
]]

-- Dependencies
------------------
-- Services
local MainService = shared("MainService")

-- Libraries
local log = shared("log")

--[[ SecondaryService Interface ]]
local SecondaryService = {}

--- Initializes the service and registers with MainService
function SecondaryService:onStart()
    log.info("SecondaryService started")
    MainService:onRequest(script.Name)
end

--- Performs initial setup for the service
function SecondaryService:onInit()
    log.info("SecondaryService initialized") 
end

return SecondaryService