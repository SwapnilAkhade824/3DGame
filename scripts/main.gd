extends Node3D
class_name game

var player_scene = preload("res://characters/player.tscn")
var enemy_scene = preload("res://characters/enemy.tscn")

@onready var control = controls.new()
@onready var collect = collector.new()
@onready var _enemy = enemy_control.new()
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
	#map.connect("done_generating",_access_the_rooms)
	

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
	
# function for player death
func player_dead(body: Node3D):
	if body.is_in_group("player"):
		var uis = get_node("controls")
		uis.end_game("lost")
	
# function for enemy spawning & despawning
func spawn_enemies(region: Node3D, body: Node3D):
	if body.is_in_group("player"):
		# getting the spawn points 
		var enemies: Array[CharacterBody3D] 
		var spawn_points: Array[Node3D]
		var room = region.get_parent_node_3d()
		for node in room.get_children():
			if node.is_in_group("enemy_spawn_point"):
				spawn_points.append(node)
		
		# initiating the enemies
		while len(enemies) < len(spawn_points):
			enemies.append(enemy_scene.instantiate())
		
		# passing the enemy array
		_enemy.player_death_region($".", enemies)
		
		# spawning enemies
		for i in range(len(spawn_points)):
			if spawn_points[i].get_children() == []:
				spawn_points[i].add_child(enemies[i])
		
	
func despawn_enemies(region: Node3D, body: Node3D):
	var spawn_points: Array[Node3D]
	var room = region.get_parent_node_3d()
	for nodes in room.get_children():
		if nodes.is_in_group("enemy_spawn_point"):
			spawn_points.append(nodes)
	if body.is_in_group("player"):
		for spawn_point in spawn_points:
			spawn_point.get_child(0).queue_free()

func generate_new_map():
	print(AutoLoad.Seed)
	$DungeonGenerator3D.generate(AutoLoad.Seed)

func player_exit(body: Node3D):
	if body.is_in_group("player"):
		if keys_collected >= 2:
			var uis = get_node("controls")
			uis.end_game("won")
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
	_enemy.work_with_enemies($".",living_rooms)
