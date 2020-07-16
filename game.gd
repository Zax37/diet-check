extends Node2D

const InteractableObject = preload("res://object.gd")

var level = 1
var player = null
var player_scene = preload("res://player.tscn")
onready var yummy : AudioStreamPlayer = get_node("yummy")
onready var yumyum : AudioStreamPlayer = get_node("yumyum")
onready var tryagain : AudioStreamPlayer = get_node("tryagain")
onready var world = get_node("Navigation2D").get_child(0)
onready var map : TileMap = world.get_child(0)
onready var start_pos = world.get_node("Player").get_child(0).position
onready var bad_root = world.get_node("Bad")
onready var good_root = world.get_node("Good")
onready var goodies = []
onready var baddies = []

func _ready():
	start_pos.x += 36
	start_pos.y -= 38
	player = player_scene.instance()
	player.set_position(start_pos)
	world.remove_child(world.get_node("Player"))
	world.add_child(player)

	if level < 4:
		yummy.play()

		for bad_food in bad_root.get_children():
			var baddie : InteractableObject = InteractableObject.new(bad_food)
			baddies.push_back(baddie)
			bad_food.replace_by(baddie)
			baddie.connect("body_entered", self, "baddie_collect", [baddie])
	
		for good_food in good_root.get_children():
			var goodie : InteractableObject = InteractableObject.new(good_food)
			goodies.push_back(goodie)
			good_food.replace_by(goodie)
			goodie.connect("body_entered", self, "goodie_collect", [goodie])

func baddie_collect(_idk, baddie: InteractableObject):
	yumyum.play()
	player.stop()
	yield(get_tree().create_timer(.7),"timeout")
	tryagain.play()
	yield(get_tree().create_timer(.8),"timeout")
	restart_level()
	
func goodie_collect(_idk, goodie: InteractableObject):
	yumyum.play()
	goodies.remove(goodies.find(goodie))
	good_root.remove_child(goodie)
	
	if (goodies.empty()):
		player.stop()
		yield(get_tree().create_timer(1),"timeout")
		next_level()

func to_tile_pos(var pos: Vector2):
	pos -= world.position
	pos.x = floor(pos.x / map.cell_size.x)
	pos.y = floor(pos.y / map.cell_size.y)
	return pos

func restart_level():
	var pos = world.position
	var parent = world.get_parent()
	parent.remove_child(world)
	parent.add_child(load("res://worlds/%d.tmx" % level).instance())
	_ready()
	world.position = pos

func next_level():
	level = level + 1
	restart_level()

func _unhandled_input(event):
	if event.is_action_pressed("click"):
		var pos = to_tile_pos(get_global_mouse_position())
		map.set_cell(pos.x, pos.y, 4)
		yield(get_tree().create_timer(.1),"timeout")
		player.find_closest_food()
	elif event.is_action_pressed("restart"):
		player.stop()
		tryagain.play()
		yield(get_tree().create_timer(.8),"timeout")
		restart_level()
	#elif event.is_action_pressed("ui_focus_next"):
	#	next_level()
