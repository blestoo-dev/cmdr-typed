--!strict

const Types = require(script.Parent.Parent.Parent.CmdrClient.Shared.Types)

return function(_: Types.CommandContext, players: { Player }): string
	for _, player in ipairs(players) do
		task.spawn(pcall, player.LoadCharacterAsync, player)
	end

	return `Respawned {#players} players.`
end
