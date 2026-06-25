extends Control

@onready var object_container: HBoxContainer= %objects
@onready var scroll_container: ScrollContainer= %ScrollContainer
var targetScroll = 0
var current_item_index: int = 0
@onready var name_label: Label = %ItemNameLabel
@onready var price_label: Label = %ItemPriceLabel


func _ready()-> void:
	_set_selection()
	
func _set_selection():
	await get_tree().create_timer(0.01).timeout
	_select_deselect_highlight()

func _on_previous_pressed() -> void:
	if current_item_index > 0:
		var scrollValue = targetScroll - _get_scroll_distance_to_next(-1)
		current_item_index -= 1
	var scrollValue= targetScroll - _get_space_between()
	_select_deselect_highlight()
	await _tween_scroll(scrollValue)
	
func _get_scroll_distance_to_next(direction: int) -> float:
	var separation = object_container.get_theme_constant("separation")
	var children = object_container.get_children()
	var current_obj = children[current_item_index]
	var current_half_width = current_obj.size.x / 2.0
	var next_item_index = current_item_index + direction
	var next_obj = children[next_item_index]
	var next_half_width = next_obj.size.x / 2.0
	return current_half_width + separation + next_half_width
	
func _on_next_pressed() -> void:
	if current_item_index < object_container.get_child_count() - 1:
		var scrollValue = targetScroll + _get_scroll_distance_to_next(1)
		current_item_index += 1
	var scrollValue= targetScroll + _get_space_between()
	_select_deselect_highlight()
	await _tween_scroll(scrollValue)
	
	
func _get_space_between() -> int:
	if object_container.get_child_count() < 1:
		return 0
	
	var distanceSize = object_container.get_theme_constant("separation")
	if object_container.get_child_count() < 2:
		return 0
	var objectSize = object_container.get_children()[current_item_index].size.x
	return distanceSize + objectSize 
	
	
func _select_deselect_highlight():
	var children = object_container.get_children()
	for i in range(children.size()):
		var object = children[i]
		if object is not TextureRect: continue
		
		if i == current_item_index:
			object.modulate = Color(1.0, 1.0, 1.0, 1.0) 
		
func _tween_scroll(scrollValue):
	targetScroll= scrollValue
	var tween= get_tree().create_tween()
	tween.tween_property(scroll_container, "scroll_horizontal", scrollValue, 0.25)
	await tween.finished
	await get_tree().process_frame
	
	


func _on_purchase_pressed() -> void:
	var children = object_container.get_children()
	if children.size() == 0: return
	
	var active_node = children[current_item_index]
	var active_product = null
	
	if active_node.get_child_count() > 0:
		active_product = active_node.get_child(0)
	else:
		active_product = active_node
		
	if active_product and "item_cost" in active_product:
		var cost = active_product.item_cost
		var item_name = active_product.item_name
		
		Global.purchase(cost)
		Global.add_to_inventory(item_name)
		print("Successfully purchased: ", item_name)
	else:
		print("Cannot purchase: This slot is a layout spacer (", active_node.name, ")")



func _on_close_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn") 
