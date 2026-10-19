--!strict

const Types = require("../Types")

return function(index: number, forbiddenValue: Types.ArgumentValue)
	return function(context: Types.CommandContext): string?
		const argContext = context:GetArgument(index)
		const value = argContext and argContext:GetValue()

		return if value == forbiddenValue then `Argument #{index} cannot be "{forbiddenValue}".` else nil
	end
end
