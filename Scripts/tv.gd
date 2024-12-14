extends CSGBox3D

@onready var tv_text: Label3D = $ScreenBody/Screen/TvText


func _ready() -> void:
	tv_text.text = ""


func update_text(text: String) -> void:
	tv_text.text = text
