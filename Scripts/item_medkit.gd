extends Area2D

func interaksi(player):
	var berhasil_diambil = player.tambah_item("medkit")
	
	if berhasil_diambil:
		queue_free()
