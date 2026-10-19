--!strict

const Types = require(script.Parent.Parent.Parent.CmdrClient.Shared.Types)

local command: Types.CommandDefinition = {
	Name = "exit",
	Aliases = { "escape" },
	Description = "Exits the Cmdr window.",
	Group = "DefaultUtil",
	Args = {},
	ClientRun = function(context: Types.CommandContext): string
		context.Cmdr:Hide()
		return ""
	end,
}

return command
