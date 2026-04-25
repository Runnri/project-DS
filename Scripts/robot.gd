extends CharacterBody2D

@export var speed_wander: float = 60.0
@export var speed_chase: float = 130.0


@onready var sprite = $AnimatedSprite2D
@onready var timer_wander = $TimerWander
@onready var mata_laser = $MataLaser

var state: String = "WANDER"
var arah_wander: Vector2 = Vector2.ZERO
var player_target = null
var waktu_ingatan: float = 0.0
var posisi_terakhir_player: Vector2 = Vector2.ZERO

func _ready():
	add_to_group("musuh")
	mata_laser.add_exception(self) # PENTING: Biar laser nggak nabrak badan robot itu sendiri!
	pilih_arah_acak()
	
	timer_wander.timeout.connect(_on_timer_wander_timeout)

func _physics_process(delta):
	if state == "CHASE" and player_target and is_instance_valid(player_target):
		# 1. Update Laser
		mata_laser.target_position = to_local(player_target.global_position)
		mata_laser.force_raycast_update()
		
		var kehalang_tembok = false
		if mata_laser.is_colliding():
			var benda_ditabrak = mata_laser.get_collider()
			if not benda_ditabrak.is_in_group("player"):
				kehalang_tembok = true
				
		# 2. LOGIKA INGATAN & KEJAR
		if not kehalang_tembok:
			# MELIHAT BIT: Kejar dan catat di memori!
			posisi_terakhir_player = player_target.global_position
			waktu_ingatan = 3.0 # Ingat posisi ini selama 3 detik
			
			var arah_ke_player = (player_target.global_position - global_position).normalized()
			velocity = arah_ke_player * speed_chase
			_atur_animasi(arah_ke_player)
			
		else:
			# KEHALANG TEMBOK: Cek apakah masih punya ingatan
			if waktu_ingatan > 0:
				waktu_ingatan -= delta # Waktu ingatan terus berkurang
				
				# Lari ke posisi terakhir Bit terlihat (bukan posisi Bit sekarang)
				var arah_ke_ingatan = (posisi_terakhir_player - global_position).normalized()
				velocity = arah_ke_ingatan * speed_chase
				_atur_animasi(arah_ke_ingatan)
				
				# ANTI-NYANGKUT: Kalau sudah sampai di titik itu, ATAU nabrak tembok, langsung lupakan!
				if global_position.distance_to(posisi_terakhir_player) < 10.0 or is_on_wall():
					waktu_ingatan = 0.0
			else:
				# LUPA: Waktu habis, Bit beneran hilang. Balik keliling labirin.
				velocity = arah_wander * speed_wander
				_atur_animasi(arah_wander)
				if is_on_wall():
					pilih_arah_acak()
	else:
		# --- MODE KELILING LABIRIN (Bit benar-benar di luar jangkauan radar) ---
		velocity = arah_wander * speed_wander
		_atur_animasi(arah_wander)
		
		if is_on_wall():
			pilih_arah_acak()

	move_and_slide()

# Fungsi untuk mencari jalan baru
func pilih_arah_acak():
	# Bikin arah acak (X dan Y diacak antara -1 sampai 1)
	var x = randf_range(-1.0, 1.0)
	var y = randf_range(-1.0, 1.0)
	arah_wander = Vector2(x, y).normalized()
	
	# Atur waktu kapan dia mau belok lagi (acak antara 2 sampai 4 detik)
	timer_wander.start(randf_range(2.0, 4.0))

func _on_timer_wander_timeout():
	# Kalau waktunya habis, ganti arah jalan walau gak nabrak dinding
	if state == "WANDER":
		pilih_arah_acak()

# Fungsi buat ngatur gambar hadap kanan/kiri
func _atur_animasi(arah: Vector2):
	# Sesuaikan "robot_kanan" dengan nama animasimu
	if arah.x > 0.1:
		sprite.play("robot_kanan") 
		sprite.flip_h = false # Menghadap kanan asli
	elif arah.x < -0.1:
		sprite.play("robot_kanan")
		sprite.flip_h = true  # Dibalik jadi menghadap kiri

# ==========================================
# JANGAN LUPA SAMBUNGKAN 3 SINYAL DI BAWAH INI LEWAT EDITOR!
# ==========================================

# 1. Dari ZonaDeteksi -> body_entered
func _on_zona_deteksi_body_entered(body):
	if body.is_in_group("player"):
		player_target = body
		state = "CHASE"

# 2. Dari ZonaDeteksi -> body_exited
func _on_zona_deteksi_body_exited(body):
	if body == player_target:
		player_target = null
		state = "WANDER"
		pilih_arah_acak() # Balik keliling lagi

# 3. Dari Hitbox -> body_entered (Buat bunuh player)
func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("mati"):
			body.mati()
