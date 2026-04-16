extends Camera2D
#todo - make screen vars constants


var cam_move_right = false
var cam_move_left = false
var cam_move_up = false
var cam_move_down = false
@onready var screen = $"../UI/MiniMap/Screen"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if get_local_mouse_position().x > 540: #screen size
		cam_move_right = true
		cam_move_left = false
	if get_local_mouse_position().x < -540: #screen size
		cam_move_right = false
		cam_move_left = true
	if get_local_mouse_position().x > -540 and get_local_mouse_position().x < 540: #screen size
		cam_move_right = false
		cam_move_left = false
		
	if get_local_mouse_position().y > 280: #screen size
		cam_move_up = false
		cam_move_down = true
	if get_local_mouse_position().y < -280: #screen size
		cam_move_up = true
		cam_move_down = false
	if get_local_mouse_position().y > -280 and get_local_mouse_position().y < 280: #screen size
		cam_move_up = false
		cam_move_down = false

	if cam_move_right == true and position.x <= 1940: #cam adjust to map sizes
		position += Vector2(1, 0) * 6 #speed
		screen.position += Vector2(1, 0) * .2
	if cam_move_left == true and position.x >= -870: #cam adjust to map sizes
		position -= Vector2(1, 0) * 6 #speed
		screen.position -= Vector2(1, 0) * .2
	if cam_move_down == true and position.y <= 1700: #cam adjust to map sizes
		position += Vector2(0, 1) * 6 #speed
		screen.position += Vector2(0, 1) * .2 
	if cam_move_up == true and position.y >= -1060: #cam adjust to map sizes
		position -= Vector2(0, 1) * 6 #speed
		screen.position -= Vector2(0, 1) * .2 
