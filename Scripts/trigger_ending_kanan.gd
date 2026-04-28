extends Area2D

# ==========================================
# TRIGGER ENDING KANAN (Recycle Bin)
# Pasang script ini ke Area2D di lorong kanan level utama.
# Saat Bit masuk area ini, gerakannya dikunci lalu pindah ke ending_bin.
# ==========================================

# Pastikan sinyal body_entered sudah terhubung ke fungsi ini
# (bisa via Inspector atau kode di bawah)
func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Hanya trigger untuk player
	if not body.is_in_group("player"):
		return

	# Kunci gerakan player
	if "frozen" in body:
		body.frozen = true

	# Pastikan game tidak ter-pause
	get_tree().paused = false

	# Pindah ke scene ending bin
	get_tree().change_scene_to_file("res://Scenes/ending_bin.tscn")
