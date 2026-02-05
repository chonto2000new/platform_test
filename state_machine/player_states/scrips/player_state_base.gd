class_name PlayerStateBase  extends StateBase

var player : PLAYER:
	set(value):
		controlled_node = value
	get:
		return controlled_node
@onready var player_animations: AnimatedSprite2D = $"../../player_animations"

func air_move(delta):
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction:
		# 1. ACELERACIÓN
		# En lugar de SPEED * 1.5, usa tu velocidad base primero. 
		# Aumentar la velocidad máxima en el aire suele hacer el juego incontrolable.
		# La clave es cuan RÁPIDO llegas a esa velocidad (el tercer argumento).
		
		player.velocity.x = move_toward(
			player.velocity.x, 
			direction * player.AIR_SPEED, 
			player.AIR_ACCELERATION * delta
		)
		
		# Manejo de Sprites (Tu lógica original estaba bien, la mantengo)
		if direction > 0:
			player_animations.flip_h = false
		elif direction < 0:
			player_animations.flip_h = true
			
		# Lógica de facing (simplificada)
		if direction != 0:
			player.facing_right = direction > 0

	else:
		# 2. FRICCIÓN (La clave del "Game Feel")
		# En lugar de velocity.x = 0, usamos move_toward hacia 0.
		# Esto permite que el personaje "deslice" un poco en el aire antes de parar,
		# dándole peso y suavidad.
		
		player.velocity.x = move_toward(
			player.velocity.x, 
			0, 
			player.AIR_FRICTION * delta
		)


func ground_move(_delta):
	var direction := Input.get_axis("move_left", "move_right")

	if direction > 0:
		player_animations.flip_h = false
		player_animations.play("walk")
	elif direction < 0: 
		player_animations.play("walk")
		player_animations.flip_h = true
		
	if player.is_on_wall() and not player.is_on_floor():
		if direction != 0:	
			player.facing_right = !direction > 0
	else:
		if direction != 0:	
			player.facing_right = direction > 0
		
	#if Input.is_action_just_pressed("dash"):
			#var dash_speed = 1000 * delta 
			#var dash =  Vector2(dash_speed,0.0) * SPEED
			#velocity = dash
	
	if direction:
		player.velocity.x = direction * player.SPEED
		#if wall_jump_lock > 0.0:
			#wall_jump_lock -= delta
			#velocity.x = lerp(velocity.x, direction * (SPEED /2 ),   0.3) 
		#else:
			#velocity.x = direction * SPEED
			
	#else:
		#player_animations.play("idle")
		#velocity.x = move_toward(velocity.x, 0, SPEED)
