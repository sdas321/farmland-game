extends CharacterBody2D
var speed: float = 150.0
var character_direction: Vector2
@export var animation: AnimatedSprite2D

func _physics_process(delta):
	character_direction.x= Input.get_axis("ui_left","ui_right")
	character_direction.y= Input.get_axis("ui_up","ui_down")
	character_direction= character_direction.normalized()
	
	
	if character_direction:
		velocity= character_direction*speed
		if %sprite.animation != "walk_front": %sprite.animation= "walk_front"
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
		if %sprite.animation != "idle_front": %sprite.animation= "idle_front"
		
	move_and_slide()
	
