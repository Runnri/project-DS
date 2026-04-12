extends CharacterBody2D

# --- PENGATURAN KECEPATAN ---
@export var speed: float = 200.0
@export var sprint_speed: float = 350.0

# --- PENGATURAN STAMINA ---
@export var max_stamina: float = 100.0
var stamina: float = max_stamina
var stamina_drain: float = 40.0
var stamina_regen: float = 20.0

# --- DATA SYSTEM & INVENTORY ---
var inventory = [] 
@export var max_inventory: int = 3
var arah_terakhir: String = "bawah"

# --- NODE REFERENCES ---
@onready var sprite = $AnimatedSprite2D
@onready var stamina_bar = $CanvasLayer/ProgressBar
@onready var terminal = $CanvasLayer/CMD
@onready var input_cmd = $CanvasLayer/CMD/LineEdit
@onready var notif_dot = $CanvasLayer/IconCMD/NotifDot
@onready var log_teks = $CanvasLayer/CMD/LogTeks 
@onready var senter_player = $SenterPlayer
@onready var interact_box = $InteractBox
@onready var prompt_f = $F

# --- DATABASE TERMINAL ---
var valid_commands = ["use flashlight", "use medkit", "use scanner", "help", "clear", "inventory"]
var item_descriptions = {
	"flashlight": "Alat penerangan portabel, menggunakan baterai A3.",
	"medkit": "P3K standar untuk pertolongan pertama memulihkan HP.",
	"scanner": "Alat pemindai anomali dan blueprint area sekitar."
}

func _ready():
	if stamina_bar:
		stamina_bar.max_value = max_stamina
		stamina_bar.value = stamina
	
	terminal.hide()
	notif_dot.hide()
	senter_player.enabled = false
	
	# Menghubungkan signal untuk ketikan CMD saat enter
	if not input_cmd.text_submitted.is_connected(_on_cmd_submitted):
		input_cmd.text_submitted.connect(_on_cmd_submitted)

func _physics_process(delta):
	if terminal.visible:
		velocity = Vector2.ZERO
		sprite.play("idle_" + arah_terakhir)
		move_and_slide()
		return

	var direction = Vector2.ZERO
	
	if Input.is_physical_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"): direction.y -= 1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"): direction.y += 1
	if Input.is_physical_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"): direction.x -= 1
	if Input.is_physical_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"): direction.x += 1
		
	direction = direction.normalized()
	
	var current_speed = speed
	var is_sprinting = Input.is_physical_key_pressed(KEY_SHIFT)
	
	if is_sprinting and stamina > 0 and direction != Vector2.ZERO:
		current_speed = sprint_speed
		stamina -= stamina_drain * delta
		sprite.speed_scale = 1.8 
	else:
		if stamina < max_stamina: stamina += stamina_regen * delta
		sprite.speed_scale = 1.0

	stamina = clamp(stamina, 0.0, max_stamina)
	if stamina_bar: stamina_bar.value = stamina
	
	if direction != Vector2.ZERO:
		velocity = direction * current_speed
		update_animation(direction)
	else:
		velocity = Vector2.ZERO
		sprite.play("idle_" + arah_terakhir) 
	
	move_and_slide()
	# --- SISTEM MUNCULIN LOGO [F] OTOMATIS ---
	var bisa_interaksi = false
	var benda_sekitar = interact_box.get_overlapping_areas()
	
	# Godot akan ngecek, ada nggak barang yang bisa di-"interaksi" di dekat si Bit?
	for benda in benda_sekitar:
		if benda.has_method("interaksi"):
			bisa_interaksi = true
			break # Kalau ketemu 1 aja, langsung berhenti nyari
			
	# Kalau ada barang, munculkan [F]. Kalau nggak ada, sembunyikan.
	if bisa_interaksi == true:
		prompt_f.show()
	else:
		prompt_f.hide()

# --- FUNGSI ANIMASI ---
func update_animation(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0: sprite.play("kanan"); arah_terakhir = "kanan"
		else: sprite.play("kiri"); arah_terakhir = "kiri"
	else:
		if dir.y > 0: sprite.play("bawah"); arah_terakhir = "bawah"
		else: sprite.play("atas"); arah_terakhir = "atas"

# --- FUNGSI BUKA/TUTUP TERMINAL ---
func _input(event):
	# Kembali menggunakan tombol TAB
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		if terminal.visible:
			terminal.hide()
			input_cmd.release_focus()
		else:
			terminal.show()
			input_cmd.text = "" # Membersihkan sisa ketikan saat CMD dibuka lagi
			input_cmd.grab_focus()
			notif_dot.hide()
		
		# Menelan input TAB agar tidak tertulis masuk ke dalam LineEdit
		get_viewport().set_input_as_handled()
		
		# --- FITUR INTERAKSI (TOMBOL F) ---
	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		# Cari semua benda yang masuk ke dalam InteractBox
		var benda_sekitar = interact_box.get_overlapping_areas()
		
		for benda in benda_sekitar:
			# Cek apakah benda itu punya script yang ada fungsi "interaksi"-nya
			if benda.has_method("interaksi"):
				benda.interaksi(self) # Lakukan interaksi dan kirim data si Bit ke benda tersebut
				break # Stop looping, biar cuma 1 barang yang diambil per pencet F

# --- FUNGSI INVENTORY & NOTIFIKASI ---
func tambah_item(nama_barang: String) -> bool:
	if inventory.size() < max_inventory:
		inventory.append(nama_barang.to_lower())
		notif_dot.show()
		
		if log_teks:
			log_teks.text += "\n[SYSTEM]: U got new item (" + nama_barang + ")!"
			log_teks.text += "\n[SYSTEM]: Please type 'use [item_name]' to activate."
		return true
	return false

# ========================================================
# --- FITUR HACKER TERMINAL: COMMAND EKSEKUSI ---
# ========================================================

# Fungsi saat menekan ENTER
func _on_cmd_submitted(new_text: String):
	var cmd = new_text.to_lower().strip_edges()
	if cmd == "": return
	
	log_teks.text += "\n\n> " + cmd
	input_cmd.clear()
	
	var parts = cmd.split(" ")
	var action = parts[0]
	var target = ""
	if parts.size() > 1: target = parts[1]
	
	# --- EKSEKUSI PERINTAH ---
	if cmd in valid_commands or action == "help":
		
		if action == "use":
			if target == "flashlight":
				if "senter" in inventory or "flashlight" in inventory:
					senter_player.enabled = !senter_player.enabled
					
					senter_player.visible = senter_player.enabled
					# Hanya menampilkan "true" atau "false"
					log_teks.text += "\n" + str(senter_player.enabled).to_lower()
				else:
					log_teks.text += "\n[Error]: Hardware 'flashlight' not found in inventory."
			
			elif target == "medkit" or target == "scanner":
				log_teks.text += "\n[System]: " + target.capitalize() + " deployed."
				
		elif action == "help":
			if target != "" and item_descriptions.has(target):
				log_teks.text += "\n[Info] " + target + ": " + item_descriptions[target]
			else:
				log_teks.text += "\n[Available Commands]:\n- " + "\n- ".join(PackedStringArray(valid_commands))
				
		elif action == "ls":
			log_teks.text += "\n[Inventory]: " + str(inventory)
			
		elif action == "clear":
			log_teks.text = "--- BIT TERMINAL ---"
			
	else:
		# --- ERROR HANDLING (DID YOU MEAN?) ---
		var best_match = ""
		var min_dist = 999
		
		for v_cmd in valid_commands:
			var dist = _levenshtein_distance(cmd, v_cmd)
			if dist < min_dist:
				min_dist = dist
				best_match = v_cmd
		
		if min_dist <= 3:
			log_teks.text += "\n[Error]: Command not found. Did you mean '" + best_match + "'?"
		else:
			log_teks.text += "\n[Error]: Unknown command. Type 'help' for options."
			
	# Auto-scroll ke bawah
	await get_tree().process_frame
	log_teks.scroll_to_line(log_teks.get_line_count())

# Rumus Matematika untuk menghitung kemiripan kata (Levenshtein Distance)
func _levenshtein_distance(s1: String, s2: String) -> int:
	var m = s1.length()
	var n = s2.length()
	var d = []
	for i in range(m + 1):
		d.append([])
		d[i].resize(n + 1)
		d[i][0] = i
	for j in range(n + 1):
		d[0][j] = j
	for j in range(1, n + 1):
		for i in range(1, m + 1):
			var cost = 0 if s1[i - 1] == s2[j - 1] else 1
			d[i][j] = min(min(d[i - 1][j] + 1, d[i][j - 1] + 1), d[i - 1][j - 1] + cost)
	return d[m][n]
