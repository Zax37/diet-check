extends RigidBody2D

const eps = 16.5

var speed = 200
var points = []
onready var game = get_node("../../..")
onready var path : Path2D = game.get_node("Path2D")
onready var navigation : Navigation2D = game.get_node("Navigation2D")
onready var world = navigation.get_child(0)
onready var map = world.get_child(0)
onready var bad_food = get_node("../Bad")
onready var timer : Timer = get_node("Timer")

func _ready():
	set_process(true)
	timer.connect("timeout", self, "find_closest_food")
	timer.start()
	set_bounce(1.0)

func align_to_tile_center(var pos: Vector2):
	pos = game.to_tile_pos(pos)
	pos.x = (pos.x + 0.5) * map.cell_size.x
	pos.y = (pos.y + 0.5) * map.cell_size.y
	return pos + world.position

func stop():
	points = []
	path.curve.clear_points()
	path.update()

func round_path():
	var new_points = [points[0]]
	var horizontal = false
	for i in range(1, points.size()):
		if points[i].x != points[i - 1].x and points[i].y != points[i - 1].y:
			new_points.pop_back()
			if not horizontal:
				new_points.push_back(Vector2(points[i - 1].x, points[i].y))
			else:
				new_points.push_back(Vector2(points[i].x, points[i - 1].y))
			horizontal = not horizontal
		else:
			horizontal = abs(points[i].x - points[i - 1].x) > abs(points[i].y - points[i - 1].y)
		new_points.push_back(points[i])
	points = new_points

func find_closest_food():
	var best_distance = 0
	for food in bad_food.get_children():
		var source_pos = get_global_position()
		var target_pos = food.get_global_position()
		var test_path = navigation.get_simple_path(source_pos, target_pos, false)
		if (test_path.empty()):
			continue

		var test_distance = 0
		
		for i in range(1, test_path.size()):				
			test_distance += test_path[i-1].distance_to(test_path[i])
		
		if best_distance == 0 or test_distance < best_distance:
			best_distance = test_distance
			points = test_path

	path.curve.clear_points()

	if best_distance == 0:
		points.resize(0)
	elif not points.empty():
		round_path()
		for i in range(points.size() - 1, -1, -1):
			path.curve.add_point(points[i], Vector2(1.0, 1.0), Vector2(1.0, 1.0))

	path.update()

func _process(delta):		
	if points.empty():
		var distance = align_to_tile_center(get_global_position()) - get_global_position()
		if distance.length() > eps:
			var direction = (linear_velocity.normalized() + distance.normalized()) / 2
			set_linear_velocity(direction * speed)
	else:
		var distance = points[0] - get_global_position()
		
		if distance.length() <= eps:
			points.remove(0)
		else:
			var direction = (linear_velocity.normalized() + distance.normalized()) / 2
			set_linear_velocity(direction * speed)
	update()

#func _draw():
	#if points.size() > 1:
		#for p in points:
			#draw_circle(p - get_global_position(), 8, Color.green)
