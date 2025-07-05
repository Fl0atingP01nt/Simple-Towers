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
@export var path_length:int = 640;

var _debug_mesh_lib:MeshLibrary = load("res://assets/debug/debug_mesh_library.tres");

var terrain_noise:FastNoiseLite = FastNoiseLite.new();

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

func _generate_path() -> void:
	var point:Vector3i = Vector3i(-x_radius + 5, y_radius - 1, -z_radius + 5);
	var dir:Array = [0,1,2,3]; #left/up/right/down
	var dist:int;
	var cur_len:int; #current length
	
	var prev_point:Vector3i; #previous point
	var cur_dir:int = dir.pick_random(); #current direction
	
	set_cell_item(point, TerrainBlockType.SPAWN);
	while cur_len < path_length:
		for x in range(point.x - 1, point.x + 1):
			for z in range(point.z - 1, point.z + 1):
				cur_dir = dir.pick_random();
				if prev_point != point:
					prev_point = point;
					match cur_dir:
						0: point.z -= 1
						1: point.x += 1
						2: point.z += 1
						3: point.x -= 1
					if point.x in range(-x_radius + 5, x_radius - 5) and point.z in range(-z_radius + 5, z_radius - 5):
						set_cell_item(point, path_block);
						print(cur_dir, ' ', prev_point, ' ', point);
						cur_len += 1;

func generate(length:int, height:int, width:int, block_id:int, threshold:float, new_seed:int, fill:bool = false, fill_block_id:int = -1) -> void:
	terrain_noise.seed = new_seed;
	for x in range(-length, length):
		for y in range(-height, height):
			for z in range(-width, width):
				if terrain_noise.get_noise_2d(x, z) > threshold:
					set_cell_item(Vector3i(x,y,z), block_id);
				else: if fill: set_cell_item(Vector3i(x,y,z), fill_block_id); #funny nesting
	if path:
		_generate_path();

func _ready() -> void:
	terrain_noise.noise_type = noise_type;
	terrain_noise.frequency = freqency;
	terrain_noise.seed = init_seed;
	
	if mesh_library == null:
		mesh_library = _debug_mesh_lib;
	
	generate(x_radius, y_radius, z_radius, block_id, 0, randi(), fill, fill_block_id);

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		clear_blocks(x_radius,y_radius,z_radius);

	if Input.is_action_just_pressed("ui_accept"):
		clear_blocks(x_radius,y_radius,z_radius);
		generate(x_radius, y_radius, z_radius, block_id, 0, randi(), fill, fill_block_id);
	
