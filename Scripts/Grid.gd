extends Node2D

# state machine
enum {wait, move}
var state

# Grid variables
export (int) var width
export (int) var height
export (int) var x_start
export (int) var y_start
export (int) var offset

export (int) var y_offset

# Resources
var piece = preload("res://Scenes/Piece.tscn")
const charac = [["我",2],["是", 3],["中", 0],["国", 1],["人",1],["的", 4]]
const possible_pieces = [
	preload("res://Scenes/Red.tscn"),
	preload("res://Scenes/Yellow.tscn"),
	preload("res://Scenes/Green.tscn"),
	preload("res://Scenes/Blue.tscn"),
	preload("res://Scenes/Grey.tscn")
]

# Current pieces in the scene
var all_pieces = []

# swap back variables
var piece_one = null
var piece_two = null
var last_place = Vector2(0, 0)
var last_direction = Vector2(0, 0)
var move_checked = false

# Touch variables
var first_touch = Vector2(0, 0)
var final_touch = Vector2(0, 0)
var controlling = false

func _ready():
	state = move
	all_pieces = make_2d_array()
	print(all_pieces)
	spawn_pieces()

func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array

func spawn_pieces():
	for i in width:
		for j in height:
			var rand = floor(rand_range(0, 6))
			var loop = 0
			while(match_at(i, j, charac[rand][0]) && loop < 100):
				rand = floor(rand_range(0, 6))
				loop += 1
			var new_piece = possible_pieces[charac[rand][1]].instance()
			add_child(new_piece)
			new_piece.position = grid_to_pixel(i, j)
			new_piece.set_hanzi(charac[rand][0])
			all_pieces[i][j] = new_piece

func match_at(i, j, hanzi):
	if i > 1:
		if all_pieces[i - 1][j] != null && all_pieces[i - 2][j] != null:
			if all_pieces[i - 1][j].get_hanzi() == hanzi && all_pieces[i - 2][j].get_hanzi() == hanzi:
				return true
	if j > 1:
		if all_pieces[i][j - 1] != null && all_pieces[i][j - 2] != null:
			if all_pieces[i][j - 1].get_hanzi() == hanzi && all_pieces[i][j - 2].get_hanzi() == hanzi:
				return true
	pass;

func grid_to_pixel(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start + offset * row
	return Vector2(new_x, new_y)

func pixel_to_grid(pixel_position):
	var new_x = round((pixel_position.x - x_start) / offset)
	var new_y = round((pixel_position.y - y_start) / offset)
	return Vector2(new_x, new_y)

func is_in_grid(grid_position):
	if grid_position.x >= 0 && grid_position.x < width:
		if grid_position.y >= 0 && grid_position.y < height:
			return true
	return false

func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position())):
			first_touch = pixel_to_grid(get_global_mouse_position())
			controlling = true
	if Input.is_action_just_released("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position())):
			controlling = false
			final_touch = pixel_to_grid(get_global_mouse_position())
			touch_difference(first_touch, final_touch)

func swap_pieces(col, row, direction):
	var first_piece = all_pieces[col][row]
	var other_piece = all_pieces[col + direction.x][row + direction.y]
	if first_piece != null && other_piece != null:
		store_info(first_piece, other_piece, Vector2(col, row), direction)
		state = wait
		all_pieces[col][row] = other_piece
		all_pieces[col + direction.x][row + direction.y] = first_piece
		first_piece.move(grid_to_pixel(col + direction.x, row + direction.y))
		other_piece.move(grid_to_pixel(col, row))
		if !move_checked:
			find_matches()

func store_info(first_piece, other_piece, place, direction):
	piece_one = first_piece
	piece_two = other_piece
	last_place = place
	last_direction = direction
	pass

func swap_back():
	# Move the previously swapped pieces
	if piece_one != null && piece_two != null:
		swap_pieces(last_place.x, last_place.y, last_direction)
	state = move
	move_checked = false
	pass

func touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(1, 0))
		elif difference.x < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(-1, 0))
	elif abs(difference.x) < abs(difference.y):
		if difference.y > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, 1))
		elif difference.y < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2(0, -1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if state == move:
		touch_input()

func find_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var current_hanzi = all_pieces[i][j].get_hanzi()
				if i > 0 && i < width - 1:
					if all_pieces[i - 1][j] != null && all_pieces[i + 1][j] != null:
						if all_pieces[i - 1][j].get_hanzi() == current_hanzi && all_pieces[i + 1][j].get_hanzi() == current_hanzi:
							all_pieces[i - 1][j].matched = true
							all_pieces[i - 1][j].dim()
							all_pieces[i][j].matched = true
							all_pieces[i][j].dim()
							all_pieces[i + 1][j].matched = true
							all_pieces[i + 1][j].dim()
				if j > 0 && j < height - 1:
					if all_pieces[i][j - 1] != null && all_pieces[i][j + 1] != null:
						if all_pieces[i][j - 1].get_hanzi() == current_hanzi && all_pieces[i][j + 1].get_hanzi() == current_hanzi:
							all_pieces[i][j - 1].matched = true
							all_pieces[i][j - 1].dim()
							all_pieces[i][j].matched = true
							all_pieces[i][j].dim()
							all_pieces[i][j + 1].matched = true
							all_pieces[i][j + 1].dim()
	$"DestroyTimer".start()

func destroy_matched():
	var was_matched = false
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					was_matched = true
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null
	move_checked = true
	if was_matched:
		$CollapseTimer.start()
	else:
		swap_back()

func collapse_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				for k in range(j + 1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i, j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break
	$RefillTimer.start()

func refill_column():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null:
				var rand = floor(rand_range(0, 6))
				var loop = 0
				while(match_at(i, j, charac[rand][0]) && loop < 100):
					rand = floor(rand_range(0, 6))
					loop += 1
				var new_piece = possible_pieces[charac[rand][1]].instance()
				add_child(new_piece)
				new_piece.position = grid_to_pixel(i, j + y_offset)
				new_piece.set_hanzi(charac[rand][0])
				all_pieces[i][j] = new_piece
				new_piece.move(grid_to_pixel(i, j))
		after_refill()

func after_refill():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if match_at(i, j, all_pieces[i][j].get_hanzi()):
					find_matches()
					$DestroyTimer.start()
					return
	state = move
	move_checked = false

func _on_DestroyTimer_timeout():
	destroy_matched()

func _on_CollapseTimer_timeout():
	collapse_columns()

func _on_RefillTimer_timeout():
	refill_column()
