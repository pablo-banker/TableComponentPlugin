extends TextureButton
class_name TableTextureButton

@export var unscale_on_click : bool = true
@export var rotate_on_click : bool = false

@export var size_decrease_on_click : int = 15

var opened = false

var is_pressing : bool = false
signal on_click()

func _ready() -> void:
	pressed.connect(on_pressed)

func on_pressed() -> void:
	if is_pressing:
		return
	is_pressing = true
	
	if unscale_on_click: 
		var actual_size : Vector2 = size
		
		
		custom_minimum_size = Vector2(size.x - size_decrease_on_click, size.y - size_decrease_on_click)
		
		var tween = get_tree().create_tween()
		var tween_position = get_tree().create_tween()
		
		tween.tween_property(self, "size", Vector2(size.x - size_decrease_on_click, size.y - size_decrease_on_click), 0.075)
		tween.tween_property(self, "size", actual_size, 0.075)
		
		var position_size = size_decrease_on_click / 2
		tween_position.tween_property(self, "position", Vector2(position_size, position_size), 0.075)
		tween_position.tween_property(self, "position", Vector2(0.0, 0.0), 0.075)
		
		await tween_position.finished
	
	if rotate_on_click:
		rotate()
		
	is_pressing = false
	on_click.emit()

var is_rotating : bool = false
var target_rotation : float = 360.0

func rotate() -> void:
	is_rotating = true
	set_rotation_degrees(0.0)
	pivot_offset = Vector2(size.x / 2, size.y / 2)

func make_scale():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)

func unscale():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.15)

func _process(_delta):
	if is_rotating:
		var current_rotation : float = rotation_degrees
		var new_rotation : float = lerp(current_rotation, target_rotation, 0.1)
		set_rotation_degrees(new_rotation)

		if abs(new_rotation - target_rotation) < 0.1:
			set_rotation_degrees(target_rotation)
			is_rotating = false
