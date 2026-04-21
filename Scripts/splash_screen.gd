extends Control

@onready var teks_judul = $LabelJudul
@onready var teks_author = $LabelAuthor

func _ready():
	# 1. Pastikan kedua teks gaib (transparan) saat game baru dibuka
	teks_judul.modulate.a = 0.0
	teks_author.modulate.a = 0.0
	
	# 2. Langsung jalankan fungsi animasinya
	jalankan_animasi()

func jalankan_animasi():
	# Bikin sistem Tween (animasi otomatis dari Godot)
	var tween = get_tree().create_tween()
	
	# === SEQUENCE 1: JUDUL GAME ===
	# Fade In (muncul) selama 1.5 detik
	tween.tween_property(teks_judul, "modulate:a", 1.0, 1.5)
	# Tahan di layar selama 2 detik
	tween.tween_interval(2.0)
	# Fade Out (menghilang) selama 1.5 detik
	tween.tween_property(teks_judul, "modulate:a", 0.0, 1.5)
	
	# Jeda sejenak layar hitam kosong 0.5 detik
	tween.tween_interval(0.5)
	
	# === SEQUENCE 2: MADE BY RUNNRI ===
	# Fade In (muncul) selama 1.5 detik
	tween.tween_property(teks_author, "modulate:a", 1.0, 1.5)
	# Tahan di layar selama 2 detik
	tween.tween_interval(2.0)
	# Fade Out (menghilang) selama 1.5 detik
	tween.tween_property(teks_author, "modulate:a", 0.0, 1.5)
	
	# === SEQUENCE 3: PINDAH KE LOGIN ===
	# Setelah semua rentetan animasi di atas selesai, jalankan fungsi pindah_scene
	tween.tween_callback(pindah_scene)

func pindah_scene():
	# Pastikan path ini sesuai dengan lokasi file auth.tscn kamu!
	get_tree().change_scene_to_file("res://Scenes/auth.tscn")
