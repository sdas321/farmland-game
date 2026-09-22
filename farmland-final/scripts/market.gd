extends Control

@onready var object_container: HBoxContainer = %objects
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var name_label: Label = %ItemNameLabel
@onready var price_label: Label = %ItemPriceLabel
@onready var toast = $Toast

var targetScroll = 0
var index: int = 0

# Starts the product selection system when the market scene loads.
# The selection function waits briefly for the UI layout to initialise before
# highlighting the first available product.
func _ready() -> void:
	_selection()

# Waits for the market interface to finish positioning its child elements before
# highlighting the current product. The short delay prevents the selection from
# being calculated before the container has finished setting its layout.
func _selection() -> void:
	await get_tree().create_timer(0.01).timeout
	_highlight()

# Moves the selected product one position to the left when possible.
# It updates the selected index, changes the visual highlight and smoothly scrolls
# the product container so the newly selected item is displayed.
func _on_previous_pressed() -> void:
	if index > 0:
		var scrollValue = targetScroll - _scroll(-1)
		index -= 1
		_highlight()
		await _tween_scroll(scrollValue)

# Moves the selected product one position to the right when possible.
# The selection index, visual highlight and scroll position are updated together
# so the interface stays centred on the newly selected product.
func _on_next_pressed() -> void:
	if index < object_container.get_child_count() - 1:
		var scrollValue = targetScroll + _scroll(1)
		index += 1
		_highlight()
		await _tween_scroll(scrollValue)

# Calculates the horizontal distance required to move between two products.
# It uses the widths of the current and next objects plus the container spacing
# so the scrolling movement accounts for different product sizes.
func _scroll(direction: int) -> float:
	var separation = object_container.get_theme_constant("separation")
	var children = object_container.get_children()
	var current_obj = children[index]
	var current_half_width = current_obj.size.x / 2.0
	var next_item_index = index + direction
	var next_obj = children[next_item_index]
	var next_half_width = next_obj.size.x / 2.0

	return current_half_width + separation + next_half_width

# Calculates the space occupied by the current product and the container separation.
# The checks prevent the function from attempting to access children when there are
# not enough products available.
func _get_space_between() -> int:
	if object_container.get_child_count() < 1:
		return 0

	var distanceSize = object_container.get_theme_constant("separation")

	if object_container.get_child_count() < 2:
		return 0

	var objectSize = object_container.get_children()[index].size.x

	return distanceSize + objectSize

# Changes the appearance of the products so that the currently selected item is
# clearly distinguished from the other products. This allows the player to see
# which product will be affected by the purchase button.
func _highlight() -> void:
	var children = object_container.get_children()

	for i in range(children.size()):
		var object = children[i]

		if object is not TextureRect:
			continue

		if i == index:
			object.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			object.modulate = Color(0, 0, 0, 1)

# Smoothly moves the ScrollContainer to the requested horizontal position instead
# of instantly changing it. The function waits for the tween to finish before
# allowing the next frame of UI processing to continue.
func _tween_scroll(scrollValue) -> void:
	targetScroll = scrollValue

	var tween = get_tree().create_tween()
	tween.tween_property(scroll_container, "scroll_horizontal", scrollValue, 0.25)

	await tween.finished
	await get_tree().process_frame

# Processes a purchase for the currently selected product by finding the valid
# product containers, retrieving its cost and name, and checking the player's coins.
# When affordable, the cost is removed through Global and the purchased item is
# added to the inventory so it can later be placed in the game.
func _on_purchase_pressed() -> void:
	var children = object_container.get_children()

	if children.size() == 0:
		return

	var valid_items: Array = []

	for child in children:
		if child is VBoxContainer:
			valid_items.append(child)
		else:
			continue

	if valid_items.size() == 0 or index >= valid_items.size():
		return

	Toast.show_toast("Purchased!", 2.0)

	print(index)

	var active_node = valid_items[index]
	var active_product = active_node

	if active_node.get_child_count() > 0:
		active_product = active_node.get_child(0)

	var cost = active_product.get("item_cost")
	var item_name = active_product.get("item_name")

	if item_name == null:
		item_name = active_product.name.to_lower()

	if cost != null:
		if Global.coins >= cost:
			Global.purchase(cost)
			Global.add_to_inventory(item_name)
			print("Purchased: ", item_name)

# Returns the player from the market to the main game scene when the close button
# is pressed. This allows the player to continue playing after finishing shopping.
func _on_close_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
