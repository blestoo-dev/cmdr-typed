--!strict

const Types = require("@self/Shared/Types")
type CmdrClient = Types.CmdrClient
type AutoComplete = Types.AutoComplete
type AutocompleteItem = Types.AutocompleteItem
type AutocompleteDisplayOptions = Types.AutocompleteDisplayOptions
type AutocompleteShowOptions = Types.AutocompleteShowOptions

const VALID_TEXT_COLOR = Color3.fromRGB(255, 255, 255)
const INVALID_TEXT_COLOR = Color3.fromRGB(255, 73, 73)
const TEXT_MEASUREMENT_SIZE = Vector2.new(1000, 1000)

--[=[
	@class AutoComplete
	@ignore
	Handles the Cmdr suggestions interface.
]=]

return function(CmdrClient: CmdrClient): AutoComplete
	local gui = assert(CmdrClient.Gui, "CmdrClient GUI must exist before constructing autocomplete")
	const autoCompleteFrame = gui:WaitForChild("Autocomplete") :: ScrollingFrame
	const defaultBarThickness = autoCompleteFrame.ScrollBarThickness

	const AutoComplete = ({
		_autoItem = autoCompleteFrame:WaitForChild("TextButton") :: TextButton,
		_title = autoCompleteFrame:WaitForChild("Title") :: TextLabel,
		_description = autoCompleteFrame:WaitForChild("Description") :: TextLabel,
		_entry = gui.Frame:WaitForChild("Entry") :: Frame,

		Items = {} :: { AutocompleteItem },
		SelectedItem = 1,

		Prefix = "",
		LastItem = false,

		Command = nil,
		Arg = nil,
		NumArgs = nil,
		IsPartial = false,
	} :: any) :: AutoComplete

	-- Updates the size of the container.
	const function updateContainerSize()
		const titleWidth = AutoComplete._title.Field.TextBounds.X
		const typeWidth = AutoComplete._title.Field.Type.TextBounds.X
		const frameWidth = autoCompleteFrame.Size.X.Offset

		const availableHeight = autoCompleteFrame.Parent.AbsoluteSize.Y - autoCompleteFrame.AbsolutePosition.Y - 10
		const contentHeight = autoCompleteFrame.UIListLayout.AbsoluteContentSize.Y

		const xOffset = math.max(titleWidth + typeWidth, frameWidth)
		const yOffset = math.min(contentHeight, availableHeight)
		autoCompleteFrame.Size = UDim2.fromOffset(xOffset, yOffset)
	end

	--[=[
		@within AutoComplete
		@private

		Updates the position of the container.
	]=]
	function AutoComplete:_updateContainerPosition(offset: number?)
		const entryPosition = self._entry.TextBox.AbsolutePosition
		const xOffset = if offset then entryPosition.X - 10 + offset else entryPosition.X
		const yOffset = entryPosition.Y + 30
		autoCompleteFrame.Position = UDim2.fromOffset(xOffset, yOffset)
	end

	--[=[
		@within AutoComplete
		@private

		Sets the text of the provided object.
	]=]
	function AutoComplete:_setText(object: GuiObject, textObject: TextLabel, text: string?, sizeFromContents: boolean?)
		object.Visible = text ~= nil
		textObject.Text = text or ""

		if sizeFromContents then
			const textSize = CmdrClient.Util.GetTextSize(text or "", textObject, TEXT_MEASUREMENT_SIZE)
			textObject.Size = UDim2.new(0, textSize.X, object.Size.Y.Scale, object.Size.Y.Offset)
		end
	end

	--[=[
		@within AutoComplete
		@private

		Updates the displayed auto completion info.
	]=]
	function AutoComplete:_updateInfoDisplay(options: AutocompleteDisplayOptions)
		const typeName = options.type and `{options.type:sub(1, 1):upper()}{options.type:sub(2)}`
		const typeText = typeName and `: {typeName}`
		self:_setText(self._title, self._title.Field, options.name, true)
		self:_setText(self._title.Field.Type, self._title.Field.Type, typeText)
		self:_setText(self._description, self._description.Label, options.description)

		self._description.Label.TextColor3 = if options.invalid then INVALID_TEXT_COLOR else VALID_TEXT_COLOR
		self._description.Size = UDim2.new(1, 0, 0, 40)

		while not self._description.Label.TextFits do
			self._description.Size = self._description.Size + UDim2.fromOffset(0, 2)

			if self._description.Size.Y.Offset > 500 then
				break
			end
		end

		task.wait()
		updateContainerSize()
		autoCompleteFrame.ScrollBarThickness = defaultBarThickness
	end

	--[=[
		@within AutoComplete
		Shows the autocomplete menu.
	]=]
	function AutoComplete:Show(items: { AutocompleteItem }, options: AutocompleteShowOptions?)
		local displayOptions: AutocompleteShowOptions = options or {}

		for _, item in ipairs(self.Items) do
			if item.gui then
				item.gui:Destroy()
			end
		end

		self.SelectedItem = 1
		self.Items = items

		self.Prefix = displayOptions.prefix or ""
		self.LastItem = displayOptions.isLast or false

		self.Command = displayOptions.command
		self.Arg = displayOptions.arg
		self.NumArgs = displayOptions.numArgs
		self.IsPartial = displayOptions.isPartial or false

		local autocompleteWidth = 200
		autoCompleteFrame.ScrollBarThickness = 0

		for index, item in ipairs(items) do
			const typedText = item[1]
			const suggestionText = item[2]
			const button = self._autoItem:Clone()
			button.Name = `{typedText}{suggestionText}`
			button.BackgroundTransparency = if index == self.SelectedItem then 0.5 else 1

			local start, stop = suggestionText:lower():find(typedText:lower(), 1, true)
			if not start then
				start = 1
				stop = #suggestionText
			end

			const prefix = suggestionText:sub(1, start - 1)
			const suffix = suggestionText:sub(stop + 1)
			button.Typed.Text = `{(" "):rep(start - 1)}{typedText}`
			button.Suggest.Text = `{prefix}{(" "):rep(#typedText)}{suffix}`

			button.LayoutOrder = index
			button.Parent = autoCompleteFrame

			const maxBounds = math.max(button.Typed.TextBounds.X, button.Suggest.TextBounds.X) + 20
			autocompleteWidth = math.max(autocompleteWidth, maxBounds)

			item.gui = button
		end

		const text = self._entry.TextBox.Text
		const words = CmdrClient.Util.SplitString(text)
		if text:sub(#text, #text) == " " and not displayOptions.at then
			words[#words + 1] = "e"
		end

		table.remove(words, #words)

		const positionOffset = (displayOptions.at or (#table.concat(words, " ") + 1)) * 7
		const sizeOffset = UDim2.fromOffset(autocompleteWidth, autoCompleteFrame.UIListLayout.AbsoluteContentSize.Y)
		self:_updateContainerPosition(positionOffset)
		autoCompleteFrame.Size = sizeOffset
		autoCompleteFrame.Visible = true

		self:_updateInfoDisplay(if self.Items[1] and self.Items[1].options then self.Items[1].options else displayOptions)
	end

	--[=[
		@within AutoComplete
		Returns the selected autocomplete item.
	]=]
	function AutoComplete:GetSelectedItem(): AutocompleteItem?
		if not autoCompleteFrame.Visible then
			return nil
		end

		return self.Items[self.SelectedItem]
	end

	--[=[
		@within AutoComplete
		Hides the autocomplete menu.
	]=]
	function AutoComplete:Hide()
		autoCompleteFrame.Visible = false
	end

	--[=[
		@within AutoComplete
		Returns whether autocomplete is visible.
	]=]
	function AutoComplete:IsVisible(): boolean
		return autoCompleteFrame.Visible
	end

	--[=[
		@within AutoComplete
		Changes the current selection.
	]=]
	function AutoComplete:Select(delta: number)
		if not autoCompleteFrame.Visible then
			return
		end

		self.SelectedItem += delta

		if self.SelectedItem > #self.Items then
			self.SelectedItem = 1
		elseif self.SelectedItem < 1 then
			self.SelectedItem = #self.Items
		end

		for index, item in ipairs(self.Items) do
			local button = item.gui
			if button then
				button.BackgroundTransparency = if index == self.SelectedItem then 0.5 else 1
			end
		end

		const headerHeight = self._title.Size.Y.Offset + self._description.Size.Y.Offset
		const itemPosition = self.SelectedItem * self._autoItem.Size.Y.Offset
		const ySize = headerHeight + itemPosition - autoCompleteFrame.Size.Y.Offset
		autoCompleteFrame.CanvasPosition = Vector2.new(0, math.max(0, ySize))

		const selectedItem = self.Items[self.SelectedItem]
		if selectedItem and selectedItem.options then
			self:_updateInfoDisplay(selectedItem.options)
		end
	end

	AutoComplete._autoItem.Parent = nil
	autoCompleteFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateContainerSize)

	return AutoComplete
end
