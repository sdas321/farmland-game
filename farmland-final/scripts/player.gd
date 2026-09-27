extends CharacterBody2D

var speed: float = 150.0
var character_direction: Vector2

@export var animation: AnimatedSprite2D

var last_direction: Vector2 = Vector2.DOWN


# Reads the player's directional input every physics frame and converts it into
# movement using the configured speed. The player's last non-zero direction is
# stored so the correct idle animation can be shown when movement stops.
func _physics_process(delta):
	var direction = Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	velocity = direction.normalized() * speed
	move_and_slide()

	if direction != Vector2.ZERO:
		last_direction = direction

	update_animation(direction)


# Selects the correct walking animation based on the direction of movement.
# When the player is not moving, the stored last direction is used to select
# the matching idle animation so the character continues facing the correct way.
func update_animation(direction: Vector2):
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				animation.play(Global.WALK_RIGHT)
			else:
				animation.play(Global.WALK_LEFT)
		else:
			if direction.y > 0:
				animation.play(Global.WALK_FRONT)
			else:
				animation.play(Global.WALK_BACK)
	else:
		if abs(last_direction.x) > abs(last_direction.y):
			if last_direction.x > 0:
				animation.play(Global.IDLE_RIGHT)
			else:
				animation.play(Global.IDLE_LEFT)
		else:
			if last_direction.y > 0:
				animation.play(Global.IDLE_FRONT)
			else:
				animation.play(Global.IDLE_BACK)
