extends StaticBody2D

# ==========================================
# PINTU KODE — input digit, buka pintu,
# terangkan area, matikan semua serangga
# ==========================================

# Kode yang harus dimasukkan player (set dari Inspector)
@export var kode_benar: String = "1234"

# Node CanvasModulate di scene (diisi dari Inspector via NodePath)
@export var canvas_modulate_path: NodePath = NodePath("")

# Apakah setelah terbuka, hanya serangga di group ini yang dimatikan?
# Kosongkan = matikan SEMUA serangga di scene
@export var group_serangga: String = "serangga"

@onready var animasi_pintu   = $AnimatedSprite2D
@onready var collision_tembok = $CollisionShape2D
@onready var sensor           = $SensorPintu
@onready var ui_kode          = $CanvasLayer/UIKode
@onready var input_kode       = $CanvasLayer/UIKode/Panel/VBox/InputKode
@onready var label_status     = $CanvasLayer/UIKode/Panel/VBox/LabelStatus
@onready var label_petunjuk   = $CanvasLayer/UIKode/Panel/VBox/LabelPetunjuk

var sudah_terbuka: bool = false
var player_di_sensor: Node = null

func _ready():
	ui_kode.hide()
	if animasi_pintu.sprite_frames.has_animation("idle"):
		animasi_pintu.play("idle")

func _input(event):
	# Buka/tutup UI kode dengan F saat player di dekat pintu
	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		if player_di_sensor and not sudah_terbuka and not ui_kode.visible:
			_tampilkan_ui()
		elif ui_kode.visible:
			_sembunyikan_ui()

# ---- UI INPUT KODE ----
func _tampilkan_ui():
	ui_kode.show()
	input_kode.text = ""
	label_status.text = ""
	label_petunjuk.text = "> MASUKKAN KODE " + str(kode_benar.length()) + " DIGIT :"
	input_kode.grab_focus()
	get_tree().paused = true

func _sembunyikan_ui():
	ui_kode.hide()
	input_kode.release_focus()
	get_tree().paused = false

func _on_input_kode_submitted(teks: String):
	var input = teks.strip_edges()

	if input == kode_benar:
		label_status.modulate = Color(0.2, 1.0, 0.5, 1.0)
		label_status.text = "> ACCESS GRANTED. OPENING..."
		input_kode.editable = false
		await get_tree().create_timer(0.8, true).timeout
		_sembunyikan_ui()
		_buka_pintu()
	else:
		label_status.modulate = Color(1.0, 0.25, 0.2, 1.0)
		label_status.text = "> ACCESS DENIED. CODE INVALID."
		input_kode.text = ""
		# Getar ringan pada panel
		var panel = $CanvasLayer/UIKode/Panel
		var tween = create_tween()
		tween.tween_property(panel, "position:x", panel.position.x + 6, 0.05)
		tween.tween_property(panel, "position:x", panel.position.x - 6, 0.05)
		tween.tween_property(panel, "position:x", panel.position.x, 0.05)

func _buka_pintu():
	sudah_terbuka = true

	# Buka fisik pintu
	collision_tembok.set_deferred("disabled", true)
	if animasi_pintu.sprite_frames.has_animation("buka"):
		animasi_pintu.play("buka")
	else:
		animasi_pintu.hide()

	# Terangkan area via CanvasModulate
	_nyalakan_cahaya()

	# Matikan semua serangga
	await get_tree().create_timer(0.3).timeout
	_matikan_serangga()

func _nyalakan_cahaya():
	var canvas_mod: CanvasModulate = null

	# Coba ambil via NodePath yang di-set di Inspector
	if canvas_modulate_path != NodePath(""):
		canvas_mod = get_node_or_null(canvas_modulate_path)

	# Fallback: cari di scene root
	if canvas_mod == null:
		canvas_mod = get_tree().current_scene.get_node_or_null("CanvasModulate")

	if canvas_mod == null:
		push_warning("[PintuKode]: CanvasModulate tidak ditemukan.")
		return

	# Fade dari gelap ke terang
	canvas_mod.visible = true
	var tween = create_tween()
	tween.tween_property(canvas_mod, "color", Color(1, 1, 1, 1), 1.5)

func _matikan_serangga():
	var semua_serangga = get_tree().get_nodes_in_group(group_serangga)
	for s in semua_serangga:
		if s.has_method("matikan"):
			s.matikan()

# ---- SENSOR AREA (player mendekat) ----
func _on_sensor_pintu_body_entered(body):
	if body.is_in_group("player"):
		player_di_sensor = body
		if body.log_teks and not sudah_terbuka:
			body.log_teks.text += "\n[SYSTEM]: Pintu terdeteksi. Tekan [F] untuk input kode."

func _on_sensor_pintu_body_exited(body):
	if body == player_di_sensor:
		player_di_sensor = null
		if ui_kode.visible:
			_sembunyikan_ui()

func _on_konfirmasi_pressed():
	_on_input_kode_submitted(input_kode.text)
