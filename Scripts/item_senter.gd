extends Area2D

@export var nama_item: String = "flashlight"

# Fungsi ini HANYA akan jalan kalau si Bit mencet tombol 'F' di dekat senter
func interaksi(player):
	# Kita panggil fungsi tambah_item yang ada di script Player
	var berhasil_diambil = player.tambah_item(nama_item)
	
	if berhasil_diambil:
		queue_free() # Senternya lenyap dari lantai karena sudah masuk inventory
