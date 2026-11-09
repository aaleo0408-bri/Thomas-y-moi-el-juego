extends Node2D
## Nodo visual del héroe (8 bits). El jugador (player.gd) fija kind, phase, facing, grav y squash.

const SB := preload("res://scripts/sprite_bank.gd")
const HERO_U := 2.0
const FEET_ROW := 29

var kind := "idle"
var phase := 0
var facing := 1.0
var grav := 1.0
var squash := 0.0
var _t := 0.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _process(delta: float) -> void:
	_t += delta
	if kind == "idle":
		phase = int(_t * 1.6) % 2
	queue_redraw()

func _draw() -> void:
	var tex: Texture2D = SB.hero_texture(kind, phase)
	var sq := clampf(squash / 0.18, 0.0, 1.0)
	# como en la web: origen en los pies (p.y + grav*23), voltea con la gravedad
	draw_set_transform(Vector2(0.0, 23.0 * grav), 0.0, Vector2(facing * (1.0 + sq * 0.1), grav * (1.0 - sq * 0.14)))
	var w := tex.get_width() * HERO_U
	var h := tex.get_height() * HERO_U
	draw_texture_rect(tex, Rect2(-w * 0.5, -FEET_ROW * HERO_U, w, h), false)
