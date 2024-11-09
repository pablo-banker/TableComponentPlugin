extends Control

@onready var _table_component := $TableComponent

var total = 0
var page = 1
var limit = 10

func _ready() -> void:
	_table_component.set_header()
	
	var rows  : Array[Array] = []
	for i in range(50):
		rows.append([RowUtils.generate_random_first_name(), RowUtils.generate_random_age(), RowUtils.generate_random_feeling()])
	
	total = rows.size()
		
	_table_component.rows = rows
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
