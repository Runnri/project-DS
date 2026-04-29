extends Area2D

@export var warna_ubin: String = "biru"

@onready var lampu = $Lampu

var warna_visual: Dictionary = {
	"biru":  Color(0.1, 0.4, 1.0, 1),
	"merah": Color(1.0, 0.1, 0.1, 1),
	"hijau": Color(0.1, 0.85, 0.2, 1),
}

func _ready() -> void:
	add_to_group("ubin_puzzle")
	if lampu:
		lampu.color = warna_visual.get(warna_ubin, Color.RED)

# Signal disambung dari Inspector (bukan connect()) — sama seperti LaserJebakan di project ini
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	var manager = get_tree().get_first_node_in_group("puzzle_manager")
	if manager:
		manager.catat_injak(warna_ubin)

func set_lampu(color: Color) -> void:
	if lampu:
		lampu.color = color

func reset_lampu() -> void:
	if lampu:
		lampu.color = warna_visual.get(warna_ubin, Color.RED)
