//#load "entry_point.jai";
//#load "window_and_input.jai";
#load "memory.jai";

SYSTEM_THREAD_COUNT :: #run get_number_of_processors() / 2;

f32 :: float32;
new :: New;
array_allocate :: NewArray;


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

Vec2 :: Vector2;
Vec3 :: Vector3;
Vec4 :: Vector4;
Mat4 :: Matrix4;

clamp_hi :: inline (val: $T, max: T) -> T {
	return clamp(val, val, max);
}

clamp_lo :: inline (val: $T, min: T) -> T {
	if val < min return min;
	else return val;
}


init_thread_group :: (thread_group: *Thread_Group, proc: Thread_Group_Proc, thread_count : s32 = SYSTEM_THREAD_COUNT - 1) {
    init(thread_group, thread_count, proc);
    thread_group.name    = "Thread_Group";
    thread_group.logging = false;
}

start_thread_group :: start;

