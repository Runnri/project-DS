extends CanvasLayer

# ==========================================
# SCENE TEKS ENDING (VERSI DINAMIS)
# Menampilkan judul ending sesuai yang baru saja didapat
# ==========================================

@onready var teks_ending : Label = $TeksEnding
@onready var timer        : Timer = $Timer

func _ready() -> void:
	# 1. Ambil jumlah ending yang terbuka (diambil dari meta yang diset saat catat_ending)
	var jumlah: int = 1
	if Global.has_meta("jumlah_ending_saat_ini"):
		jumlah = Global.get_meta("jumlah_ending_saat_ini")

	# 2. Tentukan Judul Berdasarkan Ending yang Terakhir Dicatat
	var judul_ending = ""
	
	match Global.last_ending_achieved:
		"THE DESKTOP":
			judul_ending = "[THE DESKTOP: FATAL ERROR]"
		"THE RECYCLE BIN":
			judul_ending = "[THE RECYCLE BIN]"
		_:
			# Default jika nama ending tidak terdaftar
			judul_ending = "[" + Global.last_ending_achieved + "]"

	# 3. Update Label Teks
	teks_ending.text = "ENDING UNLOCKED: %d/2\n%s" % [jumlah, judul_ending]

	# Animasi fade-in teks agar lebih elegan
	teks_ending.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(teks_ending, "modulate:a", 1.0, 1.5)

	# Timer 5 detik lalu pindah ke scene credit
	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)
	
	timer.wait_time = 5.0
	timer.one_shot  = true
	timer.start()

func _on_timer_timeout() -> void:
	# Pastikan path scene credit sudah benar sesuai folder Bos
	get_tree().change_scene_to_file("res://Scenes/scene_credit.tscn")
