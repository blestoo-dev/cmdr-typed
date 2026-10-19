--!strict

const Types = require(script.Parent.Parent.Parent.CmdrClient.Shared.Types)

local command: Types.CommandDefinition = {
	Name = "kill",
	Aliases = { "slay" },
	Description = "Kills a player or set of players.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "players",
			Name = "victims",
			Description = "The players to kill.",
		},
	},
}

return command
