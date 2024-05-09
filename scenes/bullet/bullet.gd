extends Area2D

@onready var timer = $Timer

const BOOM = preload("res://scenes/boom/boom.tscn")
const SPEED: float = 450.0

var _travel_dir: Vector2 = Vector2.ZERO
var _target_position: Vector2 = Vector2.ZERO

func _ready():
	look_at(_target_position)


func _process(delta):
	position += SPEED * delta * _travel_dir


func init(target: Vector2, start_pos: Vector2) -> void:
	_target_position = target
	_travel_dir = start_pos.direction_to(target)
	global_position = start_pos


func create_boom() -> void:
	var new_boom = BOOM.instantiate()
	new_boom.global_position = global_position
	get_tree().root.add_child(new_boom)
	queue_free()


func _on_timer_timeout():
	create_boom()


func _on_body_entered(body):
	if (body.is_in_group("player")):
		timer.stop()
		SignalManager.on_game_over.emit()
	else:
		create_boom()
