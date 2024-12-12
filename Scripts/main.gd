extends Node3D

const CHAIR = preload("res://Scenes/chair.tscn")

var assembly: CSGPrimitive3D


func _ready() -> void:
	while true:
		assembly = CHAIR.instantiate()
		assembly.position = Vector3(-10, 2.375, -2.5)
		get_tree().get_root().add_child.call_deferred(assembly)
		await assembly.ready

		get_tree().create_tween().tween_property(assembly, "position", Vector3(10, 2.375, -2.5), 15)
		await get_tree().create_timer(15).timeout

		get_tree().get_root().remove_child(assembly)
