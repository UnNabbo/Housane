#import "Basic";
#import "Compiler";
#import "File";
#import "File_Utilities";
#import "Process";
#import "Metaprogram_Plugins";

println :: inline (Args: ..Any) { print("%\n", ..Args); }

plugins: [..] *Metaprogram_Plugin;

build :: () {
	set_working_directory(#filepath);
    defer set_build_options_dc(.{do_output=false});
	options := get_build_options();
	options.output_executable_name = "Vulkan";
	options.text_output_flags = 0;
	
	build_path := "out/debug";
	src_path := "housane/src";
	options.entry_point_name = "entry_point";
	debug := true;
	run_debugger := false;

	plugin_start_index: s64;
	
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
        }

		if it[0] == #char "+" {
            plugin_start_index = it_index;
            break;
        }else{
			compiler_report(tprint("Command-line argument #%, '%', is invalid. Valid options are: 'debug', 'release', 'attach_debugger'.\n", it_index + 1, it));
		}
    }

	make_directory_if_it_does_not_exist(build_path);
	options.output_path = build_path;
	
	workspace := compiler_create_workspace(options.output_executable_name);
	set_build_options(options, workspace);

	plugins_to_create: [..] Plugin_To_Create;

    if plugin_start_index >= 0 {
        success:, plugins_to_create = parse_plugin_arguments(options.compile_time_command_line, plugin_start_index);
        if !success then exit(1);
    }
	
    init_plugins(plugins_to_create, *plugins, workspace);
    assert(plugins.count == plugins_to_create.count);

	all_success := true;
    assert(plugins.count == plugins_to_create.count);
    for p: plugins {
        c := *plugins_to_create[it_index];
        if p.init {
            success := p.init(p, c.options);
            all_success &&= success;
        } else if c.options {
            log_error("Plugin '%' takes no options, but these options were given: %\n", c.name, c.options);
        }
    }

    if !all_success {
        log_error("A plugin init() failed. Exiting.\n");
        exit(0);
    }

	intercept_flags: Intercept_Flags;
	
	for plugins if it.before_intercept then it.before_intercept(it, *intercept_flags);
	
	compiler_begin_intercept(workspace, intercept_flags);

	for plugins if it.add_source then it.add_source(it);

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

		for plugins if it.message it.message(it, message);
		
        if message.kind == {
			case .COMPLETE;{
                complete_message := cast(*Message_Complete) message;
                if complete_message.error_code == .COMPILATION_FAILED then failed = true;
				break;
			}
		}
	}
	
	compiler_end_intercept(workspace);

	for plugins if it.finish   it.finish  (it);
    for plugins if it.shutdown it.shutdown(it);
	
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
 
#run build();

