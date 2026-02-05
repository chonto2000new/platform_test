extends Area2D

# Ruta de la escena a la que vamos a viajar
@export_file("*.tscn") var target_scene_path: String

# El nombre del Marker2D en la SIGUIENTE escena donde queremos aparecer
@export var target_spawn_point_name: String

func _on_body_entered(body):
	if body.is_in_group("player"): # O usa grupos: body.is_in_group("player")
		# 1. Guardamos en el Global a dónde queremos llegar
		PlayerNextPosition.next_spawn_point = target_spawn_point_name
		print(PlayerNextPosition.next_spawn_point,"punto de aparicion")
		# 2. Cambiamos la escena (Sintaxis Godot 4)
		get_tree().change_scene_to_file(target_scene_path)
