extends Area2D

var health = 10
var dead = false
@export var cleared_block: PackedScene

var x_value = 0
var y_value = 0

var removed_collision = false
var create = false
var new_id
var is_a_building = true

func _ready():
	var new_pos = cleared_block.instantiate()
	add_child(new_pos)
	if position.x > 0:
		new_pos.position.x -= position.x
	if position.x < 0:
		new_pos.position.x += (position.x * -1)
	if position.y > 0:
		new_pos.position.y -= position.y
	if position.y < 0:
		new_pos.position.y += (position.y * -1)
	
	while new_pos.position.x < (0):
		if new_pos.position.x < (position.x):
			new_pos.position.x += 40 #can update depending on map size
			x_value += 1
	while new_pos.position.x > 40:
		if new_pos.position.x > (position.x):
			new_pos.position.x -= 40 #can update depending on map size
			x_value -= 1
	while new_pos.position.y < (-40):
		if new_pos.position.y < (position.y):
			new_pos.position.y += 40 #can update depending on map size
			y_value += 1
	while new_pos.position.y > (0):
		if new_pos.position.y > (position.y):
			new_pos.position.y -= 40 #can update depending on map size
			y_value -= 1
	
	x_value -= 1
	new_pos.position.y += 20 #force center on tc
	new_pos.position.x -= 20
	
	create = true
	
	var characters = "abcdefghijklmnopqrstuvwxyz"
	new_id = generate_id(characters, 10)

func _physics_process(delta):
	if create == true:
		Global.add_to_no_nav_spot.append(Vector2i(x_value, y_value))
		create = false
	if health <= 0:
		if removed_collision == false:
			Global.add_nav_spot.append(Vector2i(x_value, y_value))
			queue_free()
			removed_collision = true
	$ProgressBar.value = health
	if Global.units_selected == true and health > 0:
		$ButtonTC.visible = true
	if Global.units_selected == false and health > 0:
		$ButtonTC.visible = false

func generate_id(chars, length):
	var word: String
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi() % n_char]
	return word

func _on_button_remove_pressed():
	health -= 10

func _on_button_tc_pressed():
	if Global.units_selected == true:
		Global.new_worker_target = position
		Global.new_worker_target_job = 'attack_building'
		Global.new_worker_target_id = new_id
		$TimerRemoveNav.start()

func _on_area_entered(area):
	if area.is_in_group("unit_laser"):
		health -= 1
		area.queue_free()

func _on_timer_remove_nav_timeout():
	Global.new_worker_target = null
	Global.new_worker_target_job = null
	Global.new_worker_target_id = null
