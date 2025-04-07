extends Node2D

@onready var platform: Platform = $Platform
@onready var ball: Ball = $Ball
@onready var death_block: CollisionShape2D = $DeathBlock/CollisionShape2D

## 平台左右移动的速度系数
const SPEED: float = 100.0

func _ready() -> void:
	## 获取屏幕的宽度
	var screenWidth: int = get_viewport().size.x
	var screenHeight: int = get_viewport().size.y
	
	## 初始化Platform的位置
	var platformPosition: Vector2 = Vector2(screenWidth * 0.5, screenHeight * 0.95)
	platform.position = platformPosition

	## 初始化Ball的位置
	var ballPosition: Vector2 = Vector2(screenWidth * 0.5, platform.position.y - platform.HEIGHT * 0.5 - ball.HEIGHT * 0.5)
	ball.position = ballPosition
	
	## 初始化death_block的collisionShape的位置和大小
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(screenWidth * 2 - 64, 50.0)
	death_block.shape = shape
	death_block.position = Vector2(32, screenHeight)


func _process(delta: float) -> void:
	pass
