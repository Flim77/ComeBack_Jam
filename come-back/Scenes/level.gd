extends Node2D

func _on_player_change_camera_pos(player_pos):
	$Camera2D.position.y = player_pos


func _on_character_body_2d_change_camera_pos(player_pos):
	$Camera2D.position.y = player_pos
