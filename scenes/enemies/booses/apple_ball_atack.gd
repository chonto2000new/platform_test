extends Area2D # O CharacterBody2D, lo que estés usando

var speed: float = 700.0
var direction: Vector2 = Vector2.ZERO

func _physics_process(delta):
	# Movemos la bola en la dirección que le asignen
	position += direction * speed * delta

# Esta función la llamará el enemigo al crear la bola
func set_move_direction(new_direction: Vector2):
	direction = new_direction
	# Opcional: Rotar la imagen para que mire hacia donde va
	rotation = direction.angle()

# Si usas Area2D, conecta la señal "body_entered" para borrarla si choca
func _on_body_entered(body):
	if body.name == "player": # O usa grupos: body.is_in_group("player")
		print("¡Auch! Golpeas al jugador")
		queue_free() # Borrar bola
	elif body.name != "Enemigo": # Para que no se borre al tocar al enemigo que la disparó
		queue_free() # Borrar bola si choca pared


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
