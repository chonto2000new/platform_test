# SettingsManager.gd
extends Node

const SETTINGS_FILE = "user://config.cfg" # La ruta donde se guarda en el PC del usuario
var config = ConfigFile.new()

# Lista de acciones que permitimos configurar (para no guardar cosas raras)
var input_actions = ["move_up", "move_down", "move_left", "move_right", "jump", "shoot","restart"]

func _ready():
	load_settings()

func save_key_mapping(action_name: String, event: InputEvent):
	# Solo guardamos si es una tecla o botón de ratón/mando
	if event is InputEventKey:
		# Guardamos el código físico de la tecla (ej: 4194320 para 'A')
		config.set_value("Controls", action_name, event.physical_keycode)
		
		# Escribimos el archivo inmediatamente
		config.save(SETTINGS_FILE)

func load_settings():
	# Intentamos cargar el archivo. Si no existe, no hacemos nada.
	var error = config.load(SETTINGS_FILE)
	if error != OK:
		return # Archivo no existe o corrupto (usará controles por defecto)

	# Recorremos las acciones que nos interesan
	for action in input_actions:
		# Verificamos si hay algo guardado para esta acción
		var key_code = config.get_value("Controls", action, null)
		
		if key_code != null:
			# 1. Borramos la configuración por defecto
			InputMap.action_erase_events(action)
			
			# 2. Creamos el nuevo evento con el código guardado
			var new_event = InputEventKey.new()
			new_event.physical_keycode = key_code
			
			# 3. Lo añadimos al InputMap
			InputMap.action_add_event(action, new_event)


func reset_to_defaults():
	# 1. La función mágica: Vuelve a cargar lo que está en Project Settings
	InputMap.load_from_project_settings()
	
	# 2. Limpiamos el archivo de guardado para olvidar las personalizaciones
	config.clear()
	config.save(SETTINGS_FILE)
