extends TextureRect

@export var item_name: String = "lamp"
@export var item_cost: int = 400

func _on_purchase_button_pressed() -> void:
	Global.buy_item("lamp")
