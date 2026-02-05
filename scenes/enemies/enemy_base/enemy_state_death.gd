extends EnemyStateBase






func enter():
	enemy.enemy_radar.set_deferred("monitoring", true)
	if enemy.tween_hit and enemy.tween_hit.is_valid():
		enemy.tween_hit.kill()
	enemy.modulate = Color(1, 1, 1, 1)
	enemy.enemy_actual_animation = enemy.animations.croler
	enemy.enemy_animation.play(enemy.enemy_actual_animation )
	morir(enemy.ball_speed)
	enemy.enemy_actual_animation = enemy.animations.croler
	enemy.JUMP_SPEED = 700.0
	#enemy.SPEED = 250
	enemy.JUMP =  -160
	enemy.enemy_hp = enemy.enemy_default_hp


func on_physics_process(delta: float) -> void:
	enemy.rotation_degrees += 720 * delta
	if enemy.is_on_floor_only():
		enemy.rotation_degrees = 0
		state_machine.change_to(enemy.states.walking)
