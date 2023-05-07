extends KinematicBody
var MOVE_SPEED=12
const JUMP_FORCE=16
const GRAVITY=0.75
const MAX_FALL_SPEED=30

const H_LOOK_SENS = 0.25
const V_LOOKS_SENS = 0.25
var move_vec = Vector3()
export (NodePath) var cam_path
onready var cam=get_node(cam_path)
export var song = 0

var y_velo=0
var x_velo=0
var z_velo=0
var z_was_down=0
var x_was_down=0

var saved_x=0
var saved_z=0

var DASH_SPEED=0
var DASH_SPEED_GROUND=30
var DASH_SPEED_AIR=60
var dashing = false
var on_dash_cooldown = false
var dash_timer=null
var dash_cooldown_timer=null

export (NodePath) var guno_path
onready var guno = get_node(guno_path)

export (NodePath) var cty_player_path
onready var cty_player = get_node(cty_player_path)

func play_song_and_shooters():
	if(song==0):
		$cty_with_no_wind_boopers/city_with_no_wind_player.stop()
		$cty_with_no_wind_boopers/city_with_no_wind_player.play("down")
		$songs/the_city_with_no_wind.play()
	if(song==1):
		$cty_cut_boopers/city_with_no_wind_player.stop()
		$cty_cut_boopers/city_with_no_wind_player.play("down")
		$songs/city_cut.play()

var bouncing=false
var bounce_force=30
var actively_bouncing=false

var move_vec_temp=Vector3()
var move_vec_temp_temp=Vector3()
var last_checkpoint_pos=Vector3(3,2,4)

var keep_dashing=false
var current_song="none"

var dash_addition=Vector3()
var bouncing_addition=Vector3()
var can_continue_bounce=true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	print(guno.shoot)
	dash_timer = Timer.new()
	dash_timer.set_one_shot(true)
	dash_timer.set_wait_time(0.2)
	dash_timer.connect("timeout", self, "on_dash_timer_complete")
	add_child(dash_timer)
	
	dash_cooldown_timer = Timer.new()
	dash_cooldown_timer.set_one_shot(true)
	dash_cooldown_timer.set_wait_time(0.5)
	dash_cooldown_timer.connect("timeout", self, "on_dash_cooldown_timer_complete")
	add_child(dash_cooldown_timer)
	play_song_and_shooters()
	
func on_dash_timer_complete():
	keep_dashing=false

func on_dash_cooldown_timer_complete():
	on_dash_cooldown=false

func _input(event):
	if event is InputEventMouseMotion:
		cam.rotation_degrees.x -= event.relative.y * V_LOOKS_SENS
		cam.rotation_degrees.x=clamp(cam.rotation_degrees.x, -90, 90)
		rotation_degrees.y -= event.relative.x * H_LOOK_SENS

func hit_by_spike():
	print("cool")
	translation=last_checkpoint_pos
	play_song_and_shooters()

func need_to_bounce():
	bouncing=true

func _process(delta):
	if(is_on_floor()):
		DASH_SPEED=DASH_SPEED_GROUND
	else:
		DASH_SPEED=DASH_SPEED_AIR
	if(Input.is_action_just_pressed("dash")&&!on_dash_cooldown):
		keep_dashing=true
		on_dash_cooldown=true
		dash_timer.start()
		dash_cooldown_timer.start()
		bouncing_addition=Vector3()
		
		dash_addition=Vector3(x_was_down, 0, z_was_down)
		dash_addition=dash_addition.rotated(Vector3(0,1,0), rotation.y)
		dash_addition*=DASH_SPEED
	
	if(!keep_dashing&&is_on_floor()):
		dash_addition=Vector3()
	
	if(bouncing):
		bouncing=false
		dash_addition=Vector3()
		can_continue_bounce=true
		var move_vec_temp = Vector3()
		move_vec_temp.z+=1
		move_vec_temp=move_vec_temp.normalized()
		move_vec_temp=move_vec_temp.rotated(Vector3(1, 0, 0), deg2rad(cam.rotation_degrees.x))
		move_vec_temp = move_vec_temp.rotated(Vector3(0,1,0), rotation.y)
		move_vec_temp*=bounce_force
		y_velo=move_vec_temp.y
		move_vec_temp.y=0
		bouncing_addition=move_vec_temp
		move_vec_temp=Vector3()
	
	if(is_on_floor()):
		if(Input.is_action_pressed("jump")&&can_continue_bounce):
			can_continue_bounce=false
		else:
			bouncing_addition=Vector3()

	move_vec_temp=Vector3()
	x_velo=0
	z_velo=0
	z_was_down=0
	x_was_down=0
	if Input.is_action_pressed("move_forwards"):
		move_vec_temp.z -=1
		z_was_down-=1
	if Input.is_action_pressed("move_backwards"):
		move_vec_temp.z +=1
		z_was_down+=1
	if Input.is_action_pressed("move_right"):
		move_vec_temp.x +=1
		x_was_down+=1
	if Input.is_action_pressed("move_left"):
		move_vec_temp.x -=1
		x_was_down-=1

	move_vec_temp=move_vec_temp.normalized()
	move_vec_temp=move_vec_temp.rotated(Vector3(0,1,0), rotation.y)
	move_vec_temp*=MOVE_SPEED
	
	x_velo+=move_vec_temp.x
	z_velo+=move_vec_temp.z
	
	var grounded = is_on_floor()
	move_vec.y=y_velo
	y_velo-=GRAVITY
	if grounded and Input.is_action_pressed("jump"):
		y_velo=JUMP_FORCE
	if grounded and y_velo <=0:
		y_velo=-0.1
	if y_velo < -MAX_FALL_SPEED:
		y_velo=-MAX_FALL_SPEED
	
	move_vec=Vector3(move_vec_temp.x,y_velo,move_vec_temp.z)
	move_vec+=dash_addition
	move_vec+=bouncing_addition
	move_and_slide(move_vec, Vector3(0,1,0))
