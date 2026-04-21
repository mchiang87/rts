extends Area2D

@export var resource_count = 10
var dead = false
@export var cleared_block: PackedScene

var x_value = 0
var y_value = 0

var removed_collision = false
var create = false
var new_id

@export var tree = false
@export var gold = false

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
	
	if tree == true:
		add_to_group("tree")
	if gold == true:
		add_to_group("gold")

func _physics_process(delta):
	if create == true:
		Global.add_to_no_nav_spot.append(Vector2i(x_value, y_value))
		create = false
	if resource_count <= 0:
		if removed_collision == false:
			Global.add_nav_spot.append(Vector2i(x_value, y_value))
			queue_free()
			removed_collision = true
	
	if Global.units_selected == true:
		$ButtonSelect.visible = true
	if Global.units_selected == false:
		$ButtonSelect.visible = false
	
	if resource_count <= 0:
		queue_free()

func generate_id(chars, length):
	var word: String = ''
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi() % n_char]
	return word

func _on_area_entered(area):
	if area.is_in_group("worker_tools") and area.get_parent().job_cutting_wood == true and tree == true:
		area.get_parent().reset_stand_still_time()
		resource_count -= 1
		area.get_parent().wood_gathered += 1
	if area.is_in_group("worker_tools") and area.get_parent().job_mining_gold == true and gold == true:
		area.get_parent().reset_stand_still_time()
		resource_count -= 1
		area.get_parent().gold_gathered += 1

func _on_button_select_pressed():
	Global.new_worker_target = position
	Global.new_worker_target_type = "tile"
	if tree == true:
		Global.new_worker_target_job = "chop_wood"
	if gold == true:
		Global.new_worker_target_job = "mine_gold"
	Global.new_worker_target_id = new_id
	$TimerRemoveNav.start()

func _on_timer_remove_nav_timeout():
	Global.new_worker_target = null
	Global.new_worker_target_type = null
	Global.new_worker_target_job = null
	Global.new_worker_target_id = null
