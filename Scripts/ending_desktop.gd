extends Node2D

@onready var bit = $Player
@onready var blue_screen = $CanvasLayer/BlueScreen
@onready var wallpaper = $Wallpaper

var sudah_crash: bool = false
var posisi_y_tetap: float = 0.0 
var cam: Camera2D # Variabel untuk mengontrol kamera tetap

func _ready():
	if Global.has_method("catat_ending_ke_akun"):
		Global.catat_ending_ke_akun("THE DESKTOP")
	
	
	get_window().size = Vector2i(1586, 992)
	get_tree().root.content_scale_size = Vector2i(1586, 992) 
	get_window().move_to_center()
	# ==================================
	
	setup_camera_tetap()
	
	if wallpaper:
		wallpaper.size = Vector2(1586, 992)
		wallpaper.position = Vector2(0, 0)
	
	blue_screen.visible = false
	
	if bit:
		bit.frozen = false
		
		# Kunci posisi Y awal agar si Bit nempel di taskbar/lantai
		posisi_y_tetap = bit.global_position.y
		
		# MATIKAN UI PLAYER (Darah, Stamina, CMD)
		if bit.has_node("CanvasLayer"):
			bit.get_node("CanvasLayer").visible = false 
		if bit.has_node("CanvasLayer/CMD"):
			bit.get_node("CanvasLayer/CMD").process_mode = Node.PROCESS_MODE_DISABLED

	# FADE IN (0.8 Detik)
	var fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 1)
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	$CanvasLayer.add_child(fade_rect)
	
	var tw_in = create_tween()
	tw_in.tween_property(fade_rect, "color:a", 0.0, 0.8)
	tw_in.tween_callback(func(): fade_rect.queue_free())

	mulai_hitung_mundur_crash()

func setup_camera_tetap():
	# Kita buat kamera baru lewat kode biar gak bentrok sama kamera Player
	cam = Camera2D.new()
	cam.name = "FixedCamera"
	# Taruh kamera tepat di tengah wallpaper (1586 / 2 dan 992 / 2)
	cam.position = Vector2(793, 496)
	cam.enabled = true
	cam.zoom = Vector2(1, 1) # Kunci zoom agar tidak besar/kecil
	add_child(cam)
	cam.make_current() # Paksa Godot pakai kamera ini, bukan kamera si Bit

func mulai_hitung_mundur_crash():
	await get_tree().create_timer(4.5).timeout
	eksekusi_bsod()

func eksekusi_bsod():
	sudah_crash = true
	if bit:
		bit.frozen = true 
	
	blue_screen.visible = true
	
	await get_tree().create_timer(1.0).timeout
	
	# FADE OUT 6 DETIK (Menuju kegelapan)
	var fade_out = ColorRect.new()
	fade_out.color = Color(0, 0, 0, 0)
	fade_out.set_anchors_preset(Control.PRESET_FULL_RECT)
	$CanvasLayer.add_child(fade_out)
	
	var tw_out = create_tween()
	tw_out.tween_property(fade_out, "color:a", 1.0, 6.0) 
	
	await tw_out.finished
	pindah_scene_ending()

func pindah_scene_ending():
	# Balikin resolusi normal sebelum pindah scene
	get_window().size = Vector2i(1908, 927)
	get_window().move_to_center()
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/scene_teks_ending.tscn")

func _physics_process(_delta):
	if bit and not sudah_crash:
		# 1. KUNCI POSISI Y (Mutlak gak bisa lompat/turun)
		bit.global_position.y = posisi_y_tetap
		
		# 2. ANTI TEMBUS (Bit mentok di ujung kiri/kanan gambar 1586px)
		bit.global_position.x = clamp(bit.global_position.x, 40, 1546)
		
		# 3. ANTI ZOOM (Tiap frame dipaksa balik ke zoom 1:1)
		if cam:
			cam.zoom = Vector2(1, 1)
