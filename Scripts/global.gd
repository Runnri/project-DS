extends Node

var kesulitan_terpilih: String = "easy"
var sedang_load: bool = false
var auth_tujuan: String = "start"

# -- TAMBAHAN UNTUK JUDUL ENDING --
var last_ending_achieved: String = ""

# ── AKUN ────────────────────────────────────────────────────
var username_aktif: String = ""
const JALUR_AKUN = "user://accounts.cfg"

func _jalur_save_user(username: String) -> String:
	return "user://saves/" + username + ".cfg"

func jalur_save_aktif() -> String:
	return _jalur_save_user(username_aktif)

# ── HASH ─────────────────────────────────────────────────────
func _hash_password(password: String) -> String:
	return password.sha256_text()

# ── REGISTER ─────────────────────────────────────────────────
func register(username: String, password: String) -> String:
	username = username.strip_edges()
	password = password.strip_edges()
	if username.length() < 3:
		return "Username minimal 3 karakter."
	if password.length() < 4:
		return "Password minimal 4 karakter."
	for c in ["/", "\\", ":", "*", "?", "\"", "<", ">", "|", " "]:
		if username.contains(c):
			return "Username tidak boleh mengandung karakter khusus atau spasi."
	var config = ConfigFile.new()
	if FileAccess.file_exists(JALUR_AKUN):
		config.load(JALUR_AKUN)
	if config.has_section_key("Accounts", username):
		return "Username sudah digunakan."
	config.set_value("Accounts", username, _hash_password(password))
	config.save(JALUR_AKUN)
	
	var save_dir = "user://saves/"
	if not DirAccess.dir_exists_absolute(save_dir):
		DirAccess.make_dir_recursive_absolute(save_dir)
		
	return ""

# ── LOGIN ────────────────────────────────────────────────────
func login(username: String, password: String) -> String:
	var config = ConfigFile.new()
	if not FileAccess.file_exists(JALUR_AKUN):
		return "Belum ada akun terdaftar."
	config.load(JALUR_AKUN)
	if not config.has_section_key("Accounts", username):
		return "Username tidak ditemukan."
	if config.get_value("Accounts", username) != _hash_password(password):
		return "Password salah."
	username_aktif = username
	return ""

# ── CEK SAVE ─────────────────────────────────────────────────
func ada_file_save() -> bool:
	if username_aktif == "": return false
	return FileAccess.file_exists(jalur_save_aktif())

# ── SIMPAN GAME ──────────────────────────────────────────────
func simpan_game(player: CharacterBody2D):
	if username_aktif == "": return
	var config = ConfigFile.new()
	if ada_file_save():
		config.load(jalur_save_aktif())

	config.set_value("Progres", "posisi_x", player.global_position.x)
	config.set_value("Progres", "posisi_y", player.global_position.y)
	config.set_value("Progres", "kesulitan", kesulitan_terpilih)
	config.save(jalur_save_aktif())
	print("[SAVE]: Berhasil disimpan untuk user '", username_aktif, "'")

# ── MUAT GAME ────────────────────────────────────────────────
func muat_game(player: CharacterBody2D) -> bool:
	if not ada_file_save(): return false
	sedang_load = true
	var config = ConfigFile.new()
	config.load(jalur_save_aktif())

	var px = config.get_value("Progres", "posisi_x", player.global_position.x)
	var py = config.get_value("Progres", "posisi_y", player.global_position.y)
	
	player.global_position = Vector2(px, py)
	
	if player.has_method("set_deferred"):
		player.call_deferred("set", "global_position", Vector2(px, py))
		player.call_deferred("set", "spawn_x", px)
		player.call_deferred("set", "spawn_y", py)
	
	if player.stamina_bar:
		player.stamina_bar.max_value = player.max_stamina
		player.stamina_bar.value     = player.stamina

	if player.inventory.size() > 0 and player.notif_dot:
		player.notif_dot.show()

	kesulitan_terpilih = config.get_value("Progres", "kesulitan", "easy")
	sedang_load = false
	print("[LOAD]: Berhasil dimuat untuk user '", username_aktif, "'")
	return true

# ── HAPUS SAVE ────────────────────────────────────────────────
func hapus_save():
	if ada_file_save():
		DirAccess.remove_absolute(jalur_save_aktif())
		print("[SAVE]: File save untuk '", username_aktif, "' dihapus.")

# ── ENDING SYSTEM ────────────────────────────────────────────
func catat_ending_ke_akun(nama_ending: String) -> int:
	# Simpan judul ending untuk scene teks
	last_ending_achieved = nama_ending
	
	if not ada_file_save():
		return 0

	var config = ConfigFile.new()
	config.load(jalur_save_aktif())

	var list_ending: Array = config.get_value("Progres", "ending_terbuka", [])

	if nama_ending not in list_ending:
		list_ending.append(nama_ending)
		config.set_value("Progres", "ending_terbuka", list_ending)
		config.save(jalur_save_aktif())
		print("[ENDING]: Baru terbuka -> ", nama_ending)
	
	return list_ending.size()
