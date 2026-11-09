extends CanvasLayer

const WORLD_NAMES := ["BOSQUE SUSURRANTE", "CIUDAD DE COBRE", "INFRAMUNDO"]
const WORLD_TAGLINES := ["Donde despiertan las raíces", "La noche nunca duerme", "Un eco bajo la tierra"]
const WORLD_COLORS := [Color("83c98a"), Color("e5a257"), Color("d77bc7")]

var game: Node
var root: Control
var current_panel: Control
var active_level: Node2D
var hud_lives: Label
var hud_stars: Label

func _ready() -> void:
	game = get_node("/root/GameSession")
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	show_title()

func clear_panel() -> void:
	if current_panel != null and is_instance_valid(current_panel):
		current_panel.queue_free()
	current_panel = Control.new()
	current_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	current_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	root.add_child(current_panel)

func panel_bg(parent: Control, color: Color) -> void:
	var bg := ColorRect.new()
	bg.color = color
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(bg)

func label(parent: Node, text: String, pos: Vector2, size: Vector2, font_size := 24, color := Color.WHITE, centered := false) -> Label:
	var item := Label.new()
	item.text = text
	item.position = pos
	item.size = size
	item.add_theme_font_size_override("font_size", font_size)
	item.add_theme_color_override("font_color", color)
	item.add_theme_color_override("font_shadow_color", Color(0.04, 0.03, 0.09, 0.7))
	item.add_theme_constant_override("shadow_offset_x", 2)
	item.add_theme_constant_override("shadow_offset_y", 3)
	if font_size >= 24:
		item.add_theme_color_override("font_outline_color", Color("10131c"))
		item.add_theme_constant_override("outline_size", 6)
	item.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if centered else HORIZONTAL_ALIGNMENT_LEFT
	item.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	item.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(item)
	return item

func button(parent: Node, text: String, pos: Vector2, size: Vector2, callback: Callable, accent := Color("e8a64c"), font_size := 22) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = size
	b.add_theme_font_size_override("font_size", font_size)
	b.add_theme_color_override("font_color", Color("182332"))
	b.add_theme_color_override("font_hover_color", Color("182332"))
	b.add_theme_color_override("font_pressed_color", Color("182332"))
	var style := StyleBoxFlat.new()
	style.bg_color = accent.lightened(0.12)
	style.set_corner_radius_all(14)
	style.set_border_width_all(2)
	style.border_width_bottom = 6
	style.border_color = Color("1a1224")
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 6
	style.shadow_offset = Vector2(0, 5)
	style.set_expand_margin_all(0)
	b.add_theme_stylebox_override("normal", style)
	var hover := style.duplicate()
	hover.bg_color = accent.lightened(0.26)
	b.add_theme_stylebox_override("hover", hover)
	var pressed := style.duplicate()
	pressed.bg_color = accent.darkened(0.08)
	pressed.border_width_bottom = 2
	pressed.shadow_size = 2
	pressed.shadow_offset = Vector2(0, 1)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.pressed.connect(callback)
	parent.add_child(b)
	return b

func show_title() -> void:
	_remove_active_level()
	clear_panel()
	_add_backdrop(0)
	label(current_panel, "T / GRAVITY", Vector2(96, 88), Vector2(960, 98), 72, Color("ffd23f"), true)
	label(current_panel, "UNA AVENTURA AL REVÉS", Vector2(180, 180), Vector2(792, 40), 24, Color("a9d2d2"), true)
	label(current_panel, "Bosque  ·  Ciudad  ·  Inframundo", Vector2(180, 246), Vector2(792, 38), 21, Color("d7e1dc"), true)
	button(current_panel, "NUEVA PARTIDA", Vector2(430, 330), Vector2(292, 65), _start_new_run, Color("f4bd5c"), 22)
	if game.lives < 5:
		button(current_panel, "CONTINUAR  ·  %d VIDAS" % game.lives, Vector2(430, 410), Vector2(292, 55), show_map, Color("8bcca0"), 18)

func _start_new_run() -> void:
	game.begin_new_run()
	show_map()

func show_map() -> void:
	_remove_active_level()
	clear_panel()
	var world := clampi(game.current_world, 0, 2)
	_add_backdrop(world)
	label(current_panel, WORLD_NAMES[world], Vector2(300, 28), Vector2(552, 54), 29, Color("fff0c8"), true)
	label(current_panel, WORLD_TAGLINES[world], Vector2(350, 76), Vector2(452, 32), 17, Color("d6dfd8"), true)
	label(current_panel, "VIDAS  %d / 5" % game.lives, Vector2(30, 24), Vector2(170, 38), 20, Color("ffdf81"))
	button(current_panel, "‹", Vector2(36, 290), Vector2(64, 64), func(): _change_world(-1), Color("8dc69e"), 36)
	button(current_panel, "›", Vector2(1052, 290), Vector2(64, 64), func(): _change_world(1), Color("8dc69e"), 36)
	var node_positions: Array[Vector2] = [Vector2(180, 210),Vector2(360, 270),Vector2(540, 188),Vector2(720, 270),Vector2(900, 195),Vector2(900, 405),Vector2(720, 455),Vector2(540, 385),Vector2(360, 470),Vector2(180, 402)]
	for i in range(9):
		_add_path(current_panel, node_positions[i], node_positions[i + 1], world)
	for i in range(10):
		var unlocked: bool = game.is_level_unlocked(world, i) and world < game.unlocked_worlds()
		var stars: int = game.stars_for(world, i)
		var node := Button.new()
		node.position = node_positions[i] - Vector2(29, 29)
		node.size = Vector2(58, 58)
		if unlocked:
			node.text = str(i + 1)
		else:
			var lock := Label.new()
			lock.text = "🔒"
			lock.position = Vector2(0, 0)
			lock.size = node.size
			lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lock.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			node.add_child(lock)
		node.disabled = not unlocked or game.lives <= 0
		node.add_theme_font_size_override("font_size", 19)
		node.add_theme_color_override("font_color", Color("192531"))
		node.add_theme_color_override("font_disabled_color", Color("b1b6b2"))
		var style := StyleBoxFlat.new()
		style.bg_color = WORLD_COLORS[world] if unlocked else Color("535b60")
		style.set_corner_radius_all(30)
		style.set_border_width_all(3)
		style.border_color = Color("fff0bc") if stars == 3 else Color("bfd0c3")
		node.add_theme_stylebox_override("normal", style)
		node.add_theme_stylebox_override("disabled", style)
		node.pressed.connect(_enter_level.bind(world, i))
		current_panel.add_child(node)
		if unlocked:
			label(current_panel, "★".repeat(stars) + "☆".repeat(3 - stars), node_positions[i] + Vector2(-35, 28), Vector2(70, 24), 14, Color("ffe36c"), true)
	label(current_panel, "3 estrellas desbloquean cada etapa", Vector2(357, 584), Vector2(438, 31), 16, Color("dce4d8"), true)
	button(current_panel, "TÍTULO", Vector2(28, 572), Vector2(132, 48), show_title, Color("d39b76"), 16)
	if game.lives <= 0:
		button(current_panel, "NUEVA PARTIDA", Vector2(973, 570), Vector2(160, 50), _start_new_run, Color("f4bd5c"), 14)

	if world >= game.unlocked_worlds():
		var overlay := ColorRect.new()
		overlay.color = Color("100c18", 0.8)
		overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		current_panel.add_child(overlay)
		label(current_panel, "🔒", Vector2(460, 200), Vector2(232, 232), 100, Color.WHITE, true)
		label(current_panel, "MUNDO BLOQUEADO", Vector2(300, 400), Vector2(552, 54), 30, Color.WHITE, true)

## Fondo por capas del mundo (mismo escenario que dentro del nivel), sin bloquear clics.
func _add_backdrop(world: int) -> void:
	var bd := Node2D.new()
	bd.set_script(load("res://scripts/backdrop.gd"))
	bd.world = world
	current_panel.add_child(bd)

func _add_path(parent: Control, from: Vector2, to: Vector2, world: int) -> void:
	var under := Line2D.new()
	under.points = PackedVector2Array([from, to])
	under.width = 13
	under.default_color = Color(0.06, 0.05, 0.12, 0.6)
	under.z_index = 0
	parent.add_child(under)
	var line := Line2D.new()
	line.points = PackedVector2Array([from, to])
	line.width = 5
	line.default_color = WORLD_COLORS[world].lightened(0.45)
	line.z_index = 1
	parent.add_child(line)

func _change_world(amount: int) -> void:
	var target: int = game.current_world + amount
	if target < 0 or target >= 3:
		return
	game.current_world = target
	show_map()

func _enter_level(world: int, level: int) -> void:
	if game.start_level(world, level):
		start_level_scene()

func start_level_scene() -> void:
	_remove_active_level()
	clear_panel()
	active_level = Node2D.new()
	active_level.set_script(load("res://scripts/level.gd"))
	active_level.world_index = game.current_world
	active_level.level_index = game.current_level
	active_level.level_title = _level_title(game.current_world, game.current_level)
	get_parent().add_child(active_level)
	_build_hud()

func _remove_active_level() -> void:
	if active_level != null and is_instance_valid(active_level):
		active_level.queue_free()
	active_level = null

func _build_hud() -> void:
	clear_panel()
	current_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_lives = label(current_panel, "♥ %d" % game.lives, Vector2(24, 18), Vector2(140, 46), 25, Color("fff0cf"))
	hud_stars = label(current_panel, "★ 0 / 3", Vector2(180, 18), Vector2(175, 46), 22, Color("ffe36c"))
	label(current_panel, WORLD_NAMES[game.current_world] + " · " + _level_title(game.current_world, game.current_level), Vector2(385, 16), Vector2(380, 46), 17, Color("fff0cf"), true)
	button(current_panel, "Ⅱ", Vector2(1062, 18), Vector2(64, 54), _toggle_pause, Color("d6dfd8"), 24)
	if active_level.mobile_controls:
		_add_touch_button("◀", Vector2(32, 536), Vector2(76, 76), "move_left")
		_add_touch_button("▶", Vector2(122, 536), Vector2(76, 76), "move_right")
		_add_touch_button("▲", Vector2(218, 536), Vector2(82, 76), "jump", Color("85c7a5"))
	var gravity := button(current_panel, "↕", Vector2(1016, 519), Vector2(104, 94), _flip_player_gravity, Color("bb91db"), 37)
	gravity.tooltip_text = "Invertir gravedad del personaje"

func _flip_player_gravity() -> void:
	if active_level != null and is_instance_valid(active_level.player):
		active_level.player.flip_gravity()

func _add_touch_button(text: String, pos: Vector2, size: Vector2, action: String, accent := Color("f2c36c")) -> void:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = size
	b.add_theme_font_size_override("font_size", 29)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(accent.r, accent.g, accent.b, 0.82)
	style.set_corner_radius_all(16)
	style.border_color = Color("fff1cf")
	style.set_border_width_all(2)
	b.add_theme_stylebox_override("normal", style)
	var pressed := style.duplicate()
	pressed.bg_color = accent.darkened(0.2)
	b.add_theme_stylebox_override("pressed", pressed)
	b.button_down.connect(_press_action.bind(action))
	b.button_up.connect(_release_action.bind(action))
	current_panel.add_child(b)

func _press_action(action: String) -> void:
	Input.action_press(action)

func _release_action(action: String) -> void:
	Input.action_release(action)

func update_hud() -> void:
	if is_instance_valid(hud_stars) and active_level != null:
		hud_stars.text = "★ %d / 3" % active_level.collected
	if is_instance_valid(hud_lives):
		hud_lives.text = "♥ %d" % game.lives

func show_results(stars: int) -> void:
	active_level = null
	clear_panel()
	panel_bg(current_panel, Color("111c2b", 0.94))
	label(current_panel, "¡NIVEL COMPLETADO!", Vector2(250, 92), Vector2(652, 64), 34, Color("fff0cf"), true)
	label(current_panel, "★".repeat(stars) + "☆".repeat(3 - stars), Vector2(380, 176), Vector2(392, 74), 48, Color("ffe36c"), true)
	label(current_panel, "%s  ·  %s" % [WORLD_NAMES[game.current_world], _level_title(game.current_world, game.current_level)], Vector2(300, 250), Vector2(552, 40), 19, Color("dce4e2"), true)
	button(current_panel, "MAPA DE MUNDOS", Vector2(270, 340), Vector2(220, 68), show_map, Color("8dc69e"), 18)
	button(current_panel, "REINTENTAR", Vector2(516, 340), Vector2(190, 68), _restart_level, Color("f1c36a"), 18)
	if stars == 3:
		button(current_panel, "SIGUIENTE ➜", Vector2(730, 340), Vector2(205, 68), _go_next, Color("bd93dd"), 18)
	label(current_panel, "VIDAS RESTANTES  ♥ %d" % game.lives, Vector2(420, 450), Vector2(312, 40), 20, Color("fff0cf"), true)

func _go_next() -> void:
	if game.next_level():
		start_level_scene()
	else:
		show_map()

func _restart_level() -> void:
	if game.continue_level():
		start_level_scene()

func show_message(title: String, subtitle: String) -> void:
	_remove_active_level()
	clear_panel()
	panel_bg(current_panel, Color("172333", 0.88))
	label(current_panel, title, Vector2(300, 230), Vector2(552, 60), 34, Color("fff0cf"), true)
	label(current_panel, subtitle, Vector2(300, 295), Vector2(552, 38), 22, Color("d6dfd8"), true)

func retry_after_delay() -> void:
	await get_tree().create_timer(0.9).timeout
	if game.run_state == "playing" and game.lives > 0:
		start_level_scene()

func show_game_over() -> void:
	active_level = null
	clear_panel()
	panel_bg(current_panel, Color("1c1828"))
	label(current_panel, "FIN DE LA PARTIDA", Vector2(270, 150), Vector2(612, 62), 38, Color("f19078"), true)
	label(current_panel, "Tus mundos siguen ahí. ¿Un nuevo intento?", Vector2(300, 236), Vector2(552, 40), 20, Color("e5dbd4"), true)
	button(current_panel, "VOLVER AL MAPA", Vector2(340, 326), Vector2(220, 64), show_map, Color("8dc69e"), 18)
	button(current_panel, "NUEVA PARTIDA", Vector2(590, 326), Vector2(220, 64), _start_new_run, Color("f1c36a"), 18)

func _toggle_pause() -> void:
	if active_level == null:
		return
	if get_tree().paused:
		get_tree().paused = false
		return
	get_tree().paused = true
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	current_panel.add_child(overlay)
	panel_bg(overlay, Color("101827", 0.84))
	label(overlay, "PAUSA", Vector2(400, 205), Vector2(352, 60), 38, Color("fff0cf"), true)
	button(overlay, "CONTINUAR", Vector2(365, 300), Vector2(200, 62), _resume_game, Color("8dc69e"), 18)
	button(overlay, "SALIR AL MAPA", Vector2(590, 300), Vector2(200, 62), _leave_to_map, Color("f1c36a"), 18)

func _resume_game() -> void:
	get_tree().paused = false
	clear_panel()
	_build_hud()

func _leave_to_map() -> void:
	get_tree().paused = false
	show_map()

func _level_title(world: int, level: int) -> String:
	var lists := [
		["Sendero de brotes", "Puentes de lianas", "La charca espejo", "Raíces cruzadas", "Nido en la copa", "Viento entre pinos", "Troncos errantes", "La gruta verde", "Cima del rocío", "Corazón del bosque"],
		["Avenida de cobre", "Azoteas al alba", "Cruce elevado", "Túneles de neón", "Obras nocturnas", "Rieles fugaces", "Torre de relojes", "Lluvia eléctrica", "El último tranvía", "Cima metropolitana"],
		["Umbral de ceniza", "Galería carmesí", "Pozos de eco", "Pilares flotantes", "Río de brasas", "Cripta invertida", "La sala sin suelo", "Escaleras del abismo", "Trono de obsidiana", "Núcleo profundo"]
	]
	return lists[clampi(world, 0, 2)][clampi(level, 0, 9)]
