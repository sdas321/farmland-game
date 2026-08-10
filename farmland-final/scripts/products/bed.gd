extends TextureRect
@export var item_name: String = "bed"
@export var item_cost: int = 200

func _on_purchase_button_pressed() -> void:
	Global.buy_item("bed")
