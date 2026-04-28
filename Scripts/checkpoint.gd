extends Area2D

var is_active = false

@onready var sprite = $AnimatedSprite2D
@onready var lampu_cahaya = $PointLight2D

func _ready():
	add_to_group("checkpoint")  # Agar bisa ditemukan oleh _reset_semua_checkpoint()
	sprite.play("mati")
	if lampu_cahaya:
		lampu_cahaya.enabled = false
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not is_active and body.has_method("update_checkpoint"):
		is_active = true
		sprite.play("nyala")
		if lampu_cahaya:
			lampu_cahaya.enabled = true
		body.update_checkpoint(global_position)

# Dipanggil saat game over agar checkpoint bisa disentuh ulang
func reset_checkpoint():
	is_active = false
	sprite.play("mati")
	if lampu_cahaya:
		lampu_cahaya.enabled = false


func _on_tombol_keluar_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
