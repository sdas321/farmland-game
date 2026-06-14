extends CharacterBody2D
var SPEED: float = 200.0

func _physics_process(delta: float) -> void:
	pass
	
func _process(delta: float) -> void:
	var direction: Vector2 = Vector2(0.0, 0.0)
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")
	velocity = SPEED * direction.normalized()
	move_and_slide()
