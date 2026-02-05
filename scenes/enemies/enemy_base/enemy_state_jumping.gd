extends EnemyStateBase

func enter():
	# 1. EL IMPULSO INICIAL (Solo una vez)
	# Usamos negativo para ir hacia arriba. 
	# -30 es muy poco, prueba con -300 o -400.
	enemy.enemy_radar.set_deferred("monitoring", false)
	enemy.velocity.y = enemy.JUMP
	
	# Opcional: Una animación de salto
	# enemy.animation_player.play("jump")
func end():
	enemy.enemy_radar.set_deferred("monitoring", true)
	
func on_physics_process(_delta: float) -> void:
	# 2. MOVIMIENTO EN EL AIRE
	# ¿Quieres que se mueva mientras salta? 
	# Si sí, mantén la velocidad X.
	enemy.velocity.x = enemy.JUMP_SPEED * enemy.direction
	
	# 3. TRANSICIÓN DE SALIDA (Aterrizaje)
	# Si ya vamos cayendo (velocity.y > 0) y tocamos suelo...
	if enemy.velocity.y >= 0 and enemy.is_on_floor():
		state_machine.change_to(enemy.states.walking) # O "Idle"
