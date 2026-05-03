extends Area2D

@export_multiline var pesan_level: String = "SEQUENCE 1..."
@export var aktifkan_autosave: bool = true
@export var nama_scene_level: String = "res://Scenes/level_easy.tscn"

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	# Tampilkan dialog naratif kotak bawah layar dengan efek ketikan
	var scene_root = get_tree().current_scene
	var dialog_ui = scene_root.get_node_or_null("DialogNaratif")
	if dialog_ui and dialog_ui.has_method("tampilkan"):
		dialog_ui.tampilkan(pesan_level)

	if aktifkan_autosave:
		if nama_scene_level.is_empty():
			push_warning("[TRIGGER]: 'nama_scene_level' belum diisi! Autosave dibatalkan.")
		else:
			Global.simpan_game(body)
			print("[SYSTEM]: Progress berhasil disimpan secara otomatis.")

	queue_free()
