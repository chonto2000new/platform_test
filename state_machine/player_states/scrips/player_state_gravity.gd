class_name PlayerStateGravityBase extends PlayerStateBase

var gravity:float = ProjectSettings.get_setting("physics/2d/default_gravity")
var max_falling:float = 250.0


func handle_gravity(delta):
	if player.velocity.y < max_falling:
		player.velocity.y += gravity * delta 
