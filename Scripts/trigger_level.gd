extends Area2D

@export_multiline var pesan_level: String = "SEQUENCE 1..."
# Nama scene level ini — harus diisi di Inspector agar autosave tahu posisi pemain
@export var nama_scene_level: String = "res://Scenes/level_easy.tscn"

func _on_body_entered(body: Node2D) -> void:
	# Hanya bereaksi terhadap Player
	if not body.is_in_group("player"):
		return

	# Tampilkan notifikasi teks dengan animasi fade in/out
	if body.has_method("tampilkan_notif_level"):
		body.tampilkan_notif_level(pesan_level)

	# --- AUTOSAVE ---
	# Validasi: pastikan nama_scene_level sudah diisi di Inspector
	if nama_scene_level.is_empty():
		push_warning("[TRIGGER]: 'nama_scene_level' belum diisi di Inspector! Autosave dibatalkan.")
	else:
		Global.simpan_game(body, nama_scene_level)

	# Hapus trigger setelah sekali disentuh (tidak boleh trigger dua kali)
	queue_free()
