extends CharacterBody2D

@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@export var speed = 150
@export var laser: PackedScene

var target_radius = 10
var av = Vector2.ZERO
var avoid_weight = 0.1

var job_building = false
var job_cutting_wood = false
var job_mining_gold = false
var job_farming_farm = false
var job_attack = false
var job_attack_unit = false
var using_worker_tools = false
var target_id = null
var target_middle_of_enemy = null

var wood_gathered = 0
var gold_gathered = 0
var food_gathered = 0

var able_to_shoot = true
var new_id

var health = 10

var selected = false:
	set = set_selected
var target = null:
	set = set_target

func set_selected(value):
	selected = value
	if selected == true:
		$Body/backSprite.visible = true
		Global.units_selected = true
		Global.workers_selected = true
	else:
		$Body/backSprite.visible = false
		Global.units_selected = false
		Global.workers_selected = false

func set_target(value):
	target = value

func avoid():
	var result = Vector2.ZERO
	var neighbors = $Area2D.get_overlapping_bodies()
	if neighbors:
		for neighbor in neighbors:
			result += neighbor.position.direction_to(position)
		result /= neighbors.size()
	return result.normalized()
	
func _on_navigation_agent_2d_veloctiy_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func makepath():
	if target != null:
		nav_agent.target_position = target

func move_towards_target():
	velocity = Vector2.ZERO
	if target != null:
		velocity = position.direction_to(target)
		var dir = to_local(nav_agent.get_next_path_position()).normalized()
		velocity = dir * speed
		if position.distance_to(target) < target_radius:
			target = null
	av = avoid()
	velocity = (velocity + av * avoid_weight).normalized() * speed
	
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(velocity)
	else:
		_on_navigation_agent_2d_veloctiy_computed(velocity)
	
	move_and_slide()
	var next_path_pos = nav_agent.get_next_path_position()

func _ready():
	Global.friendly_units += 1
	Global.population_count += 1
	
	var characters = 'abcdefghijklmnopqrstuvwxyz'
	new_id = generate_id(characters, 10)
	add_to_group("unit")

func _physics_process(delta):
	makepath()
	move_towards_target()
	
	if selected == true and Global.new_worker_target != null:
		turn_off_all_jobs()
		target = Global.new_worker_target
		#refactor below
		if Global.new_worker_target_job == "build":
			job_cutting_wood = false
			job_building = true
			job_mining_gold = false
			job_farming_farm = false
			job_attack_unit = true
			job_attack = false
			target_id = Global.new_worker_target_id
		if Global.new_worker_target_job == "chop_wood":
			job_cutting_wood = true
			job_building = false
			job_mining_gold = false
			job_farming_farm = false
			job_attack_unit = true
			job_attack = false
			target_id = Global.new_worker_target_id
		if Global.new_worker_target_job == "mine_gold":
			job_cutting_wood = false
			job_building = false
			job_mining_gold = true
			job_farming_farm = false
			job_attack_unit = true
			job_attack = false
			target_id = Global.new_worker_target_id
		if Global.new_worker_target_job == "farm":
			job_cutting_wood = false
			job_building = false
			job_mining_gold = false
			job_farming_farm = true
			job_attack_unit = true
			job_attack = false
			target_id = Global.new_worker_target_id
		if Global.new_worker_target_job == "attack_unit":
			job_cutting_wood = false
			job_building = false
			job_mining_gold = false
			job_farming_farm = false
			job_attack_unit = true
			job_attack = true
			target_id = Global.new_worker_target_id
		if Global.new_worker_target_job == "attack_building":
			job_cutting_wood = false
			job_building = false
			job_mining_gold = false
			job_farming_farm = false
			job_attack_unit = false
			job_attack = true
			target_id = Global.new_worker_target_id
		if Global.new_worker_target_type == "tile" and job_farming_farm == false:
			find_closest_side_of_tile()
		#selected = false
	
	if using_worker_tools == true:
		speed = 0
		$AnimationPlayer.play("use_tools")
		await $AnimationPlayer.animation_finished
		if job_cutting_wood == true or job_mining_gold == true or job_farming_farm == true:
			find_closest_drop_off_spot()
			find_closest_side_of_tile()
			using_worker_tools = false
		speed = 150
	
	if (job_cutting_wood == true or job_mining_gold == true or job_farming_farm == true or job_building == true) and $TimerIdleTooLong.time_left == 0 and velocity == Vector2(0, 0) and target == null:
		using_worker_tools = false
		find_closest_target_for_job()
		reset_stand_still_time() #refactor to reset_idle_timer()
		
	check_if_no_more_resources_for_job()

	if velocity != Vector2(0, 0):
		$Body.look_at($NavigationAgent2D.get_next_path_position())

	if job_attack == true and target != null:
		var distance_to_enemy = (target - global_position).length()
		if distance_to_enemy <= 70:
			$Body.look_at(target_middle_of_enemy)
			speed = 0
			if able_to_shoot == true:
				able_to_shoot = false
				$TimerAttack.start()
				var new_laser = laser.instantiate()
				new_laser.is_good_laser = true
				add_sibling(new_laser)
				new_laser.position = $Body.global_position
				new_laser.look_at(target_middle_of_enemy)
				new_laser.owners_id = new_id
			var all_enemies = get_tree().get_nodes_in_group("enemy")
			var found_targeted_enemy = false
			for enemy in all_enemies:
				if enemy.new_id == target_id:
					target = enemy.position
					target_middle_of_enemy = target
					if job_attack_unit == false:
						find_closest_side_of_tile()
					found_targeted_enemy = true
			if found_targeted_enemy == false:
				job_attack = false
				target = null
				target_id = null
				turn_off_all_jobs()
		else:
			var all_enemies = get_tree().get_nodes_in_group("enemy")
			var found_targeted_enemy = false
			for enemy in all_enemies:
				if enemy.new_id == target_id:
					target = enemy.position
					target_middle_of_enemy = target
					find_closest_side_of_tile()
					found_targeted_enemy = true
			if found_targeted_enemy == false:
				job_attack = false
				target = null
				target_id = null
				turn_off_all_jobs()
			speed = 150
			
	$ProgressBar.value = health
	if health <= 0:
		Global.enemy_units -= 1
		Global.population_count -= 1
		queue_free()

func find_closest_side_of_tile():
	if target != null and target.x < self.position.x and target.y < self.position.y:
		target.x = target.x + 40
		target.y = target.y + 40
	if target != null and target.x < self.position.x and target.y > self.position.y:
		target.x = target.x + 40
		target.y = target.y - 40
	if target != null and target.x > self.position.x and target.y < self.position.y:
		target.x = target.x - 40
		target.y = target.y + 40
	if target != null and target.x > self.position.x and target.y > self.position.y:
		target.x = target.x - 40
		target.y = target.y - 40

func _on_area_2d_area_entered(area):
	if area.is_in_group("unbuilt_building") and job_building == true and area.new_id == target_id:
		using_worker_tools = true
		$Body.look_at(area.position)
	if area.is_in_group("built_building") and job_building == true:
		using_worker_tools = false
		find_closest_target_for_job()
		reset_stand_still_time()
	if area.is_in_group("tree") and job_cutting_wood == true and area.new_id == target_id:
		using_worker_tools = true
		$Body.look_at(area.position)
	if area.is_in_group("gold") and job_mining_gold == true and area.new_id == target_id:
		using_worker_tools = true
		$Body.look_at(area.position)
	if area.is_in_group("farm") and job_farming_farm == true and area.new_id == target_id:
		using_worker_tools = true
		$Body.look_at(area.position)
	if area.is_in_group("town_center") and (job_farming_farm == true or job_cutting_wood == true or job_mining_gold == true):
		Global.wood_count += wood_gathered
		Global.gold_count += gold_gathered
		Global.food_count += food_gathered
		
		wood_gathered = 0
		gold_gathered = 0
		food_gathered = 0
		$Body.look_at(area.position)
		go_back_to_the_resources()
	
	if area.is_in_group("enemy_laser"):
		health -= 1
		if target_id != area.owners_id:
			turn_off_all_jobs()
			job_attack = true
			job_attack_unit = true
			target_id = area.owners_id
			$Body.look_at(area.position)
			var all_enemies = get_tree().get_nodes_in_group("enemy")
			for enemy in all_enemies:
				if enemy.new_id == target_id:
					target = enemy.position
					target_middle_of_enemy = target
		area.queue_free()

func reset_stand_still_time():
	$TimerIdleTooLong.start()

func find_closest_target_for_job():
	var lowest_distance = INF
	var closest_job
	var all_jobs
	
	if job_building == true:
		all_jobs = get_tree().get_nodes_in_group("unbuilt_building")
	if job_cutting_wood == true:
		all_jobs = get_tree().get_nodes_in_group("tree")
	if job_mining_gold == true:
		all_jobs = get_tree().get_nodes_in_group("gold")
	if job_farming_farm == true:
		all_jobs = get_tree().get_nodes_in_group("farm")
	for job in all_jobs:
		var distance = job.global_position.distance_to(position)
		if distance < lowest_distance:
			closest_job = job.position
			lowest_distance = distance
			target_id = job.new_id
			target = closest_job
			if job_farming_farm == false:
				find_closest_side_of_tile()

func find_closest_drop_off_spot():
	var lowest_distance = INF
	var closest_drop_offs
	var all_drop_offs
	all_drop_offs = get_tree().get_nodes_in_group('town_center')
	for drop_off in all_drop_offs:
		var distance = drop_off.global_position.distance_to(position)
		if distance < lowest_distance:
			closest_drop_offs = drop_off.position
			lowest_distance = distance
			target = closest_drop_offs

func go_back_to_the_resources():
	var lowest_distance = INF
	var all_resources
	if job_cutting_wood == true:
		all_resources = get_tree().get_nodes_in_group("tree")
	if job_mining_gold == true:
		all_resources = get_tree().get_nodes_in_group("gold")
	if job_farming_farm == true:
		all_resources = get_tree().get_nodes_in_group("farm")
	var found_resource_with_id = false
	for resource in all_resources:
		var distance = resource.global_position.distance_to(position)
		if resource.new_id == target_id:
			target = resource.position
			found_resource_with_id = true
			if job_farming_farm == false:
				find_closest_side_of_tile()
	if found_resource_with_id == false:
		target_id = null
		target = null
		find_closest_target_for_job()

func turn_off_all_jobs():
	target_id = null
	job_attack = false
	job_attack_unit = false
	job_building = false
	job_cutting_wood = false
	job_farming_farm = false
	job_mining_gold = false
	using_worker_tools = false
	speed = 150

func check_if_no_more_resources_for_job():
	var lowest_distance = INF
	var all_resources
	if job_cutting_wood == true:
		all_resources = get_tree().get_nodes_in_group("tree")
	if job_building == true:
		all_resources = get_tree().get_nodes_in_group("unbuilt_buildings")
	if job_mining_gold == true:
		all_resources = get_tree().get_nodes_in_group("gold")
	if job_farming_farm == true:
		all_resources = get_tree().get_nodes_in_group("farm")
	if job_attack == true:
		all_resources = get_tree().get_nodes_in_group("enemies")
	if all_resources == null:
		turn_off_all_jobs()

func _on_timer_attack_timeout():
	able_to_shoot = true

func generate_id(chars, length):
	var word: String
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi() % n_char]
	return word
