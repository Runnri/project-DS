extends CanvasLayer

# process_mode ALWAYS agar tetap aktif saat game pause
func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if visible:
			_on_resume_pressed()
		else:
			tampilkan()
		get_viewport().set_input_as_handled()

func tampilkan():
	show()
	get_tree().paused = true

func _on_resume_pressed():
	hide()
	get_tree().paused = false

func _on_quit_to_menu_pressed():
	get_tree().paused = false
	hide()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
