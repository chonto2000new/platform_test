extends Node2D
class_name SpakeBase

@export var radar: Area2D
@export var hurtbox: AnimatableBody2D
# Velocidad de escape
@export var velocidad: float = 300.0 

var direccion_movimiento: Vector2 = Vector2.ZERO
var moviendose: bool = false

func _ready() -> void:
	# Conectamos la señal. Asegúrate de que tu Area2D tenga monitoreo activado.
	radar.body_entered.connect(_on_body_entered)



func _physics_process(delta: float) -> void:
	if moviendose:
		# Mueve el objeto en la dirección fija calculada
		hurtbox.position += direccion_movimiento * velocidad * delta

func _on_body_entered(body: Node2D):
	#print("Detectado: ", body.name)
	
	# CORRECCIÓN: Destino (Jugador) - Origen (Yo)
	# Esto nos da la flecha que apunta hacia el jugador
	var diferencia = body.global_position - global_position
	
	# --- LÓGICA CARDINAL ---
	if abs(diferencia.x) > abs(diferencia.y):
		# El jugador está más lejos horizontalmente
		if diferencia.x > 0:
			direccion_movimiento = Vector2.RIGHT # Ir a la Derecha
		else:
			direccion_movimiento = Vector2.LEFT  # Ir a la Izquierda
	else:
		# El jugador está más lejos verticalmente
		if diferencia.y > 0:
			direccion_movimiento = Vector2.DOWN  # Ir Abajo
		else:
			direccion_movimiento = Vector2.UP    # Ir Arriba
	
	moviendose = true
