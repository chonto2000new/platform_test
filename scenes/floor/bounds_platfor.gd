extends AnimatableBody2D
var SPEED = 0.2
var velocity = Vector2(300, 0) # Una velocidad inicial

func _physics_process(delta: float) -> void:
	#position.x += 200 * delta
	var collision = move_and_collide(velocity * delta * SPEED)

	if collision:
			# Usamos la normal de la colisión para calcular el rebote.
			# La función bounce() invierte la velocidad como si rebotara en una pared.
			velocity = velocity.bounce(collision.get_normal())
