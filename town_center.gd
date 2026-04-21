extends Area2D

var health = 10
var dead = false
@export var cleared_block: PackedScene

var x_value = 0
var y_value = 0

var removed_collision = false
var create = false
var new_id

var workers_in_queue = 0
@export var new_worker: PackedScene

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
	
	add_to_group("building")
	add_to_group("town_center")
	
	var characters = "abcdefghijklmnopqrstuvwxyz"
	new_id = Global.generate_id(characters, 10)
	add_to_group("unit")

func _physics_process(delta):
	if create == true:
		Global.add_to_no_nav_spot.append(Vector2i(x_value, y_value))
		Global.max_population_count += 10
		create = false
	if health <= 0:
		if removed_collision == false:
			Global.add_nav_spot.append(Vector2i(x_value, y_value))
			remove_from_group("building")
			remove_from_group("town_center")
			Global.max_population_count -= 10
			queue_free()
			removed_collision = true
	$ProgressBar.value = health
	if Global.units_selected == true and health > 0 or Global.building_selected == true:
		$ButtonTC.visible = false
		$CanvasLayer.visible = false
	if Global.units_selected == false and health > 0:
		$ButtonTC.visible = true
	
	if workers_in_queue > 0 and $TimerWorker.is_stopped() and Global.population_count < Global.max_population_count:
		$TimerWorker.start()
		
	if workers_in_queue == 0:
		$CanvasLayer/q1.visible = false
		$CanvasLayer/q2.visible = false
		$CanvasLayer/q3.visible = false
		$CanvasLayer/q4.visible = false
	elif workers_in_queue == 1:
		$CanvasLayer/q1.visible = true
		$CanvasLayer/q2.visible = false
		$CanvasLayer/q3.visible = false
		$CanvasLayer/q4.visible = false
	elif workers_in_queue == 2:
		$CanvasLayer/q1.visible = true
		$CanvasLayer/q2.visible = true
		$CanvasLayer/q3.visible = false
		$CanvasLayer/q4.visible = false
	elif workers_in_queue == 3:
		$CanvasLayer/q1.visible = true
		$CanvasLayer/q2.visible = true
		$CanvasLayer/q3.visible = true
		$CanvasLayer/q4.visible = false
	elif workers_in_queue == 4:
		$CanvasLayer/q1.visible = true
		$CanvasLayer/q2.visible = true
		$CanvasLayer/q3.visible = true
		$CanvasLayer/q4.visible = true

func _on_button_remove_pressed():
	health -= 10

func _on_button_add_worker_pressed():
	if workers_in_queue < 4 and Global.population_count < Global.max_population_count and Global.food_count >= 50:
		$TimerWorker.start()
		workers_in_queue += 1
		Global.food_count -= 50

func _on_button_tc_pressed():
	Global.building_selected = true
	$TimerUIOn.start()

func _on_timer_worker_timeout():
	var new_worker_created = new_worker.instantiate()
	add_sibling(new_worker_created)
	new_worker_created.position = position + Vector2(0, 60)
	workers_in_queue -= 1
	if workers_in_queue > 0 and Global.population_count < Global.max_population_count:
		$TimerWorker.start()

func _on_area_entered(area):
	if area.is_in_group("enemy_laser"):
		health -= 1
		area.queue_free()

func _on_timer_ui_on_timeout():
	Global.building_selected = false
	$CanvasLayer.visible = true
