extends PlayerStateGravityBase

func start():
	# 🚀 Inicializa variables al entrar (solo una vez)
	player.JUMP_COUNT = player.MAX_JUMP
	# Mantenemos el snap solo al inicio si es necesario
	player.set_floor_snap_length(4.0)



func on_physics_process(delta):
	
	if not player.coyote_timer > 0:
		player.JUMP_COUNT = 1
		state_machine.change_to(player.states.falling)
		return
	
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		# Si hay dirección, cambia a caminar INMEDIATAMENTE
		state_machine.change_to(player.states.walking)
		return
	if Input.is_action_just_pressed("jump") or player.jump_buffer_timer > 0:

		state_machine.change_to(player.states.jumping)
		return
	player.velocity.x = 0
	player_animations.play("idle")
	handle_gravity(delta)
	player.move_and_slide()


		





func on_input(event:InputEvent):

	if event.is_action("move_left") or event.is_action("move_right"): 
		state_machine.change_to(player.states.walking)
		return
	
