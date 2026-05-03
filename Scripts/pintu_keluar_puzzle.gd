extends StaticBody2D

# ==========================================
# PINTU KELUAR — Dipanggil saat puzzle selesai
# Tambahkan node ini ke group "pintu_keluar"
# ==========================================

@onready var collision = $CollisionShape2D
@onready var visual_pintu = $ColorRect # Langsung ambil ColorRect-nya

func _ready() -> void:
	# Memastikan pintu masuk grup agar bisa dipanggil oleh puzzle manager
	add_to_group("pintu_keluar")

func buka_pintu() -> void:
	print("[PINTU]: Pintu terbuka!")

	# 1. Nonaktifkan collision agar player bisa lewat
	if collision:
		collision.set_deferred("disabled", true)

	# 2. Sembunyikan ColorRect agar pintunya seolah-olah hilang/terbuka
	if visual_pintu:
		visual_pintu.hide()
	
	# Opsional: Kalau mau menyembunyikan seluruh node PintuPuzzle sekaligus, 
	# kamu juga bisa cukup memanggil hide() di sini.
