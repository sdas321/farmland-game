extends Control
"res://scripts/day_and_night_cycle_manager.gd"



@onready var day_label: Label = $day_night/MarginContainer/day_label
@onready var time_label: Label= $time/MarginContainer/time_label

func _ready()->void:
	day_and_night_cycle_manager.time_tick.connect(on_time_tick)
	
func on_time_tick(day: int, hour: int, minute: int)->void: 
	day_label.text= "Day" + str(day)
