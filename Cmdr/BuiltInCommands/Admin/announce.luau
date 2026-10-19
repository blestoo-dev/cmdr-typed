--!strict

const Types = require(script.Parent.Parent.Parent.CmdrClient.Shared.Types)

const ReplicatedStorage = game:GetService("ReplicatedStorage")

const BuiltInGuards = ReplicatedStorage.CmdrClient.Shared.BuiltInGuards
const NonEmptyString = require(BuiltInGuards.NonEmptyString) :: (number) -> (Types.CommandContext) -> string?

local command: Types.CommandDefinition = {
	Name = "announce",
	Aliases = { "m" },
	Description = "Makes a server-wide announcement.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "string",
			Name = "Text",
			Description = "The announcement text.",
		},
	},
	Guards = {
		NonEmptyString(1),
	},
}

return command
