--!strict

const Types = require(script.Parent.Parent.Parent.CmdrClient.Shared.Types)

local command: Types.CommandDefinition = {
	Name = "echo",
	Aliases = { "=" },
	Description = "Echoes your text back to you.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "string",
			Name = "Text",
			Description = "The text to echo.",
		},
	},

	ClientRun = function(_: Types.CommandContext, text: string): string
		return text
	end,
}

return command
