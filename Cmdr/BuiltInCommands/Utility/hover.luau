--!strict

const Types = require(script.Parent.Parent.Parent.CmdrClient.Shared.Types)

const Players = game:GetService("Players")

const Player = Players.LocalPlayer

local command: Types.CommandDefinition = {
	Name = "hover",
	Description = "Returns the name of the player you are hovering over.",
	Group = "DefaultUtil",
	Args = {},

	ClientRun = function(): string
		const mouse = Player:GetMouse()
		const target = mouse.Target
		if not target then
			return ""
		end

		const targetPlayer = Players:GetPlayerFromCharacter(target:FindFirstAncestorOfClass("Model"))
		return if targetPlayer then `{targetPlayer.DisplayName} @({targetPlayer.Name})` else ""
	end,
}

return command
