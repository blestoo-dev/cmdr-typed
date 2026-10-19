--!strict

const Types = require(script.Parent.Parent.Parent.CmdrClient.Shared.Types)

const VERSION = "v1.13.1"

local command: Types.CommandDefinition = {
	Name = "version",
	Description = "Shows the current version of Cmdr.",
	Group = "DefaultDebug",
	Args = {},

	ClientRun = function(): string
		return `Cmdr Version {VERSION}`
	end,
}

return command
