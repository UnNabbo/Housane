
Type_And_Size :: struct {
	#as type: Type;
	size: u64;
}


Shader_Stage :: enum_flags {
    VERTEX                  :: 0x1;
    TESSELLATION_CONTROL    :: 0x2;
    TESSELLATION_EVALUATION :: 0x4;
    GEOMETRY                :: 0x8;
    FRAGMENT                :: 0x10;
    COMPUTE                 :: 0x20;
    ALL_GRAPHICS            :: 0x1f;
    ALL                     :: 0x7fffffff;
    RAYGEN                  :: 0x100;
    ANY_HIT                 :: 0x200;
    CLOSEST_HIT             :: 0x400;
    MISS                    :: 0x800;
    INTERSECTION            :: 0x1000;
    CALLABLE                :: 0x2000;
    TASK                    :: 0x40;
    MESH                    :: 0x80;
}

Shader_Module :: struct{
	#as handle: VkShaderModule;
	stage: Shader_Stage;
	entry_point: string = "main";
	
	push_types: [..] Type;
}

Shader :: struct{
	stages: [..] VkPipelineShaderStageCreateInfo;
	push_constants: [..] VkPushConstantRange;
	descriptor_layouts: [..] Descriptor_Set_Layout;
}

create_shader :: (modules: []Shader_Module, descriptors: []Descriptor_Set_Layout) -> Shader {
	shader: Shader;

	for *descriptors {
		array_add(*shader.descriptor_layouts, it.*);
	}
	
	for *modules {
		stage_info: VkPipelineShaderStageCreateInfo;
		stage_info.stage = xx it.stage;
		stage_info.module = it;
		stage_info.pName = it.entry_point.data;
		
		array_add(*shader.stages, stage_info);
		for type: it.push_types {
			push_constant_info: VkPushConstantRange;
			push_constant_info.offset = 0;
			push_constant_info.size = xx cast(*Type_Info, type).runtime_size;
			push_constant_info.stageFlags = xx it.stage;
			
			array_add(*shader.push_constants, push_constant_info);
		}
	}

	return shader;
}

create_shader_module :: (device: Device, stage: Shader_Stage, path: string, push_types: ..Type) -> Shader_Module{
	data, result := read_entire_file(path);
	if !result{
		breakpoint();
		exit(-1);
	}

	create_info: VkShaderModuleCreateInfo;
    create_info.codeSize = xx data.count;
    create_info.pCode = xx data.data;
	
	module: Shader_Module;
	module.stage = stage;

    vk_assert(vkCreateShaderModule(device, *create_info, null, *module.handle));

	for push_types {
		array_add(*module.push_types, it);
	}
	
	return module;
}

destroy_shader_module :: (device: Device, module: Shader_Module){
	vkDestroyShaderModule(device, module, null);
	array_free(module.push_types);
}
