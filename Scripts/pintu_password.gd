extends StaticBody2D

@export var password: String = "1234"

@onready var animasi_pintu   = $AnimatedSprite2D
@onready var collision_pintu = $CollisionShape2D
@onready var canvas_layer    = $CanvasLayer
@onready var line_edit       = $CanvasLayer/Panel/LineEdit
@onready var label_status    = $CanvasLayer/Panel/LabelStatus
@onready var btn_tutup       = $CanvasLayer/Panel/BtnTutup

var sudah_terbuka: bool = false
var player_ref: Node = null
var ui_aktif: bool = false

func _ready():
	add_to_group("pintu_password")
	canvas_layer.hide()
	line_edit.text = ""
	label_status.text = ""
	line_edit.set_editable(true)

	if animasi_pintu.sprite_frames.has_animation("tertutup"):
		animasi_pintu.play("tertutup")
	elif animasi_pintu.sprite_frames.has_animation("idle"):
		animasi_pintu.play("idle")

# ── ESC untuk tutup UI ───────────────────────────────────────
func _input(event: InputEvent) -> void:
	if not ui_aktif:
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_tutup_ui()
		get_viewport().set_input_as_handled()

# ── Tombol X ditekan ─────────────────────────────────────────
func _on_btn_tutup_pressed() -> void:
	_tutup_ui()

# ── Tutup UI tanpa buka pintu (player masih di zona) ─────────
func _tutup_ui() -> void:
	ui_aktif = false
	if player_ref and is_instance_valid(player_ref):
		player_ref.set("frozen", false)
	canvas_layer.hide()
	line_edit.text = ""
	label_status.text = ""

# ── Filter input: angka saja ──────────────────────────────────
func _on_line_edit_text_changed(new_text: String) -> void:
	var hanya_angka = ""
	for c in new_text:
		if c >= "0" and c <= "9":
			hanya_angka += c
	if hanya_angka != new_text:
		line_edit.text = hanya_angka
		line_edit.caret_column = hanya_angka.length()

# ── Player masuk zona ────────────────────────────────────────
func _on_area_2d_body_entered(body: Node2D) -> void:
	if sudah_terbuka or not body.is_in_group("player"):
		return
	player_ref = body
	ui_aktif   = true
	player_ref.set("frozen", true)
	canvas_layer.show()
	line_edit.text = ""
	line_edit.placeholder_text = "_ _ _ _"
	label_status.text = ""
	line_edit.grab_focus()

# ── Player keluar zona ───────────────────────────────────────
func _on_area_2d_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	ui_aktif = false
	if player_ref and is_instance_valid(player_ref):
		player_ref.set("frozen", false)
	player_ref = null
	canvas_layer.hide()
	line_edit.text = ""
	label_status.text = ""

# ── Enter ditekan ────────────────────────────────────────────
func _on_line_edit_text_submitted(new_text: String) -> void:
	if sudah_terbuka:
		return
	if new_text.strip_edges() == password:
		_buka_pintu()
	else:
		line_edit.text = ""
		line_edit.placeholder_text = "_ _ _ _"
		label_status.modulate = Color(1.0, 0.25, 0.2, 1.0)
		label_status.text     = "> PASSWORD SALAH!"
		line_edit.grab_focus()

# ── Buka pintu ───────────────────────────────────────────────
func _buka_pintu() -> void:
	sudah_terbuka = true
	ui_aktif      = false

	if player_ref and is_instance_valid(player_ref):
		player_ref.set("frozen", false)

	collision_pintu.set_deferred("disabled", true)

	if animasi_pintu.sprite_frames.has_animation("terbuka"):
		animasi_pintu.play("terbuka")
	else:
		animasi_pintu.hide()

	canvas_layer.hide()

	# Matikan semua serangga di scene dengan fade out
	for serangga in get_tree().get_nodes_in_group("serangga"):
		if serangga.has_method("matikan"):
			serangga.matikan()
