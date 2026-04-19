extends Camera2D

# --- PENGATURAN ZOOM ---
var kecepatan_zoom: float = 0.1
var zoom_minimal: float = 0.5  # Makin kecil angkanya, makin jauh kameranya
var zoom_maksimal: float = 1.5 # Makin besar angkanya, makin dekat kameranya (nge-zoom)

func _input(event):
	# Mengecek apakah input berasal dari mouse
	if event is InputEventMouseButton and event.is_pressed():
		
		# Mengambil ukuran zoom saat ini (X dan Y sama saja, kita ambil X)
		var target_zoom = zoom.x
		
		# Kalau scroll ke ATAS (Zoom In / Mendekat)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom += kecepatan_zoom
			
		# Kalau scroll ke BAWAH (Zoom Out / Menjauh)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom -= kecepatan_zoom
			
		# clamp() berguna untuk membatasi angka agar tidak melebihi batas minimal dan maksimal
		target_zoom = clamp(target_zoom, zoom_minimal, zoom_maksimal)
		
		# Menerapkan zoom baru ke kamera
		zoom = Vector2(target_zoom, target_zoom)
