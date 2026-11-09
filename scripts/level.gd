extends Node2D
const SB := preload("res://scripts/sprite_bank.gd")

signal finished(stars: int)
signal life_lost
signal game_over

@export var world_index := 0
@export var level_index := 0
@export var level_title := "Sendero de brotes"
@export var level_length := 2700.0
@export var star_positions: Array[float] = [610.0, 1370.0, 2180.0]
@export var enemy_positions: Array[float] = [960.0, 1830.0]
@export var gap_positions: Array[float] = [820.0, 1570.0, 2350.0]

var collected := 0
var ending := false
var game: Node
var player: CharacterBody2D
var world_floor: StaticBody2D
var world_ceiling: StaticBody2D
var camera: Camera2D
var screen_size := Vector2(1152, 648)
var palette: Dictionary
var death_handled := false
var mobile_controls := false
var backdrop: Node2D

func _ready() -> void:
	game = get_node("/root/GameSession")
	palette = _world_palette(world_index)
	_build_level()

func _process(_delta: float) -> void:
	if ending or player == null:
		return
	if camera != null:
		camera.position.x = clampf(player.position.x, screen_size.x * 0.5, level_length - screen_size.x * 0.5)
	if player.global_position.y > 760.0 or player.global_position.y < -220.0:
		_on_player_died()
	elif player.global_position.x >= level_length - 110.0 and player.global_position.y > 255.0 and player.global_position.y < 365.0:
		finish_level()

func _build_level() -> void:
	mobile_controls = OS.has_feature("mobile") or DisplayServer.is_touchscreen_available()
	_add_rect(self, Vector2(level_length * 0.5, screen_size.y * 0.5), Vector2(level_length, screen_size.y), palette.sky, -20)
	_build_backdrop()
	var ground = Node2D.new()
	ground.set_script(load("res://scripts/ground_art.gd"))
	ground.world = world_index
	ground.level_length = level_length
	add_child(ground)
	var adjusted_gaps: Array[Vector2] = []
	for i in range(gap_positions.size()):
		var gap_start := gap_positions[i] + float(level_index * 19 % 120)
		var gap_width := 125.0 + float(i % 2) * 20.0
		adjusted_gaps.append(Vector2(gap_start, gap_width))
	var floor_segments: Array[Vector2] = []
	var cursor := 0.0
	for gap in adjusted_gaps:
		var gap_start: float = gap.x
		var gap_width: float = gap.y
		if gap_start > cursor:
			floor_segments.append(Vector2(cursor, gap_start))
		cursor = gap_start + gap_width
	if cursor < level_length:
		floor_segments.append(Vector2(cursor, level_length))
	for segment in floor_segments:
		var segment_width := segment.y - segment.x
		_add_platform(Vector2((segment.x + segment.y) * 0.5, 632), Vector2(segment_width, 32), palette.ground, "floor", palette.grass, palette.dark)
	var ceiling_segments: Array[Vector2] = []
	cursor = 0.0
	for gap in adjusted_gaps:
		var gap_start: float = gap.x + 35.0
		var gap_width: float = 100.0 + (gap.y - 125.0) * 0.75
		if gap_start > cursor:
			ceiling_segments.append(Vector2(cursor, gap_start))
		cursor = gap_start + gap_width
	if cursor < level_length:
		ceiling_segments.append(Vector2(cursor, level_length))
	for segment in ceiling_segments:
		_add_platform(Vector2((segment.x + segment.y) * 0.5, 16), Vector2(segment.y - segment.x, 28), palette.ceiling, "ceiling", palette.grass, palette.dark)
	for index in range(10):
		var x := 160.0 + index * (level_length - 320.0) / 9.0
		var ground_y := 455.0 - float(index % 3) * 26.0
		var ceiling_y := 174.0 + float(index % 3) * 25.0
		_add_platform(Vector2(x, ground_y), Vector2(170, 20), palette.platform, "platform", palette.highlight)
		_add_platform(Vector2(x + 30, ceiling_y), Vector2(148, 18), palette.platform, "platform", palette.highlight)
	_add_platform(Vector2(level_length - 70, 320), Vector2(90, 34), palette.highlight)
	var exit := Area2D.new()
	exit.position = Vector2(level_length - 70, 275)
	var exit_shape := CollisionShape2D.new()
	var exit_box := RectangleShape2D.new()
	exit_box.size = Vector2(74, 110)
	exit_shape.shape = exit_box
	exit.add_child(exit_shape)
	exit.body_entered.connect(_on_exit_entered)
	add_child(exit)
	var portal = Node2D.new()
	portal.set_script(load("res://scripts/sprite_node.gd"))
	portal.tex = SB.portal_texture(SB.world_value(world_index, "accent"))
	portal.px = 2.0
	portal.wobble = 0.25
	exit.add_child(portal)
	for gap in adjusted_gaps:
		var g: float = gap.x
		var gap_width: float = gap.y
		_add_rect(self, Vector2(g + gap_width * 0.5, 635), Vector2(gap_width, 70), Color(0.04, 0.045, 0.08), 1)
		var ceiling_gap := g + 35.0
		_add_rect(self, Vector2(ceiling_gap + 62.5, 25), Vector2(125, 46), Color(0.04, 0.045, 0.08), 1)
	for i in range(star_positions.size()):
		var star := Area2D.new()
		var candidate_star_x := star_positions[i] + float(level_index * 31 % 75)
		for gap in adjusted_gaps:
			if candidate_star_x >= gap.x - 25.0 and candidate_star_x <= gap.x + gap.y + 25.0:
				candidate_star_x = gap.x + gap.y + 65.0
		star.position = Vector2(candidate_star_x, 460 if i % 2 == 0 else 174)
		star.add_to_group("collectibles")
		star.set_meta("collected", false)
		var shape := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 18
		shape.shape = circle
		star.add_child(shape)
		var visual = Node2D.new()
		visual.set_script(load("res://scripts/sprite_node.gd"))
		visual.tex = SB.spr_texture("star")
		visual.px = 1.4
		star.add_child(visual)
		star.body_entered.connect(_collect_star.bind(star))
		add_child(star)
	var exit_marker := _add_rect(self, Vector2(level_length - 70, 190), Vector2(46, 26), palette.highlight, 3)
	exit_marker.rotation = -0.08
	var hazard_count := clampi(int((level_index + world_index * 3) / 3.0), 0, 5)
	var placed_hazards: Array[float] = []
	for index in range(hazard_count):
		var hazard_x := 360.0 + float(index + 1) * (level_length - 720.0) / float(hazard_count + 1)
		for gap in adjusted_gaps:
			if hazard_x >= gap.x - 45.0 and hazard_x <= gap.x + gap.y + 45.0:
				hazard_x = gap.x + gap.y + 75.0
		for star_node in get_children():
			if star_node.is_in_group("collectibles") and absf(hazard_x - star_node.position.x) < 95.0:
				hazard_x = star_node.position.x + 110.0
		for enemy_x in enemy_positions:
			var adjusted_enemy_x: float = float(enemy_x) + float(level_index * 43 % 150)
			if absf(hazard_x - adjusted_enemy_x) < 85.0:
				hazard_x += 95.0
		hazard_x = clampf(hazard_x, 300.0, level_length - 260.0)
		var overlaps_another := false
		for previous_x in placed_hazards:
			if absf(hazard_x - previous_x) < 80.0:
				overlaps_another = true
		if not _is_inside_gap(hazard_x, adjusted_gaps) and not overlaps_another:
			placed_hazards.append(hazard_x)
			_add_hazard(hazard_x)
	for x in enemy_positions:
		var enemy := _make_enemy(float(x) + float(level_index * 43 % 150))
		add_child(enemy)
	player = _make_player()
	player.position = Vector2(100, 530)
	player.connect("died", _on_player_died)
	add_child(player)
	camera = Camera2D.new()
	camera.position = Vector2(screen_size.x * 0.5, screen_size.y * 0.5)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	add_child(camera)
	backdrop.camera = camera

func _build_backdrop() -> void:
	backdrop = Node2D.new()
	backdrop.set_script(load("res://scripts/backdrop.gd"))
	backdrop.world = world_index
	backdrop.z_index = -10
	add_child(backdrop)

func _is_inside_gap(x: float, gaps: Array[Vector2]) -> bool:
	for gap in gaps:
		if x >= gap.x - 35.0 and x <= gap.x + gap.y + 35.0:
			return true
	return false

func _add_hazard(x: float) -> void:
	var hazard := Area2D.new()
	hazard.name = "GravityShard"
	hazard.position = Vector2(x, 596.0)
	hazard.collision_layer = 0
	hazard.collision_mask = 1
	var shape := CollisionShape2D.new()
	var polygon := ConvexPolygonShape2D.new()
	polygon.points = PackedVector2Array([Vector2(-15, 18), Vector2(-9, -8), Vector2(0, -20), Vector2(9, -8), Vector2(15, 18)])
	shape.shape = polygon
	hazard.add_child(shape)
	var spike = Node2D.new()
	spike.set_script(load("res://scripts/sprite_node.gd"))
	spike.tex = SB.spr_texture("spike")
	spike.px = 1.0
	spike.position = Vector2(0, 6)
	hazard.add_child(spike)
	hazard.body_entered.connect(_on_hazard_entered)
	add_child(hazard)

func _on_hazard_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage()

func _add_platform(pos: Vector2, size: Vector2, color: Color, kind := "platform", top := Color.WHITE, dark := Color.BLACK) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.position = pos
	var shape_node := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape_node.shape = rect
	body.add_child(shape_node)
	if kind == "platform":
		var visual = Node2D.new()
		visual.set_script(load("res://scripts/surface_art.gd"))
		visual.world = world_index
		visual.size = size
		body.add_child(visual)
	add_child(body)
	return body

func _add_rect(parent: Node, pos: Vector2, size: Vector2, color: Color, z: int) -> Polygon2D:
	var polygon := Polygon2D.new()
	polygon.position = pos
	polygon.z_index = z
	polygon.color = color
	polygon.polygon = PackedVector2Array([Vector2(-size.x/2,-size.y/2),Vector2(size.x/2,-size.y/2),Vector2(size.x/2,size.y/2),Vector2(-size.x/2,size.y/2)])
	parent.add_child(polygon)
	return polygon

func _make_player() -> CharacterBody2D:
	var hero := CharacterBody2D.new()
	hero.name = "Player"
	hero.set_script(load("res://scripts/player.gd"))
	hero.add_to_group("player")
	var trail := Polygon2D.new()
	trail.name = "GravityTrail"
	trail.polygon = PackedVector2Array([Vector2(-12, 27), Vector2(0, 55), Vector2(12, 27)])
	trail.color = Color("85c7a5")
	trail.modulate.a = 0.0
	trail.z_index = -1
	hero.add_child(trail)
	var collision := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(30, 46)
	collision.shape = rect
	hero.add_child(collision)
	var art := Node2D.new()
	art.name = "HeroArt"
	art.set_script(load("res://scripts/hero_art.gd"))
	hero.add_child(art)
	return hero

func _make_enemy(x: float) -> CharacterBody2D:
	var enemy := CharacterBody2D.new()
	enemy.name = "Enemy"
	enemy.set_script(load("res://scripts/enemy.gd"))
	enemy.position = Vector2(x, 570)
	enemy.speed = 42.0 + float(level_index) * 2.6 + float(world_index) * 8.0
	var collision := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(34, 32)
	collision.shape = rect
	enemy.add_child(collision)
	var art := Node2D.new()
	art.set_script(load("res://scripts/slime_art.gd"))
	art.enemy_color = Color(SB.world_value(world_index, "enemy"))
	enemy.add_child(art)
	return enemy

func _on_exit_entered(body: Node2D) -> void:
	if not ending and body.is_in_group("player") and body.global_position.y > 255.0 and body.global_position.y < 365.0:
		finish_level()

func _collect_star(body: Node2D, star: Area2D) -> void:
	if ending or not body.is_in_group("player") or star.get_meta("collected", false):
		return
	star.set_meta("collected", true)
	collected += 1
	star.queue_free()
	get_node("/root/GameUI").update_hud()

func _on_player_died() -> void:
	if ending or death_handled:
		return
	death_handled = true
	ending = true
	var had_life: bool = game.lose_life()
	life_lost.emit()
	if had_life and game.lives > 0:
		var ui = get_node("/root/GameUI")
		ui.show_message("VIDA PERDIDA", "Reintentando…")
		ui.retry_after_delay()
	else:
		game_over.emit()
		get_node("/root/GameUI").show_game_over()

func finish_level() -> void:
	if ending:
		return
	ending = true
	game.record_clear(collected)
	finished.emit(collected)
	get_node("/root/GameUI").show_results(collected)

func _world_palette(world: int) -> Dictionary:
	if world == 1:
		return {"sky": Color("243b65"), "distant": Color("3b6080"), "ground": Color("514b59"), "ceiling": Color("343d55"), "platform": Color("697280"), "highlight": Color("f4bb63"), "enemy": Color("df7556"), "grass": Color("9fb3d9"), "dark": Color("2a2e3f")}
	if world == 2:
		return {"sky": Color("211e3d"), "distant": Color("443052"), "ground": Color("49334a"), "ceiling": Color("30233e"), "platform": Color("69506e"), "highlight": Color("70e6ca"), "enemy": Color("e15b89"), "grass": Color("9b5cc0"), "dark": Color("1a1420")}
	return {"sky": Color("9bd9d7"), "distant": Color("4e9b88"), "ground": Color("654f39"), "ceiling": Color("345d53"), "platform": Color("88ac69"), "highlight": Color("f7cf61"), "enemy": Color("8d594c"), "grass": Color("7ed957"), "dark": Color("4f3826")}
