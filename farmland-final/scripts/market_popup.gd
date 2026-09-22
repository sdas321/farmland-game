extends CanvasLayer

@onready var panel: TextureRect = $Control/TextureRect
@onready var label: Label = $Control/TextureRect/Label

var toast_tween: Tween

# Hides the notification panel when the scene first loads so that the toast does
# not appear until another part of the game specifically requests a notification.
func _ready() -> void:
	panel.hide()

# Displays a temporary notification message to the player for the specified duration.
# Any existing toast animation is stopped first so multiple notifications do not
# overlap, then a tween is used to automatically hide the panel after the delay.
func show_toast(message: String, duration: float = 2.0) -> void:
	if toast_tween and toast_tween.is_running():
		toast_tween.kill()

	label.text = message
	panel.show()

	toast_tween = create_tween()
	toast_tween.tween_interval(duration)
	toast_tween.tween_callback(panel.hide)
