extends CanvasLayer

@onready var life_sprite = $Sidebar
@export var life_textures: Array[Texture2D]

func _ready():
	await get_tree().process_frame
	update_life()
	
func update_life():
	var index = clamp(Level.deathCount, 0, life_textures.size() -1)
	life_sprite.texture = life_textures[index]
