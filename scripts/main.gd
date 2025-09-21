extends Node3D
class_name game

var player_scene = preload("res://characters/player.tscn")

@onready var control = controls.new()
@onready var collect = collector.new()
@onready var map = $DungeonGenerator3D

# rooms
var entrance_room: DungeonRoom3D
var living_rooms: Array[DungeonRoom3D]

# Elements to collect
var keys_collected = 0

# message
var message = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Main ready working")
	map.connect("done_generating",_access_the_rooms)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

var player
func spawn_player():
	if player and is_instance_valid(player): return
	var spawn_points = get_tree().get_nodes_in_group("player_spawn_point")
	if spawn_points.size() == 0: return
	player = player_scene.instantiate()
	spawn_points.pick_random().add_child(player)
	for cam in player.find_children("*", "Camera3D"):
		cam.current = true
	player.call_deferred("grab_focus")
	
func generate_new_map():
	$DungeonGenerator3D.generate(randi())

func player_exit(body: Node3D):
	if body.is_in_group("player"):
		if keys_collected >= 2:
			print("Player Won!")
		else:
			print("find ", 2 - keys_collected, " more")
			message = "find %d more keys" % (2-keys_collected)
			

func player_collecting_key(region: Node3D, body: Node3D):
	if body.is_in_group("player"):
		message = "collected a key +1"
		keys_collected += 1
		var key = region.get_parent_node_3d()
		key.visible = false
		
	
func player_picked_key(region: Node3D, body: Node3D):
	if body.is_in_group("player"):
		message = ""
		region.queue_free()
		
	
func player_exited_region(body: Node3D):
	if body.is_in_group("player"):
		message = ""
	
func _access_the_rooms():
	var rooms = map.get_node("RoomsContainer")
	for room in rooms.get_children():
		if room.name.begins_with("EntranceRoom"):
			entrance_room = room
		if room.name.begins_with("LivingRoom"):
			living_rooms.append(room)
	
	collect._player_activity($".", entrance_room, living_rooms)
