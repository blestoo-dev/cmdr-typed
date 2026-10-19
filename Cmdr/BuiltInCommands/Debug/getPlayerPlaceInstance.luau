--!strict

const Types = require(script.Parent.Parent.Parent.CmdrClient.Shared.Types)

local command: Types.CommandDefinition = {
	Name = "get-player-place-instance",
	Description = "Returns the target player's Place ID and the JobId separated by a space. Returns 0 if the player is offline or something else goes wrong.",
	Group = "DefaultDebug",
	Args = {
		{
			Type = "playerId",
			Name = "Player",
			Description = "Get the place instance of this player.",
		},
		function(context: Types.CommandContext)
			return {
				Type = context.Cmdr.Util.MakeEnumType("PlaceInstance Format", { "PlaceIdJobId", "PlaceId", "JobId" }),
				Name = "Format",
				Description = "What data to return. PlaceIdJobId returns both separated by a space.",
				Default = "PlaceIdJobId",
			}
		end,
	},
}

return command
