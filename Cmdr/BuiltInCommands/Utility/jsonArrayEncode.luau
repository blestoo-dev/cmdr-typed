--!strict

const Types = require(script.Parent.Parent.Parent.CmdrClient.Shared.Types)

const HttpService = game:GetService("HttpService")

local command: Types.CommandDefinition = {
	Name = "json-array-encode",
	Description = "Encodes a comma-separated list into a JSON array.",
	Group = "DefaultUtil",
	Args = {
		{
			Type = "string",
			Name = "CSV",
			Description = "The comma-separated list.",
		},
	},

	ClientRun = function(_: Types.CommandContext, text: string): string
		return HttpService:JSONEncode(text:split(","))
	end,
}

return command
