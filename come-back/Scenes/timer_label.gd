extends Label

@export var death_timer: Timer
@export var player: CharacterBody2D

func _process(delta):
	if death_timer == null:
		return
	
	var time_left = death_timer.time_left
	if not player.has_moved_once:
		text = "%d" % int(ceil(death_timer.wait_time))
		return
		
	text = str(int(ceil(time_left)))
