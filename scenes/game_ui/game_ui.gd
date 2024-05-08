extends Control

@onready var score_label = $MC/ScoreLabel
@onready var exit_label = $MC/ExitLabel
@onready var time_label = $MC/TimeLabel
@onready var game_over = $GameOver
@onready var game_over_label = $GameOver/GameOverLabel

var _time: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.on_show_exit.connect(on_show_exit)
	SignalManager.on_exit.connect(on_exit)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_time += delta
	time_label.text = "%.1fs" % _time


func on_show_exit() -> void:
	exit_label.show()


func on_exit() -> void:
	set_process(false)
	game_over.show()
	game_over_label.text = "Mission Success! \nYou took %.1f seconds" % _time
