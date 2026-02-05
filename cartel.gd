class_name CARTEL extends Node2D

@export_group("Configuración del Cartel")
@export var mensaje: Label
@export var sprite_2d: Sprite2D
@export var area_2d: Area2D 

# --- NUEVO: Variable para activar la lógica ---
@export_group("Configuración de Efectos")
@export var usar_maquina_escribir: bool = false
@export var velocidad_escritura: float = 1.0 # Tiempo que tarda en escribirse

var tween_actual: Tween 

func _ready():
	if !mensaje or !sprite_2d or !area_2d:
		push_error("¡OJO! Faltan referencias en: " + name)
		return # Agregué return para que no crashee si falta algo
		
	mensaje.modulate.a = 0 
	sprite_2d.modulate.a = 0 
	area_2d.set_collision_mask_value(2,true)
	
	# Aseguramos el estado inicial de las letras
	mensaje.visible_ratio = 0.0 if usar_maquina_escribir else 1.0
	
	area_2d.body_entered.connect(_on_area_2d_body_entered)
	area_2d.body_exited.connect(_on_area_2d_body_exited)
	
func _on_area_2d_body_entered(body):
	#if body.name == "Player":
	animar_mensaje(true) 

func _on_area_2d_body_exited(body):
	#if body.name == "Player":
	animar_mensaje(false) 

func animar_mensaje(mostrar: bool):
	if tween_actual:
		tween_actual.kill()
	
	tween_actual = create_tween()
	tween_actual.set_parallel(true)
	
	var objetivo_alpha = 1.0 if mostrar else 0.0
	
	# 1. El Sprite siempre hace Fade In/Out normal
	tween_actual.tween_property(sprite_2d, "modulate:a", objetivo_alpha, 0.5)
	
	# 2. Lógica diferenciada para el Texto
	if usar_maquina_escribir:
		if mostrar:
			# Reseteamos las letras a 0 antes de animar
			mensaje.visible_ratio = 0.0 
			# Hacemos el texto opaco (para que se vean las letras al salir)
			tween_actual.tween_property(mensaje, "modulate:a", 1.0, 0.2)
			# Animamos la escritura (de 0 a 1)
			tween_actual.tween_property(mensaje, "visible_ratio", 1.0, velocidad_escritura)
		else:
			# Al ocultar, solo hacemos fade out (queda mejor que borrar letra por letra)
			tween_actual.tween_property(mensaje, "modulate:a", 0.0, 0.3)
	else:
		# Lógica clásica (Solo Fade In/Out)
		mensaje.visible_ratio = 1.0 # Asegura que el texto esté completo
		tween_actual.tween_property(mensaje, "modulate:a", objetivo_alpha, 0.5)
