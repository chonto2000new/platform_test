extends CharacterBody2D
class_name PLAYER
const Ball = preload("uid://dyl6bwk7hmew2")
@export var mapa_bloques: TileMapLayer
@onready var right_outer: RayCast2D = $right_outer
@onready var right_inner: RayCast2D = $right_inner
@onready var left_outer: RayCast2D = $left_outer
@onready var left_inner: RayCast2D = $left_inner
@onready var player_animations: AnimatedSprite2D = $player_animations
@export var explosion_scene: PackedScene
@export var COYOTE_TIME: float = 0.1
const WALL_JUMP_LOCK_TIMER: float = 0.1
const WALL_CONTACT_COYOTE_TIME: float = 0.1
const JUMP_BUFFER_TIME: float = 0.12 # 100ms


var jump_buffer_timer: float = 0.0
var wall_contact_coyote: float = 0.0
var wall_jump_lock: float = 0.0
var coyote_timer: float = 0.0
var wall_jump_direction: float = 0.0

var JUMP_COUNT = 0
var MAX_JUMP = 2

const DECELERATION = 50.0
const AIR_SPEED = 140.0
const ACCELERATION = 300.0

const SPEED = 130.0
const aceleration := 500.0
const WALL_SLIDE_SPEED = 50.0
const JUMP_VELOCITY = -380.0
#const JUMP_WALL = -600.0
const JUMP_WALL = -180.0

const JUMP_WALL_X = 200.0


const AIR_ACCELERATION = 800.0
const AIR_FRICTION = 400.0

#var jumped_from_ground := false
var facing_right := true
var position_player: Vector2 = Vector2.ZERO

var states: PlayerStatesNames = PlayerStatesNames.new()

#shoot vars //////
@export var fire_rate: float = 0.2 # Tiempo en segundos entre disparos (0.5s)
var max_bullets = 4
var ball_array = []

var can_shoot: bool = true # Bandera para el control de tiempo


func _ready():
	add_to_group("player")
	
	teletransportar_a_save()


func teletransportar_a_save():
	# 1. ¿Existe una partida cargada en el Manager?
	if SaveManager.current_save == null:
		return # No hacemos nada, el player se queda donde lo pusiste en el editor

	# 2. (Opcional pero recomendado) ¿Estamos en la misma escena que se guardó?
	# Esto evita que si pones al player en el Menú Principal, intente irse a coordenadas raras.
	var escena_actual = get_tree().current_scene.scene_file_path
	var escena_guardada = SaveManager.current_save.current_scene_path
	
	if escena_actual == escena_guardada:
		# 3. VERIFICAR QUE LA POSICIÓN NO SEA (0,0) o vacía
		# A veces la primera vez es Vector2.ZERO, hay que tener cuidado.
		if SaveManager.current_save.player_position != Vector2.ZERO:
			global_position = SaveManager.current_save.player_position
			print("Player movido a checkpoint: ", global_position)


func _physics_process(delta: float):
	# 1. Gestionar el Input Buffer (Lógica Global de la Pulsación)
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer -= delta
		
	# 2. Mover la lógica del Coyote Time aquí (si no está en los estados)
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta
		
	if is_on_wall(): # O is_on_wall_only() si prefieres ser más estricto
		wall_contact_coyote = WALL_CONTACT_COYOTE_TIME # Resetear el contador mientras tocas
	else:
		wall_contact_coyote -= delta # Decrementar al dejar la pared
	
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()
	verificar_aplastamiento()
	

func shoot():
	# 1. Verificar cantidad de balas
	var current_bullets = get_tree().get_nodes_in_group("balls").size()
	
	if current_bullets <= max_bullets:
		var ball: BALL = Ball.instantiate()
		ball.SPEED = 1000.0
		ball.add_to_group("balls")
		
		# --- NUEVA LÓGICA DE DIRECCIÓN ---
		var shoot_direction = Vector2.ZERO
		
		# A. Prioridad 1: ¿Quiere disparar hacia ARRIBA?
		# Asegúrate de que "ui_up" esté configurado en tu Mapa de Entradas (Project Settings)
		if Input.is_action_pressed("ui_up"):
			shoot_direction = Vector2(0, -1) # Hacia arriba
			
		# B. Prioridad 2: ¿Está pegado a la pared y en el aire?
		# Usamos get_wall_normal() para disparar "hacia afuera" de la pared
		elif is_on_wall() and not is_on_floor():
			shoot_direction = Vector2(get_wall_normal().x, 0)
			
		# C. Prioridad 3: Disparo normal horizontal
		else:
			shoot_direction = Vector2(1, 0) if facing_right else Vector2(-1, 0)
			
		ball.direction = shoot_direction
		
		# --- SOLUCIÓN AL PROBLEMA DE LA PARED (EL OFFSET) ---
		# En lugar de usar solo global_position, le sumamos la dirección multiplicada por una distancia.
		# Esto hace que la bala "nazca" unos pixeles adelante (o arriba), evitando chocar con la pared o el propio jugador.
		var spawn_offset = 25.0 # Ajusta este valor según el tamaño de tu sprite
		ball.global_position = global_position + (shoot_direction * spawn_offset)
		
		get_tree().root.add_child(ball)
		
		# --- LÓGICA DEL RETARDO ---
		can_shoot = false
		start_cooldown_timer()

func start_cooldown_timer():
	# Creamos un temporizador temporal en código (es más limpio para esto)
	# create_timer crea un timer que se destruye solo al terminar
	await get_tree().create_timer(fire_rate).timeout

	# Una vez que el tiempo pasa, permitimos disparar de nuevo
	can_shoot = true


#func _physics_process(delta: float) -> void:
	#if right_outer.is_colliding() and !right_inner.is_colliding() \
		#and !left_inner.is_colliding() and !left_outer.is_colliding():
			#global_position.x -= 5
	#elif left_outer.is_colliding() and !right_inner.is_colliding() \
		#and !left_inner.is_colliding() and !right_outer.is_colliding():
			#global_position.x += 5
	#
	## Gravity
	#if not is_on_floor():
		#coyote_timer -= delta
		#velocity.y += GRAVITY * delta
		#
			#
	#else:
#
#
		#coyote_timer = COYOTE_TIME
		#JUMP_COUNT = 0
		#jumped_from_ground = false
		#cut_applied = false
#
	#if !is_on_floor() and velocity.y > 0 and is_on_wall():
		#wall_contact_coyote = WALL_CONTACT_COYOTE_TIME
	#else:
		#wall_contact_coyote -= delta
#
	#if is_on_wall() and not is_on_floor():
#
		#wall_jump_lock = WALL_JUMP_LOCK_TIMER
		## Limitar la velocidad hacia abajo (en lugar de sumar)
		#velocity.x = lerp(velocity.x, 0.0, 0.2)
		#JUMP_COUNT = 1
		#
		#if velocity.y > WALL_SLIDE_SPEED:
			#velocity.y = WALL_SLIDE_SPEED
	#
	#if Input.is_action_just_pressed("jump"):
		#if Input.is_action_pressed("ui_down") and is_on_floor():
			#position.y += 2
#
			## Empuje hacia el lado contrario de la pared
		#else:	
			#if is_on_floor() or coyote_timer > 0:
				## Saltando desde el suelo: permite doble salto
				#JUMP_COUNT = 1
				#jumped_from_ground = true
				#velocity.y = JUMP_VELOCITY
				#cut_applied = false
			#elif not is_on_floor() and JUMP_COUNT == 0:
				## Dejándose caer: solo permite un salto en el aire
				#JUMP_COUNT = 1
				#jumped_from_ground = false
				#velocity.y = JUMP_VELOCITY
				#cut_applied = false
			#elif JUMP_COUNT < MAX_JUMP and jumped_from_ground and wall_contact_coyote < 0:
		#
				## Doble salto solo si empezaste desde el suelo
				#JUMP_COUNT += 1
				#velocity.y = JUMP_VELOCITY 
				#cut_applied = false
			##if is_on_wall() and not is_on_floor() or wall_contact_coyote > 0:
			#if wall_contact_coyote > 0:
#
				#JUMP_COUNT = 1
				##cut_applied = true
				#cut_applied = false
				#jumped_from_ground = true
				#var wall_normal = get_wall_normal()
				#wall_normal =  wall_normal*1.5
				##var angle = 90
				##wall_normal.x = wall_normal.x * 2	
				## var direction = Vector2(wall_normal.x, -0.6)
				## var normalized_direction = direction.normalized()
				## velocity = normalized_direction * JUMP_WALL
#
				##velocity.y = lerp(0.0 ,JUMP_WALL, 0.05)
				##velocity.x = (JUMP_WALL_X * wall_normal.x) * 1.5
				##velocity.y = JUMP_WALL  # salto vertical
				##velocity.x = lerp(velocity.x, wall_normal.x  * JUMP_WALL_X, 0.3)
				## Impulso horizontal y vertical desacoplados para mejor control
				#velocity.x = wall_normal.x * JUMP_WALL_X
				#velocity.y = JUMP_WALL
					#
			#
			## Short jump if released early
	#if not is_on_floor():
		#if Input.is_action_just_released("jump") and velocity.y < 0 and not cut_applied:
			#
			#velocity.y *= 0.5
			#cut_applied = true
		#
#
#
	## Horizontal movement
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction > 0:
		#player_animations.flip_h = false
		#player_animations.play("walk")
	#elif direction < 0: 
		#player_animations.play("walk")
		#player_animations.flip_h = true
		#
	#if is_on_wall() and not is_on_floor():
		#if direction != 0:	
			#facing_right = !direction > 0
	#else:
		#if direction != 0:	
			#facing_right = direction > 0
		#
	##if Input.is_action_just_pressed("dash"):
			##var dash_speed = 1000 * delta 
			##var dash =  Vector2(dash_speed,0.0) * SPEED
			##velocity = dash
	#
	#if direction:
#
		#if wall_jump_lock > 0.0:
			#wall_jump_lock -= delta
			#velocity.x = lerp(velocity.x, direction * (SPEED /2 ),   0.3) 
		#else:
			#velocity.x = direction * SPEED
			#
	#else:
		#player_animations.play("idle")
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
	#set_floor_snap_length(4.0)
#


#func _input(event):
	##var ball_container = get_node("ballContainer")
	#if event.is_action("shoot"):  # botón de disparop
		#var cantidad = get_tree().get_nodes_in_group("balls").size()
		#if cantidad <= max_bullets:
			#var ball =BALL.instantiate()
			#ball.add_to_group("balls")
			#ball.global_position = global_position  # la posición del Player
			##bullet.direction = Vector2(1, 0) if facing_right else Vector2(-1, 0)
			#ball.direction = Vector2(1, 0) if facing_right else Vector2(-1, 0)
			#
			#get_tree().root.add_child(ball)


func _on_save_box_area_entered(_area: Area2D) -> void:
	pass


func _on_hurtbox_body_entered(_body: Node2D) -> void:
	death_player()

func _on_hurtbox_area_entered(_area: Area2D) -> void:
	death_player()


func apply_jump_pad_force(force_y: float):
	# Aquí puedes resetear estados si es necesario (ej: recuperar el doble salto)
	velocity.y = force_y
	JUMP_COUNT = 1
	
	#Opcional: velocity.x = 0 # Si quieres que el trampolín cancele el movimiento horizontal

	# Aquí iría tu animación futura, centralizada en un solo lugar:
	# animation_player.play("jump_start")

func verificar_aplastamiento():
	# 1. Obtenemos qué cuerpos sólidos están tocando nuestro "Hueso" interno
	var cuerpos_intrusos = get_node("player_crushed").get_overlapping_bodies()
	
	for cuerpo in cuerpos_intrusos:
		# 2. Si el cuerpo intruso es el mapa de bloques...
		if cuerpo == mapa_bloques:
			# ¡Significa que el bloque atravesó nuestra piel y tocó el sensor interno!
			death_player()

func death_player():
	var explosion = explosion_scene.instantiate()
	explosion.global_position = global_position
	get_parent().add_child(explosion)
	#SoundManager.play_death_sound()
	queue_free()
