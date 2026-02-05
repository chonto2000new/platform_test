class_name ENEMYBASE  extends CharacterBody2D

@export var enemy_hp := 10
@export var enemy_default_hp := 10


var direction = 1.0
var SPEED:float = 200.0

var JUMP_SPEED:float = 350.0
var JUMP := -250.0

#collitions
@onready var left: RayCast2D = %left
@onready var left_down: RayCast2D = %left_down
@onready var right: RayCast2D = %right
@onready var right_down: RayCast2D = %right_down
@onready var damage_area= $damage_area/CollisionShape2D

@onready var state_machine = $StateMachine

var gravity:float = ProjectSettings.get_setting("physics/2d/default_gravity")
var max_falling:float = 250.0
var states:EnemyBaseStatesNames = EnemyBaseStatesNames.new()
var animations:EnemyAnimationsNames = EnemyAnimationsNames.new()
@onready var enemy_radar: Area2D = %enemy_radar


#Animation zone
@onready var enemy_animation: AnimatedSprite2D = %AnimatedSprite2D
var enemy_actual_animation =  animations.walking
@onready var flames: CPUParticles2D = %flames
var tween_hit: Tween

#Var de muerte 
@export var fuerza_empuje_x = 400.0
@export var fuerza_empuje_y = -300.0
var ball_speed
#se;ales 


func handle_gravity(delta):
	if velocity.y < max_falling:
		velocity.y += gravity * delta 




func _physics_process(delta: float) -> void:
		handle_gravity(delta)
		move_and_slide()

func take_damage(damage:int,ball_position = null):
	if enemy_hp <= 0:
		damage_area.set_deferred("disabled", true)
	else:

		if ball_position == null:
			ball_position = Vector2(0,0)
		
		
		# CORRECCIÓN PRINCIPAL:
		# 1. Usamos "state_machine" directo (la variable que creamos arriba).
		# 2. Pasamos "pos_ataque", no "position" (porque "position" es TU ubicación, no la de la bala).
		if state_machine.current_state.has_method("take_damage_state"):
			state_machine.current_state.take_damage_state(damage, ball_position)
	
	
func damage_effect():
	# 1. Si ya había un tween corriendo, MÁTALO para que no estorbe
	if tween_hit and tween_hit.is_valid():
		tween_hit.kill()
	
	# 2. Guardamos el nuevo tween en la variable
	tween_hit = create_tween()
	
	modulate = Color(10, 10, 10, 1) 
	tween_hit.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.15)
