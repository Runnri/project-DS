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
		
		# Perintah munculin laser
		var jebakan = get_tree().get_first_node_in_group("laser_jebakan")
		if jebakan:
			jebakan.muncul()

func _on_body_exited(body):
	if body.is_in_group("balok"):
		if lampu:
			lampu.color = Color.RED
		
		# PERINTAH MATIKAN LASER SAAT BALOK KELUAR
		var jebakan = get_tree().get_first_node_in_group("laser_jebakan")
		if jebakan:
			jebakan.matikan()
