extends StaticBody2D

# ==========================================
# PINTU KELUAR — Dipanggil saat puzzle selesai
# Tambahkan node ini ke group "pintu_keluar"
# ==========================================

@onready var collision = $CollisionShape2D
@onready var sprite    = get_node_or_null("Sprite2D")
@onready var animasi   = get_node_or_null("AnimationPlayer")

func _ready() -> void:
	add_to_group("pintu_keluar")

func buka_pintu() -> void:
	print("[PINTU]: Pintu terbuka!")

	# Nonaktifkan collision agar player bisa lewat
	if collision:
		collision.set_deferred("disabled", true)

	# Mainkan animasi jika ada
	if animasi and animasi.has_animation("buka"):
		animasi.play("buka")
	elif sprite:
		# Tidak ada animasi — sembunyikan saja
		sprite.hide()
	else:
		hide()
