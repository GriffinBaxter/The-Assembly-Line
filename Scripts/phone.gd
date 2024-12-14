extends CSGBox3D

signal phone_hidden

var phone_visible := false
var phone_moving := false

@onready var phone_text: Label3D = $Screen/PhoneText


func _ready() -> void:
	position -= Vector3(0, .2, 0)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("accept") and phone_visible and !phone_moving:
		hide_phone()


func show_phone(text: String) -> void:
	phone_text.text = text
	phone_moving = true
	get_tree().create_tween().tween_property(self, "position", position + Vector3(0, .2, 0), .5)
	await get_tree().create_timer(.5).timeout

	phone_moving = false
	phone_visible = true


func hide_phone():
	phone_moving = true
	get_tree().create_tween().tween_property(self, "position", position + Vector3(0, -.2, 0), .5)
	await get_tree().create_timer(.5).timeout

	phone_moving = true
	phone_visible = false
	phone_hidden.emit()
