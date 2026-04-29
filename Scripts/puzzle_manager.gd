extends Node

# ============================================================
# PUZZLE MANAGER — otak urutan ubin
# Taruh script ini di Node kosong di dalam level
# ============================================================

# Urutan yang harus diinjak: BIRU → MERAH → HIJAU
var target_sequence: Array[String] = ["biru", "merah", "hijau"]
var current_sequence: Array[String] = []

# Dipanggil oleh ubin saat player menginjaknya
func catat_injak(warna: String) -> void:
	var index_sekarang = current_sequence.size()

	# Cek apakah warna ini benar sesuai urutan
	if warna == target_sequence[index_sekarang]:
		current_sequence.append(warna)
		print("[PUZZLE]: Benar! Urutan: ", current_sequence)

		# Ubah lampu ubin yang diinjak jadi HIJAU
		_set_lampu_ubin(warna, Color.GREEN)

		# Cek apakah sudah selesai
		if current_sequence == target_sequence:
			_puzzle_selesai()
	else:
		# Salah → reset semua
		print("[PUZZLE]: Salah! Reset urutan.")
		reset()

# Panggil saat puzzle selesai
func _puzzle_selesai() -> void:
	print("[PUZZLE]: Urutan benar! Membuka pintu...")
	for pintu in get_tree().get_nodes_in_group("pintu_keluar"):
		if pintu.has_method("buka"):
			pintu.buka()

# Reset semua ubin ke merah dan kosongkan current_sequence
func reset() -> void:
	current_sequence.clear()
	for ubin in get_tree().get_nodes_in_group("ubin_puzzle"):
		if ubin.has_method("reset_lampu"):
			ubin.reset_lampu()

# Ubah lampu spesifik ubin berdasarkan warnanya
func _set_lampu_ubin(warna: String, color: Color) -> void:
	for ubin in get_tree().get_nodes_in_group("ubin_puzzle"):
		if ubin.warna_ubin == warna:
			ubin.set_lampu(color)
