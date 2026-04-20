extends Control

# ==========================================
# 1. PERSIAPAN NODE & VARIABEL
# ==========================================
@onready var vbox        = $VBoxContainer
@onready var judul_game  = $Judul
@onready var load_button = $VBoxContainer/LoadButton
@onready var label_user  = $LabelUser   # Label kecil "Login sebagai: xxx"

var time: float = 0.0
var base_vbox_y: float = 0.0
var base_judul_pos: Vector2 = Vector2.ZERO
var timer_tunggu: float = 0.0
var is_glitching: bool = false
var durasi_glitch: float = 0.0

# ==========================================
# 2. READY
# ==========================================
func _ready():
	base_vbox_y    = vbox.position.y
	base_judul_pos = judul_game.position
	timer_tunggu   = randf_range(2.0, 5.0)
	_perbarui_ui_user()

func _perbarui_ui_user():
	# Tampilkan username jika sudah login
	if label_user != null:
		if Global.sudah_login():
			label_user.text    = "[ " + Global.username_aktif + " ]"
			label_user.visible = true
		else:
			label_user.visible = false

	# Tombol Load hanya aktif jika sudah login DAN ada save
	if load_button != null:
		if Global.sudah_login() and Global.ada_file_save():
			load_button.disabled = false
			var info = Global.baca_info_save()
			if info.size() > 0:
				var nama = info.get("level","?").get_file().replace(".tscn","").replace("_"," ").capitalize()
				load_button.tooltip_text = "Level: " + nama + \
					"\nKesulitan: " + info.get("kesulitan","?").capitalize() + \
					"\nDisimpan: " + info.get("timestamp","?")
		else:
			load_button.disabled = true
			load_button.tooltip_text = "Belum ada data tersimpan."

# ==========================================
# 3. PROCESS (animasi)
# ==========================================
func _process(delta):
	time += delta * 1.0
	vbox.position.y = base_vbox_y + (sin(time) * 10.0)

	if not is_glitching:
		timer_tunggu -= delta
		if timer_tunggu <= 0:
			mulai_glitch()
	else:
		durasi_glitch -= delta
		judul_game.position.x = base_judul_pos.x + randf_range(-8.0, 8.0)
		judul_game.position.y = base_judul_pos.y + randf_range(-3.0, 3.0)
		judul_game.visible    = randf() > 0.4
		if durasi_glitch <= 0:
			stop_glitch()

func mulai_glitch():
	is_glitching  = true
	durasi_glitch = randf_range(0.1, 0.3)

func stop_glitch():
	is_glitching       = false
	judul_game.visible  = true
	judul_game.position = base_judul_pos
	timer_tunggu        = randf_range(2.0, 6.0)

# ==========================================
# 4. TOMBOL
# ==========================================
func _on_start_button_pressed():
	# Kalau belum login → ke Auth dulu, tujuan = start
	# Kalau sudah login → langsung ke difficulty
	if Global.sudah_login():
		get_tree().change_scene_to_file("res://Scenes/difficulty.tscn")
	else:
		Global.auth_tujuan = "start"
		get_tree().change_scene_to_file("res://Scenes/auth.tscn")

func _on_load_button_pressed():
	if Global.sudah_login():
		get_tree().change_scene_to_file("res://Scenes/load_game.tscn")
	else:
		Global.auth_tujuan = "load"
		get_tree().change_scene_to_file("res://Scenes/auth.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
