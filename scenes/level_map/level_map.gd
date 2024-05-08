extends Node2D

@onready var pick_ups = $PickUps

var _pickups_count: int = 0
var _collected: int = 0

func _ready():
	_pickups_count = pick_ups.get_children().size()
	SignalManager.on_pickup.connect(on_pickup)
	SignalManager.on_exit.connect(on_exit)


func _process(delta):
	pass


func check_show_exit() -> void:
	if (_collected == _pickups_count):
		SignalManager.on_show_exit.emit()
		print("check_show_exit")


func on_pickup() -> void:
	print("on_pickup")
	_collected += 1
	check_show_exit()


func on_exit() -> void:
	print("GAME OVER, WIN")
