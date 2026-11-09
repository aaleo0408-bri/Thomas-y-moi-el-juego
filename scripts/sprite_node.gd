extends Node2D
## Dibuja una textura de pixel art centrada. px = píxeles en pantalla por píxel del arte.
## wobble > 0 hace que el sprite oscile (usado por el portal de salida).

var tex: Texture2D
var px := 2.0
var wobble := 0.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _process(_delta: float) -> void:
	if wobble != 0.0:
		rotation = sin(Time.get_ticks_msec() / 1000.0 * 1.2) * wobble
	queue_redraw()

func _draw() -> void:
	if tex == null:
		return
	var w := tex.get_width() * px
	var h := tex.get_height() * px
	draw_texture_rect(tex, Rect2(-w * 0.5, -h * 0.5, w, h), false)
