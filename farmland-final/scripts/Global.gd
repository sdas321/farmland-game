extends Node

signal coins_changed(new_amount: int) 
var coins: int = 0
var inventory: Array[String] = []
signal inventory_updated

func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins) 
	
func purchase(cost: int) -> void:
	coins -= cost
	coins_changed.emit(coins)
	

func add_to_inventory(item_name: String) -> void:
	inventory.append(item_name)
	print("Current Inventory List: ", inventory)
