extends CharacterBody2D

# ==========================================
# 1. VARIABEL PENGATURAN UMUM
# ==========================================
@export var speed: float = 200.0
@export var sprint_speed: float = 350.0
@export var max_stamina: float = 100.0
@export var max_hp: int = 100        # Tetap ada untuk kompatibilitas save/load
@export var max_inventory: int = 3
@export var img_darah_ada: Texture2D = preload("res://Assets/ornamen/slime_darahada.png.png")
@export var img_darah_kosong: Texture2D = preload("res://Assets/ornamen/slime_darahkosong.png.png")
@onready var item_di_tangan = $ItemDiTangan

# ==========================================
# 2. STATUS PLAYER
# ==========================================
var stamina: float = max_stamina
var stamina_drain: float = 40.0
var stamina_regen: float = 20.0

# UBAH DI SINI: Tambahkan Setter untuk hp
var hp: int = max_hp:
	set(value):
		hp = value
		# Konversi otomatis hp ke nyawa saat data di-load
		if hp > 66: nyawa = 3
		elif hp > 33: nyawa = 2
		elif hp > 0: nyawa = 1
		else: nyawa = 0

# --- SISTEM 3 NYAWA ---
const MAX_NYAWA: int = 3

# UBAH DI SINI: Tambahkan Setter untuk nyawa
var nyawa: int = MAX_NYAWA:
	set(value):
		nyawa = clamp(value, 0, MAX_NYAWA)
		# Update UI otomatis saat nyawa berubah atau saat load game
		if has_method("_update_ui_nyawa"):
			_update_ui_nyawa()

var spawn_awal: Vector2              # Posisi spawn PALING AWAL (tidak pernah berubah)

var is_dead: bool = false
var frozen: bool = false   # Di-set true oleh pintu_password saat UI aktif
var spawn_point: Vector2
var inventory: Array = []
var arah_terakhir: String = "bawah"

# ==========================================
# 3. KONEKSI KE NODE (UI & Sensor)
# ==========================================
@onready var sprite        = $AnimatedSprite2D
@onready var stamina_bar   = $CanvasLayer/ProgressBar
@onready var terminal      = $CanvasLayer/CMD
@onready var input_cmd     = $CanvasLayer/CMD/LineEdit
@onready var notif_dot     = $CanvasLayer/IconCMD/NotifDot
@onready var log_teks      = $CanvasLayer/CMD/LogTeks
@onready var senter_player = $SenterPlayer
@onready var interact_box  = $InteractBox
@onready var prompt_f      = $F
@onready var level_notif   = $CanvasLayer/LevelNotif
@onready var nyawa_container = $CanvasLayer/NyawaContainer
@onready var fade_awal = $CanvasLayer/FadeAwal



# ==========================================
# 4. DATABASE TERMINAL (Daftar Perintah)
# ==========================================
var valid_commands = ["use flashlight", "use medkit", "use scanner", "use tokenkey", "help", "clear", "inventory", "killme"]
var item_descriptions = {
	"flashlight": "Alat penerangan portabel, menggunakan baterai A3.",
	"medkit":     "P3K standar untuk pertolongan pertama. Memulihkan HP.",
	"scanner":    "Alat pemindai anomali dan blueprint area sekitar.",
	"tokenkey":   "Data enkripsi untuk membuka akses gerbang utama."
}

# ==========================================
# 5. FUNGSI UTAMA
# ==========================================
func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("player")

	# Simpan posisi awal SEKALI — tidak pernah diubah checkpoint
	spawn_awal  = global_position
	spawn_point = global_position

	# Setup stamina bar
	if stamina_bar:
		stamina_bar.max_value = max_stamina
		stamina_bar.value = stamina

	# Tampilkan nyawa awal (semua menyala)
	_update_ui_nyawa()

	terminal.hide()
	notif_dot.hide()
	senter_player.enabled = false
	prompt_f.hide()

	if not input_cmd.text_submitted.is_connected(_on_cmd_submitted):
		input_cmd.text_submitted.connect(_on_cmd_submitted)

	if Global.sedang_load:
		# call_deferred agar semua @onready node sudah siap
		call_deferred("_lakukan_load_game")
		
	if fade_awal:
		# Kunci pergerakan saat baru bangun (opsional, hapus baris frozen kalau mau bisa langsung gerak)
		frozen = true 
		
		# Pastikan layar mulai dari hitam pekat
		fade_awal.color = Color(0, 0, 0, 1)
		fade_awal.show()
		
		var tw = create_tween()
		# Proses fade out dari hitam ke transparan (durasi 2.0 detik)
		tw.tween_property(fade_awal, "color:a", 0.0, 2.0)
		tw.tween_callback(func():
			fade_awal.hide()
			frozen = false # Lepas kunci pergerakan
		)

func _lakukan_load_game():
	Global.muat_game(self)

# ==========================================
# 6. PERGERAKAN & FISIKA
# ==========================================
func _physics_process(delta):
	if is_dead:
		return
	if get_tree().paused:
		return
	if frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if terminal.visible:
		velocity = Vector2.ZERO
		sprite.play("idle_" + arah_terakhir)
		move_and_slide()
		return

	var direction = Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):    direction.y -= 1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):  direction.y += 1
	if Input.is_physical_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):  direction.x -= 1
	if Input.is_physical_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"): direction.x += 1
	direction = direction.normalized()

	var current_speed = speed
	var is_sprinting = Input.is_physical_key_pressed(KEY_SHIFT)

	if is_sprinting and stamina > 0 and direction != Vector2.ZERO:
		current_speed = sprint_speed
		stamina -= stamina_drain * delta
		sprite.speed_scale = 1.8
	else:
		if stamina < max_stamina:
			stamina += stamina_regen * delta
		sprite.speed_scale = 1.0

	stamina = clamp(stamina, 0.0, max_stamina)
	if stamina_bar:
		stamina_bar.value = stamina

	if direction != Vector2.ZERO:
		velocity = direction * current_speed
		update_animation(direction)
	else:
		velocity = Vector2.ZERO
		sprite.play("idle_" + arah_terakhir)

	move_and_slide()
	_update_interaction_prompt()
	
	# BIKIN BIT BISA NGEDORONG BALOK
	var kekuatan_dorong = 60.0 # Gedein angkanya kalau baloknya terasa berat
	for i in get_slide_collision_count():
		var tabrakan = get_slide_collision(i)
		var objek = tabrakan.get_collider()
		
		# Kalau yang ditabrak itu RigidBody dan masuk grup "balok"
		if objek is RigidBody2D and objek.is_in_group("balok"):
			objek.apply_central_impulse(-tabrakan.get_normal() * kekuatan_dorong)

# ==========================================
# 7. INPUT
# ==========================================
func _input(event):
	if is_dead:
		return

	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		# Blokir TAB jika UI password sedang aktif
		for pintu in get_tree().get_nodes_in_group("pintu_password"):
			if pintu.get("ui_aktif") == true:
				get_viewport().set_input_as_handled()
				return
		var layar_tutor = get_tree().current_scene.get_node_or_null("TutorialUI")
		if layar_tutor and layar_tutor.tutorial_aktif == "gerak":
			return
		if terminal.visible:
			terminal.hide()
			input_cmd.release_focus()
			get_tree().paused = false
		else:
			terminal.show()
			input_cmd.text = ""
			input_cmd.grab_focus()
			notif_dot.hide()
			get_tree().paused = true
		get_viewport().set_input_as_handled()

	if event is InputEventKey and event.pressed and event.keycode == KEY_F and not terminal.visible:
		if get_tree().paused:
			return
		var benda_sekitar = interact_box.get_overlapping_areas()
		for benda in benda_sekitar:
			if benda.has_method("interaksi"):
				benda.interaksi(self)
				break

# ==========================================
# 8. SISTEM NYAWA (3 LIVES)
# ==========================================

#tampilan 3 lingkaran berdasarkan nyawa sekarang
func _update_ui_nyawa():
	if not nyawa_container: return
	
	var list_nyawa = nyawa_container.get_children()
	for i in range(list_nyawa.size()):
		# Jika index kurang dari jumlah nyawa sekarang, pakai gambar 'ada'
		if i < nyawa:
			list_nyawa[i].texture = img_darah_ada
		# Jika sudah berkurang, ganti ke gambar 'kosong'
		else:
			list_nyawa[i].texture = img_darah_kosong

func _buat_stylebox_nyawa(isi: bool) -> StyleBoxFlat:
	var sb = StyleBoxFlat.new()
	sb.corner_radius_top_left    = 100
	sb.corner_radius_top_right   = 100
	sb.corner_radius_bottom_right = 100
	sb.corner_radius_bottom_left  = 100
	if isi:
		sb.bg_color = Color(0.9, 0.1, 0.1, 1.0)
	else:
		sb.bg_color = Color(0.2, 0.2, 0.2, 0.7)
		sb.border_width_left   = 1
		sb.border_width_top    = 1
		sb.border_width_right  = 1
		sb.border_width_bottom = 1
		sb.border_color = Color(0.5, 0.5, 0.5, 0.5)
	return sb

# Dipanggil oleh guard, obstacle, atau apapun yang menyakiti player
func terima_damage(_jumlah: int):
	if is_dead:
		return
	# Untuk kompatibilitas, jumlah damage besar = langsung mati 1 nyawa
	mati()

func mati():
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO

	# FIX: kurangi nyawa DULU sebelum pause
	# Jika pause dulu, await timer tidak akan berjalan
	nyawa -= 1
	nyawa = max(nyawa, 0)
	_update_ui_nyawa()

	if terminal.visible:
		terminal.hide()

	if log_teks:
		log_teks.text += "\n[FATAL ERROR]: System Purged. Nyawa tersisa: " + str(nyawa)

	# Putar animasi mati tanpa pause agar await bisa jalan
	if sprite.sprite_frames.has_animation("mati"):
		sprite.play("mati")
		await sprite.animation_finished
	else:
		if log_teks:
			log_teks.text += "\n[Error]: Animation 'mati' not found."

	# Baru pause setelah animasi, lalu tunggu 1 detik
	get_tree().paused = true
	await get_tree().create_timer(1.0, true).timeout
	get_tree().paused = false

	if nyawa <= 0:
		_game_over()
	else:
		respawn()

func respawn():
	# 1. Kembali ke checkpoint terakhir & reset status (Tetap)
	global_position = spawn_point
	stamina = max_stamina
	if stamina_bar:
		stamina_bar.value = stamina
	is_dead = false
	
	# 2. Lepas pause SEBELUM mutar animasi agar await tidak macet (Tetap)
	get_tree().paused = false
	
	if log_teks:
		log_teks.text += "\n[SYSTEM]: Reboot Successful. Cache restored."
		
	# 3. --- MULAI EFEK BANGUN (YANG BARU) ---
	frozen = true # Kunci pergerakan
	
	# Mainkan animasi bangun (Pastikan nama animasinya "bangun" di editor)
	sprite.play("hidup") 
	
	# Tunggu sampai animasi benar-benar selesai
	await sprite.animation_finished
	
	# 4. --- SELESAI BANGUN ---
	frozen = false # Lepas kunci
	
	# Kembali ke animasi idle sesuai arah terakhir (Yang lama dipindah ke sini)
	sprite.play("idle_" + arah_terakhir)

func _game_over():
	# Semua nyawa habis → kembali ke spawn PALING AWAL dan reset nyawa
	nyawa = MAX_NYAWA
	_update_ui_nyawa()
	global_position = spawn_awal
	spawn_point = spawn_awal
	# Reset semua checkpoint agar bisa disentuh ulang setelah game over
	_reset_semua_checkpoint()
	stamina = max_stamina
	if stamina_bar:
		stamina_bar.value = stamina
	is_dead = false
	sprite.play("idle_" + arah_terakhir)
	get_tree().paused = false
	if log_teks:
		log_teks.text += "\n[SYSTEM]: All lives lost. Returning to origin..."

func _reset_semua_checkpoint():
	for cp in get_tree().get_nodes_in_group("checkpoint"):
		if cp.has_method("reset_checkpoint"):
			cp.reset_checkpoint()

func update_checkpoint(posisi_baru: Vector2):
	# Hanya update spawn_point (checkpoint), spawn_awal tidak berubah
	spawn_point = posisi_baru
	if log_teks:
		log_teks.text += "\n[SYSTEM]: Sector recovery complete. New checkpoint cached."

# ==========================================
# 9. FUNGSI PENDUKUNG
# ==========================================
func update_animation(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0: sprite.play("kanan"); arah_terakhir = "kanan"
		else:          sprite.play("kiri");  arah_terakhir = "kiri"
	else:
		if dir.y > 0: sprite.play("bawah"); arah_terakhir = "bawah"
		else:          sprite.play("atas");  arah_terakhir = "atas"

func _update_interaction_prompt():
	var bisa_interaksi = false
	for benda in interact_box.get_overlapping_areas():
		if benda.has_method("interaksi"):
			bisa_interaksi = true
			break
	if bisa_interaksi: prompt_f.show()
	else:              prompt_f.hide()

func tambah_item(nama_barang: String) -> bool:
	if inventory.size() < max_inventory:
		inventory.append(nama_barang.to_lower())
		notif_dot.show()
		if log_teks:
			log_teks.text += "\n[SYSTEM]: Item baru ditemukan (" + nama_barang + ")!"
			log_teks.text += "\n[SYSTEM]: Ketik 'use " + nama_barang.to_lower() + "' untuk menggunakan."
		return true
	else:
		if log_teks:
			log_teks.text += "\n[WARNING]: Inventory penuh! Maks " + str(max_inventory) + " item."
		return false

func hapus_item(nama_barang: String):
	var nama = nama_barang.to_lower()
	if nama in inventory:
		inventory.erase(nama)
		if nama == "tokenkey" and item_di_tangan:
			item_di_tangan.hide()
		if log_teks:
			log_teks.text += "\n[SYSTEM]: Item '" + nama + "' telah digunakan."

# ==========================================
# 10. TERMINAL
# ==========================================
func _on_cmd_submitted(new_text: String):
	var cmd = new_text.to_lower().strip_edges()
	if cmd.is_empty():
		return

	log_teks.text += "\n\n> " + cmd
	input_cmd.clear()

	var parts  = cmd.split(" ")
	var action = parts[0]
	var target = parts[1] if parts.size() > 1 else ""

	if cmd in valid_commands or action == "help" or action == "inventory" or action == "clear" or action == "killme":
		match action:
			"use":
				_handle_use_command(target)
			"help":
				if target != "" and item_descriptions.has(target):
					log_teks.text += "\n[Info] " + target + ": " + item_descriptions[target]
				else:
					log_teks.text += "\n[Available Commands]:\n- " + "\n- ".join(PackedStringArray(valid_commands))
				var layar_tutor = get_tree().current_scene.get_node_or_null("TutorialUI")
				if layar_tutor and layar_tutor.tutorial_aktif == "cmd":
					layar_tutor.tutup_tutorial()
			"inventory":
				if inventory.is_empty():
					log_teks.text += "\n[Inventory]: (kosong)"
				else:
					log_teks.text += "\n[Inventory]: " + str(inventory)
			"clear":
				log_teks.text = "------"
			"killme":
				mati()
	else:
		var best_match = ""
		var min_dist = 999
		for v_cmd in valid_commands:
			var dist = _levenshtein_distance(cmd, v_cmd)
			if dist < min_dist:
				min_dist = dist
				best_match = v_cmd
		if min_dist <= 3:
			log_teks.text += "\n[Error]: Perintah tidak ditemukan. Maksud kamu '" + best_match + "'?"
		else:
			log_teks.text += "\n[Error]: Perintah tidak dikenal. Ketik 'help' untuk daftar perintah."

	await get_tree().process_frame
	log_teks.scroll_to_line(log_teks.get_line_count())

func _handle_use_command(target: String):
	match target:
		"flashlight":
			if "senter" in inventory or "flashlight" in inventory:
				senter_player.enabled = !senter_player.enabled
				senter_player.visible = senter_player.enabled
				var status = "ON" if senter_player.enabled else "OFF"
				log_teks.text += "\n[System]: Flashlight " + status + "."
			else:
				log_teks.text += "\n[Error]: Hardware 'flashlight' tidak ada di inventory."
		"tokenkey":
			if "tokenkey" in inventory:
				item_di_tangan.show()
				log_teks.text += "\n[System]: TokenKey disiapkan. Dekati pintu untuk menggunakan."
			else:
				log_teks.text += "\n[Error]: File 'tokenkey' tidak ada di inventory."
		"medkit":
			if "medkit" in inventory:
				# Medkit sekarang memulihkan 1 nyawa jika tidak full
				if nyawa < MAX_NYAWA:
					nyawa += 1
					_update_ui_nyawa()
					hapus_item("medkit")
					log_teks.text += "\n[System]: Medkit digunakan. Nyawa +1 (" + str(nyawa) + "/" + str(MAX_NYAWA) + ")"
				else:
					log_teks.text += "\n[System]: Nyawa sudah penuh!"
			else:
				log_teks.text += "\n[Error]: Item 'medkit' tidak ada di inventory."
		"scanner":
			if "scanner" in inventory:
				log_teks.text += "\n[System]: Scanner aktif. Memindai area sekitar..."
			else:
				log_teks.text += "\n[Error]: Item 'scanner' tidak ada di inventory."
		_:
			log_teks.text += "\n[Error]: Target '" + target + "' tidak dikenal."

func _levenshtein_distance(s1: String, s2: String) -> int:
	var m = s1.length()
	var n = s2.length()
	var d: Array = []
	for i in range(m + 1):
		d.append([])
		d[i].resize(n + 1)
		d[i][0] = i
	for j in range(n + 1):
		d[0][j] = j
	for j in range(1, n + 1):
		for i in range(1, m + 1):
			var cost = 0 if s1[i - 1] == s2[j - 1] else 1
			d[i][j] = min(min(d[i-1][j] + 1, d[i][j-1] + 1), d[i-1][j-1] + cost)
	return d[m][n]

# ==========================================
# 11. NOTIFIKASI LEVEL
# ==========================================
func tampilkan_notif_level(pesan: String):
	if level_notif:
		level_notif.text = pesan
		var tween = get_tree().create_tween()
		level_notif.modulate.a = 0.0
		tween.tween_property(level_notif, "modulate:a", 1.0, 1.5)
		tween.tween_interval(3.0)
		tween.tween_property(level_notif, "modulate:a", 0.0, 1.5)
