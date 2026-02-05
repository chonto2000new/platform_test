class_name BossData extends Resource

# Aquí defines estrictamente qué datos componen a un "Jefe" en tu guardado
@export var boss_id: String = ""
@export var boss_name: String = "Nombre Desconocido"
@export var defeat_time: float = 0.0
@export var difficulty_beaten: String = "Normal"

# NOTA SOBRE IMÁGENES:
# No se recomienda guardar la Textura entera en el archivo de guardado (pesa mucho).
# Es mejor guardar la ruta (String) a la imagen en tus archivos del juego.
@export var icon_path: String = "res://assets/ui/icons/default_boss.png"

# Si necesitas guardar metadatos extra
@export var stats: Dictionary = {}
