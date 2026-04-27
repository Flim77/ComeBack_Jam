extends CanvasLayer

var anim: AnimatedSprite2D

func _ready():
	anim = get_node("AnimatedSprite2D")
	

func play_in():
	anim.play("in")
	await anim.animation_finished

func hold():
	anim.stop()
	anim.frame = 7

func play_out():
	anim.play("out")
	await anim.animation_finished
