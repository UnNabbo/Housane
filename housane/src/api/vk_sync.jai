Fence :: struct{
	#as handle: VkFence;
	device: *Device;
};

GPU_Semaphore :: struct{
	#as handle: VkSemaphore;
	device: *Device;
};

create_fence :: (device: *Device, signaled: bool) -> Fence{
	fence: Fence;
	fence.device = device;
	
	info: VkFenceCreateInfo;
    info.flags = ifx signaled then VkFenceCreateFlagBits.SIGNALED_BIT;
	
	vk_assert(vkCreateFence(device, *info, null, *fence.handle));
	
	return fence;
}

destroy_fence :: (fence: *Fence){
	vkDestroyFence(fence.device, fence, null);
}

create_semaphore :: (device: *Device/*, flags: <type>*/) -> GPU_Semaphore{
	semaphore: GPU_Semaphore;
	semaphore.device = device;
	
	info: VkSemaphoreCreateInfo;
    //info.flags = flags;
	vk_assert(vkCreateSemaphore(device, *info, null, *semaphore.handle));
    return semaphore;
}

destroy_semaphore :: (semaphore: *GPU_Semaphore){
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
