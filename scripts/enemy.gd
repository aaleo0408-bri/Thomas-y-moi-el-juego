extends CharacterBody2D

@export var patrol_distance := 72.0
@export var speed := 42.0
@export var gravity_strength := 1050.0
var direction := -1.0
var origin_x := 0.0
var defeated := false

func _ready() -> void:
	origin_x = global_position.x
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	if defeated:
		return
	velocity.x = direction * speed
	velocity.y += gravity_strength * delta
	move_and_slide()
	if global_position.x < origin_x - patrol_distance:
		direction = 1.0
	elif global_position.x > origin_x + patrol_distance:
		direction = -1.0

func defeat() -> void:
	if defeated:
		return
	defeated = true
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 0.1), 0.12)
	tween.tween_callback(queue_free)
