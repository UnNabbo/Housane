#load "core/basic.jai";

#import "Vulkan";
#import "Vulkan_Memory_Allocator";

#load "api/vk_codegen.jai";
#load "api/vk_utils.jai";
#load "api/vk_memory.jai";
#load "api/vk_init.jai";
#load "api/vk_pipeline.jai";
#load "api/vk_descriptors.jai";

#load "api/vk_commands.jai";
#load "api/vk_sync.jai";

#load "renderer.jai";

nlogger :: (message: string, data: *void, info: Log_Info)
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

	if message[0] != #char "[" then with_console_color(.WHITE, write_string("[Runtime]: "));
	write_string(message);
	write_string("\n");
}
 
main :: () {
	context.logger = nlogger;
	window := create_window("Vulkan", 800, 600);
	render_init(window);
	//NOTE: LET IT LEAK!!
	//defer destroy_window(window);
	//defer render_deinit();
	
	while window.running{
		for event : fetch_window_events(window){
			if event.kind == {
				case .QUIT;
				window.running = false;
			}
		}
		
		render_next_frame();
	};

	
}
