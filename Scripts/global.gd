extends Node

var kesulitan_terpilih: String = "easy"

# Folder 'user://' adalah folder khusus yang aman di komputer/HP pemain,
# file save tidak akan hilang meski gamenya di-update.
var jalur_save = "user://save_data.cfg"

# Flag: apakah session ini adalah hasil dari "Load Game"?
var sedang_load: bool = false

# ==========================================
# CEK APAKAH FILE SAVE ADA
# ==========================================
func ada_file_save() -> bool:
	return FileAccess.file_exists(jalur_save)

# ==========================================
# FUNGSI UNTUK MENYIMPAN GAME
# ==========================================
func simpan_game(player: CharacterBody2D, nama_level_sekarang: String):
	var config = ConfigFile.new()

	# 1. Catat Data Level / Progres
	config.set_value("Progres", "level", nama_level_sekarang)
	config.set_value("Progres", "kesulitan", kesulitan_terpilih)

	# 2. Catat Kondisi Bit (Player) — inventory disimpan langsung sebagai Array
	config.set_value("Player", "hp", player.hp)
	config.set_value("Player", "stamina", player.stamina)
	config.set_value("Player", "inventory", player.inventory)

	# 3. Catat Posisi Bit (Sumbu X dan Y)
	config.set_value("Player", "posisi_x", player.global_position.x)
	config.set_value("Player", "posisi_y", player.global_position.y)

	# 4. Catat Spawn Point terakhir (supaya respawn juga benar setelah load)
	config.set_value("Player", "spawn_x", player.spawn_point.x)
	config.set_value("Player", "spawn_y", player.spawn_point.y)

	# 5. Metadata untuk tampilan di menu Load
	config.set_value("Meta", "timestamp", Time.get_datetime_string_from_system())
	config.set_value("Meta", "versi_save", 1)

	var hasil = config.save(jalur_save)
	if hasil == OK:
		print("[AUTOSAVE]: Game berhasil disimpan! File: ", jalur_save)
	else:
		push_error("[AUTOSAVE ERROR]: Gagal menyimpan game! Kode error: " + str(hasil))

# ==========================================
# BACA INFO SAVE (untuk tampilan menu Load)
# ==========================================
func baca_info_save() -> Dictionary:
	if not ada_file_save():
		return {}

	var config = ConfigFile.new()
	var err = config.load(jalur_save)
	if err != OK:
		return {}

	return {
		"level": config.get_value("Progres", "level", ""),
		"kesulitan": config.get_value("Progres", "kesulitan", "easy"),
		"timestamp": config.get_value("Meta", "timestamp", "Tidak diketahui"),
		"hp": config.get_value("Player", "hp", 100),
	}

# ==========================================
# FUNGSI MEMUAT GAME (dipanggil di _ready() player)
# ==========================================
func muat_game(player: CharacterBody2D) -> bool:
	if not ada_file_save():
		push_warning("[LOAD]: Tidak ada file save yang ditemukan.")
		return false

	var config = ConfigFile.new()
	var err = config.load(jalur_save)
	if err != OK:
		push_error("[LOAD ERROR]: Gagal membaca file save. Kode: " + str(err))
		return false

	# Terapkan data ke player
	player.hp     = config.get_value("Player", "hp",      player.max_hp)
	player.stamina = config.get_value("Player", "stamina", player.max_stamina)
	player.inventory = config.get_value("Player", "inventory", [])

	# Terapkan posisi
	var px = config.get_value("Player", "posisi_x", player.global_position.x)
	var py = config.get_value("Player", "posisi_y", player.global_position.y)
	player.global_position = Vector2(px, py)

	# Terapkan spawn point dari save
	var sx = config.get_value("Player", "spawn_x", px)
	var sy = config.get_value("Player", "spawn_y", py)
	player.spawn_point = Vector2(sx, sy)

	# Update UI bars
	if player.hp_bar:
		player.hp_bar.max_value = player.max_hp
		player.hp_bar.value = player.hp
	if player.stamina_bar:
		player.stamina_bar.max_value = player.max_stamina
		player.stamina_bar.value = player.stamina

	# Notif jika inventory tidak kosong
	if player.inventory.size() > 0 and player.notif_dot:
		player.notif_dot.show()

	kesulitan_terpilih = config.get_value("Progres", "kesulitan", "easy")
	sedang_load = false  # reset flag setelah berhasil load

	print("[LOAD]: Game berhasil dimuat dari ", jalur_save)
	return true

# ==========================================
# HAPUS FILE SAVE (New Game / Reset)
# ==========================================
func hapus_save():
	if ada_file_save():
		DirAccess.remove_absolute(jalur_save)
		print("[SAVE]: File save dihapus.")
