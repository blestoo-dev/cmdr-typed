--!strict

const Types = require(script.CmdrClient.Shared.Types)

const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")

const IS_SERVER_CONTAINER = script:FindFirstAncestorWhichIsA("ServerScriptService")
	or script:FindFirstAncestorWhichIsA("ServerStorage")
const IS_SERVER = RunService:IsServer()

if not IS_SERVER_CONTAINER then
	warn(
		"[Cmdr] The package should be kept within a server-side location. Future versions of Cmdr will require the server library be kept within ServerScriptService or ServerStorage."
	)
end

assert(
	IS_SERVER,
	"[Cmdr] The Cmdr server library cannot be required by the client. Please require the client libary instead."
)

const Dispatcher = require("@self/CmdrClient/Shared/Dispatcher")
const Registry = require("@self/CmdrClient/Shared/Registry")
const Util = require("@self/CmdrClient/Shared/Util")

const function createObject(className: string, name: string, parent: Instance): Instance
	const object = Instance.new(className)
	object.Name = name
	object.Parent = parent

	return object
end

--[=[
	@class Cmdr
	@server

	The Cmdr server object and entry point.
]=]

--[=[
	@within Cmdr
	@readonly

	@prop Registry Registry

	Refers to the command Registry.
]=]

--[=[
	@within Cmdr
	@readonly

	@prop Dispatcher Dispatcher

	Refers to the command Dispatcher.
]=]

--[=[
	@within Cmdr
	@readonly

	@prop Util Util

	Refers to a table containing many useful utility functions.
]=]

--[=[
	@within Cmdr
	@readonly
	@private

	@prop _remoteEvent RemoteEvent

	Refers to the CmdrEvent RemoteEvent found within CmdrClient.
]=]

--[=[
	@within Cmdr
	@readonly
	@private

	@prop _remoteFunction RemoteFunction

	Refers to the CmdrFunction RemoteFunction found within CmdrClient.
]=]

--[=[
	@within Cmdr
	@readonly
	@private

	@prop _replicatedRoot ModuleScript

	Refers to the CmdrClient modulescript containing all shared functionality.
]=]

--[=[
	@within Cmdr
	@readonly
	@private

	@prop _defaultCommandsFolder Folder

	Refers to the BuiltInCommands folder containing all default commands.
]=]

--[=[
	@within Cmdr
	@readonly
	@private

	@prop _defaultTypesFolder Folder

	Refers to the BuiltInTypes folder containing all default types.
]=]

const Cmdr = {
	Registry = nil :: Types.Registry?,
	Dispatcher = nil :: Types.Dispatcher?,
	Util = Util,

	_remoteEvent = nil :: RemoteEvent?,
	_remoteFunction = nil :: RemoteFunction?,

	_replicatedRoot = nil :: ModuleScript?,
	_defaultCommandsFolder = script.BuiltInCommands,
	_defaultTypesFolder = script.BuiltInTypes,
}

-- Initialize Cmdr
const function initialize()
	const registry = Registry(Cmdr :: Types.Framework)
	Cmdr.Registry = registry
	const dispatcher = Dispatcher(Cmdr :: Types.Framework)
	Cmdr.Dispatcher = dispatcher

	createObject("Folder", "Commands", script.CmdrClient)
	createObject("Folder", "Types", script.CmdrClient)

	Cmdr._replicatedRoot = script.CmdrClient
	Cmdr._replicatedRoot.Parent = ReplicatedStorage

	const remoteEvent = createObject("RemoteEvent", "CmdrEvent", script.CmdrClient) :: RemoteEvent
	Cmdr._remoteEvent = remoteEvent
	const remoteFunction = createObject("RemoteFunction", "CmdrFunction", script.CmdrClient) :: RemoteFunction
	Cmdr._remoteFunction = remoteFunction

	remoteFunction.OnServerInvoke = function(player: Player, text: string, options: { Data: Types.ArgumentValue?, IsHuman: boolean? }?)
		if #text > 10000 then
			return "Input too long"
		end

		return dispatcher:EvaluateAndRun(text, player, options)
	end

	registry:RegisterTypesIn(Cmdr._defaultTypesFolder)

	script.BuiltInTypes:Destroy()
	script.BuiltInCommands.Name = "Server commands"
end

initialize()

-- Export Cmdr
return (setmetatable(Cmdr, {
	__index = function(self: { [string]: unknown }, key: string)
		const registry = rawget(self, "Registry") :: Types.Registry?
		const value = if registry then (registry :: any)[key] else nil
		assert(value, `[Cmdr] Registry has no method or property "{key}".`)

		if type(value) == "function" then
			Util:_emitDeprecationWarning("ProxyCalls")

			return function(_: unknown, ...: Types.ArgumentValue)
				return value(registry, ...)
			end
		end

		return nil
	end,
	__newindex = function(_: unknown, key: string, _value: unknown)
		error(`[Cmdr] Cannot assign key "{key}"; the Cmdr object is read-only.`)
	end,
}) :: any) :: Types.Cmdr
