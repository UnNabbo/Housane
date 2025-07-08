render_init :: (window: *Window){
	using context.render_data;
	
	instance = create_instance(window.handle, window.width, window.height); 
	device = create_device(*instance.physical_device);
    swap_chain = create_swapchain(*device, *instance.surface);
	
	for 0..Frame_Data.OVERLAP - 1 {
		frames[it].buffer = create_command_buffer(*device, .GRAPHIC_PRESENT);
		frames[it].fence = create_fence(*device, true);
		frames[it].swapchain_semaphore = create_semaphore(*device);
		frames[it].render_semaphore = create_semaphore(*device);
	}
}

render_next_frame :: (){
	using context.render_data;
	frame := *frames[frame_count % Frame_Data.OVERLAP];
	frame_count += 1;
	
	
}

#scope_file

#add_context render_data: Render_Data;

Render_Data :: struct{
	instance: Instance;
	device: Device;
	swap_chain: Swap_Chain;

	frame_count := 0;
	frames : [Frame_Data.OVERLAP]Frame_Data;
}

Frame_Data :: struct {
	swapchain_semaphore, render_semaphore: Semaphore;
	fence: Fence;
	buffer: Command_Buffer; 
	
	OVERLAP :: 2; 
}


