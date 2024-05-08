extends CharacterBody2D

const SPEED: float = 240.0

enum ENEMY_STATE {
	PATROLLING,
	CHASING,
	SEARCHING
}

@export var patrol_points: NodePath

@onready var sprite_2d = $Sprite2D
@onready var nav_agent = $NavAgent
@onready var label = $Label
@onready var player_detect = $PlayerDetect
@onready var ray_cast_2d = $PlayerDetect/RayCast2D

var _waypoints: Array = []
var _current_wp: int = 0
var _player_ref: Player
var _state: ENEMY_STATE = ENEMY_STATE.PATROLLING

func _ready():
	set_physics_process(false)
	create_wp()
	_player_ref = get_tree().get_first_node_in_group("player")
	call_deferred("set_physics_process", true)


func create_wp() -> void:
	for child_node in get_node(patrol_points).get_children():
		_waypoints.append(child_node.global_position)


func _physics_process(delta):
	if (Input.is_action_just_pressed("set_target")):
		nav_agent.target_position = get_global_mouse_position()
	
	raycast_to_player()
	update_state()
	update_movement()
	update_navigation()
	set_label()


func get_fov_angle() -> float:
	var direction = global_position.direction_to(_player_ref.global_position)
	var dot_product = direction.dot(velocity.normalized())
	if (dot_product >= -1.0 and dot_product <= 1.0):
		return rad_to_deg(acos(dot_product))
	return 0.0


func player_in_fov() -> bool:
	return get_fov_angle() < 60.0


func raycast_to_player() -> void:
	player_detect.look_at(_player_ref.global_position)


func player_detected() -> bool:
	var first_collider = ray_cast_2d.get_collider()
	if (first_collider != null):
		return first_collider.is_in_group("player")
	return false


func can_see_player() -> bool:
	return player_in_fov() and player_detected()


func update_navigation() -> void:
	if (!nav_agent.is_navigation_finished()):
		var next_path_position: Vector2 = nav_agent.get_next_path_position()
		sprite_2d.look_at(next_path_position)
		velocity = global_position.direction_to(next_path_position) * SPEED
		move_and_slide()


func navigate_wp() -> void:
	if (_current_wp >= len(_waypoints)):
		_current_wp = 0
	nav_agent.target_position = _waypoints[_current_wp]
	_current_wp += 1


func set_nav_to_player() -> void:
	nav_agent.target_position = _player_ref.global_position


func process_patrolling() -> void:
	if (nav_agent.is_navigation_finished()):
		navigate_wp()


func process_chasing() -> void:
	set_nav_to_player()


func update_movement() -> void:
	match _state:
		ENEMY_STATE.PATROLLING:
			process_patrolling()
		ENEMY_STATE.CHASING:
			process_chasing()


func set_state(new_state: ENEMY_STATE) -> void:
	if (new_state == _state):
		return
	_state = new_state


func update_state() -> void:
	var new_state = _state
	var can_see = can_see_player()
	if (can_see_player()):
		new_state = ENEMY_STATE.CHASING
	else:
		new_state = ENEMY_STATE.PATROLLING
	set_state(new_state)


func set_label() -> void:
	var status_string = "Done: %s\n" % nav_agent.is_navigation_finished()
	status_string += "Reached: %s\n" % nav_agent.is_target_reached()
	status_string += "Target: %s\n" % nav_agent.target_position
	status_string += "PlayerDetected: %s\n" % player_detected()
	status_string += "FOV: %.2f %s\n" % [get_fov_angle(), ENEMY_STATE.keys()[_state]]
	label.text = status_string


