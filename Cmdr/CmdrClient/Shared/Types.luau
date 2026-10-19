--!strict

-- Shared public and internal contracts for Cmdr. Keep dynamic values limited to the
-- argument/type system, where commands are intentionally extensible at runtime.

export type HookType = "BeforeRun" | "AfterRun" | "BeforeCommandRegister"
export type ArgumentValue = any

export type SequenceTypeOptions = {
	Transform: ((text: string, executor: Player) -> ArgumentValue)?,
	Parse: ((components: { ArgumentValue }) -> ArgumentValue)?,
	Constructor: ((...ArgumentValue) -> ArgumentValue)?,
	TransformEach: ((text: string) -> ArgumentValue)?,
	ValidateEach: ((value: ArgumentValue, index: number) -> (boolean, string?))?,
	Prefixes: { string }?,
	Length: number?,
}

export type AutocompleteOptions = {
	IsPartial: boolean?,
}

export type AutocompleteDisplayOptions = {
	name: string?,
	type: string?,
	description: string?,
	invalid: boolean?,
}

export type AutocompleteItem = {
	[1]: string,
	[2]: string,
	gui: TextButton?,
	options: AutocompleteDisplayOptions?,
}

export type AutocompleteShowOptions = AutocompleteDisplayOptions & {
	at: number?,
	prefix: string?,
	isLast: boolean?,
	numArgs: number?,
	command: CommandContext?,
	arg: ArgumentContext?,
	isPartial: boolean?,
}

export type TypeDefinition = {
	Name: string?,
	Prefixes: string?,
	DisplayName: string?,
	Default: ((executor: Player) -> string)?,
	Listable: boolean?,
	Transform: ((text: string, executor: Player) -> ...ArgumentValue)?,
	Validate: ((...ArgumentValue) -> (boolean, string?))?,
	ValidateOnce: ((...ArgumentValue) -> (boolean, string?))?,
	Autocomplete: ((...ArgumentValue) -> ({ string }, AutocompleteOptions?))?,
	Parse: (...ArgumentValue) -> ...ArgumentValue,
	ArgumentOperatorAliases: { [string]: string }?,
}

export type ArgumentDefinition = {
	Name: string,
	Type: string | TypeDefinition,
	Description: string?,
	Optional: boolean?,
	Default: ArgumentValue?,
}

export type ArgumentDefinitionProvider = (context: CommandContext) -> ArgumentDefinition?

export type CommandDefinition = {
	Name: string,
	Aliases: { string }?,
	AutoExec: { string }?,
	Description: string?,
	Group: string?,
	Args: { ArgumentDefinition | ArgumentDefinitionProvider },
	Data: ((context: CommandContext, ...ArgumentValue) -> ArgumentValue)?,
	ClientRun: ((context: CommandContext, ...ArgumentValue) -> string?)?,
	Run: ((context: CommandContext, ...ArgumentValue) -> string?)?,
	Guards: { ((context: CommandContext, ...ArgumentValue) -> string?) }?,
	_isDefault: boolean?,
	_isHidden: boolean?,
	_scriptInstance: ModuleScript?,
}

export type ArgumentContext = {
	Command: CommandContext,
	Type: TypeDefinition,
	Name: string,
	Object: ArgumentDefinition,
	Required: boolean,
	Executor: Player,
	RawValue: string,
	RawSegments: { string },
	Prefix: string,
	TextSegmentInProgress: ArgumentValue,
	RawSegmentsAreAutocomplete: boolean,
	TransformedValues: { ArgumentValue },
	Transform: (self: ArgumentContext) -> (),
	TransformSegment: (self: ArgumentContext, rawSegment: string) -> ...ArgumentValue,
	GetTransformedValue: (self: ArgumentContext, segment: number) -> ...ArgumentValue,
	GetDefaultAutocomplete: (self: ArgumentContext) -> ({ string }, AutocompleteOptions),
	GetAutocomplete: (self: ArgumentContext) -> ({ string }, AutocompleteOptions?),
	Validate: (self: ArgumentContext, isFinal: boolean?) -> (boolean, string?),
	_parseValue: (self: ArgumentContext, segment: number) -> ...ArgumentValue,
	GetValue: (self: ArgumentContext) -> ArgumentValue,
}

export type CommandOptions = {
	Dispatcher: Dispatcher,
	Text: string?,
	CommandObject: CommandDefinition,
	Alias: string?,
	Executor: Player,
	Arguments: { string },
	Data: ArgumentValue?,
	Guards: { ((context: CommandContext, ...ArgumentValue) -> string?) }?,
}

export type CommandContext = {
	Dispatcher: Dispatcher,
	Cmdr: Framework,
	Name: string,
	RawText: string?,
	Object: CommandDefinition,
	Group: string?,
	State: { [string]: ArgumentValue },
	Aliases: { string }?,
	Alias: string?,
	Description: string?,
	Executor: Player,
	ArgumentDefinitions: { ArgumentDefinition | ArgumentDefinitionProvider },
	RawArguments: { string },
	Arguments: { ArgumentContext },
	Data: ArgumentValue?,
	Response: string?,
	_Validated: boolean?,
	Guards: { ((context: CommandContext, ...ArgumentValue) -> string?) }?,
	Parse: (self: CommandContext, allowIncompleteArguments: boolean?) -> (boolean, string?),
	Validate: (self: CommandContext, isFinal: boolean?) -> (boolean, string),
	GetLastArgument: (self: CommandContext) -> ArgumentContext?,
	GatherArgumentValues: (self: CommandContext) -> ({ ArgumentValue }, number),
	Run: (self: CommandContext) -> string?,
	GetArgument: (self: CommandContext, index: number) -> ArgumentContext?,
	GetData: (self: CommandContext) -> ArgumentValue?,
	SendEvent: (self: CommandContext, player: Player, event: string, ...ArgumentValue) -> (),
	BroadcastEvent: (self: CommandContext, event: string, ...ArgumentValue) -> (),
	Reply: (self: CommandContext, text: string, options: ArgumentValue?) -> (),
	GetStore: (self: CommandContext, name: string) -> { [string]: ArgumentValue },
	HasImplementation: (self: CommandContext) -> boolean,
}

export type HookCallback = (context: CommandContext) -> (string | boolean)?

export type HookEntry = {
	callback: HookCallback,
	priority: number,
}

export type Registry = {
	Cmdr: Framework,
	_types: { [string]: TypeDefinition },
	_typeAliases: { [string]: string },
	_commands: { [string]: CommandDefinition },
	_commandsArray: { CommandDefinition },
	_hooks: { [HookType]: { HookEntry } },
	_autoExecBuffer: { { string } },
	_autoExecFlushConnection: RBXScriptConnection?,
	_stores: { [string]: { [string]: ArgumentValue } },
	RegisterType: (self: Registry, name: string, typeObject: TypeDefinition) -> (),
	RegisterTypePrefix: (self: Registry, typeName: string, union: string) -> (),
	RegisterTypeAlias: (self: Registry, name: string, alias: string) -> (),
	RegisterTypesIn: (self: Registry, container: Instance) -> (),
	RegisterHooksIn: (self: Registry, container: Instance) -> (),
	RegisterCommandObject: (self: Registry, commandObject: CommandDefinition, isDefault: boolean?) -> boolean,
	RegisterCommand: (self: Registry, commandScript: ModuleScript, commandServerScript: ModuleScript?, filter: ((CommandDefinition) -> boolean)?, isDefault: boolean?) -> (),
	RegisterCommandsIn: (self: Registry, container: Instance, filter: ((CommandDefinition) -> boolean)?, isDefault: boolean?) -> (),
	RegisterDefaultCommands: (self: Registry, arrayOrFunc: { string } | ((CommandDefinition) -> boolean)?) -> (),
	GetCommand: (self: Registry, name: string) -> CommandDefinition?,
	GetCommands: (self: Registry) -> { CommandDefinition },
	GetCommandNames: (self: Registry, includeAliases: boolean?) -> { string },
	GetCommandsAsStrings: (self: Registry, includeAliases: boolean?) -> { string },
	GetTypeNames: (self: Registry) -> { string },
	GetType: (self: Registry, name: string) -> TypeDefinition?,
	GetTypeName: (self: Registry, name: string) -> string,
	RegisterHook: (self: Registry, hookName: HookType, callback: HookCallback, priority: number?) -> (),
	AddHook: (self: Registry, hookName: HookType, callback: HookCallback, priority: number?) -> (),
	GetStore: (self: Registry, name: string) -> { [string]: ArgumentValue },
	_validateCommandArguments: (self: Registry, commandObject: CommandDefinition) -> (),
	_validateCommand: (self: Registry, commandObject: CommandDefinition) -> (),
	_flushAutoExecBuffer: (self: Registry) -> (),
	_flushAutoExecBufferDeferred: (self: Registry) -> (),
}

export type Dispatcher = {
	Cmdr: Framework,
	Registry: Registry,
	Evaluate: (self: Dispatcher, text: string, executor: Player, allowIncompleteArguments: boolean?, data: ArgumentValue?) -> (CommandContext | false, string?),
	EvaluateAndRun: (self: Dispatcher, text: string, executor: Player?, options: { Data: ArgumentValue?, IsHuman: boolean? }?) -> string,
	Send: (self: Dispatcher, text: string, data: ArgumentValue?) -> string,
	SendEvent: (self: Dispatcher, player: Player, event: string, ...ArgumentValue) -> (),
	BroadcastEvent: (self: Dispatcher, event: string, ...ArgumentValue) -> (),
	Run: (self: Dispatcher, ...ArgumentValue) -> string,
	RunHooks: (self: Dispatcher, hookName: HookType, context: CommandContext, passExactValue: boolean?) -> (string | boolean)?,
	RunGuards: (self: Dispatcher, context: CommandContext, ...ArgumentValue) -> string?,
	RunBeforeCommandRegisterHooks: (self: Dispatcher, player: Player?) -> (),
	_runBeforeCommandRegisterHookForCommand: (self: Dispatcher, commandObject: CommandDefinition) -> (string | boolean)?,
	GetHistory: (self: Dispatcher) -> { string },
	_pushHistory: (self: Dispatcher, text: string) -> (),
}

export type Window = {
	_entry: Frame,
	_lineTemplate: TextBox,
	_backdrop: Frame,
	_mouseUnlocker: TextButton,
	_previousChatStates: { [Instance]: boolean },
	_visibleInputConnection: RBXScriptConnection?,
	_hasLostFocus: boolean,
	_valid: boolean,
	_errorText: string?,
	_historyState: { Position: number, InitialText: string }?,
	_pressCount: number,
	_lastPressTime: number,
	GetLabelText: (self: Window) -> string,
	UpdateLabelText: (self: Window) -> (),
	UpdateWindowHeight: (self: Window) -> (),
	GetEntryText: (self: Window) -> string,
	AddLine: (self: Window, text: ArgumentValue, options: ArgumentValue?) -> (),
	UpdateMouseUnlock: (self: Window) -> (),
	SetVisible: (self: Window, visible: boolean) -> (),
	IsVisible: (self: Window) -> boolean,
	Hide: (self: Window) -> (),
	Show: (self: Window) -> (),
	HideInvalidState: (self: Window) -> (),
	BindActivationKeys: (self: Window) -> (),
	_setEntryText: (self: Window, text: string) -> (),
	_setChatEnabled: (self: Window, enabled: boolean) -> (),
	_setIsValidInput: (self: Window, isValid: boolean, errorText: string?) -> (),
	_traverseHistory: (self: Window, delta: number) -> (),
	_clearHistoryState: (self: Window) -> (),
	_selectVertical: (self: Window, delta: number) -> (),
	_processEntry: (self: Window, text: string) -> (),
	_loseFocus: (self: Window, submit: boolean, cause: InputObject?) -> (),
	_handleActivationKey: (self: Window) -> (),
	_handleTabCompletion: (self: Window) -> (),
	_handlePointerInput: (self: Window, input: InputObject) -> (),
	_handleVisibleInput: (self: Window, input: InputObject, gameProcessed: boolean) -> (),
	_setInputBound: (self: Window, bound: boolean) -> (),
	_handleArgumentAutoComplete: (self: Window, command: CommandContext, arguments: { string }, text: string, hasTrailingSpace: boolean, atEnd: boolean) -> (),
	_handleCommandAutoComplete: (self: Window, commandText: string, command: CommandContext | false) -> (),
	_onTextChanged: (self: Window, text: string) -> (),
}

export type AutoComplete = {
	_autoItem: TextButton,
	_title: TextLabel,
	_description: TextLabel,
	_entry: Frame,
	_updateContainerPosition: (self: AutoComplete, offset: number?) -> (),
	_setText: (self: AutoComplete, object: GuiObject, textObject: TextLabel, text: string?, sizeFromContents: boolean?) -> (),
	_updateInfoDisplay: (self: AutoComplete, options: AutocompleteDisplayOptions) -> (),
	Show: (self: AutoComplete, items: { AutocompleteItem }, options: AutocompleteShowOptions?) -> (),
	GetSelectedItem: (self: AutoComplete) -> AutocompleteItem?,
	Hide: (self: AutoComplete) -> (),
	IsVisible: (self: AutoComplete) -> boolean,
	Select: (self: AutoComplete, delta: number) -> (),
	Items: { AutocompleteItem },
	SelectedItem: number,
	Prefix: string,
	LastItem: boolean,
	Command: CommandContext?,
	Arg: ArgumentContext?,
	NumArgs: number?,
	IsPartial: boolean,
}

export type CmdrInterface = {
	Window: Window,
	AutoComplete: AutoComplete,
}

export type UtilAPI = {
	GetDataStore: () -> GlobalDataStore?,
	MakeDictionary: (array: { any }) -> { [any]: true },
	DictionaryKeys: (dict: { [any]: any }) -> { any },
	MakeFuzzyFinder: (setOrContainer: any) -> (text: string, returnFirst: boolean?, matchStart: boolean?) -> any,
	GetNames: (instances: any) -> { string },
	SplitStringSimple: (input: string, separator: string?) -> { string },
	ParseEscapeSequences: (text: string) -> string,
	EncodeEscapedOperator: (text: string, operator: string) -> string,
	EncodeEscapedOperators: (text: string) -> string,
	SplitString: (text: string, max: number?) -> { string },
	MashExcessArguments: (arguments: { string }, max: number) -> { string },
	TrimString: (text: string) -> string,
	GetTextSize: (text: string, label: TextLabel, size: Vector2?) -> Vector2,
	MakeEnumType: (name: string, values: ArgumentValue) -> TypeDefinition,
	ParsePrefixedUnionType: (typeValue: string, rawValue: string) -> (string?, string?, string?),
	MakeListableType: (typeDefinition: TypeDefinition, override: { [string]: any }?) -> TypeDefinition,
	RunCommandString: (dispatcher: Dispatcher, commandString: string) -> string?,
	RunEmbeddedCommands: (dispatcher: Dispatcher, text: string) -> string,
	SubstituteArgs: (text: string, replace: any) -> string,
	MakeAliasCommand: (name: string, commandString: string) -> CommandDefinition,
	MakeSequenceType: (options: SequenceTypeOptions) -> TypeDefinition,
	SplitPrioritizedDelimeter: (text: string, delimiters: { string }) -> { string }?,
	Map: (array: { any }, callback: (any, number) -> any) -> { any },
	Each: (callback: (any) -> any, ...any) -> ...any,
	EmulateTabstops: (text: string, tabWidth: number) -> string,
	Mutex: () -> () -> (),
	_registerDeprecationWarning: (self: UtilAPI, name: string, description: string) -> (),
	_emitDeprecationWarning: (self: UtilAPI, name: string) -> (),
	SuppressDeprecationWarning: (self: UtilAPI, names: string | { string }) -> (),
	_deprecationWarnings: { [string]: { Description: string, Suppressed: boolean, Emitted: boolean } },
}

export type Framework = {
	Registry: Registry,
	Dispatcher: Dispatcher,
	Util: UtilAPI,
	_remoteEvent: RemoteEvent?,
	_remoteFunction: RemoteFunction?,
	_replicatedRoot: ModuleScript?,
	_defaultCommandsFolder: Folder?,
	_defaultTypesFolder: Folder?,
	_events: { [string]: (...ArgumentValue) -> () }?,
}

export type Cmdr = Framework & {
	_remoteEvent: RemoteEvent?,
	_remoteFunction: RemoteFunction?,
	_replicatedRoot: ModuleScript?,
	_defaultCommandsFolder: Folder,
	_defaultTypesFolder: Folder,
}

export type Signal = {
	Fire: (self: Signal, ...ArgumentValue) -> (),
	Connect: (self: Signal, callback: (...ArgumentValue) -> ()) -> RBXScriptConnection,
}

export type CmdrClient = Framework & {
	Gui: ScreenGui?,
	Toggled: Signal,
	_interface: CmdrInterface,
	_replicatedRoot: ModuleScript,
	_remoteEvent: RemoteEvent,
	_remoteFunction: RemoteFunction,
	_enabled: boolean,
	_activationKeys: { Enum.KeyCode },
	_activationUnlocksMouse: boolean,
	_mashToEnable: boolean,
	_hideOnLostFocus: boolean,
	_placeName: string,
	_events: { [string]: (...ArgumentValue) -> () },
	SetEnabled: (self: CmdrClient, enabled: boolean) -> (),
	SetActivationKeys: (self: CmdrClient, keys: { Enum.KeyCode }) -> (),
	SetActivationUnlocksMouse: (self: CmdrClient, enabled: boolean) -> (),
	Show: (self: CmdrClient) -> (),
	Hide: (self: CmdrClient) -> (),
	Toggle: (self: CmdrClient) -> (),
	SetMashToEnable: (self: CmdrClient, enabled: boolean) -> (),
	SetHideOnLostFocus: (self: CmdrClient, enabled: boolean) -> (),
	SetPlaceName: (self: CmdrClient, name: string) -> (),
	HandleEvent: (self: CmdrClient, name: string, callback: (...ArgumentValue) -> ()) -> (),
}

return {}
