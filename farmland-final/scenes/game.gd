extends Node2D
@export var spawn_point: Marker2D



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_boundaries_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		area.global_position= spawn_point.global_position
		get_tree().reload_current_scene()
