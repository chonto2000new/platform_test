extends PlayerStateGravityBase

const SPEED = 100.0




func on_physics_process(delta: float) -> void:
	ground_move(delta)
	

	#if player.velocity.y > 0:
	if not player.coyote_timer > 0:
		player.JUMP_COUNT = 1
		state_machine.change_to(player.states.falling)
		return
		
	if not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		state_machine.change_to("PlayerStateIdle")
		return

	if Input.is_action_just_pressed("jump") or player.jump_buffer_timer > 0:
		state_machine.change_to(player.states.jumping)
		return


		
	handle_gravity(delta)
	player.move_and_slide()
	player.set_floor_snap_length(4.0)
	
