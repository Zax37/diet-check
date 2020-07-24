extends Node2D

const TileCenter = Vector2(36, -38)

const PlayerSpawnID = 2
const SweetsIDs = [ 0, 10, 11 ]
const HealthyIDs = [ 4, 6, 7, 8, 9 ]

var level = 1
var player = null

onready var world : Node2D = get_node("World")
onready var path : Path2D = get_node("Path2D")
var map : TileMap
var goodies = []
var baddies = []

func to_tile_pos(var pos: Vector2):
	var ret = map.world_to_map(pos - map.position)
	ret.y += 1
	return ret

func to_screen_pos(var pos: Vector2):
	return map.map_to_world(pos) + map.position + TileCenter

func lead_to_goodie(var pos: Vector2)->Vector2:
	return Vector2.ZERO
