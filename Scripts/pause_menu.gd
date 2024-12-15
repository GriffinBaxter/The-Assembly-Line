extends Control

signal resume
signal mouse_sensitivity


func _on_resume_game_pressed() -> void:
	resume.emit()


func _on_mouse_sensitivity_value_changed(value: float) -> void:
	mouse_sensitivity.emit(value)
