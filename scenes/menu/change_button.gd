class_name BUTTONOPTION extends Button

# Escribe aquí el nombre EXACTO de la acción como está en tu Mapa de Entradas
@export var action_name: String = "jump"

var is_remapping = false

func _ready():
	# 1. Nos añadimos al grupo automáticamente
	add_to_group("BotonesRemap")
	
	# 2. Aseguramos que no procese inputs hasta que le demos clic
	# ### CAMBIO AQUÍ: Usamos set_process_input (Mayor prioridad) en vez de unhandled
	set_process_input(false)
	
	# 3. Si ya tiene nombre (puesto manual), cargamos datos
	if action_name != "":
		refresh_view()

# --- Tus funciones originales (INTACTAS) ---
func setup_button(new_action_name: String):
	action_name = new_action_name
	refresh_view()

func refresh_view():
	update_button_text()
	search_and_update_label()

func search_and_update_label():
	var parientes = get_parent().get_children()
	for nodo in parientes:
		if nodo is Label:
			nodo.text = action_name.capitalize()
			break 

func _on_pressed():
	if not is_remapping:
		is_remapping = true
		text = "Presiona tecla..."
		# ### CAMBIO AQUÍ: Activamos el input de Alta Prioridad
		set_process_input(true)

# ### CAMBIO AQUÍ: Renombramos _unhandled_input a _input
# Esto intercepta la tecla ANTES de que el menú intente moverse
func _input(event):
	if is_remapping:
		# Aceptamos Teclado o Botones de Mouse/Gamepad
		if (event is InputEventKey) or (event is InputEventMouseButton) or (event is InputEventJoypadButton):
			if event.is_pressed():
				
				# ### CAMBIO CRÍTICO: DETENER EL EVENTO
				# Esto le dice a Godot "Ya usé esta tecla, no muevas el menú"
				get_viewport().set_input_as_handled()
				
				# --- Tu lógica original sigue aquí ---
				limpiar_conflictos(event)
				
				InputMap.action_erase_events(action_name)
				InputMap.action_add_event(action_name, event)
				SettingsManager.save_key_mapping(action_name, event)
				
				is_remapping = false
				
				# ### CAMBIO AQUÍ: Apagamos el input de Alta Prioridad
				set_process_input(false)
				
				get_tree().call_group("BotonesRemap", "refresh_view")
				
				# Ya no necesitamos accept_event() porque usamos set_input_as_handled() arriba

# --- Resto de tus funciones originales (INTACTAS) ---
func limpiar_conflictos(nuevo_evento):
	for accion in InputMap.get_actions():
		if accion == action_name:
			continue
			
		if InputMap.action_has_event(accion, nuevo_evento):
			InputMap.action_erase_event(accion, nuevo_evento)

func update_button_text():
	var events = InputMap.action_get_events(action_name)
	
	if events.size() > 0:
		var nombre_tecla = events[0].as_text()
		nombre_tecla = nombre_tecla.replace(" (Physical)", "").replace(" - Physical", "")
		text = nombre_tecla
	else:
		text = "Sin asignar"

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if not is_visible_in_tree():
			cancelar_reasignacion()

func cancelar_reasignacion():
	if is_remapping:
		is_remapping = false
		# ### CAMBIO AQUÍ: Asegúrate de apagar el input correcto
		set_process_input(false)
