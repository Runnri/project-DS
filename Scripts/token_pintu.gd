extends Area2D

func interaksi(player):
	# UBAH NAMA ITEMNYA DI SINI MENJADI "tokenkey"
	var berhasil_diambil = player.tambah_item("tokenkey")
	
	if berhasil_diambil:
		queue_free()
