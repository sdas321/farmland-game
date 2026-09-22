extends Node

@onready var time_label: Label = $time2/time_label
@onready var day_label: Label = $time2/day_label

# Connects the time display to the main game clock when the scene loads.
func _ready() -> void:
	var main_game = get_tree().current_scene
	if main_game and main_game.has_signal("game_time_updated"):
		main_game.game_time_updated.connect(_on_game_time_updated)

# Updates the displayed time and day whenever the game clock changes.
func _on_game_time_updated(hour: int, minute: int, day: int) -> void:
	time_label.text = "%02d:%02d" % [hour, minute]
	day_label.text = "Day: " + str(day)
