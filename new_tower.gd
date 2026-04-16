extends Area2D

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

@export var laser: PackedScene
var target_id = null
var able_to_shoot = true

func _ready():
	add_to_group('building')
	var characters = 'abcdefghijklmnopqrstuvwxyz'
	new_id = generate_id(characters, 10)

func _physics_process(delta):
	if create == true:
		$buildingSprite.modulate = Color('#ffffff')
		create = false
	if health <= 0:
		if removed_collision == false:
			Global.add_nav_spot.append(Vector2(x_value - 1, y_value - 1))
			remove_from_group('building')
			queue_free()
			removed_collision = true
	$ProgressBar.value = health
	
	if Global.workers_selected == true or Global.building_selected == true:
		$CanvasLayer.visible = false
		$ButtonTC.visible = false
		if freeze_pos == true and fully_built == false:
			$ButtonBuildMe.visible = true
	
	if Global.workers_selected == false:
		$ButtonTC.visible = true
		if freeze_pos == true and fully_built == false:
			$ButtonBuildMe.visible = false

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
			Global.add_to_no_nav_spot.append(Vector2i(x_value - 1, y_value - 1))
			$ProgressBar.visible = true
			$StaticBody2D/CollisionShape2D.disabled = false
			built_spot += 1
	if built_num >= 5:
		fully_built = true
		if fully_built_val == 0:
			remove_from_group('unbuilt_building')
			add_to_group('built_building')
			$ButtonBuildMe.queue_free()
			$buildingSprite/Sprite2D/turret.visible = true
			create = true
			fully_built_val += 1
	
	var all_units = get_tree().get_nodes_in_group('enemy')
	for unit in all_units:
		var distance_to_unit = (unit.position - global_position).length()
		if distance_to_unit <= 150 and target_id == null and fully_built == true:
			target_id = unit.new_id
			$buildingSprite/Sprite2D/turret.look_at(unit.position)
	if target_id != null:
		var unit_exists = false
		for unit in all_units:
			var distance_to_unit = (unit.position - global_position).length()
			if unit.new_id == target_id and distance_to_unit <= 150 and able_to_shoot == true:
				$buildingSprite/Sprite2D/turret.look_at(unit.position)
				able_to_shoot = false
				$TimerShoot.start()
				var new_laser = laser.instantiate()
				new_laser.is_good_laser = true
				add_sibling(new_laser)
				new_laser.position = $buildingSprite/Sprite2D/turret.global_position
				new_laser.look_at(unit.position)
				new_laser.owners_id = new_id
			if unit.new_id == target_id and distance_to_unit <= 150:
				$buildingSprite/Sprite2D/turret.look_at(unit.position)
				unit_exists = true
		if unit_exists == false:
			target_id = null

func generate_id(chars, length):
	var word: String
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi() % n_char]
	return word

func _on_button_remove_pressed():
	health -= 10

func _on_button_tc_pressed():
	Global.building_selected = true
	$TimerUIOn.start()

func _on_button_build_me_pressed():
	Global.new_worker_target = position
	Global.new_worker_target_type = "tile"
	Global.new_worker_target_job = "build"
	Global.new_worker_target_id = new_id
	$TimerRemoveNav.start()

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
			add_to_group('unbuilt_building')
			$ButtonPlace.visible = false
			freeze_pos = true


func _on_timer_shoot_timeout():
	able_to_shoot = true
