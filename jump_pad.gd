extends Node2D

@export var jump_force: float = -900.0
@onready var sprite = $Sprite2D
var escala_original: Vector2


func _ready():
	# Guardamos el tamaño que configuraste manualmente
	escala_original = sprite.scale



func _on_area_2d_body_entered(body: Node2D) -> void:
	
	if body.has_method("apply_jump_pad_force"):
		body.apply_jump_pad_force(jump_force)
		animar_rebote()
		


func animar_rebote():
	var tween = create_tween()
	
	# FASE 1: SQUASH (Multiplicamos por tu escala original)
	# Si tu escala era 0.5, esto hará: 0.5 * 1.3 = 0.65 (Un poquito más ancho)
	tween.tween_property(sprite, "scale", escala_original * Vector2(1.3, 0.7), 0.05)
	
	# FASE 2: STRETCH
	tween.tween_property(sprite, "scale", escala_original * Vector2(0.8, 1.2), 0.1)
	
	# FASE 3: RETORNO
	# Regresamos a la "escala_original", no a (1, 1)
	tween.tween_property(sprite, "scale", escala_original, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
