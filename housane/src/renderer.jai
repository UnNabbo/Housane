Buffer_Push_Constants :: struct {
	world:   Mat4 = Matrix4_Identity;
	address: Buffer_Device_Address;
};

Vertex :: struct{
	position: Vec3;
	uv_x: f32;
	normal: Vec3;
	uv_y: f32;
	color: Vec4; //TODO: make color4
}

Scene :: struct {
	data: Scene_Data;
	//descriptor_layout: Descriptor_Set_Layout;
	set: Descriptor_Set;
	buffer: Allocated_Buffer;
}

Scene_Data :: struct {
    view: Mat4;
    projection: Mat4;
    view_projection: Mat4;
    ambient_color: Vec4;
    sunlight_direction: Vec4; // w for sun power
    sunlight_color: Vec4;
};


allocate_mesh_on_gpu :: (vertices: *Vertex, vertices_count: s64, indices: *u32, indices_count: s64) -> Mesh_Buffer{
	using,except(mesh) render_data;
	
	raw_vertices_size := vertices_count * size_of(Vertex);
	raw_indices_size  := indices_count * size_of(u32);

	mesh: Mesh_Buffer;
	mesh.vertex = allocate_gpu_buffer(*allocator, raw_vertices_size, .STORAGE | .TRANSFER_DST | .SHADER_DEVICE_ADDRESS,.GPU_ONLY);
	mesh.index  = allocate_gpu_buffer(*allocator, raw_indices_size, .INDEX | .TRANSFER_DST,.GPU_ONLY);
	mesh.address = get_buffer_device_address(mesh.vertex);

	staging := allocate_gpu_buffer(*allocator, raw_indices_size + raw_vertices_size, .TRANSFER_SRC, .CPU_ONLY);
	data := staging.info.pMappedData;
	memcpy(data, vertices, raw_vertices_size);
	memcpy(data + raw_vertices_size, indices, raw_indices_size);

	command_buffer := immediate_command_recording_begin();
	memcpy_command(command_buffer, staging, mesh.vertex, raw_vertices_size);
	memcpy_command(command_buffer, staging, mesh.index, raw_indices_size, raw_vertices_size);
	immediate_command_recording_end();

	deallocate_gpu_buffer(*staging);
	return mesh;
}

allocate_texture_image :: (allocator: *Vulkan_Memory_Allocator, width: s32, height: s32, channels: s32, data: * void, image_usage: Image_Usage = .SAMPLED, image_format: Image_Format = .R8G8B8A8_UNORM) -> Image {

	size := width * height * channels;
	staging := allocate_gpu_buffer(allocator, size, .TRANSFER_SRC, .CPU_TO_GPU);
	memcpy(staging.info.pMappedData, data, size);

	image := allocate_image(allocator, width, height, image_usage | .TRANSFER_DST | .TRANSFER_SRC, image_format);
	
	command_buffer := immediate_command_recording_begin();
	transition_image_layout_command(command_buffer, *image, .TRANSFER_DST_OPTIMAL);
	memcpy_command(command_buffer, staging, image);
	transition_image_layout_command(command_buffer, *image, .SHADER_READ_ONLY_OPTIMAL);
	immediate_command_recording_end();

	deallocate_gpu_buffer(*staging);
	return image;
}

allocate_mesh_on_gpu :: (vertices: []Vertex, indices: []u32) -> Mesh_Buffer{
	using,except(mesh) render_data;
	
	raw_vertices_size := vertices.count * size_of(Vertex);
	raw_indices_size  := indices.count * size_of(u32);

	mesh: Mesh_Buffer;
	mesh.vertex = allocate_gpu_buffer(*allocator, raw_vertices_size, .STORAGE | .TRANSFER_DST | .SHADER_DEVICE_ADDRESS,.GPU_ONLY);
	mesh.index  = allocate_gpu_buffer(*allocator, raw_indices_size, .INDEX | .TRANSFER_DST,.GPU_ONLY);
	mesh.address = get_buffer_device_address(mesh.vertex);

	staging := allocate_gpu_buffer(*allocator, raw_indices_size + raw_vertices_size, .TRANSFER_SRC, .CPU_ONLY);
	data := staging.info.pMappedData;
	memcpy(data, vertices.data, raw_vertices_size);
	memcpy(data + raw_vertices_size, indices.data, raw_indices_size);

	command_buffer := immediate_command_recording_begin();
	memcpy_command(command_buffer, staging, mesh.vertex, raw_vertices_size);
	memcpy_command(command_buffer, staging, mesh.index, raw_indices_size, raw_vertices_size);
	immediate_command_recording_end();

	deallocate_gpu_buffer(*staging);
	return mesh;
}

immediate_command_recording_begin :: () -> Command_Buffer{
	using render_data;
	
	reset_fence(immediate_fence);
	begin_command_recording(immediate_buffer);
	return immediate_buffer;
}

immediate_command_recording_end :: () {
	using render_data;

	end_command_recording(immediate_buffer);
	submit_command_buffer(immediate_buffer, device.queues[Device_Queue.GRAPHIC_PRESENT], *immediate_fence);
	wait_fence(immediate_fence);
}

render_resize ::(width: s32, height: s32){
	using render_data;
	
	if swapchain.handle != NULL_HANDLE{
		destroy_swapchain(*swapchain);
		swapchain = create_swapchain(*device, *instance.surface, .MAILBOX, width, height);
	}
	
	render_next_frame();
}

render_init :: (window: *Window){
	using,except(window) render_data;
	render_data.window = window;
	
	instance = create_instance(window.handle); 
	device = create_device(*instance.physical_device);
    swapchain = create_swapchain(*device, *instance.surface, .MAILBOX, window.width, window.height);
	
	for * frames {
		it.buffer = create_command_buffer(*device, .GRAPHIC_PRESENT, *deletion_queue);
		it.fence = create_fence(*device, true, *deletion_queue);
		it.swapchain_semaphore = create_semaphore(*device, *deletion_queue);
		it.render_semaphore = create_semaphore(*device, *deletion_queue);
		it.descriptor_allocator = create_descriptor_allocator(*device,
															  .{ .STORAGE_IMAGE, 3 },
															  .{ .STORAGE_BUFFER, 3 },
															  .{ .UNIFORM_BUFFER, 3 },
															  .{ .COMBINED_IMAGE_SAMPLER, 4 }
		);

	}
	allocator = create_vulkan_memory_allocator(instance, *device);
	descriptor_allocator = create_descriptor_allocator(*device, .{.STORAGE_IMAGE, 1});
	
	immediate_buffer = create_command_buffer(*device, .GRAPHIC_PRESENT, *deletion_queue);
	immediate_fence = create_fence(*device, true, *deletion_queue);

	backbuffer = allocate_image(*allocator, IMAGE_DEFAULT_WIDTH, IMAGE_DEFAULT_HEIGHT, .TRANSFER_SRC | .TRANSFER_DST | .STORAGE | .COLOR_ATTACHMENT);
	depth_buffer = allocate_image(*allocator, IMAGE_DEFAULT_WIDTH, IMAGE_DEFAULT_HEIGHT, .DEPTH_STENCIL_ATTACHMENT, .D32_SFLOAT);

	pipeline_info:  Pipeline_Info;
	pipeline_info.color_attachment_format = backbuffer.format;
	pipeline_info.depth_attachment_format = depth_buffer.format;
	vertex_shader_module := create_shader_module(device, .VERTEX, "housane/res/shader_vertex.sprv", Buffer_Push_Constants);
	defer destroy_shader_module(device, vertex_shader_module);
	fragment_shader_module := create_shader_module(device, .FRAGMENT, "housane/res/shader_frag.sprv");
	defer destroy_shader_module(device, fragment_shader_module);


	texture_descriptor_layout := create_descriptor_set_layout(device, .FRAGMENT, .{.COMBINED_IMAGE_SAMPLER, 0});
	texture_descriptor_set = allocate_descriptor_set(*descriptor_allocator, texture_descriptor_layout);
		
	shader := create_shader(.[vertex_shader_module, fragment_shader_module], .[texture_descriptor_layout]);
	pipeline = create_pipeline(*device, pipeline_info, *shader);
	
	write_queue = create_descriptor_write_queue(*device);
	
	scene_descriptor_layout := create_descriptor_set_layout(device, .VERTEX | .FRAGMENT, .{.UNIFORM_BUFFER,0 });
	scene.set = allocate_descriptor_set(*descriptor_allocator, scene_descriptor_layout);
	scene.buffer = allocate_gpu_buffer(*allocator, size_of(Scene_Data), .UNIFORM, .CPU_TO_GPU);
	
	arena := arena_alloc();
	//monkey := load_gltf_file(arena, "housane/res/models/monkey.glb")[0].buffer;
	
	mesh = load_gltf_file(arena, "housane/res/models/monkey.glb")[0];//TODO: destroy
	//mesh.buffer = allocate_mesh_on_gpu(vertices, indices);
	//mesh.indices_count = 6;
	texture_data : [16][16][4]u8;
	for y: 0..15{
		for x: 0..15{
			d : u8 = xx ((x % 2) ^ (y % 2));
			texture_data[y][x] = .[255 * d, 255 * d, 255 * d, 255];
		}
	}
	
	sampler = create_sampler(*device);
	texture = allocate_texture_image(*allocator, 16, 16, 4, texture_data.data);
	write_descriptor(*write_queue, texture, .COMBINED_IMAGE_SAMPLER, 0, sampler);
	flush_descriptor_write_queue(*write_queue, texture_descriptor_set, true);
}

render_deinit :: (){
	using render_data;
	
	for 0..Frame_Data.OVERLAP - 1 {
		Deletion_Queue.flush(*frames[it].deletion_queue);
	}

	Deletion_Queue.flush(*deletion_queue);

	deallocate_gpu_buffer(*scene.buffer);
}

render_next_frame :: (){
	using render_data;
	frame := *frames[frame_count % Frame_Data.OVERLAP];
	defer frame_count += 1;

	wait_and_reset_fence(frame.fence);
	Deletion_Queue.flush(*frame.deletion_queue);
	clear_descriptor_allocator(*frame.descriptor_allocator);
	image, index, should_resize := acquire_image_from_swapchain(swapchain, frame.swapchain_semaphore);
	begin_command_recording(frame.buffer);

	draw_width, draw_height : u32 = xx window.width, xx  window.height;
		
	transition_image_layout_command(frame.buffer, *backbuffer, .GENERAL);
	clear_image_command(frame.buffer, backbuffer, .{0, 0, 255, 255});

	transition_image_layout_command(frame.buffer, *backbuffer, .COLOR_ATTACHMENT_OPTIMAL);
	transition_image_layout_command(frame.buffer, *depth_buffer, .DEPTH_ATTACHMENT_OPTIMAL);
	
	begin_rendering_command(frame.buffer, *backbuffer, *depth_buffer);
	bind_pipeline_command(frame.buffer, pipeline);
	set_viewport_command(frame.buffer, 0, 0, draw_width, draw_height);
	set_scissor_command(frame.buffer, 0, 0, draw_width, draw_height);


	bind_descriptor_set(frame.buffer, pipeline, texture_descriptor_set);
	
	memcpy(scene.buffer.info.pMappedData, *scene.data, size_of(Scene_Data));
	write_descriptor(*write_queue, scene.buffer, .UNIFORM_BUFFER, 0, size_of(Scene_Data));
	flush_descriptor_write_queue(*write_queue, scene.set, true);

	
	constants: Buffer_Push_Constants;
	constants.address = mesh.buffer.address;
	projection :=  make_projection_matrix(90.0 * PI / 180.0, cast(f32, draw_width) / cast(f32, draw_height),  10000, 0.1, depth_range_01 = true);
	projection._22 *= -1;
	constants.world =    projection * make_translation_matrix4(.{0, 0, -5});
	push_constants_command(frame.buffer, pipeline, .VERTEX, *constants);
	bind_index_buffer_command(frame.buffer, mesh.buffer.index);
	draw_indexed_command(frame.buffer, xx mesh.indices_count);
	end_rendering_command(frame.buffer);

	blit_image_command(frame.buffer, *backbuffer, .{draw_width, draw_height}, image, .{image.width, image.height});
	transition_image_layout_command(frame.buffer, image, .PRESENT_SRC);

	end_command_recording(frame.buffer);
	submit_command_buffer(frame.buffer, device.queues[Device_Queue.GRAPHIC_PRESENT], *frame.fence, *frame.swapchain_semaphore, *frame.render_semaphore);
	
	present_queue_to_swapchain(swapchain, index, *frame.render_semaphore);
}


#scope_file

render_data: Render_Data;

Render_Data :: struct{
	IMAGE_DEFAULT_WIDTH, IMAGE_DEFAULT_HEIGHT :: 2560, 1440;
	
	window: *Window;
	
	instance: Instance;
	device: Device;
	swapchain: Swapchain;

	frame_count := 0;

	allocator: Vulkan_Memory_Allocator;
	descriptor_allocator: Descriptor_Allocator;
	
	backbuffer: Image; 
	depth_buffer: Image; 

	pipeline: Pipeline;

	immediate_fence: Fence;
	immediate_buffer: Command_Buffer; 

	mesh: Mesh;
	scene: Scene;
	
	texture: Image;
	sampler: Sampler;
	texture_descriptor_set: Descriptor_Set;
	
	write_queue: Descriptor_Write_Queue;
	
	frames : [Frame_Data.OVERLAP]Frame_Data;
	deletion_queue: Deletion_Queue;
}

Frame_Data :: struct {
	OVERLAP :: 2;
	
	swapchain_semaphore, render_semaphore: Semaphore;
	fence: Fence;
	buffer: Command_Buffer; 

	
	deletion_queue: Deletion_Queue;
	descriptor_allocator: Descriptor_Allocator;
}
