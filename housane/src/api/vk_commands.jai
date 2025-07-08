Command_Buffer :: struct{
	#as handle: VkCommandBuffer;
	allocator: VkCommandPool;
}

Fence :: VkFence;
Semaphore :: VkSemaphore;

create_command_buffer :: (device: *Device, queue_family: Device_Queue) -> Command_Buffer{
	command_buffer: Command_Buffer;
	
	command_pool_info: VkCommandPoolCreateInfo;
	command_pool_info.flags = .RESET_COMMAND_BUFFER_BIT;
	command_pool_info.queueFamilyIndex = device.physical_device.queue_families[queue_family];

	vk_assert(vkCreateCommandPool(device, *command_pool_info, null, *command_buffer.allocator));

	command_buffer_info: VkCommandBufferAllocateInfo;
	command_buffer_info.commandPool = command_buffer.allocator;
	command_buffer_info.commandBufferCount = 1;
	command_buffer_info.level = .PRIMARY;

	vk_assert(vkAllocateCommandBuffers(device, *command_buffer_info, *command_buffer.handle));
	
	return command_buffer;
}

begin_command_recording :: (/*flags: <type>*/){
	
}

destroy_command_buffer :: (device: *Device, buffer: *Command_Buffer){
	vkDestroyCommandPool(device, buffer.allocator, null);
}

create_fence :: (device: *Device, signaled: bool) -> Fence{
	fence: Fence;
	info: VkFenceCreateInfo;
    info.flags = ifx signaled then VkFenceCreateFlagBits.SIGNALED_BIT;
	
	vk_assert(vkCreateFence(device, *info, null, *fence));
	return fence;
}

create_semaphore :: (device: *Device/*, flags: VkSemaphoreCreateFlags*/) -> Semaphore{
	semaphore: Semaphore;
	info: VkSemaphoreCreateInfo;
    //info.flags = flags;
	vk_assert(vkCreateSemaphore(device, *info, null, *semaphore));
    return semaphore;
}

wait_fence :: (device: *Device, fence: Fence, timeout: u64 = U64_MAX){
	vk_assert(vkWaitForFences(device, 1, *fence, 1, timeout));
	vk_assert(vkResetFences(device, 1, *fence));
}
