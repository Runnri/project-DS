extends Control

@onready var layar_gambar = $TextureRect
@onready var timer_auto   = $Timer
@onready var label_skip   = $LabelSkip

var daftar_slide = [
	preload("res://Assets/intro/humanDelete.png"),
	preload("res://Assets/intro/pembersihan.png"),
	preload("res://Assets/intro/humanMinum.png"),
	preload("res://Assets/intro/pembersihan1.png")
]

const DURASI_PER_SLIDE: float = 4.0

var slide_sekarang: int = 0
var bisa_skip: bool = false

func _ready():
	layar_gambar.modulate.a = 0.0
	timer_auto.wait_time = DURASI_PER_SLIDE
	timer_auto.one_shot = true
	timer_auto.timeout.connect(_on_timer_auto_timeout)

	if daftar_slide.size() > 0:
		tampilkan_slide()

func _input(event):
	if bisa_skip and (event.is_action_pressed("ui_accept") or event is InputEventMouseButton and event.pressed):
		timer_auto.stop()
		ke_slide_berikutnya()

func _on_timer_auto_timeout():
	ke_slide_berikutnya()

func ke_slide_berikutnya():
	bisa_skip = false
	slide_sekarang += 1
	if slide_sekarang >= daftar_slide.size():
		pindah_ke_gameplay()
	else:
		tampilkan_slide()

# Sesuaikan stretch_mode berdasarkan aspect ratio gambar vs layar
func _sesuaikan_stretch(tex: Texture2D):
	var img_w = tex.get_width()
	var img_h = tex.get_height()
	var img_ratio = float(img_w) / float(img_h)

	var layar = get_viewport_rect().size
	var layar_ratio = layar.x / layar.y

	# Jika rasio gambar hampir sama dengan layar (toleransi 5%), pakai KEEP_ASPECT_COVERED
	# supaya tidak ada letterbox hitam — gambar memenuhi layar dengan crop minimal.
	# Jika rasio sangat berbeda (mis. 1:1 vs 16:9), pakai KEEP_ASPECT_CENTERED
	# supaya gambar penuh terlihat dengan letterbox hitam di sisi kosong.
	var selisih = abs(img_ratio - layar_ratio) / layar_ratio

	if selisih < 0.05:
		# Rasio hampir sama → penuhi layar tanpa letterbox
		layar_gambar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	else:
		# Rasio beda jauh → tampilkan gambar utuh + letterbox hitam
		layar_gambar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

func tampilkan_slide():
	bisa_skip = false
	var tween = create_tween()

	# 1. FADE OUT gambar lama
	tween.tween_property(layar_gambar, "modulate:a", 0.0, 0.5)

	# 2. Ganti tekstur + sesuaikan stretch mode sebelum fade in
	tween.tween_callback(func():
		var tex = daftar_slide[slide_sekarang]
		layar_gambar.texture = tex
		_sesuaikan_stretch(tex)
	)

	# 3. FADE IN gambar baru
	tween.tween_property(layar_gambar, "modulate:a", 1.0, 0.5)

	# 4. Aktifkan skip & mulai timer
	tween.tween_callback(func():
		bisa_skip = true
		timer_auto.start()
	)

func pindah_ke_gameplay():
	var path_level = "res://Scenes/level_easy.tscn"

	match Global.kesulitan_terpilih:
		"easy":   path_level = "res://Scenes/level_easy.tscn"
		"medium": path_level = "res://Scenes/level_medium.tscn"
		"hard":   path_level = "res://Scenes/level_hard.tscn"

	var tween = create_tween()
	tween.tween_property(layar_gambar, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		var err = get_tree().change_scene_to_file(path_level)
		if err != OK:
			push_error("[CutScene]: Gagal load scene: " + path_level)
	)
