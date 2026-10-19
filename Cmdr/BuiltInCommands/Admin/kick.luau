--!strict

const Types = require(script.Parent.Parent.Parent.CmdrClient.Shared.Types)

local command: Types.CommandDefinition = {
	Name = "kick",
	Aliases = { "boot" },
	Description = "Kicks a player or set of players.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "players",
			Name = "Players",
			Description = "The players to kick.",
		},
		{
			Type = "string",
			Name = "Reason",
			Description = "Kick message shown to the players.",
			Default = "No reason provided",
		},
	},
}

return command
