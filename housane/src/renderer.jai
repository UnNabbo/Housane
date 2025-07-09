Compute_Push_Constants :: struct {
	data1: Vector4;
	data2: Vector4;
	data3: Vector4;
	data4: Vector4;
};

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

	allocator = create_vulkan_memory_allocator(*instance, *device, *deletion_queue);

	descriptor_allocator = create_descriptor_allocator(*device, *deletion_queue, 16, .{.STORAGE_IMAGE, 1});
	
	backbuffer.handle = create_image(*allocator, window.width, window.height, .TRANSFER_SRC_BIT | .TRANSFER_DST_BIT | .STORAGE_BIT | .COLOR_ATTACHMENT_BIT, deletion_queue = *deletion_queue);

	backbuffer.descriptor_set = create_descriptor_set(*descriptor_allocator, .COMPUTE, .{.STORAGE_IMAGE, 0});
	update_descriptor_set_image(*device, *backbuffer.descriptor_set, *backbuffer.handle);
	
	backbuffer_shader_module0 := create_shader_module(*device, .COMPUTE, "housane/res/gradient_comp.sprv", Compute_Push_Constants);
	backbuffer_shader := create_shader(backbuffer_shader_module0);
	backbuffer.pipeline = create_compute_pipeline(*device, backbuffer_shader, backbuffer.descriptor_set);
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

	image, index := acquire_image_from_swapchain(*swapchain, frame.swapchain_semaphore);
	begin_command_recording(*frame.buffer);

	transition_image_layout_command(*frame.buffer, *backbuffer, .GENERAL);

	clear_image_command(*frame.buffer, backbuffer, .{0, 0, 255, 255});

	bind_pipeline_command(*frame.buffer, .COMPUTE, *backbuffer.pipeline, backbuffer.descriptor_set);

	pc: Compute_Push_Constants;
	pc.data1 = .{1, 1, 0, 1};
	pc.data2 = .{0, 0, 1, 1};
	
	push_constants_command(*frame.buffer, *backbuffer.pipeline, .COMPUTE, *pc);
	
	dispatch_compute_command(*frame.buffer, xx ceil(800.0 / 16.0), xx ceil(600.0 / 16.0));
	
	blit_image_command(*frame.buffer, *backbuffer, image);
	
	transition_image_layout_command(*frame.buffer, image, .PRESENT_SRC);

	end_command_recording(*frame.buffer);
	
	submit_command_buffer(*frame.buffer, device.queues[Device_Queue.GRAPHIC_PRESENT], *frame.fence, *frame.swapchain_semaphore, *frame.render_semaphore);
	
	present_queue_to_swapchain(*swapchain, index, *frame.render_semaphore);
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

	
	Backbuffer :: struct{
		#as handle: Image;
		descriptor_set: Descriptor_Set;
		pipeline: Pipeline;
	}
	backbuffer: Backbuffer; 
	
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


