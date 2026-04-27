extends CanvasLayer

@export_file("*.json") var scene_text_file

var scene_text = {}
var selected_text = []
var in_progress = false
var is_fading := false

@onready var background = $Background
@onready var text_label = $Text_Label
@onready var tuna = $tuna


func _enter_tree():
	SingalBus.connect("dialog_fade", Callable(self, "fade_out_dialog"))
	SingalBus.connect("display_dialog", Callable(self, "on_display_dialog"))


func _ready():
	background.visible = false
	tuna.visible = false
	background.modulate.a = 1.0
	text_label.modulate.a = 1.0
	tuna.modulate.a = 1.0
	
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	
	
	scene_text = load_scene_text()

	SingalBus.connect("dialog_fade", Callable(self, "fade_out_dialog"))
	SingalBus.connect("display_dialog", Callable(self, "on_display_dialog"))

	call_deferred("check_for_death_dialog")

func load_scene_text():
	if FileAccess.file_exists(scene_text_file):
		var file = FileAccess.open(scene_text_file, FileAccess.READ)
		return JSON.parse_string(file.get_as_text())
	return {}


func on_display_dialog(text_key):
	if not scene_text.has(text_key):
		return

	if in_progress:
		next_line()
		return

	background.visible = true
	tuna.visible = true
	in_progress = true
	selected_text = scene_text[text_key].duplicate()

	show_text()


func show_text():
	if is_fading:
		return

	background.visible = true
	text_label.visible = true
	tuna.visible = true

	background.modulate.a = 1.0
	text_label.modulate.a = 1.0
	tuna.modulate.a = 1.0

	text_label.text = selected_text.pop_front()


func next_line():
	if selected_text.size() > 0:
		show_text()
	else:
		finish()


func finish():
	text_label.text = ""
	background.visible = false
	in_progress = false
	get_tree().paused = false


func fade_out_dialog():
	if is_fading:
		return
	is_fading = true
	
	background.visible = true
	text_label.visible = true
	tuna.visible = true

	var tween = create_tween()
	tween.tween_property(background, "modulate:a", 0.0, 0.15)
	tween.parallel().tween_property(text_label, "modulate:a", 0.0, 0.15)
	tween.parallel().tween_property(tuna, "modulate:a", 0.0, 0.15)

	await tween.finished
	is_fading = false 


func check_for_death_dialog():
	match Level.deathCount:
		1:
			SingalBus.emit_signal("display_dialog", "Death1")
		2:
			SingalBus.emit_signal("display_dialog", "Death2")
		3:
			SingalBus.emit_signal("display_dialog", "Death3")
		4:
			SingalBus.emit_signal("display_dialog", "Death4")
		5:
			SingalBus.emit_signal("display_dialog", "Death5")
		6:
			SingalBus.emit_signal("display_dialog", "Death6")
		7:
			SingalBus.emit_signal("display_dialog", "Death7")
		8:
			SingalBus.emit_signal("display_dialog", "Death8")
