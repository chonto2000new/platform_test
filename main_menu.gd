extends Control

# Referencias a los contenedores
@onready var menu_inicio = $MenuInicio
@onready var player: TextureRect = $player
@onready var label_titulo: Label = $LabelTitulo


@onready var menu_slots = $MenuSlots
@onready var options: Control = $Options


const NIVEL_PRUEBAS = "res://main.tscn"
# Referencias a los botones clave para el "Focus" (Teclado)
@onready var btn_jugar = $MenuInicio/BtnJugar
@onready var slot_1 = $MenuSlots/HBoxSlots/SaveSlot
@onready var control: Button = $Options/MarginContainer/HBoxContainer/AllOptions/control

@onready var btn_volver = $MenuSlots/BtnVolver

# Referencias a los 3 slots para configurarlos
@onready var all_slots = [
	$MenuSlots/HBoxSlots/SaveSlot,
	$MenuSlots/HBoxSlots/SaveSlot2,
	$MenuSlots/HBoxSlots/SaveSlot3
]

@onready var botones = [
	$MenuInicio/BtnJugar,
	$MenuInicio/BtnOpciones,
	$MenuInicio/BtnSalir
]

const OPTION_BUTTON_CONFIG = preload("uid://b82r3jelsfqey")
@onready var buttons: VBoxContainer = $Options/MarginContainer/HBoxContainer/ControlData/buttons


@onready var selector: TextureRect = %selector
@export var input_activo: bool = false
@onready var intro: AnimationPlayer = %intro

func _ready():
	# ... (tu código de configuración de slots sigue igual) ...
	var index = 1
	for slot in all_slots:
		slot.set_slot_index(index)
		slot.slot_selected.connect(_on_slot_selected)
		slot.play_requested.connect(_on_slot_play)
		slot.delete_requested.connect(_on_slot_delete)
		
		# Conectamos los focos para que la flecha se mueva
		# Usamos una lambda para pasar un offset menor (ej. 10) para que la flecha esté más pegada
		# --- AQUÍ ESTÁ LA VARIABLE: Cambia el 10 por un número menor si quieres la flecha más cerca ---
		slot.internal_button_focused.connect(func(btn): _on_button_focus_entered(btn, 3))
		# Conectamos la señal para ocultar la flecha en el menú de confirmación (Sí/No)
		slot.hide_selector_requested.connect(_on_slot_focused)
		# También conectamos el slot en sí, para que la flecha apunte a la tarjeta grande
		slot.focus_entered.connect(_on_slot_focused)
		index += 1
	
	for btn in botones:
		btn.focus_entered.connect(_on_button_focus_entered.bind(btn))
		# Desactivamos el foco temporalmente para que no se mueva durante la intro
		btn.focus_mode = Control.FOCUS_NONE
	
	# --- AQUÍ ESTÁ EL CAMBIO ---
	
	# 1. Asegúrate de que el menú sea visible para que la animación se vea
	menu_inicio.visible = true
	menu_slots.visible = false
	
	# 2. Ocultamos el selector (la flecha) para que no aparezca todavía
	selector.visible = false
	
	# 3. Iniciamos la animación
	intro.play("intro")
	
	# 4. ¡BORRA O COMENTA ESTA LÍNEA! 
	# ver_inicio()  <-- ESTO ES LO QUE ROMPÍA LA ESPERA
func config_buttons():
	# 1. Limpieza
	for hijo in buttons.get_children():
		hijo.queue_free()

	# 2. Creación
	for action in SettingsManager.input_actions:
		# Aquí "fila" es el HBoxContainer (la caja entera)
		var fila = OPTION_BUTTON_CONFIG.instantiate()
		buttons.add_child(fila)
		
		# --- CORRECCIÓN AQUÍ ---
		# Buscamos el nodo hijo llamado "button" (o como le hayas puesto en tu escena)
		# Asegúrate de que en tu escena option_button_config.tscn el botón se llame "button"
		var boton_real = fila.find_child("button", true, false)
		
		if boton_real and boton_real.has_method("setup_button"):
			boton_real.setup_button(action)
		else:
			print("ERROR: No encontré el nodo 'button' dentro de la fila o no tiene el script")


func ver_inicio():
	menu_slots.visible = false
	options.visible = false
	label_titulo.visible = true
	menu_inicio.visible = true
	selector.visible = true
	player.visible = true
	
	# CRUCIAL: Poner el foco en "Jugar" para que el teclado funcione al instante
	btn_jugar.grab_focus()

func ver_slots():
	menu_inicio.visible = false
	selector.visible = false
	player.visible = false
	menu_slots.visible = true
	
	# Actualizamos la info visual (muertes, jefes) antes de mostrar
	for slot in all_slots:
		slot.actualizar_visuales()
	
	# CRUCIAL: Poner el foco en el Slot 1
	slot_1.grab_focus()
	
	
func ver_options():
	config_buttons()
	menu_inicio.visible = false
	label_titulo.visible = false
	selector.visible = false
	player.visible = false
	menu_slots.visible = false
	options.visible = true
	
	control.grab_focus()

# --- SEÑALES DE LOS BOTONES (Conéctalas desde el editor) ---

func _on_btn_jugar_pressed():
	ver_slots()

func _on_btn_opciones_pressed():
	ver_options()
	print("Aquí abrirías el menú de opciones")
	# get_tree().change_scene_to_file("res://menus/options_menu.tscn")

func _on_btn_salir_pressed():
	get_tree().quit()

func _on_btn_volver_pressed():
	ver_inicio()

# --- LÓGICA DE CARGA DE PARTIDA ---

func _on_slot_selected(slot_id):
	print("Seleccionado Slot: ", slot_id)
	
	# 1. Primero cerramos cualquier otro slot que pudiera estar abierto
	for s in all_slots:
		if s.slot_id != slot_id and s.has_method("show_text"):
			s.show_text()
	
	# 2. Calculamos el índice correcto (Array empieza en 0, Slot_id en 1)
	var id = slot_id - 1
	
	if id >= 0 and id < all_slots.size():
		var actual_slot = all_slots[id]
		if actual_slot.has_method("hide_text"):
			actual_slot.hide_text()

func _on_slot_play(slot_id):
	print("JUGAR partida del Slot: ", slot_id)
	
	# 1. Cargar la partida en memoria (SaveManager)
	SaveManager.load_game(slot_id)
	
	# 2. Obtener la data actual
	var save_data = SaveManager.current_save
	
	# 3. VERIFICACIÓN: ¿Es una partida nueva?
	# Si current_scene_path está vacío, es que nunca hemos guardado aquí.
	if save_data.current_scene_path == "":
		print("Detectada partida nueva. Iniciando configuración inicial...")
		
		# --- CONFIGURACIÓN DE PARTIDA NUEVA ---
		save_data.current_scene_path = NIVEL_PRUEBAS
		save_data.actual_level = "Inicio" # Nombre para mostrar en el menú
		save_data.death_count = 0
		save_data.defeated_bosses.clear()
		
		# IMPORTANTE: Guardamos inmediatamente para que el slot deje de estar "Vacío"
		# y ya aparezca como "Partida 1" si vuelves al menú.
		SaveManager.save_game()
	
	# 4. Cambiar a la escena correspondiente
	# (Sea la nueva que acabamos de asignar o la vieja que ya tenía)
	get_tree().change_scene_to_file(save_data.current_scene_path)

func _on_slot_delete(slot_id):
	print("BORRAR partida del Slot: ", slot_id)
	
	# 1. Borramos el archivo físico (Usamos el ID directo como indicaste)
	SaveManager.delete_save(slot_id)
	
	# 2. Actualizamos la interfaz visual
	# Usamos [slot_id - 1] solo para seleccionar el botón correcto de la lista en pantalla
	var slot_ui = all_slots[slot_id - 1]
	
	slot_ui.actualizar_visuales() # Al no haber archivo, se pondrá en modo "VACÍO" / "Nueva Partida"
	slot_ui.show_text() # Cierra los botones Play/Delete y muestra el texto normal
	slot_ui.grab_focus() # Devolvemos el control al slot para que no se pierda el foco
	

func _on_button_focus_entered(boton_seleccionado, offset_x = 50):
	selector.visible = true
	# Calculamos la posición donde debe ir la flecha
	# Ajusta el 'offset_x' para separar la flecha del texto
	# El valor por defecto es 50 (Menú principal), pero puede venir otro valor (ej. 10 para slots)
	var ajuste_vertical = 80 # Ponle 5, 10, -5, etc.

	var nueva_pos = Vector2(
		boton_seleccionado.global_position.x - offset_x,
		boton_seleccionado.global_position.y + (boton_seleccionado.size.y / 2) - (selector.size.y / 2) + ajuste_vertical
	)
		# Opción A: Movimiento instantáneo (más retro)
	selector.global_position = nueva_pos
	
	# Opción B: Movimiento suave (Tween) - Descomenta si prefieres animación
	# var tween = create_tween()
	# tween.tween_property(selector, "global_position", nueva_pos, 0.1)


func _on_intro_terminada():
	print("¡Animación terminada!")
	input_activo = true
	
	# Reactivamos los botones para que puedan recibir foco
	for btn in botones:
		btn.focus_mode = Control.FOCUS_ALL
	
	# 1. Aseguramos que el selector sea visible
	selector.visible = true
	
	# 2. Damos el foco al primer botón
	if botones.size() > 0:
		botones[0].grab_focus()
		
		# 3. EL TRUCO: Usamos call_deferred para mover la flecha
		# Esto espera a que la interfaz termine de acomodarse antes de calcular la posición
		call_deferred("actualizar_posicion_flecha_inicial")

func _on_slot_focused():
	selector.visible = false

func actualizar_posicion_flecha_inicial():
	# Forzamos manualmente la función de movimiento usando el primer botón
	if botones.size() > 0:
		_on_button_focus_entered(botones[0])


func _on_btn_reset_pressed():
	# 1. Llamamos al manager para que resetee la lógica interna y el archivo
	SettingsManager.reset_to_defaults()
	
	# 2. IMPORTANTE: Decimos a todos los botones visuales que se actualicen
	# Como ya están en el grupo "BotonesRemap", esto actualizará sus textos
	# al valor original (ej. de "Z" volverá a "Espacio" si ese era el default)
	get_tree().call_group("BotonesRemap", "refresh_view")

func _unhandled_input(event):
	# Si la intro no ha terminado, ignoramos cualquier input
	if not input_activo:
		return

	# Detectamos "ui_cancel" (Escape o Botón B/Círculo en mando)
	# Si quieres que tu botón de disparo también sirva para volver, agrégalo con 'or event.is_action_pressed("disparo")'
	if event.is_action_pressed("ui_cancel"):
		if options.visible:
			ver_inicio()
			get_viewport().set_input_as_handled()
		elif menu_slots.visible:
			ver_inicio()
			get_viewport().set_input_as_handled()
