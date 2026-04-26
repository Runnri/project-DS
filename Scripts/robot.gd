extends CharacterBody2D

# ============================================================
# ROBOT AI - V3 (Sistem Anti-Getar & Komitmen Belok)
# ============================================================

@export var speed_patrol: float = 60.0
@export var speed_chase: float  = 130.0
@export var waypoints: Array[Vector2] = []

@onready var sprite       = $AnimatedSprite2D
@onready var timer_wander = $TimerWander
@onready var mata_laser   = $MataLaser
@onready var cahaya       = $CahayaSorot # (Nggak akan error walau nodenya belum kamu buat)
@onready var zona_deteksi = $ZonaDeteksi
@onready var sensor_kiri  = $SensorKiri
@onready var sensor_kanan = $SensorKanan

enum State { PATROL, CHASE, INVESTIGATE }
var state: State = State.PATROL

var wp_index: int = 0
var arah_wander: Vector2 = Vector2.RIGHT

var player_target = null
var waktu_ingatan: float = 0.0
var posisi_terakhir_player: Vector2 = Vector2.ZERO

# --- VARIABEL BARU BUAT ANTI GETAR (JITTER) ---
var waktu_menghindar: float = 0.0
var arah_menghindar: Vector2 = Vector2.ZERO

var base_energy: float = 1.0
var alert_energy: float = 2.5

func _ready():
	add_to_group("musuh")
	mata_laser.add_exception(self)
	sensor_kiri.add_exception(self)
	sensor_kanan.add_exception(self)

	if waypoints.is_empty():
		pilih_arah_acak()
		timer_wander.start(randf_range(2.0, 4.0))
	else:
		wp_index = 0

	timer_wander.timeout.connect(_on_timer_wander_timeout)
	if cahaya:
		cahaya.energy = base_energy

func _physics_process(delta):
	match state:
		State.PATROL:
			_do_patrol(delta)
		State.CHASE:
			_do_chase(delta)
		State.INVESTIGATE:
			_do_investigate(delta)
	
	move_and_slide()
	_update_cahaya(delta)

func _do_patrol(delta):
	if waypoints.is_empty():
		var dir_aman = _hindari_rintangan(arah_wander, delta)
		velocity = dir_aman * speed_patrol
		_atur_animasi(dir_aman)
		if is_on_wall():
			pilih_arah_acak()
		return

	var target_wp = waypoints[wp_index]
	var arah = (target_wp - global_position)
	if arah.length() < 12.0:
		wp_index = (wp_index + 1) % waypoints.size()
		return

	var dir = arah.normalized()
	var dir_aman = _hindari_rintangan(dir, delta)
	velocity = dir_aman * speed_patrol
	_atur_animasi(dir_aman)

func _do_chase(delta):
	if not player_target or not is_instance_valid(player_target):
		state = State.PATROL
		return

	mata_laser.target_position = to_local(player_target.global_position)
	mata_laser.force_raycast_update()

	var kehalang = false
	if mata_laser.is_colliding():
		var hit = mata_laser.get_collider()
		if not hit.is_in_group("player"):
			kehalang = true

	if not kehalang:
		posisi_terakhir_player = player_target.global_position
		waktu_ingatan = 3.0
		var dir = (player_target.global_position - global_position).normalized()
		var dir_aman = _hindari_rintangan(dir, delta)
		velocity = dir_aman * speed_chase
		_atur_animasi(dir_aman)
	else:
		if waktu_ingatan > 0:
			waktu_ingatan -= delta
			var dir = (posisi_terakhir_player - global_position).normalized()
			var dir_aman = _hindari_rintangan(dir, delta)
			velocity = dir_aman * speed_chase
			_atur_animasi(dir_aman)
			
			if global_position.distance_to(posisi_terakhir_player) < 10.0 or is_on_wall():
				waktu_ingatan = 0.0
		else:
			state = State.INVESTIGATE

func _do_investigate(delta):
	var dir = (posisi_terakhir_player - global_position).normalized()
	var dir_aman = _hindari_rintangan(dir, delta)
	velocity = dir_aman * speed_patrol
	_atur_animasi(dir_aman)

	if global_position.distance_to(posisi_terakhir_player) < 16.0 or is_on_wall():
		state = State.PATROL
		if not waypoints.is_empty():
			_cari_waypoint_terdekat()

func _update_cahaya(_delta):
	if not cahaya: return
	match state:
		State.PATROL:
			cahaya.color = Color(1.0, 0.85, 0.3, 1.0)
			cahaya.energy = base_energy
		State.CHASE:
			cahaya.color = Color(1.0, 0.2, 0.1, 1.0)
			cahaya.energy = lerp(cahaya.energy, alert_energy + sin(Time.get_ticks_msec() * 0.02) * 0.4, 0.15)
		State.INVESTIGATE:
			cahaya.color = Color(1.0, 0.6, 0.1, 1.0)
			cahaya.energy = lerp(cahaya.energy, 1.5, 0.1)

# ============================================================
# SISTEM ANTI NYANGKUT V3 (DENGAN KOMITMEN/MEMORI BELOK)
# ============================================================
func _hindari_rintangan(arah_awal: Vector2, delta: float) -> Vector2:
	# 1. Kalau lagi komitmen belok, TERUSIN JALAN! Jangan ngecek kumis dulu.
	if waktu_menghindar > 0:
		waktu_menghindar -= delta
		return arah_menghindar

	var panjang_kumis = 45.0
	sensor_kiri.target_position = arah_awal.rotated(deg_to_rad(-35)) * panjang_kumis
	sensor_kanan.target_position = arah_awal.rotated(deg_to_rad(35)) * panjang_kumis

	sensor_kiri.force_raycast_update()
	sensor_kanan.force_raycast_update()

	var kiri_nabrak = sensor_kiri.is_colliding() and not sensor_kiri.get_collider().is_in_group("player")
	var kanan_nabrak = sensor_kanan.is_colliding() and not sensor_kanan.get_collider().is_in_group("player")

	var arah_baru = arah_awal

	if kiri_nabrak and kanan_nabrak:
		arah_baru = arah_awal.rotated(deg_to_rad(90))
		_mulai_menghindar(arah_baru)
	elif kiri_nabrak:
		arah_baru = arah_awal.rotated(deg_to_rad(60))
		_mulai_menghindar(arah_baru)
	elif kanan_nabrak:
		arah_baru = arah_awal.rotated(deg_to_rad(-60))
		_mulai_menghindar(arah_baru)

	return arah_baru.normalized()

func _mulai_menghindar(arah: Vector2):
	arah_menghindar = arah.normalized()
	# Robot dipaksa jalan melengos ke arah aman selama 0.3 detik
	# Biar dia benar-benar lepas dari pojokan tembok (hilang getar-getarnya)
	waktu_menghindar = 0.3

# ============================================================
# HELPERS & SINYAL 
# ============================================================
func pilih_arah_acak():
	arah_wander = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	timer_wander.start(randf_range(2.0, 4.0))

func _cari_waypoint_terdekat():
	var dist_min = INF
	for i in range(waypoints.size()):
		var d = global_position.distance_to(waypoints[i])
		if d < dist_min:
			dist_min = d
			wp_index = i

func _on_timer_wander_timeout():
	if state == State.PATROL and waypoints.is_empty():
		pilih_arah_acak()

func _atur_animasi(arah: Vector2):
	if abs(arah.x) >= abs(arah.y):
		if arah.x > 0:
			sprite.play("robot_kanan"); sprite.flip_h = false
		else:
			sprite.play("robot_kanan"); sprite.flip_h = true
	else:
		if arah.y > 0:
			sprite.play("robot_bawah")
		else:
			sprite.play("robot_atas")

func _on_zona_deteksi_body_entered(body):
	if body.is_in_group("player"):
		player_target = body
		state = State.CHASE

func _on_zona_deteksi_body_exited(body):
	if body == player_target:
		state = State.INVESTIGATE
		waktu_ingatan = 2.0

func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("mati"):
			body.mati()
