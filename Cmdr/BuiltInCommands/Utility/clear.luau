--!strict

const Types = require(script.Parent.Parent.Parent.CmdrClient.Shared.Types)

local command: Types.CommandDefinition = {
	Name = "clear",
	Description = "Clear all lines above the entry line of the Cmdr window.",
	Group = "DefaultUtil",
	Args = {},
	ClientRun = function(context: Types.CommandContext): string
		const entryFrame = context.Cmdr.Gui:WaitForChild("Frame", 2)
		if not entryFrame then
			return "Failed to clear: Frame not found."
		end

		for _, child in pairs(entryFrame:GetChildren()) do
			if child.Name == "Line" and child:IsA("TextBox") then
				child:Destroy()
			end
		end

		return ""
	end,
}

return command
