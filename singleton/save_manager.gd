extends Node

# Este es el script que definimos antes (tu DTO)
var current_save: SaveGameData

# Para saber si estamos en el slot 1, 2 o 3
var current_slot: int = 1

const SAVE_DIR = "user://saves/"

func _ready():
	# Asegurar que el directorio existe
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_absolute(SAVE_DIR)

# --- CARGAR PARTIDA (Llamar al iniciar el juego o elegir slot) ---
func load_game(slot: int):
	current_slot = slot
	var path = SAVE_DIR + "slot_" + str(slot) + ".tres"
	
	if ResourceLoader.exists(path):
		current_save = ResourceLoader.load(path)
	else:
		# Si no existe, creamos una nueva partida vacía
		current_save = SaveGameData.new()

# --- GUARDAR PARTIDA (La función mágica) ---
func save_game():
	if current_save == null:
		print("Error: No hay partida cargada para guardar.")
		return
	
	# Actualizamos la fecha/hora
	# current_save.timestamp = Time.get_datetime_string_from_system()
	
	var path = SAVE_DIR + "slot_" + str(current_slot) + ".tres"
	var error = ResourceSaver.save(current_save, path)
	
	if error == OK:
		print("Guardado exitoso en Slot ", current_slot)
	else:
		print("Error al guardar: ", error)

# Pega esto en save_manager.gd
func get_save_data_preview(slot: int) -> SaveGameData:
	var path = SAVE_DIR + "slot_" + str(slot) + ".tres"
	if ResourceLoader.exists(path):
		return ResourceLoader.load(path)
	return null

# --- BORRAR PARTIDA ---
func delete_save(slot: int):
	var path = SAVE_DIR + "slot_" + str(slot) + ".tres"
	
	# Verificamos si el archivo existe antes de intentar borrarlo
	if FileAccess.file_exists(path):
		var error = DirAccess.remove_absolute(path)
		if error == OK:
			print("Partida borrada exitosamente del Slot ", slot)
		else:
			print("Error al intentar borrar el archivo: ", error)
