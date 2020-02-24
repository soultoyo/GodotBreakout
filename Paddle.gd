extends KinematicBody2D

export var speed = 300
var vel = Vector2()
var startingPos = Vector2()


# Called when the node enters the scene tree for the first time.
func _ready():
	startingPos = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Input.is_action_pressed("left"):
		#Move left
		vel.x = delta * -speed
	elif Input.is_action_pressed("right"):
		#Move Right
		vel.x = delta * speed
	else:
		vel.x = 0
	move_and_collide(vel)

func reset():
	position = startingPos