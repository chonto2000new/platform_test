extends Area2D






func _on_area_entered(area: Area2D) -> void:
	hit_by_bullet()
	area.queue_free()




func hit_by_bullet():
	print("¡Bloque disparado!")
	
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		# --- EL FIX ES ESTE BLOQUE IF ---
		# Si current_save está vacío (porque estamos probando la escena suelta),
		# creamos una instancia nueva en memoria para que no falle.
		if SaveManager.current_save == null:
			print("Advertencia: No había partida cargada. Creando una temporal.")
			SaveManager.current_save = SaveGameData.new()
			# Opcional: Si quieres forzar que sea el slot 1 para pruebas
			SaveManager.current_slot = 1 
		
		# Ahora sí, ya es seguro asignar valores
		SaveManager.current_save.player_position = player.global_position
		SaveManager.current_save.current_scene_path = get_tree().current_scene.scene_file_path
		
		SaveManager.save_game()
		
		efectos_visuales()
	else:
		print("Error: No encontré al player")
		
func efectos_visuales():
	# Aquí pones el cambio de color o animación tipico de IWBTG
	#if animation_player:
		#animation_player.play("save_trigger")
	#if audio_player:
		#audio_player.play()
		#
	# Un tween simple si no tienes animaciones: Haces que vibre o cambie de color
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.GREEN, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
