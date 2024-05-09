extends CharacterBody2D

const BULLET = preload("res://scenes/bullet/bullet.tscn")

enum ENEMY_STATE {
	PATROLLING,
	CHASING,
	SEARCHING
}

const FOV = {
	ENEMY_STATE.PATROLLING: 60.0,
	ENEMY_STATE.CHASING: 120.0,
	ENEMY_STATE.SEARCHING: 100.0
}

const SPEED = {
	ENEMY_STATE.PATROLLING: 120.0,
	ENEMY_STATE.CHASING: 240.0,
	ENEMY_STATE.SEARCHING: 180.0
}

@export var patrol_points: NodePath

@onready var sprite_2d = $Sprite2D
@onready var nav_agent = $NavAgent
@onready var debug_label = $DebugLabel
@onready var player_detect = $PlayerDetect
@onready var ray_cast_2d = $PlayerDetect/RayCast2D
@onready var warning = $Warning
@onready var animation_player = $AnimationPlayer
@onready var shoot_timer = $ShootTimer

@onready var gasp_sound = $Sounds/GaspSound
@onready var shoot_sound = $Sounds/ShootSound

var _waypoints: Array = []
var _current_wp: int = 0
var _player_ref: Player
var _state: ENEMY_STATE = ENEMY_STATE.PATROLLING

func _ready():
	set_physics_process(false)
	create_wp()
	_player_ref = get_tree().get_first_node_in_group("player")
	#call_deferred("set_physics_process", true)
	call_deferred("late_setup")


func late_setup() -> void:
	await get_tree().physics_frame
	call_deferred("set_physics_process", true)


func create_wp() -> void:
	for child_node in get_node(patrol_points).get_children():
		_waypoints.append(child_node.global_position)


func _physics_process(_delta):
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
	return get_fov_angle() < FOV[_state]


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
		velocity = global_position.direction_to(next_path_position) * SPEED[_state]
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


func process_searching() -> void:
	if (nav_agent.is_navigation_finished()):
		set_state(ENEMY_STATE.PATROLLING)


func update_movement() -> void:
	match _state:
		ENEMY_STATE.PATROLLING:
			process_patrolling()
		ENEMY_STATE.CHASING:
			process_chasing()
		ENEMY_STATE.SEARCHING:
			process_searching()


func set_state(new_state: ENEMY_STATE) -> void:
	if (new_state == _state):
		return
	
	if (new_state == ENEMY_STATE.SEARCHING):
		warning.show()
	elif(new_state == ENEMY_STATE.CHASING):
		warning.hide()
		SoundManager.play_gasp(gasp_sound)
		animation_player.play("alert")
	elif (new_state == ENEMY_STATE.PATROLLING):
		warning.hide()
		animation_player.play("RESET")
	
	_state = new_state


func update_state() -> void:
	var new_state = _state
	var can_see = can_see_player()
	if (can_see):
		new_state = ENEMY_STATE.CHASING
	elif (!can_see and new_state == ENEMY_STATE.CHASING):
		new_state = ENEMY_STATE.SEARCHING
	set_state(new_state)


func set_label() -> void:
	var status_string = "Done: %s\n" % nav_agent.is_navigation_finished()
	status_string += "Reached: %s\n" % nav_agent.is_target_reached()
	status_string += "Target: %s\n" % nav_agent.target_position
	status_string += "PlayerDetected: %s\n" % player_detected()
	status_string += "FOV: %.2f %s\n" % [get_fov_angle(), ENEMY_STATE.keys()[_state]]
	status_string += "%s %s\n" % [player_in_fov(), SPEED[_state]]
	if (debug_label != null): debug_label.text = status_string


func shoot() -> void:
	var target = _player_ref.global_position
	var new_bullet = BULLET.instantiate()
	new_bullet.init(target, global_position)
	get_tree().root.add_child(new_bullet)
	SoundManager.play_laser(shoot_sound)


func stop_action() -> void:
	set_physics_process(false)
	shoot_timer.stop()


func _on_shoot_timer_timeout():
	if (_state != ENEMY_STATE.CHASING):
		return
	shoot()


func _on_hit_box_body_entered(_body):
	SignalManager.on_game_over.emit()
