extends TextureRect

@export var item_name: String = "drawer"
@export var item_cost: int = 300


# Handles the purchase button being pressed by sending the selected item's name
# to the Global script, where the purchase is processed and the item can be added
# to the player's inventory. 
func _on_purchase_button_pressed() -> void:
	Global.buy_item("drawer")
