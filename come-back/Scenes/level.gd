extends Node2D

# ---Game Triggers ---
@export var deathCount = 0
@export var trans = 0
var speedAdd = 0
var jumpUnlock = false
var dashUnlock = false
var wallJumpUnlock = false
var airDashUnlock = false
var passWallUnlock = false
var mitosisUnlock = false
var trueMax_jumps = 1
var deathTimerTime = 400

func resetGame():
	deathCount = 0
	speedAdd = 0
	jumpUnlock = false
	dashUnlock = false
	wallJumpUnlock = false
	airDashUnlock = false
	passWallUnlock = false
	mitosisUnlock = false
	trueMax_jumps = 1
	deathTimerTime = 400

func _on_player_change_camera_pos(player_pos):
	$Camera2D.position.y = player_pos


func _on_character_body_2d_change_camera_pos(player_pos):
	$Camera2D.position.y = player_pos
