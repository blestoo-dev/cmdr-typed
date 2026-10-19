--!strict

type ArgumentValue = any

type TypeDefinition = {
	Name: string?,
	Prefixes: string?,
	DisplayName: string?,
	Default: ((executor: Player) -> string)?,
	Listable: boolean?,
	Transform: ((text: string, executor: Player) -> ...ArgumentValue)?,
	Validate: ((...ArgumentValue) -> (boolean, string?))?,
	ValidateOnce: ((...ArgumentValue) -> (boolean, string?))?,
	Autocomplete: ((...ArgumentValue) -> ({ string }, { IsPartial: boolean? }?))?,
	Parse: (...ArgumentValue) -> ...ArgumentValue,
	ArgumentOperatorAliases: { [string]: string }?,
}

type Registry = {
	Cmdr: { Util: any, Registry: any, Dispatcher: any },
	GetCommandNames: (self: any, includeAliases: boolean?) -> { string },
	GetTypeNames: (self: any) -> { string },
	GetType: (self: any, name: string) -> TypeDefinition?,
	GetStore: (self: any, name: string) -> { [string]: ArgumentValue },
	RegisterType: (self: any, name: string, typeObject: TypeDefinition) -> (),
}
const Players = game:GetService("Players")

return function(registry: Registry)
	const playerType = {
		Transform = function(text: string): { Player }
			const findPlayer = registry.Cmdr.Util.MakeFuzzyFinder(Players:GetPlayers())
			return findPlayer(text)
		end,

		Validate = function(players: { Player }): (boolean, string?)
			return #players > 0, "No player with that name could be found."
		end,

		Autocomplete = function(players: { Player }): { string }
			return registry.Cmdr.Util.GetNames(players)
		end,

		Parse = function(players: { Player }): Player?
			return players[1]
		end,

		Default = function(player: Player): string
			return player.Name
		end,

		ArgumentOperatorAliases = {
			me = ".",
			all = "*",
			others = "**",
			random = "?",
		},
	}

	registry:RegisterType("player", playerType)
	registry:RegisterType("players", registry.Cmdr.Util.MakeListableType(playerType, { Prefixes = "% teamPlayers" }))
end
