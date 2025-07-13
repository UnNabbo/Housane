NULL_HANDLE :: VK_NULL_HANDLE;

Image_Subresource_Range :: VkImageSubresourceRange;

vk_assert :: val => assert(val == .SUCCESS);

Deletion_Queue :: struct {#insert #run __generate_deletion_queue_body(
		Fence,
		Pipeline,
		Semaphore,
		Command_Buffer,
		Descriptor_Allocator,
		Vulkan_Memory_Allocator
);}



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
    attachment.loadOp  = .LOAD;
    attachment.storeOp = .STORE;

	if image.usage == .DEPTH_STENCIL_ATTACHMENT_BIT {
		attachment.loadOp = .CLEAR;
		attachment.clearValue.depthStencil.depth = 0.0;
	}

	return attachment;
}
