ARENA_HEADER_MAX_SIZE :: size_of(Arena);
ARENA_DEFAULT_ALIGNMENT :: (2* size_of(*void));

to_kilobytes :: (amt) => (cast(u64, amt) << 10);
to_megabytes :: (amt) => (cast(u64, amt) << 20);
to_gigabytes :: (amt) => (cast(u64, amt) << 30);

align_pow2 :: (x: u64, b: u64) -> u64{
	return (((x) + cast(u64, (b) - 1)) & (~((b) - 1)));
}

PAGE_SIZE :: 4096; //TODO: comptime insert page size;

Arena_Options :: enum_flags {
	NONE;
	NO_CHAIN;
}

Arena :: struct	 {
	options: Arena_Options = .NONE;
	previous: *Arena;
	current:  *Arena ;
	commit: u64;
	reserve: u64;
	base: u64;
	position: u64;
}


arena_alloc :: (base: *void = null, commit: u64 = 65536, reserve: u64  = 67108864, options: Arena_Options = .NONE) -> *Arena{
	reserve_size := align_pow2(reserve, PAGE_SIZE);
	commit_size	 := align_pow2(commit, PAGE_SIZE);
	
	if(!base){
		base = platform_mem_reserve(reserve_size);
		platform_mem_commit(base, commit_size);
	}else{
		assert(commit_size == reserve_size);
	}

	arena := cast(*Arena, base);
	arena.options = options;
	arena.previous = null;
	arena.current = arena;
	arena.commit = commit_size;
	arena.reserve = reserve_size;
	arena.base = 0;
	arena.position = ARENA_HEADER_MAX_SIZE;
	
	return arena;
}

arena_push_no_zero :: (arena: *Arena, size: u64, alignment: u64	 = ARENA_DEFAULT_ALIGNMENT) -> *void{
	current := arena.current;
	pos_pre := align_pow2(current.position, alignment);
	pos_post := pos_pre + size;
  
	if(current.reserve < pos_post && !(current.options == .NO_CHAIN)){
		reserve_size := current.reserve;
		commit_size := current.commit;
		if(size + ARENA_HEADER_MAX_SIZE > reserve_size)
		{
			reserve_size = align_pow2(size + ARENA_HEADER_MAX_SIZE, alignment);
			commit_size = align_pow2(size + ARENA_HEADER_MAX_SIZE, alignment);
		}
		block := arena_alloc(null, commit_size, reserve_size, current.options);

	  
		block.base = current.base + current.reserve;
		block.previous = current;
		arena.current = block;
		current = block;
	  
		pos_pre = align_pow2(current.position, alignment);
		pos_post = pos_pre + size;
	}
  
	if(current.commit < pos_post)
	{
		commit_post_aligned := pos_post + current.commit - 1;
		commit_post_aligned -= commit_post_aligned % current.commit;
		commit_post_clamped := clamp_hi(commit_post_aligned, current.reserve);
		commit_size := commit_post_clamped - current.commit;
		commit_ptr := cast(*u8, current) + current.commit;
		platform_mem_commit(commit_ptr, commit_size);
		current.commit = commit_post_clamped;
	}
  
	result := null;
	if(current.commit >= pos_post)
	{
		result = cast(*u8, current) + pos_pre;
		current.position = pos_post;
	}
  

	return result;
}

arena_push :: (arena: *Arena, size: u64, allignment: u64 = ARENA_DEFAULT_ALIGNMENT) -> *void{
	ptr := arena_push_no_zero(arena, size);
	memset(ptr, 0, xx size);
	return ptr;
}

arena_push :: (arena: *Arena, $type: Type, count: u64 = 1, allignment: u64 = ARENA_DEFAULT_ALIGNMENT) -> *void{
	size := size_of(type) * count;
	ptr := arena_push_no_zero(arena, size);
	memset(ptr, 0, xx size);
	return ptr;
}

arena_release :: (arena: *Arena) {
	current := arena.current;
	prev: *Arena ;
	while current != null {
		prev = current.previous;
		platform_mem_release(current, current.reserve);
		current = prev;
	}
}

arena_pos :: (arena: *Arena) -> u64{ return arena.current.base + arena.current.position;}

arena_pop_to :: (arena: *Arena, position: u64){
	current := arena.current;
	clamped_pos := clamp_lo(position, ARENA_HEADER_MAX_SIZE);

	prev: *Arena;
	while current.base >= clamped_pos{
		prev = current.previous;
		platform_mem_release(current, current.reserve);
		current = prev;
	}
	
	new_pos := clamped_pos - current.base;
	assert(new_pos <= current.position);
	current.position = position;
}

arena_pop :: (arena: *Arena, amt: u64) {
	pos_old := arena_pos(arena);
	pos_new := pos_old;
	if(amt < pos_old)
		{
			pos_new = pos_old - amt;
		}
	arena_pop_to(arena, pos_new);
}

arena_clear :: (arena: *Arena){
	arena_pop_to(arena, 0);
}
