class_name SaveGameData extends Resource

# Definimos las variables con tipos estrictos.
# Usamos @export para que Godot sepa que debe guardar estos datos en el disco.

@export var actual_level: String = "first"
@export var player_position: Vector2 = Vector2.ZERO
@export var current_scene_path: String = ""
@export var inventory: Array[String] = []
@export var defeated_bosses: Array[BossData] = []
@export var death_count: int = 0  # Agregué esta porque la usas en el slot
@export var timestamp: String = "" # Para saber cuándo se guardó (fecha/hora)

# Puedes añadir funciones auxiliares aquí si quieres
func update_timestamp():
	timestamp = Time.get_datetime_string_from_system()
