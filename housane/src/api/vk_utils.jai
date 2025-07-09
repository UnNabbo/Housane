NULL_HANDLE :: VK_NULL_HANDLE;

Image_Subresource_Range :: VkImageSubresourceRange;

vk_assert :: val => assert(val == .SUCCESS);

Deletion_Queue :: struct {
	#insert #run __generate_deletion_queue_body(Fence, Semaphore, Vulkan_Memory_Allocator, Command_Buffer, Image_Internals, Descriptor_Allocator_Internals);
}


clamp_hi :: inline (val: $T, max: T) -> T {
	return clamp(val, val, max);
}

get_instance_proc_add :: (inst: VkInstance, entry: string) #expand {
	#insert #run tprint("`% : PFN_% = xx vkGetInstanceProcAddr(inst, \"%\");", entry, entry, entry);
}


create_subresource_range :: (mask: u64) -> Image_Subresource_Range{
	subresource: Image_Subresource_Range;
    subresource.aspectMask = xx mask;
    subresource.baseMipLevel = 0;
    subresource.levelCount = VK_REMAINING_MIP_LEVELS;
    subresource.baseArrayLayer = 0;
    subresource.layerCount = VK_REMAINING_ARRAY_LAYERS;

	return subresource;
}

#scope_file

//NOTE: maybe move it in vk_memory.jai.
destroy_image_internals :: (using image_internals: Image_Internals){
	vkDestroyImageView(allocation.allocator.device, view, null);
	vmaDestroyImage(allocation.allocator, handle, allocation);
}
