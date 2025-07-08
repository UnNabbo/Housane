Window_Event_Kind :: enum u32 {  // If we set this to u8, our packing will stop matching C's.
    NONE;
	RESIZE;
	QUIT;
}

Window_Event :: struct{
    kind: Window_Event_Kind;

	Window_Event_Data :: union{
		struct{
			width, height: s32;
		}
		window: *Window;
	}

	using data: Window_Event_Data;
}

Window :: struct{
	title: string;
	width, height: s32;
	running: bool;
	
	handle : *void;
}

    window_events: [..] Window_Event;

Key_Code :: enum{
	DELETE :: 8;
	ENTER  :: 13;
	SHIFT  :: 16;
	CTRL   :: 17;
	ALT    :: 18;
	ESC    :: 27;
	SPACE  :: 32;
	LEFT   :: 37;
	UP     :: 38;
	RIGHT  :: 39;
	DOWN   :: 40;
	F1     :: 112;
	F2     :: 113;
	F3     :: 114;
	F4     :: 115;
	F5     :: 116;
	F6     :: 117;
	F7     :: 118;
	F8     :: 119;
	F9     :: 120;
	F10    :: 121;
	F11    :: 122;
	F12    :: 123;
}

create_window :: (window_name: string, width: s32, height: s32) -> *Window {
	window := new(Window);
	window.height = height;
	window.width = width;
	window.title = window_name;
	SetProcessDpiAwareness(PROCESS_DPI_AWARENESS.SYSTEM);
	
	wide_name := utf8_to_wide(window_name,, temp);
	
	wc: WNDCLASSEXW;
	wc.cbSize = size_of(WNDCLASSEXW);
	wc.lpfnWndProc   = xx window_proc;
	wc.hInstance     = GetModuleHandleW(null);
	wc.lpszClassName = wide_name;
	wc.hCursor       = LoadCursorW(null, cast(*s16, 32512));
	wc.hbrBackground = CreateSolidBrush((38 << 16) | (38 << 8) | 38);

	RegisterClassExW(*wc);

	// calculate the monitor size and adjust it in the middle of the screen
	monitor_width := GetSystemMetrics(0);
	monitor_height := GetSystemMetrics(1);
	x_pos := (monitor_width - width) / 2;
	y_pos := (monitor_height - height) / 2;

	rect := RECT.{x_pos, y_pos, width + x_pos, height + y_pos};
	AdjustWindowRectEx(*rect, WS_OVERLAPPEDWINDOW,xx false, 0);
	
	data: Threaded_Window_Create_Data;
    data.dwExStyle = 0;;
    data.lpClassName = wc.lpszClassName;
    data.lpWindowName = wide_name;
    data.dwStyle = WS_OVERLAPPEDWINDOW | WS_VISIBLE;
    data.X = rect.left;
    data.Y = rect.top;
    data.nWidth = rect.right - rect.left;
    data.nHeight = rect.bottom - rect.top;
    data.hInstance = wc.hInstance;

	proc_data := new(Window_Proc_Data);
	proc_data.context_ptr = *context;
	proc_data.window = window;
	
    data.lpParam = xx proc_data;

    window.handle = cast(*void, send_service_thread_message(CREATE_WINDOW, *data));
	window.running = true;

	return window;
}

destroy_window :: (window: *Window){
	send_service_thread_message(DESTROY_WINDOW, xx window.handle);
	free(window);
}

fetch_window_events :: (window: *Window) -> [] Window_Event {
	message: MSG;
	
	window_events.count = 0;

	reset_input_state();
	
	while PeekMessageW(*message, null, 0, 0, 1)
    {
		event: Window_Event;
		
        if message.message == {
			case WM_SIZE; {
				event.kind = .RESIZE;
				window.width,  event.width = xx (message.lParam & 0xFFFF);
				window.height, event.height = xx ((message.lParam >> 16) & 0xFFFF);
			}
			
			case WM_SETFOCUS;{
				event.window = xx message.lParam;
			}
			
            case WM_CLOSE; {
				event.kind = .QUIT;

                //send_service_thread_message(DESTROY_WINDOW, xx message.wParam);
            }

			case WM_SYSKEYDOWN; #through;
			case WM_KEYFIRST;{
				repeat := ((cast(s32, message.lParam)) & 0x40000000) != 0;
				if(message.wParam < 0xFF) then input.keyboard_states[message.wParam] = true;
			}

			case WM_SYSKEYUP; #through;
			case WM_KEYUP; {
				if(message.wParam < 0xFF) then input.keyboard_states[message.wParam] = false;
			}

			case WM_CHAR; {
				input.last_char = xx message.wParam;
			}

			case WM_MOUSEMOVE;{
				input.mouse_x = xx(message.lParam & 0xffff);
				input.mouse_y = xx((message.lParam >> 16) & 0xffff);
			}

			case WM_LBUTTONDOWN;{
				input.button_states[0] = true;
			}

			case WM_LBUTTONUP;{
				input.button_states[0] = false;
			}
			
			case WM_RBUTTONDOWN;{
				input.button_states[1] = true;
			}
			
			case WM_RBUTTONUP;{
				input.button_states[1] = false;
			}

			case WM_MOUSEWHEEL;{
				input.scroll_wheal_delta = xx((message.wParam >> 16) / 120);
			}
        }

		if event.kind != .NONE then array_add(*window_events, event);
    }

	return window_events;
}

reset_input_state :: () {
	memcpy(input.button_states_old.data, input.button_states.data, size_of(type_of(input.button_states)));
	memcpy(input.keyboard_states_old.data, input.keyboard_states.data, size_of(type_of(input.keyboard_states)));
	input.scroll_wheal_delta = 0;
	input.last_char_old = input.last_char;
	input.last_char = 0;
}

reset_input :: () {
	memset(*input, 0, size_of(Input_Data));
}

mouse_is_pressed  :: (key: int) -> bool { return  input.button_states[key] && !input.button_states_old[key]; }
mouse_is_down     :: (key: int) -> bool { return  input.button_states[key]; }
mouse_is_released :: (key: int) -> bool { return !input.button_states[key] &&  input.button_states_old[key]; }
mouse_is_up       :: (key: int) -> bool { return !input.button_states[key]; }

key_is_pressed  :: (key: int) -> bool { return  input.keyboard_states[key] && !input.keyboard_states_old[key]; }
key_is_down     :: (key: int) -> bool { return  input.keyboard_states[key]; }
key_is_released :: (key: int) -> bool { return !input.keyboard_states[key] &&  input.keyboard_states_old[key]; }

mouse_get_position :: () -> int, int {return input.mouse_x, input.mouse_y; }
keyboard_get_last_char :: () -> u8 {return input.last_char; }

#scope_file

input: Input_Data;

Input_Data :: struct{
	mouse_x: int;
	mouse_y: int;
	scroll_wheal_delta: int;

	last_char: u8;
	last_char_old: u8;

	button_states: [3]bool;
	button_states_old: [3]bool;

	keyboard_states: [0xFF]bool;
	keyboard_states_old: [0xFF]bool;
}

Window_Proc_Data :: struct{
	window: *Window;
	context_ptr: *#Context;
}

window_proc :: (hwnd: *void, msg: u32,  wparam: u64, lparam: u64) -> s64 #c_call {
	data := ifx msg != WM_CREATE then cast(*Window_Proc_Data, GetWindowLongPtrW(hwnd, -21)) else null;
	if msg == WM_CREATE{
		pCreate := cast(*CREATESTRUCTW, lparam);
		SetWindowLongPtrW(hwnd, -21, pCreate.lpCreateParams);
		data = pCreate.lpCreateParams;
	}

	result := 0;
	if data then push_context data.context_ptr{
		if msg == {
			case WM_CLOSE;{
				send_main_thread_message(msg, xx hwnd, lparam);
			}
			
			case WM_SETFOCUS;{
				send_main_thread_message(msg, wparam, xx data.window);
			}
			
			case WM_SIZE;        #through;
			
			case WM_KEYFIRST;    #through;
			
			case WM_SYSKEYUP;    #through;
			case WM_KEYUP;       #through;

			
			case WM_CHAR;        #through;
			
			case WM_MOUSEMOVE;   #through;
			
			case WM_LBUTTONDOWN; #through;
			case WM_LBUTTONUP;   #through;
			
			case WM_RBUTTONDOWN; #through;
			case WM_RBUTTONUP;   #through;
			
			case WM_MOUSEWHEEL; {
				send_main_thread_message(msg, wparam, lparam);
			}
			case;{
				result = DefWindowProcW(hwnd, msg, wparam, lparam);
			}
		}
	}else{
		result = DefWindowProcW(hwnd, msg, wparam, lparam);
	}

	return result;
}

//#load "win32.jai";
