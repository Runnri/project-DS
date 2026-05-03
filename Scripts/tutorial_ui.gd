extends CanvasLayer

@onready var layar_gelap = $ColorRect
@onready var teks_tutor  = $Label
@onready var spotlight   = $Spotlight

var tutorial_aktif = ""
var bisa_diskip    = false

func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func munculkan_tutorial(jenis: String):
	tutorial_aktif = jenis
	bisa_diskip    = false
	show()
	get_tree().paused = true

	# --- Teks tutorial ---
	if jenis == "gerak":
		teks_tutor.text = "[WARNING]\nTekan tombol W, A, S, D untuk bergerak.\nTekan tombol SHIFT untuk berlari"
		spotlight.hide()
	elif jenis == "cmd":
		teks_tutor.text = "[WARNING]\nTekan TAB untuk membuka Command Prompt.\nKetik 'help' untuk membuka list command."
		spotlight.show()
		spotlight.position = Vector2(100, 500)
	elif jenis == "f":
		teks_tutor.text = "[WARNING]\nTekan F untuk pickup item!"
	elif jenis == "guard1":
		teks_tutor.text = "[WARNING]\nItu adalah guard pembersih.\nJangan sampai kau mengenainya atau kamu akan terdelete!"

	# Teks langsung muncul penuh, tidak perlu efek tambahan
	teks_tutor.modulate.a = 1.0

	await get_tree().create_timer(1.0, true).timeout
	bisa_diskip = true

func _input(event):
	if not get_tree().paused or tutorial_aktif == "" or not bisa_diskip:
		return
	if event is InputEventKey and event.pressed:
		tutup_tutorial()

func tutup_tutorial():
	tutorial_aktif = ""
	hide()
	get_tree().paused = false
