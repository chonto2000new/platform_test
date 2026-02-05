extends CPUParticles2D

func _ready():
	emitting = true # Activa la explosión al nacer
	
	# Opción A: Usar la señal 'finished' (funciona en Godot 4)
	finished.connect(_on_finished)

func _on_finished():
	queue_free() # Se borra a sí misma de la memoria
