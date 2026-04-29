extends Area2D

func _ready():
	add_to_group("laser_pinggir")
	visible = true
	$CollisionShape2D.set_deferred("disabled", false)

func nyalakan():
	visible = true
	$CollisionShape2D.set_deferred("disabled", false)
	print("[SYSTEM]: Laser Pinggir Aktif!")

func matikan():
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	print("[SYSTEM]: Laser Pinggir Nonaktif.")

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("mati"):
			body.mati()
