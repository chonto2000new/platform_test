extends Area2D

@export var damage: int = 1
@export var velocidad_inicial: float = 0.0
@export var gravedad: float = 700.0 # Qué tan rápido acelera hacia abajo

var velocidad_actual_y: float = 0.0

func _ready():
	velocidad_actual_y = velocidad_inicial
	
	# Conectamos la señal por código para asegurar que funcione, 
	# o hazlo desde el editor (Node -> Signals -> body_entered)
	#body_entered.connect(_on_body_entered)

func _physics_process(delta):
	# 1. Calcular gravedad
	velocidad_actual_y += gravedad * delta
	
	# 2. Mover el objeto (al ser Area2D movemos position directamente)
	position.y += velocidad_actual_y * delta

func _on_body_entered(body):
	# CASO 1: Chocó con el Jugador
	if body.name == "Player" or body.is_in_group("Player"): 
		if body.has_method("take_damage"): # O como se llame tu función de daño
			body.take_damage(damage)
		queue_free() # El pico desaparece tras golpear
	
	# CASO 2: Chocó con el Suelo (TileMap o Paredes)
	# Asegúrate de que tu suelo esté en un Grupo "Suelo" o usa capas de colisión
	elif body is TileMap or body.name == "Suelo": 
		queue_free() # El pico se rompe en el suelo


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
