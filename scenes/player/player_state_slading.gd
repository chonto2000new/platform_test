extends PlayerStateGravityBase

# Asumo que WALL_SLIDE_SPEED es una constante definida en tu Player.gd o similar.
# Ejemplo: const WALL_SLIDE_SPEED = 150.0

func on_physics_process(_delta: float) -> void:
	# 1. Aplicar la velocidad de deslizamiento vertical
	# Usar la velocidad de deslizamiento o gravedad si es menor
	
	player.JUMP_COUNT = 1
	player.velocity.y = player.WALL_SLIDE_SPEED 
	

	# 🚨 CORRECCIÓN CLAVE: Esto asegura que el personaje caiga LENTAMENTE
	# Si quieres una aceleración suave hasta el límite, usa: 
	# player.velocity.y = min(player.velocity.y + gravity * delta, player.WALL_SLIDE_SPEED)


	# 2. Control horizontal para salir del deslizamiento
	var direction := Input.get_axis("move_left", "move_right")
	
	# Esto es importante para salir del estado si el jugador presiona 
	# la dirección opuesta a la pared, pero también permite un leve movimiento en la pared
	if direction:
		player.velocity.x = direction * player.SPEED
	else:
		player.velocity.x = 0

	# 3. Lógica de salida del estado
	
	# Si ya no está en la pared (e.g., salió por arriba o el control horizontal lo empujó)
	if not player.is_on_wall_only() and not player.wall_contact_coyote > 0 :
		state_machine.change_to(player.states.falling)
		return # Salir para evitar move_and_slide() doble o incorrecto
	
	# Si toca el suelo, ir a Idle
	if player.is_on_floor():
		# No sumes gravedad aquí, simplemente transiciona
		state_machine.change_to(player.states.idle)
		return

	# 4. Mover el cuerpo
	player.move_and_slide()
	
	# Nota: handle_gravity(delta) no es necesario aquí, ya que la velocidad vertical
	# se establece directamente con player.WALL_SLIDE_SPEED.
	
	# 5. Lógica de animación (opcional, si quieres que mire hacia afuera de la pared)
	if player.is_on_wall():
		var normal_x = player.get_last_slide_collision().get_normal().x
		
		if normal_x != 0:
			player_animations.play("slide")
			player_animations.flip_h = normal_x > 0
			
			# --- 🔄 AQUÍ AGREGAS LA ROTACIÓN ---
			# Ajusta el "90" al ángulo que necesites para que se vea bien.
			# Si necesitas que rote diferente según la pared, usa el 'normal_x'.
			
			# Ejemplo: Si quieres que la cabeza apunte hacia arriba o afuera:
			if player_animations.flip_h:
				player_animations.flip_h = false
			else:
				player_animations.flip_h =true  
# En WallSliding.gd
func on_input(_event: InputEvent) -> void:
	# 🚨 Es crucial usar 'is_action_just_pressed' para evitar que se ejecute en cada frame.
	if Input.is_action_just_pressed("jump") or player.jump_buffer_timer > 0:
		if player.wall_contact_coyote > 0:
		
			# Calcular la dirección del salto (OPUESTA a la pared/flip_h)
			# 1.0 = Derecha, -1.0 = Izquierda
			var direction: float = -1.0 if player_animations.flip_h else 1.0
			
			# ⬅️ ESCRIBIR: Actualizar la variable del Player
			# Asumiendo que definiste 'wall_jump_direction' en Player.gd
			player.wall_jump_direction = direction
			
			
			# Transición al nuevo estado
			state_machine.change_to(player.states.wall_jumping)
func end() -> void: # O func exit():
	player_animations.rotation_degrees = 0.0
	
