extends Area2D

@export var warna_ubin: String = "biru"

@onready var lampu = get_node_or_null("Lampu")

func _ready() -> void:
	add_to_group("ubin_puzzle")
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	set_lampu("asal")

func _on_body_entered(_body: Node2D) -> void:
	if not _body.is_in_group("player"):
		return
	var manager = get_tree().get_root().find_child("PuzzleManager", true, false)
	if manager:
		manager.terima_input(warna_ubin)

func set_lampu(state: String) -> void:
	if not lampu:
		return
	var warna := Color.GRAY
	match state:
		"asal":
			match warna_ubin:
				"biru":  warna = Color.BLUE
				"merah": warna = Color.RED
				"hijau": warna = Color.GREEN
		"benar":  warna = Color.WHITE
		"hitam":  warna = Color.BLACK
		"selesai": warna = Color.YELLOW

	if lampu is ColorRect:
		lampu.color = warna
	else:
		lampu.modulate = warna
