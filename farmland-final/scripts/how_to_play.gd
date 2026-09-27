extends Control

@onready var close: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Handles the Home button by playing its button sound and changing the current
# scene to the main menu. This gives the player audio feedback before leaving
# the current screen.
func _on_home_pressed() -> void:
	close.play()
	await close.finished
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
