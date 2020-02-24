extends KinematicBody2D

export var speed = 300

var direction_vector

var rng = RandomNumberGenerator.new()
var startingPos = Vector2()
var start = false
var lives = 3
var score = 0
var lives_string = "Lives: {int}"
var score_string = "Score: {int}"

# Called when the node enters the scene tree for the first time.
func _ready():
	direction_vector = Vector2()
	startingPos = position
	rng.randomize()
	var num = rng.randi_range(1,2)
	if num == 1:
		direction_vector.x = speed
		direction_vector.y = -speed
	elif num == 2:
		direction_vector.x = -speed
		direction_vector.y = -speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Input.is_action_just_pressed("action"):
		start = true
	
	if(start):
		var collision = move_and_collide(direction_vector * delta)
		if collision:
			var collider = collision.collider
			if collider == get_node(".."):
				direction_vector = direction_vector.bounce(collision.normal)
			elif collider == get_node("../Bricks"):
				handle_brick_collision(collision)
			elif collider == get_node("../Paddle"):
				handle_paddle_collision()
		if position.y > get_viewport().size.y:
			reset()
			lives -= 1
			
			#Update lives label to screen
			var lives_label = get_node("../../LivesLabel")
			lives_label.text = lives_string.format({"int": lives})
			
			if lives <= 0:
				var win_label = get_node("../../WinLoseLabel")
				win_label.text = "Game Over!"
				win_label.visible = true
				get_node("..").gameover()
				
func reset():
	position = startingPos
	get_node("../Paddle").reset()
	start = false
	rng.randomize()
	var num = 1 #rng.randi_range(1,2)
	if num == 1:
		direction_vector.x = speed
		direction_vector.y = -speed
	elif num == 2:
		direction_vector.x = -speed
		direction_vector.y = -speed

func handle_brick_collision(collision):
	var collider = collision.collider
	direction_vector = direction_vector.bounce(collision.normal)
	var tile_global_pos = collider.world_to_map(position)
	tile_global_pos -= collision.normal
	var brick_id = collider.get_cellv(tile_global_pos)
	if brick_id != -1:
		collider.set_cellv(tile_global_pos, -1)
	else:
		corner_checks(collision)
	
	score += 100
	var score_label = get_node("../../ScoreLabel")
	score_label.text = score_string.format({"int": score})
	
	if collider.get_used_cells().size() == 0:
		var win_label = get_node("../../WinLoseLabel")
		win_label.visible = true
		
	
	
func corner_checks(collision):
	# corner check
	var collider = collision.collider
	var ball_sprite = get_node("./Ball") 
	var width = ball_sprite.texture.get_size().x
	var height = ball_sprite.texture.get_size().y
	var adjusted_position = position
	
	for i in range(4):
		if i == 0:
			#RD
			adjusted_position.x = position.x + (width / 2)
			adjusted_position.y = position.y + (height / 2)
		elif i == 1:
			#RU
			adjusted_position.x = position.x + (width / 2)
			adjusted_position.y = position.y - (height / 2)
		elif i == 2:
			#LD
			adjusted_position.x = position.x - (width / 2)
			adjusted_position.y = position.y + (height / 2)
		elif i == 3:
			#LU
			adjusted_position.x = position.x - (width / 2)
			adjusted_position.y = position.y - (height / 2)
	
		var tile_global_pos = collider.world_to_map(adjusted_position)
		tile_global_pos -= collision.normal
		var brick_id = collider.get_cellv(tile_global_pos)
		if(brick_id != -1):
			collider.set_cellv(tile_global_pos, -1)
			break
		
func handle_paddle_collision():
		var paddle_position = get_node("../Paddle").position
		var ball_position = position
		
		var paddle_area = ball_position - paddle_position
		paddle_area = paddle_area.normalized()
		
		direction_vector.x = paddle_area.x * speed
		direction_vector.y = paddle_area.y * speed
		