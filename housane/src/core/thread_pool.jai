
Work :: struct{

}

Async_Deque :: struct($T: Type){
	buffer: [..] T;
	tail: s32 = 0;
	head: s32 = 0;
	count: s32 = 0;
}

deque_add :: (queue : *Async_Deque($T), data: T){
	tail := queue.tail;
	while true{
		if tail != queue.tail continue;
		queue.tail += 1;
		queue.count += 1;
		if queue.tail >= queue.count {
			array_add(*queue.buffer, data);
		}else{
			queue.buffer[tail] = data;
		}
		//print("%\n", queue.buffer.count);
		return;
	}
}

deque_pop_back :: (queue : *Async_Deque($T)) -> T{
	head, tail := queue.head, queue.tail;
	assert(head + 1 <= tail);
	while true{
		if (head != queue.head) || (tail != queue.tail) || (head < queue.buffer.count) continue;
		queue.head += 1;
		queue.count -= 1;
		return queue.buffer[head];
	}
}

deque_pop_front :: (queue : *Async_Deque($T)) -> T{
	head, tail := queue.head, queue.tail;
	assert(tail >= head);
	while true{
		if (head != queue.head) || (tail != queue.tail) || (tail < queue.buffer.count) continue;
		queue.tail -= 1;
		queue.count -= 1;
		return queue.buffer[tail];
	}
}

Worker_Thread :: struct{
	#as thread: Thread;
	work: Async_Deque(Work);
}

Thread_Pool :: struct{
	workers: [] Worker_Thread;
	work: Async_Deque(Work);
	
	should_exit: bool = false;
}

get_work :: (pool: *Thread_Pool, worker: *Worker_Thread){
	if pool.work.count {
		deque_add(*worker.work, deque_pop_back(*pool.work));
	}
	//TODO random stealing.
}

add_work :: (pool: *Thread_Pool){
	deque_add(*pool.work, .{});
}

thread_pool_proc :: (thread: *Thread) -> s64{
	using pool := cast(*Thread_Pool, thread.data);
	worker := *workers[thread.index - 1];
	while !should_exit{
		if !worker.work.count {
			get_work(pool, worker);
		}
		while worker.work.count{
			work := deque_pop_front(*worker.work);
			print("thread % got work\n", thread.index);
		}
	}
	
	return 0;
}

init_thread_pool :: (pool: *Thread_Pool, thread_count: s32 = SYTEM_THREAD_COUNT - 1) -> Thread_Pool {
	assert(thread_count <= SYTEM_THREAD_COUNT, "%", thread_count);
	
	pool.workers = array_allocate(thread_count, Worker_Thread);
	log("Starting % threads", thread_count);
	for * pool.workers{
		it.thread.data = pool;
		thread_init(*it.thread, thread_pool_proc);
		log("Thread % was initialized", it_index + 1);
	}
	
	return pool;
}

start_thread_pool :: (pool: *Thread_Pool){
	for * pool.workers{
		thread_start(*it.thread);
	}
}
