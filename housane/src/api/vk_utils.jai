clamp_hi :: inline (val: $T, max: T) -> T { return clamp(val, val, max); }

vk_assert :: val => assert(val == .SUCCESS);

get_instance_proc_add :: (inst: VkInstance, entry: string) #expand {
	#insert #run tprint("`% : PFN_% = xx vkGetInstanceProcAddr(inst, \"%\");", entry, entry, entry);
}


NULL_HANDLE :: VK_NULL_HANDLE;
