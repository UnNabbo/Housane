NULL_HANDLE :: VK_NULL_HANDLE;

Image_Subresource_Range :: VkImageSubresourceRange;

vk_assert :: val => assert(val == .SUCCESS);

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


image_attachment_info :: (image: Image, clear: bool = false) -> VkRenderingAttachmentInfo{
	attachment: VkRenderingAttachmentInfo;
    attachment.imageView = image.view;
    attachment.imageLayout = xx image.layout;
    attachment.storeOp = .STORE;
	if image.usage == .DEPTH_STENCIL_ATTACHMENT {
		attachment.loadOp = .CLEAR;
		attachment.clearValue.depthStencil.depth = 0.0;
	}else{
		attachment.loadOp  = .LOAD;
	}

	return attachment;
}

SDL_Vulkan_CreateSurface :: (window: *SDL_Window, instance: VkInstance, allocator: *VkAllocationCallbacks, surface: *VkSurfaceKHR) -> bool #foreign libsdl3;

SDL_Vulkan_DestroySurface :: (instance: VkInstance, surface: VkSurfaceKHR, allocator: *VkAllocationCallbacks) -> void #foreign libsdl3;
 
SDL_Vulkan_GetPresentationSupport :: (instance: VkInstance, physicalDevice: VkPhysicalDevice, queueFamilyIndex: Uint32) -> bool #foreign libsdl3;

#scope_file

libsdl3 :: #library "../../../modules/jai-sdl3/libSDL3";
