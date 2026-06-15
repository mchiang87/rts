extends Node2D

var dragging = false
var drag_start = Vector2.ZERO
var select_rect = RectangleShape2D.new()
#var selected = []

#func _ready() -> void:
	#worker.input_pickable = true
	#worker.input_event.connect(_on_worker_input_event)
#
#func _on_worker_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	#print(event)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				dragging = true
				drag_start = get_global_mouse_position()
				for item in Global.selected:
					if str(item.collider) != "<Freed Object>":
						#item.collider.turn_off_all_jobs()
						item.collider.selected = false
				#selected = []
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				for item in Global.selected:
					if str(item.collider) != "<Freed Object>":
						item.collider.target = get_global_mouse_position()
						item.collider.turn_off_all_jobs()
						#item.collider.selected = false
				#selected = []
		elif dragging == true:
			dragging = false
			queue_redraw()
			var drag_end = get_global_mouse_position()
			select_rect.extents = abs(drag_end - drag_start) / 2
			var space = get_world_2d().direct_space_state
			var q = PhysicsShapeQueryParameters2D.new()
			q.shape = select_rect
			q.collision_mask = 2
			q.transform = Transform2D(0, (drag_end + drag_start) / 2)
			Global.selected = space.intersect_shape(q)
			#print(Global.selected.size())
			for item in Global.selected:
				#print(item.collider)
				#print(item.collider.unit_name)
				item.collider.selected = true
	
	if event is InputEventMouseMotion and dragging:
		queue_redraw()
		
func _draw():
	if dragging == true:
		draw_rect(Rect2(drag_start, get_global_mouse_position() - drag_start), Color.WHITE, false, 4.0)

func _process(delta):
	if Global.units_selected == false:
		Global.selected = []
