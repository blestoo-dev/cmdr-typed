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
return function(registry: Registry)
	const commandType = {
		Transform = function(text: string): { [number]: string }
			const findCommand = registry.Cmdr.Util.MakeFuzzyFinder(registry:GetCommandNames())
			return findCommand(text)
		end,

		Validate = function(commands: { [number]: string }): (boolean, string?)
			return #commands > 0, "No command with that name could be found."
		end,

		Autocomplete = function(commands: { [number]: string }): { [number]: string }
			return commands
		end,

		Parse = function(commands: { [number]: string }): string
			return commands[1]
		end,
	}

	registry:RegisterType("command", commandType)
	registry:RegisterType("commands", registry.Cmdr.Util.MakeListableType(commandType))
end
