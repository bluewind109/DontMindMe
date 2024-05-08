extends Area2D

@onready var sound = $Sound
@onready var animation_player = $AnimationPlayer

func play_sound() -> void:
	sound.stream = SoundManager.get_random_pickup_sound()
	sound.play()


func _on_body_entered(body):
	SignalManager.on_pickup.emit()
	animation_player.play("vanish")
	play_sound()


func _on_sound_finished():
	queue_free()
