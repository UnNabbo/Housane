#import "Basic"()(MEMORY_DEBUGGER = BUILD_TYPE != .RELEASE, ENABLE_ASSERT = BUILD_TYPE != .RELEASE);

#import "Math";

#import "String";
#import "Debug";
#import "File";
#import "Print_Color";

#load "entry_point.jai";
#load "window_and_input.jai";

Color3 :: struct {
    r, g, b: u8;
	#place r;
    channel: [3] u8 = ---;
}

Color4 :: struct {
    r, g, b, a: u8;
#place r;
    rgb: Color3 = ---;
#place r;
    channel: [4] u8 = ---;
}



	
array_allocate :: NewArray;
