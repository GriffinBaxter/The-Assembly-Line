extends Node3D

const CHAIR = preload("res://Scenes/chair.tscn")

var assembly: CSGPrimitive3D
var missing_part: CSGPrimitive3D


func _ready() -> void:
	while true:
		assembly = CHAIR.instantiate()
		assembly.position = Vector3(-10, 2.375, -2.5)
		get_tree().get_root().add_child.call_deferred(assembly)
		await assembly.ready

		var missing_part_file_path = assembly.get_missing_part_file_path()
		missing_part = ResourceLoader.load(missing_part_file_path).instantiate()
		missing_part.position = Vector3(2, 2.5, -2)
		get_tree().get_root().add_child.call_deferred(missing_part)
		get_tree().create_tween().tween_property(assembly, "position", Vector3(10, 2.375, -2.5), 15)
		await get_tree().create_timer(15).timeout

		get_tree().get_root().remove_child(assembly)


func _process(_delta: float) -> void:
	if missing_part.position.distance_to(assembly.position) < 1:
		assembly.add_missing_part()
		missing_part.visible = false
