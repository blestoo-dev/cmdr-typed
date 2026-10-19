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
const combinedInputEnums: { EnumItem } = {}
for _, enum: Enum.UserInputType in ipairs(Enum.UserInputType:GetEnumItems()) do
	combinedInputEnums[#combinedInputEnums + 1] = enum
end

for _, enum: Enum.KeyCode in ipairs(Enum.KeyCode:GetEnumItems()) do
	combinedInputEnums[#combinedInputEnums + 1] = enum
end

return function(registry: Registry)
	const userInputType = {
		Transform = function(text: string): { EnumItem }
			const findEnum = registry.Cmdr.Util.MakeFuzzyFinder(combinedInputEnums)
			return findEnum(text)
		end,

		Validate = function(enums: { EnumItem }): (boolean, string?)
			return #enums > 0
		end,

		Autocomplete = function(enums: { EnumItem }): { string }
			return registry.Cmdr.Util.GetNames(enums)
		end,

		Parse = function(enums: { EnumItem }): EnumItem?
			return enums[1]
		end,
	}

	registry:RegisterType("userInput", userInputType)
	registry:RegisterType("userInputs", registry.Cmdr.Util.MakeListableType(userInputType))
end
