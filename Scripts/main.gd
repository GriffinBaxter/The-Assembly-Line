extends Node3D

@export var assemblies: Array[PackedScene]

var assembly: CSGPrimitive3D
var rng = RandomNumberGenerator.new()
var actions := [action_1, action_2]
var current_action := -1

@onready var phone: CSGBox3D = $Player/Head/Camera3D/Phone


func _ready() -> void:
	phone.phone_hidden.connect(_on_phone_hidden)
	phone.show_phone(
		(
			"Welcome to the job. You can move with WASD, jump with space, and pick up/drop the "
			+ "assembly parts on the pedestals beside you.\n\n-Boss"
			+ '\n\n(P.S. Press "Enter" to close this message)'
		)
	)


func _on_phone_hidden() -> void:
	current_action += 1
	if current_action < actions.size():
		actions[current_action].call()


func assembly_line_loop() -> void:
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


func action_1() -> void:
	phone.show_phone(
		(
			"Also, remember the rules!\n\nWhile assembling, "
			+ "make sure you're using the right parts, and the correct colours.\n\n-Boss"
		)
	)


func action_2() -> void:
	while true:
		await assembly_line_loop()
