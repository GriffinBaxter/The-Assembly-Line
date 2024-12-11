extends Node3D

const CHAIR = preload("res://Scenes/chair.tscn")


func _ready() -> void:
	while true:
		var chair = CHAIR.instantiate()
		chair.position = Vector3(-10, 2, -2.5)
		get_tree().get_root().add_child.call_deferred(chair)
		get_tree().create_tween().tween_property(chair, "position", Vector3(10, 2, -2.5), 15)
		await get_tree().create_timer(10).timeout

		get_tree().get_root().remove_child(chair)
