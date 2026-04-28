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

func _on_body_exited(body):
	if body.is_in_group("balok"):
		if lampu:
			lampu.color = Color.RED
