extends Node2D

# ---Game Triggers ---
@export var deathCount = 0
@export var trans = 0
var speedAdd = 200
var jumpUnlock = true
var dashUnlock = true
var wallJumpUnlock = true
var airDashUnlock = true
var passWallUnlock = true
var mitosisUnlock = true 
var trueMax_jumps = 2

	

func _on_player_change_camera_pos(player_pos):
	$Camera2D.position.y = player_pos


func _on_character_body_2d_change_camera_pos(player_pos):
	$Camera2D.position.y = player_pos
