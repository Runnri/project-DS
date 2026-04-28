extends Node2D

@onready var bit_jatuh : RigidBody2D  = $Bit_Jatuh
@onready var lantai    : StaticBody2D = $LantaiSampah
@onready var timer     : Timer        = $Timer

var jumlah_ending: int = 0

const LEBAR_GUNUNG  : float = 1000.0
const TINGGI_GUNUNG : float = 280.0

func _ready() -> void:
	# Hard-coded untuk resolusi 1908x927
	var cx : float = 954.0
	var cy : float = 741.0   # 927 * 0.8

	$TumpukanMayat.position = Vector2(cx, cy)
	$Bit_Jatuh.position     = Vector2(cx, cy - TINGGI_GUNUNG - 150.0)
	$LantaiSampah.position  = Vector2(0, 0)

	_buat_collision_gunung(cx, cy)

	jumlah_ending = Global.catat_ending_ke_akun("bin")
	Global.set_meta("jumlah_ending_saat_ini", jumlah_ending)

	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)
	timer.wait_time = 5.0
	timer.one_shot  = true
	timer.start()

func _buat_collision_gunung(cx: float, cy: float) -> void:
	for child in lantai.get_children():
		child.queue_free()

	var points : PackedVector2Array = PackedVector2Array()
	var steps  : int = 80

	for i in range(steps + 1):
		var t  = float(i) / float(steps)
		var x  = (t - 0.5) * LEBAR_GUNUNG
		var nx = abs(x) / (LEBAR_GUNUNG * 0.5)
		var y  = -TINGGI_GUNUNG * cos(nx * PI * 0.5)
		points.append(Vector2(cx + x, cy + y))

	points.append(Vector2(cx + LEBAR_GUNUNG * 0.5 + 50, cy + 300.0))
	points.append(Vector2(cx - LEBAR_GUNUNG * 0.5 - 50, cy + 300.0))

	var col = CollisionPolygon2D.new()
	col.polygon = points
	lantai.add_child(col)

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/scene_teks_ending.tscn")
