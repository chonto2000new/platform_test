extends TileMapLayer

# IMPORTANTE: Revisa el ID de tu nuevo atlas. 
# Pasa el mouse sobre 'switch_blocks-Sheet' en la lista de la izquierda abajo.
# Si es el único que tienes ahí, probablemente sea 0.

# Antes tenías 0, cámbialo por el número que te sale en el tooltip (4 en tu caso)
const SOURCE_ID = 4
const ANCHO_BLOQUE = 2 # Cuántas celdas de 16px mide tu bloque de ancho (32px / 16px = 2)



func alternar_bloques():
	var celdas = get_used_cells()
	
	for celda in celdas:
		# Verificamos que sea un tile de nuestros interruptores
		if get_cell_source_id(celda) == SOURCE_ID:
			var atlas_coords = get_cell_atlas_coords(celda)
			
			# --- MAGIA MATEMÁTICA ---
			# Si la coordenada X es menor que 2, significa que estamos en la parte IZQUIERDA (Encendido)
			if atlas_coords.x < ANCHO_BLOQUE:
				# Lo mandamos a la derecha (Apagar)
				var nueva_coord = atlas_coords + Vector2i(ANCHO_BLOQUE, 0)
				set_cell(celda, SOURCE_ID, nueva_coord)
				
			# Si la coordenada X es mayor o igual a 2, estamos en la parte DERECHA (Apagado)
			else:
				# Lo mandamos a la izquierda (Encender)
				var nueva_coord = atlas_coords - Vector2i(ANCHO_BLOQUE, 0)
				set_cell(celda, SOURCE_ID, nueva_coord)


func _on_timer_timeout() -> void:
	alternar_bloques()
