Buffer_Push_Constants :: struct {
	world:   Mat4;
	address: Buffer_Device_Address;
};

Mesh_Buffer :: struct{
	address: Buffer_Device_Address;
	vertex:  Allocated_Buffer;
	index:   Allocated_Buffer;
}

Vertex :: struct{
	position: Vec3;
	uv_x: f32;
	normal: Vec3;
	uv_y: f32;
	color: Vec4; //TODO: make color4
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


create_mesh :: (vertices: []Vertex, indices: []u32) -> Mesh_Buffer{
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

render_init :: (window: *Window){
	using render_data;
	
	instance = create_instance(window.handle, window.width, window.height); 
	device = create_device(*instance.physical_device);
    swapchain = create_swapchain(*device, *instance.surface);
	
	for 0..Frame_Data.OVERLAP - 1 {
		frames[it].buffer = create_command_buffer(*device, .GRAPHIC_PRESENT, *deletion_queue);
		frames[it].fence = create_fence(*device, true, *deletion_queue);
		frames[it].swapchain_semaphore = create_semaphore(*device, *deletion_queue);
		frames[it].render_semaphore = create_semaphore(*device, *deletion_queue);
	}
	allocator = create_vulkan_memory_allocator(instance, *device, *deletion_queue);
	descriptor_allocator = create_descriptor_allocator(*device, *deletion_queue, 16, .{.STORAGE_IMAGE, 1});
	
	immediate_buffer = create_command_buffer(*device, .GRAPHIC_PRESENT, *deletion_queue);
	immediate_fence = create_fence(*device, true, *deletion_queue);

	backbuffer = allocate_image(*allocator, window.width, window.height, .TRANSFER_SRC_BIT | .TRANSFER_DST_BIT | .STORAGE_BIT | .COLOR_ATTACHMENT_BIT);

	pipeline_info:  Pipeline_Info;
	pipeline_info.color_attachment_format = backbuffer.format;
	vertex_shader_module := create_shader_module(device, .VERTEX, "housane/res/shader_vertex.sprv", Buffer_Push_Constants);
	defer destroy_shader_module(device, vertex_shader_module);
	fragment_shader_module := create_shader_module(device, .FRAGMENT, "housane/res/shader_frag.sprv");
	defer destroy_shader_module(device, fragment_shader_module);
	shader := create_shader(.[vertex_shader_module, fragment_shader_module], .[]);
	pipeline = create_pipeline(*device, pipeline_info, *shader);

	vertices: [4]Vertex;
	vertices[0].position = .{ 0.5, -0.5, 0};
	vertices[1].position = .{ 0.5,  0.5, 0};
	vertices[2].position = .{-0.5, -0.5, 0};
	vertices[3].position = .{-0.5,  0.5, 0};
	
	vertices[0].color = .{0,  0, 0, 1};
	vertices[1].color = .{0.5,  0.5, 0.5, 1};
	vertices[2].color = .{1,  0, 0, 1};
	vertices[3].color = .{0, 1, 0, 1};

	indices: []u32 = .[0, 1, 2, 2, 1, 3];
	
	mesh = create_mesh(vertices, indices);//TODO: destroy
}

render_deinit :: (){
	using render_data;
	
	for 0..Frame_Data.OVERLAP - 1 {
		Deletion_Queue.flush(*frames[it].deletion_queue);
	}

	Deletion_Queue.flush(*deletion_queue);
}

render_next_frame :: (){
	using render_data;
	frame := *frames[frame_count % Frame_Data.OVERLAP];
	defer frame_count += 1;

	wait_fence(frame.fence);
	Deletion_Queue.flush(*frame.deletion_queue);
	image, index := acquire_image_from_swapchain(swapchain, frame.swapchain_semaphore);

	begin_command_recording(frame.buffer);

	transition_image_layout_command(frame.buffer, *backbuffer, .GENERAL);
	clear_image_command(frame.buffer, backbuffer, .{0, 0, 255, 255});

	transition_image_layout_command(frame.buffer, *backbuffer, .COLOR_ATTACHMENT_OPTIMAL);
	begin_rendering_command(frame.buffer, *backbuffer);
	bind_pipeline_command(frame.buffer, pipeline);
	set_viewport_command(frame.buffer, 0, 0, xx backbuffer.width, xx backbuffer.height);
	set_scissor_command(frame.buffer, 0, 0, backbuffer.width, backbuffer.height);
	constants: Buffer_Push_Constants;
	constants.address = mesh.address;
	identity(*constants.world);
	push_constants_command(frame.buffer, pipeline, .VERTEX, *constants);
	bind_index_buffer_command(frame.buffer, mesh.index);
	draw_indexed_command(frame.buffer, 6);
	end_rendering_command(frame.buffer);

	blit_image_command(frame.buffer, *backbuffer, image);
	transition_image_layout_command(frame.buffer, image, .PRESENT_SRC);

	end_command_recording(frame.buffer);
	submit_command_buffer(frame.buffer, device.queues[Device_Queue.GRAPHIC_PRESENT], *frame.fence, *frame.swapchain_semaphore, *frame.render_semaphore);
	
	present_queue_to_swapchain(swapchain, index, *frame.render_semaphore);
}


#scope_file

render_data: Render_Data;

Render_Data :: struct{
	instance: Instance;
	device: Device;
	swapchain: Swapchain;

	frame_count := 0;

	allocator: Vulkan_Memory_Allocator;
	descriptor_allocator: Descriptor_Allocator;
	
	backbuffer: Image; 

	pipeline: Pipeline;

	immediate_fence: Fence;
	immediate_buffer: Command_Buffer; 

	mesh: Mesh_Buffer;
	
	frames : [Frame_Data.OVERLAP]Frame_Data;
	deletion_queue: Deletion_Queue;
}

Frame_Data :: struct {
	swapchain_semaphore, render_semaphore: Semaphore;
	fence: Fence;
	buffer: Command_Buffer; 

	deletion_queue: Deletion_Queue;
	OVERLAP :: 2; 
}
