extends Control


# Precargas la escena en una variable al inicio
var nivel_siguiente = preload("res://scenes/menu/main_menu.tscn")

func cambiar_de_nivel():
	# Usas la variable precargada
	get_tree().change_scene_to_packed(nivel_siguiente)
