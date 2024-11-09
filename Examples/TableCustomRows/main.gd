extends Control

const CUSTOM_ROW_INST := preload("res://Examples/TableCustomRows/custom_row.tscn")

@onready var _table_component := $TableComponent

var total = 0
var page = 1
var limit = 10

func _ready() -> void:
	_table_component.set_header()
	
	var rows  : Array[TableRowComponent] = []
	for i in range(50):
		var row = CUSTOM_ROW_INST.instantiate()
		rows.append(row)
	
	total = rows.size()
		
	_table_component.custom_rows = rows
	_table_component.set_rows(limit, page)
	_table_component.set_pagination(get_actual_page_index(), total)

func _on_search_text_changed(new_text: String) -> void:
	page = 1
	refresh_data()

func _on_table_component_on_next_page() -> void:
	if limit * page >= total:
		return
	page += 1

	refresh_data()

func _on_table_component_on_previous_page() -> void:
	if page <= 1:
		return
	page -= 1
	
	refresh_data()

func refresh_data():
	var data = _table_component.static_refresh("name", $Search.text, limit, page)
	if data.code != OK:
		return
	
	total = data.total
	_table_component.set_pagination(get_actual_page_index(), total)

func get_actual_page_index() -> int:
	var items = limit * page
	if items > total:
		items = total
	
	return items
