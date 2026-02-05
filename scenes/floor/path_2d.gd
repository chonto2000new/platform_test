extends Path2D
@export var loop:bool = true
@export var speed:float = 2.0
@export var speed_scale = 1.0

@onready var path_follow_2d: PathFollow2D = $PathFollow2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	if not loop:
		animation_player.play("move")
		animation_player.speed_scale = speed_scale
		set_process(false)
		
		
func _process(_delta: float) -> void:
	path_follow_2d.progress += speed
