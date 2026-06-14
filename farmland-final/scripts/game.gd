extends Node2D
@export var spawn_point: Marker2D



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_boundaries_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.global_position= spawn_point.global_position
		get_tree().reload_current_scene() 
