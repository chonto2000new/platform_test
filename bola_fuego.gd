extends Area2D

@export var velocidad_caida: float = 600.0
# Arrastra aquí la escena de la CortinaFuego desde el FileSystem
@export var cortina_scene: PackedScene 
@onready var ray_cast_2d: RayCast2D = $RayCast2D

func _physics_process(delta):
	if ray_cast_2d.is_colliding():
		generar_cortina()
		queue_free() # La bola desaparece
		
	position.y += velocidad_caida * delta
	

#func _on_body_entered(body):
	## Asumiendo que tu suelo está en un grupo llamado "suelo" o usando capas físicas
	## Para el prototipo, chequeamos si es un TileMap o StaticBody
	#if body is TileMap or body is StaticBody2D: 
		#

func generar_cortina():
	if cortina_scene:
		var cortina = cortina_scene.instantiate()
		
		# 1. Posicionar la cortina (usando tu RayCast o posición global)
		if ray_cast_2d and ray_cast_2d.is_colliding():
			cortina.global_position = ray_cast_2d.get_collision_point()
		else:
			cortina.global_position = global_position
		
		# 2. CALCULAR DIRECCIÓN HACIA EL JUGADOR
		# Primero intentamos buscar al nodo del jugador en el árbol
		# Asegúrate de que tu Player esté en un grupo llamado "player"
		var player = get_tree().get_first_node_in_group("player")
		
		if player:
			# Restamos: Destino (Player) - Origen (Fuego)
			var diferencia_x = player.global_position.x - cortina.global_position.x
			
			# 'sign' nos devuelve 1, -1 o 0
			var direccion_final = sign(diferencia_x)
			
			# Corrección por si caen exactamente en el mismo pixel (sign daría 0)
			if direccion_final == 0:
				direccion_final = 1 
			
			cortina.direccion = direccion_final
		else:
			# Si no encuentra al jugador, usamos un valor por defecto (ej. izquierda)
			# O podrías usar tu lógica anterior del centro como respaldo
			cortina.direccion = -1
			print("¡Ojo! No se encontró al nodo 'player'. Revisa los grupos.")
		
		# Añadir a la escena
		get_tree().current_scene.add_child(cortina)
