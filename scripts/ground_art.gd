extends Node2D
## Suelo y techo de pixel art para todo el nivel (franjas de 2 px por píxel del arte).

const SB := preload("res://scripts/sprite_bank.gd")

var world := 0
var level_length := 2700.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _draw() -> void:
	var floor_tex: Texture2D = SB.strip_texture(world, int(ceil((level_length + 400.0) / 2.0)), 40, false)
	var ceil_tex: Texture2D = SB.strip_texture(world, int(ceil((level_length + 400.0) / 2.0)), 21, true)
	draw_texture_rect(floor_tex, Rect2(-200.0, 616.0, floor_tex.get_width() * 2.0, floor_tex.get_height() * 2.0), false)
	draw_texture_rect(ceil_tex, Rect2(-200.0, 0.0, ceil_tex.get_width() * 2.0, ceil_tex.get_height() * 2.0), false)
