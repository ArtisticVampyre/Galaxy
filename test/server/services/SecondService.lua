local log = shared("log")

local SecondService = {}

function SecondService:CallHello()
    warn("This is a warning from SecondService")
end

function SecondService:Start()
    log("SecondService Start")
    self._firstService:CallHello()
    self._secondService:CallHello()
end

function SecondService:Init(galaxy)
    log("SecondService Init")
    self._firstService = galaxy.Get("FirstService")
    self._secondService = galaxy.Get("SecondService")
end

return SecondService