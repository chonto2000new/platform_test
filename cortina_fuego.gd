extends Area2D

@export var velocidad: float = 300.0
var direccion: int = 0 # 1 derecha, -1 izquierda

func _physics_process(delta):
	# Mueve la flama en la dirección asignada
	position.x += velocidad * direccion * delta

# Opcional: Borrar si sale de pantalla
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _ready():
	# 1. Empezamos invisibles y aplastados
	scale = Vector2(1, 0) 
	
	# 2. Creamos el Tween
	var tween = create_tween()
	
	# IMPORTANTE: Usar set_process_mode para sincronizar con físicas si es muy rápido
	# Pero para efectos visuales/daño, el default suele bastar.
	
	# FASE 1: Crecer (Subir)
	# Tweeneamos la propiedad "scale" hacia (1, 1) en 0.2 segundos
	# Usamos EASE_OUT y TRANS_BACK para que dé un efecto de "fwoosh" explosivo
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	# Esperar un momento arriba (opcional)
	tween.tween_interval(1.2)
	
	# FASE 2: Desaparecer (Bajar)
	# Vuelve a escala 0 en Y
	tween.tween_property(self, "scale", Vector2(1, 0), 0.2)
	
	# Al terminar, borramos la flama
	tween.tween_callback(queue_free)
