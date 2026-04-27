extends CharacterBody2D

enum State { PATROL, CHASE }

@onready var agent = $NavigationAgent2D
@onready var ray = $RayCast2D
@onready var sprite = $AnimatedSprite2D
@onready var hitbox = $hitbox

var state = State.PATROL
var speed = 100.0

# titik patrol kamu
var patrol_points = [
	Vector2(-5926,15183),
	Vector2(-5934,16386),
	Vector2(-1488,16386),
	Vector2(-1496,15178)
]

var current_point = 0
var player = null

var waktu_ingatan: float = 0.0
var posisi_terakhir: Vector2 = Vector2.ZERO

# ======================
func _ready():
	hitbox.body_entered.connect(_on_hit)

# ======================
func _physics_process(delta):

	match state:
		State.PATROL:
			_patrol()
		State.CHASE:
			_chase(delta) # <--- Tambahkan delta di dalam kurung ini

	move_and_slide()
	_update_anim()

# ======================
# PATROL
# ======================
func _patrol():
	var target = patrol_points[current_point]

	agent.target_position = target
	var next = agent.get_next_path_position()

	var dir = (next - global_position).normalized()
	velocity = dir * speed

	# arahkan mata ke depan
	ray.target_position = dir * 150

	# kalau sampai titik → lanjut
	if global_position.distance_to(target) < 20:
		current_point = (current_point + 1) % patrol_points.size()

	# cek player
	if ray.is_colliding():
		var obj = ray.get_collider()
		if obj and obj.is_in_group("player"):
			player = obj
			state = State.CHASE

# ======================
# CHASE (PATHFINDING DENGAN MEMORI)
# ======================
# ======================
# CHASE (PATHFINDING DENGAN MEMORI & LOCK-ON)
# ======================
func _chase(delta):
	if player == null and waktu_ingatan <= 0:
		state = State.PATROL
		return

	# 1. KUNCI MATA KE PLAYER (Lock-On Target)
	# Biar panahnya lurus nembak ke posisi Bit secara akurat!
	if player and is_instance_valid(player):
		ray.target_position = to_local(player.global_position)
		ray.force_raycast_update() # Paksa baca detik itu juga

	# 2. Cek Line of Sight (Apakah terhalang tembok?)
	var sedang_lihat_player = false
	if ray.is_colliding():
		var obj = ray.get_collider()
		if obj and obj.is_in_group("player"):
			sedang_lihat_player = true

	# 3. Logika Ingatan Navigasi
	if sedang_lihat_player:
		# Kelihatan jelas: Update memori
		posisi_terakhir = player.global_position
		waktu_ingatan = 8.0 
		agent.target_position = player.global_position
	else:
		# Kehalang tembok: Pakai memori
		waktu_ingatan -= delta
		agent.target_position = posisi_terakhir 
		
		# NYERAH: Waktu habis atau sudah sampai di titik memori
		if waktu_ingatan <= 0 or global_position.distance_to(posisi_terakhir) < 20:
			player = null
			state = State.PATROL
			return 

	# 4. Bergerak Mengikuti Jalur Hijau
	var next = agent.get_next_path_position()
	var dir = (next - global_position).normalized()
	velocity = dir * (speed * 2.2)

	# 5. Kalau sedang NYARI (nggak lihat Bit), baru matanya diarahkan ke jalan depan
	if not sedang_lihat_player:
		ray.target_position = dir * 150
# ======================
# HIT PLAYER (AREA)
# ======================
func _on_hit(body):
	if body.is_in_group("player"):
		if body.has_method("mati"):
			body.mati()
		elif body.has_method("take_damage"):
			body.take_damage(1)

# ======================
# ANIMASI
# ======================
func _update_anim():
	

	if abs(velocity.x) > abs(velocity.y):
		if velocity.x > 0:
			sprite.play("robot_kanan")
		else:
			sprite.play("robot_kiri")
	else:
		if velocity.y > 0:
			sprite.play("robot_bawah")
		else:
			sprite.play("robot_atas")
