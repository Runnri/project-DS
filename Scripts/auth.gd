extends Control

# ==========================================
# MODE: "login" atau "register"
# ==========================================
var mode: String = "login"

# Dari mana scene ini dipanggil: "start" atau "load"
var tujuan: String = "start"

@onready var label_judul    = $Panel/VBox/LabelJudul
@onready var input_username = $Panel/VBox/InputUsername
@onready var input_password = $Panel/VBox/InputPassword
@onready var btn_aksi       = $Panel/VBox/BtnAksi
@onready var btn_toggle     = $Panel/VBox/BtnToggle
@onready var label_error    = $Panel/VBox/LabelError
@onready var btn_kembali    = $BtnKembali

func _ready():
	# Terima parameter dari scene sebelumnya via Global
	tujuan = Global.auth_tujuan
	label_error.text = ""
	input_password.secret = true
	_set_mode("login")

func _set_mode(m: String):
	mode = m
	label_error.text = ""
	input_username.text = ""
	input_password.text = ""

	if mode == "login":
		label_judul.text  = " LOGIN "
		btn_aksi.text     = "MASUK"
		btn_toggle.text   = "Belum punya akun? Register"
	else:
		label_judul.text  = " REGISTER "
		btn_aksi.text     = "DAFTAR"
		btn_toggle.text   = "Sudah punya akun? Login"

func _on_btn_aksi_pressed():
	var username = input_username.text
	var password = input_password.text
	label_error.text = ""

	var err_msg: String = ""

	if mode == "login":
		err_msg = Global.login(username, password)
		if err_msg == "":
			_lanjut_setelah_auth()
	else:
		err_msg = Global.register(username, password)
		if err_msg == "":
			# Auto-login setelah register berhasil
			Global.login(username, password)
			label_error.modulate = Color(0.3, 1.0, 0.5, 1)  # hijau = sukses
			label_error.text = "Akun berhasil dibuat! Masuk..."
			await get_tree().create_timer(1.0).timeout
			_lanjut_setelah_auth()

	if err_msg != "":
		label_error.modulate = Color(1.0, 0.3, 0.3, 1)  # merah = error
		label_error.text = err_msg

func _lanjut_setelah_auth():
	if tujuan == "load":
		get_tree().change_scene_to_file("res://Scenes/load_game.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/difficulty.tscn")

func _on_btn_toggle_pressed():
	if mode == "login":
		_set_mode("register")
	else:
		_set_mode("login")

func _on_btn_kembali_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# Enter = submit
func _input(event):
	if event.is_action_pressed("ui_accept"):
		_on_btn_aksi_pressed()
