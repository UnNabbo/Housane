#run build();

build :: () {
	set_working_directory(#filepath);
    defer set_build_options_dc(.{do_output=false});

	options := get_build_options();
	options.output_executable_name = "Vulkan";
	options.text_output_flags = 0;
	
	build_path := "out/debug";
	src_path := "vulkan/src";
	options.entry_point_name = "entry_point";
	debug := true;
	run_debugger := false;
	
	for options.compile_time_command_line {
        if it == {
		case "attach_debugger";
			run_debugger = true;
		#through;
		case "debug";
			println("Building in debug mode");
			options.backend = .X64;
			set_optimization(*options, .DEBUG);
		case "release";
			println("Building in release mode");
			build_path = "out/release";
			options.backend = .LLVM;
			set_optimization(*options, .VERY_OPTIMIZED);
	debug = false;
		case;
			compiler_report(tprint("Command-line argument #%, '%', is invalid. Valid options are: 'debug', 'release', 'attach_debugger'.\n", it_index + 1, it));
        }
    }

	make_directory_if_it_does_not_exist(build_path);
	options.output_path = build_path;
	
	workspace := compiler_create_workspace(options.output_executable_name);
	set_build_options(options, workspace);

	compiler_begin_intercept(workspace);

	//add_build_string("#load \"vulkan/src/core/entry_point.jai\";", workspace);
	
	add_build_string("Build_Type :: enum u8{DEBUG; OPTIMIZED; RELEASE; }", workspace);
	
	if debug {
		add_build_string("BUILD_TYPE :: Build_Type.DEBUG;", workspace);
	}else{
		add_build_string("BUILD_TYPE :: Build_Type.RELEASE;", workspace);
	}
	
	add_build_file(tprint("%/main.jai", src_path), workspace);

	failed := false;
    while true {
        message := compiler_wait_for_message();
        if message.kind == {
			case .COMPLETE;{
                complete_message := cast(*Message_Complete) message;
                if complete_message.error_code == .COMPILATION_FAILED then failed = true;
				break;
			}
		}
	}
	
	compiler_end_intercept(workspace);

	if !failed {
		copy_file("modules/Vulkan_Memory_Allocator/windows/Vulkan_Memory_Allocator.dll", tprint("%/Vulkan_Memory_Allocator.dll", options.output_path));
		
		exe_full_name := tprint("%/%.exe", options.output_path, options.output_executable_name);
		process: Process;
		if run_debugger{
			success := create_process(*process, "raddbg.exe", exe_full_name, kill_process_if_parent_exits = false);
		}else{
			for exe_full_name if it == #char "/" then exe_full_name[it_index] = #char "\\";
			success := create_process(*process, "wt", "-d", #filepath, "cmd", "/k", exe_full_name, "&", "exit", kill_process_if_parent_exits = false);
		}
	}
}
 
println :: inline (Args: ..Any) { print("%\n", ..Args); }
 

#import "Basic";
#import "Compiler";
#import "File";
#import "File_Utilities";
#import "Process";
