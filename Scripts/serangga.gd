extends Area2D

@export var speed_patrol: float = 100.0
@export var speed_chase: float = 180.0

@onready var sprite = $AnimatedSprite2D
@onready var path_follower = get_parent()

var player_target = null
var mode_ngejar: bool = false
var posisi_awal_lokal: Vector2
var sudah_mati: bool = false

func _ready():
	add_to_group("serangga")
	posisi_awal_lokal = position

func _physics_process(delta):
	if sudah_mati:
		return

	if mode_ngejar and player_target and is_instance_valid(player_target):
		var arah = (player_target.global_position - global_position).normalized()
		global_position += arah * speed_chase * delta
		_atur_animasi(arah.x)
	else:
		position = position.move_toward(posisi_awal_lokal, speed_patrol * delta)
		if path_follower is PathFollow2D:
			path_follower.progress += speed_patrol * delta
			_atur_animasi(1.0)

func _atur_animasi(arah_x: float):
	if arah_x > 0:
		sprite.play("serangga_kanan")
	else:
		sprite.play("serangga_kiri")

func _on_zona_deteksi_body_entered(body):
	if body.is_in_group("player"):
		player_target = body
		mode_ngejar = true

func _on_zona_deteksi_body_exited(body):
	if body == player_target:
		mode_ngejar = false

func _on_body_entered(body):
	if sudah_mati:
		return
	if body.is_in_group("player"):
		if body.has_method("mati"):
			body.mati()
		elif body.has_method("take_damage"):
			body.take_damage(1)

# ── Dipanggil saat pintu terbuka → fade out lalu hilang ──────
func matikan():
	if sudah_mati:
		return
	sudah_mati   = true
	mode_ngejar  = false
	player_target = null

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
