extends Node2D

# Berapa detik setelah scene muncul sebelum Bit_Jatuh dilepas
const DELAY_JATUH: float = 2.5

@onready var bit_jatuh     = $Bit_Jatuh
@onready var timer         = $Timer
@onready var overlay       = $FadeOverlay/ColorRect

func _ready():
	BgmManager.fade_to("ending")
	# Catat ending ke akun
	var jumlah = Global.catat_ending_ke_akun("THE RECYCLE BIN")
	Global.set_meta("jumlah_ending_saat_ini", jumlah)

	# Bit_Jatuh dibekukan dulu — gravity off sementara
	bit_jatuh.freeze = true

	# Fade IN dari hitam ke transparan
	overlay.color = Color(0, 0, 0, 1)
	var tw = create_tween()
	tw.tween_property(overlay, "color", Color(0, 0, 0, 0), 0.8)

	# Setelah fade in selesai + delay, baru lepas Bit_Jatuh
	tw.tween_interval(DELAY_JATUH)
	tw.tween_callback(func():
		bit_jatuh.freeze = false
	)

	# Timer untuk pindah ke scene berikutnya (diset dari Inspector, misal 5 detik)
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout():
	# Fade out lalu ke scene_teks_ending
	var tw = create_tween()
	tw.tween_property(overlay, "color", Color(0, 0, 0, 1), 0.6)
	tw.tween_interval(0.2)
	tw.tween_callback(func():
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/scene_teks_ending.tscn")
	)
