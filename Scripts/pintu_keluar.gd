extends StaticBody2D

func _ready():
	# Daftarin ke grup supaya tombol bisa nemu pintu ini
	add_to_group("pintu_keluar")

# Fungsi ini bakal dipanggil sama tombol pas puzzle beres
func buka():
	# 1. Matikan tabrakan biar Bit bisa lewat
	# Pakai set_deferred biar gak error pas lagi proses fisika
	$CollisionShape2D.set_deferred("disabled", true)
	
	# 2. Efek memudar (Fade Out)
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.5) # Hilang dalam 0.5 detik
	
	# 3. Hapus pintu dari sistem setelah memudar
	tw.tween_callback(queue_free)
	
	print("[SYSTEM]: Akses diberikan. Pintu terbuka.")
