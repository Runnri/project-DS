extends CharacterBody2D

# Kecepatan gerak si Bit
@export var speed: float = 200.0

# Ngambil animasi
@onready var sprite = $AnimatedSprite2D

# Variabel memori untuk mengingat arah terakhir (defaultnya bawah)
var arah_terakhir: String = "bawah"

func _physics_process(_delta):
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
	
	# Logika Jalan & Animasi
	if direction != Vector2.ZERO:
		velocity = direction * speed
		update_animation(direction)
	else:
		velocity = Vector2.ZERO
		# --- BAGIAN BARU: Memutar idle sesuai arah terakhir ---
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
