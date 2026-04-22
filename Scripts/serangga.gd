extends Area2D

@export var speed_patrol: float = 50.0
@export var speed_chase: float = 120.0

@onready var sprite = $AnimatedSprite2D
@onready var path_follower = get_parent() # Merujuk ke PathFollow2D

var player_target = null
var mode_ngejar = false
var posisi_terakhir: Vector2

func _ready():
	add_to_group("serangga")
	posisi_terakhir = global_position

func _physics_process(delta):
	if mode_ngejar and player_target:
		# MODE PENGEJARAN
		var arah = (player_target.global_position - global_position).normalized()
		global_position += arah * speed_chase * delta
		_atur_animasi(arah.x)
	else:
		# MODE PATROLI (Ikut Path2D)
		path_follower.progress += speed_patrol * delta
		
		# Hitung arah gerak berdasarkan perubahan posisi untuk animasi
		var arah_jalan = global_position.x - posisi_terakhir.x
		_atur_animasi(arah_jalan)
		posisi_terakhir = global_position

func _atur_animasi(arah_x: float):
	if arah_x > 0:
		sprite.play("serangga_kanan")
	elif arah_x < 0:
		sprite.play("serangga_kiri")

# --- SINYAL ---

# Hubungkan sinyal body_entered dari ZonaDeteksi ke sini
func _on_zona_deteksi_body_entered(body):
	if body.is_in_group("player"):
		player_target = body
		mode_ngejar = true

# Hubungkan sinyal body_exited dari ZonaDeteksi ke sini (Opsional: biar dia balik patroli)
func _on_zona_deteksi_body_exited(body):
	if body == player_target:
		mode_ngejar = false

# Hubungkan sinyal body_entered dari Serangga (utama) ke sini
func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("mati"):
			body.mati()
