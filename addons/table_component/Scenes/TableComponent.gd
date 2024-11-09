@icon('./../Icons/table_icon.svg')

extends VBoxContainer
class_name TableComponent

## TableComponent: Component responsible for displaying and managing table-like data with header, rows, pagination, and search functionalities.

# Constants
const INST_TABLE_ROW = preload("./Row/TableRowComponent.tscn")

# Ready variables to control table elements
@onready var _table := $Table
@onready var _table_header := $Table/Header
@onready var _table_rows := $Table/ScrollContainer/Rows
@onready var _scroll_container := $Table/ScrollContainer
@onready var _global_loading := $UILoading
@onready var _loading := $Table/UILoading
@onready var _pagination := $Pagination
@onready var _pagination_pages := $Pagination/HBoxContainer/Pages
@onready var _pagination_previous := $Pagination/HBoxContainer/Previous/TableTextureButton
@onready var _pagination_next := $Pagination/HBoxContainer/Next/TableTextureButton
@onready var _search_not_found := $Table/ScrollContainer/Rows/SearchNotFound
@onready var _search_not_found_label := $Table/ScrollContainer/Rows/SearchNotFound/Label

# Table display options
var font : FontFile
var font_size : float

# Table properties
@export var pagination : bool = false
@export var global_loading : bool = false
@export var loading : bool = false
@export var loading_texture : Texture2D = load("res://addons/table_component/Icons/loading.svg")

# Header settings
@export_group("Header")
@export var header : Array[TableEntity]
@export var header_font_size : float
@export var header_font : FontFile

# Row settings
@export_group("Rows")
@export var rows : Array[Array] = [["row0"],]
@export var row_font_size : float
@export var row_font : FontFile
@export_subgroup("Custom")
@export var custom_rows : Array[TableRowComponent]

# Signals for interaction events
signal on_row_pressed(data : Dictionary)
signal on_list_rows(rows)
signal on_next_page
signal on_previous_page

# Enum for result statuses
enum {
	OK,
	ERR_COLUMN_NOT_FOUND,
	ERR_NO_MATCH_VALUE
}

var header_separator : VSeparator
var last_row = null

func _ready() -> void:
	_global_loading.texture = loading_texture
	_loading.texture = loading_texture
	
	if header_font:
		$Table/ScrollContainer/Rows/SearchNotFound/Label.add_theme_font_override("font", header_font)

func _process(delta: float) -> void:
	if header_separator:
		header_separator.set_visible(_table_rows.size.y > _scroll_container.size.y)
	
	_global_loading.set_visible(global_loading)
	_table.set_visible(!global_loading)
	
	_loading.set_visible(loading)
	_scroll_container.set_visible(!loading)
	_pagination.set_visible(pagination and !loading)

func set_header():
	for child in _table_header.get_children():
		if child.is_in_group("static"):
			continue
		child.queue_free()
	
	for idx in header.size():
		var data = header[idx]
		
		var label = Label.new()
		if data.id:
			label.name = data.id
		label.text = data.title
		label.uppercase = true
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size_flags_vertical = Control.SIZE_FILL
		
		#Check if is the last one and put the correct type variation
		var has_more = idx + 1 < header.size()
		label.theme_type_variation = "HeaderLabel" if has_more else "HeaderLastLabel"
		
		if data.width:
			label.custom_minimum_size = Vector2(data.width, 0.0)
		else:
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		if header_font_size:
			label.add_theme_font_size_override("font_size", header_font_size)
		
		if header_font:
			label.add_theme_font_override("font", header_font)

		_table_header.add_child(label)
		
		if !has_more:
			header_separator = VSeparator.new()
			header_separator.add_theme_constant_override("separation", 8)
			header_separator.add_theme_stylebox_override("separator",StyleBoxEmpty.new())
			_table_header.add_child(header_separator)

func set_rows(limit = 0, page_index = 0 ):
	for child in _table_rows.get_children():
		if child.is_in_group("static"):
			continue

		child.queue_free()
	
	if custom_rows.is_empty():
		for idx in rows.size():
			var row = rows[idx]
			var table_row : TableRowComponent = INST_TABLE_ROW.instantiate()
			_table_rows.add_child(table_row)
			table_row.on_row_pressed.connect(_on_row_pressed)
			table_row.set_row(header, row, idx + 1, row_font_size, row_font)
	else:
		for idx in custom_rows.size():
			var row : TableRowComponent = custom_rows[idx]
			_table_rows.add_child(row)
			row.on_row_pressed.connect(_on_row_pressed)
			row.set_row(header, [], idx + 1, row_font_size, row_font)
		
		
	if limit and page_index:
		var start_index = (page_index - 1) * limit
		var end_index = start_index + limit
		
		var row_count = 0
		for row in _table_rows.get_children():
			if row.is_in_group("static"):
				continue
			
			# Determine the visibility of each row based on pagination
			var is_within_page = row_count >= start_index and row_count < end_index
			row.visible = is_within_page
			
			row_count += 1
	
	await get_tree().process_frame
	on_list_rows.emit(_table_rows.get_children().filter(func(row): return !row.is_in_group("static")))

## Searches for values within a specific column and sets the visibility of rows based on the search term.
## Parameters:
## - column_id: (String) The ID of the column to search within.
## - value: (String) The value to search for in the specified column.
## - limit: (int) The maximum number of rows to display per page.
## - page_index: (int) The starting index of the page to display.
## Returns:
## - OK if successful.
## - ERR_COLUMN_NOT_FOUND if the specified column ID does not exist.
## - ERR_NO_MATCH_VALUE if no rows match the search term.
func static_refresh(column_id: String, value: String, limit: int, page: int) -> Dictionary:
	var column_index = -1
	
	# Find the column index that matches the column_id
	for i in range(_table_header.get_child_count()):
		if _table_header.get_child(i).name == column_id:
			column_index = i
			break
	
	if column_index == -1:
		print("Column ID not found")
		return {
			"code": ERR_COLUMN_NOT_FOUND
		}
	
	var search_value = value.to_lower()
	var found_match = false
	var row_count = 0
	
	
	var start_index = (page - 1) * limit
	var end_index = start_index + limit
	# Loop through rows and apply search visibility based on pagination limits
	for row in _table_rows.get_children():
		if row.is_in_group("static"):
			continue
		
		var row_value = str(row.get_value_by_index(column_index)).to_lower()
		var match_found = (search_value == "" or row_value.findn(search_value) != -1)
		
		# Calculate pagination bounds
		row.visible = match_found
		
		if match_found:
			found_match = true
		
	for row in _table_rows.get_children():
		if row.is_in_group("static"):
			continue
		
		if !row.visible:
			continue
		
		var row_value = str(row.get_value_by_index(column_index)).to_lower()
		
		# Calculate pagination bounds
		var is_within_page = row_count >= start_index and row_count < end_index
		row.visible = is_within_page
		row_count += 1

	# Display the 'not found' message if no matches are within the current page
	_search_not_found.set_visible(!found_match)
	return {
		"code": OK if found_match else ERR_NO_MATCH_VALUE,
		"total": row_count
	}

## This function is used to search rows based on data received.
## Will check each dictionary of data, verifing if its exists or not on table
## Each data should have a id field
func iterate_refresh(new_data, row_inst: Resource = null, limit : int = 100, page_index : int = 100) -> int:
	var row_preload = INST_TABLE_ROW if row_inst == null else row_inst
	
	# Get all current rows from table
	var current_rows = _table_rows.get_children()
	var new_ids = new_data.map(func(d): return d.id) if new_data else []

	# First part: Set visibility to false for rows without the same ID as the received data
	for row in current_rows:
		if row.is_in_group("static"):
			continue
		
		if row.data.id in new_ids:
			row.visible = true
		else:
			row.visible = false
		
	_search_not_found.set_visible(!new_ids)
	if !new_ids:
		return ERR_NO_MATCH_VALUE
	
	# Second part: Check if any new_data info is missing in the visible lines and instantiate the missing ones
	var visible_rows = current_rows.filter(func(row): return row.visible and !row.is_in_group("static"))
	var visible_ids = visible_rows.map(func(row): return row.data.id)
	for idx in range(new_data.size()):
		var data = new_data[idx]
		if data.id not in visible_ids:
			var new_row : TableRowComponent = row_preload.instantiate()
			new_row.data = data
			new_row.on_row_pressed.connect(_on_row_pressed)
			new_row.set_row(header, [], (page_index - new_data.size()) + (idx + 1), row_font_size, row_font)
			
			var inserted = false
			for i in range(_table_rows.get_child_count()):
				var existing_row = _table_rows.get_child(i)
				if existing_row.is_in_group("static"):
					continue
				
				if data.has('position'):
					if existing_row.data.position > data.position:
						_table_rows.add_child(new_row, true)
						_table_rows.move_child(new_row, i)
						inserted = true
						break
						print("idx: ", idx, " ", " existing createdAt: ", parse_date_time(existing_row.data.createdAt), " ", " new createdAt: ", parse_date_time(data.createdAt))
				elif data.has('created_at') and parse_date_time(existing_row.data.created_at) < parse_date_time(data.created_at):				
					_table_rows.add_child(new_row, true)
					_table_rows.move_child(new_row, i)
					inserted = true
					break
					
			if not inserted:
				_table_rows.add_child(new_row)

			visible_ids.append(data.id)
			visible_rows.append(new_row)
		else:
			var actual_rows = visible_rows.filter(func(row): return row.data.id == data.id)
			for row in actual_rows:
				row.data = data
				row.set_row(header, [], (page_index - new_data.size()) + (idx + 1), row_font_size, row_font)

	# Third part: Checking the limit, always removing the excess from the last lines
	while visible_rows.size() > limit:
		var row_to_remove = visible_rows.pop_back()
		row_to_remove.queue_free()
	
	on_list_rows.emit(_table_rows.get_children().filter(func(row): return !row.is_in_group("static") ))
	
	return OK

func parse_date_time(date_string: String) -> int:
	return Time.get_unix_time_from_datetime_string(date_string)

func _on_row_pressed(data : Dictionary):
	on_row_pressed.emit(data)

func set_search_not_found(value : bool):
	_search_not_found.set_visible(value)

func set_pagination(items : int, total : int, page : int = 1):
	_pagination_pages.text = "%d / %d" % [items, total]
	
	#previous_page_disabled(items >= total)
	#next_page_disabled(page <= 1)

func _on_next_pressed() -> void:
	on_next_page.emit()

func _on_previous_pressed() -> void:
	on_previous_page.emit()

func next_page_disabled(value : bool = true):
	_pagination_next.disabled = value
	
func previous_page_disabled(value : bool = true):
	_pagination_previous.disabled = value

func no_rows_found(value : bool, text = "No matching value found."):
	_search_not_found.set_visible(value)
	_search_not_found_label.text = text
