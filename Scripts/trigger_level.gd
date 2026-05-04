extends Area2D

@export_multiline var pesan_level: String = "SEQUENCE 1..."
@export var aktifkan_autosave: bool = true
@export var nama_scene_level: String = "res://Scenes/level_easy.tscn"
@export var ganti_bgm: String = ""

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	var scene_root = get_tree().current_scene
	var dialog_ui = scene_root.get_node_or_null("DialogNaratif")
	if dialog_ui and dialog_ui.has_method("tampilkan"):
		dialog_ui.tampilkan(pesan_level)

	if not ganti_bgm.is_empty():
		BgmManager.fade_to(ganti_bgm)

	if aktifkan_autosave:
		if nama_scene_level.is_empty():
			push_warning("[TRIGGER]: 'nama_scene_level' belum diisi! Autosave dibatalkan.")
		else:
			# FIX: kirim nama_scene_level sebagai parameter ke-2
			Global.simpan_game(body, nama_scene_level)

	queue_free()
