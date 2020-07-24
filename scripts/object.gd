extends Area2D

const shape = preload("res://collider.tres")

var sprite : Sprite
var collision_shape : CollisionShape2D
var tile_pos : Vector2

func _init(var texture : Texture):
	self.sprite = Sprite.new()
	self.sprite.set_texture(texture)
	self.collision_shape = CollisionShape2D.new()
	self.collision_shape.shape = shape

func _ready():
	add_child(self.sprite)
	add_child(self.collision_shape)
