extends Node3D

@export var missing_parts: Array[CSGPrimitive3D]

var assembled := false
var part_attached: String


func _ready() -> void:
	for part in missing_parts:
		part.visible = false


func get_missing_part_file_paths() -> PackedStringArray:
	var missing_part_file_paths: PackedStringArray = []
	for part in missing_parts:
		missing_part_file_paths.append(part.scene_file_path)
	return missing_part_file_paths


func add_missing_part(part_file_path: String) -> void:
	for part in missing_parts:
		if part.scene_file_path == part_file_path:
			part.visible = true
			part_attached = part.scene_file_path
			break
	assembled = true
