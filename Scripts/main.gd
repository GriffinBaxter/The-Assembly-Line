extends Node3D

@export var base_assemblies: Array[PackedScene]
@export var additional_assemblies: Array[PackedScene]
@export var tutorial_debug := false

var current_assemblies: Array[PackedScene]
var assembly: CSGPrimitive3D
var rng = RandomNumberGenerator.new()
var actions := [action_1, action_2, action_3, action_4, action_5]
var current_action := -1

@onready var phone: CSGBox3D = $Player/Head/Camera3D/Phone
@onready var additional_parts: Node3D = $Parts/AdditionalParts


func _ready() -> void:
	additional_parts.position -= Vector3(0, 10, 0)
	current_assemblies = base_assemblies
	phone.phone_hidden.connect(next_action)
	phone.show_phone(
		(
			"Welcome to the job. You can move with WASD, jump with space, and pick up/drop the "
			+ "assembly parts on the pedestals beside you.\n\n-Boss"
			+ '\n\n(P.S. Press "Enter" to close this message)'
		)
	)


func next_action() -> void:
	current_action += 1
	if current_action < actions.size():
		actions[current_action].call()


func assembly_line_loop() -> void:
	if !tutorial_debug:
		var assembly_index = rng.randi_range(0, current_assemblies.size() - 1)
		assembly = current_assemblies[assembly_index].instantiate()
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
	for i in range(3):
		await assembly_line_loop()
	next_action()


func action_3() -> void:
	additional_parts.position += Vector3(0, 9, 0)
	get_tree().create_tween().tween_property(
		additional_parts,
		"position",
		Vector3(
			additional_parts.position.x,
			additional_parts.position.y + 1,
			additional_parts.position.z
		),
		1
	)
	phone.show_phone(
		(
			"FYI: we're not just making furniture anymore, we're expanding our lineup.\n\n"
			+ "Look to your right to find the new parts.\n\n-Boss"
		)
	)


func action_4() -> void:
	current_assemblies = additional_assemblies
	for i in range(3):
		await assembly_line_loop()
	base_assemblies.append_array(additional_assemblies)
	current_assemblies = base_assemblies
	await assembly_line_loop()
	next_action()


func action_5() -> void:
	phone.show_phone(
		(
			"Hey, you might get a bonus if you use cheaper parts!\n\nThe grey table leg "
			+ "and the candle are the most inexpensive options...\n\n-Dodgy co-worker"
		)
	)


func action_6() -> void:
	await assembly_line_loop()
	next_action()


func action_7() -> void:
	phone.show_phone(
		(
			"The laptop screen is super expensive, try to never use that.\n\n"
			+ "I wonder what the next best option is?\n\n-Dodgy co-worker"
		)
	)


func action_8() -> void:
	while true:
		await assembly_line_loop()
