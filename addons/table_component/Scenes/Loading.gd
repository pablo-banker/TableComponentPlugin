extends Control

@export var texture : Texture2D : set = set_texture

func set_texture(value) -> void:
	texture = value
	if texture:
		$Icon.texture = texture
