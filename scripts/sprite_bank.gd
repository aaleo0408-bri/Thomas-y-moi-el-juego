extends RefCounted
## Texturas de pixel art (8 bits) generadas desde las rejillas de sprite_data.gd.
## Espejo de la versión web (index.html): mismos sprites, mismos tonos por mundo.
## 1 píxel del arte = 2 px en pantalla (los nodos usan texture_filter nearest).

const D := preload("res://scripts/sprite_data.gd")

static var _cache := {}

static func _rgb(s: String) -> Color:
	if s.begins_with("#"):
		return Color(s)
	var p := s.split(",")
	return Color(p[0].to_float() / 255.0, p[1].to_float() / 255.0, p[2].to_float() / 255.0)

static func _apply(col: Color, rc: Dictionary) -> Color:
	if rc.has("hue"):
		return Color.from_hsv(fposmod(col.h + float(rc["hue"]), 1.0), col.s, col.v, col.a)
	if rc.has("grey"):
		var l := 0.3 * col.r + 0.59 * col.g + 0.11 * col.b
		return Color(l, l, l, col.a)
	return col

## Cambio de tono: lleva el color de referencia al color objetivo conservando brillo y saturación.
static func hue_recolor(ref_rgb: String, target_hex: String) -> Dictionary:
	var rc := _rgb(ref_rgb)
	var tc := Color(target_hex)
	return {"hue": tc.h - rc.h}

## Convierte una rejilla de caracteres en imagen. Celdas "." quedan transparentes.
static func grid_image(rows: Array, pal: Dictionary, rc: Dictionary = {}) -> Image:
	var h := rows.size()
	var w := (rows[0] as String).length()
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in h:
		var r: String = rows[y]
		for x in w:
			var ch := r[x]
			if ch == "." or not pal.has(ch):
				continue
			img.set_pixel(x, y, _apply(_rgb(pal[ch]), rc))
	return img

static func _tex_from_sprite(name: String, rc: Dictionary) -> ImageTexture:
	var key := "spr|" + name + "|" + str(rc)
	if not _cache.has(key):
		var entry: Dictionary = D.SPR[name]
		_cache[key] = ImageTexture.create_from_image(grid_image(entry["grid"], entry["pal"], rc))
	return _cache[key]

static func spr_texture(name: String) -> ImageTexture:
	return _tex_from_sprite(name, {})

static func spr_texture_grey(name: String) -> ImageTexture:
	return _tex_from_sprite(name, {"grey": true})

## Slime con el tono del mundo (el dibujo base es verde).
static func slime_texture(enemy_color: Color) -> ImageTexture:
	var rc := hue_recolor(D.SPR["slime"]["pal"]["a"], "#" + enemy_color.to_html(false))
	return _tex_from_sprite("slime", rc)

static func portal_texture(accent_hex: String) -> ImageTexture:
	var rc := hue_recolor(D.SPR["portal"]["pal"]["a"], accent_hex)
	return _tex_from_sprite("portal", rc)

## Valor de un mundo. Claves "grupo_nombre" (p. ej. "plat_top") leen dentro del grupo anidado.
static func world_value(world: int, key: String) -> String:
	var w: Dictionary = D.WORLDS[clampi(world, 0, 2)]
	var parts := key.split("_", true, 1)
	if parts.size() == 2 and w.has(parts[0]):
		return str(w[parts[0]][parts[1]])
	return str(w.get(key, ""))

static func world_color(world: int, key: String) -> Color:
	return Color(world_value(world, key))

static func _part(x: int, y: int, w: int) -> String:
	if y >= 20:
		return "lL" if x < w / 2 else "lR"
	if y < 10:
		return "h"
	return "t"

static func _hero_offsets(kind: String, phase: int) -> Dictionary:
	var off := {"h": Vector2i.ZERO, "t": Vector2i.ZERO, "lL": Vector2i.ZERO, "lR": Vector2i.ZERO}
	if kind == "run":
		if phase == 1:
			off["lL"] = Vector2i(1, -2)
			off["h"] = Vector2i(0, -1)
			off["t"] = Vector2i(0, -1)
		if phase == 3:
			off["lR"] = Vector2i(-1, -2)
			off["h"] = Vector2i(0, -1)
			off["t"] = Vector2i(0, -1)
	elif kind == "jump":
		off["h"] = Vector2i(0, -1)
		off["t"] = Vector2i(0, -1)
		off["lL"] = Vector2i(2, -4)
		off["lR"] = Vector2i(-2, -3)
	elif kind == "fall":
		off["lL"] = Vector2i(1, -1)
		off["lR"] = Vector2i(-1, -1)
	elif phase == 1:
		off["h"] = Vector2i(0, -1)
		off["t"] = Vector2i(0, -1)
	return off

## Fotograma del héroe. kind: idle | run | jump | fall. Mismo recorte por partes que la versión web.
static func hero_texture(kind: String, phase: int) -> ImageTexture:
	var key := "hero|%s|%d" % [kind, phase]
	if _cache.has(key):
		return _cache[key]
	var off := _hero_offsets(kind, phase)
	var rows: Array = D.HERO_ROWS
	var w := (rows[0] as String).length()
	var h := rows.size()
	var pad := 2
	var top := 1
	var gw := w + pad * 2
	var gh := h + top + 1
	var img := Image.create(gw, gh, false, Image.FORMAT_RGBA8)
	for y in h:
		var r: String = rows[y]
		for x in w:
			var ch := r[x]
			if ch == "." or not D.HERO_PAL.has(ch):
				continue
			var o: Vector2i = off[_part(x, y, w)]
			var px := x + o.x + pad
			var py := y + o.y + top
			if px >= 0 and py >= 0 and px < gw and py < gh:
				img.set_pixel(px, py, _rgb(D.HERO_PAL[ch]))
	var t := ImageTexture.create_from_image(img)
	_cache[key] = t
	return t

## Vecinos de un mapa de celdas: añade contorno negro alrededor de lo dibujado.
static func _outline_grid(g: Array) -> Array:
	var h := g.size()
	var w: int = (g[0] as Array).size()
	var out := []
	for y in h:
		var row := []
		for x in w:
			var v: String = g[y][x]
			if v == ".":
				var edge := false
				for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
					var nx: int = x + int(d.x)
					var ny: int = y + int(d.y)
					if nx >= 0 and ny >= 0 and nx < w and ny < h and g[ny][nx] != ".":
						edge = true
				row.append("k" if edge else ".")
			else:
				row.append(v)
		out.append(row)
	return out

static func _to_rows(g: Array) -> Array:
	var rows := []
	for r in g:
		rows.append("".join(PackedStringArray(r)))
	return rows

static func _rnd(i: float) -> float:
	var s := sin(i * 127.1 + 311.7) * 43758.5453
	return s - floor(s)

## Plataforma con tapa, remaches y contorno (espejo de platCanvas de la web).
static func platform_texture(world: int, w_px: float, h_px: float) -> ImageTexture:
	var wu := maxi(4, roundi(w_px / 2.0))
	var hu := maxi(3, roundi(h_px / 2.0))
	var key := "plat|%d|%d|%d" % [world, wu, hu]
	if _cache.has(key):
		return _cache[key]
	var g := []
	for y in hu:
		var row := []
		for x in wu:
			var v := "p"
			if y == 0:
				v = "T"
			elif y == hu - 1:
				v = "q"
			if y == 1 and x % 5 == 2:
				v = "r"
			row.append(v)
		g.append(row)
	var rows := _to_rows(_outline_grid(g))
	var pal := {
		"T": world_value(world, "plat_top"), "p": world_value(world, "plat_body"),
		"q": world_value(world, "plat_shade"), "r": world_value(world, "plat_rivet"), "k": "#1a1224",
	}
	var t := ImageTexture.create_from_image(grid_image(rows, pal))
	_cache[key] = t
	return t

## Franja de suelo (floor) o techo (ceil), espejo de stripCanvas de la web.
static func strip_texture(world: int, wu: int, hu: int, ceil_strip: bool) -> ImageTexture:
	var key := "strip|%d|%d|%d|%s" % [world, wu, hu, str(ceil_strip)]
	if _cache.has(key):
		return _cache[key]
	var g := []
	for y in hu:
		var row := []
		for x in wu:
			var v := "d"
			if y == 0:
				v = "G"
			elif y == 1:
				v = "g" if _rnd(x * 1.7) > 0.5 else "G"
			elif y == 2:
				v = "g"
			else:
				var r := _rnd(x * 13 + y * 7)
				v = "D" if r > 0.92 else ("L" if r > 0.8 else "d")
			if world == 1 and y == 5 and int(floor(x / 7.0)) % 4 == 0:
				v = "Y"
			if world == 2 and y >= 3 and _rnd(x * 3 + y) > 0.97:
				v = "C"
			row.append(v)
		g.append(row)
	if ceil_strip:
		g.reverse()
	var glow := world_value(world, "tile_glow")
	if glow == "":
		glow = "#6fffd8"
	var pal := {
		"G": world_value(world, "tile_top"), "g": world_value(world, "tile_topD"),
		"d": world_value(world, "tile_dirt"), "D": world_value(world, "tile_pebble"),
		"L": world_value(world, "tile_dirtL"), "Y": "#ffe27a", "C": glow,
	}
	var t := ImageTexture.create_from_image(grid_image(_to_rows(g), pal))
	_cache[key] = t
	return t
