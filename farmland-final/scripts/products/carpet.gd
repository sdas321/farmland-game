extends TextureRect
@export var item_name: String = "carpet"
@export var item_cost: int = 1000

func _on_purchase_button_pressed() -> void:
	Global.buy_item("carpet")
