extends Path2D

const Game = preload("res://scripts/game.gd")
onready var game : Game = get_node("..")
var a : Vector2
func _ready():
	set_process(true)

func _process(delta):
	if curve.get_point_count() >= 2:
		if (curve.get_point_position(1) - game.player.position).length() < 2.0:
			curve.remove_point(0)
		else:
			curve.set_point_position(0, game.player.position)
		update()

func _draw():
	if (curve.get_point_count() >= 2):
		draw_polyline(curve.get_baked_points(), Color.white, 3.0)
