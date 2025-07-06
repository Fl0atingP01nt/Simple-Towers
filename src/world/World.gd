extends Node3D

@onready var generation: TerrainGen = $Generation;
var _unit_folder := "res://src/entity/types/";
var _unit_scenes:Array;

func _dir_contents(path):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				continue;
			else:
				_unit_scenes.append(path + file_name)
			file_name = dir.get_next()

func load_enemy() -> PackedScene:
	_dir_contents(_unit_folder)
	var enemy:PackedScene = load(_unit_scenes.pick_random());
	return enemy;

func spawn(entity:PackedScene, location:Vector3):
	var e = entity.instantiate();

func _ready() -> void:
	_dir_contents(_unit_folder);
	spawn(load_enemy(), generation.local_to_map(generation.get_path_start()));
