extends Button
@onready var play: Button = $"."
var main_rout = "res://main.tscn"
func _ready():
	play.grab_focus.call_deferred()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)



func _on_pressed() -> void:
	get_tree().change_scene_to_file(main_rout)
	
	pass # Replace with function body.
