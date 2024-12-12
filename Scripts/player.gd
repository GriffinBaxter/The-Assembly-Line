extends CharacterBody3D

const SPEED := 5.0
const JUMP_VELOCITY := 4.5
const SENSITIVITY := 0.002

@export var parts: Array[CSGPrimitive3D]

var held_part: CSGPrimitive3D

@onready var head: Node3D = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D
@onready var main: Node3D = $".."


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)


func _process(_delta: float) -> void:
	move_and_slide()

	if held_part != null:
		if (
			held_part.global_position.distance_to(main.assembly.global_position) < 1
			and !main.assembly.assembled
			and main.assembly.get_missing_part_file_path() == held_part.scene_file_path
		):
			main.assembly.add_missing_part()
			held_part.queue_free()
		elif Input.is_action_just_pressed("interact"):
			held_part.queue_free()

	if Input.is_action_just_pressed("interact") and held_part == null:
		var min_part
		var min_distance = INF
		for part in parts:
			var distance_to_part = global_position.distance_to(part.global_position)
			if distance_to_part < min_distance and distance_to_part < 3:
				min_part = part
				min_distance = distance_to_part
		if min_part:
			held_part = min_part.duplicate()
			held_part.rotation = Vector3(0, 0, 0)
			held_part.position = Vector3(0, -0.5, -1.5)
			camera_3d.add_child(held_part)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x as float * SENSITIVITY)
		camera_3d.rotate_x(-event.relative.y as float * SENSITIVITY)
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, deg_to_rad(-60), deg_to_rad(60))
