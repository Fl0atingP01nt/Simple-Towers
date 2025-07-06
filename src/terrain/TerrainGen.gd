extends GridMap
class_name TerrainGen

@export_category('Terrain Size')
@export var x_radius:int = 16;
@export var y_radius:int = 1;
@export var z_radius:int = 16;

@export_category('Noise Settings')
@export var init_seed:int; ##initial seed that doesn't even get used lmao
@export var noise_type:FastNoiseLite.NoiseType = FastNoiseLite.TYPE_PERLIN; ##noise type with perlin as default. Due to the lack of brainpower, fractal and cellular generation does not work
@export var freqency:float = 0.001; ##how often blobs appear
@export var threshold:float = 0; ##the required value of the noise before it generates
@export var block_id:TerrainBlockType; 

@export_category('Fill Settings')
@export var fill:bool = false;
@export var fill_block_id:TerrainBlockType;

@export_category('Path Settings')
@export var path:bool;
@export var path_block:TerrainBlockType = TerrainBlockType.PATH;
@export var spawn_point:TerrainBlockType = TerrainBlockType.SPAWN;
@export var end_point:TerrainBlockType = TerrainBlockType.END;
@export var padding:int = 5;
@export var path_width:int = 30;

var _debug_mesh_lib:MeshLibrary = load("res://assets/debug/debug_mesh_library.tres");

var _terrain_noise:FastNoiseLite = FastNoiseLite.new();
var _point:Vector3i = Vector3i(0, y_radius - 1, (z_radius * 2) - padding);
var _start_location:Vector3i;
var _end_location:Vector3i;

enum TerrainBlockType{ 
	STONE,
	GRASS,
	PATH,
	SPAWN,
	END
}; #TIL about enums 7-5-25

func clear_blocks(length:int, height:int, width:int) -> void:
	for x in range(-length, length):
		for y in range(-height, height):
			for z in range(-width, width):
				set_cell_item(Vector3i(x, y, z), -1);

func fill_blocks(length:int, height:int, width:int, block_id:int) -> void: #I honestly don't know the use case for this since the generate() has autofill implemented
	for x in range(-length, length):
		for y in range(-height, height):
			for z in range(-width, width):
				set_cell_item(Vector3i(x, y, z), block_id);

func get_path_end() -> Vector3:
	var pos = map_to_local(_end_location)
	return pos;

func get_path_start() -> Vector3:
	var pos = map_to_local(_start_location);
	return pos;

func _generate_path(point:Vector3i, path:TerrainBlockType, start:TerrainBlockType, end:TerrainBlockType) -> void:
	var cur_len:int;
	var max_len:int = (z_radius * 2) - (padding * 2);
	
	var dir:Array = [0, 1, 2]; #1 = left; 2 = right; 0 = go down;
	
	var cur_dir:int;
	var prev_dir:int;
	var turn_dist:int;
	
	var l_padding:int = -path_width/2;
	var r_padding:int = path_width/2;
	
	set_cell_item(point, start);
	_start_location = point;
	while cur_len <= max_len:
		var h_len:int = randi_range(2, 3);
		cur_dir = dir.pick_random();
		#print(prev_dir, ' ', cur_dir); for debug only DO NOT UNCOMMENT AGAIN
		if cur_dir and prev_dir == cur_dir: #I wonder how I wonder why but if it works it works (.-.)
			match cur_dir:
				1: 
					for h in range(h_len):
						if point.x > l_padding:
							point.x -= 1;
							set_cell_item(point, path);
				2: 
					for h in range(h_len):
						if point.x < r_padding:
							point.x += 1;
							set_cell_item(point, path);
		else: 
			for h in range(h_len):
				point.z -= 1;
				cur_len += 1;
				set_cell_item(point, path);
				if cur_len > max_len:
					break;
		prev_dir = cur_dir
	set_cell_item(point, end);
	_end_location = point;

func generate(length:int, height:int, width:int, block_id:int, threshold:float, new_seed:int, fill:bool = false, fill_block_id:int = -1) -> void:
	_terrain_noise.seed = new_seed;
	for x in range(-length, length):
		for y in range(-height, height):
			for z in range(-width, width):
				if _terrain_noise.get_noise_2d(x, z) > threshold:
					set_cell_item(Vector3i(x,y,z), block_id);
				elif fill: set_cell_item(Vector3i(x,y,z), fill_block_id); #funny nesting
	if path:
		_generate_path(_point, path_block, spawn_point, end_point);

func _ready() -> void:
	_terrain_noise.noise_type = noise_type;
	_terrain_noise.frequency = freqency;
	_terrain_noise.seed = init_seed;
	
	if mesh_library == null:
		mesh_library = _debug_mesh_lib;
	
	generate(x_radius, y_radius, z_radius, block_id, 0, randi(), fill, fill_block_id);

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		clear_blocks(x_radius,y_radius,z_radius);

	if Input.is_action_just_pressed("ui_accept"):
		clear_blocks(x_radius,y_radius,z_radius);
		generate(x_radius, y_radius, z_radius, block_id, 0, randi(), fill, fill_block_id);
	
