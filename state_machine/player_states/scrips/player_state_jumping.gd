extends PlayerStateGravityBase


func on_physics_process(delta: float) -> void:
	
	air_move(delta)
	if player.velocity.y > 0: 
		state_machine.change_to(player.states.falling)
		return

	#if player.is_on_wall_only():    
		#state_machine.change_to(player.states.slading)
		#return
		
		
	if Input.is_action_just_released("jump"):
		player.velocity.y *= 0.5

		state_machine.change_to(player.states.falling)
		return
	handle_gravity(delta)
	player.move_and_slide()
func start():
	
		
	if player.JUMP_COUNT > 0:
		player.velocity.y = player.JUMP_VELOCITY
		player.JUMP_COUNT -= 1
		if player.JUMP_COUNT <= 0:
			player_animations.play("jumping_two")
		else:
			player_animations.play("jumping")
			
	
		
	
	# Asegúrate de que JUMP_VELOCITY sea un valor negativo para ir hacia arriba (en Godot).
