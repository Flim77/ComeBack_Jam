extends Camera2D

@onready var screen_size: Vector2 = get_viewport_rect().size
@export var player_node: Node2D

func _ready():
	await get_tree().process_frame
	set_screen_position()

	position_smoothing_enabled = true
	position_smoothing_speed = 1.0
	
func _process(delta: float) -> void:
	set_screen_position()

func set_screen_position():
	var player_pos = player_node.global_position
	var x = floor(player_pos.x / screen_size.x) * screen_size.x + screen_size.x /2
	var y = floor(player_pos.y / screen_size.y) * screen_size.y + screen_size.y /2
	global_position = Vector2(x, y)
