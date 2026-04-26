extends CanvasLayer

@onready var layar_gelap = $ColorRect
@onready var teks_tutor = $Label
@onready var spotlight = $Spotlight

var tutorial_aktif = ""
var bisa_diskip = false # <--- TAMBAHAN: Gembok biar gak langsung ke-skip

func _ready():
	# Memaksa TutorialUI tetap hidup meskipun game sedang Pause!
	self.process_mode = Node.PROCESS_MODE_ALWAYS 
	hide()

func munculkan_tutorial(jenis: String):
	tutorial_aktif = jenis
	bisa_diskip = false # <--- Kunci layarnya saat baru muncul
	show()
	get_tree().paused = true # BEKUKAN GAME!
	
	if jenis == "gerak":
		teks_tutor.text = "[WARNING]\nTekan tombol W, A, S, D untuk bergerak.\nTekan tombol SHIFT untuk berlari"
		spotlight.hide()
		
	elif jenis == "cmd":
		teks_tutor.text = "[WARNING]\nTekan TAB untuk membuka Command Prompt.\nKetik 'help' untuk membuka list list command."
		spotlight.show()
		spotlight.position = Vector2(100, 500)
		
	elif jenis == "f":
		teks_tutor.text = "[WARNING]\nTekan F untuk pickup item!"
	
	# === TAMBAHAN: JEDA WAKTU ===
	# Tunggu 1 detik (pakai 'true' agar timer tetap jalan meski game di-pause)
	await get_tree().create_timer(1.0, true).timeout
	bisa_diskip = true # <--- Buka gemboknya, sekarang pemain boleh nge-skip!

func _input(event):
	# Kalau game lagi jalan, gak ada tutorial, ATAU MASIH DIGEMBOK -> abaikan input
	if not get_tree().paused or tutorial_aktif == "" or not bisa_diskip: 
		return
	
	# === TUTORIAL GERAK ===
	if tutorial_aktif == "gerak":
		if event is InputEventKey and event.pressed:
			tutup_tutorial()
			
	# === TUTORIAL CMD ===
	elif tutorial_aktif == "cmd":
		if event is InputEventKey and event.pressed:
			tutup_tutorial()
			
	elif tutorial_aktif == "f":
		if event is InputEventKey and event.pressed:
			tutup_tutorial()
		

func tutup_tutorial():
	tutorial_aktif = ""
	hide()
	get_tree().paused = false
