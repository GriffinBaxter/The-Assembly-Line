extends Node3D

@export var missing_part: CSGPrimitive3D

var assembled := false


func _ready() -> void:
	missing_part.visible = false


func get_missing_part_file_path() -> String:
	return missing_part.scene_file_path


func add_missing_part() -> void:
	missing_part.visible = true
	assembled = true
