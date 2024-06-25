local log = shared("log")

local FirstService = {}

function FirstService:CallHello()
    log("FirstService Hello")
end

function FirstService:Start()
	log("FirstService Start")
end

function FirstService:Init()
	log("FirstService Init")
end

return FirstService
