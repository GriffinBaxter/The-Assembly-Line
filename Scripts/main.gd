extends Node3D

const ASSEMBLY_LINE_INDENT = preload("res://Scenes/assembly_line_indent.tscn")

@export var base_assemblies: Array[PackedScene]
@export var additional_assemblies: Array[PackedScene]
@export var tutorial_debug := false

var current_assemblies: Array[PackedScene]
var assembly: CSGPrimitive3D
var rng = RandomNumberGenerator.new()
var actions := [action_1, action_2, action_3, action_4, action_5, action_6]
var current_action := -1
var part_attached_scene_file_path := ""
var score := {"customer_ratings": [4], "part_efficiencies": [1]}
var customer_ratings_avg: float
var part_efficiencies_avg: float
var main_menu := load("res://Scenes/main_menu.tscn")
var paused := false

@onready var phone: CSGBox3D = $Player/Head/Camera3D/Phone
@onready var tv: CSGBox3D = $TV
@onready var additional_parts: Node3D = $Parts/AdditionalParts
@onready var exit: CSGBox3D = $Room/Exit
@onready var exit_light: OmniLight3D = $Room/Exit/ExitLight
@onready var fade_in_out: Control = $FadeInOut
@onready var colour_rect: ColorRect = $FadeInOut/ColourRect
@onready var pause_menu: Control = $PauseMenu
@onready var assembly_line: CSGBox3D = $Room/AssemblyLine
@onready var ending_text: RichTextLabel = $FadeInOut/EndingText


func _ready() -> void:
	additional_parts.position -= Vector3(0, 10, 0)
	current_assemblies = base_assemblies
	pause_menu.resume.connect(pause_menu_toggled)
	phone.phone_hidden.connect(next_action)
	phone.show_phone(
		(
			"Welcome to the job. You can move with WASD, jump with space, and press E to"
			+ " pick up/drop the assembly parts on the pedestals beside you.\n\n-Boss"
			+ '\n\n(P.S. Press "Enter" to close this message)'
		)
	)
	create_assembly_line_indents()


func create_assembly_line_indents() -> void:
	while true:
		var assembly_line_indent = ASSEMBLY_LINE_INDENT.instantiate()
		assembly_line.add_child.call_deferred(assembly_line_indent)
		assembly_line_indent.position.x -= 15
		get_tree().create_tween().tween_property(
			assembly_line_indent,
			"position",
			Vector3(15, assembly_line_indent.position.y, assembly_line_indent.position.z),
			15
		)
		await get_tree().create_timer(0.1).timeout
		delete_assembly_line_indent_when_done(assembly_line_indent)


func delete_assembly_line_indent_when_done(assembly_line_indent: MeshInstance3D) -> void:
	await get_tree().create_timer(14.9).timeout
	assembly_line_indent.queue_free()


func _on_room_area_body_exited(body: Node3D) -> void:
	if body.name == "Player":
		fade_in_out.visible = true
		get_tree().create_tween().tween_property(colour_rect, "color", Color(0, 0, 0, 1), 3.5)
		get_tree().create_tween().tween_property(ending_text, "modulate", Color(1, 1, 1, 1), 3.5)
		await get_tree().create_timer(3.5).timeout
		get_tree().change_scene_to_packed(main_menu)


func pause_menu_toggled() -> void:
	paused = !paused
	if paused:
		pause_menu.show()
		Engine.time_scale = 0
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		pause_menu.hide()
		Engine.time_scale = 1
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


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

		assembly.position += Vector3(-15, 1.9, -2.5)
		get_tree().create_tween().tween_property(
			assembly, "position", Vector3(15, assembly.position.y, -2.5), 15
		)
		await get_tree().create_timer(15).timeout

		update_score_and_tv()
		get_tree().get_root().remove_child(assembly)


func update_score_and_tv():
	if assembly.scene_file_path.contains("chair"):
		if !assembly.assembled:
			tv.update_text("★★✰✰✰\n\nMissing a leg, which isn't ideal...")
			update_score(2, 5)
		elif assembly.part_attached.contains("leg_red"):
			tv.update_text("★★★★★\n\nPerfect, I love the red colour!")
			update_score(5, 2)
		elif assembly.part_attached.contains("leg_blue"):
			tv.update_text("★★★✰✰\n\nOne of the legs is the wrong colour but that's okay...")
			update_score(3, 2)
		elif assembly.part_attached.contains("leg_grey"):
			tv.update_text("★★★✰✰\n\nOne of the legs was not painted but that's okay...")
			update_score(3, 4)
		elif assembly.part_attached.contains("laptop_screen"):
			tv.update_text(
				(
					"★★✰✰✰\n\nOne of the legs looks to be some sort of screen,"
					+ " which is sturdy at least..."
				)
			)
			update_score(2, 1)
		elif assembly.part_attached.contains("candle"):
			tv.update_text("★✰✰✰✰\n\nOne of the legs is a CANDLE???")
			update_score(1, 4)
		elif assembly.part_attached.contains("light_bulb"):
			tv.update_text("★✰✰✰✰\n\nOne of the legs is a LIGHT BULB???")
			update_score(1, 3)
	elif assembly.scene_file_path.contains("table"):
		if !assembly.assembled:
			tv.update_text("★★✰✰✰\n\nMissing a leg, which isn't ideal...")
			update_score(2, 5)
		elif assembly.part_attached.contains("leg_blue"):
			tv.update_text("★★★★★\n\nPerfect, I love the blue colour!")
			update_score(5, 2)
		elif assembly.part_attached.contains("leg_red"):
			tv.update_text("★★★✰✰\n\nOne of the legs is the wrong colour but that's okay...")
			update_score(3, 2)
		elif assembly.part_attached.contains("leg_grey"):
			tv.update_text("★★★✰✰\n\nOne of the legs was not painted but that's okay...")
			update_score(3, 4)
		elif assembly.part_attached.contains("laptop_screen"):
			tv.update_text(
				(
					"★★✰✰✰\n\nOne of the legs looks to be some sort of screen,"
					+ " which is sturdy at least..."
				)
			)
			update_score(2, 1)
		elif assembly.part_attached.contains("candle"):
			tv.update_text("★✰✰✰✰\n\nOne of the legs is a CANDLE???")
			update_score(1, 4)
		elif assembly.part_attached.contains("light_bulb"):
			tv.update_text("★✰✰✰✰\n\nOne of the legs is a LIGHT BULB???")
			update_score(1, 3)
	elif assembly.scene_file_path.contains("cake"):
		if !assembly.assembled:
			tv.update_text("★★✰✰✰\n\nI thought it was supposed to include a candle?")
			update_score(2, 5)
		elif (
			assembly.part_attached.contains("leg_blue")
			or assembly.part_attached.contains("leg_red")
		):
			tv.update_text(
				(
					"★★✰✰✰\n\nIf I wanted a metal rod inserted into the cake"
					+ "I would've asked... apart from that it's okay"
				)
			)
			update_score(2, 2)
		elif assembly.part_attached.contains("leg_grey"):
			tv.update_text(
				(
					"★★✰✰✰\n\nIf I wanted a metal rod inserted into the cake"
					+ "I would've asked... apart from that it's okay"
				)
			)
			update_score(2, 4)
		elif assembly.part_attached.contains("laptop_screen"):
			tv.update_text(
				(
					"★★✰✰✰\n\nI'm not sure why a screen was inserted into the cake"
					+ "but I'll take it I guess..."
				)
			)
			update_score(2, 1)
		elif assembly.part_attached.contains("candle"):
			tv.update_text("★★★★★\n\nBeautiful cake, thanks!")
			update_score(5, 4)
		elif assembly.part_attached.contains("light_bulb"):
			tv.update_text(
				"★★★✰✰\n\nUsing a light bulb instead of a candle was unique to say the least"
			)
			update_score(3, 3)
	elif assembly.scene_file_path.contains("lamp"):
		if !assembly.assembled:
			tv.update_text(
				(
					'★★✰✰✰\n\n"Light bulb included seperately"'
					+ " would've been nice to include on the box"
				)
			)
			update_score(2, 5)
		elif (
			assembly.part_attached.contains("leg_blue")
			or assembly.part_attached.contains("leg_red")
		):
			tv.update_text(
				(
					"★✰✰✰✰\n\nCertainly a manufacturing defect here, "
					+ "there's a metal rod protruding out where the light bulb should be..."
				)
			)
			update_score(1, 2)
		elif assembly.part_attached.contains("leg_grey"):
			tv.update_text(
				(
					"★✰✰✰✰\n\nCertainly a manufacturing defect here, "
					+ "there's a metal rod protruding out where the light bulb should be..."
				)
			)
			update_score(1, 4)
		elif assembly.part_attached.contains("laptop_screen"):
			tv.update_text(
				"★★✰✰✰\n\nThese new lamps with built-in screens are far too advanced for me"
			)
			update_score(2, 1)
		elif assembly.part_attached.contains("candle"):
			tv.update_text(
				'★★★✰✰\n\nI didn\'t think a candle is what they meant by "no batteries included"'
			)
			update_score(3, 4)
		elif assembly.part_attached.contains("light_bulb"):
			tv.update_text("★★★★★\n\nI love lamp!")
			update_score(5, 3)
	elif assembly.scene_file_path.contains("laptop"):
		if !assembly.assembled:
			tv.update_text(
				(
					'★★✰✰✰\n\n"Screen included seperately"'
					+ " would've been nice to include on the box"
				)
			)
			update_score(2, 5)
		elif (
			assembly.part_attached.contains("leg_blue")
			or assembly.part_attached.contains("leg_red")
		):
			tv.update_text(
				(
					"★✰✰✰✰\n\nCertainly a manufacturing defect here, "
					+ "there's a metal rod protruding out where the screen should be..."
				)
			)
			update_score(1, 3)
		elif assembly.part_attached.contains("leg_grey"):
			tv.update_text(
				(
					"★✰✰✰✰\n\nCertainly a manufacturing defect here, "
					+ "there's a metal rod protruding out where the screen should be..."
				)
			)
			update_score(1, 4)
		elif assembly.part_attached.contains("laptop_screen"):
			tv.update_text("★★★★★\n\nFantastic laptop, great screen")
			update_score(5, 2)
		elif assembly.part_attached.contains("candle"):
			tv.update_text(
				"★✰✰✰✰\n\nA bit medieval... why is there is a candle instead of a screen???"
			)
			update_score(1, 4)
		elif assembly.part_attached.contains("light_bulb"):
			tv.update_text(
				(
					"★★✰✰✰\n\nI knew the screen was low resolution,"
					+ " but I didn't think it would just be a single pixel..."
				)
			)
			update_score(2, 3)


func update_score(customer_rating: int, part_efficiency: int) -> void:
	score.customer_ratings.append(customer_rating)
	score.part_efficiencies.append(part_efficiency)


func average(array: Array) -> float:
	return float(array.reduce(sum, 0)) / float(array.size())


func sum(accumulator: int, number: int) -> int:
	return accumulator + number


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


func action_3() -> void:
	current_assemblies = additional_assemblies
	for i in range(3):
		await assembly_line_loop()
	base_assemblies.append_array(additional_assemblies)
	current_assemblies = base_assemblies
	await assembly_line_loop()
	phone.show_phone(
		(
			"Hey, you might get a bonus if you use cheaper parts!\n\nThe grey table leg "
			+ "and the candle are the most inexpensive options...\n\n-Dodgy co-worker"
		)
	)


func action_4() -> void:
	await assembly_line_loop()
	phone.show_phone(
		(
			"The laptop screen is super expensive, try to never use that.\n\n"
			+ "I wonder what the next best option is?\n\n-Dodgy co-worker"
		)
	)


func action_5() -> void:
	for i in range(4):
		await assembly_line_loop()
	customer_ratings_avg = average(score.customer_ratings)
	part_efficiencies_avg = average(score.part_efficiencies)
	if customer_ratings_avg < 2.5 and part_efficiencies_avg < 2.5:
		phone.show_phone(
			"What have you been doing??? Horrible job all round, you're fired.\n\n-Boss"
		)
		ending_text.text = "Ending 1 / 5"
	elif customer_ratings_avg >= 2.5 and part_efficiencies_avg < 2.5:
		phone.show_phone(
			(
				"We're going to have to let you go. The parts we're using are too expensive"
				+ "\n\n...and we figured a robot could do your job cheaper.\n\n-Boss"
			)
		)
		ending_text.text = "Ending 2 / 5"
	elif customer_ratings_avg < 2.5 and part_efficiencies_avg >= 2.5:
		phone.show_phone(
			"Our customers are FURIOUS, and we're getting less sales! You're fired.\n\n-Boss"
		)
		ending_text.text = "Ending 3 / 5"
	else:
		phone.show_phone(
			(
				"Adequate work! As a bonus, we're going to not fire you.\n\nThat dodgy "
				+ "co-worker of yours, however, is terminated effective immediately.\n\n-Boss"
			)
		)
		ending_text.text = "Ending 4 / 5"


func action_6() -> void:
	if customer_ratings_avg >= 2.5 and part_efficiencies_avg >= 2.5:
		for i in range(100):
			await assembly_line_loop()
	exit.position = Vector3(0, -4.75, 6)
	exit_light.light_energy = 0
	get_tree().create_tween().tween_property(exit, "position", Vector3(0, -2.25, 6), 1.5)
	get_tree().create_tween().tween_property(exit_light, "light_energy", 1, 1.5)
	exit.visible = true
