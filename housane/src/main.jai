#import "Basic"()(MEMORY_DEBUGGER = BUILD_TYPE != .RELEASE, ENABLE_ASSERT = BUILD_TYPE != .RELEASE);

#import "Math";

#import "Debug";
#import "File";
#import "Print_Color";

#load "core/entry_point.jai";
#load "core/window_and_input.jai";

#import "Vulkan";
#import "Vulkan_Memory_Allocator";

#load "api/vk_utils.jai";
#load "api/vk_init.jai";

#load "api/vk_commands.jai";

#load "renderer.jai";

nlogger :: (message: string, data: *void, info: Log_Info)
{
	#if BUILD_TYPE == .RELEASE then return;
	if info.common_flags == .VERBOSE_ONLY && context.log_level != .VERBOSE then return;
	if info.common_flags == .VERY_VERBOSE_ONLY && context.log_level != .VERY_VERBOSE then return;

	color: Console_Color = .WHITE;
	if info.common_flags == .ERROR then color = .RED;
	if info.common_flags == .WARNING then color = .YELLOW;

		
	time := to_calendar(current_time_consensus());
	with_console_color(color, write_string(tprint("[%:%:%]", time.hour, formatInt(time.minute, minimum_digits = 2), time.second, message)));
	
	if message[0] != #char "[" then with_console_color(color, write_string("[Runtime]: "));
	with_console_color(color, write_string(tprint("%\n", message)));
}
 
main :: () {
	context.logger = nlogger;
	window := create_window("Vulkan", 800, 600);
	defer destroy_window(window);

	
	render_init(window);
	
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
	
array_allocate :: NewArray;
