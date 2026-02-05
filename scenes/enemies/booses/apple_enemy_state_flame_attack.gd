extends AppleBossStateBase

@export var bomb_scene: PackedScene 

var drop_timer: Timer
var duration_timer: Timer
var subiendo_al_techo: bool = true # Nueva variable de control

func start():
	apple.tiempo = 0.0
	subiendo_al_techo = true # Al iniciar, forzamos que quiera subir
	
	# NO iniciamos los timers aún, esperamos a llegar al techo

func end():
	# Limpieza de timers al salir
	if drop_timer: drop_timer.queue_free()
	if duration_timer: duration_timer.queue_free()

func on_physics_process(delta: float):
	
	if subiendo_al_techo:
		# --- FASE 1: SUBIR AL TECHO ---
		apple.velocity.x = 0
		apple.velocity.y = -apple.velocidad_horizontal # Sube constante
		
		# Verificamos si ya tocó el techo con el RayCast
		if apple.r_up.is_colliding():
			subiendo_al_techo = false
			iniciar_bombardeo() # Iniciamos el ataque real
			
		apple.move_and_slide()
		
	else:
		# --- FASE 2: BOMBARDEO (Tu código de movimiento) ---
		apple.tiempo += delta
		
		# Movimiento Horizontal (Patrulla)
		apple.velocity.x = apple.velocidad_horizontal * apple.dir_x
		
		# Rebote Horizontal
		if apple.dir_x == 1 and apple.r_right.is_colliding():
			apple.dir_x = -1
		elif apple.dir_x == -1 and apple.r_left.is_colliding():
			apple.dir_x = 1
			
		# Mantenemos Y fijo o con pequeña onda para que no se despegue del techo
		apple.velocity.y = cos(apple.tiempo * apple.frecuencia) * 50 # Amplitud pequeña
		
		apple.move_and_slide()

# Función auxiliar para iniciar los timers una vez arriba
func iniciar_bombardeo():
	# Timer de bombas
	drop_timer = Timer.new()
	drop_timer.wait_time = 0.8
	drop_timer.autostart = true
	drop_timer.timeout.connect(soltar_bomba)
	add_child(drop_timer)
	
	# Timer de duración
	duration_timer = Timer.new()
	duration_timer.wait_time = 4.0
	duration_timer.one_shot = true
	duration_timer.autostart = true
	duration_timer.timeout.connect(terminar_ataque)
	add_child(duration_timer)

func soltar_bomba():
	if bomb_scene:
		var bomb = bomb_scene.instantiate()
		# Ajusta el offset en Y para que la bomba no salga dentro del techo
		bomb.global_position = apple.global_position + Vector2(0, 30) 
		get_tree().current_scene.add_child(bomb)

func terminar_ataque():
	state_machine.change_to(apple.apple_boss_states_names.state_idle
	) # O state_idle
