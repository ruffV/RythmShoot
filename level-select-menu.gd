extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_Button1_pressed():
	get_tree().change_scene("res://tutorial.tscn")
	pass # Replace with function body.

func _on_Button2_pressed():
	get_tree().change_scene("res://levels/level1.tscn")
	pass # Replace with function body.
