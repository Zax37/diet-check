extends Area2D

const shape = preload("res://collider.tres")

var sprite : Sprite
var collision_shape : CollisionShape2D

func _init(var sprite : Sprite):
	self.position = sprite.position + sprite.offset + sprite.texture.get_size() / 2
	self.sprite = sprite
	self.collision_shape = CollisionShape2D.new()
	self.collision_shape.shape = shape

func _ready():
	self.sprite.position = Vector2()
	self.sprite.offset = sprite.texture.get_size() * -0.5
	add_child(self.sprite)
	add_child(self.collision_shape)
