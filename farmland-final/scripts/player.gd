extends CharacterBody2D

var speed: float = 150.0
var character_direction: Vector2
@export var animation: AnimatedSprite2D
var last_direction: Vector2 = Vector2.DOWN

# Handles the player's movement every physics frame by reading the directional
# keyboard input and converting it into velocity using the player's movement speed.
# It also remembers the last direction travelled so the correct idle animation can
# be shown when the player stops moving.
func _physics_process(delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	velocity = direction.normalized() * speed
	move_and_slide()

	if direction != Vector2.ZERO:
		last_direction = direction

	update_animation(direction)

# Selects the appropriate walking or idle animation based on the player's direction.
# Horizontal and vertical movement are compared to determine which direction is
# dominant, while last_direction is used to preserve the player's facing direction
# when they are standing still.
func update_animation(direction: Vector2):
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				animation.play("walk_right")
			else:
				animation.play("walk_left")
		else:
			if direction.y > 0:
				animation.play("walk_front")
			else:
				animation.play("walk_back")
	else:
		if abs(last_direction.x) > abs(last_direction.y):
			if last_direction.x > 0:
				animation.play("idle_right")
			else:
				animation.play("idle_left")
		else:
			if last_direction.y > 0:
				animation.play("idle_front")
			else:
				animation.play("idle_back")
