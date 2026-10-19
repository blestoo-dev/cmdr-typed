--!strict

const Types = require(script.Parent.Parent.Parent.CmdrClient.Shared.Types)

local command: Types.CommandDefinition = {
	Name = "fetch",
	Description = "Fetch a value from the Internet.",
	Group = "DefaultDebug",
	Args = {
		{
			Type = "url",
			Name = "URL",
			Description = "The URL to fetch.",
		},
	},
}

return command
