extends CharacterBody2D

# ==========================================
# 1. VARIABEL PENGATURAN UMUM
# ==========================================
@export var speed: float = 200.0
@export var sprint_speed: float = 350.0
@export var max_stamina: float = 100.0
@export var max_hp: int = 100
@export var max_inventory: int = 3
@onready var item_di_tangan = $ItemDiTangan

# ==========================================
# 2. STATUS PLAYER (Berubah saat bermain)
# ==========================================
var stamina: float = max_stamina
var stamina_drain: float = 40.0
var stamina_regen: float = 20.0
var hp: int = max_hp
var is_dead: bool = false
var spawn_point: Vector2
var inventory: Array = []
var arah_terakhir: String = "bawah"

# ==========================================
# 3. KONEKSI KE NODE (UI & Sensor)
# ==========================================
@onready var sprite       = $AnimatedSprite2D
@onready var stamina_bar  = $CanvasLayer/ProgressBar
@onready var hp_bar       = $CanvasLayer/HpBar
@onready var terminal     = $CanvasLayer/CMD
@onready var input_cmd    = $CanvasLayer/CMD/LineEdit
@onready var notif_dot    = $CanvasLayer/IconCMD/NotifDot
@onready var log_teks     = $CanvasLayer/CMD/LogTeks
@onready var senter_player = $SenterPlayer
@onready var interact_box  = $InteractBox
@onready var prompt_f      = $F
@onready var level_notif   = $CanvasLayer/LevelNotif

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
	# Player tidak ikut membeku saat game di-pause
	self.process_mode = Node.PROCESS_MODE_ALWAYS

	# Tambahkan ke group agar trigger_level.gd bisa mengenali player
	add_to_group("player")

	# Simpan posisi awal sebagai spawn point default
	spawn_point = global_position

	# Setup awal UI Stamina & HP
	if stamina_bar:
		stamina_bar.max_value = max_stamina
		stamina_bar.value = stamina
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = hp

	terminal.hide()
	notif_dot.hide()
	senter_player.enabled = false
	prompt_f.hide()

	# Hubungkan tombol Enter ke fungsi CMD
	if not input_cmd.text_submitted.is_connected(_on_cmd_submitted):
		input_cmd.text_submitted.connect(_on_cmd_submitted)

	# === FITUR LOAD GAME ===
	# Jika pemain memilih "Load Game" dari menu, terapkan data save ke player ini
	if Global.sedang_load:
		Global.muat_game(self)

# ==========================================
# 6. PERGERAKAN & FISIKA
# ==========================================
func _physics_process(delta):
	if is_dead:
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

# ==========================================
# 7. INPUT (Deteksi Tombol Keyboard)
# ==========================================
func _input(event):
	if is_dead:
		return

	# BUKA/TUTUP TERMINAL (TAB)
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
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

	# INTERAKSI (F)
	if event is InputEventKey and event.pressed and event.keycode == KEY_F and not terminal.visible:
		var benda_sekitar = interact_box.get_overlapping_areas()
		for benda in benda_sekitar:
			if benda.has_method("interaksi"):
				benda.interaksi(self)
				break

# ==========================================
# 8. SISTEM KESEHATAN
# ==========================================
func terima_damage(jumlah: int):
	if is_dead:
		return

	hp -= jumlah
	hp = max(hp, 0)  # Cegah HP minus

	if hp_bar:
		hp_bar.value = hp

	if log_teks:
		log_teks.text += "\n[WARNING]: System Damaged! HP: " + str(hp)

	if hp <= 0:
		mati()

func mati():
	is_dead = true
	velocity = Vector2.ZERO
	get_tree().paused = true

	if terminal.visible:
		terminal.hide()

	if sprite.sprite_frames.has_animation("mati"):
		sprite.play("mati")
		await sprite.animation_finished
	else:
		if log_teks:
			log_teks.text += "\n[Error]: Animation 'mati' not found."

	if log_teks:
		log_teks.text += "\n[FATAL ERROR]: System Purged. Rebooting..."

	# Timer tetap jalan saat pause (parameter kedua = true)
	await get_tree().create_timer(1.0, true).timeout

	respawn()

func respawn():
	global_position = spawn_point

	hp = max_hp
	if hp_bar:
		hp_bar.value = hp

	stamina = max_stamina
	if stamina_bar:
		stamina_bar.value = stamina

	is_dead = false
	sprite.play("idle_" + arah_terakhir)
	get_tree().paused = false

	if log_teks:
		log_teks.text += "\n[SYSTEM]: Reboot Successful. Cache restored."

func update_checkpoint(posisi_baru: Vector2):
	spawn_point = posisi_baru
	if log_teks:
		log_teks.text += "\n[SYSTEM]: Sector recovery complete. New checkpoint cached."

# ==========================================
# 9. FUNGSI PENDUKUNG (Animasi, Interaksi, Item)
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
# 10. TERMINAL: LOGIKA KETIKAN
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
			"ls":
				if inventory.is_empty():
					log_teks.text += "\n[Inventory]: (kosong)"
				else:
					log_teks.text += "\n[Inventory]: " + str(inventory)
			"clear":
				log_teks.text = "--- BIT TERMINAL ---"
			"killme":
				terima_damage(max_hp)
	else:
		# Auto-correction Typo (Levenshtein)
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
				var hp_sebelum = hp
				hp = min(hp + 50, max_hp)
				hapus_item("medkit")
				if hp_bar: hp_bar.value = hp
				log_teks.text += "\n[System]: Medkit digunakan. HP: " + str(hp_sebelum) + " -> " + str(hp)
			else:
				log_teks.text += "\n[Error]: Item 'medkit' tidak ada di inventory."
		"scanner":
			if "scanner" in inventory:
				log_teks.text += "\n[System]: Scanner aktif. Memindai area sekitar..."
				# TODO: implementasi efek scan
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
# 11. NOTIFIKASI LEVEL (FADE IN/OUT)
# ==========================================
func tampilkan_notif_level(pesan: String):
	if level_notif:
		level_notif.text = pesan
		var tween = get_tree().create_tween()
		level_notif.modulate.a = 0.0
		tween.tween_property(level_notif, "modulate:a", 1.0, 1.5)
		tween.tween_interval(3.0)
		tween.tween_property(level_notif, "modulate:a", 0.0, 1.5)
