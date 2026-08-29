extends CanvasLayer

@onready var panel: TextureRect = $Control/TextureRect
@onready var label: Label = $Control/TextureRect/Label

var toast_tween: Tween

func _ready() -> void:
	# Ensure the UI starts hidden when the game launches
	panel.hide()

func show_toast(message: String, duration: float = 2.0) -> void:
	# 1. Kill any existing running timer so new messages override smoothly
	if toast_tween and toast_tween.is_running():
		toast_tween.kill()

	# 2. Set text and show panel
	label.text = message
	panel.show()

	# 3. Create a clean timer that forces panel.hide() when done
	toast_tween = create_tween()
	toast_tween.tween_interval(duration)
	toast_tween.tween_callback(panel.hide)
