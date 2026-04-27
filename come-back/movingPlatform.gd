extends Path2D


@export var loop = true
@export var speed = 2.0
@export var speed_scale = 1.0

@onready var path = $PathFollow2D
@onready var animation = $AnimationPlayer


func _ready() -> void:
	if not loop:
		animation.play("Up_Down_Block")
		animation.speed_scale = speed_scale
		set_process(false) 
	
func _process(delta: float) -> void:
	pass
