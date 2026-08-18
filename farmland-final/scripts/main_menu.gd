extends Control
var button_press= AudioStreamPlayer


func _on_play_pressed() -> void:
	$button_press.play()
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_how_to_play_pressed() -> void:
	$button_press.play()
	get_tree().change_scene_to_file("res://scenes/how_to_play.tscn")


func _on_quit_pressed() -> void:
	$button_press.play()
	get_tree().quit()
