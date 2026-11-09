extends Node2D
## Plataforma de pixel art (8 bits). Los suelos y techos los dibuja ground_art.gd.

const SB := preload("res://scripts/sprite_bank.gd")

var world := 0
var size := Vector2(10, 10)

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _draw() -> void:
	var tex: Texture2D = SB.platform_texture(world, size.x, size.y)
	var w := tex.get_width() * 2.0
	var h := tex.get_height() * 2.0
	draw_texture_rect(tex, Rect2(-w * 0.5, -h * 0.5, w, h), false)
