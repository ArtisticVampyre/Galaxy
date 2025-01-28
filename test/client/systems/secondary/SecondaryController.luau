--[[ 
    SecondaryController
    Handles secondary game systems and interfaces with MainController
]]

-- Dependencies
------------------
-- Controllers
local MainController = shared("MainController")

-- Libraries
local log = shared("log")

--[[ SecondaryController Interface ]]
local SecondaryController = {}

-- Initializes the controller and registers with MainController
function SecondaryController:onStart()
    log.info("SecondaryController started")
    MainController:onRequest(script.Name)
end

-- Performs initial setup for the controller
function SecondaryController:onInit()
    log.info("SecondaryController initialized") 
end

return SecondaryController