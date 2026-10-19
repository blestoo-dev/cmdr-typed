--!strict

const Types = require("../Types")

return function(index: number)
	return function(context: Types.CommandContext): string?
		const argContext = context:GetArgument(index)
		const value = argContext and argContext:GetValue()

		return if typeof(value) ~= "string" or value:match("^%s*$")
			then `Argument #{index} cannot be empty or blank.`
			else nil
	end
end
