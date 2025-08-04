#load "win32.jai";


service_window: *void;
main_thread_id: s32;

entry_point :: (){
	wide_name := utf8_to_wide("Service_Window",, temp);
	
	wc: WNDCLASSEXW;
	wc.cbSize = size_of(WNDCLASSEXW);
	wc.lpfnWndProc   = xx service_window_proc;
	wc.hInstance     = GetModuleHandleW(null);
	wc.lpszClassName = wide_name;
	wc.hCursor       = LoadCursorW(null, cast(*s16, 32512));
	wc.hbrBackground = CreateSolidBrush(0);
	RegisterClassExW(*wc);

	service_window = CreateWindowExW(0, wide_name, wide_name, 0, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, null, null, wc.hInstance, null);
	assert(xx service_window);


	Thread_Data :: struct{
		context_ptr: *#Context;
		proc: (); 
	}

	thread_porc :: (opaque_data: *void) #c_call{
		data := cast(*Thread_Data, opaque_data);
		push_context data.context_ptr{
			data.proc();
		}
	}
	
	data := new(Thread_Data);
	data.context_ptr = *context;
	data.proc = main;

	thread_handle := CreateThread(null, 0,xx thread_porc, data, 0, *main_thread_id);
	
	while true {
        message: MSG;
        GetMessageW(*message, null, 0, 0);
        TranslateMessage(*message);
        if((message.message == WM_CHAR) ||
           (message.message == WM_KEYDOWN) ||
           (message.message == WM_QUIT) ||
           (message.message == WM_SIZE))
        {
            send_main_thread_message(message);
        }
        else
        {
            DispatchMessageW(*message);
        }

		result := WaitForSingleObject(thread_handle, 0);
		if !result then return;
    }
}

CREATE_WINDOW :: (WM_USER + 0x1337);
DESTROY_WINDOW :: (WM_USER + 0x1338);

send_service_thread_message :: inline (message: u32, data: *void) -> *void{
	return xx SendMessageW(service_window, message, cast(u64, data), 0);
}

send_main_thread_message :: inline(message: MSG){
	PostThreadMessageW(xx main_thread_id, message.message, message.wParam, message.lParam);
}

send_main_thread_message :: inline(message: u32, wparam: u64, lparam: u64){
	PostThreadMessageW(xx main_thread_id, message, wparam, lparam);
}

Threaded_Window_Create_Data :: struct {
	dwExStyle: s32;
	lpClassName: *u16;
	lpWindowName: *u16;
	dwStyle: u32;
	X: s32;
	Y: s32;
	nWidth: s32;
	nHeight: s32;
	hWndParent: *void;
	hMenu: *void;
	hInstance: *void;
	lpParam: *void;
}


#scope_file

service_window_proc :: (hwnd: *void, msg: u32,  wparam: u64, lparam: u64) -> s64 #c_call {
	result : s64;
	if msg == {
		case CREATE_WINDOW;{
			data := cast(*Threaded_Window_Create_Data, wparam);
			result = cast(s64, CreateWindowExW(data.dwExStyle, data.lpClassName, data.lpWindowName, data.dwStyle, data.X, data.Y, data.nWidth, data.nHeight, data.hWndParent, data.hMenu, data.hInstance, data.lpParam));
		}

		case DESTROY_WINDOW;{
			DestroyWindow(xx wparam);
		}

		case;{
			result = DefWindowProcW(hwnd, msg, wparam, lparam);
		}
	}
	return result;
}

