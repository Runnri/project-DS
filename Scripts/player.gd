extends CharacterBody2D

# --- PENGATURAN KECEPATAN ---
@export var speed: float = 200.0
@export var sprint_speed: float = 350.0 # Kecepatan saat nahan SHIFT

# --- PENGATURAN STAMINA ---
@export var max_stamina: float = 100.0
var stamina: float = max_stamina
var stamina_drain: float = 40.0 # Kecepatan bar habis saat lari
var stamina_regen: float = 20.0 # Kecepatan bar ngisi saat jalan/diam

# --- NODE ---
@onready var sprite = $AnimatedSprite2D
@onready var stamina_bar = $CanvasLayer/ProgressBar # Memanggil UI Bar

# Variabel memori untuk mengingat arah terakhir
var arah_terakhir: String = "bawah"

func _ready():
	# Setting awal: Stamina penuh saat game mulai
	if stamina_bar:
		stamina_bar.max_value = max_stamina
		stamina_bar.value = stamina

func _physics_process(delta): # Ganti _delta jadi delta buat ngitung waktu
	var direction = Vector2.ZERO
	
	# Deteksi tombol WASD dan Panah secara paksa/langsung
	if Input.is_physical_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_physical_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_physical_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
		direction.x += 1
		
	# Menormalkan arah biar jalan serong nggak lebih cepat
	direction = direction.normalized()
	
	# === SISTEM LARI (SPRINT) & STAMINA ===
	var current_speed = speed
	var is_sprinting = Input.is_physical_key_pressed(KEY_SHIFT)
	
	# Syarat lari: Pencet SHIFT + Stamina masih ada + Sedang bergerak
	if is_sprinting and stamina > 0 and direction != Vector2.ZERO:
		current_speed = sprint_speed
		stamina -= stamina_drain * delta 
		
		# --- TAMBAH BARIS INI: Bikin animasi 1.5x lebih cepat ---
		sprite.speed_scale = 1.8 
		
	else:
		# Kalau nggak lari, stamina ngisi lagi pelan-pelan
		if stamina < max_stamina:
			stamina += stamina_regen * delta
			
		# --- TAMBAH BARIS INI: Kembalikan kecepatan animasi ke normal ---
		sprite.speed_scale = 1.0
	# Kunci stamina biar nggak kurang dari 0 atau lebih dari 100
	stamina = clamp(stamina, 0.0, max_stamina)
	
	# Update tampilan visual bar di layar
	if stamina_bar:
		stamina_bar.value = stamina
	# =======================================
	
	# Logika Jalan & Animasi
	if direction != Vector2.ZERO:
		velocity = direction * current_speed # Pakai current_speed yang bisa berubah
		update_animation(direction)
	else:
		velocity = Vector2.ZERO
		sprite.play("idle_" + arah_terakhir) 
	
	# Eksekusi tabrakan dan gerak
	move_and_slide()

# Fungsi buat milih animasi sesuai arah dan menyimpan "ingatan"
func update_animation(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			sprite.play("kanan")
			arah_terakhir = "kanan" # Ingat menghadap kanan
		else:
			sprite.play("kiri")
			arah_terakhir = "kiri"  # Ingat menghadap kiri
	else:
		if dir.y > 0:
			sprite.play("bawah")
			arah_terakhir = "bawah" # Ingat menghadap bawah
		else:
			sprite.play("atas")
			arah_terakhir = "atas"  # Ingat menghadap atas
