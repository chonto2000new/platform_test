class_name BossEntity extends CharacterBody2D


@export var boss_hp : int = 100
@export var ball_speed : float = 300.0
@export var damage_power : int = 10


#movimiento
@export var velocidad_entrada : float = 2.0

@export var velocidad_horizontal : float = 200.0  # Qué tan rápido va de izq a der
@export var amplitud_vertical : float = 180.0     # Qué tan ALTO sube y baja (fuerza)
@export var frecuencia : float = 10.0              # Qué tan RÁPIDO hace las ondas


@export var velocidad_iddle : float = 600.0              # Qué tan RÁPIDO hace las ondas


var tiempo : float = 0.0
var direccion_x : int = 1 # 1 = Derecha, -1 = Izquierda

var velocidad_x: float = 200.0
var velocidad_y: float = 200.0


var dir_x : int = 1
var dir_y : int = 1

var tween_hit: Tween

# Aquí pones lo que TODOS los jefes tienen en común
func moverse_al_centro():
	print("Moviéndome al centro...")

func recibir_dano(cantidad):
	print("Auch!")



func take_damage(damage:int,velocidad = null):


	boss_hp -= damage 
	print("muelto",boss_hp)
	
	damage_effect()
	
	if boss_hp <= 0:
		print("muelto")
		queue_free()
		
		#if enemy.enemy_actual_animation == enemy.animations.croler:
				#state_machine.change_to(enemy.states.perma_death)
				#return
			
		#var numero = randi_range(0, 4) # Genera 0, 1, 2, 3 o 4
		#match numero:
			#0, 1:
				#state_machine.change_to(enemy.states.death)
			## Tu código aquí (ej. generar un enemigo débil)
			#2, 3, 4:
				#state_machine.change_to(enemy.states.perma_death)
			## Tu código aquí (ej. generar un enemigo fuerte)


func damage_effect():
	# 1. Si ya había un tween corriendo, MÁTALO para que no estorbe
	if tween_hit and tween_hit.is_valid():
		tween_hit.kill()
	
	# 2. Guardamos el nuevo tween en la variable
	tween_hit = create_tween()
	
	modulate = Color(10, 10, 10, 1) 
	tween_hit.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.15)
