extends Area2D

var sudah_triggered: bool = false

func _ready():
	# Sambungin sensor maut
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not body.is_in_group("player") or sudah_triggered:
		return

	sudah_triggered = true
	body.frozen = true # Kunci gerakan Bit biar ga liar pas transisi

	# Fade Out ke Hitam (Pakai Tween sederhana)
	var cl = CanvasLayer.new()
	var rect = ColorRect.new()
	rect.color = Color(0, 0, 0, 0)
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	cl.add_child(rect)
	get_tree().current_scene.add_child(cl)

	var tw = create_tween()
	tw.tween_property(rect, "color", Color(0, 0, 0, 1), 0.8)
	tw.tween_callback(func():
		# Pindah ke scene Windows Desktop
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/ending_desktop.tscn")
	)
