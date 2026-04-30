extends Node2D

@onready var bit        = $Player
@onready var blue_screen = $CanvasLayer/BlueScreen
@onready var wallpaper  = $Wallpaper

var sudah_crash: bool = false
var posisi_y_tetap: float = 0.0
var cam: Camera2D

# Resolusi project (1908x927) — JANGAN diubah ke 1586x992
const RES_W = 1908
const RES_H = 927

func _ready():
	if Global.has_method("catat_ending_ke_akun"):
		Global.catat_ending_ke_akun("THE DESKTOP")

	# Pastikan window & canvas scale sesuai resolusi project
	get_window().size = Vector2i(RES_W, RES_H)
	get_tree().root.content_scale_size = Vector2i(RES_W, RES_H)
	get_window().move_to_center()

	setup_camera_tetap()

	if wallpaper:
		wallpaper.set_deferred("size", Vector2(RES_W, RES_H))
		wallpaper.set_deferred("position", Vector2(0, 0))

	blue_screen.visible = false

	if bit:
		bit.frozen = false
		posisi_y_tetap = bit.global_position.y
		if bit.has_node("CanvasLayer"):
			bit.get_node("CanvasLayer").visible = false
		if bit.has_node("CanvasLayer/CMD"):
			bit.get_node("CanvasLayer/CMD").process_mode = Node.PROCESS_MODE_DISABLED

	# FADE IN
	var fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 1)
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	$CanvasLayer.add_child(fade_rect)

	var tw_in = create_tween()
	tw_in.tween_property(fade_rect, "color:a", 0.0, 0.8)
	tw_in.tween_callback(func(): fade_rect.queue_free())

	mulai_hitung_mundur_crash()

func setup_camera_tetap():
	cam = Camera2D.new()
	cam.name = "FixedCamera"
	# Tengah resolusi 1908x927
	cam.position = Vector2(RES_W / 2.0, RES_H / 2.0)
	cam.enabled = true
	cam.zoom = Vector2(1, 1)
	add_child(cam)
	cam.make_current()

func mulai_hitung_mundur_crash():
	await get_tree().create_timer(4.5).timeout
	eksekusi_bsod()

func eksekusi_bsod():
	sudah_crash = true
	if bit:
		bit.frozen = true

	blue_screen.visible = true
	await get_tree().create_timer(1.0).timeout

	var fade_out = ColorRect.new()
	fade_out.color = Color(0, 0, 0, 0)
	fade_out.set_anchors_preset(Control.PRESET_FULL_RECT)
	$CanvasLayer.add_child(fade_out)

	var tw_out = create_tween()
	tw_out.tween_property(fade_out, "color:a", 1.0, 6.0)
	await tw_out.finished
	pindah_scene_ending()

func pindah_scene_ending():
	get_window().size = Vector2i(RES_W, RES_H)
	get_window().move_to_center()
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/scene_teks_ending.tscn")

func _physics_process(_delta):
	if bit and not sudah_crash:
		bit.global_position.y = posisi_y_tetap
		# Batas kiri-kanan sesuai lebar 1908
		bit.global_position.x = clamp(bit.global_position.x, 40, RES_W - 40)
		if cam:
			cam.zoom = Vector2(1, 1)
