extends Node2D
## Fondo por capas con parallax: cielo, sol, montañas, árboles/edificios/cristales y colinas.
## Se mantiene centrado en la cámara; cada capa se desplaza a distinta velocidad.

const SCREEN := Vector2(1152, 648)
const LEVEL_LEN := 2700.0

# Paleta por mundo: sky1, sky2, sun, far, far2, near, glow, cloud
const WORLD_SKY := [
	[Color("6ec6d9"), Color("e4f7e8"), Color("fff3b0"), Color("8cc7a6"), Color("4f9d7a"), Color("2f7a5a"), Color("ffd45e"), Color("ffffff")],
	[Color("243b78"), Color("7b5ea7"), Color("e8f0ff"), Color("3d4f8a"), Color("2a3766"), Color("1b2447"), Color("ffd27a"), Color("a9b8e0")],
	[Color("1a1230"), Color("4a1f3d"), Color("ff6a3d"), Color("3a2350"), Color("2a1a3d"), Color("1b1028"), Color("6fffd8"), Color("5b3d7a")],
]

var world := 0
var camera: Camera2D
var _t := 0.0

func _process(delta: float) -> void:
	_t += delta
	if camera != null:
		position = Vector2(camera.position.x - SCREEN.x * 0.5, 0.0)
	queue_redraw()

func _c(i: int) -> Color:
	return WORLD_SKY[world][i]

func _draw() -> void:
	var cam_x := camera.position.x if camera != null else SCREEN.x * 0.5
	var sky_top := _c(0)
	var sky_bot := _c(1)
	for i in 36:
		var t := float(i) / 35.0
		draw_rect(Rect2(0, SCREEN.y * t, SCREEN.x, SCREEN.y / 36.0 + 1.0), sky_top.lerp(sky_bot, t))
	# sol / luna con halo
	var sun_pos := Vector2(SCREEN.x * 0.74, 130.0 if world != 2 else SCREEN.y * 0.82)
	var halo := 190.0 if world != 2 else 340.0
	for k in 10:
		var r := halo * (1.0 - float(k) / 10.0)
		draw_circle(sun_pos, r, Color(_c(2).r, _c(2).g, _c(2).b, 0.05))
	if world != 2:
		draw_circle(sun_pos, 34.0, Color(_c(2).r, _c(2).g, _c(2).b, 0.9))
	# nubes
	for i in 8:
		var cx := fposmod(float(i) * 331.0 + 90.0 - cam_x * 0.08 - _t * 6.0, SCREEN.x + 360.0) - 180.0
		var cy := 60.0 + float((i * 71) % 130)
		_puff(Vector2(cx, cy), 0.9 + float(i % 3) * 0.3, Color(_c(7).r, _c(7).g, _c(7).b, 0.45))
	# montañas lejanas
	_ridge(_c(3), 0.12, 220.0, SCREEN.y - 120.0, 1.3, cam_x)
	# capa media
	if world == 0:
		_row(cam_x, 0.3, 62.0, func(x: float, i: int) -> void: _pine(x + _rnd(i) * 20.0, SCREEN.y - 70.0, 90.0 + _rnd(i + 4) * 60.0, _c(4)))
	elif world == 1:
		_row(cam_x, 0.3, 74.0, func(x: float, i: int) -> void: _building(x, SCREEN.y - 60.0, 80.0 + _rnd(i) * 120.0, 44.0 + _rnd(i + 9) * 26.0, _c(4), _c(6), i))
	else:
		_row(cam_x, 0.3, 70.0, func(x: float, i: int) -> void: _crystal(x + _rnd(i) * 30.0, SCREEN.y - 50.0, 60.0 + _rnd(i + 2) * 90.0, _c(4), _c(6)))
	# colinas cercanas
	_ridge(_c(4), 0.35, 150.0, SCREEN.y - 40.0, 2.7, cam_x)
	_ridge(_c(5), 0.6, 90.0, SCREEN.y - 16.0, 4.1, cam_x)

func _rnd(i: int) -> float:
	var s := sin(float(i) * 127.1 + 311.7) * 43758.5453
	return s - floor(s)

func _ridge(col: Color, f: float, amp: float, base: float, seed_v: float, cam_x: float) -> void:
	var pts := PackedVector2Array()
	pts.append(Vector2(-40, SCREEN.y))
	var sx := -40.0
	while sx <= SCREEN.x + 40.0:
		var wx := sx + cam_x * f
		var y := base - amp * (0.55 + 0.45 * sin(wx * 0.0031 + seed_v)) - amp * 0.35 * (0.5 + 0.5 * sin(wx * 0.0093 + seed_v * 2.1))
		pts.append(Vector2(sx, y))
		sx += 24.0
	pts.append(Vector2(SCREEN.x + 40.0, SCREEN.y))
	draw_colored_polygon(pts, col)

func _row(cam_x: float, f: float, spacing: float, fn: Callable) -> void:
	var base := cam_x * f
	var start := int(floor((base - spacing) / spacing))
	var end := int(ceil((base + SCREEN.x + spacing) / spacing))
	for i in range(start, end + 1):
		fn.call(float(i) * spacing - base, i)

func _pine(x: float, base_y: float, h: float, col: Color) -> void:
	for k in 3:
		var top := base_y - h + float(k) * h * 0.27
		var wid := h * (0.22 + float(k) * 0.11)
		draw_colored_polygon(PackedVector2Array([Vector2(x, top), Vector2(x + wid, top + h * 0.4), Vector2(x - wid, top + h * 0.4)]), col)
	draw_rect(Rect2(x - 3, base_y - h * 0.12, 6, h * 0.12), col.darkened(0.2))

func _building(x: float, base_y: float, h: float, w: float, col: Color, glow: Color, seed_i: int) -> void:
	draw_rect(Rect2(x, base_y - h, w, h), col)
	draw_rect(Rect2(x, base_y - h, 3, h), col.lightened(0.08))
	var rows := int(h / 18.0)
	var cols := int(w / 10.0)
	for wy in rows:
		for wx in cols:
			if _rnd(seed_i * 17 + wy * 7 + wx * 3) > 0.45:
				draw_rect(Rect2(x + 6.0 + float(wx) * 10.0, base_y - h + 8.0 + float(wy) * 18.0, 5, 8), Color(glow.r, glow.g, glow.b, 0.75))

func _crystal(x: float, base_y: float, h: float, col: Color, glow: Color) -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(x - h * 0.22, base_y), Vector2(x, base_y - h), Vector2(x + h * 0.22, base_y)]), col)
	draw_colored_polygon(PackedVector2Array([Vector2(x - h * 0.05, base_y - h * 0.2), Vector2(x, base_y - h), Vector2(x + h * 0.07, base_y - h * 0.25)]), Color(glow.r, glow.g, glow.b, 0.55))

func _puff(c: Vector2, s: float, col: Color) -> void:
	draw_circle(c, 16.0 * s, col)
	draw_circle(c + Vector2(18.0 * s, 4.0 * s), 12.0 * s, col)
	draw_circle(c + Vector2(-18.0 * s, 5.0 * s), 11.0 * s, col)
	draw_circle(c + Vector2(4.0 * s, -8.0 * s), 11.0 * s, col)
