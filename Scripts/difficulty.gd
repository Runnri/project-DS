extends Control

# Fungsi ini akan menyimpan pilihan pemain ke sebuah variabel global
# Tapi sementara, kita langsung arahkan saja ke level utama (main.tscn)

func _on_easy_button_pressed():
	print("Level Easy Dipilih!")
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_medium_button_pressed():
	print("Level Medium Dipilih!")
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_hard_button_pressed():
	print("Level Hard Dipilih!")
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
