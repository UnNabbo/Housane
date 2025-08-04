


#if OS == .WINDOWS {
	 platform_mem_reserve :: (size: u64) -> *void{
		return VirtualAlloc(null, size, MEM_RESERVE, PAGE_READWRITE);
	}

	platform_mem_commit :: (ptr: *void, size: u64) -> *void{
		return VirtualAlloc(ptr, size, MEM_COMMIT, PAGE_READWRITE);
	}

	platform_mem_release :: (ptr: *void, size: u64){
		VirtualFree(ptr, 0, MEM_RELEASE);
	}
	
} else #if OS == .LINUX {
	#import "POSIX";
	
	platform_mem_reserve :: (size: u64) -> *void {
		return mmap(null, size, PROT_NONE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
	}

	platform_mem_commit :: (ptr: *void, size: u64) -> *void {
		if mprotect(ptr, size, PROT_READ | PROT_WRITE) == 0 {
			return ptr;
		}
		return null;
	}

	platform_mem_release :: (ptr: *void, size: u64) {
		munmap(ptr, size);
	}

} else {
	#assert(false);
}
