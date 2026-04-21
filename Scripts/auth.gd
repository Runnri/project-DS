extends Control

var mode: String = "login"

@onready var label_judul    = $Panel/VBox/LabelJudul
@onready var input_username = $Panel/VBox/InputUsername
@onready var input_password = $Panel/VBox/InputPassword
@onready var label_error    = $Panel/VBox/LabelError

func _ready():
	label_error.text = ""
	input_password.secret = true
	_set_mode("login")

func _set_mode(m: String):
	mode = m
	label_error.text = ""
	input_username.text = ""
	input_password.text = ""

	if mode == "login":
		label_judul.text = "// LOGIN //"
		$Panel/VBox/BtnAksi.text   = "MASUK"
		$Panel/VBox/BtnToggle.text = "Belum punya akun? Register"
	else:
		label_judul.text = "// REGISTER //"
		$Panel/VBox/BtnAksi.text   = "DAFTAR"
		$Panel/VBox/BtnToggle.text = "Sudah punya akun? Login"

func _on_btn_aksi_pressed():
	var username = input_username.text
	var password = input_password.text
	label_error.text = ""

	var err_msg: String = ""

	if mode == "login":
		err_msg = Global.login(username, password)
		if err_msg == "":
			get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	else:
		err_msg = Global.register(username, password)
		if err_msg == "":
			Global.login(username, password)
			label_error.modulate = Color(0.3, 1.0, 0.5, 1)
			label_error.text = "Akun berhasil dibuat! Masuk..."
			await get_tree().create_timer(1.0).timeout
			get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

	if err_msg != "":
		label_error.modulate = Color(1.0, 0.3, 0.3, 1)
		label_error.text = err_msg

func _on_btn_toggle_pressed():
	if mode == "login":
		_set_mode("register")
	else:
		_set_mode("login")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_on_btn_aksi_pressed()
