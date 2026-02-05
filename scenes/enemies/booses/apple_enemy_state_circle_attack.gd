extends AppleBossStateBase
var mi_timer: Timer
var attack_timer:Timer


# Nueva variable para llevar la cuenta del giro
var rotacion_actual_grados = 0.0
# Velocidad de giro: Cuanto más alto, más rápido gira el patrón
var velocidad_giro = 8.0 

# Variables arriba
var rotacion_actual = 0.0
var velocidad_giro_patron = 15.0 # Ajusta esto: más alto = espiral más cerrada

#ataques cantidades controles 
#circle_attack 
var cantidad_balas_circle_attack := 17 # Cuantas balas tiene el círculo



func start():
	mi_timer = Timer.new()
	# Un tiempo un poco más rápido ayuda a que se vea mejor la espiral
	mi_timer.wait_time = 0.3
	mi_timer.one_shot = false 
	mi_timer.timeout.connect(_on_timer_disparo_timeout)
	add_child(mi_timer)
	mi_timer.start()
	#tiempo_ataque
	attack_timer = Timer.new()
	# Un tiempo un poco más rápido ayuda a que se vea mejor la espiral
	attack_timer.wait_time = 6.0
	attack_timer.one_shot = true 
	attack_timer.timeout.connect(_on_timer_attack_timeout)
	add_child(attack_timer)
	attack_timer.start()

func end():
	mi_timer.queue_free()
	attack_timer.queue_free()
	

func _on_timer_disparo_timeout():
	# 1. Giramos el cañón imaginario
	rotacion_actual += velocidad_giro_patron
	
	# 2. Disparamos con ese ángulo
	disparar_anillo(rotacion_actual)

func _on_timer_attack_timeout():
	state_machine.change_to(apple.apple_boss_states_names.state_idle)
	


func disparar_anillo(angulo_base):
	var paso = 360.0 / cantidad_balas_circle_attack
	
	for i in range(cantidad_balas_circle_attack):
		var angulo_final = angulo_base + (i * paso)
		var rad = deg_to_rad(angulo_final)
		
		var bala = apple.CIRCLE_BALL.instantiate()
		get_parent().add_child(bala)
		bala.global_position = apple.global_position
		
		# Le damos la dirección RECTA basada en el ángulo actual
		bala.direccion = Vector2(cos(rad), sin(rad))
		bala.rotation = rad
