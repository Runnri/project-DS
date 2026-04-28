extends Node2D

@export var tekstur_mayat: Texture2D
@export var jumlah_mayat: int = 1500
@export var lebar_gunung: float = 900.0   # lebar total gunung kiri-kanan
@export var tinggi_gunung: float = 350.0  # tinggi puncak gunung dari dasar
@export var tebal_tumpukan: float = 80.0  # ketebalan lapisan mayat di permukaan

func _ready() -> void:
	if not tekstur_mayat:
		push_error("[TUMPUKAN MAYAT]: Tekstur belum di-assign!")
		return

	var quad = QuadMesh.new()
	var ukuran_sprite = Vector2(
		tekstur_mayat.get_width(),
		tekstur_mayat.get_height()
	) * 1.2
	quad.size = ukuran_sprite

	var mmesh = MultiMesh.new()
	mmesh.transform_format = MultiMesh.TRANSFORM_2D
	mmesh.use_colors        = false
	mmesh.use_custom_data   = false
	mmesh.mesh              = quad
	mmesh.instance_count    = jumlah_mayat

	for i in jumlah_mayat:
		# Posisi X acak sepanjang lebar gunung
		var x = randf_range(-lebar_gunung * 0.5, lebar_gunung * 0.5)

		# Hitung tinggi permukaan gunung di titik X ini
		# Pakai fungsi segitiga: makin ke tengah makin tinggi
		var t_norm = abs(x) / (lebar_gunung * 0.5)          # 0.0 di tengah, 1.0 di tepi
		var permukaan_y = -tinggi_gunung * (1.0 - t_norm)   # negatif = ke atas

		# Posisi Y acak dalam lapisan tipis di atas permukaan gunung
		var y = permukaan_y + randf_range(-tebal_tumpukan * 0.3, tebal_tumpukan * 0.7)

		# Rotasi sedikit — mayat mengikuti kemiringan gunung
		var kemiringan = atan2(tinggi_gunung, lebar_gunung * 0.5)
		var sisi = sign(x)  # -1 kiri, +1 kanan
		var rot_dasar = sisi * kemiringan * (t_norm)         # lebih miring di tepi
		var rot = rot_dasar + randf_range(-0.2, 0.2)         # sedikit variasi acak

		var s = randf_range(0.85, 1.15)
		var tr = Transform2D(rot, Vector2(x, y))
		tr = tr.scaled(Vector2(s, s))
		mmesh.set_instance_transform_2d(i, tr)

	var mmi = MultiMeshInstance2D.new()
	mmi.multimesh = mmesh
	mmi.texture   = tekstur_mayat
	add_child(mmi)

	print("[TUMPUKAN MAYAT]: ", jumlah_mayat, " mayat berbentuk gunung, 1 draw call.")
