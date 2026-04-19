extends Control

# ==========================================
# SCENE LOAD GAME
# Menampilkan info save dan tombol konfirmasi
# ==========================================

@onready var panel_save     = $PanelSave
@onready var label_level    = $PanelSave/VBox/LabelLevel
@onready var label_kesulitan = $PanelSave/VBox/LabelKesulitan
@onready var label_timestamp = $PanelSave/VBox/LabelTimestamp
@onready var label_hp        = $PanelSave/VBox/LabelHP
@onready var panel_kosong   = $PanelKosong
@onready var btn_load       = $PanelSave/VBox/BtnLoad
@onready var btn_hapus      = $PanelSave/VBox/BtnHapus
@onready var btn_kembali    = $BtnKembali
@onready var dialog_konfirmasi = $DialogKonfirmasi

func _ready():
	dialog_konfirmasi.hide()
	_tampilkan_info_save()

func _tampilkan_info_save():
	if Global.ada_file_save():
		panel_save.show()
		panel_kosong.hide()

		var info = Global.baca_info_save()

		# Format nama level supaya lebih manusiawi
		var nama_level = info.get("level", "")
		nama_level = nama_level.get_file().replace(".tscn", "").replace("_", " ").capitalize()

		label_level.text     = "Level   : " + nama_level
		label_kesulitan.text = "Tingkat : " + info.get("kesulitan", "-").capitalize()
		label_timestamp.text = "Disimpan: " + info.get("timestamp", "-")
		label_hp.text        = "HP      : " + str(info.get("hp", "?"))
	else:
		panel_save.hide()
		panel_kosong.show()

func _on_btn_load_pressed():
	if not Global.ada_file_save():
		return

	var info = Global.baca_info_save()
	var nama_level = info.get("level", "")

	if nama_level.is_empty():
		push_error("[LOAD]: Nama level di file save kosong!")
		return

	Global.sedang_load = true

	var err = get_tree().change_scene_to_file(nama_level)
	if err != OK:
		push_error("[LOAD]: Gagal buka scene: " + nama_level)
		Global.sedang_load = false

func _on_btn_hapus_pressed():
	# Tampilkan dialog konfirmasi sebelum hapus
	dialog_konfirmasi.show()

func _on_btn_ya_pressed():
	Global.hapus_save()
	dialog_konfirmasi.hide()
	_tampilkan_info_save()

func _on_btn_tidak_pressed():
	dialog_konfirmasi.hide()

func _on_btn_kembali_pressed():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
