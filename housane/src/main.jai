#import "Basic"()(MEMORY_DEBUGGER = BUILD_TYPE != .RELEASE, ENABLE_ASSERT = BUILD_TYPE != .RELEASE);

#import "Math";

#import "System";
#import "String";
#import "Debug";
#import "File";
#import "Print_Color";

#import "Thread";
#import "Atomics";

#import "jai-sdl3";
#import "cgltf";

#import "Vulkan";
#import "Vulkan_Memory_Allocator";

#load "core/basic.jai";
//#load "core/thread_pool.jai"; TODO: too lazy to currently make a lockless queue so i'm gonna use the std ones
#load "core/arena.jai";

#load "api/vk_codegen.jai";
#load "api/vk_utils.jai";
#load "api/vk_memory.jai";
#load "api/vk_init.jai";
#load "api/vk_shader.jai";
#load "api/vk_pipeline.jai";
#load "api/vk_descriptors.jai";

#load "api/vk_commands.jai";
#load "api/vk_sync.jai";

#load "mesh_loader.jai";
#load "renderer.jai";

nlogger :: (message: string, data: *void, info: Log_Info) //TODO: solve console access race condition
{
	#if BUILD_TYPE == .RELEASE then return;
	if info.common_flags == .VERBOSE_ONLY && context.log_level != .VERBOSE then return; 
	if info.common_flags == .VERY_VERBOSE_ONLY && context.log_level != .VERY_VERBOSE then return;

		
	time := to_calendar(current_time_consensus());
	
	color: Console_Color = .GREEN;
	if info.common_flags == .ERROR then color = .RED;
	if info.common_flags == .WARNING then color = .YELLOW;
	

	with_console_color(color, write_string(tprint("[%:%:%]", time.hour, formatInt(time.minute, minimum_digits = 2), time.second, message)));
	
	if info.common_flags == .NONE then with_console_color(.GREEN, write_string("[INFO]"));
	if info.common_flags == .WARNING then with_console_color(.YELLOW, write_string("[WARN]"));
	if info.common_flags == .ERROR then with_console_color(.RED, write_string("[ERROR]"));

	with_console_color(.WHITE, write_string(tprint("[Thread: %]", context.thread_index)));
	if message[0] != #char "[" then with_console_color(.WHITE, write_string("[Runtime]: "));
	write_string(message);
	write_string("\n");
}

work_proc :: (group: *Thread_Group, thread: *Thread, work: *void)  -> Thread_Continue_Status{
	log("test");
	return .CONTINUE;
}

main :: () {
	context.logger = nlogger;
	pool : Thread_Group;
	init_thread_group(*pool, work_proc);
	start_thread_group(*pool);
	
	SDL_Init(SDL_INIT_VIDEO);
	window := SDL_CreateWindow("Housane", 800, 600, SDL_WINDOW_VULKAN | SDL_WINDOW_RESIZABLE);
	render_init(window);
	//NOTE: LET IT LEAK!!
	//defer destroy_window(window);
	//defer render_deinit();
	
	running := true;
    while (running) {
		event: SDL_Event ;
        while (SDL_PollEvent(*event)) {
            if cast(SDL_EventType, event.type) == {
				case .QUIT;
					running = false;
				case .WINDOW_RESIZED;
				    width  := event.window.data1;
                    height := event.window.data2;
					render_resize(width, height);
            }
		}
		render_next_frame();
	}

}
