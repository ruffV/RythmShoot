extends Area

export (NodePath) var ray_path
onready var raycast = get_node(ray_path)
export (NodePath) var explo_path
onready var explo = get_node(explo_path)
export (NodePath) var explo_path2
onready var explo2 = get_node(explo_path2)
export (NodePath) var explo_anim_path
onready var explo_anim = get_node(explo_anim_path)
export (NodePath) var explo_anim_path2
onready var explo_anim2 = get_node(explo_anim_path2)
export (NodePath) var player_path
onready var player = get_node(player_path)
var shoot=false

var blast=false

func _ready():
	explo.hide()
	explo2.hide()


func _process(delta):
	if(shoot):
		print("shot")
		explo.show()
		explo_anim.play("explosion")
		check_collision()
		shoot=false
	#if(Input.is_action_just_pressed("ml")):
		#shoot=true
	#if(Input.is_action_just_pressed("mr")):
		#blast=true
	if (blast):
		print("blasted")
		explo2.show()
		explo_anim2.play("explosion")
		blast=false

func check_collision():
	if(raycast.is_colliding()):
		var collider=raycast.get_collider()
		print(raycast.get_collider().get_name())
		if(collider.is_in_group("enemy") or collider.get_name()=="StaticBodyT"):
			collider.queue_free()
			print("???")


func _on_body_entered(body):
	print(body.get_name())
	if(body.is_in_group("booper")):
		shoot=true
		print("h")
	if(body.get_name()=="StaticBodyB"):
		print("blasted")
		blast=true
		player.need_to_bounce()
