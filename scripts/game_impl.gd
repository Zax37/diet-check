extends "res://scripts/game.gd"

const Player = preload("res://player.tscn")
const InteractableObject = preload("res://scripts/object.gd")

var dijkstra_map : DijkstraMap
var grid_to_node : Dictionary
var node_to_grid : Dictionary
var targets : Array
var play_rect : Rect2

var loader

func _exit_tree():
	dijkstra_map.free()

func reversed_dictionary(dic: Dictionary)->Dictionary:
	var ndic = {}
	for key in dic.keys():
		ndic[dic[key]] = key
	return ndic
	
func update_map():
	path.curve.clear_points()
	path.curve.add_point(to_screen_pos(player.tile_pos))
	dijkstra_map.recalculate(targets)
	for pt in dijkstra_map.get_shortest_path_from_point(grid_to_node[player.target_tile_pos]):
		path.curve.add_point(to_screen_pos(node_to_grid[pt]))
		
	path.update()

func _ready():
	map = world.get_node("Map")
	goodies = []
	baddies = []
	targets = []

	play_rect = map.get_used_rect()
	dijkstra_map = DijkstraMap.new()
	grid_to_node = dijkstra_map.add_square_grid(0, play_rect)
	node_to_grid = reversed_dictionary(grid_to_node)

	for v in map.get_used_cells():
		var obj = null
		var id = map.get_cellv(v) - 1

		if id == PlayerSpawnID:
			player = Player.instance()
			obj = player
		elif id in SweetsIDs:
			obj = InteractableObject.new(map.tile_set.tile_get_texture(id + 1))
			baddies.push_back(obj)
			obj.connect("area_entered", self, "baddie_collect", [obj])
			targets.push_back(grid_to_node[v])
		elif id in HealthyIDs:
			obj = InteractableObject.new(map.tile_set.tile_get_texture(id + 1))
			goodies.push_back(obj)
			obj.connect("area_entered", self, "goodie_collect", [obj])
		else:
			dijkstra_map.disable_point(grid_to_node[v])

		if obj != null:
			map.set_cellv(v, -1)
			obj.tile_pos = v
			obj.set_position(map.map_to_world(v) + map.position + TileCenter)
			world.add_child(obj)

	update_map()

	if level < 4:
		if not SoundManager.bgm_playing:
			SoundManager.play_bgm("Music")
		SoundManager.play_se("Begin")

func baddie_collect(_idk, baddie: InteractableObject):
	SoundManager.play_se("Eat")
	player.stop()
	yield(get_tree().create_timer(.7),"timeout")
	SoundManager.play_se("TryAgain")
	yield(get_tree().create_timer(.8),"timeout")
	restart_level()
	
func goodie_collect(_idk, goodie: InteractableObject):
	SoundManager.play_se("Eat")
	goodies.remove(goodies.find(goodie))
	goodie.queue_free()
	player.delay_next_move()
	
	if (goodies.empty()):
		player.stop()
		yield(get_tree().create_timer(1),"timeout")
		next_level()

func restart_level():
	loader = ResourceLoader.load_interactive("res://worlds/%d.tmx" % level)
	set_process(true)

func next_level():
	level = level + 1
	restart_level()
	
func _process(delta):
	if loader == null:
		set_process(false)
		return

	var err = loader.poll()

	if err == ERR_FILE_EOF: # Finished loading.
		var level = loader.get_resource()
		loader = null
		world.queue_free()
		remove_child(world)
		world = level.instance()
		world.set_name("World")
		add_child(world)
		#move_child(world, 0)
		_ready()
	elif err == OK:
		#update_progress()
		pass
	else: # error during loading
		#show_error()
		loader = null

func _unhandled_input(event):
	if event.is_action_pressed("click"):
		var pos = to_tile_pos(get_global_mouse_position())
		if pos == player.target_tile_pos:
			if pos == player.tile_pos:
				return
			player.bounce()
		elif pos == player.tile_pos:
			player.push()
		elif pos.x < play_rect.position.x or pos.x >= play_rect.end.x \
		  or pos.y < play_rect.position.y or pos.y >= play_rect.end.y:
			return
		map.set_cell(pos.x, pos.y, 4)
		dijkstra_map.disable_point(grid_to_node[pos])
		update_map()
	elif event.is_action_pressed("restart"):
		player.stop()
		SoundManager.play_se("TryAgain")
		yield(get_tree().create_timer(.8),"timeout")
		restart_level()
	elif event.is_action_pressed("ui_focus_next"):
		next_level()

func lead_to_goodie(var pos: Vector2)->Vector2:
	var target_node = dijkstra_map.get_direction_at_point(grid_to_node[pos])
	return Vector2.ZERO if target_node == -1 else node_to_grid[target_node] - pos
