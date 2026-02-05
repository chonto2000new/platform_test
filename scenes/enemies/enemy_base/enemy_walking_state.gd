extends EnemyStateBase

# Usamos on_ready como tu función de entrada ("Start" o "Enter")
func enter():
	
	# Conexión Segura: Solo conecta si no está conectado ya
	
	enemy.enemy_animation.play(enemy.enemy_actual_animation)
	
	if not enemy.enemy_radar.body_entered.is_connected(_on_radar_detects_body):
		enemy.enemy_radar.body_entered.connect(_on_radar_detects_body)

# Asumo que tienes una función de salida, si no, las señales se acumulan
func end() -> void: # O como llames a tu función de salida
	enemy.enemy_animation.play(enemy.enemy_actual_animation)

	if enemy.enemy_radar.body_entered.is_connected(_on_radar_detects_body):
		enemy.enemy_radar.body_entered.disconnect(_on_radar_detects_body)

func on_physics_process(_delta: float) -> void:
#	sistema de animacion
	
	#if enemy.enemy_actual_animation == enemy.animations.croler:
		#enemy.enemy_radar.monitoring = true

	# Lógica de dirección
	if enemy.direction > 0 and (enemy.right.is_colliding() or not enemy.right_down.is_colliding()):
		# --- ERROR 2 CORREGIDO: Usar rotación o escala en un nodo padre, no directo en el area si da problemas ---
		# Si prefieres seguir con escala, asegúrate que el CollisionShape no se deforme raro.
		enemy.enemy_radar.scale.x = -1.0 
		enemy.direction = -1.0 
		
	elif enemy.direction < 0 and (enemy.left.is_colliding() or not enemy.left_down.is_colliding()):
		enemy.enemy_radar.scale.x = 1.0
		enemy.direction = 1.0 

	# Aplicamos velocidad X. La Y la maneja el padre (gravedad) o el salto.
	if enemy.direction > 0:
		enemy.enemy_animation.flip_h = false
	else:
		enemy.enemy_animation.flip_h = true
		
		
	
	enemy.velocity.x = enemy.SPEED * enemy.direction
