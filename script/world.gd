extends Node2D

@onready var platform: Platform = $Platform
@onready var ball: Ball = $Ball
@onready var death_block: CollisionShape2D = $DeathBlock/CollisionShape2D
@onready var ball_pop_up: AudioStreamPlayer2D = $Audio/BallPopUp
@onready var ball_explosion: AudioStreamPlayer2D = $Audio/BallExplosion
@onready var death_wait: Timer = $DeathWait
@onready var bricks: Node = $Bricks


var rng = RandomNumberGenerator.new()

## 平台和ball左右移动的速度系数
@export var MOVE_SPEED: float = 360.0
## ball飞行的速度
@export var BALL_SPEED: float = 400.0
## ball是否已经发射
var isShoot: bool = false
## 斜上45度或135度的方向
var i: int = 0
var deg: float = 45.0
var angle: float = 0.0
## 移动的向量
var dir: Vector2 = Vector2.ZERO

## 屏幕宽高
var screenWidth: int = 0
var screenHeight: int = 0

## 移动limit
var limit: int = 50

## 是否死亡
var isDead: bool = false


func _ready() -> void:
	## 获取屏幕的宽度
	screenWidth = get_viewport().size.x
	screenHeight = get_viewport().size.y
	
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
	death_block.position = Vector2(32, screenHeight + 50.0)
	
	## 生成砖块
	_generate_bricks()
	
## 生成砖块 
func _generate_bricks() -> void:
	var brickRes: Resource = preload("res://scene/brick.tscn")
	## 先根据整个屏幕的宽度，计算出能够生成的范围（左右两侧，各100的边界）
	var width: int = screenWidth - 30 - 30
	var brickWidth: int = 42
	var brickHeight: int = 16
	var gap: int = 12
	var leftBegin: int = 40
	var topBegin: int = 40
	
	## 计算一行能容纳多少
	var count: int = width / (brickWidth + gap)
	
	for x in range(5):
		for i in count:
			## 实例化
			var b: Brick = brickRes.instantiate()
			var pos: Vector2 = Vector2(leftBegin + i * (brickWidth + gap), topBegin * x)
			b.position = pos
			bricks.add_child(b)


func _process(delta: float) -> void:
	pass
			
func _physics_process(delta: float) -> void:
	if not isDead:
		## 左右移动横轴的差值
		var moveAxis: float = Input.get_axis("move_left", "move_right")
		## 移动的趋势
		var trend: float = moveAxis * delta * MOVE_SPEED
		
		var newX: float = platform.position.x + trend

		## 限定范围
		if newX >= limit and newX <= screenWidth - limit:
			## 平台左右移动
			platform.position.x = newX
			
			## ball未发射前，跟随
			if not isShoot:
				## 如果ball还未发射过，那么也可以跟着平台一起移动
				ball.position.x = ball.position.x + trend
				
		## 小球开始移动了
		if isShoot:
			ball.velocity = dir * BALL_SPEED * delta
			var coll: KinematicCollision2D = ball.move_and_collide(ball.velocity)
			
			## 碰撞检测
			if coll:
				## 播放碰撞音效
				ball_pop_up.play()
				
				## 获取碰撞点的法线
				var nor: Vector2 = coll.get_normal()
				## 以法线为中线的反向向量
				dir = ball.velocity.bounce(nor)
				## 生成一点随机数值
				var v: Vector2 = Vector2(rng.randf_range(0, 1), rng.randf_range(0, 1))
				dir = (dir + v).normalized()
				
				ball.velocity = dir * BALL_SPEED * delta
				ball.move_and_collide(ball.velocity)
				
				## 判断碰撞的是否是砖块
				if coll.get_collider() is Brick:
					## 发送一个砖块爆炸的信号
					var b: Brick = coll.get_collider()
					b.brick_explosion.emit()
		
		
func _unhandled_input(event: InputEvent) -> void:
	## 处理发射事件
	if event.is_action_pressed("shoot") and not isShoot and not isDead:
		## 先把是否第一次发射，改为true
		isShoot = true
		## 随机定义符号
		var i : int = rng.randi_range(0, 1)
		## 按 45度 or 135度 角发射出去，转为弧度
		deg = 45.0 if i else 135.0
		angle = deg_to_rad(deg)
		## 第一次的方向向量
		dir = Vector2(cos(angle), -sin(angle)).normalized()
		


func _on_death_block_body_entered(body: Node2D) -> void:
	## 先对body的类型进行判断
	if body is Ball:
		## 转换
		var ball: Ball = body
		ball.queue_free()
		
		## 设置死亡
		isDead = true
		## 播放死亡音效
		ball_explosion.play()
		## 死亡冻结开始计时
		death_wait.start()


func _on_death_wait_timeout() -> void:
	## 计时器播放完毕后回调
	get_tree().reload_current_scene()
		
