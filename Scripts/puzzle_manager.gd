extends Node

var target_sequence: Array = ["biru", "merah", "hijau"]
var current_sequence: Array = []

func terima_input(warna: String) -> void:
	var index = current_sequence.size()
	if index >= target_sequence.size():
		return

	var warna_benar = target_sequence[index]

	if warna == warna_benar:
		current_sequence.append(warna)
		_set_lampu_ubin(warna, "benar")
		_log("[PUZZLE] ✔ Benar! %s (%d/%d)" % [warna.to_upper(), current_sequence.size(), target_sequence.size()])
		if current_sequence == target_sequence:
			_buka_semua_pintu()
	else:
		_log("[PUZZLE] ❌ SALAH! Menginjak '%s', seharusnya '%s'." % [warna.to_upper(), warna_benar.to_upper()])
		_reset_puzzle()

func _reset_puzzle() -> void:
	current_sequence.clear()
	for ubin in get_tree().get_nodes_in_group("ubin_puzzle"):
		ubin.set_lampu("hitam")
	await get_tree().create_timer(1.0).timeout
	target_sequence.shuffle()
	_log("[PUZZLE] 🔄 RESET — Urutan baru: " + _format_urutan())
	for ubin in get_tree().get_nodes_in_group("ubin_puzzle"):
		ubin.set_lampu("asal")

func _set_lampu_ubin(warna: String, state: String) -> void:
	for ubin in get_tree().get_nodes_in_group("ubin_puzzle"):
		if ubin.warna_ubin == warna:
			ubin.set_lampu(state)

func _buka_semua_pintu() -> void:
	_log("[PUZZLE] ✅ BENAR SEMUA — Pintu terbuka!")
	for pintu in get_tree().get_nodes_in_group("pintu_keluar"):
		# Support dua nama fungsi: buka() di pintu_keluar.gd
		#                          buka_pintu() di pintu_keluar_puzzle.gd
		if pintu.has_method("buka"):
			pintu.buka()
		elif pintu.has_method("buka_pintu"):
			pintu.buka_pintu()

func _format_urutan() -> String:
	return " → ".join(target_sequence).to_upper()

func _log(pesan: String) -> void:
	print(pesan)
	var player = get_tree().get_first_node_in_group("player")
	if player and player.log_teks:
		player.log_teks.text += "\n" + pesan
		if player.notif_dot:
			player.notif_dot.show()
