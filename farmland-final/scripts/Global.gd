extends Node

var game_seconds: float = 21600.0
var current_day: int = 1

signal coins_changed(new_amount: int)
signal inventory_updated

var coins: int = 0
var inventory: Array[String] = []
var selected_item: String = "watering_can"

var plant_data: Dictionary = {}
var placed_furniture: Array[Dictionary] = []
var placed_animals: Array[Dictionary] = []

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

# Adds the specified number of coins to the player's total and emits a signal
# so connected UI elements can immediately update the displayed coin balance.
func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins)

# Removes the specified purchase cost from the player's coin total and sends
# an updated value through the signal so the coin display remains synchronised.
func purchase(amount: int) -> void:
	coins -= amount
	coins_changed.emit(coins)

# Adds a purchased item to the player's inventory and emits an update signal.
# The signal allows inventory UI elements to refresh and display the new item.
func add_to_inventory(item_name: String) -> void:
	inventory.append(item_name)
	inventory_updated.emit()

# Checks whether the requested item exists and whether the player has enough coins.
# If both conditions are met, the cost is removed and the item is added to the inventory;
# the function returns true for a successful purchase and false otherwise.
func buy_item(item_name: String) -> bool:
	if item_costs.has(item_name):
		var cost = item_costs[item_name]

		if coins >= cost:
			purchase(cost)
			add_to_inventory(item_name)
			return true

	return false

# Removes a specified item from the inventory when it has been used or placed.
# An inventory update signal is emitted afterwards so the inventory interface
# can immediately reflect the item being removed.
func remove_from_inventory(item_name: String) -> void:
	if inventory.has(item_name):
		inventory.erase(item_name)
		inventory_updated.emit()
