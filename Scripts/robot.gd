extends CharacterBody2D

enum State { PATROL, CHASE }

@onready var agent = $NavigationAgent2D
@onready var ray = $RayCast2D
@onready var sprite = $AnimatedSprite2D

var state = State.PATROL
var speed = 100

var patrol_points = [
	Vector2(-5926,15183),
	Vector2(-5934,16386),
	Vector2(-1488,16386),
	Vector2(-1496,15178)
]

var current_point = 0
var player = null

# ======================
func _physics_process(delta):

	match state:
		State.PATROL:
			_patrol()
		State.CHASE:
			_chase()

	move_and_slide()
	_update_animasi()

# ======================
# PATROL
# ======================
func _patrol():
	var target = patrol_points[current_point]
	agent.target_position = target

	var next = agent.get_next_path_position()
	var dir = (next - global_position).normalized()

	velocity = dir * speed

	# rotate mata ke arah jalan
	ray.target_position = dir * 150

	# kalau sampai titik
	if global_position.distance_to(target) < 20:
		current_point = (current_point + 1) % patrol_points.size()

	# cek lihat player
	if ray.is_colliding():
		var obj = ray.get_collider()
		if obj.is_in_group("player"):
			player = obj
			state = State.CHASE

# ======================
# CHASE (PATHFINDING)
# ======================
func _chase():
	if player == null:
		state = State.PATROL
		return

	# 🔥 update target ke player
	agent.target_position = player.global_position

	# 🔥 ambil titik path berikutnya
	var next_pos = agent.get_next_path_position()

	var direction = (next_pos - global_position).normalized()

	velocity = direction * speed * 1.4

	# arahkan mata ke arah gerak
	ray.target_position = direction * 150

	# ❗ kalau sudah dekat banget → anggap kena
	if global_position.distance_to(player.global_position) < 20:
		player.queue_free() # atau damage

	# ❗ kalau kehilangan line of sight
	if not ray.is_colliding():
		player = null
		state = State.PATROL

	agent.target_position = player.global_position

	var next = agent.get_next_path_position()
	var dir = (next - global_position).normalized()

	velocity = dir * (speed * 1.3)

	# update mata
	ray.target_position = dir * 150

	# kalau kehilangan (tidak terlihat lagi)
	if not ray.is_colliding():
		state = State.PATROL
		player = null

# ======================
# ANIMASI
# ======================
func _update_animasi():


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
