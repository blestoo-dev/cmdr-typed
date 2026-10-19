--!strict

const Types = require(script.Parent.Parent.Parent.CmdrClient.Shared.Types)

local command: Types.CommandDefinition = {
	Name = "pick",
	Description = "Picks a value out of a comma-separated list.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "positiveInteger",
			Name = "Index to pick",
			Description = "The index of the item you want to pick.",
		},
		{
			Type = "string",
			Name = "CSV",
			Description = "The comma-separated list.",
		},
	},

	ClientRun = function(_: Types.CommandContext, index: number, list: string): string
		return list:split(",")[index] or ""
	end,
}

return command
