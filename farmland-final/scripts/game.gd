extends Node2D
@export var spawn_point: Marker2D



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_boundaries_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.global_position= spawn_point.global_position
		get_tree().reload_current_scene() 


func _on_market_door_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://scenes/market.tscn")


func _on_house_door_outside_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://scenes/game_with_house.tscn")
