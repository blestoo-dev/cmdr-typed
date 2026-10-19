--!strict

const Types = require(script.Parent.Parent.Parent.CmdrClient.Shared.Types)

local command: Types.CommandDefinition = {
	Name = "uptime",
	Description = "Returns the amount of time the server has been running.",
	Group = "DefaultDebug",
	Args = {},
}

return command
