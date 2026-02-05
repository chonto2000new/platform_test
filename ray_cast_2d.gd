extends RayCast2D

var numero = 0
func _physics_process(_delta):
	if is_colliding():
		#enabled = false
		var obj = get_collider()
		#print(obj)
		if obj.is_in_group("player"):
			numero += 1
			#print("El player tocó el rayo",":",numero)
		# Aquí puedes mover tu objeto hacia la izquierda/derecha
