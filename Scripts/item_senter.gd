extends Area2D

@export var item_name: String = "Senter"

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("tambah_item"):
		# Kita tanya Player, "Bisa nampung barang nggak?"
		# Hasilnya (true/false) kita simpan di variabel 'berhasil_diambil'
		var berhasil_diambil = body.tambah_item(item_name)
		
		# Kalau hasilnya true (berhasil masuk inventory)
		if berhasil_diambil == true:
			queue_free() # Baru deh senternya menghilang dari map
