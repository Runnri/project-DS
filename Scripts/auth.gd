extends Control

var mode: String = "login"

@onready var label_prompt  = $Panel/VBox/HeaderBox/LabelPrompt
@onready var label_judul   = $Panel/VBox/HeaderBox/LabelJudul
@onready var input_username = $Panel/VBox/InputUsername
@onready var input_password = $Panel/VBox/InputPassword
@onready var label_error   = $Panel/VBox/LabelError
@onready var btn_aksi      = $Panel/VBox/BtnAksi
@onready var btn_toggle    = $Panel/VBox/BtnToggle

func _ready():
	BgmManager.play("lobby")
	label_error.text = ""
	input_password.secret = true
	_set_mode("login")

func _set_mode(m: String):
	mode = m
	label_error.text = ""
	input_username.text = ""
	input_password.text = ""

	if mode == "login":
		label_prompt.text  = "> IDENTIFYING USER..."
		label_judul.text   = "ACCESS_TERMINAL"
		btn_aksi.text      = "LOGIN"
		btn_toggle.text    = "NO ACCOUNT?  REGISTER_NEW"
	else:
		label_prompt.text  = "> CREATING NEW IDENTITY..."
		label_judul.text   = "REGISTER_NODE"
		btn_aksi.text      = "REGISTER"
		btn_toggle.text    = "HAVE ACCOUNT?  LOGIN"

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
			label_error.add_theme_color_override("font_color", Color(0.2, 0.9, 0.5, 1.0))
			label_error.text = "> IDENTITY COMMITTED. LOGGING IN..."
			await get_tree().create_timer(1.0).timeout
			get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

	if err_msg != "":
		label_error.add_theme_color_override("font_color", Color(0.95, 0.2, 0.2, 1.0))
		label_error.text = "> ERR: " + err_msg.to_upper()

func _on_btn_toggle_pressed():
	if mode == "login":
		_set_mode("register")
	else:
		_set_mode("login")

func _input(event):
	if event.is_action_pressed("ui_accept"):
		_on_btn_aksi_pressed()
