extends Area2D

@export var sprite: AnimatedSprite2D
@export var crop_name: String = "Wheat"
@export var growth_time_seconds: float = 10.0
@export var coins_reward: int = 10
@export var animation_name: String = "wheat_grow"

var is_fully_grown: bool = false

func _ready() -> void:
	if sprite == null:
		push_error("Missing AnimatedSprite2D assignment on node: " + name)
		return
		
	sprite.animation_finished.connect(self._on_growth_finished)
	body_entered.connect(self._on_body_entered)
	
	start_growing()

func start_growing() -> void:
	is_fully_grown = false
	sprite.frame = 0
	var base_fps: float = sprite.sprite_frames.get_animation_speed(animation_name)
	var total_frames: int = sprite.sprite_frames.get_frame_count(animation_name)
	var target_fps: float = float(total_frames) / growth_time_seconds
	
	sprite.speed_scale = target_fps / base_fps
	sprite.play(animation_name)

func _on_growth_finished() -> void:
	if sprite.animation == animation_name:
		is_fully_grown = true
		print(crop_name + " is fully grown and ready for pickup!")
		
func _on_body_entered(body: Node2D) -> void:
	if is_fully_grown and "player" in body.name:
		harvest_and_restart()

func harvest_and_restart() -> void:
	print("Auto-harvested " + crop_name + "! Gained ", coins_reward, " coins.")
	Global.add_coins(coins_reward)
	start_growing()
