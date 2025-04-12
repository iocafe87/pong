extends StaticBody2D
class_name Brick

@onready var brick_destroy: AudioStreamPlayer2D = $BrickDestroy
@onready var brick_audio_play_time: Timer = $BrickAudioPlayTime
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D

signal brick_explosion

func _ready() -> void:
	brick_explosion.connect(_signal_brick_explosion)

## 实现信号：
func _signal_brick_explosion() -> void:
	brick_destroy.play()
	brick_audio_play_time.start()
	collision_shape_2d.disabled = true
	hide()


func _on_brick_audio_play_time_timeout() -> void:
	queue_free()
