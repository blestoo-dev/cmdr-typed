--!strict

const Types = require(script.Parent.Parent.Parent.CmdrClient.Shared.Types)

const HttpService = game:GetService("HttpService")

return function(_: Types.CommandContext, url: string): string
	const success, response = pcall(HttpService.GetAsync, HttpService, url)

	return if success then response else `Failed to fetch URL: {response}`
end
