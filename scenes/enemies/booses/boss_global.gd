class_name AppleBoss extends BossEntity


@onready var r_up: RayCast2D = $R_UP
@onready var r_down: RayCast2D = $R_DOWN
@onready var r_left: RayCast2D = $R_LEFT
@onready var r_right: RayCast2D = $R_RIGHT
@export var modo_vertical: bool = false

var only_apple = 0
@export var player_target: Node2D # Arrastra al jugador o búscalo en el _ready
const APPLE_BALL_ATACK = preload("uid://b67jp30e0jujs")
const CIRCLE_BALL = preload("uid://djq0ug3wmrdwx")

const ball_cantidad := 1

#timers
@onready var cambiar_face: Timer = $cambiar_face


#states
var apple_boss_states_names:AppleBossStatesNames = AppleBossStatesNames.new()


func _ready() -> void:
	boss_hp = 120
	velocidad_entrada = 3.0
		# Si no asignaste al jugador manual, búscalo (igual que con tu cámara)
	if not player_target:
		player_target = get_parent().find_child("player")



func _on_timer_timeout_player_follow():
	if not player_target: return # Si el jugador murió, no disparamos
	
	var tiempo_entre_balas = 0.2 # 200 milisegundos de espera
	
	for i in range(ball_cantidad):
		# Chequeo de seguridad: ¿El jugador sigue vivo?
		# (Puede que muera justo entre la bala 1 y la 2)
		if not player_target: 
			break 
		
		shoot_at_player()
		
		# AQUÍ ESTÁ EL TRUCO:
		# Detenemos la función solo por un momentito antes de seguir el ciclo
		await get_tree().create_timer(tiempo_entre_balas).timeout
	
	shoot_at_player()

func shoot_at_player():
	# 1. Crear la instancia
	var ball = APPLE_BALL_ATACK.instantiate()
	
	# 2. Posicionar la bola donde está el enemigo
	ball.global_position = global_position
	
	# 3. CÁLCULO DE LA DIRECCIÓN (La parte importante)
	# Destino (Jugador) - Origen (Enemigo) = Vector Dirección
	
	
	# Modificar ligeramente el ángulo (entre -15 y +15 grados por ejemplo)
	var spread = deg_to_rad(randf_range(-15, 15)) 
	var dir_vector = 0.0
	if !player_target:
		dir_vector = Vector2(0.0,-1.0)
	else:
		dir_vector = (player_target.global_position - global_position).normalized()
		
	
	dir_vector = dir_vector.rotated(spread)
	
	ball.set_move_direction(dir_vector)
	
	# 4. Le pasamos el vector a la bola
	ball.set_move_direction(dir_vector)
	
	# 5. Agregar la bola a la escena (¡NO al enemigo, sino al mundo!)
	# Usamos get_parent() o get_tree().current_scene
	get_parent().add_child(ball)
