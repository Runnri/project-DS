extends Area2D

@onready var teks_popup = $Label

# Fitur ajaib biar kamu bisa ngubah isi teks tiap papan langsung dari Inspector!
@export_multiline var isi_pesan: String = "Ketik teks di sini..."

func _ready():
	# Sembunyikan teks saat game baru mulai
	teks_popup.hide()
	teks_popup.text = isi_pesan

func _on_body_entered(body):
	# Kalau yang nginjek zona ini adalah Bit, munculkan teks
	if body.is_in_group("player"):
		teks_popup.show()

func _on_body_exited(body):
	# Kalau Bit keluar dari zona ini, hilangkan teks
	if body.is_in_group("player"):
		teks_popup.hide()
