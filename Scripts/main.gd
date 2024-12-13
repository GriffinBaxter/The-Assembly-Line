extends Node3D

@export var assemblies: Array[PackedScene]

var assembly: CSGPrimitive3D
var rng = RandomNumberGenerator.new()


func _ready() -> void:
	while true:
		var assembly_index = rng.randi_range(0, assemblies.size() - 1)
		assembly = assemblies[assembly_index].instantiate()
		get_tree().get_root().add_child.call_deferred(assembly)
		await assembly.ready

		assembly.position += Vector3(-10, 1.9, -2.5)
		get_tree().create_tween().tween_property(
			assembly, "position", Vector3(10, assembly.position.y, -2.5), 15
		)
		await get_tree().create_timer(15).timeout

		get_tree().get_root().remove_child(assembly)
