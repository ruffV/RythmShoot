extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_body_entered(body):
	if body.has_method("hit_by_spike"):
		body.hit_by_spike()
