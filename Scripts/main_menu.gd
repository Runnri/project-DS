extends Control

func _on_start_button_pressed():
	# Sementara ini langsung pindah ke level main
	# Nanti bisa diganti ke scene pemilihan tingkat kesulitan (Easy/Hard)
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_load_button_pressed():
	# Nanti di sini kita taruh kode sistem Load
	print("Sistem Load sedang diproses...")

func _on_quit_button_pressed():
	# Menutup game
	get_tree().quit()
