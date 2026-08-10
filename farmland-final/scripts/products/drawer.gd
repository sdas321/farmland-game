extends TextureRect

@export var item_name: String = "drawer"
@export var item_cost: int = 300

func _on_purchase_button_pressed() -> void:
	Global.buy_item("drawer")
