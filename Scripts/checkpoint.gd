extends Area2D

# Variabel untuk mengecek apakah checkpoint ini sudah aktif
var is_active = false

@onready var sprite = $AnimatedSprite2D
@onready var lampu_cahaya = $PointLight2D # Jika kamu pakai PointLight2D

func _ready():
	# Pastikan saat mulai, lampu dalam keadaan mati
	sprite.play("mati")
	if lampu_cahaya:
		lampu_cahaya.enabled = false
	
	# Hubungkan sinyal jika player masuk ke area
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Cek apakah yang masuk adalah Player dan checkpoint belum aktif
	if not is_active and body.has_method("update_checkpoint"):
		is_active = true
		
		# Nyalakan lampu secara visual
		sprite.play("nyala")
		if lampu_cahaya:
			lampu_cahaya.enabled = true
			
		# Panggil fungsi di player untuk memindahkan titik spawn
		body.update_checkpoint(global_position)
