extends CharacterBody2D

signal died
signal enemy_stomped(enemy: Node2D)

@export var move_speed := 205.0
@export var jump_speed := 410.0
@export var gravity_strength := 1050.0
@export var bounds_left := -100.0
@export var bounds_right := 2725.0
@export var coyote_time := 0.11
@export var jump_buffer_time := 0.13

var gravity_sign := 1.0
var input_enabled := true
var invulnerable := false
var facing := 1.0
var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0
var _blink_timer := 0.0
var _run_t := 0.0
var _was_on_floor := false

func _physics_process(delta: float) -> void:
	if invulnerable:
		_blink_timer += delta
		$HeroArt.modulate.a = 0.35 if int(_blink_timer * 14.0) % 2 == 0 else 1.0
	else:
		_blink_timer = 0.0
		$HeroArt.modulate.a = 1.0
	up_direction = Vector2.UP * gravity_sign
	_sync_art(delta)
	if not input_enabled:
		_coyote_timer = 0.0
		_jump_buffer_timer = 0.0
		velocity.x = move_toward(velocity.x, 0.0, move_speed * 5.0 * delta)
		velocity.y += gravity_strength * gravity_sign * delta
		move_and_slide()
		return
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		facing = signf(direction)
	velocity.x = direction * move_speed
	if Input.is_action_just_pressed("flip_gravity"):
		flip_gravity()
		return
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer = maxf(0.0, _coyote_timer - delta)
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer = maxf(0.0, _jump_buffer_timer - delta)
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = -jump_speed * gravity_sign
		_coyote_timer = 0.0
		_jump_buffer_timer = 0.0
	velocity.y += gravity_strength * gravity_sign * delta
	velocity.y = clampf(velocity.y, -650.0, 650.0)
	move_and_slide()
	position.x = clampf(position.x, bounds_left, bounds_right)
	_check_stomps()

## Alimenta la animación del héroe (pose, dirección, gravedad, squash al aterrizar).
func _sync_art(delta: float) -> void:
	var art = get_node_or_null("HeroArt")
	if art == null:
		return
	var on_floor := is_on_floor()
	if on_floor and absf(velocity.x) > 10.0:
		_run_t += delta
	elif on_floor:
		_run_t = 0.0
	if on_floor and not _was_on_floor:
		art.squash = 0.18
	_was_on_floor = on_floor
	art.squash = maxf(0.0, art.squash - delta)
	art.facing = facing
	art.grav = gravity_sign
	if not on_floor:
		art.kind = "fall" if velocity.y * gravity_sign > 60.0 else "jump"
	elif absf(velocity.x) > 10.0:
		art.kind = "run"
		art.phase = int(_run_t * 10.0) % 4
	else:
		art.kind = "idle"

func flip_gravity() -> void:
	gravity_sign *= -1.0
	up_direction = Vector2.UP * gravity_sign
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0
	velocity.y = -gravity_sign * 90.0
	if has_node("GravityTrail"):
		var trail: Polygon2D = $GravityTrail
		trail.color = Color("bb91db") if gravity_sign < 0.0 else Color("85c7a5")
		trail.scale = Vector2(1.0, gravity_sign)
		trail.modulate.a = 0.9
		var tween := create_tween()
		tween.tween_property(trail, "modulate:a", 0.0, 0.28)

func _check_stomps() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var other := collision.get_collider()
		if other != null and other.is_in_group("enemies"):
			var normal := collision.get_normal()
			var coming_down := velocity.y * gravity_sign >= 0.0
			var enemy_above_surface := normal.y * gravity_sign < -0.5
			if coming_down and enemy_above_surface:
				enemy_stomped.emit(other)
				other.call_deferred("defeat")
				velocity.y = -jump_speed * gravity_sign * 0.62
			elif not invulnerable:
				take_damage()

func take_damage() -> void:
	if invulnerable or not input_enabled:
		return
	invulnerable = true
	input_enabled = false
	died.emit()
	await get_tree().create_timer(0.8).timeout
	invulnerable = false
