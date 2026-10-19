--!strict

const Types = require(script.Parent.Parent.Parent.CmdrClient.Shared.Types)

const Players = game:GetService("Players")
const ReplicatedStorage = game:GetService("ReplicatedStorage")

const BuiltInGuards = ReplicatedStorage.CmdrClient.Shared.BuiltInGuards
const HasCharacter = require(BuiltInGuards.HasCharacter) :: (number?) -> (Types.CommandContext) -> string?

local command: Types.CommandDefinition = {
	Name = "position",
	Aliases = { "pos" },
	Description = "Returns the Vector3 position of you or another player.",
	Group = "DefaultDebug",
	Args = {
		{
			Type = "player",
			Name = "Player",
			Description = "The player to report the position of. Omit for your own position.",
			Default = Players.LocalPlayer,
		},
	},
	Guards = {
		HasCharacter(1),
	},

	ClientRun = function(_: Types.CommandContext, player: Player): string?
		const character = player.Character
		const rootPart = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
		if not rootPart then
			return nil
		end

		return (tostring(rootPart.Position):gsub("%s", ""))
	end,
}

return command
