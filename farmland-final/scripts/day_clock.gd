class_name DayClock extends Resource

@export_range(0, 59) var minutes: int = 0
@export_range(0, 59) var hours: int = 0


# Increases the stored clock time using the amount of time that has passed.
# This function is designed to update the reusable DayClock resource so that
# minutes and hours can be progressed as the game clock advances.
func increase_time(delta_seconds: float) -> void:
	pass
