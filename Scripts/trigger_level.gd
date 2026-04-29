extends Area2D

@export_multiline var pesan_level: String = "SEQUENCE 1..."

# --- FITUR BARU: SAKLAR AUTOSAVE ---
@export var aktifkan_autosave: bool = true 

# Nama scene level ini — harus diisi di Inspector agar autosave tahu posisi pemain
@export var nama_scene_level: String = "res://Scenes/level_easy.tscn"

func _on_body_entered(body: Node2D) -> void:
	# Hanya bereaksi terhadap Player
	if not body.is_in_group("player"):
		return

	# 1. Tampilkan notifikasi teks (Tetap jalan untuk semua trigger)
	if body.has_method("tampilkan_notif_level"):
		body.tampilkan_notif_level(pesan_level)

	# 2. Logika Autosave (Hanya jalan jika saklar dicentang)
	if aktifkan_autosave:
		if nama_scene_level.is_empty():
			push_warning("[TRIGGER]: 'nama_scene_level' belum diisi! Autosave dibatalkan.")
		else:
			# --- BENTROKAN DIPERBAIKI DI SINI ---
			# Cukup kirim 'body' (si Player) saja, sesuai permintaan global.gd
			Global.simpan_game(body)
			print("[SYSTEM]: Progress berhasil disimpan secara otomatis.")

	# Hapus trigger setelah sekali disentuh
	queue_free()
