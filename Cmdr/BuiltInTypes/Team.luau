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
const Teams = game:GetService("Teams")

return function(registry: Registry)
	const teamType = {
		Transform = function(text: string): { Team }
			const findTeam = registry.Cmdr.Util.MakeFuzzyFinder(Teams:GetTeams())
			return findTeam(text)
		end,

		Validate = function(teams: { Team }): (boolean, string?)
			return #teams > 0, "No team with that name could be found."
		end,

		Autocomplete = function(teams: { Team }): { string }
			return registry.Cmdr.Util.GetNames(teams)
		end,

		Parse = function(teams: { Team }): Team?
			return teams[1]
		end,
	}

	const teamPlayersType = {
		Listable = true,
		Transform = teamType.Transform,
		Validate = teamType.Validate,
		Autocomplete = teamType.Autocomplete,
		Parse = function(teams: { Team }): { Player }
			return teams[1]:GetPlayers()
		end,
	}

	const teamColorType = {
		Transform = teamType.Transform,
		Validate = teamType.Validate,
		Autocomplete = teamType.Autocomplete,
		Parse = function(teams: { Team }): BrickColor?
			return teams[1].TeamColor
		end,
	}

	registry:RegisterType("team", teamType)
	registry:RegisterType("teams", registry.Cmdr.Util.MakeListableType(teamType))

	registry:RegisterType("teamPlayers", teamPlayersType)

	registry:RegisterType("teamColor", teamColorType)
	registry:RegisterType("teamColors", registry.Cmdr.Util.MakeListableType(teamColorType))
end
