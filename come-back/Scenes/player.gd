extends CharacterBody2D

@export var speed = 400
@export var gravity = -800

func get_input():
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_direction * speed

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	get_input()
	move_and_slide()
	
