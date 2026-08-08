extends Node2D
@export var spawn_point: Marker2D
@export var dialogue_resource: Resource
@export var dialogue = preload("res://tutorial.dialogue")
var balloon_scene = preload("res://scenes/balloon.tscn")
@onready var player: CharacterBody2D = %player

func _ready() -> void:
	if Global.player_saved_position:
		player.global_position = Global.player_spawn_position+ Vector2(0, 20)
	if dialogue and not Global.tutorial_played:
		Global.tutorial_played = true
		DialogueManager.show_dialogue_balloon(dialogue, "start")
		
func _process(delta: float) -> void: 
	if Input.is_action_just_pressed("pause"):
		print("hi")
		get_tree().change_scene_to_file("res://scenes/pause_menu.tscn")


func _on_boundaries_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.global_position= spawn_point.global_position
		get_tree().reload_current_scene() 


func _on_market_door_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Global.player_spawn_position = body.global_position
		Global.player_saved_position = true
		get_tree().change_scene_to_file("res://scenes/market.tscn")


func _on_house_door_outside_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Global.player_spawn_position = body.global_position
		Global.player_saved_position = true
	
		get_tree().change_scene_to_file("res://scenes/game_with_house.tscn")
