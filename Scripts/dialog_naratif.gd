extends CanvasLayer

# ============================================================
# Dialog naratif — kotak teks bawah layar, efek ketikan
# Taruh node ini (dialog_naratif.tscn) di setiap level scene
# dengan nama "DialogNaratif"
# ============================================================

@onready var panel      = $Panel
@onready var label_teks = $Panel/Label

const KECEPATAN_KETIK: float = 0.03   # detik per karakter
const DURASI_TAMPIL:   float = 3.0    # detik setelah selesai mengetik

var _teks_penuh:  String = ""
var _idx:         int    = 0
var _timer_hapus: float  = 0.0
var _sedang_hitung: bool = false
var _selesai_ketik: bool = false

func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	panel.hide()

func tampilkan(teks: String) -> void:
	_teks_penuh    = teks
	_idx           = 0
	_sedang_hitung = false
	_selesai_ketik = false
	label_teks.text = ""
	panel.show()
	panel.modulate.a = 1.0
	# Mulai efek ketikan via Timer loop
	_ketik_karakter()

func _ketik_karakter() -> void:
	if _idx >= _teks_penuh.length():
		# Selesai mengetik — mulai countdown untuk menutup
		_selesai_ketik = true
		_sedang_hitung = true
		_timer_hapus   = DURASI_TAMPIL
		return

	label_teks.text += _teks_penuh[_idx]
	_idx += 1
	await get_tree().create_timer(KECEPATAN_KETIK, true).timeout
	_ketik_karakter()

func _process(delta: float) -> void:
	if not _sedang_hitung:
		return

	_timer_hapus -= delta
	if _timer_hapus <= 0.0:
		_sedang_hitung = false
		# Fade out panel
		var tw = create_tween()
		tw.tween_property(panel, "modulate:a", 0.0, 0.4)
		tw.tween_callback(panel.hide)

func _input(event: InputEvent) -> void:
	if not panel.visible:
		return
	# Klik kiri atau SPACE = skip efek ketikan / tutup lebih cepat
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_skip()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		_skip()

func _skip() -> void:
	if not _selesai_ketik:
		# Skip ketikan — tampilkan semua langsung
		label_teks.text = _teks_penuh
		_idx = _teks_penuh.length()
		_selesai_ketik = true
		_sedang_hitung = true
		_timer_hapus   = DURASI_TAMPIL
	else:
		# Skip delay — tutup sekarang
		_sedang_hitung = false
		panel.hide()
