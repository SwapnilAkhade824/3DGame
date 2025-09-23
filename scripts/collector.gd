extends Node
class_name collector

@onready var generator = $"../DungeonGenerator3D"
@onready var game = $".."
var control = controls.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


var region
func _player_activity(game_node, entrance_room: DungeonRoom3D, living_rooms: Array[DungeonRoom3D]):
	#print(entrance_room,living_rooms)
	# connections of the region
	# exit region in the entrance room 
	region = entrance_room.get_node("exit_region")
	region.connect("body_entered", game_node.player_exit)
	region.connect("body_exited", game_node.player_exited_region)
	# key region in the living room
	var key_regions : Array[Area3D]
	for room in living_rooms:
		var elements = room.get_node("Models/Decorations/Table")
		for element in elements.get_children():
			if element.name.begins_with("Key"):
				key_regions.append(element.get_node("key_pick"))
	for space in key_regions:
		space.body_entered.connect(func(body):
			game_node.player_collecting_key(space,body)
		)
		space.body_exited.connect(func(body):
			game_node.player_picked_key(space,body)
		)
	
