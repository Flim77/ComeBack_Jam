extends CharacterBody2D

# --- Movement ---
@export var speed := 150.0
@export var acceleration := 1200.0
@export var friction := 1500.0

# --- Jumping ---
@export var jump_velocity := -400.0
@export var gravity := 900.0
@export var max_jumps = Level.trueMax_jumps

# --- Dash ---
@export var dash_speed := 600.0
@export var dash_time := 0.2
@export var dash_cooldown := 0.3

# --- Wall ---
@export var wall_slide_speed := 100.0
@export var wall_jump_force := Vector2(300, -400)
@export var wall_climb_speed := 80.0
@export var wall_climb_hold_force := 50.0

# -- Elements grabs --
@export var DeathTimer: Timer

# --- States ---
var jump_count := 0
var can_dash := true
var is_dashing := false
var dash_timer := 0.0
var dash_dir := 0
var has_moved_once = false
var mitosis_count = 9

# --- Animation ---
@onready var csprite = $AnimatedSprite2D
@export var mitosis: PackedScene
@onready var transition = get_tree().current_scene.get_node("Trans/Transition")
var was_moving = false
var fall_lock = false
var dashin = false
var is_dead := false

# --- Camera ---
var current_cam_index := 0
@export var cam_height := 720
@export var cam_lower_limit: int = 360
@export var cam_upper_limit: int = -360

signal change_camera_pos


func _ready() -> void:
	if Level.passWallUnlock:
		pass_block()
	if Level.trans == 1:
		if Level.deathCount > 8:
			transition.play("transitioning")
			
		else:
			transition.play("out")
		Level.trans = 0
	DeathTimer.wait_time = Level.deathTimerTime


func _physics_process(delta):
	apply_gravity(delta)
	
	if is_dead:
		move_and_slide()
		return
	
	handle_movement(delta)
	_handle_animation()

	if Level.jumpUnlock:
		handle_jump()
	if Level.dashUnlock:
		handle_dash(delta)
	if Level.wallJumpUnlock:
		handle_wall()
	if Level.mitosisUnlock:
		handle_mitosis()
		
	camera_movement_match()
	move_and_slide()
	reset_states()


func handle_movement(delta):
	var direction = Input.get_axis("move_left", "move_right")

	if SingalBus.wait_for_dialog:
		if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
			SingalBus.wait_for_dialog = false
			SingalBus.emit_signal("dialog_fade")

	if direction != 0:
		if not has_moved_once:
			DeathTimer.start()
			has_moved_once = true

	if not is_dashing:
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * (speed + Level.speedAdd), acceleration * delta)
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
	var touching_wall = is_on_wall() and not is_on_floor()
	var input_dir = Input.get_axis("move_left", "move_right")
	var vertical_input = Input.get_axis("move_up", "move_down")

	if touching_wall:
		var wall_normal = get_wall_normal().x
		if input_dir != 0 and sign(input_dir) == -sign(wall_normal):
			if vertical_input != 0:
				velocity.y = vertical_input * wall_climb_speed
			else:
				velocity.y = 0
			velocity.x = -wall_normal * wall_climb_hold_force
		elif velocity.y > 0:
			velocity.y = min(velocity.y, wall_slide_speed)


func wall_jump():
	var wall_dir = get_wall_normal().x
	velocity.x = wall_dir * wall_jump_force.x
	velocity.y = wall_jump_force.y
	jump_count = 1


func handle_dash(delta):
	if Input.is_action_just_pressed("dash") and can_dash:
		if Level.airDashUnlock:
			start_dash()
		elif is_on_floor():
			start_dash()
		else:
			return

	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_dir * dash_speed
		velocity.y = 0

		if dash_timer <= 0:
			end_dash()


func _handle_animation():
	if is_dead:
		return

	var direction = Input.get_axis("move_left", "move_right")
	var is_moving = abs(velocity.x) > 0

	if direction != 0:
		csprite.flip_h = direction < 0

	if dashin:
		if is_on_floor():
			play_anim("dash")
		elif Level.airDashUnlock:
			play_anim("airdash")

		if csprite.animation in ["dash", "airdash"] and not csprite.is_playing():
			dashin = false
		return

	if Input.is_action_just_pressed("dash") and can_dash and Level.dashUnlock:
		dashin = true
		if is_on_floor():
			play_anim("dash")
		elif Level.airDashUnlock:
			play_anim("airdash")
		return

	if is_on_wall() and not is_on_floor():
		if direction == -get_wall_normal().x:
			if Input.is_action_pressed("move_up"):
				play_anim("climbup")
			elif Input.is_action_pressed("move_down"):
				play_anim("climbdown")
			else:
				play_anim("wall")
			return

	if not is_on_floor():
		if velocity.y < 0:
			if is_moving:
				play_anim("jumpdir")
			else:
				play_anim("jump")
		else:
			if not fall_lock:
				fall_lock = is_moving

			if fall_lock:
				play_anim("fallmove")
			else:
				play_anim("fall")
		return

	fall_lock = false

	if not was_moving and is_moving:
		play_anim("move_between")
	elif was_moving and not is_moving:
		play_anim("move_between")
	elif is_moving:
		play_anim("move")
	else:
		play_anim("idle")

	was_moving = is_moving


func camera_movement_match():
	var center_y = current_cam_index * cam_height + cam_height / 2

	if global_position.y < center_y - (cam_height / 2):
		current_cam_index -= 1
		emit_camera()

	elif global_position.y > center_y + (cam_height / 2):
		current_cam_index += 1
		emit_camera()


func emit_camera():
	var new_cam_y = current_cam_index * cam_height + cam_height / 2
	change_camera_pos.emit(new_cam_y)


func start_dash():
	is_dashing = true
	can_dash = false
	dash_timer = dash_time

	dash_dir = sign(Input.get_axis("move_left", "move_right"))
	if dash_dir == 0:
		dash_dir = sign(scale.x)


func end_dash():
	is_dashing = false
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true


func reset_states():
	if is_on_floor():
		jump_count = 0
		can_dash = true


func pass_block():
	set_collision_mask_value(2, false)


func handle_mitosis():
	if Input.is_action_just_pressed("split") and mitosis_count > 0:
		if not is_on_floor():
			return
		DeathTimer.start()
		mitosis_count -= 1
		var fallguy = mitosis.instantiate()
		get_parent().add_child(fallguy)
		
		fallguy.global_position = global_position
		var fake_sprite = fallguy.get_node("AnimatedSprite2D")

		
		fake_sprite.scale = csprite.scale
		fake_sprite.offset = csprite.offset
		fake_sprite.flip_h = csprite.flip_h
		
		fallguy.start()
		var dir = -1 if csprite.flip_h else 1
		velocity.x += 600 * dir
		velocity.y = -250


func death():
	if is_dead:
		return
		
	is_dead = true
	DeathTimer.stop()
	velocity.x = 0
	play_anim("death")

	while csprite.is_playing():
		await get_tree().process_frame

	Level.deathCount += 1
	Level.trans = 1
	
	await get_tree().create_timer(0.5).timeout
	if Level.deathCount > 8:
		transition.play("undu")
	else:
		transition.play("in")
	await transition.animation_finished
	await get_tree().create_timer(1.0).timeout
	handle_upgrade()
	SingalBus.wait_for_dialog = true
	get_tree().reload_current_scene()
	


func play_anim(name):
	if csprite.animation != name:
		csprite.play(name)


func _on_death_timer_timeout() -> void:
	death()

func _on_body_entered(body):
	return
		
func handle_upgrade():
	match Level.deathCount:
		1:
			Level.jumpUnlock = true
			Level.deathTimerTime = 90
		2:
			Level.speedAdd += 200
		3:
			Level.dashUnlock = true
		4:
			Level.passWallUnlock = true
			Level.deathTimerTime = 75
		5:
			Level.trueMax_jumps = 2
		6:
			Level.wallJumpUnlock = true
			Level.deathTimerTime = 60
		7:
			Level.airDashUnlock = true
		8:
			Level.mitosisUnlock = true
			Level.deathTimerTime = 40
		9:
			Level.resetGame()
			#transition.play("transitioning")
			


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
