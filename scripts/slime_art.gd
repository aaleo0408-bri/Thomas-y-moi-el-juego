extends Node2D
## Nodo visual del slime (8 bits). Sigue la dirección de patrulla del padre (enemy.gd: `direction`).

const SB := preload("res://scripts/sprite_bank.gd")

var dir := -1.0
var enemy_color := Color("ef6f5e")
var _t := 0.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _process(delta: float) -> void:
	_t += delta
	var parent_node := get_parent()
	if parent_node != null and "direction" in parent_node:
		dir = parent_node.direction
	queue_redraw()

func _draw() -> void:
	var tex: Texture2D = SB.slime_texture(enemy_color)
	var bounce := -2.0 if int(_t * 6.0) % 2 == 1 else 0.0
	var k := 2.0 * 0.9
	draw_set_transform(Vector2(0.0, 16.0 + bounce), 0.0, Vector2(dir, 1.0))
	var w := tex.get_width() * k
	var h := tex.get_height() * k
	draw_texture_rect(tex, Rect2(-w * 0.5, -h, w, h), false)
