extends Control

signal resume
signal mouse_sensitivity


func _on_resume_game_pressed() -> void:
	resume.emit()


func _on_fullscreen_pressed() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_mouse_sensitivity_value_changed(value: float) -> void:
	mouse_sensitivity.emit(value)
