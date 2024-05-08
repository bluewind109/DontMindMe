extends CharacterBody2D

const SPEED: float = 120.0

@onready var sprite_2d = $Sprite2D
@onready var nav_agent = $NavAgent
@onready var label = $Label

func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	if (Input.is_action_just_pressed("set_target")):
		nav_agent.target_position = get_global_mouse_position()
	
	update_navigation()
	set_label()


func update_navigation() -> void:
	if (!nav_agent.is_navigation_finished()):
		var next_path_position: Vector2 = nav_agent.get_next_path_position()
		sprite_2d.look_at(next_path_position)
		velocity = global_position.direction_to(next_path_position) * SPEED
		move_and_slide()


func set_label() -> void:
	var str = "DONE: %s\n" % nav_agent.is_navigation_finished()
	str += "REACH: %s\n" % nav_agent.is_target_reachable()
	str += "REACHED: %s\n" % nav_agent.is_target_reached()
	str += "TARGET: %s\n" % nav_agent.target_position
	label.text = str


