extends Area2D

@export var sprite: AnimatedSprite2D
@export var progress_bar: ProgressBar
@export var crop_name: String = "Wheat"
@export var coins_reward: int = 10
@export var max_water: float = 100.0
@export var water_speed: float = 50.0

var current_water: float = 0.0
var is_fully_grown: bool = false
var is_mouse_hovering: bool = false

func _ready() -> void:
	if sprite == null:
		return

	body_entered.connect(self._on_body_entered)
	mouse_entered.connect(self._on_mouse_entered)
	mouse_exited.connect(self._on_mouse_exited)

	if progress_bar:
		progress_bar.max_value = max_water
		progress_bar.value = 0
		progress_bar.visible = true

	reset_crop()

func reset_crop() -> void:
	is_fully_grown = false
	current_water = 0.0
	
	if progress_bar:
		progress_bar.value = 0
		progress_bar.max_value = max_water
		progress_bar.visible = true

	if sprite:
		sprite.stop()
		sprite.frame = 0

func _process(delta: float) -> void:
	if is_fully_grown:
		return

	if is_mouse_hovering and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if Global.selected_item == "watering_can":
			water_crop(delta)

func water_crop(delta: float) -> void:
	current_water += water_speed * delta
	current_water = min(current_water, max_water)

	if progress_bar:
		progress_bar.value = current_water

	var ratio: float = current_water / max_water

	if ratio < 1.0:
		if sprite:
			sprite.frame = int(ratio * 4.0)
	else:
		if sprite:
			sprite.frame = 3
		is_fully_grown = true
		if progress_bar:
			progress_bar.visible = false

func _on_body_entered(body: Node2D) -> void:
	if is_fully_grown and "player" in body.name.to_lower():
		collect_crop()

func collect_crop() -> void:
	Global.add_coins(coins_reward)
	reset_crop()

func _on_mouse_entered() -> void:
	is_mouse_hovering = true

func _on_mouse_exited() -> void:
	is_mouse_hovering = false
