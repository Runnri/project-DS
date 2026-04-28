extends Area2D


func _ready():
	add_to_group("laser_jebakan")
	visible = false 
	$CollisionShape2D.set_deferred("disabled", true)

func muncul():
	visible = true
	$CollisionShape2D.set_deferred("disabled", false)
	print("[SYSTEM]: Laser Aktif!")

func matikan():
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	print("[SYSTEM]: Laser Nonaktif.")

# SENSOR PEMBUNUH: Langsung aktif kalau Bit nyentuh
func _on_body_entered(body):
	if body.is_in_group("player"):
		# Memanggil fungsi mati() yang ada di player.gd Bos
		if body.has_method("mati"):
			body.mati()
