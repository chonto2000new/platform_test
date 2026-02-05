extends AppleBossStateBase

@export var velocidad: float = 300.0 
@export var delay_impacto: float = 0.2
@export var times_to_bounce: int = 5
const default_times_to_bounce: int = 5

@export var spike_scene: PackedScene 

# Dirección inicial diagonal
var direction: Vector2 = Vector2(1, 1).normalized() 
var is_impacting: bool = false 

func start():
	# IMPORTANTE: Reiniciar el contador al entrar al estado
	times_to_bounce = default_times_to_bounce
	
	# Configuración de RayCasts (tus valores)
	apple.r_down.target_position = Vector2(0.0, 5.0)
	apple.r_left.target_position = Vector2(0.0, 5.0)
	apple.r_right.target_position = Vector2(0.0, 5.0)
	apple.r_up.target_position = Vector2(0.0, 5.0)
	
	# Dirección aleatoria
	var x_rand = 1 if randf() > 0.5 else -1
	var y_rand = 1 if randf() > 0.5 else -1
	direction = Vector2(x_rand, y_rand).normalized()
	
	is_impacting = false

func end():
	# Restaurar RayCasts al salir
	apple.r_down.target_position = Vector2(0.0, 50.0)
	apple.r_left.target_position = Vector2(0.0, 50.0)
	apple.r_right.target_position = Vector2(0.0, 50.0)
	apple.r_up.target_position = Vector2(0.0, 50.0)

func on_physics_process(_delta: float):
	if is_impacting:
		# Solo congelamos la velocidad. NO restamos vidas aquí.
		apple.velocity = Vector2.ZERO
	else:
		# --- MOVIMIENTO ---
		apple.velocity = direction * velocidad
		
		# --- DETECCIÓN DE CHOQUES ---
		if direction.x > 0 and apple.r_right.is_colliding():
			iniciar_impacto(Vector2(-abs(direction.x), direction.y))
			
		elif direction.x < 0 and apple.r_left.is_colliding():
			iniciar_impacto(Vector2(abs(direction.x), direction.y))
			
		elif direction.y > 0 and apple.r_down.is_colliding():
			iniciar_impacto(Vector2(direction.x, -abs(direction.y)))
			
		elif direction.y < 0 and apple.r_up.is_colliding():
			iniciar_impacto(Vector2(direction.x, abs(direction.y)))
		
	apple.move_and_slide()

func iniciar_impacto(nueva_direccion: Vector2):
	is_impacting = true
	
	# 1. Restar contador
	times_to_bounce -= 1
	
	# 2. Espera del golpe (freeze)
	await get_tree().create_timer(delay_impacto).timeout
	
		# 3. Efectos
	var cameras = get_tree().get_nodes_in_group("MainCamera")
	if cameras.size() > 0:
		cameras[0].apply_shake(15.0, 5.0)
	else:
		var cam = get_viewport().get_camera_2d()
		if cam and cam.has_method("apply_shake"):
			cam.apply_shake(15.0, 5.0)
			
			
	lluvia_de_picos()

	# --- AQUÍ ESTÁ EL TRUCO PARA QUE NO SE TRABE ---
	
	# Calculamos la dirección de salida (hacia el centro de la sala)
	direction = nueva_direccion
	
	if times_to_bounce <= 0:
		# CASO FINAL: Ya no queremos rebotar, queremos SALIR.
		
		# A. Le damos velocidad para que se aleje de la pared
		is_impacting = false # Reactivamos el movimiento en _physics_process
		
		# B. Esperamos un poco (0.5s) mientras el Boss se aleja físicamente
		# Como 'direction' ya apunta hacia afuera, el Boss se moverá al centro.
		await get_tree().create_timer(0.5).timeout
		
		# C. AHORA que ya está lejos, reseteamos y cambiamos estado
		# Al cambiar estado se ejecuta end() y los raycasts crecen, 
		# pero como ya nos alejamos, no chocarán.
		times_to_bounce = default_times_to_bounce
		state_machine.change_to(apple.apple_boss_states_names.state_idle)
		return 

	# CASO NORMAL (Sigue rebotando)
	await get_tree().create_timer(0.1).timeout
	is_impacting = false
	
	
func lluvia_de_picos():
	if not spike_scene: return
	
	var cantidad = 5
	# OJO: En Godot "abajo" es positivo. Si tu techo está arriba, 
	# el número suele ser positivo (ej. 384) si el origen (0,0) está arriba a la izquierda.
	# Si tu 0,0 está en el centro, puede ser negativo. 
	# Verifica poniendo el mouse en el editor como vimos antes.
	var altura_techo_fija = 200.0 
	var limite_izquierdo = -100.0 
	var limite_derecho = 700.0 
	
	for i in range(cantidad):
		var pico = spike_scene.instantiate()
		get_tree().current_scene.add_child(pico)
		var random_x = randf_range(limite_izquierdo, limite_derecho)
		pico.global_position = Vector2(random_x, altura_techo_fija)
		await get_tree().create_timer(0.1).timeout
