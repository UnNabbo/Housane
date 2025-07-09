Command_Buffer :: struct{
	#as handle: VkCommandBuffer;
	allocator: VkCommandPool;

	device: *Device;
}

create_command_buffer :: (device: *Device, queue_family: Device_Queue, deletion_queue: *Deletion_Queue = null) -> Command_Buffer{
	command_buffer: Command_Buffer;

	command_buffer.device = device;
	
	command_pool_info: VkCommandPoolCreateInfo;
	command_pool_info.flags = .RESET_COMMAND_BUFFER_BIT;
	command_pool_info.queueFamilyIndex = device.physical_device.queue_families[queue_family];

	vk_assert(vkCreateCommandPool(device, *command_pool_info, null, *command_buffer.allocator));
	
	command_buffer_info: VkCommandBufferAllocateInfo;
	command_buffer_info.commandPool = command_buffer.allocator;
	command_buffer_info.commandBufferCount = 1;
	command_buffer_info.level = .PRIMARY;

	vk_assert(vkAllocateCommandBuffers(device, *command_buffer_info, *command_buffer.handle));
	
	Deletion_Queue.push(deletion_queue, command_buffer);
	return command_buffer;
}

destroy_command_buffer :: (buffer: Command_Buffer){
	vkDestroyCommandPool(buffer.device, buffer.allocator, null);
}

begin_command_recording :: (command_buffer: *Command_Buffer, clear: bool = true/*,flags: <type>*/){
	info: VkCommandBufferBeginInfo;
    info.flags = .ONE_TIME_SUBMIT_BIT; // TODO enable other behaviours

	if clear then vk_assert(vkResetCommandBuffer(command_buffer, 0));
	vk_assert(vkBeginCommandBuffer(command_buffer, *info));
}

end_command_recording :: (command_buffer: *Command_Buffer){
	vk_assert(vkEndCommandBuffer(command_buffer));
}

transition_image_layout_command :: (command_buffer: *Command_Buffer, image: *Image, target_layout: Image_Layout){
	if image.layout == target_layout then return;
	
	image_barrier: VkImageMemoryBarrier2;
    image_barrier.srcStageMask = VK_PIPELINE_STAGE_2_ALL_COMMANDS_BIT;
    image_barrier.srcAccessMask = VK_ACCESS_2_MEMORY_WRITE_BIT;
    image_barrier.dstStageMask = VK_PIPELINE_STAGE_2_ALL_COMMANDS_BIT;
    image_barrier.dstAccessMask = VK_ACCESS_2_MEMORY_WRITE_BIT  | VK_ACCESS_2_MEMORY_READ_BIT;
    image_barrier.oldLayout = xx image.layout;
    image_barrier.newLayout = xx target_layout;
	
    aspect_mask:  = ifx cast(u64, target_layout) == cast(u64, VkImageLayout.DEPTH_ATTACHMENT_OPTIMAL) then VkImageAspectFlagBits.DEPTH_BIT else VkImageAspectFlagBits.COLOR_BIT;

	sub_image := create_subresource_range(xx aspect_mask);
	
    image_barrier.subresourceRange = sub_image;
    image_barrier.image = image;

    dep_info: VkDependencyInfo;
    dep_info.imageMemoryBarrierCount = 1;
    dep_info.pImageMemoryBarriers = *image_barrier;

    vkCmdPipelineBarrier2(command_buffer, *dep_info);

	image.layout = target_layout;
}

clear_image_command :: (command_buffer: *Command_Buffer, image: Image,  color: Color4){
	assert(image.layout == .GENERAL, "Wrong image layout for clear command!");
	clear_range := create_subresource_range(xx VkImageAspectFlagBits.COLOR_BIT);
	clear_value: VkClearColorValue = .{.[color.r / 255.0, color.g / 255.0, color.b / 255.0, color.a / 255.0]};
	vkCmdClearColorImage(command_buffer, image, xx image.layout, *clear_value, 1, *clear_range);
}

submit_command_buffer :: (command_buffer: *Command_Buffer, queue: VkQueue, fence: *Fence, wait_semaphore: *Semaphore = null,  signal_semaphore: *Semaphore = null){
	buffer_info: VkCommandBufferSubmitInfo;
	buffer_info.commandBuffer = command_buffer;

	submit2_info: VkSubmitInfo2;

	if wait_semaphore{
		wait_semaphore_info: VkSemaphoreSubmitInfo;
		wait_semaphore_info.semaphore = wait_semaphore;
		wait_semaphore_info.stageMask = VK_PIPELINE_STAGE_2_COLOR_ATTACHMENT_OUTPUT_BIT_KHR;
		wait_semaphore_info.deviceIndex = 0;
		wait_semaphore_info.value = 1;
		
		submit2_info.waitSemaphoreInfoCount = 1;
		submit2_info.pWaitSemaphoreInfos = *wait_semaphore_info;
	}

	if signal_semaphore{
		signal_semaphore_info: VkSemaphoreSubmitInfo;
		signal_semaphore_info.semaphore = signal_semaphore;
		signal_semaphore_info.stageMask = VK_PIPELINE_STAGE_2_ALL_GRAPHICS_BIT;
		signal_semaphore_info.deviceIndex = 0;
		signal_semaphore_info.value = 1;
		
		submit2_info.signalSemaphoreInfoCount = 1;
		submit2_info.pSignalSemaphoreInfos = *signal_semaphore_info;
	}
	
    submit2_info.commandBufferInfoCount = 1;
    submit2_info.pCommandBufferInfos = *buffer_info;

	vk_assert(vkQueueSubmit2(queue, 1, *submit2_info, fence));
}


blit_image_command ::(buffer: *Command_Buffer, source: *Image, destination: *Image){
	source_layout := source.layout;
	destination_layout := destination.layout;
	
	transition_image_layout_command(buffer, source, .TRANSFER_SRC_OPTIMAL);
	transition_image_layout_command(buffer, destination, .TRANSFER_DST_OPTIMAL);
	
	blit_region: VkImageBlit2;
	blit_region.srcOffsets[1].x = xx source.extent.width;
	blit_region.srcOffsets[1].y = xx source.extent.height;
	blit_region.srcOffsets[1].z = 1;
	blit_region.dstOffsets[1].x = xx destination.extent.width;
	blit_region.dstOffsets[1].y = xx destination.extent.height;
	blit_region.dstOffsets[1].z = 1;
	blit_region.srcSubresource.aspectMask = .COLOR_BIT;
	blit_region.srcSubresource.baseArrayLayer = 0;
	blit_region.srcSubresource.layerCount = 1;
	blit_region.srcSubresource.mipLevel = 0;
	blit_region.dstSubresource.aspectMask = .COLOR_BIT;
	blit_region.dstSubresource.baseArrayLayer = 0;
	blit_region.dstSubresource.layerCount = 1;
	blit_region.dstSubresource.mipLevel = 0;
	
	blit_info: VkBlitImageInfo2;
	blit_info.dstImage = destination;
	blit_info.dstImageLayout = .TRANSFER_DST_OPTIMAL;
	blit_info.srcImage = source;
	blit_info.srcImageLayout = .TRANSFER_SRC_OPTIMAL;
	blit_info.filter = .LINEAR;
	blit_info.regionCount = 1;
	blit_info.pRegions = *blit_region;

	vkCmdBlitImage2(buffer, *blit_info);
 	
	if source_layout != .UNDEFINED then transition_image_layout_command(buffer, source, source_layout);
	if destination_layout != .UNDEFINED then transition_image_layout_command(buffer, destination, destination_layout);
}

bind_pipeline_command :: (buffer: *Command_Buffer, bind_point: Pipeline_Bind_Point, pipeline: *Pipeline, descriptor: Descriptor_Set){
	vkCmdBindPipeline(buffer, xx bind_point, pipeline);
	
	vkCmdBindDescriptorSets(buffer, xx bind_point, pipeline.layout, 0, 1, *descriptor.handle, 0, null);
}

dispatch_compute_command :: (buffer: *Command_Buffer, x_groups: u32, y_groups: u32, z_groups: u32 = 1){
	vkCmdDispatch(buffer, x_groups, y_groups, z_groups);
}

push_constants_command :: (buffer: *Command_Buffer, pipeline: *Pipeline, bind_point: Shader_Stage, data: *$T){
	vkCmdPushConstants(buffer, pipeline.layout, xx bind_point, 0, size_of(T), data);
}
