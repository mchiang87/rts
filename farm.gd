extends Area2D

var resource_count = 10
var health = 10
var dead = false

var x_value = 0
var y_value = 0

var removed_collision = false
var create = false

var built_num = 0
var freeze_pos = false
var toggle_y_value = false
var can_place = false
var built_spot = 0
var fully_built = false
var fully_built_val = 0
var new_id = null

func _ready():
	add_to_group('building')
	var characters = 'abcdefghijklmnopqrstuvwxyz'
	new_id = generate_id(characters, 10)

func _physics_process(delta):
	if create == true:
		$buildingSprite.modulate = Color('#ffffff')
		create = false
	if health <= 0 or resource_count <= 0:
		if removed_collision == false:
			Global.add_nav_spot.append(Vector2(x_value - 1, y_value - 1))
			remove_from_group('building')
			queue_free()
			removed_collision = true
	$ProgressBar.value = health
	
	if Global.units_selected == true or Global.building_selected == true:
		$CanvasLayer.visible = false
		if fully_built == false:
			$ButtonTC.visible = false
		else:
			$ButtonTC.visible = true
		#if freeze_pos == true and fully_built == false:
			#$ButtonBuildMe.visible = true
	
	if Global.units_selected == false:
		if fully_built == false:
			$ButtonTC.visible = false
		else:
			$ButtonTC.visible = true
		#if freeze_pos == true and fully_built == false:
			#$ButtonBuildMe.visible = false
		if fully_built == false:
			$CanvasLayer/addWorkerButton.visible = false
		else:
			$CanvasLayer/addWorkerButton.visible = true
	
	var mouse_position = get_global_mouse_position()
	if freeze_pos == false:
		if mouse_position.x > (position.x + 60):
			position.x += 80
			x_value += 2
		if mouse_position.x < (position.x - 60):
			position.x -= 80
			x_value -= 2
		if mouse_position.y > (position.y + 60):
			position.y += 80
			y_value += 2
		if mouse_position.y < (position.y - 60):
			position.y -= 80
			y_value -= 2
		
		if y_value % 4 != 0 and toggle_y_value == true:
			position.x -= 40
			toggle_y_value = false
			x_value -= 1
		if y_value % 4 == 0 and toggle_y_value == false:
			position.x += 40
			toggle_y_value = true
			x_value += 1
	
	if freeze_pos == false:
		if $"../TileMapLayer".get_cell_source_id(Vector2i(x_value, y_value)) == 0:
			can_place = true
			$buildingSprite.modulate = Color('#00ff00')
		else:
			can_place = false
			$buildingSprite.modulate = Color('#ff0000')

	if freeze_pos == true and fully_built == false:
		$buildingSprite.modulate = Color('#00ff00')
	
	if built_num >= 1:
		if built_spot == 0:
			add_to_group('unit')
			#Global.add_to_no_nav_spot.append(Vector2i(x_value - 1, y_value - 1))
			$ProgressBar.visible = true
			#$StaticBody2D/CollisionShape2D.disabled = false
			built_spot += 1
	if built_num >= 5:
		fully_built = true
		if fully_built_val == 0:
			remove_from_group('unbuilt_building')
			add_to_group('built_building')
			add_to_group('farm')
			$buildingSprite/farmPlants.visible = true
			#$ButtonBuildMe.queue_free()
			$CollisionShape2D.scale = Vector2(0.4, 0.4)
			create = true
			fully_built_val += 1

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
		Global.new_worker_target_type = "tile"
		Global.new_worker_target_job = "farm"
		Global.new_worker_target_id = new_id
		$TimerRemoveNav.start()
	else:
		Global.building_selected = true
		$TimerUIOn.start()

func _on_timer_remove_nav_timeout():
	Global.new_worker_target = null
	Global.new_worker_target_type = null
	Global.new_worker_target_job = null
	Global.new_worker_target_id = null

func _on_timer_ui_on_timeout():
	Global.building_selected = false
	$CanvasLayer.visible = true

func _on_area_entered(area):
	if area.is_in_group('worker_tools') and freeze_pos == true:
		if area.get_parent().job_building == true and built_num <= 4:
			area.get_parent().reset_stand_still_time()
			built_num += 1
		if area.get_parent().job_farming_farm == true and built_num >= 5:
			area.get_parent().reset_stand_still_time()
			resource_count -= 1
			area.get_parent().food_gathered += 1
		if area.get_parent().job_building == true and built_num >= 5: #safetynet from worker.gd to ensure workers continue to next build job
			remove_from_group('unbuilt_building')
			area.get_parent().reset_stand_still_time()
			area.get_parent().using_worker_tools = false
			area.get_parent().find_closest_target_for_job()
	if area.is_in_group('enemy_laser') and freeze_pos == true and built_num >= 1:
		health -= 1
		area.queue_free()

func _on_button_place_pressed():
	if can_place == true:
		if freeze_pos == false:
			print('click2')
			add_to_group('unbuilt_building')
			$ButtonPlace.visible = false
			freeze_pos = true
			Global.new_worker_target = position
			Global.new_worker_target_type = "tile"
			Global.new_worker_target_job = "build"
			Global.new_worker_target_id = new_id
			$TimerRemoveNav.start()
