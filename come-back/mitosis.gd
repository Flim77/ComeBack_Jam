extends Node

@onready var sprite = $AnimatedSprite2D

func start():
	
	sprite.play("split_n_die")
	await get_tree().create_timer(0.5).timeout
	queue_free()
