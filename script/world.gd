extends Node2D

@onready var platform: Platform = $Platform
@onready var ball: Ball = $Ball
@onready var death_block: CollisionShape2D = $DeathBlock/CollisionShape2D

var rng = RandomNumberGenerator.new()

## 平台和ball左右移动的速度系数
@export var MOVE_SPEED: float = 500.0
## ball飞行的速度
@export var BALL_SPEED: float = 500.0
## ball是否已经发射
var isShoot: bool = false
## 斜上45度或135度的方向
var i: int = 0
var deg: float = 45.0
var angle: float = 0.0
## 移动的向量
var dir: Vector2 = Vector2.ZERO


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
	## 左右移动横轴的差值
	var moveAxis: float = Input.get_axis("move_left", "move_right")
	## 移动的趋势
	var trend: float = moveAxis * delta * MOVE_SPEED
	## 平台左右移动
	platform.position.x = platform.position.x + trend
	if not isShoot:
		## 如果ball还未发射过，那么也可以跟着平台一起移动
		ball.position.x = ball.position.x + trend
			
func _physics_process(delta: float) -> void:
	## 小球开始移动了
	if isShoot:
		
		ball.velocity = dir * BALL_SPEED * delta
		var coll: KinematicCollision2D = ball.move_and_collide(ball.velocity)
		
		## 碰撞检测
		if coll:
			## 获取碰撞点的法线
			var nor: Vector2 = coll.get_normal()
			## 以法线为中线的反向向量
			dir = ball.velocity.bounce(nor).normalized()
			
			ball.velocity = dir * BALL_SPEED * delta
			ball.move_and_collide(ball.velocity)
		
		
func _unhandled_input(event: InputEvent) -> void:
	## 处理发射事件
	if event.is_action_pressed("shoot") and not isShoot:
		## 先把是否第一次发射，改为true
		isShoot = true
		## 随机定义符号
		var i : int = rng.randi_range(0, 1)
		## 按 45度 or 135度 角发射出去，转为弧度
		deg = 45.0 if i else 135.0
		angle = deg_to_rad(deg)
		## 第一次的方向向量
		dir = Vector2(cos(angle), -sin(angle)).normalized()
		
