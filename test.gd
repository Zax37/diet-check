extends Path2D

var time = 0.0

func _ready():
	set_process(true)

func _process(delta):
	time += delta
	#curve.set_point_out(0, Vector2(0, -sin(time * 10) * 5))
	#curve.set_point_in(1, Vector2(0, sin(time * 10) * 5))
	update()

func _draw():
	if (curve.get_point_count() >= 2):
		draw_polyline(curve.get_baked_points(), Color.white, 3.0)
