extends Node


# Item identifiers used throughout the game so the same names are used
# consistently by the market, inventory and placement systems.
const ITEM_BED := "bed"
const ITEM_CARPET := "carpet"
const ITEM_CHAIR := "chair"
const ITEM_CHICKEN := "chicken"
const ITEM_CLOCK := "clock"
const ITEM_COW := "cow"
const ITEM_DRAWER := "drawer"
const ITEM_LAMP := "lamp"
const ITEM_PAINTING := "painting"
const ITEM_TABLE := "table"
const ITEM_WATERING_CAN := "watering_can"
const MONEY_GOAL := 10000
const FINAL_DAY := 50


# Shared dictionary keys used when saving placed objects and crop information.
# Using constants prevents different scripts from accidentally using different
# spellings for the same saved data.
const DATA_NAME := "name"
const DATA_POSITION := "position"
const DATA_CURRENT_WATER := "current_water"
const DATA_IS_GROWN := "is_grown"


# Shared player group identifier used by doors, boundaries and crop collection.
const PLAYER_GROUP := "player"


# Input action names used by the game's custom controls.
const INPUT_MOUSE_CLICK := "mouse_click"
const INPUT_RIGHT_CLICK := "right_click"
const INPUT_PAUSE := "pause"


# Scene paths used by the remaining scene transitions in the game.
const GAME_SCENE := "res://scenes/game.tscn"
const MARKET_SCENE := "res://scenes/market.tscn"
const MAIN_MENU_SCENE := "res://scenes/main_menu.tscn"
const HOW_TO_PLAY_SCENE := "res://scenes/how_to_play.tscn"


# Shared placement type identifiers used by the combined game script.
const PLACEMENT_ANIMAL := "animal"
const PLACEMENT_FURNITURE := "furniture"


# Offset used when returning the player to their saved position.
const PLAYER_SPAWN_OFFSET := Vector2(0, 20)


# Name of the placement method used by the inventory to communicate with the game.
const PLACEMENT_METHOD := "start_placement"


# Inventory label node name.
const LABEL_NODE := "Label"


# Player animation names.
const WALK_RIGHT := "walk_right"
const WALK_LEFT := "walk_left"
const WALK_FRONT := "walk_front"
const WALK_BACK := "walk_back"
const IDLE_RIGHT := "idle_right"
const IDLE_LEFT := "idle_left"
const IDLE_FRONT := "idle_front"
const IDLE_BACK := "idle_back"


# Messages displayed when the player attempts to purchase an item.
const PURCHASE_SUCCESS_MESSAGE := "Purchased!"
const NOT_ENOUGH_COINS_MESSAGE := "Not enough!"


# Starting game time is 6:00 AM, represented as seconds after midnight.
var game_seconds: float = 21600.0
var current_day: int = 1


signal coins_changed(new_amount: int)
signal inventory_updated


var coins: int = 0
var inventory: Array[String] = []
var selected_item: String = ITEM_WATERING_CAN

var plant_data: Dictionary = {}
var placed_furniture: Array[Dictionary] = []
var placed_animals: Array[Dictionary] = []

var market_door_entered: bool = false

var player_spawn_position: Vector2 = Vector2.ZERO
var player_saved_position: bool = false

var tutorial_played: bool = false


# Stores the purchase price for every item available in the market.
# Keeping all prices in one dictionary allows the purchasing system to use the
# same values regardless of which part of the game requests a purchase.
var item_costs: Dictionary = {
	ITEM_BED: 200,
	ITEM_CARPET: 1000,
	ITEM_CHAIR: 100,
	ITEM_CHICKEN: 2000,
	ITEM_CLOCK: 150,
	ITEM_COW: 2200,
	ITEM_DRAWER: 300,
	ITEM_LAMP: 400,
	ITEM_PAINTING: 1200,
	ITEM_TABLE: 250
}


# Adds the specified number of coins to the player's balance.
# The coins_changed signal is emitted immediately so connected UI elements
# can update the displayed coin amount.
func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins)


# Removes the specified purchase cost from the player's balance.
# The updated balance is emitted through coins_changed so the interface remains
# synchronised with the actual amount stored in Global.
func purchase(amount: int) -> void:
	coins -= amount
	coins_changed.emit(coins)


# Adds an item to the player's inventory and tells the inventory interface
# that its contents have changed. This allows the inventory to refresh automatically
# after a successful purchase or another item being added.
func add_to_inventory(item_name: String) -> void:
	inventory.append(item_name)
	inventory_updated.emit()

# Checks whether the player has purchased every product available in the market.
# This prevents the player from reaching the money target without completing the shopping requirement.
func has_purchased_all_products() -> bool:
	for item_name in item_costs.keys():
		if not placed_furniture.any(func(item): return item[DATA_NAME] == item_name) \
		and not placed_animals.any(func(item): return item[DATA_NAME] == item_name):
			return false

	return true
	

# Checks whether an item exists in the price list and whether the player can afford it.
# If both conditions are met, the required coins are removed and the item is added
# to the inventory before returning true to indicate a successful purchase.
func buy_item(item_name: String) -> bool:
	if not item_costs.has(item_name):
		return false

	var cost: int = item_costs[item_name]

	if coins < cost:
		return false

	purchase(cost)
	add_to_inventory(item_name)

	return true


# Removes one matching item from the inventory when it exists.
# The inventory_updated signal is emitted afterwards so the visible inventory
# immediately reflects the removed item.
func remove_from_inventory(item_name: String) -> void:
	if inventory.has(item_name):
		inventory.erase(item_name)
		inventory_updated.emit()
