--!strict

const Types = require(script.Parent.Parent.Parent.CmdrClient.Shared.Types)

local command: Types.CommandDefinition = {
	Name = "len",
	Description = "Returns the length of a comma-separated list.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "string",
			Name = "CSV",
			Description = "The comma-separated list.",
		},
	},

	ClientRun = function(_: Types.CommandContext, list: string): string
		return if #list == 0 then "0" else tostring(#(list:split(",")))
	end,
}

return command
