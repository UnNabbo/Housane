
platform_mem_reserve :: (size: u64) -> *void{
	return VirtualAlloc(null, size, MEM_RESERVE, PAGE_READWRITE);
}

platform_mem_commit :: (ptr: *void, size: u64) -> *void{
	return VirtualAlloc(ptr, size, MEM_COMMIT, PAGE_READWRITE);
}

platform_mem_release :: (ptr: *void, size: u64){
	VirtualFree(ptr, 0, MEM_RELEASE);
}
