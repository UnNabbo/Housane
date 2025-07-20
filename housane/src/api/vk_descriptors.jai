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

Descriptor_Pool :: struct{
	#as handle: VkDescriptorPool;
	full: bool;
} 

Descriptor_Allocator :: struct{
	device: *Device;
	ratios: [..] Pool_Size_Ratio;
	pools:  [..] Descriptor_Pool;
	sets: u32 = 32;
}

Descriptor_Write_Queue :: struct {
	device: *Device;
	memory: *Arena;
	writes: [..] VkWriteDescriptorSet;
}

Descriptor_Set_Layout :: VkDescriptorSetLayout;

Descriptor_Set :: struct{
	#as handle: VkDescriptorSet;
	layout: Descriptor_Set_Layout;
}

create_descriptor_write_queue :: (device: *Device, size: u64 = 32768) -> Descriptor_Write_Queue{
	queue: Descriptor_Write_Queue;
	queue.memory = arena_alloc();
	queue.device = device;
	return queue;
}


write_descriptor :: (queue: *Descriptor_Write_Queue, buffer: Allocated_Buffer, type: Descriptor_Type, bind_point: u32, size: u64, offset: u64 = 0){
	assert(type == .UNIFORM_BUFFER || type == .UNIFORM_BUFFER_DYNAMIC || type == .STORAGE_BUFFER  || type == .STORAGE_BUFFER_DYNAMIC);
	


	data := arena_push(queue.memory, VkDescriptorBufferInfo);
	data.offset = offset;
	data.buffer = buffer;
	data.range = size;
	
	write: VkWriteDescriptorSet;
	write.dstBinding  = bind_point;
	write.dstSet = NULL_HANDLE;
	write.descriptorCount = 1;
	write.descriptorType = xx type;
	write.pBufferInfo = data;
	array_add(*queue.writes, write);
}

write_descriptor :: (queue: *Descriptor_Write_Queue, image: Image, type: Descriptor_Type, bind_point: u32, sampler: Sampler = .{}){
	//assert(type != .UNIFORM_BUFFER && type != .UNIFORM_BUFFER_DYNAMIC && type != .STORAGE_BUFFER  && type != .STORAGE_BUFFER_DYNAMIC);


	data := arena_push(queue.memory, VkDescriptorImageInfo);
	data.sampler = sampler;
	data.imageView = image.view;
	data.imageLayout = xx image.layout;
	
	write: VkWriteDescriptorSet;
	write.dstBinding  = bind_point;
	write.dstSet = NULL_HANDLE;
	write.descriptorCount = 1;
	write.descriptorType = xx type;
	write.pImageInfo  = data;
	array_add(*queue.writes, write);
}

flush_descriptor_write_queue :: (queue: *Descriptor_Write_Queue, set: Descriptor_Set, clear: bool = false){
	for * queue.writes {
		it.dstSet = set; 
	}

	vkUpdateDescriptorSets(queue.device, xx queue.writes.count, queue.writes.data, 0, null);
	
	if clear{
		queue.writes.count = 0;
		arena_clear(queue.memory);
	}
}

grow_allocator_pools :: (allocator: * Descriptor_Allocator) -> *Descriptor_Pool{
	pool_sizes: [..] VkDescriptorPoolSize;
	for allocator.ratios {
		size: VkDescriptorPoolSize;
		size.descriptorCount  = xx it.ratio * allocator.sets;
		size.type = xx it.type;
		array_add(*pool_sizes, size);
	}

	pool_info: VkDescriptorPoolCreateInfo;
	pool_info.flags = 0;
	pool_info.maxSets = allocator.sets;
	pool_info.poolSizeCount = xx pool_sizes.count;
	pool_info.pPoolSizes = pool_sizes.data;

	pool: Descriptor_Pool;
	vkCreateDescriptorPool(allocator.device, *pool_info, null, *pool.handle);
	array_add(*allocator.pools, pool);
	
	array_free(pool_sizes);
	return *allocator.pools[allocator.pools.count - 1];
}

create_descriptor_allocator :: (device: *Device, pool_ratios: ..Pool_Size_Ratio) -> Descriptor_Allocator{
	allocator: Descriptor_Allocator;
	allocator.device = device;
	
	for pool_ratios {
		array_add(*allocator.ratios, it);
	}

	grow_allocator_pools(*allocator);
	
	return allocator;
}

get_available_descriptor_pool :: (allocator: *Descriptor_Allocator) -> *Descriptor_Pool{
	for * allocator.pools{
		if !it.full then return it; 
	}
	
	allocator.sets = clamp_hi(cast(u32, allocator.sets * 1.5), 4092);
	return grow_allocator_pools(allocator);
}

clear_descriptor_allocator :: (allocator: *Descriptor_Allocator){
	for * allocator.pools{
		vkResetDescriptorPool(allocator.device, it, 0);
	}
}

destroy_descriptor_allocator :: (allocator: *Descriptor_Allocator) {
	for * allocator.pools{
		vkDestroyDescriptorPool(allocator.device, it, null);
	}
}

create_descriptor_set_layout :: (device: Device, shader_stage: Shader_Stage, bindings: ..Descriptor_Binding, next: *void = null) -> Descriptor_Set_Layout{
	layout: Descriptor_Set_Layout;
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

	vk_assert(vkCreateDescriptorSetLayout(device, *layout_info, null, *layout));

	return layout;
}

destroy_descriptor_set_layout :: (device: Device, layout: *Descriptor_Set_Layout){
	vkDestroyDescriptorSetLayout(device, layout.*, null);
}

allocate_descriptor_set :: (allocator: *Descriptor_Allocator, layout: Descriptor_Set_Layout, loc := #caller_location)  -> Descriptor_Set{
	pool := get_available_descriptor_pool(allocator);

	set: Descriptor_Set;
	set.layout = layout;

	alloc_info: VkDescriptorSetAllocateInfo ;
	alloc_info.descriptorPool = pool;
	alloc_info.descriptorSetCount = 1;
	alloc_info.pSetLayouts = *layout;

	log("Descriptor allocated at %:%", loc.fully_pathed_filename, loc.line_number);
	
	res := vkAllocateDescriptorSets(allocator.device, *alloc_info, *set.handle);
	if res == VkResult.ERROR_OUT_OF_POOL_MEMORY || res == VkResult.ERROR_FRAGMENTED_POOL{
		pool.full = true;
		pool = get_available_descriptor_pool(allocator);
		alloc_info.descriptorPool = pool;
		vk_assert(vkAllocateDescriptorSets(allocator.device, *alloc_info, *set.handle));
	}
	
	return set;
}



update_descriptor_set_image :: (device: Device, descriptor: Descriptor_Set, image: Image){
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
