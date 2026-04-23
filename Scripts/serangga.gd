extends Area2D

# ==========================================
# SERANGGA — Patroli silang + kejar player
# ==========================================

@export var speed_patrol: float = 80.0
@export var speed_chase: float = 150.0

# Dua titik pojok untuk jalur silang (diisi dari Inspector atau via kode)
# Jika kosong, diambil dari posisi awal + offset
@export var titik_a: Vector2 = Vector2.ZERO
@export var titik_b: Vector2 = Vector2.ZERO

@onready var sprite = $AnimatedSprite2D

var player_target = null
var mode_ngejar: bool = false
var sudah_mati: bool = false

# Arah patroli: 1 = menuju B, -1 = menuju A
var arah_patrol: int = 1

func _ready():
	add_to_group("serangga")

	# Jika titik tidak di-set dari luar, gunakan posisi awal apa adanya
	if titik_a == Vector2.ZERO and titik_b == Vector2.ZERO:
		titik_a = global_position
		titik_b = global_position + Vector2(400, 0)

	global_position = titik_a
	sprite.play("serangga_kanan")

func _physics_process(delta):
	if sudah_mati:
		return

	if mode_ngejar and player_target and is_instance_valid(player_target):
		_kejar(delta)
	else:
		_patrol(delta)

# ---- PATROL SILANG ----
func _patrol(delta):
	var target = titik_b if arah_patrol == 1 else titik_a
	var arah_vec = (target - global_position)

	if arah_vec.length() < 8.0:
		# Sampai di titik tujuan, balik arah
		arah_patrol *= -1
	else:
		global_position += arah_vec.normalized() * speed_patrol * delta
		_atur_animasi(arah_vec.x)

# ---- KEJAR PLAYER ----
func _kejar(delta):
	var arah_vec = player_target.global_position - global_position
	global_position += arah_vec.normalized() * speed_chase * delta
	_atur_animasi(arah_vec.x)

# ---- ANIMASI ----
func _atur_animasi(arah_x: float):
	if arah_x > 0.5:
		sprite.play("serangga_kanan")
	elif arah_x < -0.5:
		sprite.play("serangga_kiri")

# ---- SINYAL ZONA DETEKSI ----
func _on_zona_deteksi_body_entered(body):
	if body.is_in_group("player") and not sudah_mati:
		player_target = body
		mode_ngejar = true

func _on_zona_deteksi_body_exited(body):
	if body == player_target:
		mode_ngejar = false
		player_target = null

# ---- KONTAK LANGSUNG = PLAYER MATI ----
func _on_body_entered(body):
	if body.is_in_group("player") and not sudah_mati:
		if body.has_method("mati"):
			body.mati()

# ---- DIPANGGIL SAAT CAHAYA MENYALA ----
func matikan():
	if sudah_mati:
		return
	sudah_mati = true
	mode_ngejar = false

	# Efek mati: fade out lalu hilang
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(queue_free)
