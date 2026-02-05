extends PlayerStateGravityBase

func start():
	player_animations.play("falling")
	
func on_physics_process(delta: float) -> void:
	# 🚀 LÓGICA CLAVE: Detección y Consumo del Doble Salto
	if Input.is_action_just_pressed("jump") and player.JUMP_COUNT > 0:
		#
		#player.velocity.y = player.JUMP_VELOCITY # 🥈 APLICA la velocidad
		## Si tienes un estado 'jumping' separado, puedes transicionar.
		state_machine.change_to(player.states.jumping) 
		return # Salimos del proceso para este frame
		
	air_move(delta)

	# 🦶 LÓGICA CLAVE: Aterrizaje y Reinicio
	if player.is_on_floor():
		state_machine.change_to(player.states.idle)



	# Lógica de deslizamiento en pared
	if player.is_on_wall_only():
		state_machine.change_to(player.states.slading)
		return

	handle_gravity(delta)
	player.move_and_slide()
