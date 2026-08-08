extends Node

signal coins_changed(new_amount: int) 
signal inventory_updated
var coins: int = 0
var inventory: Array[String] = []
var selected_item: String = "watering_can"
var plant_data: Dictionary = {}

var market_door_entered: bool = false
var house_door_entered: bool = false
var player_spawn_position: Vector2 = Vector2.ZERO
var player_saved_position: bool = false
var tutorial_played: bool = false

func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins) 
	
func purchase(cost: int) -> void:
	coins -= cost
	coins_changed.emit(coins)

func add_to_inventory(item_name: String) -> void:
	inventory.append(item_name)
	inventory_updated.emit()
	
