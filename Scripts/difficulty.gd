extends Control

# Simpan pilihan kesulitan ke Global sebelum masuk level

func _on_easy_button_pressed():
	Global.kesulitan_terpilih = "easy"
	print("[Difficulty]: Level Easy dipilih.")
	get_tree().change_scene_to_file("res://Scenes/intro_cut_scene.tscn")

func _on_medium_button_pressed():
	Global.kesulitan_terpilih = "medium"
	print("[Difficulty]: Level Medium dipilih.")
	get_tree().change_scene_to_file("res://Scenes/intro_cut_scene.tscn")

func _on_hard_button_pressed():
	Global.kesulitan_terpilih = "hard"
	print("[Difficulty]: Level Hard dipilih.")
	get_tree().change_scene_to_file("res://Scenes/intro_cut_scene.tscn")
