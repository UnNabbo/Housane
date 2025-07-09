Rasterizer_Mode :: enum{
	NONE                          :: -1;
	POINT_LIST                    :: 0;
    LINE_LIST                     :: 1;
    LINE_STRIP                    :: 2;
    TRIANGLE_LIST                 :: 3;
    TRIANGLE_STRIP                :: 4;
    TRIANGLE_FAN                  :: 5;
    LINE_LIST_WITH_ADJACENCY      :: 6;
    LINE_STRIP_WITH_ADJACENCY     :: 7;
    TRIANGLE_LIST_WITH_ADJACENCY  :: 8;
    TRIANGLE_STRIP_WITH_ADJACENCY :: 9;
    PATCH_LIST                    :: 10;
}

Polygon_Mode :: enum{
	NONE              :: -1;
	FILL              :: 0;
    LINE              :: 1;
    POINT             :: 2;
    FILL_RECTANGLE_NV :: 1000153000;
}

Culling_Mode :: enum{
	NONE              :: -1;
	COUNTER_CLOCKWISE :: 0;
    CLOCKWISE         :: 1;
} 

Pipeline_Bind_Point :: enum{
	GRAPHICS               :: 0;
	COMPUTE                :: 1;
	RAY_TRACING_KHR        :: 1000165000;
	SUBPASS_SHADING_HUAWEI :: 1000369003;
	RAY_TRACING_NV         :: 1000165000;
}

Pipeline :: struct {
	#as handle: VkPipeline;
	layout: VkPipelineLayout;
	
	shader: Shader;
	
    rasterizer:              VkPipelineRasterizationStateCreateInfo;
    multisampling:           VkPipelineMultisampleStateCreateInfo;
    render_info:             VkPipelineRenderingCreateInfo;
    depth_stencil:           VkPipelineDepthStencilStateCreateInfo;
    input_assembly:          VkPipelineInputAssemblyStateCreateInfo;
    color_blend_attachment:  VkPipelineColorBlendAttachmentState;
    color_attachment_format: VkFormat;
}

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
	
	device: *Device;
}

Shader :: struct{
	stages: [..] VkPipelineShaderStageCreateInfo;
	push_constants: [..] VkPushConstantRange;
}

create_shader :: (modules: ..Shader_Module) -> Shader {
	shader: Shader;
	
	for modules {
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

create_shader_module :: (device: *Device, stage: Shader_Stage, path: string, push_types: ..Type) -> Shader_Module{
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

destroy_shader_module :: (module: *Shader_Module){
	vkDestroyShaderModule(module.device, module, null);
}
#if false{

create_pipeline_info :: (
	shader: Shader,
	color: Image_Format = .UNDEFINED,
	depth: Image_Format = .UNDEFINED,
	rasterizer_mode: Rasterizer_Mode = .NONE,
	polygon_mode: Polygon_Mode = .NONE,
	culling_mode: Culling_Mode = .NONE,
	enable_multisampling: bool = false,
	enable_alpha_blending: bool = false,
	enable_depth_testing: bool = false
) -> Pipeline_Info{
	info.shader = shader;

	input_assembly.topology   = xx rasterizer_mode;
    input_assembly.primitiveRestartEnable  = VK_FALSE;
		
	
	rasterizer.polygonMode = xx polygon_mode;
    rasterizer.lineWidth = xx 1.0;

	rasterizer.cullMode = .NONE;
    rasterizer.frontFace = xx culling_mode;

	if(enable_multisampling){
		
	}else{
		multisampling.sampleShadingEnable = VK_FALSE;
		multisampling.rasterizationSamples = ._1_BIT;
		multisampling.minSampleShading = 1.0;
		multisampling.pSampleMask = null;
		multisampling.alphaToCoverageEnable = VK_FALSE;
		multisampling.alphaToOneEnable = VK_FALSE;
	}
    // no alpha to coverage either

	if(enable_a_blending){
		
	}else{
		color_blend_attachment.colorWriteMask = .R_BIT | .G_BIT | .B_BIT | .A_BIT;
		color_blend_attachment.blendEnable = VK_FALSE;
	}

	color_attachment_format = color;
	render_info.colorAttachmentCount = 1;
    render_info.pColorAttachmentFormats = *color_attachment_format;
	render_info.depthAttachmentFormat = depth;

	if(enable_depth_testing){

	}else{
		depth_stencil.depthTestEnable = VK_FALSE;
		depth_stencil.depthWriteEnable = VK_FALSE;
		depth_stencil.depthCompareOp = .NEVER;
		depth_stencil.depthBoundsTestEnable = VK_FALSE;
		depth_stencil.stencilTestEnable = VK_FALSE;
		depth_stencil.front = .{};
		depth_stencil.back = .{};
		depth_stencil.minDepthBounds = xx 0.0;
		depth_stencil.maxDepthBounds = xx 1.0;
	}
	
	return info;
}

create_graphic_pipeline :: (using vk_context: *Context, info: Pipeline_Info, descriptors: ..VkDescriptorSetLayout) -> Pipeline{
	pipeline: Pipeline;
	pipeline.info = info;

	layout: VkPipelineLayoutCreateInfo;
	layout.pSetLayouts = descriptors.data;
	layout.setLayoutCount = xx descriptors.count;
	layout.pPushConstantRanges = pipeline.info.shader.push_constants.data;
	layout.pushConstantRangeCount = xx pipeline.info.shader.push_constants.count;
	
	vk_assert(vkCreatePipelineLayout(device, *layout, null, *pipeline.layout));
	
	
	viewport_state: VkPipelineViewportStateCreateInfo;
	viewport_state.viewportCount = 1;
	viewport_state.scissorCount = 1;

	color_blending: VkPipelineColorBlendStateCreateInfo;
	color_blending.logicOpEnable = VK_FALSE;
	color_blending.logicOp = .COPY;
	color_blending.attachmentCount = 1;
	color_blending.pAttachments = *pipeline.color_blend_attachment;

	vertex_input_info: VkPipelineVertexInputStateCreateInfo;

	pipeline_info: VkGraphicsPipelineCreateInfo;
	pipeline_info.pNext = *pipeline.render_info;
	pipeline_info.stageCount = xx pipeline.shader.stages.count;
	pipeline_info.pStages = pipeline.shader.stages.data;
	pipeline_info.pVertexInputState = *vertex_input_info;
	pipeline_info.pInputAssemblyState = *pipeline.input_assembly;
	pipeline_info.pViewportState = *viewport_state;
	pipeline_info.pRasterizationState = *pipeline.rasterizer;
	pipeline_info.pMultisampleState = *pipeline.multisampling;
	pipeline_info.pColorBlendState = *color_blending;
	pipeline_info.pDepthStencilState = *pipeline.depth_stencil;
	pipeline_info.layout = pipeline.layout;

	state: [] VkDynamicState = .[.VIEWPORT, .SCISSOR];

	dynamic_info: VkPipelineDynamicStateCreateInfo;
	dynamic_info.dynamicStateCount = xx state.count;
	dynamic_info.pDynamicStates = state.data;

	pipeline_info.pDynamicState = *dynamic_info;


	vkCreateGraphicsPipelines(device, VK_NULL_HANDLE, 1, *pipeline_info, null, *pipeline.handle);

	return pipeline;
}

}

create_compute_pipeline :: (device: *Device, shader: Shader, descriptors: ..Descriptor_Set) -> Pipeline{
	pipeline: Pipeline;
	pipeline.shader = shader;
	
	layouts: [..] VkDescriptorSetLayout ;
	for descriptors {
		array_add(*layouts, it.layout);
	}
	
	compute_layout: VkPipelineLayoutCreateInfo;
	compute_layout.pSetLayouts = layouts.data;
	compute_layout.setLayoutCount = xx layouts.count;
	compute_layout.pPushConstantRanges = shader.push_constants.data;
	compute_layout.pushConstantRangeCount = xx shader.push_constants.count;
	
	vk_assert(vkCreatePipelineLayout(device, *compute_layout, null, *pipeline.layout));
	array_free(layouts);

	compute_pipeline_create_info: VkComputePipelineCreateInfo;
	compute_pipeline_create_info.layout = pipeline.layout;
	assert(pipeline.shader.stages.count == 1);
	compute_pipeline_create_info.stage = pipeline.shader.stages[0];
	
	vk_assert(vkCreateComputePipelines(device, VK_NULL_HANDLE, 1, *compute_pipeline_create_info, null, *pipeline.handle));

	return pipeline;
}

