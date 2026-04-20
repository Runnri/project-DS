extends Area2D

# Bikin pilihan di Inspector biar kita gampang nentuin ini sensor buat apa
@export_enum("gerak", "cmd", "f") var jenis_tutorial: String = "gerak"

func _on_body_entered(body):
	if body.name == "Player":
		# Cari layar tutorial di level
		var layar_tutor = get_tree().current_scene.get_node_or_null("TutorialUI")
		if layar_tutor:
			layar_tutor.munculkan_tutorial(jenis_tutorial)
			queue_free() # Hapus sensor biar nggak kepanggil 2 kali
