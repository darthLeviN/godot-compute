extends Control

var try_count := 0

func _ready() -> void:
	test_compute()


func test_compute() -> void:
	# Create a local rendering device.
	var rd := RenderingServer.create_local_rendering_device()
	# Load GLSL shader
	var shader_file := load("res://shaders/compute/compute_01.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	var shader := rd.shader_create_from_spirv(shader_spirv)
	
	# Prepare our data. We use floats in the shader, so we need 32 bit.
	var input := PackedFloat32Array()
	input.resize(400000000)
	var input_bytes := input.to_byte_array()

	# Create a storage buffer that can hold our float values.
	# Each float has 4 bytes (32 bit) so 10 x 4 = 40 bytes
	var buffer := rd.storage_buffer_create(input_bytes.size(), input_bytes)
	
	# Create a uniform to assign the buffer to the rendering device
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0 # this needs to match the "binding" in our shader file
	uniform.add_id(buffer)
	var uniform_set := rd.uniform_set_create([uniform], shader, 0) # the last parameter (the 0) needs to match the "set" in our shader file
	
	# Create a compute pipeline
	var pipeline := rd.compute_pipeline_create(shader)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, input_bytes.size()/400, 1, 1)
	rd.compute_list_end()
	
	
	# Submit to GPU and wait for sync
	rd.submit()
	
	print("Starting try")
	while(not rd.try_sync()):
		try_count += 1
		await get_tree().process_frame
	
	# There is still a delay even when the fence is set.
	
	# Read back the data from the buffer
	
	# Uncomment with care. buffer_get_data still has a delay.
	#var output_bytes := rd.buffer_get_data(buffer)
	#var output := output_bytes.to_float32_array()
	#print("Input: ", input[0])
	#print("Output: ", output[0])
	
	print("Tries: ", try_count)
