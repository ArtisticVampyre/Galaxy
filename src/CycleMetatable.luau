local CycleMetatable = { CurrentModuleLoading = "Unknown" }

-- Metamethod descriptions for generating handlers
local METAMETHODS = {
	__index = "read key '%s'",
	__newindex = "set key '%s' to %s",
	__call = "call module",
	__concat = "concatenate module with %s",
	__unm = "use unary operator on module",
	__add = "add module with %s",
	__sub = "subtract module with %s",
	__mul = "multiply module with %s",
	__div = "divide module with %s",
	__mod = "modulo module with %s",
	__pow = "raise module to power of %s",
	__tostring = "convert module to string",
	__eq = "compare module with %s",
	__lt = "compare module with %s",
	__le = "compare module with %s",
	__len = "get length of module",
}

local function formatWarning(self: table, action: string, ...: any): string
	return string.format(
		"Detected bare code referencing a cyclic dependency (%s -> %s). Attempt to %s. Please revise.",
		tostring(CycleMetatable.CurrentModuleLoading),
		tostring(self.Name),
		string.format(action, ...)
	)
end

-- Generate metamethods dynamically
for name, action in METAMETHODS do
	CycleMetatable[name] = function(self, ...)
		warn(formatWarning(self, action, ...), debug.traceback(1))
	end
end

return CycleMetatable
