extends Node2D

@export var tekstur_mayat: Texture2D
@export var jumlah_mayat: int = 1500
@export var lebar_gunung: float = 1000.0
@export var tinggi_gunung: float = 300.0
@export var tebal_lapisan: float = 50.0

func _ready() -> void:
	if not tekstur_mayat:
		push_error("[TUMPUKAN MAYAT]: Tekstur belum di-assign!")
		return

	var quad = QuadMesh.new()
	quad.size = Vector2(
		tekstur_mayat.get_width(),
		tekstur_mayat.get_height()
	) * 1.2

	var mmesh = MultiMesh.new()
	mmesh.transform_format = MultiMesh.TRANSFORM_2D
	mmesh.use_colors       = false
	mmesh.use_custom_data  = false
	mmesh.mesh             = quad
	mmesh.instance_count   = jumlah_mayat

	for i in jumlah_mayat:
		# X tersebar sepanjang lebar gunung
		var x = randf_range(-lebar_gunung * 0.5, lebar_gunung * 0.5)

		# Normalisasi x: 0.0 di tengah, 1.0 di tepi
		var nx = abs(x) / (lebar_gunung * 0.5)

		# Tinggi permukaan gunung di titik x — pakai cosinus agar lebih smooth
		# cos(0) = 1 (puncak), cos(PI/2) = 0 (tepi)
		var permukaan = -tinggi_gunung * cos(nx * PI * 0.5)

		# Y acak dalam lapisan tipis DI permukaan gunung
		var y = permukaan + randf_range(0.0, tebal_lapisan)

		# Rotasi mengikuti kemiringan sisi gunung
		var kemiringan = sign(x) * nx * 0.5
		var rot = kemiringan + randf_range(-0.15, 0.15)

		var s = randf_range(0.9, 1.1)
		var tr = Transform2D(rot, Vector2(x, y))
		tr = tr.scaled(Vector2(s, s))
		mmesh.set_instance_transform_2d(i, tr)

	var mmi = MultiMeshInstance2D.new()
	mmi.multimesh = mmesh
	mmi.texture   = tekstur_mayat
	add_child(mmi)
