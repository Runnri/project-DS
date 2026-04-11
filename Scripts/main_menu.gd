extends Control

# ==========================================
# 1. PERSIAPAN NODE & VARIABEL
# ==========================================
@onready var vbox = $VBoxContainer
@onready var judul_game = $Judul # Pastikan nama Node judul kamu adalah "Judul"

# Variabel untuk animasi naik-turun tombol
var time: float = 0.0
var base_vbox_y: float = 0.0

# Variabel untuk efek glitch judul
var base_judul_pos: Vector2 = Vector2.ZERO # Untuk menyimpan posisi asli judul
var timer_tunggu: float = 0.0
var is_glitching: bool = false
var durasi_glitch: float = 0.0

# ==========================================
# 2. FUNGSI SAAT MENU PERTAMA KALI DIBUKA
# ==========================================
func _ready():
	# Simpan posisi awal tombol & judul biar saat selesai glitch kembalinya rapi
	base_vbox_y = vbox.position.y
	base_judul_pos = judul_game.position
	
	# Mulai hitung mundur untuk nunggu glitch pertama
	timer_tunggu = randf_range(2.0, 5.0)

# ==========================================
# 3. FUNGSI YANG BERJALAN TERUS-MENERUS
# ==========================================
func _process(delta):
	# --- ANIMASI TOMBOL NAIK-TURUN ---
	time += delta * 1.0 # Kecepatan mengambang
	vbox.position.y = base_vbox_y + (sin(time) * 10.0) # Jarak mengambang
	
	# --- SISTEM GLITCH JUDUL ---
	if not is_glitching:
		# MODE NORMAL: Hitung mundur sampai waktu glitch tiba
		timer_tunggu -= delta
		if timer_tunggu <= 0:
			mulai_glitch()
	else:
		# MODE GLITCH: Sedang rusak/bergetar
		durasi_glitch -= delta
		
		# Bikin getar (acak posisi X dan Y dengan cepat setiap frame)
		judul_game.position.x = base_judul_pos.x + randf_range(-8.0, 8.0)
		judul_game.position.y = base_judul_pos.y + randf_range(-3.0, 3.0)
		
		# Kadang nyala kadang mati secara acak (flicker)
		judul_game.visible = randf() > 0.4
		
		# Kalau waktu glitch habis, kembalikan ke normal
		if durasi_glitch <= 0:
			stop_glitch()

# ==========================================
# 4. PENGATURAN MODE GLITCH
# ==========================================
func mulai_glitch():
	is_glitching = true
	# Glitch terjadi sangat cepat (0.1 sampai 0.3 detik saja)
	durasi_glitch = randf_range(0.1, 0.3) 

func stop_glitch():
	is_glitching = false
	judul_game.visible = true # Pastikan nyala lagi
	judul_game.position = base_judul_pos # Kembalikan tepat ke posisi aslinya
	timer_tunggu = randf_range(2.0, 6.0) # Tunggu 2-6 detik sampai rusak lagi

# ==========================================
# 5. FUNGSI KLIK TOMBOL
# ==========================================
func _on_start_button_pressed():
	# Sesuai rencana alur, tombol Start pindah ke Difficulty Menu dulu
	get_tree().change_scene_to_file("res://Scenes/difficulty.tscn")

func _on_load_button_pressed():
	print("Sistem Load sedang diproses...")

func _on_quit_button_pressed():
	get_tree().quit()


func _on_start_pressed() -> void:
	pass # Replace with function body.
