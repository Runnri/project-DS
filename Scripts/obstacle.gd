extends Area2D

@onready var animasi = $AnimatedSprite2D
@onready var hitbox  = $CollisionShape2D
@onready var timer   = $Timer

var waktu_siklus: float = 8.0
var sedang_menyala: bool = false

func _ready():
	# Hubungkan sinyal timeout (jika belum terhubung di Inspector)
	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)
	matikan_listrik()

func nyalakan_listrik():
	sedang_menyala = true
	animasi.show()
	animasi.play("nyala")
	hitbox.set_deferred("disabled", false)
	timer.start(waktu_siklus)

func matikan_listrik():
	sedang_menyala = false
	animasi.hide()
	hitbox.set_deferred("disabled", true)
	timer.start(waktu_siklus)

func _on_timer_timeout():
	if sedang_menyala:
		matikan_listrik()
	else:
		nyalakan_listrik()

func _on_body_entered(body: Node2D):
	# Gunakan group "player" agar tidak tergantung nama node
	if sedang_menyala and body.is_in_group("player"):
		# Daripada langsung panggil mati(), kita panggil terima_damage()
		if body.has_method("terima_damage"):
			# Hitung 30% dari max HP player saat ini
			var damage = int(body.max_hp * 0.3)
			body.terima_damage(damage)
