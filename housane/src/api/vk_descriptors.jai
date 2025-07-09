Descriptor_Type :: enum {
    SAMPLER                    :: 0;
    COMBINED_IMAGE_SAMPLER     :: 1;
    SAMPLED_IMAGE              :: 2;
    STORAGE_IMAGE              :: 3;
    UNIFORM_TEXEL_BUFFER       :: 4;
    STORAGE_TEXEL_BUFFER       :: 5;
    UNIFORM_BUFFER             :: 6;
    STORAGE_BUFFER             :: 7;
    UNIFORM_BUFFER_DYNAMIC     :: 8;
    STORAGE_BUFFER_DYNAMIC     :: 9;
    INPUT_ATTACHMENT           :: 10;
    INLINE_UNIFORM_BLOCK       :: 1000138000;
    ACCELERATION_STRUCTURE_KHR :: 1000150000;
    ACCELERATION_STRUCTURE_NV  :: 1000165000;
    SAMPLE_WEIGHT_IMAGE_QCOM   :: 1000440000;
    BLOCK_MATCH_IMAGE_QCOM     :: 1000440001;
    MUTABLE_EXT                :: 1000351000;
    INLINE_UNIFORM_BLOCK_EXT   :: 1000138000;
    MUTABLE_VALVE              :: 1000351000;
    MAX_ENUM                   :: 2147483647;
}

Descriptor_Binding :: struct {
	type: Descriptor_Type;
	binding: u64;
}

Pool_Size_Ratio :: struct {
	type: Descriptor_Type;
	ratio: f32;
}

Descriptor_Allocator_Internals :: struct{
	#as handle: VkDescriptorPool;
	device: *Device;
}

Descriptor_Allocator :: struct{
	using internals: Descriptor_Allocator_Internals;
	allocations: [..] VkDescriptorPool;
}

Descriptor_Set :: struct{
	#as handle: VkDescriptorSet;
	layout: VkDescriptorSetLayout;
}

create_descriptor_allocator :: (device: *Device, deletion_queue: *Deletion_Queue, sets: u32, pool_ratios: ..Pool_Size_Ratio) -> Descriptor_Allocator{
	allocator: Descriptor_Allocator;
	allocator.device = device;
	
	pool_sizes: [..] VkDescriptorPoolSize;
	for pool_ratios {
		size: VkDescriptorPoolSize;
		size.descriptorCount  = xx it.ratio * sets;
		size.type = xx it.type;
		array_add(*pool_sizes, size);
	}

	pool_info: VkDescriptorPoolCreateInfo;
	pool_info.flags = 0;
	pool_info.maxSets = sets;
	pool_info.poolSizeCount = xx pool_sizes.count;
	pool_info.pPoolSizes = pool_sizes.data;

	vkCreateDescriptorPool(device, *pool_info, null, *allocator.handle);
	array_free(pool_sizes);
	
	Deletion_Queue.push(deletion_queue, allocator.internals);
	return allocator;
}

clear_descriptor_allocator :: (allocator: *Descriptor_Allocator){
	vkResetDescriptorPool(allocator.device, allocator, 0);
}

destroy_descriptor_allocator_internals :: (allocator: Descriptor_Allocator_Internals){
	vkDestroyDescriptorPool(allocator.device, allocator, null);
}

destroy_descriptor_allocator :: (allocator: *Descriptor_Allocator) {
	destroy_descriptor_allocator_internals(allocator.internals);
}


create_descriptor_set :: (allocator: *Descriptor_Allocator, shader_stage: Shader_Stage, bindings: ..Descriptor_Binding, next: *void = null)  -> Descriptor_Set{
	set: Descriptor_Set;
	
	vulkan_bindings: [..] VkDescriptorSetLayoutBinding;
	for bindings {
		new_bind: VkDescriptorSetLayoutBinding;
		new_bind.binding = xx it.binding;
		new_bind.descriptorCount = 1;
		new_bind.descriptorType = xx it.type;
        new_bind.stageFlags = xx shader_stage;
		
		array_add(*vulkan_bindings, new_bind);
	}

    layout_info: VkDescriptorSetLayoutCreateInfo;
	layout_info.pNext = null;

	layout_info.pBindings = vulkan_bindings.data;
	layout_info.bindingCount = xx vulkan_bindings.count;
	layout_info.flags = 0;

	vk_assert(vkCreateDescriptorSetLayout(allocator.device, *layout_info, null, *set.layout));
	
	alloc_info: VkDescriptorSetAllocateInfo ;
	alloc_info.descriptorPool = allocator;
	alloc_info.descriptorSetCount = 1;
	alloc_info.pSetLayouts = *set.layout;

	vk_assert(vkAllocateDescriptorSets(allocator.device, *alloc_info, *set.handle));
	return set;
}

update_descriptor_set_image :: (device: *Device, descriptor: *Descriptor_Set, image: *Image){
	img_info: VkDescriptorImageInfo;
	img_info.imageLayout = .GENERAL; //NOTE: dunno why i need to force it to be general
	img_info.imageView = image.view;
	
	draw_image_write: VkWriteDescriptorSet;
	draw_image_write.sType = .WRITE_DESCRIPTOR_SET;
	draw_image_write.pNext = null;
	
	draw_image_write.dstBinding = 0;
	draw_image_write.dstSet = descriptor;
	draw_image_write.descriptorCount = 1;
	draw_image_write.descriptorType = .STORAGE_IMAGE;
	draw_image_write.pImageInfo = *img_info;

	vkUpdateDescriptorSets(device, 1, *draw_image_write, 0, null);
}
