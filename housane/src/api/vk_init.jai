Device_Queue :: enum {
	INVALID :: -1;
	GRAPHIC_PRESENT;
	COUNT;
}

Physical_Device :: struct {
	#as handle : VkPhysicalDevice;
	queue_families: [Device_Queue.COUNT] u32;
}

Device :: struct { 
	#as handle: VkDevice;
	physical_device: *Physical_Device;
	queues: [Device_Queue.COUNT] VkQueue;
}

Surface :: struct {
	#as handle: VkSurfaceKHR;
	capabilities: VkSurfaceCapabilitiesKHR ;
	formats: [..] VkSurfaceFormatKHR;
	present_modes: [..] VkPresentModeKHR;
}

Swap_Chain_Present_Mode :: enum u32{
	IMMEDIATE				  :: 0;
	MAILBOX					  :: 1;
	FIFO					  :: 2;
	FIFO_RELAXED			  :: 3;
	SHARED_DEMAND_REFRESH	  :: 1000111000;
	SHARED_CONTINUOUS_REFRESH :: 1000111001;
}

Swapchain :: struct{
	#as handle: VkSwapchainKHR;
	images: [..] Image;
	extent: VkExtent2D;
	surface_format: VkSurfaceFormatKHR;
	present_mode: Swap_Chain_Present_Mode;

	device: *Device;
	surface: *Surface;
}

Instance :: struct{
	#as handle: VkInstance;
	surface: Surface;
	physical_device: Physical_Device ;
	
	#if BUILD_TYPE != .RELEASE{
		debug_messenger: VkDebugUtilsMessengerEXT ;
	}
}

create_surface :: (instance: *Instance, window: *void) {
	assert(SDL_Vulkan_CreateSurface(window, instance.handle, null, *instance.surface.handle));
}
	
get_extensions :: () -> []*u8 {
	sdl_count: u32;
	sdl_extension := SDL_Vulkan_GetInstanceExtensions(*sdl_count);
	extensions : [..]*u8;
	extensions.allocator = temp;
	
	for 0..sdl_count - 1 {
		array_add(*extensions, sdl_extension[it]);
	}
	array_add(*extensions, VK_EXT_SURFACE_MAINTENANCE_1_EXTENSION_NAME, VK_KHR_GET_SURFACE_CAPABILITIES_2_EXTENSION_NAME);
	#if BUILD_TYPE != .RELEASE{
		array_add(*extensions, VK_EXT_DEBUG_UTILS_EXTENSION_NAME);
	}
	return extensions;
}


create_instance :: (window_handle: * void, width: s32, height: s32) -> Instance	 {
	instance: Instance;
	
	app_info: VkApplicationInfo;
	app_info.pApplicationName = "Hello Triangle";
	app_info.applicationVersion = VK_MAKE_VERSION(1, 0, 0);
	app_info.pEngineName = "No Engine";
	app_info.engineVersion = VK_MAKE_VERSION(1, 0, 0);
	app_info.apiVersion = VK_API_VERSION_1_3;

	instance_info: VkInstanceCreateInfo;
	instance_info.pApplicationInfo = *app_info;

	extensions := get_extensions();
	instance_info.enabledExtensionCount = xx extensions.count;
	instance_info.ppEnabledExtensionNames = extensions.data;
	
	#if BUILD_TYPE != .RELEASE{
		//TODO MAYBE CHECK FOR SUPPORT
		validation_layers: [] *u8 = .[
		"VK_LAYER_LUNARG_monitor", "VK_LAYER_KHRONOS_validation"
		]; 

		instance_info.enabledLayerCount = xx validation_layers.count;
		instance_info.ppEnabledLayerNames = validation_layers.data;

		messenger_info: VkDebugUtilsMessengerCreateInfoEXT;
		messenger_info.messageSeverity = .VERBOSE_BIT_EXT | .WARNING_BIT_EXT | .ERROR_BIT_EXT;
		messenger_info.messageType = .GENERAL_BIT_EXT | .VALIDATION_BIT_EXT | .PERFORMANCE_BIT_EXT;
	
		debug_callback :: (message_severity: VkDebugUtilsMessageSeverityFlagBitsEXT,
			message_type: VkDebugUtilsMessageTypeFlagsEXT,
			callback_data: *VkDebugUtilsMessengerCallbackDataEXT,
			user_data: *void
		) -> VkBool32 #c_call{
			push_context,defer_pop cast(*#Context, user_data).*;

			if message_severity == .ERROR_BIT_EXT {
				log_error("[Vulkan]:  %", to_string(callback_data.pMessage));
				//assert(false, "Read error message above");
			}else{
				log("[Vulkan]:	%", to_string(callback_data.pMessage));
			}
			return VK_FALSE;
			
		}
		

	
		messenger_info.pfnUserCallback = debug_callback;
		messenger_info.pUserData = *context;

		instance_info.pNext = *messenger_info;
	}

	vk_assert(vkCreateInstance(*instance_info, null, *instance.handle));

	#if BUILD_TYPE != .RELEASE{
		get_instance_proc_add(instance.handle, "vkCreateDebugUtilsMessengerEXT");
		vk_assert(vkCreateDebugUtilsMessengerEXT(instance.handle, *messenger_info, null, *instance.debug_messenger));
	}

	create_surface(*instance, window_handle);
	
	device_extensions: []*u8 = .[
		VK_KHR_SWAPCHAIN_EXTENSION_NAME
	];

	device_count: u32;
	vkEnumeratePhysicalDevices(instance.handle, *device_count, null);

	
	devices: [..] VkPhysicalDevice;
	array_resize(*devices, device_count);
	
	vkEnumeratePhysicalDevices(instance.handle, *device_count, devices.data);
	for physical_device : devices{
		device_properties: VkPhysicalDeviceProperties;
		vkGetPhysicalDeviceProperties(physical_device, *device_properties);
		if device_properties.apiVersion < VK_API_VERSION_1_3 then continue;
		
		device_features: VkPhysicalDeviceFeatures;
		vkGetPhysicalDeviceFeatures(physical_device, *device_features);
		
		extension_count: u32;
		vkEnumerateDeviceExtensionProperties(physical_device, null, *extension_count, null);
		available_extensions := array_allocate(extension_count, VkExtensionProperties);
		vkEnumerateDeviceExtensionProperties(physical_device, null, *extension_count, available_extensions.data);
		
		req_ext := device_extensions.count;
		for extension : available_extensions {
			for j : 0..device_extensions.count - 1 {
				if to_string(*extension.extensionName[0]) == to_string(device_extensions[j]) {
					req_ext -= 1;
				}
			}
		
			if !req_ext then break;
		}
		
		assert(!req_ext, "Not all required extensions are supported");
		
		
		families: [Device_Queue.COUNT] u32;
		for * families{
			 it.* = U32_MAX;
		}
		
		queue_family_count: u32;
		vkGetPhysicalDeviceQueueFamilyProperties(physical_device, *queue_family_count, null);
		queue_families := array_allocate(queue_family_count, VkQueueFamilyProperties);
		vkGetPhysicalDeviceQueueFamilyProperties(physical_device, *queue_family_count, queue_families.data);
		
		for family, family_index : queue_families{
			extension_count: u32;
			vkEnumerateDeviceExtensionProperties(physical_device, null, *extension_count, nu\ll);
			
			available_extensions := array_allocate(extension_count, VkExtensionProperties);
			vkEnumerateDeviceExtensionProperties(physical_device, null, *extension_count, available_extensions.data);
			
			req_ext := device_extensions.count;
			for extension : available_extensions {
				for j : 0..device_extensions.count - 1 {
					if(to_string(*extension.extensionName[0]) == to_string(device_extensions[j])){
						req_ext -= 1;
					}
				}
				
				if(!req_ext) then break;
			}

			
			assert(!req_ext, "Not all device extensions are supported");
			
			if family.queueFlags & .GRAPHICS_BIT {
				families[Device_Queue.GRAPHIC_PRESENT] = xx family_index;
			}
			
			present_support: VkBool32 = 0;
			vkGetPhysicalDeviceSurfaceSupportKHR(physical_device, xx family_index, instance.surface.handle, *present_support);
			
			is_complete := true;
			for families {
				is_complete &= (it != U32_MAX);
			}
			
			if is_complete then break;
		}

		
		is_complete := true;
		for families {
			is_complete &= (it != U32_MAX);
		}
		
		if ( device_features.geometryShader && is_complete) {
			instance.physical_device.handle = physical_device;
			memcpy(instance.physical_device.queue_families.data, families.data, size_of(type_of(families)));
			break;
		}
	}


	vkGetPhysicalDeviceSurfaceCapabilitiesKHR(instance.physical_device.handle, instance.surface.handle, *instance.surface.capabilities);

	format_count: u32;
	vkGetPhysicalDeviceSurfaceFormatsKHR(instance.physical_device.handle, instance.surface.handle, *format_count, null);
	array_resize(*instance.surface.formats, format_count);
	vkGetPhysicalDeviceSurfaceFormatsKHR(instance.physical_device.handle, instance.surface.handle, *format_count, instance.surface.formats.data);
	
	present_mode_count: u32;
	vkGetPhysicalDeviceSurfacePresentModesKHR(instance.physical_device.handle, instance.surface.handle, *present_mode_count, null);
	array_resize(*instance.surface.present_modes, present_mode_count);
	vkGetPhysicalDeviceSurfacePresentModesKHR(instance.physical_device.handle, instance.surface.handle, *present_mode_count, instance.surface.present_modes.data);
	
	return instance; 
}
	

destroy_instance :: (instance: *Instance){
	assert(xx *instance.handle, "Istance is 0x00");
	vkDestroySurfaceKHR(instance.handle, instance.surface.handle, null);
	#if BUILD_TYPE != .RELEASE{
		vkDestroyDebugUtilsMessengerEXT: PFN_vkDestroyDebugUtilsMessengerEXT = xx vkGetInstanceProcAddr(instance.handle, "vkDestroyDebugUtilsMessengerEXT");
		vkDestroyDebugUtilsMessengerEXT(instance.handle, instance.debug_messenger, null);
	}
	vkDestroyInstance(instance.handle, null);
}

create_device :: (physical_device: *Physical_Device) -> Device{
	device : Device;
	
	device.physical_device = physical_device;
	
	queue_priority := 1.0;

	distinct_queues: [..] u32;
	for queue: physical_device.queue_families {
		found:= false;
		for distinct_queue: distinct_queues {
			if distinct_queue == queue then found = true;
		}
		if !found then array_add(*distinct_queues, queue);
	}

	queue_create_infos: [..] VkDeviceQueueCreateInfo;
	for distinct_queues {
		queue_create_info: VkDeviceQueueCreateInfo;
		queue_create_info.queueFamilyIndex = it;
		queue_create_info.queueCount = 1;
		queue_create_info.pQueuePriorities = *queue_priority;
		array_add(*queue_create_infos, queue_create_info);
	}
	

	device_create_info: VkDeviceCreateInfo;
	device_create_info.pQueueCreateInfos = queue_create_infos.data;
	device_create_info.queueCreateInfoCount = xx queue_create_infos.count;

	device_features: VkPhysicalDeviceFeatures2;

	features13: VkPhysicalDeviceVulkan13Features;
	features13.dynamicRendering = 1;
	features13.synchronization2 = 1;

	features12: VkPhysicalDeviceVulkan12Features;
	features12.pNext = *features13;
	features12.bufferDeviceAddress = 1;
	features12.descriptorIndexing = 1;

	device_features.pNext = *features12;
	
	vkGetPhysicalDeviceFeatures2(physical_device, *device_features);
	
	device_create_info.pNext = *device_features;

	device_extensions: [] *u8 = .[
		VK_KHR_SWAPCHAIN_EXTENSION_NAME, VK_KHR_DYNAMIC_RENDERING_EXTENSION_NAME, VK_KHR_SYNCHRONIZATION_2_EXTENSION_NAME, VK_KHR_BUFFER_DEVICE_ADDRESS_EXTENSION_NAME, VK_EXT_DESCRIPTOR_INDEXING_EXTENSION_NAME, VK_EXT_SWAPCHAIN_MAINTENANCE_1_EXTENSION_NAME
	];
	
	device_create_info.ppEnabledExtensionNames = device_extensions.data;
	device_create_info.enabledExtensionCount = xx device_extensions.count;
	
	vk_assert(vkCreateDevice(physical_device.handle, *device_create_info, null, *device.handle));

	distinct_queue: VkQueue;
	for distinct_queues {
		vkGetDeviceQueue(device.handle, physical_device.queue_families[Device_Queue.GRAPHIC_PRESENT], 0, *distinct_queue);
		for queue, type: physical_device.queue_families {
			if it == queue {
				device.queues[type] = distinct_queue;
			}
		}
	}
	
	return device;
}

destroy_device :: (device: *Device){
	vkDeviceWaitIdle(device);
	vkDestroyDevice(device, null);
}


create_swapchain :: (device: * Device, surface: * Surface, present_mode: Swap_Chain_Present_Mode, width: s32, height: s32, old_handle: VkSwapchainKHR = VK_NULL_HANDLE) -> Swapchain {
	
	swapchain: Swapchain;
	swapchain.device = device;
	swapchain.surface =surface;
	
	swapchain.surface_format = .{.B8G8R8A8_SRGB, .COLOR_SPACE_SRGB_NONLINEAR_KHR};
	swapchain.present_mode = xx present_mode;
	swapchain.extent = .{xx width, xx height};

	image_count := ifx (!surface.capabilities.maxImageCount) then surface.capabilities.minImageCount + 1 else clamp_hi(surface.capabilities.minImageCount + 1, surface.capabilities.maxImageCount);
	
	swapchain_create_info: VkSwapchainCreateInfoKHR;
	swapchain_create_info.surface = surface.handle;
	swapchain_create_info.minImageCount = image_count;
	swapchain_create_info.imageFormat = swapchain.surface_format.format;
	swapchain_create_info.imageColorSpace = swapchain.surface_format.colorSpace;
	swapchain_create_info.imageExtent = swapchain.extent;
	swapchain_create_info.imageArrayLayers = 1;
	swapchain_create_info.imageUsage = .COLOR_ATTACHMENT_BIT | .TRANSFER_DST_BIT;

	swapchain_create_info.imageSharingMode = .EXCLUSIVE;
	swapchain_create_info.queueFamilyIndexCount = 0;
	swapchain_create_info.pQueueFamilyIndices = null;
	swapchain_create_info.preTransform = surface.capabilities.currentTransform;
	swapchain_create_info.compositeAlpha = .OPAQUE_BIT_KHR;
	swapchain_create_info.presentMode = xx present_mode; 
	swapchain_create_info.clipped = VK_TRUE;
	swapchain_create_info.oldSwapchain = old_handle;

	// // MIN_BIT_EXT            :: 0x1;
    // // MAX_BIT_EXT            :: 0x2;
    // // CENTERED_BIT_EXT       :: 0x4;
	//     ONE_TO_ONE_BIT_EXT           :: 0x1;
    // ASPECT_RATIO_STRETCH_BIT_EXT :: 0x2;
    // STRETCH_BIT_EXT              :: 0x4;
    // FLAG_BITS_MAX_ENUM_EXT       :: 0x7fffffff;

	scaling :VkSwapchainPresentScalingCreateInfoEXT;
	scaling.scalingBehavior = .STRETCH_BIT_EXT;
	scaling.presentGravityX = .MIN_BIT_EXT;
	scaling.presentGravityY = .MIN_BIT_EXT;
	swapchain_create_info.pNext = *scaling;
	
	vk_assert(vkCreateSwapchainKHR(device.handle, *swapchain_create_info, null, *swapchain.handle));
	
	array_resize(*swapchain.images, image_count);
	raw_images := array_allocate(image_count, VkImage);
	vkGetSwapchainImagesKHR(device.handle, swapchain.handle, *image_count, raw_images.data);

	for raw_images{
		swapchain.images[it_index].handle = it;
		swapchain.images[it_index].layout = .UNDEFINED;
		swapchain.images[it_index].format = .B8G8R8A8_SRGB;
		swapchain.images[it_index].extent = .{xx width, xx height, 1};
	}

	array_free(raw_images);
	return swapchain;
}



destroy_swapchain :: (swapchain: *Swapchain){
	//vkDeviceWaitIdle(swapchain.device);
	vkDestroySwapchainKHR(swapchain.device, swapchain, null);
	array_free(swapchain.images);
}

acquire_image_from_swapchain :: (swapchain: Swapchain, semaphore: GPU_Semaphore, fence: Fence = .{}, timeout: u64 = U64_MAX) -> *Image, u32, bool{
	index: u32;
	e := vkAcquireNextImageKHR(swapchain.device, swapchain, timeout, semaphore, fence, *index);
	if e == VkResult.ERROR_OUT_OF_DATE_KHR return null, U32_MAX, true;
	return *swapchain.images[index], index, false;
}

present_queue_to_swapchain :: (swapchain: Swapchain, index: u32 /*temp*/, semaphore: *GPU_Semaphore = null){	
	present_info: VkPresentInfoKHR;
	present_info.pSwapchains = *swapchain.handle;
	present_info.swapchainCount = 1;

	if semaphore{
		present_info.pWaitSemaphores = *semaphore.handle;
		present_info.waitSemaphoreCount = 1;
	}

	present_info.pImageIndices = *index;

	vkQueuePresentKHR(swapchain.device.queues[Device_Queue.GRAPHIC_PRESENT], *present_info);
}

 
