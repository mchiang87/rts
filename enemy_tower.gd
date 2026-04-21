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

@export var laser: PackedScene
var target_id = null
var able_to_shoot = true

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
	new_id = Global.generate_id(characters, 10)

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
	
	var all_units = get_tree().get_nodes_in_group('unit')
	for unit in all_units:
		var distance_to_unit = (unit.position - global_position).length()
		if distance_to_unit <= 150 and target_id == null:
			target_id = unit.new_id
			$buildingSprite/turret.look_at(unit.position)
	if target_id != null:
		var unit_exists = false
		for unit in all_units:
			var distance_to_unit = (unit.position - global_position).length()
			if unit.new_id == target_id and distance_to_unit <= 150 and able_to_shoot == true:
				$buildingSprite/turret.look_at(unit.position)
				able_to_shoot = false
				$TimerShoot.start()
				var new_laser = laser.instantiate()
				new_laser.is_good_laser = false
				add_sibling(new_laser)
				new_laser.position = $buildingSprite/turret.global_position
				new_laser.look_at(unit.position)
				new_laser.owners_id = new_id
			if unit.new_id == target_id and distance_to_unit <= 150:
				$buildingSprite/turret.look_at(unit.position)
				unit_exists = true
		if unit_exists == false:
			target_id = null

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

func _on_timer_shoot_timeout():
	able_to_shoot = true
