extends Node2D

@onready var pick_ups = $PickUps
@onready var game_ui = $CanvasLayer/GameUI

var _pickups_count: int = 0
var _collected: int = 0

func _ready():
	_pickups_count = pick_ups.get_children().size()
	game_ui.update_score(_collected, _pickups_count)
	SignalManager.on_pickup.connect(on_pickup)
	SignalManager.on_exit.connect(on_exit)
	SignalManager.on_game_over.connect(on_game_over)


func _process(_delta):
	pass


func on_game_over() -> void:
	end_game()


func end_game() -> void:
	for bullet_node in get_tree().get_nodes_in_group("bullet"):
		bullet_node.queue_free()
		
	var player_node = get_tree().get_first_node_in_group("player")
	player_node.set_physics_process(false)
	
	for npc_node in get_tree().get_nodes_in_group("npc"):
		npc_node.stop_action()


func check_show_exit() -> void:
	if (_collected == _pickups_count):
		SignalManager.on_show_exit.emit()


func on_pickup() -> void:
	_collected += 1
	game_ui.update_score(_collected, _pickups_count)
	check_show_exit()


func on_exit() -> void:
	end_game()

