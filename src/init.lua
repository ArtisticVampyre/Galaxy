--[[
    Galaxy
    A simple, lightweight, and fast Roblox game framework.
--]]

-- The Galaxy module
local Galaxy = {
	_VERSION = "0.1.0",
}

-- HttpService for GUID generation
local HttpService = game:GetService("HttpService")

local CycleMetatable = require(script.CycleMetatable)
local Assert = require(script.Assert)

local ModulesLoading: { [ModuleScript]: boolean } = {}
local LoadedModules: { [ModuleScript]: any } = {}
local Modules: { [string]: ModuleScript } = {}
local Systems: { any } = {}

-- Adds a metatable to a temporary module table to let access operations fall
-- through to the original module table.
local function _switchTemp(moduleName: string, moduleData: any)
	local loadedModule = LoadedModules[Modules[moduleName]]
	loadedModule.IsFakeModule = nil
	if typeof(moduleData) == "table" then
		setmetatable(loadedModule, {
			__index = moduleData,
			__newindex = moduleData,
			__tostring = function()
				local result = "\nModule " .. moduleName .. ":\n"
				for key, value in moduleData do
					result = result .. "\t" .. tostring(key) .. ": " .. tostring(value) .. "\n"
				end
				return result
			end,
		})
	else
		LoadedModules[Modules[moduleName]] = moduleData
	end
end

-- Loads the given ModuleScript with error handling. Returns the loaded data.
local function _load(module: ModuleScript): any?
	CycleMetatable.CurrentModuleLoading = module.Name

	local success, data = pcall(require, module)
	if not success then
		local errorMessage = ("❌ Failed to load module '%s' 💥\nError: %s"):format(module.Name, data)
		warn(errorMessage)
	end

	CycleMetatable.CurrentModuleLoading = nil
	
	return data
end

-- Adds all available aliases for a ModuleScript to the internal index registry,
-- up to the specified number of ancestors (0 refers to the script itself,
-- indexes all ancestors if no cap specified)
local function _indexNames(child: ModuleScript)
	if typeof(child) ~= "Instance" then
		return
	end

	local index = child.Name

	if Modules[index] then
		warn(
			("⚠️ Duplicate module name found for '%s'!\nPlease ensure module names are unique. Check module definitions and aliases."):format(
				index
			)
		)
		return
	end

	Modules[index] = child
end

-- Indexes any ModuleScript children of the specified Instance
local function _indexModules(location: Instance)
	local descendants = location:GetDescendants()
	for _, child in descendants do
		if child:IsA("ModuleScript") and child ~= script then
			_indexNames(child)
		end
	end
end

local function _indexSystems(location: Instance)
	local descendants = location:GetDescendants()
	for _, child in descendants do
		if child:IsA("ModuleScript") and child ~= script then
			local childIndex = string.lower(child.Name)
			if string.find(childIndex, "service") or string.find(childIndex, "controller") then
				local moduleData = _load(child)
				if moduleData then
					Systems[child.Name] = moduleData
					child.Name = HttpService:GenerateGUID()
				end
			end
		end
	end
end

function Galaxy.__call(_: {}, module: string | ModuleScript): any?
	if typeof(module) == "Instance" then
		return _load(module)
	end

	local mod = Modules[module]
	if mod then
		if LoadedModules[mod] then
			return LoadedModules[mod]
		end

		if not ModulesLoading[mod] then
			ModulesLoading[mod] = true

			local moduleData = _load(mod)
			if LoadedModules[mod] then
				_switchTemp(module, moduleData)
			else
				LoadedModules[mod] = moduleData
			end

			ModulesLoading[mod] = nil
		end
	else
		warn(("❗️Module '%s' not found! 🚫"):format(module))
		local fakeModule = { IsFakeModule = true, Name = module }
		setmetatable(fakeModule, CycleMetatable)
		LoadedModules[mod] = fakeModule
	end

	return LoadedModules[mod]
end

function Galaxy.Init(params)
	for _, moduleRoot: Instance in params.Modules do
		_indexModules(moduleRoot)
	end

	for _, systemRoot: Instance in params.Systems do
		_indexSystems(systemRoot)
	end
end

function Galaxy.Get(index: string)
	return Assert(Systems[index], "System not found")
end

function Galaxy.Start()
	for _, system in Systems do
		if typeof(system.Init) == "function" then
			system:Init(Galaxy)
		end
	end

	for _, system in Systems do
		if typeof(system.Start) == "function" then
			task.spawn(system.Start, system)
		end
	end
end

setmetatable(shared, Galaxy)
setmetatable(Galaxy, Galaxy)

return Galaxy
