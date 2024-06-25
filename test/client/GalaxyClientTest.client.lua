local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")

local Galaxy = require(ReplicatedStorage.Packages.Galaxy)
Galaxy.Init({
	Modules = {
		ReplicatedStorage.Shared,
		script.Parent,
	},
    Systems = {
        script.Parent,
    },
})
Galaxy.Start()
