extends RigidBody2D
func _ready():
	# Aplicar un impulso inicial
	apply_impulse(Vector2.ZERO, Vector2(200, -400))
