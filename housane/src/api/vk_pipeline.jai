Assembly_Topology :: enum{
	NONE                          :: -1;
	POINT_LIST                    ::  0;
    LINE_LIST                     ::  1;
    LINE_STRIP                    ::  2;
    TRIANGLE_LIST                 ::  3;
    TRIANGLE_STRIP                ::  4;
    TRIANGLE_FAN                  ::  5;
    LINE_LIST_WITH_ADJACENCY      ::  6;
    LINE_STRIP_WITH_ADJACENCY     ::  7;
    TRIANGLE_LIST_WITH_ADJACENCY  ::  8;
    TRIANGLE_STRIP_WITH_ADJACENCY ::  9;
    PATCH_LIST                    :: 10;
}

Rasterization_Fill_Mode :: enum{
	NONE              ::          -1;
	FILL              ::           0;
    LINE              ::           1;
    POINT             ::           2;
    FILL_RECTANGLE_NV ::  1000153000;
}

Rasterization_Cull_Mode :: enum{
	NONE              :: -1;
	COUNTER_CLOCKWISE ::  0;
    CLOCKWISE         ::  1;
} 

Pipeline_Usage :: enum{
	GRAPHICS               :: 0;
	COMPUTE                :: 1;
	RAY_TRACING            :: 1000165000;
}

Pipeline_Info :: struct {
	color_attachment_format: Image_Format = .UNDEFINED;
	depth_attachment_format: Image_Format = .UNDEFINED;
	
	multisampling: bool = false;
	alpha_blending: bool = false;
	depth_testing: bool = false;
	
	assembly_topology: Assembly_Topology = .TRIANGLE_LIST;
	rasterization_fill_mode: Rasterization_Fill_Mode = .FILL;
	rasterization_cull_mode: Rasterization_Cull_Mode = .COUNTER_CLOCKWISE;
}

Pipeline :: struct {
	#as handle: VkPipeline;
	layout: VkPipelineLayout;
	
	usage: Pipeline_Usage = .GRAPHICS;
}

create_pipeline :: (device: *Device, info: Pipeline_Info, shader: *Shader, deletion_queue: *Deletion_Queue = null) -> Pipeline{
	pipeline: Pipeline;
	
	input_assembly: VkPipelineInputAssemblyStateCreateInfo;
	input_assembly.topology   = xx info.assembly_topology;
    input_assembly.primitiveRestartEnable  = VK_FALSE;
		
	rasterizer: VkPipelineRasterizationStateCreateInfo;
	rasterizer.polygonMode = xx info.rasterization_fill_mode;
    rasterizer.lineWidth = xx 1.0;

	rasterizer.cullMode = .NONE;
    rasterizer.frontFace = xx info.rasterization_cull_mode;

	multisampling: VkPipelineMultisampleStateCreateInfo;
	if(info.multisampling){
		
	}else{
		multisampling.sampleShadingEnable = VK_FALSE;
		multisampling.rasterizationSamples = ._1_BIT;
		multisampling.minSampleShading = 1.0;
		multisampling.pSampleMask = null;
		multisampling.alphaToCoverageEnable = VK_FALSE;
		multisampling.alphaToOneEnable = VK_FALSE;
	}

	color_blend_attachment: VkPipelineColorBlendAttachmentState;
	if(info.alpha_blending){
		
	}else{
		color_blend_attachment.colorWriteMask = .R_BIT | .G_BIT | .B_BIT | .A_BIT;
		color_blend_attachment.blendEnable = VK_FALSE;
	}

	attachment: VkFormat = xx info.color_attachment_format;
	render_info: VkPipelineRenderingCreateInfo;
	render_info.colorAttachmentCount = 1;
    render_info.pColorAttachmentFormats = *attachment;
	render_info.depthAttachmentFormat = xx info.depth_attachment_format;

	depth_stencil: VkPipelineDepthStencilStateCreateInfo;
	if(info.depth_testing){

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
	

	layout: VkPipelineLayoutCreateInfo;
	layout.pSetLayouts = shader.descriptor_layouts.data;
	layout.setLayoutCount = xx shader.descriptor_layouts.count;
	layout.pPushConstantRanges = shader.push_constants.data;
	layout.pushConstantRangeCount = xx shader.push_constants.count;
	
	vk_assert(vkCreatePipelineLayout(device, *layout, null, *pipeline.layout));
	
	viewport_state: VkPipelineViewportStateCreateInfo;
	viewport_state.viewportCount = 1;
	viewport_state.scissorCount = 1;

	color_blending: VkPipelineColorBlendStateCreateInfo;
	color_blending.logicOpEnable = VK_FALSE;
	color_blending.logicOp = .COPY;
	color_blending.attachmentCount = 1;
	color_blending.pAttachments = *color_blend_attachment;

	vertex_input_info: VkPipelineVertexInputStateCreateInfo;

	pipeline_info: VkGraphicsPipelineCreateInfo;
	pipeline_info.pNext = *render_info;
	pipeline_info.stageCount = xx shader.stages.count;
	pipeline_info.pStages = shader.stages.data;
	pipeline_info.pVertexInputState = *vertex_input_info;
	pipeline_info.pInputAssemblyState = *input_assembly;
	pipeline_info.pViewportState = *viewport_state;
	pipeline_info.pRasterizationState = *rasterizer;
	pipeline_info.pMultisampleState = *multisampling;
	pipeline_info.pColorBlendState = *color_blending;
	pipeline_info.pDepthStencilState = *depth_stencil;
	pipeline_info.layout = pipeline.layout;

	state: [] VkDynamicState = .[.VIEWPORT, .SCISSOR];

	dynamic_info: VkPipelineDynamicStateCreateInfo;
	dynamic_info.dynamicStateCount = xx state.count;
	dynamic_info.pDynamicStates = state.data;

	pipeline_info.pDynamicState = *dynamic_info;

	vkCreateGraphicsPipelines(device, VK_NULL_HANDLE, 1, *pipeline_info, null, *pipeline.handle);

	Deletion_Queue.push(deletion_queue, pipeline);
	
	return pipeline;
}

destroy_pipeline :: (device: *Pipeline){
	
}

create_pipeline :: (device: *Device, shader: *Shader) -> Pipeline{
	pipeline: Pipeline;
	pipeline.usage = .COMPUTE;
	
	compute_layout: VkPipelineLayoutCreateInfo;
	compute_layout.pSetLayouts = shader.descriptor_layouts.data;
	compute_layout.setLayoutCount = xx shader.descriptor_layouts.count;
	compute_layout.pPushConstantRanges = shader.push_constants.data;
	compute_layout.pushConstantRangeCount = xx shader.push_constants.count;
	
	vk_assert(vkCreatePipelineLayout(device, *compute_layout, null, *pipeline.layout));

	compute_pipeline_create_info: VkComputePipelineCreateInfo;
	compute_pipeline_create_info.layout = pipeline.layout;
	assert(shader.stages.count == 1);
	compute_pipeline_create_info.stage = shader.stages[0];
	
	vk_assert(vkCreateComputePipelines(device, VK_NULL_HANDLE, 1, *compute_pipeline_create_info, null, *pipeline.handle));

	return pipeline;
}

