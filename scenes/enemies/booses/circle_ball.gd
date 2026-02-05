extends Area2D # O el nodo que uses

var direccion = Vector2.RIGHT
var velocidad = 300 # Velocidad constante

func _physics_process(delta):
	# Solo movemos en la dirección que nos dieron al nacer.
	# ¡NO rotamos la dirección aquí!
	position += direccion * velocidad * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
