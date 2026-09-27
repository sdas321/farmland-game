extends CanvasLayer

var toast_tween: Tween

@onready var panel: TextureRect = $Control/TextureRect
@onready var label: Label = $Control/TextureRect/Label

# Hides the notification panel when the toast scene first loads.
# The panel remains hidden until another script calls show_toast(), preventing
# an empty notification from appearing automatically.
func _ready() -> void:
	panel.hide()

# Displays a temporary notification message for the requested duration.
# Any currently running toast animation is stopped first, then the new message
# is shown and a tween waits for the specified duration before hiding the panel.
func show_toast(message: String, duration: float = 2.0) -> void:
	if toast_tween and toast_tween.is_running():
		toast_tween.kill()

	label.text = message
	panel.show()

	toast_tween = create_tween()
	toast_tween.tween_interval(duration)
	toast_tween.tween_callback(panel.hide)
