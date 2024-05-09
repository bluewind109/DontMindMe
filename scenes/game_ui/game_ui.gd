extends Control

@onready var score_label = $MC/ScoreLabel
@onready var exit_label = $MC/ExitLabel
@onready var time_label = $MC/TimeLabel
@onready var game_over = $GameOver
@onready var game_over_label = $GameOver/GameOverLabel

var _time: float = 0.0
var _game_over: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.on_show_exit.connect(on_show_exit)
	SignalManager.on_exit.connect(on_exit)
	SignalManager.on_game_over.connect(on_game_over)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (_game_over == false):
		_time += delta
		time_label.text = "%.1fs" % _time
	else:
		if (Input.is_action_just_pressed("space")):
			GameManager.load_main_scene()


func update_score(act: int, target: int) -> void:
	score_label.text = "%s / %s" % [act, target]


func on_show_exit() -> void:
	exit_label.show()


func on_exit() -> void:
	_game_over = true
	game_over.show()
	game_over_label.text = "Mission Success! \nYou took %.1f seconds" % _time


func on_game_over() -> void:
	_game_over = true
	game_over.show()
	game_over_label.text = "You died! Press space to go back"
