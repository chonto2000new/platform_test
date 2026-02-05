# En WallJumping.gd
extends PlayerStateGravityBase

# Constantes de Fuerza
const WALL_JUMP_HORIZONTAL_FORCE := 150.0 # Aumentado para forzar el despegue
const WALL_JUMP_VERTICAL_FORCE := 300.0  # Aumentado para garantizar la elevación
const WALL_JUMP_COOLDOWN := 0.20 

var current_cooldown: float = 0.0
var jump_direction_stored: float = 0.0 # Almacena la dirección para usar en on_physics_process

func start()-> void:
	# ➡️ LEER: Obtener el valor de la variable del Player
	var jump_direction: float = player.wall_jump_direction
	
	# 🚨 Almacenar la dirección para el on_physics_process
	jump_direction_stored = jump_direction

	# 1. Aplicar el impulso inicial (hacia arriba y hacia afuera)
	player.velocity.x = jump_direction * WALL_JUMP_HORIZONTAL_FORCE
	player.velocity.y = -WALL_JUMP_VERTICAL_FORCE 
	
	# 2. Iniciar el cooldown
	current_cooldown = WALL_JUMP_COOLDOWN

	# 3. Orientación y animación
	player_animations.play("jumping")
	player_animations.flip_h = jump_direction < 0 
	
	# Tienes que actualizar también la variable lógica que usa tu función shoot()
	if jump_direction > 0:
		player.facing_right = true
	else:
		player.facing_right = false

func on_physics_process(delta: float) -> void:
	
	# 1. Manejo del Cooldown
	if current_cooldown > 0:
		current_cooldown -= delta
		# 🚨 CLAVE: Forzar la velocidad horizontal durante el cooldown. 
		# Esto asegura que el impulso venza la fricción y la colisión.
		player.velocity.x = jump_direction_stored * WALL_JUMP_HORIZONTAL_FORCE
	
	# 2. Control Horizontal (Solo después del cooldown)
	var direction := Input.get_axis("move_left", "move_right")
	
	if current_cooldown <= 0:
		if direction:
			# Si hay entrada, permite el control
			player.velocity.x = direction * player.SPEED
		else:
			# Si no hay entrada, decaemos la velocidad horizontal.
			player.velocity.x = move_toward(player.velocity.x, 0, player.ACCELERATION * delta)
	
	# Manejar la gravedad, ya que está en el aire
	handle_gravity(delta)
	
	player.move_and_slide()
	
	# 3. Lógica de Transición
	
	if player.is_on_floor():
		state_machine.change_to(player.states.idle)
		return
		
		
	if Input.is_action_just_released("jump"):
		player.velocity.y *= 0.5

		state_machine.change_to(player.states.falling)
		return
		
	# Transición a Falling: Ocurre cuando el impulso vertical ha terminado (velocity.y >= 0)
	# y el cooldown de despegue ha terminado (current_cooldown <= 0).
	if player.velocity.y >= 0 and current_cooldown <= 0:
		state_machine.change_to(player.states.falling)
		return

func on_exit() -> void:
	# 🚨 CLAVE: Activar el bloqueo para evitar que Falling transicione a WallSliding.
	player.wall_slide_lockout_timer = player.WALL_SLIDE_LOCKOUT_TIME
