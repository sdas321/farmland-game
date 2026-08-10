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
var item_costs: Dictionary = {
	"bed": 200,
	"carpet": 1000,
	"chair": 100,
	"chicken": 2000,
	"clock": 150,
	"cow": 2200,
	"drawer": 300,
	"lamp": 400,
	"painting": 1200,
	"table": 250
}

func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins) 
	
func purchase(amount: int) -> void:
	coins -= amount
	coins_changed.emit(coins)

func add_to_inventory(item_name: String) -> void:
	inventory.append(item_name)
	inventory_updated.emit()
	
func buy_item(item_name: String) -> bool:
	if item_costs.has(item_name):
		var cost = item_costs[item_name]
		if coins >= cost:
			purchase(cost)
			add_to_inventory(item_name)
			return true
	return false


	
