extends Node2D

@export var interact_name: String= ""
@export var is_interactable: bool = true

var interact: Callable= func():
	pass


func _on_interaction_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
	
	
