extends CharacterBody2D
var SPEED:float = 200.0
var GRAVITY:float = 400.0
@onready var left: RayCast2D = $left
@onready var left_down: RayCast2D = $left_down
@onready var right: RayCast2D = $right
@onready var right_down: RayCast2D = $right_down
var direction = 1.0
@export var enemy_hp = 30


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if direction > 0 and (right.is_colliding() or not right_down.is_colliding()):
		direction = -1.0 # ...cambia a la izquierda.
	# Si va a la izquierda Y choca a la izquierda O no hay suelo a la izquierda...
	elif direction < 0 and (left.is_colliding() or not left_down.is_colliding()):
		direction = 1.0 # ...cambia a la derecha.


	velocity.x = SPEED * direction 


	move_and_slide()
		
func take_damage(damage:int):
	enemy_hp -= damage
	#print(enemy_hp)

func _on_damage_area_area_entered(_area: Area2D) -> void:
	pass # Replace with function body.
