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

# ======================
func _ready():
	hitbox.body_entered.connect(_on_hit)

# ======================
func _physics_process(delta):

	match state:
		State.PATROL:
			_patrol()
		State.CHASE:
			_chase()

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
# CHASE (PATHFINDING)
# ======================
func _chase():
	if player == null:
		state = State.PATROL
		return

	agent.target_position = player.global_position
	var next = agent.get_next_path_position()

	var dir = (next - global_position).normalized()
	velocity = dir * (speed * 1.3)

	# arahkan mata
	ray.target_position = dir * 150

	# kalau kena player
	if global_position.distance_to(player.global_position) < 20:
		player.queue_free()

	# kalau sudah tidak lihat
	if not ray.is_colliding():
		player = null
		state = State.PATROL

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
