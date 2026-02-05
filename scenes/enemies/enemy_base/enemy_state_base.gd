class_name  EnemyStateBase extends StateBase



var enemy : ENEMYBASE:
	set(value):
		controlled_node = value
	get:
		return controlled_node
		


func start():

	enter() 

# Esta función está vacía aquí, pero los hijos la usarán
func enter():
	pass
	
func take_damage_state(damage:int,velocidad = null):


	enemy.ball_speed = velocidad
	enemy.enemy_hp -= damage 
	
	enemy.damage_effect()
	if enemy.enemy_hp <= 0:
		if enemy.enemy_actual_animation == enemy.animations.croler:
				state_machine.change_to(enemy.states.perma_death)
				return
			
		var numero = randi_range(0, 4) # Genera 0, 1, 2, 3 o 4
		match numero:
			0, 1:
				state_machine.change_to(enemy.states.death)
			# Tu código aquí (ej. generar un enemigo débil)
			2, 3, 4:
				state_machine.change_to(enemy.states.perma_death)
			# Tu código aquí (ej. generar un enemigo fuerte)



func morir(dato_recibido):
	var direccion_x = 0
	
	# CASO A: Recibimos VELOCIDAD (Vector2) -> ¡La mejor opción!
	if typeof(dato_recibido) == TYPE_VECTOR2 and dato_recibido.length() > 0:
		# Usamos la dirección del movimiento, no la posición
		direccion_x = sign(dato_recibido.x)
		
	# CASO B: Recibimos POSICIÓN (Vector2) -> Fallback
	else:
		var direccion_vector = dato_recibido.direction_to(enemy.global_position)
		direccion_x = sign(direccion_vector.x)
		
	if direccion_x == 0: direccion_x = 1
	
	enemy.velocity.x = direccion_x * enemy.fuerza_empuje_x
	enemy.velocity.y = -abs(enemy.fuerza_empuje_y)


func _on_radar_detects_body(_body: Node2D):
	print("--- DESDE RADAR ---")
	print("Soy el objeto: ", self)
	print("Mi state_machine es: ", state_machine)
	
	if _body.is_in_group("player"):
		print("¡Es el Player! Saltando...")
		state_machine.change_to(enemy.states.jumping)
	else:
		# Si sale este print, el problema son los GRUPOS (Punto 2)
		print("Toco algo, pero no tiene el grupo 'Player'")


func flame():
	enemy.flames.emitting = true
	enemy.velocity.x = 0.0
	await get_tree().create_timer(2.0).timeout		
	enemy.queue_free()
