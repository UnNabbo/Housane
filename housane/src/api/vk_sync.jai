Fence :: struct{
	#as handle: VkFence;
	device: *Device;
};

Semaphore :: struct{
	#as handle: VkSemaphore;
	device: *Device;
};

create_fence :: (device: *Device, signaled: bool, deletion_queue: *Deletion_Queue = null) -> Fence{
	fence: Fence;
	fence.device = device;
	
	info: VkFenceCreateInfo;
    info.flags = ifx signaled then VkFenceCreateFlagBits.SIGNALED_BIT;
	
	vk_assert(vkCreateFence(device, *info, null, *fence.handle));
	Deletion_Queue.push(deletion_queue, fence);
	
	return fence;
}

destroy_fence :: (fence: *Fence){
	vkDestroyFence(fence.device, fence, null);
}

create_semaphore :: (device: *Device, deletion_queue: *Deletion_Queue = null/*, flags: <type>*/) -> Semaphore{
	semaphore: Semaphore;
	semaphore.device = device;
	
	info: VkSemaphoreCreateInfo;
    //info.flags = flags;
	vk_assert(vkCreateSemaphore(device, *info, null, *semaphore.handle));
	Deletion_Queue.push(deletion_queue, semaphore);
    return semaphore;
}

destroy_semaphore :: (semaphore: *Semaphore){
	vkDestroySemaphore(semaphore.device, semaphore, null);
}

wait_and_reset_fence :: (fence: Fence, timeout: u64 = U64_MAX){
	vk_assert(vkWaitForFences(fence.device, 1, *fence.handle, 1, timeout));
	vk_assert(vkResetFences(fence.device, 1, *fence.handle));
}

wait_fence :: (fence: Fence, timeout: u64 = U64_MAX){
	vk_assert(vkWaitForFences(fence.device, 1, *fence.handle, 1, timeout));
}

reset_fence :: (fence: Fence){
	vk_assert(vkResetFences(fence.device, 1, *fence.handle));
}
