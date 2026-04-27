extends Area2D

@onready var sprite = $AnimatedSprite2D
@onready var dialog_ui = $DialogUI
@onready var teks_dialog = $DialogUI/BgDialog/TeksDialog

var sudah_bicara: bool = false
var baris_sekarang: int = 0

# Taruh semua dialognya di sini, berurutan dari atas ke bawah
var dialog_lines: Array = [
	"Dengarkan aku... aku sudah disini lebih dulu.",
	"Lorong kanan. Itu Recycle Bin.",
	"Tidak ada yang tau apa yang terjadi jika kamu masuk ke Recycle Bin...",
	"Sudah tidak ada jalan keluar lagi....",
	"Lorong kiri adalah data corrupt",
	"Kalo kamu masuk kesana datamu akan corrupt, hancur!",
	"aku..aku sudah tidak tau lagi harus kemana..",
	"Sudah tidak ada jalan keluar lagi :("
]

func _ready():
	dialog_ui.hide()
	sprite.play("idle")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if not sudah_bicara and body.is_in_group("player"):
		sudah_bicara = true
		
		# 1. Kunci pergerakan player biar gak bisa jalan
		body.frozen = true 
		
		sprite.play("ngobrol")
		dialog_ui.show()
		
		# 2. Mulai putar dialog dari baris pertama (index 0)
		_putar_dialog_selanjutnya(body)

func _putar_dialog_selanjutnya(player_node: Node2D):
	# Cek apakah masih ada sisa dialog
	if baris_sekarang < dialog_lines.size():
		var teks_aktif = dialog_lines[baris_sekarang]
		
		# Set teks ke label, tapi sembunyikan semua hurufnya (0)
		teks_dialog.text = teks_aktif
		teks_dialog.visible_characters = 0 
		
		# Hitung durasi ngetik biar stabil (misal 0.05 detik per huruf)
		var durasi_ngetik = teks_aktif.length() * 0.05
		
		# Mainkan efek ketikan per huruf
		var tween = get_tree().create_tween()
		tween.tween_property(teks_dialog, "visible_characters", teks_aktif.length(), durasi_ngetik)
		
		# Tunggu sampai efek ngetik beres
		await tween.finished
		
		# Tunggu 2 detik biar player sempat baca sebelum lanjut ke baris berikutnya
		await get_tree().create_timer(2.0).timeout 
		
		baris_sekarang += 1
		_putar_dialog_selanjutnya(player_node) # Putar lagi untuk baris berikutnya
		
	else:
		# 3. SEMUA DIALOG SELESAI
		dialog_ui.hide()
		sprite.play("idle")
		
		# Lepas kunci player biar bisa jalan lagi
		player_node.frozen = false 
	
