extends Area2D

# ==========================================
# UBIN — Script untuk tiap tombol ubin
# Taruh di Area2D, tambahkan ke group "ubin_puzzle"
# Set warna_ubin di Inspector: "biru" / "merah" / "hijau"
# ==========================================

@export var warna_ubin: String = "biru"

# Referensi ke PuzzleManager — cari otomatis via group
@onready var manager: Node = _cari_manager()

# Node visual lampu — opsional, bisa Sprite2D atau ColorRect
# Nama node harus "Lampu" jika ada
@onready var lampu = get_node_or_null("Lampu")

# Warna lampu
const WARNA_BENAR  = Color(0.0, 1.0, 0.0)  # Hijau
const WARNA_SALAH  = Color(1.0, 0.0, 0.0)  # Merah
const WARNA_NETRAL = Color(0.5, 0.5, 0.5)  # Abu (default)

func _ready() -> void:
	add_to_group("ubin_puzzle")
	# Hubungkan sinyal body_entered
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	# Set lampu default
	set_lampu(false)
	print("[UBIN]: Ubin '%s' siap." % warna_ubin)

func _cari_manager() -> Node:
	# Cari PuzzleManager via nama node di scene yang sama
	var m = get_tree().get_root().find_child("PuzzleManager", true, false)
	if not m:
		push_error("[UBIN]: PuzzleManager tidak ditemukan! Pastikan ada node bernama 'PuzzleManager' di scene.")
	return m

func _on_body_entered(_body: Node2D) -> void:
	# Hanya bereaksi untuk player
	if not _body.is_in_group("player"):
		return
	if manager:
		manager.terima_input(warna_ubin)

func set_lampu(benar: bool) -> void:
	if not lampu:
		return
	# Mendukung ColorRect dan Sprite2D/node lain yang punya modulate
	if lampu is ColorRect:
		lampu.color = WARNA_BENAR if benar else WARNA_SALAH
	else:
		lampu.modulate = WARNA_BENAR if benar else WARNA_SALAH
