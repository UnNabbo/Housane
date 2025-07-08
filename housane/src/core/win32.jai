utf8_to_wide :: (utf8: string) -> (result_data: *u16, success: bool, result_length_in_bytes: s32) {
    if !utf8  return null, true, 0;
    query_num_chars := MultiByteToWideChar(54936, 0,utf8.data, cast(s32, utf8.count), null, 0);
    if query_num_chars <= 0 then return null, false, 0;
    
    name := "";
    name_u16s := cast(*u16) alloc((query_num_chars+1) * size_of(u16)); 
    result_num_chars := MultiByteToWideChar(54936, 0, utf8.data, cast(s32) utf8.count, name_u16s, query_num_chars);

    if !result_num_chars {
        free(name_u16s);
        return null, false, 0;
    }

    assert(result_num_chars <= query_num_chars);
    name_u16s[result_num_chars] = 0;
    return name_u16s, true, result_num_chars * 2;
}

LOWORD :: l => cast(u32, l & 0xffff);
HIWORD :: l => cast(u32, (cast(u64, l >> 16) & 0xffff));

user32   :: #system_library "user32";

CW_USEDEFAULT :: 0x80000000;

// Window messages:
WM_NULL ::0x0000;
WM_CREATE :: 0x0001;
WM_DESTROY :: 0x0002;
WM_MOVE :: 0x0003;

WM_SIZE                         :: 0x0005;
WM_SETFOCUS                     :: 0x0007;
WM_KILLFOCUS                    :: 0x0008;
WM_ENABLE                       :: 0x000A;
WM_SETREDRAW                    :: 0x000B;
WM_SETTEXT                      :: 0x000C;
WM_GETTEXT                      :: 0x000D;
WM_GETTEXTLENGTH                :: 0x000E;
WM_PAINT                        :: 0x000F;
WM_CLOSE                        :: 0x0010;
WM_QUERYENDSESSION              :: 0x0011;
WM_QUERYOPEN                    :: 0x0013;
WM_ENDSESSION                   :: 0x0016;
WM_QUIT                         :: 0x0012;
WM_ERASEBKGND                   :: 0x0014;
WM_SYSCOLORCHANGE               :: 0x0015;
WM_SHOWWINDOW                   :: 0x0018;
WM_WININICHANGE                 :: 0x001A;
WM_SETTINGCHANGE                :: WM_WININICHANGE;
WM_DEVMODECHANGE                :: 0x001B;
WM_ACTIVATEAPP                  :: 0x001C;
WM_FONTCHANGE                   :: 0x001D;
WM_TIMECHANGE                   :: 0x001E;
WM_CANCELMODE                   :: 0x001F;
WM_SETCURSOR                    :: 0x0020;
WM_MOUSEACTIVATE                :: 0x0021;
WM_CHILDACTIVATE                :: 0x0022;
WM_QUEUESYNC                    :: 0x0023;
WM_GETMINMAXINFO                :: 0x0024;

WM_NOTIFY                       :: 0x004E;
WM_INPUTLANGCHANGEREQUEST       :: 0x0050;
WM_INPUTLANGCHANGE              :: 0x0051;
WM_TCARD                        :: 0x0052;
WM_HELP                         :: 0x0053;
WM_USERCHANGED                  :: 0x0054;
WM_NOTIFYFORMAT                 :: 0x0055;
WM_CONTEXTMENU                  :: 0x007B;
WM_STYLECHANGING                :: 0x007C;
WM_STYLECHANGED                 :: 0x007D;
WM_DISPLAYCHANGE                :: 0x007E;
WM_GETICON                      :: 0x007F;
WM_SETICON                      :: 0x0080;
WM_NCCREATE                     :: 0x0081;
WM_NCDESTROY                    :: 0x0082;
WM_NCCALCSIZE                   :: 0x0083;
WM_NCHITTEST                    :: 0x0084;
WM_NCPAINT                      :: 0x0085;
WM_NCACTIVATE                   :: 0x0086;
WM_GETDLGCODE                   :: 0x0087;
WM_SYNCPAINT                    :: 0x0088;
WM_NCMOUSEMOVE                  :: 0x00A0;
WM_NCLBUTTONDOWN                :: 0x00A1;
WM_NCLBUTTONUP                  :: 0x00A2;
WM_NCLBUTTONDBLCLK              :: 0x00A3;
WM_NCRBUTTONDOWN                :: 0x00A4;
WM_NCRBUTTONUP                  :: 0x00A5;
WM_NCRBUTTONDBLCLK              :: 0x00A6;
WM_NCMBUTTONDOWN                :: 0x00A7;
WM_NCMBUTTONUP                  :: 0x00A8;
WM_NCMBUTTONDBLCLK              :: 0x00A9;
WM_NCXBUTTONDOWN                :: 0x00AB;
WM_NCXBUTTONUP                  :: 0x00AC;
WM_NCXBUTTONDBLCLK              :: 0x00AD;
WM_INPUT_DEVICE_CHANGE          :: 0x00FE;
WM_INPUT                        :: 0x00FF;
WM_KEYFIRST                     :: 0x0100;
WM_KEYDOWN                      :: 0x0100;
WM_KEYUP                        :: 0x0101;
WM_CHAR                         :: 0x0102;
WM_DEADCHAR                     :: 0x0103;
WM_SYSKEYDOWN                   :: 0x0104;
WM_SYSKEYUP                     :: 0x0105;
WM_SYSCHAR                      :: 0x0106;
WM_SYSDEADCHAR                  :: 0x0107;
WM_UNICHAR                      :: 0x0109;
WM_KEYLAST                      :: 0x0109;
UNICODE_NOCHAR                  :: 0xFFFF;
WM_IME_STARTCOMPOSITION         :: 0x010D;
WM_IME_ENDCOMPOSITION           :: 0x010E;
WM_IME_COMPOSITION              :: 0x010F;
WM_IME_KEYLAST                  :: 0x010F;
WM_INITDIALOG                   :: 0x0110;
WM_COMMAND                      :: 0x0111;
WM_SYSCOMMAND                   :: 0x0112;
WM_TIMER                        :: 0x0113;
WM_HSCROLL                      :: 0x0114;
WM_VSCROLL                      :: 0x0115;
WM_INITMENU                     :: 0x0116;
WM_INITMENUPOPUP                :: 0x0117;
WM_GESTURE                      :: 0x0119;
WM_GESTURENOTIFY                :: 0x011A;
WM_MENUSELECT                   :: 0x011F;
WM_MENUCHAR                     :: 0x0120;
WM_ENTERIDLE                    :: 0x0121;
WM_MENURBUTTONUP                :: 0x0122;
WM_MENUDRAG                     :: 0x0123;
WM_MENUGETOBJECT                :: 0x0124;
WM_UNINITMENUPOPUP              :: 0x0125;
WM_MENUCOMMAND                  :: 0x0126;
WM_CHANGEUISTATE                :: 0x0127;
WM_UPDATEUISTATE                :: 0x0128;
WM_QUERYUISTATE                 :: 0x0129;

WM_CTLCOLORMSGBOX               :: 0x0132;
WM_CTLCOLOREDIT                 :: 0x0133;
WM_CTLCOLORLISTBOX              :: 0x0134;
WM_CTLCOLORBTN                  :: 0x0135;
WM_CTLCOLORDLG                  :: 0x0136;
WM_CTLCOLORSCROLLBAR            :: 0x0137;
WM_CTLCOLORSTATIC               :: 0x0138;
MN_GETHMENU                     :: 0x01E1;
WM_MOUSEFIRST                   :: 0x0200;
WM_MOUSEMOVE                    :: 0x0200;
WM_LBUTTONDOWN                  :: 0x0201;
WM_LBUTTONUP                    :: 0x0202;
WM_LBUTTONDBLCLK                :: 0x0203;
WM_RBUTTONDOWN                  :: 0x0204;
WM_RBUTTONUP                    :: 0x0205;
WM_RBUTTONDBLCLK                :: 0x0206;
WM_MBUTTONDOWN                  :: 0x0207;
WM_MBUTTONUP                    :: 0x0208;
WM_MBUTTONDBLCLK                :: 0x0209;
WM_MOUSEWHEEL                   :: 0x020A;
WM_XBUTTONDOWN                  :: 0x020B;
WM_XBUTTONUP                    :: 0x020C;
WM_XBUTTONDBLCLK                :: 0x020D;
WM_MOUSEHWHEEL                  :: 0x020E;
WM_MOUSELAST                    :: 0x020E;

WM_SIZING                       :: 0x0214;
WM_EXITSIZEMOVE                 :: 0x0232;
WM_DROPFILES                    :: 0x0233;
WM_DPICHANGED                   :: 0x02E0;

WM_USER                         :: 0x0400;


// Window Class styles
CS_VREDRAW :: 0x0001;
CS_HREDRAW :: 0x0002;
CS_OWNDC   :: 0x0020;

// Window styles
WS_OVERLAPPED       :: 0x00000000;
WS_POPUP            :: 0x80000000;
WS_CHILD            :: 0x40000000;
WS_MINIMIZE         :: 0x20000000;
WS_VISIBLE          :: 0x10000000;
WS_DISABLED         :: 0x08000000;
WS_CLIPSIBLINGS     :: 0x04000000;
WS_CLIPCHILDREN     :: 0x02000000;
WS_MAXIMIZE         :: 0x01000000;
WS_CAPTION          :: 0x00C00000; // WS_BORDER | WS_DLGFRAME
WS_BORDER           :: 0x00800000;
WS_DLGFRAME         :: 0x00400000;
WS_VSCROLL          :: 0x00200000;
WS_HSCROLL          :: 0x00100000;
WS_SYSMENU          :: 0x00080000;
WS_THICKFRAME       :: 0x00040000;
WS_GROUP            :: 0x00020000;
WS_TABSTOP          :: 0x00010000;
WS_MINIMIZEBOX      :: 0x00020000;
WS_MAXIMIZEBOX      :: 0x00010000;
WS_SIZEBOX          :: WS_THICKFRAME;
WS_OVERLAPPEDWINDOW :: WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX;

// Window Ex styles
WS_EX_DLGMODALFRAME     :: 0x00000001;
WS_EX_NOPARENTNOTIFY    :: 0x00000004;
WS_EX_TOPMOST           :: 0x00000008;
WS_EX_ACCEPTFILES       :: 0x00000010;
WS_EX_TRANSPARENT       :: 0x00000020;
WS_EX_MDICHILD          :: 0x00000040;
WS_EX_TOOLWINDOW        :: 0x00000080;
WS_EX_WINDOWEDGE        :: 0x00000100;
WS_EX_CLIENTEDGE        :: 0x00000200;
WS_EX_CONTEXTHELP       :: 0x00000400;
WS_EX_RIGHT             :: 0x00001000;
WS_EX_LEFT              :: 0x00000000;
WS_EX_RTLREADING        :: 0x00002000;
WS_EX_LTRREADING        :: 0x00000000;
WS_EX_LEFTSCROLLBAR     :: 0x00004000;
WS_EX_RIGHTSCROLLBAR    :: 0x00000000;
WS_EX_CONTROLPARENT     :: 0x00010000;
WS_EX_STATICEDGE        :: 0x00020000;
WS_EX_APPWINDOW         :: 0x00040000;
WS_EX_OVERLAPPEDWINDOW  :: (WS_EX_WINDOWEDGE | WS_EX_CLIENTEDGE);
WS_EX_PALETTEWINDOW     :: (WS_EX_WINDOWEDGE | WS_EX_TOOLWINDOW | WS_EX_TOPMOST);
WS_EX_LAYERED           :: 0x00080000;
WS_EX_NOINHERITLAYOUT   :: 0x00100000; // Disable inheritence of mirroring by children
WS_EX_NOREDIRECTIONBITMAP :: 0x00200000;
WS_EX_LAYOUTRTL         :: 0x00400000; // Right to left mirroring
WS_EX_COMPOSITED        :: 0x02000000;
WS_EX_NOACTIVATE        :: 0x08000000;

CREATESTRUCTW :: struct {
	lpCreateParams: *void;
	hInstance: *void;
	hMenu: *void;
	hwndParent: *void;
	cy: s32;
	cx: s32;
	y: s32;
	x: s32;
	style: s32;
	lpszName: *u16;
	lpszClass: *u16;
	dwExStyle: *u32;
}

WNDCLASSEXW :: struct {
    cbSize: u32;
    style: u32;
    lpfnWndProc: *void; // WNDPROC
    cbClsExtra: s32;
    cbWndExtra: s32;
    hInstance: *void;
    hIcon: *void;
    hCursor: *void;
    hbrBackground: *void;
    lpszMenuName: *u16;
    lpszClassName: *u16;
    hIconSm: *void;
}

POINT :: struct {
    x, y: s32;
}

RECT :: struct {
    left, top, right, bottom: s32;
}

MSG :: struct {
    hwnd:     *void;
    message:  u32;
    wParam:   u64;
    lParam:   u64;
    time:     s32;
    pt:       POINT;
    lPrivate: s32;  // This is usually not documented, but sometimes it is. Including it here.
}

GetSystemMetrics :: (nIndex: s32) -> s32 #foreign user32;
LoadCursorW :: (hInstance: *void, lpCursorName: *s16) -> *void #foreign user32;
AdjustWindowRectEx :: (lpRect: *RECT, dwStyle: u32, bMenu: s32, dwExStyle: s32) -> s32 #foreign user32;
RegisterClassExW :: (lpwcx: *WNDCLASSEXW) -> s16 #foreign user32;
CreateWindowExW :: (dwExStyle: s32, lpClassName: *u16, lpWindowName: *u16, dwStyle: u32, x: s32, y: s32, nWidth: s32, nHeight: s32, hwndParent: *void, hMenu: *void, hInstance: *void, lpParam: *void) -> *void #foreign user32;
ShowWindow :: (hwnd: *void, nCmdShow: s32) -> s32 #foreign user32;
PeekMessageW :: (msg: *MSG, hwnd: *void, wMsgFilterMin: u32, wMsgFilterMax: u32, wRemoveMsg: u32) -> s32 #foreign user32;
GetMessageW :: (msg: *MSG, hwnd: *void, wMsgFilterMin: u32, wMsgFilterMax: u32) -> s32 #foreign user32;
TranslateMessage :: (msg: *MSG) -> s32 #foreign user32;
DispatchMessageW :: (msg: *MSG) -> s32 #foreign user32;
SetWindowLongPtrW :: (hwnd: *void, nIndex: s32, dwNewLong: *void) -> s64 #foreign user32;
GetWindowLongPtrW :: (hWnd: *void, nIndex: s32) -> s64 #foreign user32;
DefWindowProcW :: (hWnd: *void, Msg: u32, wParam: u64, lParam: u64) -> s64 #foreign user32;
PostMessageW ::(hWnd: *void, Msg: u32, wParam: u64, lParam: u64) -> s32 #foreign user32;
PostThreadMessageW ::(idThread: u32, Msg: u32, wParam: u64, lParam: u64) -> s32 #foreign user32;
SendMessageW :: (hWnd: *void, Msg: u32, wParam: u64, lParam: u64) -> s64 #foreign user32;
DestroyWindow :: (hWnd: *void) -> s32 #foreign user32;
GetClientRect       :: (hwnd: *void, rect: *RECT) -> s32 #foreign user32;
GetDC :: (hwnd: *void) -> *void #foreign user32;
ReleaseDC :: (hwnd: *void, hdc: *void) -> s32 #foreign user32;

kernel32  :: #system_library "kernel32";


GetLastError :: () -> u32 #foreign kernel32;

using Creation_Flags :: enum_flags u32 {
    DEBUG_PROCESS                    :: 0x00000001;
    DEBUG_ONLY_THIS_PROCESS          :: 0x00000002;
    CREATE_SUSPENDED                 :: 0x00000004;
    DETACHED_PROCESS                 :: 0x00000008;

    CREATE_NEW_CONSOLE               :: 0x00000010;
    NORMAL_PRIORITY_CLASS            :: 0x00000020;
    IDLE_PRIORITY_CLASS              :: 0x00000040;
    HIGH_PRIORITY_CLASS              :: 0x00000080;

    REALTIME_PRIORITY_CLASS          :: 0x00000100;
    CREATE_NEW_PROCESS_GROUP         :: 0x00000200;
    CREATE_UNICODE_ENVIRONMENT       :: 0x00000400;
    CREATE_SEPARATE_WOW_VDM          :: 0x00000800;

    CREATE_SHARED_WOW_VDM            :: 0x00001000;
    CREATE_FORCEDOS                  :: 0x00002000;
    BELOW_NORMAL_PRIORITY_CLASS      :: 0x00004000;
    ABOVE_NORMAL_PRIORITY_CLASS      :: 0x00008000;

    INHERIT_PARENT_AFFINITY          :: 0x00010000;
    INHERIT_CALLER_PRIORITY          :: 0x00020000;    // Deprecated
    CREATE_PROTECTED_PROCESS         :: 0x00040000;
    EXTENDED_STARTUPINFO_PRESENT     :: 0x00080000;

    PROCESS_MODE_BACKGROUND_BEGIN    :: 0x00100000;
    PROCESS_MODE_BACKGROUND_END      :: 0x00200000;
    CREATE_SECURE_PROCESS            :: 0x00400000;

    CREATE_BREAKAWAY_FROM_JOB        :: 0x01000000;
    CREATE_PRESERVE_CODE_AUTHZ_LEVEL :: 0x02000000;
    CREATE_DEFAULT_ERROR_MODE        :: 0x04000000;
    CREATE_NO_WINDOW                 :: 0x08000000;

    PROFILE_USER                     :: 0x10000000;
    PROFILE_KERNEL                   :: 0x20000000;
    PROFILE_SERVER                   :: 0x40000000;
    CREATE_IGNORE_SYSTEM_DEFAULT     :: 0x80000000;
}


GetModuleHandleA   :: (module_name: *u8) -> *void #foreign kernel32;
GetModuleHandleW   :: (module_name: *u16) -> *void #foreign kernel32;
MultiByteToWideChar :: (CodePage: u32, dwFlags: s32, lpMultiByteStr: *u8, cbMultiByte: s32, lpWideCharStr: *u16, cchWideChar: s32) -> s32 #foreign kernel32;
CreateThread :: (threadAttributes: *void, stackSize: s64, startAddress: *void, parameter: *void, creation_flags: Creation_Flags, threadIdReturn: *s32) -> *void #foreign kernel32;
WaitForSingleObject :: (handle: *void, milliseconds: u32) -> u32 #foreign kernel32;

shellscalingapi   :: #system_library "shcore";

PROCESS_DPI_AWARENESS :: enum {
  UNAWARE :: 0;
  SYSTEM :: 1;
  PER_MONITOR :: 2;
};

HANDLE :: *void;
HWND :: HANDLE;

SetProcessDpiAwareness :: (value: PROCESS_DPI_AWARENESS) -> s32 #foreign shellscalingapi;

gdi   :: #system_library "gdi32";
CreateSolidBrush :: (color: u32) -> *void #foreign gdi;
PatBlt :: (hdc: *void , x: s32, y: s32, w: s32, h: s32, rop: u32) -> s32 #foreign gdi;
