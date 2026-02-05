extends Button

# Señal que avisa al menú: "¡Hey, el jugador eligió el Slot X!"
signal slot_selected(slot_id)
signal play_requested(slot_id)
signal delete_requested(slot_id)
# Nueva señal para avisar al menú principal que mueva la flecha
signal internal_button_focused(button_node)
signal hide_selector_requested

var slot_id: int = 1
var is_empty: bool = true

# --- Referencias a tus nodos (Según tu imagen) ---
# Si cambiaste algún nombre en el editor, ajustalo aquí
@onready var label_titulo = $MarginContainer/VBoxContainer/slot_name
@onready var label_info = $MarginContainer/VBoxContainer/deaths_count
@onready var grid_jefes = $MarginContainer/VBoxContainer/GridContainer
@onready var menu_play: VBoxContainer = $MarginContainer/VBoxContainer/MenuPlay
# Asumimos que dentro de MenuPlay tienes botones llamados "play" y "delete"
@onready var btn_play = $MarginContainer/VBoxContainer/MenuPlay/play
# Si tu botón de borrar tiene otro nombre, ajustalo aquí:
@onready var btn_delete = $MarginContainer/VBoxContainer/MenuPlay/delete
# Referencias al nuevo menú de confirmación
@onready var menu_confirm = $MarginContainer/VBoxContainer/MenuPlay/IsDelete
@onready var btn_yes = $MarginContainer/VBoxContainer/MenuPlay/IsDelete/yes
@onready var btn_no = $MarginContainer/VBoxContainer/MenuPlay/IsDelete/no

func _ready():
	# Conectamos las señales básicas del botón
	pressed.connect(_on_pressed)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	
	# Aseguramos que el menú de confirmación empiece oculto
	if menu_confirm:
		menu_confirm.hide()
	
	# Conectamos los botones internos
	if btn_play:
		btn_play.pressed.connect(func(): play_requested.emit(slot_id))
		btn_play.focus_entered.connect(func(): internal_button_focused.emit(btn_play))
	if btn_delete:
		# CAMBIO: Ahora en lugar de borrar directo, abre el menú de confirmación
		btn_delete.pressed.connect(_on_delete_pressed)
		btn_delete.focus_entered.connect(func(): internal_button_focused.emit(btn_delete))
	
	# Conectamos los botones de confirmación
	if btn_yes:
		btn_yes.pressed.connect(func(): delete_requested.emit(slot_id))
		# Configuración de foco para que no se escape
		btn_yes.focus_neighbor_top = btn_no.get_path()
		btn_yes.focus_neighbor_bottom = btn_no.get_path()
		btn_yes.focus_neighbor_left = btn_yes.get_path()
		btn_yes.focus_neighbor_right = btn_yes.get_path()
		btn_yes.focus_entered.connect(func(): hide_selector_requested.emit())
		
	if btn_no:
		btn_no.pressed.connect(_on_cancel_delete)
		btn_no.focus_neighbor_top = btn_yes.get_path()
		btn_no.focus_neighbor_bottom = btn_yes.get_path()
		btn_no.focus_neighbor_left = btn_no.get_path()
		btn_no.focus_neighbor_right = btn_no.get_path()
		btn_no.focus_entered.connect(func(): hide_selector_requested.emit())
		
	# --- CONFIGURACIÓN DE FOCO (Focus Neighbors) ---
	# Esto hace que si estás en Play y bajas, vas a Delete. Y viceversa.
	# Y evita que te salgas a los lados accidentalmente.
	if btn_play and btn_delete:
		btn_play.focus_neighbor_top = btn_delete.get_path()
		btn_play.focus_neighbor_bottom = btn_delete.get_path()
		# --- CORRECCIÓN: Bloqueamos la salida lateral ---
		# Al apuntar a sí mismo, si presionas Derecha/Izquierda, no se va al Slot 2
		btn_play.focus_neighbor_left = btn_play.get_path()
		btn_play.focus_neighbor_right = btn_play.get_path()
		
		btn_delete.focus_neighbor_top = btn_play.get_path()
		btn_delete.focus_neighbor_bottom = btn_play.get_path()
		# Lo mismo para el botón de borrar
		btn_delete.focus_neighbor_left = btn_delete.get_path()
		btn_delete.focus_neighbor_right = btn_delete.get_path()

# Esta función la llama el MainMenu para decir "Tú eres el Slot 1, tú el 2..."
func set_slot_index(index: int):
	slot_id = index
	actualizar_visuales()

func actualizar_visuales():
	# Pedimos al Manager ver qué hay en este archivo (sin cargarlo aún)
	var data = SaveManager.get_save_data_preview(slot_id)
	
	# Limpiamos los iconos viejos del grid (por si acaso)
	for child in grid_jefes.get_children():
		child.queue_free()

	if data == null:
		is_empty = true
		# --- CASO: NO HAY PARTIDA ---
		label_titulo.text = "VACÍO"
		label_info.text = "-- Nueva Partida --"
		# Hacemos el texto un poco transparente
		modulate = Color(0.8, 0.8, 0.8, 1)
	else:
		is_empty = false
		# --- CASO: SÍ HAY PARTIDA ---
		label_titulo.text = "PARTIDA " + str(slot_id)
		
		# Mostramos datos reales
		# Asegúrate que tu SaveGameData tenga estas variables (actual_level, death_count, etc)
		var texto = "Nivel: %s\nMuertes: %d" % [data.actual_level, data.death_count]
		# Nota: Puse 0 en muertes porque no sé si ya agregaste esa variable a tu SaveData.
		# Si ya la tienes, cambia el 0 por: data.death_count
		
		label_info.text = texto
		modulate = Color.WHITE
		
		# --- CARGAR JEFES ---
		# Por cada jefe derrotado, creamos un cuadrito
		for boss in data.defeated_bosses:
			var icon = TextureRect.new()
			# Si tienes icono guardado lo usa, si no, usa uno por defecto
			if boss.icon_path != "":
				icon.texture = load(boss.icon_path)
			else:
				# Icono de fallback (el icono de Godot por ejemplo)
				icon.texture = preload("res://icon.svg")
				
			icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
			icon.custom_minimum_size = Vector2(32, 32)
			grid_jefes.add_child(icon)

# --- INTERACCIÓN ---

func _on_pressed():
	# Al dar Enter o Click
	slot_selected.emit(slot_id)

func _on_focus_entered():
	# Cuando el teclado selecciona este botón
	# Hacemos que crezca un poquito (efecto pop)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1)
	
	# Opcional: Cambiar el color del borde si quieres
	# add_theme_constant_override("outline_size", 2)

func _on_focus_exited():
	# Cuando el teclado se va a otro botón
	# Vuelve al tamaño normal
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)


func hide_text():
	label_titulo.hide()
	label_info.hide()
	menu_play.show()
	
	# Aseguramos estado inicial: Botones principales visibles, confirmación oculta
	if btn_play: btn_play.show()
	
	# LÓGICA DE VISIBILIDAD SEGÚN SI HAY PARTIDA O NO
	if is_empty:
		if btn_delete: btn_delete.hide()
		# Si no hay botón de borrar, Play debe apuntarse a sí mismo arriba/abajo
		if btn_play:
			btn_play.focus_neighbor_top = btn_play.get_path()
			btn_play.focus_neighbor_bottom = btn_play.get_path()
	else:
		if btn_delete: btn_delete.show()
		# Si hay botón de borrar, restauramos la navegación entre ellos
		if btn_play and btn_delete:
			btn_play.focus_neighbor_top = btn_delete.get_path()
			btn_play.focus_neighbor_bottom = btn_delete.get_path()
			btn_delete.focus_neighbor_top = btn_play.get_path()
			btn_delete.focus_neighbor_bottom = btn_play.get_path()

	if menu_confirm: menu_confirm.hide()
	
	# 1. Desactivamos el botón padre (el slot) para que no robe clics ni foco
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	
	# 2. Pasamos el foco al botón de jugar
	if btn_play:
		btn_play.grab_focus()
	
func show_text():
	label_titulo.show()
	label_info.show()
	menu_play.hide()
	
	# 1. Reactivamos el botón padre
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	
	# 2. Recuperamos el foco (opcional, pero recomendado para navegación con teclado)
	grab_focus()

func _input(event):
	# Si el menú de Play/Delete está visible y presionamos "Cancelar" (Esc o B en mando)
	if menu_play.visible and event.is_action_pressed("ui_cancel"):
		accept_event() # Evita que el evento se propague
		
		# Si estamos en la confirmación, volvemos al menú Play/Delete
		if menu_confirm.visible:
			_on_cancel_delete()
		else:
			# Si estamos en Play/Delete, cerramos el slot completamente
			show_text()

func _on_delete_pressed():
	# Ocultamos Play/Delete y mostramos Confirmación
	btn_play.hide()
	btn_delete.hide()
	menu_confirm.show()
	if btn_no: btn_no.grab_focus() # Por seguridad, foco en NO

func _on_cancel_delete():
	# Ocultamos Confirmación y mostramos Play/Delete
	menu_confirm.hide()
	btn_play.show()
	btn_delete.show()
	if btn_delete: btn_delete.grab_focus()
