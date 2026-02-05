extends Area2D
class_name BALL
var SPEED:float = 900.0
var direction := Vector2.ZERO
var ball_damage := 1
# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
var velocidad = Vector2.ZERO

func _process(delta: float) -> void:
	
	velocidad = direction * SPEED 
	position += velocidad * delta
	
	
	
	
		


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()



#const VELOCIDAD_MAXIMA: float = 1000.0
#const ACELERACION: float = 2000.0 
#var velocidad_actual: float = 200.0
#
#func _physics_process(delta: float) -> void:
	## 1. ACELERAR: Esta lógica es idéntica y funciona perfecto.
	#velocidad_actual = move_toward(velocidad_actual, VELOCIDAD_MAXIMA, ACELERACION * delta)
	#
	## 2. MOVER: Esto también funciona perfecto con Area2D.
	#position += direction * velocidad_actual * delta
#
 

func _on_entered(scene: Node2D) -> void:
	#print(" Golpé al cuerpo: ", scene.name, " | ShapeID: ", scene.get_instance_id())
	# 1. Obtenemos al PADRE del área (que es "enemy_base")
	var enemigo_real = scene.get_parent()
	
	# 2. Verificamos si el PADRE tiene la función (el cerebro)
	if enemigo_real.has_method("take_damage"):

		enemigo_real.take_damage(ball_damage, velocidad)
	elif scene.has_method("take_damage"):
		scene.take_damage(ball_damage, velocidad)
	# 3. Destruir la bala
	queue_free()
		
