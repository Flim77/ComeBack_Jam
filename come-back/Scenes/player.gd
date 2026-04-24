extends CharacterBody2D

# --- Movement ---
@export var speed := 250.0
@export var acceleration := 1200.0
@export var friction := 1000.0

# --- Jumping ---
@export var jump_velocity := -400.0
@export var gravity := 900.0
@export var max_jumps := 2

# --- Dash ---
@export var dash_speed := 600.0
@export var dash_time := 0.2
@export var dash_cooldown := 0.3

# --- Wall ---
@export var wall_slide_speed := 100.0
@export var wall_jump_force := Vector2(300, -400)

# --- States ---
var jump_count := 0
var can_dash := true
var is_dashing := false
var dash_timer := 0.0
var dash_dir := 0

func _physics_process(delta):
	apply_gravity(delta)
	handle_movement(delta)
	handle_jump()
	handle_dash(delta)
	handle_wall()
	
	move_and_slide()

	reset_states()


func handle_movement(delta):
	var direction = Input.get_axis("move_left", "move_right")
	
	if not is_dashing:
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, friction * delta)


func apply_gravity(delta):
	if not is_on_floor() and not is_dashing:
		velocity.y += gravity * delta


func handle_jump():
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump()
		elif is_on_wall():
			wall_jump()
		elif jump_count < max_jumps:
			jump()

func jump():
	velocity.y = jump_velocity
	jump_count += 1


func handle_wall():
	if is_on_wall() and not is_on_floor() and velocity.y > 0:
		velocity.y = min(velocity.y, wall_slide_speed)

func wall_jump():
	var wall_dir = get_wall_normal().x
	velocity.x = wall_dir * wall_jump_force.x
	velocity.y = wall_jump_force.y
	jump_count = 1  # allows one more jump after wall jump


func handle_dash(delta):
	if Input.is_action_just_pressed("dash") and can_dash:
		start_dash()
	
	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_dir * dash_speed
		velocity.y = 0
		
		if dash_timer <= 0:
			end_dash()

func start_dash():
	is_dashing = true
	can_dash = false
	dash_timer = dash_time
	
	dash_dir = sign(Input.get_axis("move_left", "move_right"))
	if dash_dir == 0:
		dash_dir = sign(scale.x) # fallback to facing direction

func end_dash():
	is_dashing = false
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true

func reset_states():
	if is_on_floor():
		jump_count = 0
		can_dash = true
