extends Area2D

@onready var pintu_utama = get_parent()
@onready var tembok = get_parent().get_node("CollisionShape2D")
@onready var animasi_pintu = get_parent().get_node("AnimatedSprite2D")

var sudah_terbuka = false

func _ready():
	if animasi_pintu.sprite_frames.has_animation("idle"):
		animasi_pintu.play("idle")

func interaksi(player):
	if sudah_terbuka: 
		return

	# UBAH PENGECEKAN MENJADI "tokenkey"
	if "tokenkey" in player.inventory:
		buka_pintu(player)
	else:
		if player.log_teks:
			player.log_teks.text += "\n[SYSTEM]: AKSES DITOLAK! File 'tokenkey' tidak ditemukan."

func buka_pintu(player):
	sudah_terbuka = true
	tembok.set_deferred("disabled", true)
	
	if animasi_pintu.sprite_frames.has_animation("buka"):
		animasi_pintu.play("buka") 
	else:
		animasi_pintu.hide()
	
	# MENGHAPUS ITEM DARI TAS DAN TANGAN PLAYER
	player.hapus_item("tokenkey")
	
	if player.log_teks:
		player.log_teks.text += "\n[SYSTEM]: Token diverifikasi. Pintu terbuka."
