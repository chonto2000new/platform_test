class_name GAMEENGINE extends Node


func _input(event):
	if event.is_action_pressed("restart"):


	
		#var player = get_tree().get_first_node_in_group("player")
		
	

		
		# Ahora sí, ya es seguro asignar valores
		SaveManager.current_save.death_count += 1 
		
		SaveManager.save_game()
		cargar_ultimo_save()

func cargar_ultimo_save():
	# Verificamos que exista una partida en memoria
	if SaveManager.current_save != null:
		var ruta_escena = SaveManager.current_save.current_scene_path
		
		# Si tenemos una ruta válida guardada (ej: "res://niveles/nivel_1.tscn")
		if ruta_escena != "":
			# Esto nos lleva al nivel correcto Y resetea la escena
			get_tree().change_scene_to_file(ruta_escena)
		else:
			# Fallback: Si no hay ruta guardada, reiniciamos la actual
			get_tree().reload_current_scene()



func _ready():
	# Verificamos si hay un punto de aparición pendiente en el Global
	if PlayerNextPosition.next_spawn_point != "":
		
		# Buscamos el nodo Marker2D por su nombre
		var marker = get_parent().find_child(PlayerNextPosition.next_spawn_point)
		var player = get_parent().find_child("player")
		
		print(marker,"","player spawn")

		print(player,"","player spawn")
		
		if marker:
			player.global_position = marker.global_position
		else:
			print("Error: No se encontró el Marker llamado ", PlayerNextPosition.next_spawn_point)
			
		# Limpiamos la variable para evitar errores futuros
		PlayerNextPosition.next_spawn_point = ""
