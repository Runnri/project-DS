extends Area2D

@export var speed_patrol: float = 100.0
@export var speed_chase: float = 180.0

@onready var sprite = $AnimatedSprite2D
@onready var path_follower = get_parent() # Ini buat akses PathFollow2D

var player_target = null
var mode_ngejar: bool = false
var posisi_awal_lokal: Vector2

func _ready():
	add_to_group("serangga")
	posisi_awal_lokal = position # Simpan posisi awal relatif ke Follower

func _physics_process(delta):
	if mode_ngejar and player_target and is_instance_valid(player_target):
		# --- MODE NGEJAR ---
		var arah = (player_target.global_position - global_position).normalized()
		global_position += arah * speed_chase * delta
		_atur_animasi(arah.x)
	else:
		# --- MODE PATROLI (Kaya Keliling-keliling) ---
		# Kembali ke posisi "gerbong" pelan-pelan kalau abis ngejar
		position = position.move_toward(posisi_awal_lokal, speed_patrol * delta)
		
		# Jalankan gerbong keretanya di atas garis
		if path_follower is PathFollow2D:
			path_follower.progress += speed_patrol * delta
			
			# Animasi patroli berdasarkan progress
			var arah_x = 1.0 # Anggap default kanan
			# (Logika animasi otomatis ngikutin path biasanya lewat rotasi, 
			# tapi di sini kita paksa arah x saja)
			_atur_animasi(arah_x)

func _atur_animasi(arah_x: float):
	if arah_x > 0:
		sprite.play("serangga_kanan")
	else:
		sprite.play("serangga_kiri")

# --- KONEKSI SINYAL (Pastikan sudah di-klik di editor!) ---

func _on_zona_deteksi_body_entered(body):
	if body.is_in_group("player"):
		player_target = body
		mode_ngejar = true

func _on_zona_deteksi_body_exited(body):
	if body == player_target:
		mode_ngejar = false

# INI BUAT BUNUH PLAYER (Sinyal dari Area2D Serangga yg atas)
func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("mati"):
			body.mati()
		elif body.has_method("take_damage"): # Cek kalo namanya take_damage
			body.take_damage(1)
