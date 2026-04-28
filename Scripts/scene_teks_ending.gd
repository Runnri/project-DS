extends CanvasLayer

# ==========================================
# SCENE TEKS ENDING
# Menampilkan "ENDING UNLOCKED: X/2 \n [THE RECYCLE BIN]"
# lalu pindah ke scene_credit.tscn setelah 5 detik
# ==========================================

@onready var teks_ending : Label = $TeksEnding
@onready var timer        : Timer = $Timer

func _ready() -> void:
	# Ambil jumlah ending yang disimpan oleh ending_bin.gd via Global meta
	var jumlah: int = 1
	if Global.has_meta("jumlah_ending_saat_ini"):
		jumlah = Global.get_meta("jumlah_ending_saat_ini")

	# Tampilkan teks ending
	teks_ending.text = "ENDING UNLOCKED: %d/2\n[THE RECYCLE BIN]" % jumlah

	# Animasi fade-in teks (opsional tapi lebih elegan)
	teks_ending.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(teks_ending, "modulate:a", 1.0, 1.5)

	# Timer 5 detik lalu pindah ke credit
	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)
	timer.wait_time = 5.0
	timer.one_shot  = true
	timer.start()

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://Scenes/scene_credit.tscn")
