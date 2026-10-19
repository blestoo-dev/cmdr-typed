--!strict

const Types = require(script.Parent.Parent.Parent.CmdrClient.Shared.Types)

type ConditionFn = (text: string, arg: string) -> string?

const CONDITIONS: { [string]: ConditionFn } = {
	startsWith = function(text: string, arg: string)
		return text:sub(1, #arg) == arg and text:sub(#arg + 1)
	end,

	contains = function(text: string, arg: string)
		return text:find(arg, 1, true) and text
	end,

	endsWith = function(text: string, arg: string)
		return text:sub(-#arg) == arg and text:sub(1, -#arg - 1)
	end,

	pattern = function(text: string, arg: string)
		return text:match(arg) and text
	end,

	equals = function(text: string, arg: string)
		return text == arg and text
	end,

	notEquals = function(text: string, arg: string)
		return text ~= arg and text
	end,

	greaterThan = function(text: string, arg: string)
		return tonumber(arg) > tonumber(text) and text
	end,

	lessThan = function(text: string, arg: string)
		return tonumber(arg) < tonumber(text) and text
	end,

	greaterThanOrEqual = function(text: string, arg: string)
		return tonumber(arg) >= tonumber(text) and text
	end,

	lessThanOrEqual = function(text: string, arg: string)
		return tonumber(arg) <= tonumber(text) and text
	end,

	length = function(text: string, arg: string)
		return #text == tonumber(arg) and text
	end,
}

const conditionNames = {}
for name in pairs(CONDITIONS) do
	conditionNames[#conditionNames + 1] = name
end

local command: Types.CommandDefinition = {
	Name = "runif",
	Description = "Runs a given command string if a certain condition is met.",
	Group = "DefaultUtil",
	Args = {
		function(context: Types.CommandContext)
			return {
				Type = context.Cmdr.Util.MakeEnumType("ConditionFunction", conditionNames),
				Name = "Condition",
				Description = "The condition function.",
			}
		end,
		{
			Type = "string",
			Name = "Argument",
			Description = "The argument to the condition function.",
		},
		{
			Type = "string",
			Name = "Test against",
			Description = "The text to test against.",
		},
		{
			Type = "string",
			Name = "Command",
			Description = "The command string to run if requirements are met. If omitted, return value from condition function is used.",
			Optional = true,
		},
	},

	ClientRun = function(context: Types.CommandContext, condition: string, arg: string, testAgainst: string, command: string?): string
		const conditionFunc = CONDITIONS[condition]
		const success, text = pcall(conditionFunc, testAgainst, arg)
		if success and text then
			return context.Dispatcher:EvaluateAndRun(
				context.Cmdr.Util.RunEmbeddedCommands(context.Dispatcher, command or text)
			)
		end

		return ""
	end,
}

return command
