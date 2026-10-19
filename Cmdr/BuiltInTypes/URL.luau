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
	const urlType = {
		Validate = function(text: string): (boolean, string?)
			if text:match("^https?://.+$") then
				return true
			end

			return false, "URLs must begin with http:// or https://"
		end,

		Parse = function(text: string): string
			return text
		end,
	}

	registry:RegisterType("url", urlType)
	registry:RegisterType("urls", registry.Cmdr.Util.MakeListableType(urlType))
end
