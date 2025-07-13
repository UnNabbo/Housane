Image_Layout :: enum{
	UNDEFINED                                      :: 0;
    GENERAL                                        :: 1;
    COLOR_ATTACHMENT_OPTIMAL                       :: 2;
    DEPTH_STENCIL_ATTACHMENT_OPTIMAL               :: 3;
    DEPTH_STENCIL_READ_ONLY_OPTIMAL                :: 4;
    SHADER_READ_ONLY_OPTIMAL                       :: 5;
    TRANSFER_SRC_OPTIMAL                           :: 6;
    TRANSFER_DST_OPTIMAL                           :: 7;
    PREINITIALIZED                                 :: 8;
    DEPTH_READ_ONLY_STENCIL_ATTACHMENT_OPTIMAL     :: 1000117000;
    DEPTH_ATTACHMENT_STENCIL_READ_ONLY_OPTIMAL     :: 1000117001;
    DEPTH_ATTACHMENT_OPTIMAL                       :: 1000241000;
    DEPTH_READ_ONLY_OPTIMAL                        :: 1000241001;
    STENCIL_ATTACHMENT_OPTIMAL                     :: 1000241002;
    STENCIL_READ_ONLY_OPTIMAL                      :: 1000241003;
    READ_ONLY_OPTIMAL                              :: 1000314000;
    ATTACHMENT_OPTIMAL                             :: 1000314001;
    PRESENT_SRC                                    :: 1000001002;
    VIDEO_DECODE_DST                               :: 1000024000;
    VIDEO_DECODE_SRC                               :: 1000024001;
    VIDEO_DECODE_DPB                               :: 1000024002;
    SHARED_PRESENT                                 :: 1000111000;
    FRAGMENT_DENSITY_MAP_OPTIMAL                   :: 1000218000;
    FRAGMENT_SHADING_RATE_ATTACHMENT_OPTIMAL       :: 1000164003;
    RENDERING_LOCAL_READ                           :: 1000232000;
    VIDEO_ENCODE_DST                               :: 1000299000;
    VIDEO_ENCODE_SRC                               :: 1000299001;
    VIDEO_ENCODE_DPB                               :: 1000299002;
    ATTACHMENT_FEEDBACK_LOOP_OPTIMAL               :: 1000339000;

}

Image_Usage :: enum_flags {
    NONE                                     :: 0x0;
    TRANSFER_SRC_BIT                         :: 0x1;
    TRANSFER_DST_BIT                         :: 0x2;
    SAMPLED_BIT                              :: 0x4;
    STORAGE_BIT                              :: 0x8;
    COLOR_ATTACHMENT_BIT                     :: 0x10;
    DEPTH_STENCIL_ATTACHMENT_BIT             :: 0x20;
    TRANSIENT_ATTACHMENT_BIT                 :: 0x40;
    INPUT_ATTACHMENT_BIT                     :: 0x80;
    VIDEO_DECODE_DST_BIT_KHR                 :: 0x400;
    VIDEO_DECODE_SRC_BIT_KHR                 :: 0x800;
    VIDEO_DECODE_DPB_BIT_KHR                 :: 0x1000;
    FRAGMENT_DENSITY_MAP_BIT_EXT             :: 0x200;
    FRAGMENT_SHADING_RATE_ATTACHMENT_BIT_KHR :: 0x100;
    HOST_TRANSFER_BIT_EXT                    :: 0x400000;
    VIDEO_ENCODE_DST_BIT_KHR                 :: 0x2000;
    VIDEO_ENCODE_SRC_BIT_KHR                 :: 0x4000;
    VIDEO_ENCODE_DPB_BIT_KHR                 :: 0x8000;
    ATTACHMENT_FEEDBACK_LOOP_BIT_EXT         :: 0x80000;
    INVOCATION_MASK_BIT_HUAWEI               :: 0x40000;
    SAMPLE_WEIGHT_BIT_QCOM                   :: 0x100000;
    SAMPLE_BLOCK_MATCH_BIT_QCOM              :: 0x200000;
    SHADING_RATE_IMAGE_BIT_NV                :: 0x100;
    FLAG_BITS_MAX_ENUM                       :: 0x7fffffff;
}

Image_Format :: enum u32 {
    UNDEFINED                                      :: 0;
    R4G4_UNORM_PACK8                               :: 1;
    R4G4B4A4_UNORM_PACK16                          :: 2;
    B4G4R4A4_UNORM_PACK16                          :: 3;
    R5G6B5_UNORM_PACK16                            :: 4;
    B5G6R5_UNORM_PACK16                            :: 5;
    R5G5B5A1_UNORM_PACK16                          :: 6;
    B5G5R5A1_UNORM_PACK16                          :: 7;
    A1R5G5B5_UNORM_PACK16                          :: 8;
    R8_UNORM                                       :: 9;
    R8_SNORM                                       :: 10;
    R8_USCALED                                     :: 11;
    R8_SSCALED                                     :: 12;
    R8_UINT                                        :: 13;
    R8_SINT                                        :: 14;
    R8_SRGB                                        :: 15;
    R8G8_UNORM                                     :: 16;
    R8G8_SNORM                                     :: 17;
    R8G8_USCALED                                   :: 18;
    R8G8_SSCALED                                   :: 19;
    R8G8_UINT                                      :: 20;
    R8G8_SINT                                      :: 21;
    R8G8_SRGB                                      :: 22;
    R8G8B8_UNORM                                   :: 23;
    R8G8B8_SNORM                                   :: 24;
    R8G8B8_USCALED                                 :: 25;
    R8G8B8_SSCALED                                 :: 26;
    R8G8B8_UINT                                    :: 27;
    R8G8B8_SINT                                    :: 28;
    R8G8B8_SRGB                                    :: 29;
    B8G8R8_UNORM                                   :: 30;
    B8G8R8_SNORM                                   :: 31;
    B8G8R8_USCALED                                 :: 32;
    B8G8R8_SSCALED                                 :: 33;
    B8G8R8_UINT                                    :: 34;
    B8G8R8_SINT                                    :: 35;
    B8G8R8_SRGB                                    :: 36;
    R8G8B8A8_UNORM                                 :: 37;
    R8G8B8A8_SNORM                                 :: 38;
    R8G8B8A8_USCALED                               :: 39;
    R8G8B8A8_SSCALED                               :: 40;
    R8G8B8A8_UINT                                  :: 41;
    R8G8B8A8_SINT                                  :: 42;
    R8G8B8A8_SRGB                                  :: 43;
    B8G8R8A8_UNORM                                 :: 44;
    B8G8R8A8_SNORM                                 :: 45;
    B8G8R8A8_USCALED                               :: 46;
    B8G8R8A8_SSCALED                               :: 47;
    B8G8R8A8_UINT                                  :: 48;
    B8G8R8A8_SINT                                  :: 49;
    B8G8R8A8_SRGB                                  :: 50;
    A8B8G8R8_UNORM_PACK32                          :: 51;
    A8B8G8R8_SNORM_PACK32                          :: 52;
    A8B8G8R8_USCALED_PACK32                        :: 53;
    A8B8G8R8_SSCALED_PACK32                        :: 54;
    A8B8G8R8_UINT_PACK32                           :: 55;
    A8B8G8R8_SINT_PACK32                           :: 56;
    A8B8G8R8_SRGB_PACK32                           :: 57;
    A2R10G10B10_UNORM_PACK32                       :: 58;
    A2R10G10B10_SNORM_PACK32                       :: 59;
    A2R10G10B10_USCALED_PACK32                     :: 60;
    A2R10G10B10_SSCALED_PACK32                     :: 61;
    A2R10G10B10_UINT_PACK32                        :: 62;
    A2R10G10B10_SINT_PACK32                        :: 63;
    A2B10G10R10_UNORM_PACK32                       :: 64;
    A2B10G10R10_SNORM_PACK32                       :: 65;
    A2B10G10R10_USCALED_PACK32                     :: 66;
    A2B10G10R10_SSCALED_PACK32                     :: 67;
    A2B10G10R10_UINT_PACK32                        :: 68;
    A2B10G10R10_SINT_PACK32                        :: 69;
    R16_UNORM                                      :: 70;
    R16_SNORM                                      :: 71;
    R16_USCALED                                    :: 72;
    R16_SSCALED                                    :: 73;
    R16_UINT                                       :: 74;
    R16_SINT                                       :: 75;
    R16_SFLOAT                                     :: 76;
    R16G16_UNORM                                   :: 77;
    R16G16_SNORM                                   :: 78;
    R16G16_USCALED                                 :: 79;
    R16G16_SSCALED                                 :: 80;
    R16G16_UINT                                    :: 81;
    R16G16_SINT                                    :: 82;
    R16G16_SFLOAT                                  :: 83;
    R16G16B16_UNORM                                :: 84;
    R16G16B16_SNORM                                :: 85;
    R16G16B16_USCALED                              :: 86;
    R16G16B16_SSCALED                              :: 87;
    R16G16B16_UINT                                 :: 88;
    R16G16B16_SINT                                 :: 89;
    R16G16B16_SFLOAT                               :: 90;
    R16G16B16A16_UNORM                             :: 91;
    R16G16B16A16_SNORM                             :: 92;
    R16G16B16A16_USCALED                           :: 93;
    R16G16B16A16_SSCALED                           :: 94;
    R16G16B16A16_UINT                              :: 95;
    R16G16B16A16_SINT                              :: 96;
    R16G16B16A16_SFLOAT                            :: 97;
    R32_UINT                                       :: 98;
    R32_SINT                                       :: 99;
    R32_SFLOAT                                     :: 100;
    R32G32_UINT                                    :: 101;
    R32G32_SINT                                    :: 102;
    R32G32_SFLOAT                                  :: 103;
    R32G32B32_UINT                                 :: 104;
    R32G32B32_SINT                                 :: 105;
    R32G32B32_SFLOAT                               :: 106;
    R32G32B32A32_UINT                              :: 107;
    R32G32B32A32_SINT                              :: 108;
    R32G32B32A32_SFLOAT                            :: 109;
    R64_UINT                                       :: 110;
    R64_SINT                                       :: 111;
    R64_SFLOAT                                     :: 112;
    R64G64_UINT                                    :: 113;
    R64G64_SINT                                    :: 114;
    R64G64_SFLOAT                                  :: 115;
    R64G64B64_UINT                                 :: 116;
    R64G64B64_SINT                                 :: 117;
    R64G64B64_SFLOAT                               :: 118;
    R64G64B64A64_UINT                              :: 119;
    R64G64B64A64_SINT                              :: 120;
    R64G64B64A64_SFLOAT                            :: 121;
    B10G11R11_UFLOAT_PACK32                        :: 122;
    E5B9G9R9_UFLOAT_PACK32                         :: 123;
    D16_UNORM                                      :: 124;
    X8_D24_UNORM_PACK32                            :: 125;
    D32_SFLOAT                                     :: 126;
    S8_UINT                                        :: 127;
    D16_UNORM_S8_UINT                              :: 128;
    D24_UNORM_S8_UINT                              :: 129;
    D32_SFLOAT_S8_UINT                             :: 130;
    BC1_RGB_UNORM_BLOCK                            :: 131;
    BC1_RGB_SRGB_BLOCK                             :: 132;
    BC1_RGBA_UNORM_BLOCK                           :: 133;
    BC1_RGBA_SRGB_BLOCK                            :: 134;
    BC2_UNORM_BLOCK                                :: 135;
    BC2_SRGB_BLOCK                                 :: 136;
    BC3_UNORM_BLOCK                                :: 137;
    BC3_SRGB_BLOCK                                 :: 138;
    BC4_UNORM_BLOCK                                :: 139;
    BC4_SNORM_BLOCK                                :: 140;
    BC5_UNORM_BLOCK                                :: 141;
    BC5_SNORM_BLOCK                                :: 142;
    BC6H_UFLOAT_BLOCK                              :: 143;
    BC6H_SFLOAT_BLOCK                              :: 144;
    BC7_UNORM_BLOCK                                :: 145;
    BC7_SRGB_BLOCK                                 :: 146;
    ETC2_R8G8B8_UNORM_BLOCK                        :: 147;
    ETC2_R8G8B8_SRGB_BLOCK                         :: 148;
    ETC2_R8G8B8A1_UNORM_BLOCK                      :: 149;
    ETC2_R8G8B8A1_SRGB_BLOCK                       :: 150;
    ETC2_R8G8B8A8_UNORM_BLOCK                      :: 151;
    ETC2_R8G8B8A8_SRGB_BLOCK                       :: 152;
    EAC_R11_UNORM_BLOCK                            :: 153;
    EAC_R11_SNORM_BLOCK                            :: 154;
    EAC_R11G11_UNORM_BLOCK                         :: 155;
    EAC_R11G11_SNORM_BLOCK                         :: 156;
    ASTC_4x4_UNORM_BLOCK                           :: 157;
    ASTC_4x4_SRGB_BLOCK                            :: 158;
    ASTC_5x4_UNORM_BLOCK                           :: 159;
    ASTC_5x4_SRGB_BLOCK                            :: 160;
    ASTC_5x5_UNORM_BLOCK                           :: 161;
    ASTC_5x5_SRGB_BLOCK                            :: 162;
    ASTC_6x5_UNORM_BLOCK                           :: 163;
    ASTC_6x5_SRGB_BLOCK                            :: 164;
    ASTC_6x6_UNORM_BLOCK                           :: 165;
    ASTC_6x6_SRGB_BLOCK                            :: 166;
    ASTC_8x5_UNORM_BLOCK                           :: 167;
    ASTC_8x5_SRGB_BLOCK                            :: 168;
    ASTC_8x6_UNORM_BLOCK                           :: 169;
    ASTC_8x6_SRGB_BLOCK                            :: 170;
    ASTC_8x8_UNORM_BLOCK                           :: 171;
    ASTC_8x8_SRGB_BLOCK                            :: 172;
    ASTC_10x5_UNORM_BLOCK                          :: 173;
    ASTC_10x5_SRGB_BLOCK                           :: 174;
    ASTC_10x6_UNORM_BLOCK                          :: 175;
    ASTC_10x6_SRGB_BLOCK                           :: 176;
    ASTC_10x8_UNORM_BLOCK                          :: 177;
    ASTC_10x8_SRGB_BLOCK                           :: 178;
    ASTC_10x10_UNORM_BLOCK                         :: 179;
    ASTC_10x10_SRGB_BLOCK                          :: 180;
    ASTC_12x10_UNORM_BLOCK                         :: 181;
    ASTC_12x10_SRGB_BLOCK                          :: 182;
    ASTC_12x12_UNORM_BLOCK                         :: 183;
    ASTC_12x12_SRGB_BLOCK                          :: 184;
    G8B8G8R8_422_UNORM                             :: 1000156000;
    B8G8R8G8_422_UNORM                             :: 1000156001;
    G8_B8_R8_3PLANE_420_UNORM                      :: 1000156002;
    G8_B8R8_2PLANE_420_UNORM                       :: 1000156003;
    G8_B8_R8_3PLANE_422_UNORM                      :: 1000156004;
    G8_B8R8_2PLANE_422_UNORM                       :: 1000156005;
    G8_B8_R8_3PLANE_444_UNORM                      :: 1000156006;
    R10X6_UNORM_PACK16                             :: 1000156007;
    R10X6G10X6_UNORM_2PACK16                       :: 1000156008;
    R10X6G10X6B10X6A10X6_UNORM_4PACK16             :: 1000156009;
    G10X6B10X6G10X6R10X6_422_UNORM_4PACK16         :: 1000156010;
    B10X6G10X6R10X6G10X6_422_UNORM_4PACK16         :: 1000156011;
    G10X6_B10X6_R10X6_3PLANE_420_UNORM_3PACK16     :: 1000156012;
    G10X6_B10X6R10X6_2PLANE_420_UNORM_3PACK16      :: 1000156013;
    G10X6_B10X6_R10X6_3PLANE_422_UNORM_3PACK16     :: 1000156014;
    G10X6_B10X6R10X6_2PLANE_422_UNORM_3PACK16      :: 1000156015;
    G10X6_B10X6_R10X6_3PLANE_444_UNORM_3PACK16     :: 1000156016;
    R12X4_UNORM_PACK16                             :: 1000156017;
    R12X4G12X4_UNORM_2PACK16                       :: 1000156018;
    R12X4G12X4B12X4A12X4_UNORM_4PACK16             :: 1000156019;
    G12X4B12X4G12X4R12X4_422_UNORM_4PACK16         :: 1000156020;
    B12X4G12X4R12X4G12X4_422_UNORM_4PACK16         :: 1000156021;
    G12X4_B12X4_R12X4_3PLANE_420_UNORM_3PACK16     :: 1000156022;
    G12X4_B12X4R12X4_2PLANE_420_UNORM_3PACK16      :: 1000156023;
    G12X4_B12X4_R12X4_3PLANE_422_UNORM_3PACK16     :: 1000156024;
    G12X4_B12X4R12X4_2PLANE_422_UNORM_3PACK16      :: 1000156025;
    G12X4_B12X4_R12X4_3PLANE_444_UNORM_3PACK16     :: 1000156026;
    G16B16G16R16_422_UNORM                         :: 1000156027;
    B16G16R16G16_422_UNORM                         :: 1000156028;
    G16_B16_R16_3PLANE_420_UNORM                   :: 1000156029;
    G16_B16R16_2PLANE_420_UNORM                    :: 1000156030;
    G16_B16_R16_3PLANE_422_UNORM                   :: 1000156031;
    G16_B16R16_2PLANE_422_UNORM                    :: 1000156032;
    G16_B16_R16_3PLANE_444_UNORM                   :: 1000156033;
    G8_B8R8_2PLANE_444_UNORM                       :: 1000330000;
    G10X6_B10X6R10X6_2PLANE_444_UNORM_3PACK16      :: 1000330001;
    G12X4_B12X4R12X4_2PLANE_444_UNORM_3PACK16      :: 1000330002;
    G16_B16R16_2PLANE_444_UNORM                    :: 1000330003;
    A4R4G4B4_UNORM_PACK16                          :: 1000340000;
    A4B4G4R4_UNORM_PACK16                          :: 1000340001;
    ASTC_4x4_SFLOAT_BLOCK                          :: 1000066000;
    ASTC_5x4_SFLOAT_BLOCK                          :: 1000066001;
    ASTC_5x5_SFLOAT_BLOCK                          :: 1000066002;
    ASTC_6x5_SFLOAT_BLOCK                          :: 1000066003;
    ASTC_6x6_SFLOAT_BLOCK                          :: 1000066004;
    ASTC_8x5_SFLOAT_BLOCK                          :: 1000066005;
    ASTC_8x6_SFLOAT_BLOCK                          :: 1000066006;
    ASTC_8x8_SFLOAT_BLOCK                          :: 1000066007;
    ASTC_10x5_SFLOAT_BLOCK                         :: 1000066008;
    ASTC_10x6_SFLOAT_BLOCK                         :: 1000066009;
    ASTC_10x8_SFLOAT_BLOCK                         :: 1000066010;
    ASTC_10x10_SFLOAT_BLOCK                        :: 1000066011;
    ASTC_12x10_SFLOAT_BLOCK                        :: 1000066012;
    ASTC_12x12_SFLOAT_BLOCK                        :: 1000066013;
    PVRTC1_2BPP_UNORM_BLOCK_IMG                    :: 1000054000;
    PVRTC1_4BPP_UNORM_BLOCK_IMG                    :: 1000054001;
    PVRTC2_2BPP_UNORM_BLOCK_IMG                    :: 1000054002;
    PVRTC2_4BPP_UNORM_BLOCK_IMG                    :: 1000054003;
    PVRTC1_2BPP_SRGB_BLOCK_IMG                     :: 1000054004;
    PVRTC1_4BPP_SRGB_BLOCK_IMG                     :: 1000054005;
    PVRTC2_2BPP_SRGB_BLOCK_IMG                     :: 1000054006;
    PVRTC2_4BPP_SRGB_BLOCK_IMG                     :: 1000054007;
    R16G16_SFIXED5_NV                              :: 1000464000;
    A1B5G5R5_UNORM_PACK16_KHR                      :: 1000470000;
    A8_UNORM_KHR                                   :: 1000470001;
    ASTC_4x4_SFLOAT_BLOCK_EXT                      :: 1000066000;
    ASTC_5x4_SFLOAT_BLOCK_EXT                      :: 1000066001;
    ASTC_5x5_SFLOAT_BLOCK_EXT                      :: 1000066002;
    ASTC_6x5_SFLOAT_BLOCK_EXT                      :: 1000066003;
    ASTC_6x6_SFLOAT_BLOCK_EXT                      :: 1000066004;
    ASTC_8x5_SFLOAT_BLOCK_EXT                      :: 1000066005;
    ASTC_8x6_SFLOAT_BLOCK_EXT                      :: 1000066006;
    ASTC_8x8_SFLOAT_BLOCK_EXT                      :: 1000066007;
    ASTC_10x5_SFLOAT_BLOCK_EXT                     :: 1000066008;
    ASTC_10x6_SFLOAT_BLOCK_EXT                     :: 1000066009;
    ASTC_10x8_SFLOAT_BLOCK_EXT                     :: 1000066010;
    ASTC_10x10_SFLOAT_BLOCK_EXT                    :: 1000066011;
    ASTC_12x10_SFLOAT_BLOCK_EXT                    :: 1000066012;
    ASTC_12x12_SFLOAT_BLOCK_EXT                    :: 1000066013;
    G8B8G8R8_422_UNORM_KHR                         :: 1000156000;
    B8G8R8G8_422_UNORM_KHR                         :: 1000156001;
    G8_B8_R8_3PLANE_420_UNORM_KHR                  :: 1000156002;
    G8_B8R8_2PLANE_420_UNORM_KHR                   :: 1000156003;
    G8_B8_R8_3PLANE_422_UNORM_KHR                  :: 1000156004;
    G8_B8R8_2PLANE_422_UNORM_KHR                   :: 1000156005;
    G8_B8_R8_3PLANE_444_UNORM_KHR                  :: 1000156006;
    R10X6_UNORM_PACK16_KHR                         :: 1000156007;
    R10X6G10X6_UNORM_2PACK16_KHR                   :: 1000156008;
    R10X6G10X6B10X6A10X6_UNORM_4PACK16_KHR         :: 1000156009;
    G10X6B10X6G10X6R10X6_422_UNORM_4PACK16_KHR     :: 1000156010;
    B10X6G10X6R10X6G10X6_422_UNORM_4PACK16_KHR     :: 1000156011;
    G10X6_B10X6_R10X6_3PLANE_420_UNORM_3PACK16_KHR :: 1000156012;
    G10X6_B10X6R10X6_2PLANE_420_UNORM_3PACK16_KHR  :: 1000156013;
    G10X6_B10X6_R10X6_3PLANE_422_UNORM_3PACK16_KHR :: 1000156014;
    G10X6_B10X6R10X6_2PLANE_422_UNORM_3PACK16_KHR  :: 1000156015;
    G10X6_B10X6_R10X6_3PLANE_444_UNORM_3PACK16_KHR :: 1000156016;
    R12X4_UNORM_PACK16_KHR                         :: 1000156017;
    R12X4G12X4_UNORM_2PACK16_KHR                   :: 1000156018;
    R12X4G12X4B12X4A12X4_UNORM_4PACK16_KHR         :: 1000156019;
    G12X4B12X4G12X4R12X4_422_UNORM_4PACK16_KHR     :: 1000156020;
    B12X4G12X4R12X4G12X4_422_UNORM_4PACK16_KHR     :: 1000156021;
    G12X4_B12X4_R12X4_3PLANE_420_UNORM_3PACK16_KHR :: 1000156022;
    G12X4_B12X4R12X4_2PLANE_420_UNORM_3PACK16_KHR  :: 1000156023;
    G12X4_B12X4_R12X4_3PLANE_422_UNORM_3PACK16_KHR :: 1000156024;
    G12X4_B12X4R12X4_2PLANE_422_UNORM_3PACK16_KHR  :: 1000156025;
    G12X4_B12X4_R12X4_3PLANE_444_UNORM_3PACK16_KHR :: 1000156026;
    G16B16G16R16_422_UNORM_KHR                     :: 1000156027;
    B16G16R16G16_422_UNORM_KHR                     :: 1000156028;
    G16_B16_R16_3PLANE_420_UNORM_KHR               :: 1000156029;
    G16_B16R16_2PLANE_420_UNORM_KHR                :: 1000156030;
    G16_B16_R16_3PLANE_422_UNORM_KHR               :: 1000156031;
    G16_B16R16_2PLANE_422_UNORM_KHR                :: 1000156032;
    G16_B16_R16_3PLANE_444_UNORM_KHR               :: 1000156033;
    G8_B8R8_2PLANE_444_UNORM_EXT                   :: 1000330000;
    G10X6_B10X6R10X6_2PLANE_444_UNORM_3PACK16_EXT  :: 1000330001;
    G12X4_B12X4R12X4_2PLANE_444_UNORM_3PACK16_EXT  :: 1000330002;
    G16_B16R16_2PLANE_444_UNORM_EXT                :: 1000330003;
    A4R4G4B4_UNORM_PACK16_EXT                      :: 1000340000;
    A4B4G4R4_UNORM_PACK16_EXT                      :: 1000340001;
    R16G16_S10_5_NV                                :: 1000464000;
}

Vulkan_Memory_Usage :: enum_flags{
	UNKNOWN              :: 0;
    GPU_ONLY             :: 1;
    CPU_ONLY             :: 2;
    CPU_TO_GPU           :: 3;
    GPU_TO_CPU           :: 4;
    CPU_COPY             :: 5;
    GPU_LAZILY_ALLOCATED :: 6;
    AUTO                 :: 7;
    AUTO_PREFER_DEVICE   :: 8;
    AUTO_PREFER_HOST     :: 9;
}

Allocated_Buffer_Usage :: enum_flags{
    TRANSFER_SRC                                     :: 0x1;
    TRANSFER_DST                                     :: 0x2;
    UNIFORM_TEXEL                                    :: 0x4;
    STORAGE_TEXEL                                    :: 0x8;
    UNIFORM                                          :: 0x10;
    STORAGE                                          :: 0x20;
    INDEX                                            :: 0x40;
    VERTEX                                           :: 0x80;
    INDIRECT                                         :: 0x100;
    SHADER_DEVICE_ADDRESS                            :: 0x20000;
    VIDEO_DECODE_SRC                                 :: 0x2000;
    VIDEO_DECODE_DST                                 :: 0x4000;
    TRANSFORM_FEEDBACK                               :: 0x800;
    TRANSFORM_FEEDBACK_COUNTER                       :: 0x1000;
    CONDITIONAL_RENDERING                            :: 0x200;
    ACCELERATION_STRUCTURE_BUILD_INPUT_READ_ONLY     :: 0x80000;
    ACCELERATION_STRUCTURE_STORAGE                   :: 0x100000;
    SHADER_BINDING_TABLE                             :: 0x400;
    VIDEO_ENCODE_DST                                 :: 0x8000;
    VIDEO_ENCODE_SRC                                 :: 0x10000;
    SAMPLER_DESCRIPTOR                               :: 0x200000;
    RESOURCE_DESCRIPTOR                              :: 0x400000;
    PUSH_DESCRIPTORS_DESCRIPTOR                      :: 0x4000000;
    MICROMAP_BUILD_INPUT_READ_ONLY                   :: 0x800000;
    MICROMAP_STORAGE                                 :: 0x1000000;
    RAY_TRACING                                      :: 0x400;
}
Allocated_Buffer :: struct {
	#as handle: VkBuffer;
    allocation: Vulkan_Memory_Allocation;
	info: Vulkan_Memory_Allocation_Info;
}

Buffer_Device_Address :: VkDeviceAddress ;

Image :: struct{
	#as handle: VkImage;
    using extent: VkExtent3D;
	view: VkImageView;
	layout : Image_Layout;
	usage : Image_Usage;
    format: Image_Format;
    allocation: Vulkan_Memory_Allocation;
}

Vulkan_Memory_Allocation_Info :: VmaAllocationInfo;

Vulkan_Memory_Allocation :: struct {
	#as handle: VmaAllocation;
	allocator: *Vulkan_Memory_Allocator;
}

Vulkan_Memory_Allocator :: struct {
	#as handle: VmaAllocator;
	device: *Device;
}

allocate_image :: (allocator: *Vulkan_Memory_Allocator, width: s32, height: s32, image_usage: Image_Usage = .NONE, image_format: Image_Format = .R16G16B16A16_SFLOAT, loc := #caller_location) -> Image{
	image: Image;
	image.usage = image_usage;
	
	image_3d_extent: VkExtent3D = .{
		xx width,
		xx height,
		1
	};
	
	image.format = image_format;
	image.extent = image_3d_extent;

	image_info: VkImageCreateInfo;
    image_info.imageType = ._2D;
    image_info.format = xx image.format;
    image_info.extent = image.extent;
    image_info.mipLevels = 1;
    image_info.arrayLayers = 1;
    image_info.samples = ._1_BIT;
    image_info.tiling = .OPTIMAL;
    image_info.usage = xx image_usage;
	
	alloc_info: VmaAllocationCreateInfo;
	alloc_info.usage = xx VmaMemoryUsage.GPU_ONLY;
	alloc_info.requiredFlags = .DEVICE_LOCAL_BIT;

	vmaCreateImage(allocator, *image_info, *alloc_info, *image.handle, *image.allocation.handle, null);
	image.allocation.allocator = allocator;
	
	view_info: VkImageViewCreateInfo;
    view_info.viewType = ._2D;
    view_info.image = image;
    view_info.format = xx image.format;
    view_info.subresourceRange.baseMipLevel = 0;
    view_info.subresourceRange.levelCount = 1;
    view_info.subresourceRange.baseArrayLayer = 0;
    view_info.subresourceRange.layerCount = 1;
	if image_usage & .COLOR_ATTACHMENT_BIT then view_info.subresourceRange.aspectMask = .COLOR_BIT;
	if image_usage & .DEPTH_STENCIL_ATTACHMENT_BIT then view_info.subresourceRange.aspectMask = .DEPTH_BIT;


	vk_assert(vkCreateImageView(allocator.device, *view_info, null, *image.view));
	
	log("Image allocated at %:%", loc.fully_pathed_filename, loc.line_number);
	
	return image;
}

create_vulkan_memory_allocator :: (instance: Instance, device: *Device, deletion_queue: *Deletion_Queue = null) -> Vulkan_Memory_Allocator{
	allocator: Vulkan_Memory_Allocator;

	allocator.device = device;

	allocator_info: VmaAllocatorCreateInfo;
    allocator_info.physicalDevice = instance.physical_device;
    allocator_info.device = device;
    allocator_info.instance = instance;
    allocator_info.flags = .BUFFER_DEVICE_ADDRESS_BIT;
    vmaCreateAllocator(*allocator_info, *allocator.handle);
	Deletion_Queue.push(deletion_queue, allocator);
	return allocator;
}

destroy_vulkan_memory_allocator :: (allocator: *Vulkan_Memory_Allocator){
	vmaDestroyAllocator(allocator);
}

allocate_gpu_buffer :: (allocator: *Vulkan_Memory_Allocator, size: s64, buffer_usage: Allocated_Buffer_Usage, memory_usage: Vulkan_Memory_Usage, loc := #caller_location) -> Allocated_Buffer{
	buffer_info: VkBufferCreateInfo;
	buffer_info.size = xx size;
	buffer_info.usage = xx buffer_usage;

	vma_alloc_info: VmaAllocationCreateInfo ;
	vma_alloc_info.usage = xx memory_usage;
	vma_alloc_info.flags = .MAPPED_BIT;
	buffer : Allocated_Buffer;

	// allocate the buffer
	vk_assert(vmaCreateBuffer(allocator, *buffer_info, *vma_alloc_info, *buffer.handle, *buffer.allocation.handle, *buffer.info));
	buffer.allocation.allocator = allocator;
	log("Buffer allocated at %:%", loc.fully_pathed_filename, loc.line_number);
	
	return buffer;
}

deallocate_gpu_buffer :: (buffer: *Allocated_Buffer, loc := #caller_location){
	log("Buffer deallocated at %:%", loc.fully_pathed_filename, loc.line_number);
	vmaDestroyBuffer(buffer.allocation.allocator, buffer.handle, buffer.allocation);
}

get_buffer_device_address :: (buffer: Allocated_Buffer) -> Buffer_Device_Address{
	device_adress_info: VkBufferDeviceAddressInfo;
	device_adress_info.buffer = buffer;
	return vkGetBufferDeviceAddress(buffer.allocation.allocator.device, *device_adress_info);
}
