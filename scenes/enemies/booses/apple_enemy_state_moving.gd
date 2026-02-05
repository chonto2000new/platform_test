extends AppleBossStateBase
var follow_attack_timer:Timer



func start():
	apple.tiempo = 0.0
	apple.cambiar_face.start()
	apple.cambiar_face.timeout.connect(return_start)
	
	follow_attack_timer =  Timer.new()
	follow_attack_timer.wait_time = 1.5
	follow_attack_timer.autostart = true
	follow_attack_timer.timeout.connect(apple._on_timer_timeout_player_follow)
	add_child(follow_attack_timer)
	
func end():
	follow_attack_timer.queue_free()
	
	

func on_physics_process(delta: float):
	# 1. Acumular Tiempo (siempre corre)
	apple.tiempo += delta
	
	# --- MODO 1: PATRULLA HORIZONTAL (Tu código original) ---
	# Se activa si "modo_vertical" es falso
	if not apple.modo_vertical:
		
		# Movimiento Lineal en X (Rebotes)
		apple.velocity.x = apple.velocidad_horizontal * apple.dir_x
		# Movimiento de Onda en Y
		apple.velocity.y = cos(apple.tiempo * apple.frecuencia) * apple.amplitud_vertical
		
		# Lógica de Rebote Horizontal
		if apple.dir_x == 1 and apple.r_right.is_colliding():
			apple.dir_x = -1
		elif apple.dir_x == -1 and apple.r_left.is_colliding():
			apple.dir_x = 1

	# --- MODO 2: PATRULLA VERTICAL (Lo nuevo) ---
	# Se activa si "modo_vertical" es verdadero
	else:
		
		# Movimiento Lineal en Y (Arriba/Abajo)
		apple.velocity.y = apple.velocidad_horizontal * apple.dir_y # Reusamos la velocidad o crea una nueva variable
		# Movimiento de Onda en X (ZigZag lateral)
		apple.velocity.x = cos(apple.tiempo * apple.frecuencia) * apple.amplitud_vertical
		
		# Lógica de Rebote Vertical (Necesitas RayCasts arriba/abajo)
		# Si va bajando (1) y toca suelo -> sube (-1)
		if apple.dir_y == 1 and apple.r_down.is_colliding():
			apple.dir_y = -1 
			
		# Si va subiendo (-1) y toca techo -> baja (1)
		elif apple.dir_y == -1 and apple.r_up.is_colliding():
			apple.dir_y = 1

	# 3. Mover (Al final, una sola vez)
	apple.move_and_slide()

func return_start():
	elegir_siguiente_ataque()



func elegir_siguiente_ataque():
	var dado = randf() # Genera un número decimal entre 0.0 y 1.0
	print("Dado lanzado: ", dado) # Útil para depurar y ver qué sale
	
	# --- 50% DE PROBABILIDAD (0.0 a 0.5) ---
	if dado < 0.5:
		# Asumiendo que accedes a los nombres así:
		state_machine.change_to(apple.apple_boss_states_names.state_circle_attack)
		print("Eligió: CIRCLE ATTACK (Común)")
		
	# --- 25% DE PROBABILIDAD (0.5 a 0.75) ---
	elif dado < 0.75:
		state_machine.change_to(apple.apple_boss_states_names.state_flame_attack)
		print("Eligió: FLAME ATTACK (Raro)")
		
	# --- 25% DE PROBABILIDAD (0.75 a 1.0) ---
	else:
		state_machine.change_to(apple.apple_boss_states_names.state_bounce_attack)
		print("Eligió: BOUNCE ATTACK (Raro)")
