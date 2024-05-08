extends CharacterBody2D

class_name Player

const SPEED: float = 360.0

func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	get_input()
	move_and_slide()
	rotation = velocity.angle()


func get_input() -> void:
	var new_velocity = Vector2.ZERO
	new_velocity.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	new_velocity.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	velocity = new_velocity.normalized() * SPEED


