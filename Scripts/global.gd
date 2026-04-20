extends Node

var kesulitan_terpilih: String = "easy"
var sedang_load: bool = false
var auth_tujuan: String = "start"  # "start" atau "load"

# ==========================================
# SISTEM AKUN
# ==========================================
var username_aktif: String = ""  # Username yang sedang login

# File database semua akun (username + password hash)
const JALUR_AKUN = "user://accounts.cfg"

# Jalur save game per-user: user://saves/<username>.cfg
func _jalur_save_user(username: String) -> String:
	return "user://saves/" + username + ".cfg"

# Jalur save untuk user yang sedang login
func jalur_save_aktif() -> String:
	return _jalur_save_user(username_aktif)

# ==========================================
# HASH PASSWORD (sederhana, cukup untuk game lokal)
# ==========================================
func _hash_password(password: String) -> String:
	return password.sha256_text()

# ==========================================
# REGISTER AKUN BARU
# Mengembalikan "" jika berhasil, atau pesan error
# ==========================================
func register(username: String, password: String) -> String:
	username = username.strip_edges()
	password = password.strip_edges()

	if username.length() < 3:
		return "Username minimal 3 karakter."
	if password.length() < 4:
		return "Password minimal 4 karakter."
	# Cegah karakter ilegal di nama file
	for c in ["/", "\\", ":", "*", "?", "\"", "<", ">", "|", " "]:
		if username.contains(c):
			return "Username tidak boleh mengandung karakter khusus atau spasi."

	var config = ConfigFile.new()
	if FileAccess.file_exists(JALUR_AKUN):
		config.load(JALUR_AKUN)

	if config.has_section_key("Accounts", username):
		return "Username sudah digunakan."

	config.set_value("Accounts", username, _hash_password(password))
	var err = config.save(JALUR_AKUN)
	if err != OK:
		return "Gagal menyimpan akun."

	# Buat folder saves jika belum ada
	DirAccess.make_dir_recursive_absolute("user://saves")
	return ""

# ==========================================
# LOGIN
# Mengembalikan "" jika berhasil, atau pesan error
# ==========================================
func login(username: String, password: String) -> String:
	username = username.strip_edges()
	password = password.strip_edges()

	if not FileAccess.file_exists(JALUR_AKUN):
		return "Belum ada akun. Silakan Register dulu."

	var config = ConfigFile.new()
	config.load(JALUR_AKUN)

	if not config.has_section_key("Accounts", username):
		return "Username tidak ditemukan."

	var stored_hash = config.get_value("Accounts", username, "")
	if stored_hash != _hash_password(password):
		return "Password salah."

	username_aktif = username
	DirAccess.make_dir_recursive_absolute("user://saves")
	print("[AUTH]: Login berhasil sebagai '", username, "'")
	return ""

# ==========================================
# LOGOUT
# ==========================================
func logout():
	print("[AUTH]: '", username_aktif, "' logout.")
	username_aktif = ""
	sedang_load = false

# ==========================================
# CEK APAKAH USER SUDAH LOGIN
# ==========================================
func sudah_login() -> bool:
	return username_aktif != ""

# ==========================================
# CEK SAVE UNTUK USER AKTIF
# ==========================================
func ada_file_save() -> bool:
	if not sudah_login():
		return false
	return FileAccess.file_exists(jalur_save_aktif())

# ==========================================
# SIMPAN GAME (per-user)
# ==========================================
func simpan_game(player: CharacterBody2D, nama_level_sekarang: String):
	if not sudah_login():
		push_error("[SAVE]: Tidak ada user yang login!")
		return

	var config = ConfigFile.new()
	config.set_value("Progres", "level", nama_level_sekarang)
	config.set_value("Progres", "kesulitan", kesulitan_terpilih)
	config.set_value("Player", "hp", player.hp)
	config.set_value("Player", "stamina", player.stamina)
	config.set_value("Player", "inventory", player.inventory)
	config.set_value("Player", "posisi_x", player.global_position.x)
	config.set_value("Player", "posisi_y", player.global_position.y)
	config.set_value("Player", "spawn_x", player.spawn_point.x)
	config.set_value("Player", "spawn_y", player.spawn_point.y)
	config.set_value("Meta", "timestamp", Time.get_datetime_string_from_system())
	config.set_value("Meta", "versi_save", 1)

	var hasil = config.save(jalur_save_aktif())
	if hasil == OK:
		print("[AUTOSAVE]: Tersimpan untuk user '", username_aktif, "'")
	else:
		push_error("[AUTOSAVE ERROR]: Kode error: " + str(hasil))

# ==========================================
# BACA INFO SAVE
# ==========================================
func baca_info_save() -> Dictionary:
	if not ada_file_save():
		return {}
	var config = ConfigFile.new()
	if config.load(jalur_save_aktif()) != OK:
		return {}
	return {
		"level":     config.get_value("Progres", "level", ""),
		"kesulitan": config.get_value("Progres", "kesulitan", "easy"),
		"timestamp": config.get_value("Meta", "timestamp", "Tidak diketahui"),
		"hp":        config.get_value("Player", "hp", 100),
	}

# ==========================================
# MUAT GAME
# ==========================================
func muat_game(player: CharacterBody2D) -> bool:
	if not ada_file_save():
		push_warning("[LOAD]: Tidak ada file save untuk user '" + username_aktif + "'.")
		return false

	var config = ConfigFile.new()
	if config.load(jalur_save_aktif()) != OK:
		push_error("[LOAD ERROR]: Gagal membaca file save.")
		return false

	player.hp       = config.get_value("Player", "hp",        player.max_hp)
	player.stamina  = config.get_value("Player", "stamina",   player.max_stamina)
	player.inventory = config.get_value("Player", "inventory", [])

	var px = config.get_value("Player", "posisi_x", player.global_position.x)
	var py = config.get_value("Player", "posisi_y", player.global_position.y)
	player.global_position = Vector2(px, py)
	player.spawn_point = Vector2(
		config.get_value("Player", "spawn_x", px),
		config.get_value("Player", "spawn_y", py)
	)

	if player.hp_bar:
		player.hp_bar.max_value = player.max_hp
		player.hp_bar.value = player.hp
	if player.stamina_bar:
		player.stamina_bar.max_value = player.max_stamina
		player.stamina_bar.value = player.stamina
	if player.inventory.size() > 0 and player.notif_dot:
		player.notif_dot.show()

	kesulitan_terpilih = config.get_value("Progres", "kesulitan", "easy")
	sedang_load = false
	print("[LOAD]: Berhasil dimuat untuk user '", username_aktif, "'")
	return true

# ==========================================
# HAPUS SAVE USER AKTIF
# ==========================================
func hapus_save():
	if ada_file_save():
		DirAccess.remove_absolute(jalur_save_aktif())
		print("[SAVE]: File save untuk '", username_aktif, "' dihapus.")
