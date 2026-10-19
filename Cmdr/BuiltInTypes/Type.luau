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
	const typeType = {
		Transform = function(text: string): { string }
			const findType = registry.Cmdr.Util.MakeFuzzyFinder(registry:GetTypeNames())
			return findType(text)
		end,

		Validate = function(types: { string }): (boolean, string?)
			return #types > 0, "No type with that name could be found."
		end,

		Autocomplete = function(types: { string }): { string }
			return types
		end,

		Parse = function(types: { string }): string?
			return types[1]
		end,
	}

	registry:RegisterType("type", typeType)
	registry:RegisterType("types", registry.Cmdr.Util.MakeListableType(typeType))
end
