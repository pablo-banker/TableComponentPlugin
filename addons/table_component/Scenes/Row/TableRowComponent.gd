@icon("./../../Icons/table_row_icon.svg")

extends Control
class_name TableRowComponent

@onready var _values := $Values
@onready var _position := $Values/Position

@export var data : Variant = null : set = set_data

signal on_row_pressed(data : Variant)

## Sets up the row with header and row data, customizing each cell with font and position.
## @param header Array[TableEntity] - Array containing the table headers, used to define column properties.
## @param row Array - Array of values for the row, each element corresponding to a column.
## @param position_idx int - Row position index used for display purposes.
## @param font_size int - Optional font size for the row's text. Default is 0.
## @param font FontFile - Optional font file for custom font style. Default is null.
func set_row(header : Array[TableEntity], row : Array, position_idx : int, font_size = 0, font : FontFile = null):	
	# Clear any existing, non-static children in the _values container.
	for child in _values.get_children():
		if child.is_in_group("static"):
			continue
		child.queue_free()
	
	# Display row position index.
	_position.text = "#%d" % position_idx
	
	# Override separation between values in the row.
	_values.add_theme_constant_override("separation", 0)
	
	# Loop through each header item to create and configure cells for the row.
	for idx in header.size():
		var data = header[idx]
		
		var label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size_flags_vertical = Control.SIZE_FILL
		
		# Determine the style of the cell based on its position (last or non-last).
		label.theme_type_variation = "RowLabel" if idx + 1 < header.size() else "RowLastLabel"
		
		# Apply width if specified, otherwise enable horizontal expansion.
		if data.width:
			label.custom_minimum_size = Vector2(data.width, 0.0)
		else:
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
		# Set font size override if a custom size is provided.
		if font_size:
			label.add_theme_font_size_override("font_size", font_size)
		
		# Apply custom font if provided.
		if font:
			label.add_theme_font_override("font", font)
			
		# Display placeholder or actual row data.
		if idx + 1 > row.size():
			label.text = "..."
		else:
			var value = row[idx]
			
			if value is String:
				label.text = value
			elif value is int or value is float:
				label.text = str(value)
			else:
				push_warning("The value of column %s has invalid class. Class: %s | Value: %s" % [data.title, value.get_class(), row[0]])
			
		_values.add_child(label)

## Sets the `data` variable for the row. This is useful for storing additional information associated with the row.
## @param value Variant - The data to associate with the row, often used in signals for handling events.
func set_data(value : Variant):
	data = value

## Retrieves the text value of a cell at a specified index in the row.
## @param idx int - The index of the cell to retrieve the value from.
## @return String - The text value of the cell at the specified index.
func get_value_by_index(idx : int):
	return $Values.get_child(idx).text

## Emits a signal when the row is pressed, passing the row's data as an argument.
func _on_button_pressed() -> void:
	on_row_pressed.emit(data)
