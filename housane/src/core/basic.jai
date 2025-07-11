

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

Vec2 :: Vector2;
Vec3 :: Vector3;
Vec4 :: Vector4;

Mat4 :: Matrix4;

	
array_allocate :: NewArray;
