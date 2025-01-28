--[[ 
    🌌 Galaxy Framework
    🚀 A fast, lightweight game framework for Roblox
    
    📦 Features:
    • 🔄 Automatic module loading
    • 🎮 Client/Server system management
    • ⚡ Optimized for performance
    • 🛡️ Type-safe with Luau
    
    Version: 0.2.0
    Author: ArtisticVampyre
--]]

-- 🔧 Core Services
local HttpService: HttpService = game:GetService("HttpService")
local RunService: RunService = game:GetService("RunService")

-- 📝 Type Definitions
type LaunchParams = {
	Modules: { Instance },
	Systems: { Instance },
	Config: { [string]: any },
}

-- 🌟 Main Module
local Galaxy = { _VERSION = "0.2.0" }

-- 🎯 Environment Detection
local SystemKey: string = RunService:IsServer() and "service" or "controller"
local CycleMetatable = require(script.CycleMetatable)

-- 📦 Module Management
local ModulesLoading: { [ModuleScript]: boolean } = {}
local LoadedModules: { [ModuleScript]: any } = {}
local Modules: { [string]: ModuleScript } = {}
local Systems: { [string]: any } = {}
local Config: { [string]: any } = {}

-- 🔄 Module Loading Functions
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

	local success, dataOrErr = pcall(require, module)
	CycleMetatable.CurrentModuleLoading = nil

	if success then
		return dataOrErr
	end

	warn(("❌ Failed to load module '%s' 💥\nError: %s"):format(module.Name, dataOrErr))
	return nil
end

-- 📚 Module Indexing Functions
-- Adds all available aliases for a ModuleScript to the internal index registry,
-- up to the specified number of ancestors (0 refers to the script itself,
-- indexes all ancestors if no cap specified)
local function _indexNames(child: ModuleScript)
	if typeof(child) ~= "Instance" then
		return
	end

	local index = child.Name

	if Modules[index] and not Config.AllowDuplicates then
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
	for _, descendant in location:GetDescendants() do
		if
			descendant:IsA("ModuleScript")
			and not descendant:FindFirstAncestorWhichIsA("ModuleScript")
			and descendant ~= script
		then
			_indexNames(descendant)
		end
	end
end

-- 🛠️ System Management
local function _loadInternal(system, rootModule: ModuleScript)
	local internal = system.DirectoriesToLoad
	if not internal then
		return
	end

	local root: Folder | ModuleScript

	if #rootModule:GetChildren() > 0 then
		root = rootModule
	else
		root = rootModule:FindFirstAncestorWhichIsA("Folder")
	end

	for _, dirKey: string in internal do
		local dir: Folder? = root:FindFirstChild(dirKey) :: Folder?
		if not dir then
			warn(("❗️Internal directory '%s' not found in system '%s'! 🚫"):format(dirKey, root.Name))
			continue
		end

		for _, module: ModuleScript in dir:GetDescendants() do
			if not module:IsA("ModuleScript") then
				continue
			end

			local success, dataOrErr = pcall(require, module)
			if not success then
				warn("❌ Failed to load internal module '%s' in system '%s'! 💥\nError: %s"):format(
					module.Name,
					root.Name,
					dataOrErr
				)
				continue
			end

			system[module.Name] = require(module)
		end
	end
end

-- 🎮 System Initialization
local function _indexSystems(location: Instance)
	for _, descendant: ModuleScript in location:GetDescendants() do
		if descendant:IsA("ModuleScript") and descendant ~= script then
			local childIndex = string.lower(descendant.Name)
			if string.find(childIndex, SystemKey) then
				local activeSystem = _load(descendant)

				if activeSystem then
					if root then
						_loadInternal(activeSystem, root :: Folder)
					end
					Systems[descendant.Name] = activeSystem
					descendant.Name = HttpService:GenerateGUID()
				end
			end
		end
	end
end

-- 🛡️ Fake Module Protection
local FakeModule = { IsFakeModule = true }
setmetatable(FakeModule, CycleMetatable)

-- 🚀 Core API
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
		LoadedModules[mod] = FakeModule -- Reuse a shared object
	end

	return LoadedModules[mod]
end

-- 🎯 Framework Launch
function Galaxy.Launch(launchParams: LaunchParams)
	assert(typeof(launchParams) == "table", `Expected table, got {typeof(launchParams)}`)

	if launchParams.Config then
		Config = launchParams.Config
	end

	for _, moduleRoot: Instance in launchParams.Modules do
		_indexModules(moduleRoot)
	end

	for _, systemRoot: Instance in launchParams.Systems do
		_indexSystems(systemRoot)
	end

	for _, system in Systems do
		if system.onInit and typeof(system.onInit) == "function" then
			system:onInit()
		end
	end

	for _, system in Systems do
		if system.onStart and typeof(system.onStart) == "function" then
			task.spawn(system.onStart, system)
		end
	end
end

-- ⚡ Metatable Setup
setmetatable(shared, Galaxy)
setmetatable(Galaxy, Galaxy)

return Galaxy
