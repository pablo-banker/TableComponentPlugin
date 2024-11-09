extends Resource
class_name TableEntity

@export var id : String
@export var title : String
@export var width : float

func _init(_id : String = "", _title : String = "", _width : float = 0.0) -> void:
	id = _id
	title = _title
	width = _width
