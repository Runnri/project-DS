extends Area2D

var sudah_triggered: bool = false

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or sudah_triggered:
		return

	sudah_triggered = true
	body.frozen = true

	# Buat ColorRect hitam full-screen sebagai overlay fade
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Taruh di CanvasLayer agar selalu di depan
	var cl = CanvasLayer.new()
	cl.layer = 100
	cl.add_child(overlay)
	
	# PERBAIKAN 1: Masukkan ke current_scene, bukan ke root. 
	# Agar saat scene hancur, layar hitam ini ikut hancur.
	get_tree().current_scene.add_child(cl)

	# Fade OUT: hitam dalam 0.8 detik
	var tw = create_tween()
	tw.tween_property(overlay, "color", Color(0, 0, 0, 1), 0.8)
	tw.tween_interval(0.2)
	tw.tween_callback(func():
		# PERBAIKAN 2: Hapus paksa cl sebelum pindah scene untuk jaga-jaga
		cl.queue_free() 
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/ending_bin.tscn")
	)
