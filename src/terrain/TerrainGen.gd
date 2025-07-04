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
@export var block_id:int; 

@export_category('Fill Settings')
@export var fill:bool = false;
@export var fill_block_id:int;

var _debug_mesh_lib:MeshLibrary = load("res://assets/debug/debug_mesh_library.tres");

var terrain_noise:FastNoiseLite = FastNoiseLite.new();

func clear_blocks(length:int, height:int, width:int):
	for x in range(-length, length):
		for y in range(-height, height):
			for z in range(-width, width):
				set_cell_item(Vector3i(x, y, z), -1);

func fill_blocks(length:int, width:int, height:int, block_id:int): #I honestly don't know the use case for this since the generate_blocks() has autofill implemented
	for x in range(-length, length):
		for y in range(-height, height):
			for z in range(-width, width):
				set_cell_item(Vector3i(x, y, z), block_id);

func generate_blocks(length:int, height:int, width:int, block_id:int, threshold:float, new_seed:int, fill:bool = false, fill_block_id:int = -1):
	terrain_noise.seed = new_seed;
	for x in range(-length, length):
		for y in range(-height, height):
			for z in range(-width, width):
				if terrain_noise.get_noise_2d(x, z) > threshold:
					set_cell_item(Vector3i(x,y,z), block_id);
				else: if fill: set_cell_item(Vector3i(x,y,z), fill_block_id); #funny nesting

func _ready() -> void:
	terrain_noise.noise_type = noise_type;
	terrain_noise.frequency = freqency;
	terrain_noise.seed = init_seed;
	
	if mesh_library == null:
		mesh_library = _debug_mesh_lib;
	
	generate_blocks(x_radius, y_radius, z_radius, block_id, 0, randi(), fill, fill_block_id);

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		clear_blocks(x_radius,y_radius,z_radius);

	if Input.is_action_just_pressed("ui_accept"):
		generate_blocks(x_radius, y_radius, z_radius, block_id, 0, randi(), fill, fill_block_id);
