extends CharacterBody2D

# ==========================================
# PENGATURAN PATROLI
# ==========================================
@export var speed: float = 80.0
@export var titik_tujuan: Marker2D

@onready var sprite = $AnimatedSprite2D

var titik_awal: Vector2
var target_posisi: Vector2
var arah_sekarang: String = "bawah"
var sedang_menangkap: bool = false

func _ready():
	titik_awal = global_position
	# Jika tidak ada titik tujuan, guard diam di tempat
	target_posisi = titik_tujuan.global_position if titik_tujuan else titik_awal

func _physics_process(_delta):
	if not titik_tujuan or sedang_menangkap:
		return

	var arah = global_position.direction_to(target_posisi)
	velocity = arah * speed
	move_and_slide()
	update_animasi(arah)

	# Ganti target jika sudah sampai (threshold 5 px)
	if global_position.distance_to(target_posisi) < 5.0:
		target_posisi = titik_tujuan.global_position if target_posisi == titik_awal else titik_awal

# ==========================================
# ANIMASI
# ==========================================
func update_animasi(arah_gerak: Vector2):
	if abs(arah_gerak.x) > abs(arah_gerak.y):
		arah_sekarang = "kanan" if arah_gerak.x > 0 else "kiri"
	else:
		arah_sekarang = "bawah" if arah_gerak.y > 0 else "atas"
	sprite.play("guard_" + arah_sekarang)

# ==========================================
# DETEKSI PLAYER (CAUGHT)
# ==========================================
func _on_hitbox_body_entered(body: Node2D):
	# Gunakan group "player" agar tidak tergantung nama node
	if body.is_in_group("player") and not sedang_menangkap:
		
		# Berikan damage ke player terlebih dahulu
		if body.has_method("terima_damage"):
			body.terima_damage(100)

		# Cek tingkat kesulitan dari Global.gd
		if Global.kesulitan_terpilih == "easy":
			# --- MODE EASY ---
			# Guard berhenti total setelah menangkap
			sedang_menangkap = true
			sprite.play("caught_" + arah_sekarang)
		else:
			# --- MODE MEDIUM / HARD ---
			# Guard nge-stun bentar buat animasi, lalu keliling lagi!
			sedang_menangkap = true
			sprite.play("caught_" + arah_sekarang)
			
			# Tunggu 1 detik biar animasinya kelar (bisa Bos ubah durasinya)
			await get_tree().create_timer(1.0).timeout
			
			# Lepas status menangkap biar bisa jalan keliling lagi
			sedang_menangkap = false
