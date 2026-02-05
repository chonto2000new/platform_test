extends AppleBossStateBase





#
func start():
	var destino = Vector2.ZERO
	
	# 1. Buscamos la cámara activa automáticamente
	var camara = get_viewport().get_camera_2d()
	if camara:
		# ¡ESTA es la clave! Nos da la coordenada MUNDIAL del centro de la vista
		destino = camara.get_screen_center_position()

	else:
		# Plan B por si no hay cámara (fallback)
		print("¡Ojo! No encontré cámara activa")
		destino = apple.global_position # Que se quede donde está

	
 	
	# 2. El resto de tu código de Tween sigue igual
	var tween = create_tween()
	tween.tween_property(apple, "global_position", destino, apple.velocidad_entrada)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	
	tween.finished.connect(_al_terminar_entrada)
func _al_terminar_entrada():
	state_machine.change_to(apple.apple_boss_states_names.state_idle)
	#state_machine.change_to(siguiente_estado)
