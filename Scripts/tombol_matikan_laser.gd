extends Area2D

@onready var lampu = $Lampu

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if lampu:
		lampu.color = Color.RED

func _on_body_entered(body):
	if body.is_in_group("balok"):
		if lampu:
			lampu.color = Color.GREEN
		for laser in get_tree().get_nodes_in_group("laser_pinggir"):
			laser.matikan()

func _on_body_exited(body):
	if body.is_in_group("balok"):
		if lampu:
			lampu.color = Color.RED
		# Balok keluar → laser nyala lagi
		for laser in get_tree().get_nodes_in_group("laser_pinggir"):
			laser.nyalakan()
