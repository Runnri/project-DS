extends Control

@onready var vbox        = $MenuBlock
@onready var judul_game  = $TitleBlock/Judul
@onready var load_button = $MenuBlock/LoadButton
@onready var user_text   = $LabelUser/UserText

var time: float = 0.0
var base_vbox_y: float = 0.0
var base_judul_pos: Vector2 = Vector2.ZERO
var timer_tunggu: float = 0.0
var is_glitching: bool = false
var durasi_glitch: float = 0.0

func _ready():
	BgmManager.play("lobby")
	base_vbox_y    = vbox.position.y
	base_judul_pos = judul_game.position
	timer_tunggu   = randf_range(2.0, 5.0)

	if user_text:
		user_text.text = "USER: " + Global.username_aktif.to_upper()

	if load_button:
		if Global.ada_file_save():
			load_button.disabled = false
			var info = Global.baca_info_save()
			if info.size() > 0:
				var nama = info.get("level","?").get_file().replace(".tscn","").replace("_"," ").to_upper()
				load_button.tooltip_text = "LEVEL: " + nama + \
					"\nDIFF: " + info.get("kesulitan","?").to_upper() + \
					"\nSAVED: " + info.get("timestamp","?")
		else:
			load_button.disabled = true
			load_button.tooltip_text = "NO SAVE DATA FOUND."

func _process(delta):
	time += delta
	vbox.position.y = base_vbox_y + (sin(time) * 6.0)

	if not is_glitching:
		timer_tunggu -= delta
		if timer_tunggu <= 0:
			mulai_glitch()
	else:
		durasi_glitch -= delta
		judul_game.position.x = base_judul_pos.x + randf_range(-6.0, 6.0)
		judul_game.position.y = base_judul_pos.y + randf_range(-2.0, 2.0)
		judul_game.visible    = randf() > 0.35
		if durasi_glitch <= 0:
			stop_glitch()

func mulai_glitch():
	is_glitching  = true
	durasi_glitch = randf_range(0.08, 0.25)

func stop_glitch():
	is_glitching       = false
	judul_game.visible  = true
	judul_game.position = base_judul_pos
	timer_tunggu        = randf_range(2.0, 6.0)

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/difficulty.tscn")

func _on_load_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/load_game.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
