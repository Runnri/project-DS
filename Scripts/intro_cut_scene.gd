extends Control

@onready var layar_gambar = $TextureRect
@onready var label_skip   = $LabelSkip
@onready var label_teks   = $LabelTeks


var daftar_slide = [
	{
		"teks": "Tahun 2026... Protokol pembersihan sistem akan segera dimulai.",
		"gambar": preload("res://Assets/intro/humanDelete.png")
	},
	{
		"teks": "Satu per satu data usang dihapus tanpa ampun.",
		"gambar": preload("res://Assets/intro/pembersihan.png")
	},
	{
		"teks": "Di balik rutinitas sang Pengguna, ancaman datang secara diam-diam...",
		"gambar": preload("res://Assets/intro/humanMinum.png")
	},
	{
		"teks": "Bagi data-data yang terlupakan, ini adalah akhir dari segalanya.",
		"gambar": preload("res://Assets/intro/pembersihan1.png")
	}
]

const KECEPATAN_NGETIK: float = 0.1 
const DURASI_GAMBAR: float = 3.0     

var slide_sekarang: int = 0
var fase: String = "ngetik"          
var tween_aktif: Tween

func _ready():
	layar_gambar.modulate.a = 0.0
	label_teks.modulate.a = 1.0
	label_teks.text = ""
	label_teks.visible_characters = 0

	if has_node("Timer"):
		$Timer.queue_free()

	if daftar_slide.size() > 0:
		mulai_ngetik()

func _input(event):
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		if fase == "ngetik":
			if tween_aktif: tween_aktif.kill()
			label_teks.visible_characters = -1
			munculkan_gambar()
		elif fase == "gambar_tampil":
			if tween_aktif: tween_aktif.kill()
			lanjut_slide()

func mulai_ngetik():
	fase = "ngetik"
	layar_gambar.modulate.a = 0.0
	
	var data = daftar_slide[slide_sekarang]
	label_teks.text = data["teks"]
	label_teks.visible_characters = 0
	
	var durasi_ngetik = data["teks"].length() * KECEPATAN_NGETIK

	tween_aktif = create_tween()
	tween_aktif.tween_property(label_teks, "visible_characters", data["teks"].length(), durasi_ngetik)
	tween_aktif.tween_callback(munculkan_gambar)

func munculkan_gambar():
	fase = "gambar_tampil"
	label_teks.visible_characters = -1 

	var data = daftar_slide[slide_sekarang]
	layar_gambar.texture = data["gambar"]
	_sesuaikan_stretch(data["gambar"])

	tween_aktif = create_tween()
	tween_aktif.tween_property(layar_gambar, "modulate:a", 1.0, 1.0)
	tween_aktif.tween_interval(DURASI_GAMBAR)
	tween_aktif.tween_property(layar_gambar, "modulate:a", 0.0, 0.5)
	tween_aktif.parallel().tween_property(label_teks, "modulate:a", 0.0, 0.5)
	tween_aktif.tween_callback(lanjut_slide)

func lanjut_slide():
	slide_sekarang += 1
	if slide_sekarang >= daftar_slide.size():
		pindah_ke_gameplay()
	else:
		label_teks.modulate.a = 1.0
		mulai_ngetik()

# ==========================================================
# INI DUA FUNGSI YANG TADI IKUT KEHAPUS
# ==========================================================

func _sesuaikan_stretch(tex):
	var img_ratio = tex.get_width() / float(tex.get_height())
	var layar_ratio = 1908.0 / 927.0 
	var selisih = abs(img_ratio - layar_ratio) / layar_ratio

	if selisih < 0.05:
		layar_gambar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	else:
		layar_gambar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

func pindah_ke_gameplay():
	var path_level = ""
	
	# Cek tingkat kesulitan dari Global, lalu arahkan ke file yang sesuai
	match Global.kesulitan_terpilih:
		"easy":
			path_level = "res://Scenes/level_easy.tscn"
		"medium":
			path_level = "res://Scenes/level_medium.tscn"
		"hard":
			path_level = "res://Scenes/level_hard.tscn"
		_:
			# Default (buat jaga-jaga kalau ada error/kosong)
			path_level = "res://Scenes/level_easy.tscn"
			
	get_tree().change_scene_to_file(path_level)
