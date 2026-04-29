extends Node

# ==========================================
# SCENE CREDIT — Scrolling text ke atas
# Setelah selesai, kembali ke main_menu.tscn
# ==========================================

@onready var label_credit : Label      = $CanvasLayer/LabelCredit
@onready var color_rect   : ColorRect  = $CanvasLayer/ColorRect

# Kecepatan scroll pixel per detik
const KECEPATAN_SCROLL: float = 60.0

# Posisi awal (di bawah layar) dan posisi akhir (di atas layar)
var posisi_awal_y  : float
var posisi_akhir_y : float
var selesai        : bool = false

func _ready() -> void:
	# Isi teks credit — ganti dengan nama tim kamu
	label_credit.text = _teks_credit()

	# Pastikan label sudah dirender agar get_rect() akurat
	await get_tree().process_frame

	var tinggi_viewport = get_viewport().get_visible_rect().size.y
	var tinggi_label    = label_credit.get_rect().size.y

	# Mulai dari bawah layar, akhiri sampai seluruh teks naik ke atas
	posisi_awal_y  = tinggi_viewport + 40.0
	posisi_akhir_y = -tinggi_label - 40.0

	label_credit.position.y = posisi_awal_y

func _process(delta: float) -> void:
	if selesai:
		return

	label_credit.position.y -= KECEPATAN_SCROLL * delta

	if label_credit.position.y <= posisi_akhir_y:
		selesai = true
		# Jeda 1 detik sebelum kembali ke menu
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _teks_credit() -> String:
	return """
════════════════════════
    Undeleted Cache
════════════════════════

~ GAME DESIGN ~
	runnri

~ PROGRAMMING ~
	runnri

~ ART & ASSETS ~
	itch.io

~ SOUND & MUSIC ~
	runnri

~ SPECIAL THANKS ~
  Guru Pembimbing
  Ismita Ratnasari

~ Create with ❤️ ~
  At SMKN2Cimahi

   Terima Kasih Sudah
      Bermain!

"""
