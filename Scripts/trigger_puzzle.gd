extends Area2D

func _ready() -> void:
	_set_puzzle_aktif(false)
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(_body: Node2D) -> void:
	if not _body.is_in_group("player"):
		return

	_set_puzzle_aktif(true)

	var log_node = _body.get("log_teks")
	var notif = _body.get("notif_dot")
	if log_node:
		log_node.text += "\n[SYSTEM]: Area puzzle terdeteksi."
		log_node.text += "\n[PUZZLE] Puzzle dimulai. Urutan: " + _get_urutan()
	if notif:
		notif.show()

	queue_free()

func _set_puzzle_aktif(aktif: bool) -> void:
	for ubin in get_tree().get_nodes_in_group("ubin_puzzle"):
		ubin.visible = aktif
		ubin.set_deferred("monitoring", aktif)
		ubin.set_deferred("monitorable", aktif)

func _get_urutan() -> String:
	var manager = get_tree().get_root().find_child("PuzzleManager", true, false)
	if manager:
		return " → ".join(manager.target_sequence).to_upper()
	return "BIRU → MERAH → HIJAU"
