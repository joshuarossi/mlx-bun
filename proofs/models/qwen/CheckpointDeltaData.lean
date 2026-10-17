import models.qwen.CheckpointRanges

namespace Inference.Models.Qwen.CheckpointDeltaData
open Contracts.Mlx
open FloatLib FloatLib.Floats FloatLib.Floats.Formats.BinaryInterchange
abbrev BF := BFloat16Arithmetic.Value
set_option maxRecDepth 30000

-- Literal payloads from Qwen3.8-27B-Trellis-3.2bpw, snapshot
-- cbb7a58a7222a19a3d02d36540c9cab5d9aadf0d, Delta layers 0,1,2,4,...,62.
-- These certify the literals. Host file parsing and native loader attachment
-- are separate obligations. Regeneration uses checkpoint-delta.ts.
def raw (dictionary : List BF) (table : List (List Nat)) (layer : Fin 48) (i : Fin width) : BF :=
  dictionary[((table[layer.val]?.getD [])[i.val]?.getD 0)]?.getD CheckpointRanges.zeroCap

def aLogDictionary : List BF := [
  Model.ofBits 0x3be1, Model.ofBits 0x3c03, Model.ofBits 0x3c53, Model.ofBits 0x3c69, Model.ofBits 0x3c9d, Model.ofBits 0x3cc0, Model.ofBits 0x3ccf, Model.ofBits 0x3cd5, Model.ofBits 0x3ce9, Model.ofBits 0x3cea, Model.ofBits 0x3cff, Model.ofBits 0x3d03, Model.ofBits 0x3d10, Model.ofBits 0x3d1e, Model.ofBits 0x3d22, Model.ofBits 0x3d34,
  Model.ofBits 0x3d35, Model.ofBits 0x3d37, Model.ofBits 0x3d39, Model.ofBits 0x3d40, Model.ofBits 0x3d41, Model.ofBits 0x3d68, Model.ofBits 0x3d6a, Model.ofBits 0x3d73, Model.ofBits 0x3d7a, Model.ofBits 0x3d7e, Model.ofBits 0x3d86, Model.ofBits 0x3d8f, Model.ofBits 0x3d98, Model.ofBits 0x3d9e, Model.ofBits 0x3da4, Model.ofBits 0x3da5,
  Model.ofBits 0x3da6, Model.ofBits 0x3da7, Model.ofBits 0x3db1, Model.ofBits 0x3dbe, Model.ofBits 0x3dc9, Model.ofBits 0x3dd1, Model.ofBits 0x3de2, Model.ofBits 0x3de4, Model.ofBits 0x3def, Model.ofBits 0x3e0c, Model.ofBits 0x3e0e, Model.ofBits 0x3e11, Model.ofBits 0x3e13, Model.ofBits 0x3e18, Model.ofBits 0x3e1b, Model.ofBits 0x3e25,
  Model.ofBits 0x3e26, Model.ofBits 0x3e2c, Model.ofBits 0x3e2e, Model.ofBits 0x3e32, Model.ofBits 0x3e38, Model.ofBits 0x3e3e, Model.ofBits 0x3e41, Model.ofBits 0x3e46, Model.ofBits 0x3e4e, Model.ofBits 0x3e56, Model.ofBits 0x3e59, Model.ofBits 0x3e67, Model.ofBits 0x3e69, Model.ofBits 0x3e6a, Model.ofBits 0x3e6b, Model.ofBits 0x3e6d,
  Model.ofBits 0x3e6e, Model.ofBits 0x3e72, Model.ofBits 0x3e74, Model.ofBits 0x3e76, Model.ofBits 0x3e7a, Model.ofBits 0x3e7f, Model.ofBits 0x3e80, Model.ofBits 0x3e81, Model.ofBits 0x3e82, Model.ofBits 0x3e83, Model.ofBits 0x3e85, Model.ofBits 0x3e87, Model.ofBits 0x3e88, Model.ofBits 0x3e89, Model.ofBits 0x3e8a, Model.ofBits 0x3e8c,
  Model.ofBits 0x3e8d, Model.ofBits 0x3e91, Model.ofBits 0x3e92, Model.ofBits 0x3e95, Model.ofBits 0x3e99, Model.ofBits 0x3e9a, Model.ofBits 0x3e9f, Model.ofBits 0x3ea0, Model.ofBits 0x3ea1, Model.ofBits 0x3ea3, Model.ofBits 0x3ea4, Model.ofBits 0x3ea5, Model.ofBits 0x3ea7, Model.ofBits 0x3eab, Model.ofBits 0x3eac, Model.ofBits 0x3ead,
  Model.ofBits 0x3eaf, Model.ofBits 0x3eb0, Model.ofBits 0x3eba, Model.ofBits 0x3ebb, Model.ofBits 0x3ebf, Model.ofBits 0x3ec0, Model.ofBits 0x3ec3, Model.ofBits 0x3ec8, Model.ofBits 0x3ecd, Model.ofBits 0x3ed0, Model.ofBits 0x3ed1, Model.ofBits 0x3ed2, Model.ofBits 0x3edb, Model.ofBits 0x3ee0, Model.ofBits 0x3ee2, Model.ofBits 0x3ee3,
  Model.ofBits 0x3ee4, Model.ofBits 0x3ee7, Model.ofBits 0x3eec, Model.ofBits 0x3eee, Model.ofBits 0x3eef, Model.ofBits 0x3ef4, Model.ofBits 0x3ef5, Model.ofBits 0x3ef7, Model.ofBits 0x3efd, Model.ofBits 0x3f02, Model.ofBits 0x3f03, Model.ofBits 0x3f06, Model.ofBits 0x3f07, Model.ofBits 0x3f08, Model.ofBits 0x3f0a, Model.ofBits 0x3f0b,
  Model.ofBits 0x3f0c, Model.ofBits 0x3f0f, Model.ofBits 0x3f10, Model.ofBits 0x3f11, Model.ofBits 0x3f13, Model.ofBits 0x3f18, Model.ofBits 0x3f19, Model.ofBits 0x3f1c, Model.ofBits 0x3f1d, Model.ofBits 0x3f1e, Model.ofBits 0x3f1f, Model.ofBits 0x3f20, Model.ofBits 0x3f22, Model.ofBits 0x3f23, Model.ofBits 0x3f27, Model.ofBits 0x3f29,
  Model.ofBits 0x3f2a, Model.ofBits 0x3f2b, Model.ofBits 0x3f2c, Model.ofBits 0x3f2d, Model.ofBits 0x3f30, Model.ofBits 0x3f32, Model.ofBits 0x3f33, Model.ofBits 0x3f34, Model.ofBits 0x3f35, Model.ofBits 0x3f36, Model.ofBits 0x3f37, Model.ofBits 0x3f3a, Model.ofBits 0x3f3b, Model.ofBits 0x3f3d, Model.ofBits 0x3f3e, Model.ofBits 0x3f3f,
  Model.ofBits 0x3f40, Model.ofBits 0x3f42, Model.ofBits 0x3f43, Model.ofBits 0x3f47, Model.ofBits 0x3f48, Model.ofBits 0x3f49, Model.ofBits 0x3f4a, Model.ofBits 0x3f4b, Model.ofBits 0x3f4d, Model.ofBits 0x3f4f, Model.ofBits 0x3f50, Model.ofBits 0x3f51, Model.ofBits 0x3f52, Model.ofBits 0x3f53, Model.ofBits 0x3f55, Model.ofBits 0x3f56,
  Model.ofBits 0x3f58, Model.ofBits 0x3f5b, Model.ofBits 0x3f5c, Model.ofBits 0x3f5d, Model.ofBits 0x3f5f, Model.ofBits 0x3f62, Model.ofBits 0x3f65, Model.ofBits 0x3f67, Model.ofBits 0x3f68, Model.ofBits 0x3f6a, Model.ofBits 0x3f6b, Model.ofBits 0x3f6c, Model.ofBits 0x3f6e, Model.ofBits 0x3f6f, Model.ofBits 0x3f70, Model.ofBits 0x3f72,
  Model.ofBits 0x3f75, Model.ofBits 0x3f76, Model.ofBits 0x3f77, Model.ofBits 0x3f78, Model.ofBits 0x3f7c, Model.ofBits 0x3f7d, Model.ofBits 0x3f7f, Model.ofBits 0x3f80, Model.ofBits 0x3f81, Model.ofBits 0x3f82, Model.ofBits 0x3f83, Model.ofBits 0x3f84, Model.ofBits 0x3f85, Model.ofBits 0x3f86, Model.ofBits 0x3f88, Model.ofBits 0x3f89,
  Model.ofBits 0x3f8a, Model.ofBits 0x3f8b, Model.ofBits 0x3f8c, Model.ofBits 0x3f8d, Model.ofBits 0x3f8e, Model.ofBits 0x3f8f, Model.ofBits 0x3f90, Model.ofBits 0x3f91, Model.ofBits 0x3f92, Model.ofBits 0x3f96, Model.ofBits 0x3f97, Model.ofBits 0x3f98, Model.ofBits 0x3f9a, Model.ofBits 0x3f9b, Model.ofBits 0x3f9c, Model.ofBits 0x3f9d,
  Model.ofBits 0x3f9e, Model.ofBits 0x3fa1, Model.ofBits 0x3fa2, Model.ofBits 0x3fa3, Model.ofBits 0x3fa4, Model.ofBits 0x3fa5, Model.ofBits 0x3fa6, Model.ofBits 0x3fa7, Model.ofBits 0x3fa9, Model.ofBits 0x3fac, Model.ofBits 0x3fad, Model.ofBits 0x3fae, Model.ofBits 0x3faf, Model.ofBits 0x3fb0, Model.ofBits 0x3fb1, Model.ofBits 0x3fb3,
  Model.ofBits 0x3fb4, Model.ofBits 0x3fb5, Model.ofBits 0x3fb6, Model.ofBits 0x3fb7, Model.ofBits 0x3fb9, Model.ofBits 0x3fba, Model.ofBits 0x3fbc, Model.ofBits 0x3fbd, Model.ofBits 0x3fbe, Model.ofBits 0x3fbf, Model.ofBits 0x3fc0, Model.ofBits 0x3fc1, Model.ofBits 0x3fc2, Model.ofBits 0x3fc3, Model.ofBits 0x3fc4, Model.ofBits 0x3fc5,
  Model.ofBits 0x3fc7, Model.ofBits 0x3fc8, Model.ofBits 0x3fca, Model.ofBits 0x3fcb, Model.ofBits 0x3fcc, Model.ofBits 0x3fcd, Model.ofBits 0x3fce, Model.ofBits 0x3fd0, Model.ofBits 0x3fd2, Model.ofBits 0x3fd3, Model.ofBits 0x3fd4, Model.ofBits 0x3fd5, Model.ofBits 0x3fd6, Model.ofBits 0x3fd7, Model.ofBits 0x3fd8, Model.ofBits 0x3fd9,
  Model.ofBits 0x3fda, Model.ofBits 0x3fdd, Model.ofBits 0x3fde, Model.ofBits 0x3fdf, Model.ofBits 0x3fe0, Model.ofBits 0x3fe1, Model.ofBits 0x3fe3, Model.ofBits 0x3fe4, Model.ofBits 0x3fe5, Model.ofBits 0x3fe6, Model.ofBits 0x3fe8, Model.ofBits 0x3fe9, Model.ofBits 0x3fea, Model.ofBits 0x3feb, Model.ofBits 0x3fed, Model.ofBits 0x3fee,
  Model.ofBits 0x3fef, Model.ofBits 0x3ff0, Model.ofBits 0x3ff1, Model.ofBits 0x3ff3, Model.ofBits 0x3ff4, Model.ofBits 0x3ff5, Model.ofBits 0x3ff6, Model.ofBits 0x3ff8, Model.ofBits 0x3ffa, Model.ofBits 0x3ffb, Model.ofBits 0x3ffd, Model.ofBits 0x3ffe, Model.ofBits 0x3fff, Model.ofBits 0x4000, Model.ofBits 0x4001, Model.ofBits 0x4002,
  Model.ofBits 0x4003, Model.ofBits 0x4004, Model.ofBits 0x4005, Model.ofBits 0x4006, Model.ofBits 0x4007, Model.ofBits 0x4008, Model.ofBits 0x4009, Model.ofBits 0x400a, Model.ofBits 0x400b, Model.ofBits 0x400c, Model.ofBits 0x400d, Model.ofBits 0x400e, Model.ofBits 0x400f, Model.ofBits 0x4010, Model.ofBits 0x4011, Model.ofBits 0x4013,
  Model.ofBits 0x4014, Model.ofBits 0x4015, Model.ofBits 0x4016, Model.ofBits 0x4017, Model.ofBits 0x4018, Model.ofBits 0x4019, Model.ofBits 0x401b, Model.ofBits 0x401c, Model.ofBits 0x401d, Model.ofBits 0x401e, Model.ofBits 0x401f, Model.ofBits 0x4020, Model.ofBits 0x4021, Model.ofBits 0x4022, Model.ofBits 0x4023, Model.ofBits 0x4024,
  Model.ofBits 0x4026, Model.ofBits 0x4029, Model.ofBits 0x402a, Model.ofBits 0x402b, Model.ofBits 0x402c, Model.ofBits 0x402d, Model.ofBits 0x402f, Model.ofBits 0x4030, Model.ofBits 0x4032, Model.ofBits 0x4033, Model.ofBits 0x4036, Model.ofBits 0x4037, Model.ofBits 0x4038, Model.ofBits 0x4039, Model.ofBits 0x403e, Model.ofBits 0x4040,
  Model.ofBits 0x4041, Model.ofBits 0x4042, Model.ofBits 0x4044, Model.ofBits 0x4046, Model.ofBits 0x4047, Model.ofBits 0x404a, Model.ofBits 0x404c, Model.ofBits 0x404d, Model.ofBits 0x4050, Model.ofBits 0x4053, Model.ofBits 0x4055, Model.ofBits 0x4057, Model.ofBits 0x4058, Model.ofBits 0x405d, Model.ofBits 0x405e, Model.ofBits 0x4062,
  Model.ofBits 0x4063, Model.ofBits 0x4064, Model.ofBits 0x4067, Model.ofBits 0x4068, Model.ofBits 0x4069, Model.ofBits 0x406a, Model.ofBits 0x406d, Model.ofBits 0x4071, Model.ofBits 0x4073, Model.ofBits 0x4074, Model.ofBits 0x4077, Model.ofBits 0x407a, Model.ofBits 0x407d, Model.ofBits 0x4083, Model.ofBits 0x4085, Model.ofBits 0x4087,
  Model.ofBits 0x408d, Model.ofBits 0x4094, Model.ofBits 0x409e, Model.ofBits 0xbb00, Model.ofBits 0xbb39, Model.ofBits 0xbb5d, Model.ofBits 0xbbd6, Model.ofBits 0xbbdb, Model.ofBits 0xbbf5, Model.ofBits 0xbc14, Model.ofBits 0xbc4f, Model.ofBits 0xbc56, Model.ofBits 0xbc9a, Model.ofBits 0xbca8, Model.ofBits 0xbcd0, Model.ofBits 0xbcf3,
  Model.ofBits 0xbd00, Model.ofBits 0xbd03, Model.ofBits 0xbd09, Model.ofBits 0xbd11, Model.ofBits 0xbd20, Model.ofBits 0xbd21, Model.ofBits 0xbd22, Model.ofBits 0xbd33, Model.ofBits 0xbd3c, Model.ofBits 0xbd43, Model.ofBits 0xbd44, Model.ofBits 0xbd49, Model.ofBits 0xbd5f, Model.ofBits 0xbd74, Model.ofBits 0xbd7e, Model.ofBits 0xbd84,
  Model.ofBits 0xbd89, Model.ofBits 0xbd8a, Model.ofBits 0xbd8e, Model.ofBits 0xbd9c, Model.ofBits 0xbd9e, Model.ofBits 0xbda3, Model.ofBits 0xbdab, Model.ofBits 0xbdb2, Model.ofBits 0xbdb4, Model.ofBits 0xbdb5, Model.ofBits 0xbdb9, Model.ofBits 0xbdbc, Model.ofBits 0xbdc2, Model.ofBits 0xbdc8, Model.ofBits 0xbdcc, Model.ofBits 0xbdd9,
  Model.ofBits 0xbde6, Model.ofBits 0xbde9, Model.ofBits 0xbdea, Model.ofBits 0xbdef, Model.ofBits 0xbdf2, Model.ofBits 0xbdf3, Model.ofBits 0xbdfe, Model.ofBits 0xbdff, Model.ofBits 0xbe01, Model.ofBits 0xbe02, Model.ofBits 0xbe06, Model.ofBits 0xbe0b, Model.ofBits 0xbe13, Model.ofBits 0xbe16, Model.ofBits 0xbe17, Model.ofBits 0xbe19,
  Model.ofBits 0xbe20, Model.ofBits 0xbe23, Model.ofBits 0xbe24, Model.ofBits 0xbe25, Model.ofBits 0xbe26, Model.ofBits 0xbe28, Model.ofBits 0xbe2b, Model.ofBits 0xbe30, Model.ofBits 0xbe32, Model.ofBits 0xbe3a, Model.ofBits 0xbe3c, Model.ofBits 0xbe4b, Model.ofBits 0xbe4c, Model.ofBits 0xbe4d, Model.ofBits 0xbe54, Model.ofBits 0xbe5a,
  Model.ofBits 0xbe5b, Model.ofBits 0xbe5c, Model.ofBits 0xbe5e, Model.ofBits 0xbe5f, Model.ofBits 0xbe60, Model.ofBits 0xbe61, Model.ofBits 0xbe66, Model.ofBits 0xbe6f, Model.ofBits 0xbe78, Model.ofBits 0xbe79, Model.ofBits 0xbe7b, Model.ofBits 0xbe7c, Model.ofBits 0xbe7f, Model.ofBits 0xbe80, Model.ofBits 0xbe81, Model.ofBits 0xbe82,
  Model.ofBits 0xbe83, Model.ofBits 0xbe88, Model.ofBits 0xbe89, Model.ofBits 0xbe8b, Model.ofBits 0xbe8d, Model.ofBits 0xbe8e, Model.ofBits 0xbe90, Model.ofBits 0xbe91, Model.ofBits 0xbe92, Model.ofBits 0xbe93, Model.ofBits 0xbe98, Model.ofBits 0xbe9a, Model.ofBits 0xbe9e, Model.ofBits 0xbe9f, Model.ofBits 0xbea0, Model.ofBits 0xbea2,
  Model.ofBits 0xbea3, Model.ofBits 0xbea4, Model.ofBits 0xbea5, Model.ofBits 0xbea7, Model.ofBits 0xbea9, Model.ofBits 0xbead, Model.ofBits 0xbeae, Model.ofBits 0xbeb0, Model.ofBits 0xbeb1, Model.ofBits 0xbeb3, Model.ofBits 0xbeb5, Model.ofBits 0xbeb7, Model.ofBits 0xbeb9, Model.ofBits 0xbeba, Model.ofBits 0xbebe, Model.ofBits 0xbec5,
  Model.ofBits 0xbec6, Model.ofBits 0xbec8, Model.ofBits 0xbec9, Model.ofBits 0xbecc, Model.ofBits 0xbecd, Model.ofBits 0xbece, Model.ofBits 0xbed5, Model.ofBits 0xbed6, Model.ofBits 0xbed7, Model.ofBits 0xbed9, Model.ofBits 0xbeda, Model.ofBits 0xbedc, Model.ofBits 0xbedd, Model.ofBits 0xbee1, Model.ofBits 0xbee2, Model.ofBits 0xbee3,
  Model.ofBits 0xbee8, Model.ofBits 0xbee9, Model.ofBits 0xbeec, Model.ofBits 0xbef2, Model.ofBits 0xbef3, Model.ofBits 0xbef6, Model.ofBits 0xbefb, Model.ofBits 0xbefc, Model.ofBits 0xbefd, Model.ofBits 0xbefe, Model.ofBits 0xbeff, Model.ofBits 0xbf00, Model.ofBits 0xbf01, Model.ofBits 0xbf02, Model.ofBits 0xbf03, Model.ofBits 0xbf04,
  Model.ofBits 0xbf05, Model.ofBits 0xbf06, Model.ofBits 0xbf07, Model.ofBits 0xbf08, Model.ofBits 0xbf09, Model.ofBits 0xbf0a, Model.ofBits 0xbf0b, Model.ofBits 0xbf0c, Model.ofBits 0xbf0d, Model.ofBits 0xbf0e, Model.ofBits 0xbf0f, Model.ofBits 0xbf10, Model.ofBits 0xbf11, Model.ofBits 0xbf12, Model.ofBits 0xbf14, Model.ofBits 0xbf15,
  Model.ofBits 0xbf16, Model.ofBits 0xbf17, Model.ofBits 0xbf18, Model.ofBits 0xbf1a, Model.ofBits 0xbf1b, Model.ofBits 0xbf1c, Model.ofBits 0xbf1d, Model.ofBits 0xbf1e, Model.ofBits 0xbf23, Model.ofBits 0xbf24, Model.ofBits 0xbf25, Model.ofBits 0xbf26, Model.ofBits 0xbf27, Model.ofBits 0xbf28, Model.ofBits 0xbf29, Model.ofBits 0xbf2a,
  Model.ofBits 0xbf2b, Model.ofBits 0xbf2c, Model.ofBits 0xbf2d, Model.ofBits 0xbf2f, Model.ofBits 0xbf30, Model.ofBits 0xbf31, Model.ofBits 0xbf32, Model.ofBits 0xbf33, Model.ofBits 0xbf34, Model.ofBits 0xbf35, Model.ofBits 0xbf36, Model.ofBits 0xbf37, Model.ofBits 0xbf38, Model.ofBits 0xbf39, Model.ofBits 0xbf3a, Model.ofBits 0xbf3b,
  Model.ofBits 0xbf3c, Model.ofBits 0xbf3d, Model.ofBits 0xbf3e, Model.ofBits 0xbf3f, Model.ofBits 0xbf40, Model.ofBits 0xbf41, Model.ofBits 0xbf42, Model.ofBits 0xbf44, Model.ofBits 0xbf45, Model.ofBits 0xbf46, Model.ofBits 0xbf47, Model.ofBits 0xbf49, Model.ofBits 0xbf4a, Model.ofBits 0xbf4b, Model.ofBits 0xbf4c, Model.ofBits 0xbf4d,
  Model.ofBits 0xbf4e, Model.ofBits 0xbf4f, Model.ofBits 0xbf50, Model.ofBits 0xbf51, Model.ofBits 0xbf52, Model.ofBits 0xbf53, Model.ofBits 0xbf54, Model.ofBits 0xbf55, Model.ofBits 0xbf56, Model.ofBits 0xbf58, Model.ofBits 0xbf59, Model.ofBits 0xbf5a, Model.ofBits 0xbf5b, Model.ofBits 0xbf5c, Model.ofBits 0xbf5d, Model.ofBits 0xbf5e,
  Model.ofBits 0xbf5f, Model.ofBits 0xbf60, Model.ofBits 0xbf61, Model.ofBits 0xbf62, Model.ofBits 0xbf63, Model.ofBits 0xbf64, Model.ofBits 0xbf65, Model.ofBits 0xbf66, Model.ofBits 0xbf68, Model.ofBits 0xbf69, Model.ofBits 0xbf6a, Model.ofBits 0xbf6b, Model.ofBits 0xbf6d, Model.ofBits 0xbf6f, Model.ofBits 0xbf70, Model.ofBits 0xbf71,
  Model.ofBits 0xbf72, Model.ofBits 0xbf73, Model.ofBits 0xbf75, Model.ofBits 0xbf76, Model.ofBits 0xbf77, Model.ofBits 0xbf78, Model.ofBits 0xbf7a, Model.ofBits 0xbf7b, Model.ofBits 0xbf7c, Model.ofBits 0xbf7d, Model.ofBits 0xbf7e, Model.ofBits 0xbf7f, Model.ofBits 0xbf80, Model.ofBits 0xbf81, Model.ofBits 0xbf82, Model.ofBits 0xbf83,
  Model.ofBits 0xbf84, Model.ofBits 0xbf85, Model.ofBits 0xbf86, Model.ofBits 0xbf87, Model.ofBits 0xbf88, Model.ofBits 0xbf89, Model.ofBits 0xbf8a, Model.ofBits 0xbf8b, Model.ofBits 0xbf8c, Model.ofBits 0xbf8d, Model.ofBits 0xbf8e, Model.ofBits 0xbf8f, Model.ofBits 0xbf90, Model.ofBits 0xbf91, Model.ofBits 0xbf92, Model.ofBits 0xbf93,
  Model.ofBits 0xbf94, Model.ofBits 0xbf95, Model.ofBits 0xbf96, Model.ofBits 0xbf97, Model.ofBits 0xbf98, Model.ofBits 0xbf99, Model.ofBits 0xbf9a, Model.ofBits 0xbf9b, Model.ofBits 0xbf9c, Model.ofBits 0xbf9d, Model.ofBits 0xbf9e, Model.ofBits 0xbf9f, Model.ofBits 0xbfa0, Model.ofBits 0xbfa1, Model.ofBits 0xbfa2, Model.ofBits 0xbfa3,
  Model.ofBits 0xbfa4, Model.ofBits 0xbfa5, Model.ofBits 0xbfa6, Model.ofBits 0xbfa7, Model.ofBits 0xbfa8, Model.ofBits 0xbfa9, Model.ofBits 0xbfaa, Model.ofBits 0xbfab, Model.ofBits 0xbfac, Model.ofBits 0xbfad, Model.ofBits 0xbfae, Model.ofBits 0xbfaf, Model.ofBits 0xbfb0, Model.ofBits 0xbfb1, Model.ofBits 0xbfb2, Model.ofBits 0xbfb3,
  Model.ofBits 0xbfb4, Model.ofBits 0xbfb5, Model.ofBits 0xbfb6, Model.ofBits 0xbfb7, Model.ofBits 0xbfb8, Model.ofBits 0xbfb9, Model.ofBits 0xbfba, Model.ofBits 0xbfbb, Model.ofBits 0xbfbc, Model.ofBits 0xbfbd, Model.ofBits 0xbfbe, Model.ofBits 0xbfbf, Model.ofBits 0xbfc0, Model.ofBits 0xbfc1, Model.ofBits 0xbfc2, Model.ofBits 0xbfc3,
  Model.ofBits 0xbfc4, Model.ofBits 0xbfc5, Model.ofBits 0xbfc6, Model.ofBits 0xbfc8, Model.ofBits 0xbfc9, Model.ofBits 0xbfca, Model.ofBits 0xbfcb, Model.ofBits 0xbfcc, Model.ofBits 0xbfcd, Model.ofBits 0xbfce, Model.ofBits 0xbfcf, Model.ofBits 0xbfd0, Model.ofBits 0xbfd1, Model.ofBits 0xbfd2, Model.ofBits 0xbfd3, Model.ofBits 0xbfd4,
  Model.ofBits 0xbfd5, Model.ofBits 0xbfd6, Model.ofBits 0xbfd7, Model.ofBits 0xbfd8, Model.ofBits 0xbfd9, Model.ofBits 0xbfda, Model.ofBits 0xbfdb, Model.ofBits 0xbfdc, Model.ofBits 0xbfdd, Model.ofBits 0xbfde, Model.ofBits 0xbfdf, Model.ofBits 0xbfe0, Model.ofBits 0xbfe1, Model.ofBits 0xbfe2, Model.ofBits 0xbfe3, Model.ofBits 0xbfe4,
  Model.ofBits 0xbfe5, Model.ofBits 0xbfe6, Model.ofBits 0xbfe7, Model.ofBits 0xbfe8, Model.ofBits 0xbfe9, Model.ofBits 0xbfea, Model.ofBits 0xbfeb, Model.ofBits 0xbfec, Model.ofBits 0xbfed, Model.ofBits 0xbfee, Model.ofBits 0xbfef, Model.ofBits 0xbff0, Model.ofBits 0xbff1, Model.ofBits 0xbff2, Model.ofBits 0xbff3, Model.ofBits 0xbff4,
  Model.ofBits 0xbff5, Model.ofBits 0xbff6, Model.ofBits 0xbff7, Model.ofBits 0xbff8, Model.ofBits 0xbff9, Model.ofBits 0xbffa, Model.ofBits 0xbffb, Model.ofBits 0xbffc, Model.ofBits 0xbffd, Model.ofBits 0xbffe, Model.ofBits 0xbfff, Model.ofBits 0xc000, Model.ofBits 0xc001, Model.ofBits 0xc002, Model.ofBits 0xc003, Model.ofBits 0xc004,
  Model.ofBits 0xc005, Model.ofBits 0xc006, Model.ofBits 0xc007, Model.ofBits 0xc008, Model.ofBits 0xc009, Model.ofBits 0xc00a, Model.ofBits 0xc00b, Model.ofBits 0xc00c, Model.ofBits 0xc00d, Model.ofBits 0xc00e, Model.ofBits 0xc00f, Model.ofBits 0xc010, Model.ofBits 0xc011, Model.ofBits 0xc012, Model.ofBits 0xc013, Model.ofBits 0xc014,
  Model.ofBits 0xc015, Model.ofBits 0xc016, Model.ofBits 0xc017, Model.ofBits 0xc018, Model.ofBits 0xc019, Model.ofBits 0xc01a, Model.ofBits 0xc01b, Model.ofBits 0xc01c, Model.ofBits 0xc01d, Model.ofBits 0xc01e, Model.ofBits 0xc01f, Model.ofBits 0xc020, Model.ofBits 0xc021, Model.ofBits 0xc022, Model.ofBits 0xc023, Model.ofBits 0xc024,
  Model.ofBits 0xc025, Model.ofBits 0xc026, Model.ofBits 0xc027, Model.ofBits 0xc028, Model.ofBits 0xc029, Model.ofBits 0xc02a, Model.ofBits 0xc02b, Model.ofBits 0xc02c, Model.ofBits 0xc02d, Model.ofBits 0xc02e, Model.ofBits 0xc02f, Model.ofBits 0xc030, Model.ofBits 0xc031, Model.ofBits 0xc032, Model.ofBits 0xc033, Model.ofBits 0xc034,
  Model.ofBits 0xc035, Model.ofBits 0xc036, Model.ofBits 0xc037, Model.ofBits 0xc038, Model.ofBits 0xc039, Model.ofBits 0xc03c, Model.ofBits 0xc03d, Model.ofBits 0xc03e, Model.ofBits 0xc03f, Model.ofBits 0xc040, Model.ofBits 0xc041, Model.ofBits 0xc044, Model.ofBits 0xc045, Model.ofBits 0xc047, Model.ofBits 0xc049, Model.ofBits 0xc04a,
  Model.ofBits 0xc04d, Model.ofBits 0xc050, Model.ofBits 0xc053, Model.ofBits 0xc059, Model.ofBits 0xc05b, Model.ofBits 0xc05c, Model.ofBits 0xc05d, Model.ofBits 0xc05f, Model.ofBits 0xc068, Model.ofBits 0xc06d, Model.ofBits 0xc078, Model.ofBits 0xc07a, Model.ofBits 0xc07b, Model.ofBits 0xc083, Model.ofBits 0xc086, Model.ofBits 0xc087,
  Model.ofBits 0xc08a, Model.ofBits 0xc08f, Model.ofBits 0xc091, Model.ofBits 0xc093, Model.ofBits 0xc095, Model.ofBits 0xc09b, Model.ofBits 0xc09d, Model.ofBits 0xc09e, Model.ofBits 0xc0ad, Model.ofBits 0xc0b2
]
def aLogIndices : List (List Nat) := [
  [
    848, 821, 826, 868, 870, 872, 832, 863, 803, 860, 855, 833, 870, 871, 864, 865,
    868, 863, 821, 813, 787, 850, 867, 866, 873, 872, 869, 838, 851, 855, 787, 781,
    663, 856, 857, 859, 843, 841, 818, 853, 861, 858, 829, 862, 868, 783, 798, 799
  ],
  [
    219, 173, 204, 369, 120, 358, 808, 89, 658, 408, 283, 160, 471, 682, 62, 278,
    347, 308, 323, 624, 267, 671, 714, 791, 40, 367, 628, 299, 351, 191, 418, 701,
    652, 678, 554, 767, 344, 211, 316, 210, 222, 193, 287, 280, 345, 308, 267, 267
  ],
  [
    364, 363, 354, 208, 123, 420, 313, 377, 292, 323, 295, 284, 272, 176, 326, 203,
    323, 532, 372, 85, 360, 241, 34, 26, 349, 326, 373, 45, 749, 210, 329, 341,
    337, 228, 695, 307, 378, 636, 370, 330, 141, 306, 290, 721, 204, 271, 381, 224
  ],
  [
    208, 337, 260, 228, 275, 309, 329, 696, 263, 400, 311, 216, 770, 780, 705, 192,
    684, 77, 648, 158, 239, 161, 96, 243, 170, 119, 277, 340, 184, 317, 349, 159,
    329, 348, 230, 371, 350, 137, 300, 732, 789, 777, 203, 268, 246, 740, 655, 647
  ],
  [
    151, 709, 442, 394, 401, 76, 593, 130, 699, 269, 121, 235, 114, 124, 417, 280,
    137, 131, 99, 124, 218, 205, 465, 257, 447, 429, 175, 340, 349, 359, 578, 598,
    692, 570, 592, 694, 236, 126, 203, 224, 741, 81, 504, 671, 580, 9, 302, 527
  ],
  [
    77, 74, 503, 325, 256, 298, 395, 433, 464, 84, 36, 148, 136, 551, 491, 701,
    164, 617, 190, 207, 199, 74, 139, 415, 659, 263, 495, 444, 163, 87, 134, 380,
    7, 757, 436, 729, 589, 525, 453, 331, 149, 357, 117, 72, 130, 697, 190, 762
  ],
  [
    781, 737, 815, 147, 301, 84, 307, 91, 335, 745, 46, 649, 120, 708, 425, 448,
    427, 54, 250, 441, 188, 589, 711, 549, 317, 285, 267, 329, 650, 279, 745, 682,
    568, 81, 79, 46, 817, 706, 837, 681, 785, 113, 271, 133, 305, 256, 17, 248
  ],
  [
    83, 62, 438, 38, 445, 510, 463, 678, 708, 551, 516, 633, 273, 511, 223, 16,
    458, 388, 287, 459, 224, 136, 298, 391, 0, 451, 92, 361, 422, 379, 713, 747,
    681, 572, 486, 481, 741, 755, 722, 767, 757, 671, 312, 539, 229, 596, 69, 700
  ],
  [
    449, 676, 552, 396, 264, 577, 538, 240, 79, 741, 705, 645, 336, 533, 289, 210,
    627, 307, 70, 477, 632, 304, 194, 349, 489, 277, 604, 493, 100, 20, 167, 328,
    42, 252, 236, 169, 27, 533, 4, 212, 143, 112, 1, 304, 662, 457, 208, 561
  ],
  [
    667, 637, 526, 50, 677, 474, 658, 488, 484, 328, 275, 308, 781, 790, 738, 599,
    209, 65, 612, 717, 708, 634, 229, 692, 407, 662, 661, 385, 710, 386, 213, 39,
    43, 641, 678, 656, 44, 139, 60, 650, 547, 574, 774, 773, 732, 630, 698, 553
  ],
  [
    695, 10, 456, 129, 503, 210, 528, 631, 22, 325, 71, 286, 80, 176, 104, 679,
    752, 668, 657, 491, 679, 397, 106, 520, 278, 635, 215, 219, 524, 234, 279, 335,
    238, 330, 78, 311, 707, 650, 666, 128, 719, 439, 313, 156, 343, 414, 489, 145
  ],
  [
    644, 548, 563, 706, 291, 640, 291, 374, 328, 259, 263, 292, 366, 271, 348, 204,
    809, 108, 555, 505, 589, 303, 152, 322, 660, 3, 699, 717, 5, 660, 657, 393,
    543, 462, 669, 699, 482, 712, 651, 204, 209, 127, 787, 15, 681, 582, 704, 688
  ],
  [
    700, 759, 566, 541, 675, 706, 209, 633, 265, 44, 725, 144, 745, 806, 700, 515,
    643, 638, 569, 413, 53, 672, 689, 734, 138, 600, 227, 737, 700, 652, 730, 240,
    644, 710, 649, 665, 532, 778, 670, 666, 675, 673, 524, 249, 501, 518, 685, 732
  ],
  [
    767, 772, 696, 319, 246, 292, 135, 248, 235, 714, 798, 555, 782, 640, 684, 629,
    716, 721, 93, 293, 177, 669, 723, 761, 624, 297, 668, 355, 704, 338, 628, 678,
    703, 154, 523, 209, 504, 534, 497, 483, 325, 135, 505, 479, 551, 468, 100, 458
  ],
  [
    792, 502, 688, 664, 320, 576, 595, 739, 695, 153, 773, 142, 661, 797, 540, 663,
    780, 753, 722, 403, 781, 668, 230, 558, 602, 148, 535, 560, 670, 661, 109, 435,
    513, 753, 756, 742, 676, 756, 616, 211, 724, 108, 636, 570, 606, 590, 654, 508
  ],
  [
    782, 744, 735, 784, 218, 785, 820, 849, 844, 831, 836, 838, 675, 672, 638, 745,
    666, 725, 614, 682, 6, 116, 654, 180, 615, 703, 567, 666, 712, 694, 741, 31,
    702, 725, 782, 782, 758, 765, 661, 692, 716, 698, 460, 617, 55, 476, 681, 636
  ],
  [
    779, 118, 720, 795, 753, 799, 89, 759, 105, 759, 737, 757, 781, 775, 788, 788,
    640, 768, 795, 807, 794, 518, 670, 571, 760, 781, 762, 587, 750, 528, 623, 485,
    753, 509, 770, 665, 658, 762, 677, 103, 703, 568, 732, 19, 506, 679, 655, 637
  ],
  [
    787, 755, 741, 797, 795, 786, 667, 702, 669, 691, 790, 784, 495, 738, 416, 631,
    696, 681, 796, 781, 793, 98, 782, 514, 779, 805, 791, 738, 668, 696, 700, 670,
    779, 737, 782, 791, 546, 782, 673, 697, 677, 798, 803, 727, 801, 185, 687, 244
  ],
  [
    802, 733, 794, 480, 280, 30, 322, 562, 303, 746, 554, 781, 592, 753, 679, 646,
    654, 543, 85, 633, 283, 625, 734, 557, 307, 276, 274, 268, 682, 314, 704, 694,
    642, 481, 472, 421, 819, 681, 840, 776, 795, 616, 247, 11, 274, 268, 411, 232
  ],
  [
    604, 585, 671, 669, 609, 597, 764, 715, 698, 622, 520, 571, 213, 560, 147, 521,
    583, 586, 201, 623, 228, 424, 237, 99, 603, 624, 509, 357, 492, 376, 775, 784,
    731, 659, 671, 759, 761, 765, 735, 808, 784, 749, 220, 575, 198, 675, 406, 732
  ],
  [
    543, 684, 487, 614, 232, 733, 508, 224, 638, 739, 777, 790, 327, 624, 294, 206,
    621, 287, 771, 440, 623, 290, 187, 333, 554, 252, 623, 473, 584, 533, 455, 329,
    587, 213, 203, 140, 437, 623, 32, 475, 2, 59, 95, 260, 654, 587, 196, 727
  ],
  [
    753, 718, 643, 466, 702, 28, 679, 605, 534, 315, 264, 296, 762, 766, 734, 48,
    189, 550, 772, 745, 748, 658, 221, 572, 695, 755, 782, 382, 814, 384, 450, 566,
    566, 648, 707, 670, 556, 8, 41, 768, 619, 673, 781, 782, 762, 552, 771, 749
  ],
  [
    702, 105, 757, 182, 680, 57, 597, 739, 515, 249, 569, 306, 404, 149, 402, 732,
    790, 642, 693, 512, 725, 727, 444, 616, 204, 650, 255, 252, 668, 172, 213, 326,
    268, 308, 529, 327, 778, 628, 703, 90, 726, 469, 337, 126, 312, 459, 480, 68
  ],
  [
    665, 686, 759, 748, 278, 693, 294, 365, 323, 268, 233, 231, 335, 242, 353, 202,
    803, 544, 600, 591, 676, 290, 94, 323, 769, 480, 677, 676, 442, 783, 594, 470,
    674, 747, 719, 606, 657, 764, 537, 126, 221, 207, 809, 399, 748, 676, 785, 748
  ],
  [
    729, 783, 628, 783, 696, 676, 243, 699, 200, 112, 767, 150, 760, 819, 784, 725,
    718, 690, 66, 500, 561, 735, 742, 716, 164, 674, 221, 744, 700, 647, 678, 210,
    749, 741, 701, 697, 701, 790, 598, 688, 689, 677, 592, 266, 667, 648, 686, 731
  ],
  [
    713, 750, 747, 327, 258, 311, 153, 253, 222, 782, 794, 699, 731, 694, 797, 766,
    765, 697, 102, 304, 153, 748, 706, 634, 723, 293, 697, 353, 737, 342, 676, 697,
    714, 128, 519, 195, 647, 705, 692, 511, 323, 387, 579, 536, 663, 75, 101, 691
  ],
  [
    737, 570, 789, 630, 310, 716, 737, 780, 592, 111, 780, 676, 622, 768, 419, 698,
    765, 748, 779, 535, 781, 660, 226, 712, 598, 124, 596, 634, 681, 686, 62, 432,
    491, 714, 732, 732, 662, 762, 688, 85, 799, 162, 693, 681, 691, 638, 680, 670
  ],
  [
    800, 772, 740, 797, 240, 780, 836, 846, 818, 825, 835, 831, 721, 713, 660, 767,
    760, 784, 576, 723, 515, 107, 452, 171, 642, 756, 682, 716, 711, 728, 745, 392,
    780, 744, 803, 805, 713, 789, 796, 764, 798, 802, 51, 618, 434, 677, 634, 722
  ],
  [
    781, 86, 780, 786, 758, 794, 460, 739, 49, 752, 753, 750, 808, 781, 819, 763,
    692, 748, 794, 802, 789, 616, 697, 593, 780, 768, 758, 710, 779, 710, 719, 582,
    802, 719, 793, 592, 724, 777, 701, 134, 689, 604, 794, 461, 700, 664, 687, 701
  ],
  [
    752, 803, 789, 727, 762, 769, 760, 742, 783, 800, 800, 761, 390, 810, 398, 712,
    770, 714, 792, 794, 795, 559, 729, 498, 792, 794, 779, 797, 747, 791, 755, 741,
    790, 819, 821, 794, 789, 795, 704, 809, 794, 794, 800, 793, 794, 214, 768, 229
  ],
  [
    802, 731, 802, 499, 267, 544, 314, 666, 308, 779, 667, 774, 604, 787, 684, 687,
    707, 670, 288, 669, 135, 676, 737, 721, 276, 280, 310, 323, 744, 281, 645, 725,
    739, 654, 629, 656, 836, 691, 810, 575, 794, 744, 244, 494, 245, 146, 478, 238
  ],
  [
    648, 580, 628, 693, 663, 711, 748, 711, 746, 604, 501, 557, 165, 600, 231, 638,
    609, 610, 229, 667, 246, 493, 258, 58, 683, 690, 589, 368, 440, 356, 750, 797,
    725, 772, 734, 727, 742, 758, 743, 735, 781, 791, 184, 580, 217, 655, 29, 702
  ],
  [
    499, 691, 546, 653, 252, 710, 575, 238, 590, 751, 774, 701, 318, 587, 337, 251,
    590, 306, 766, 82, 637, 303, 203, 334, 584, 132, 667, 409, 651, 517, 586, 323,
    21, 220, 208, 155, 35, 536, 410, 544, 512, 110, 63, 261, 675, 730, 197, 672
  ],
  [
    613, 731, 703, 426, 699, 13, 651, 586, 579, 305, 282, 317, 752, 752, 726, 505,
    203, 91, 738, 745, 768, 672, 199, 701, 702, 747, 742, 384, 812, 383, 431, 412,
    530, 676, 717, 651, 565, 33, 542, 624, 625, 761, 783, 781, 772, 779, 796, 763
  ],
  [
    668, 64, 782, 157, 696, 62, 617, 705, 525, 293, 564, 309, 554, 37, 520, 698,
    789, 654, 738, 503, 746, 655, 522, 730, 241, 597, 220, 225, 684, 262, 231, 332,
    268, 311, 545, 324, 660, 602, 725, 423, 744, 465, 339, 166, 321, 39, 430, 405
  ],
  [
    667, 690, 755, 692, 293, 755, 325, 375, 307, 255, 255, 281, 352, 236, 362, 555,
    785, 115, 713, 555, 700, 301, 153, 319, 680, 73, 739, 729, 389, 669, 744, 467,
    758, 606, 749, 734, 639, 739, 593, 149, 178, 201, 739, 56, 785, 690, 783, 709
  ],
  [
    702, 788, 733, 664, 776, 781, 256, 697, 230, 179, 780, 122, 751, 819, 769, 734,
    730, 728, 652, 581, 24, 768, 762, 773, 186, 668, 174, 601, 642, 690, 681, 242,
    746, 742, 711, 708, 684, 807, 734, 736, 724, 744, 661, 216, 633, 707, 680, 654
  ],
  [
    762, 783, 751, 314, 254, 327, 120, 257, 183, 654, 736, 711, 687, 662, 782, 718,
    727, 633, 14, 312, 97, 747, 751, 713, 754, 270, 597, 356, 761, 346, 669, 745,
    714, 192, 562, 161, 656, 666, 645, 496, 329, 47, 603, 611, 674, 463, 52, 659
  ],
  [
    785, 595, 790, 461, 331, 696, 706, 803, 772, 531, 800, 534, 595, 789, 517, 720,
    787, 693, 800, 23, 785, 620, 156, 729, 624, 148, 573, 688, 781, 724, 443, 25,
    67, 788, 793, 793, 660, 740, 671, 124, 751, 61, 687, 697, 713, 608, 718, 588
  ],
  [
    767, 802, 809, 800, 233, 779, 811, 847, 836, 825, 823, 818, 715, 743, 734, 804,
    781, 786, 705, 781, 763, 125, 428, 168, 774, 783, 705, 768, 753, 750, 762, 615,
    794, 720, 811, 795, 791, 813, 738, 808, 791, 794, 446, 668, 626, 657, 688, 697
  ],
  [
    810, 608, 688, 816, 800, 694, 12, 797, 18, 797, 797, 796, 815, 819, 777, 796,
    717, 809, 722, 814, 790, 607, 746, 657, 807, 802, 813, 741, 804, 731, 804, 724,
    747, 737, 819, 727, 758, 781, 738, 568, 744, 88, 697, 507, 786, 743, 787, 779
  ],
  [
    799, 793, 816, 797, 792, 787, 765, 782, 773, 788, 824, 811, 651, 804, 655, 717,
    736, 760, 816, 801, 811, 714, 810, 667, 805, 820, 819, 800, 754, 800, 809, 777,
    805, 805, 810, 814, 686, 807, 787, 759, 797, 808, 808, 785, 824, 181, 771, 454
  ],
  [
    704, 715, 627, 819, 824, 814, 825, 822, 821, 806, 650, 808, 800, 811, 768, 736,
    801, 674, 756, 804, 803, 666, 707, 701, 807, 804, 769, 780, 799, 795, 807, 818,
    824, 734, 825, 763, 818, 828, 833, 805, 834, 790, 792, 792, 807, 812, 693, 783
  ],
  [
    823, 830, 822, 780, 154, 782, 819, 683, 790, 815, 822, 822, 744, 490, 753, 753,
    640, 699, 760, 810, 814, 761, 802, 821, 786, 772, 782, 790, 800, 716, 770, 787,
    755, 772, 738, 810, 786, 787, 780, 799, 822, 784, 793, 818, 809, 592, 683, 587
  ],
  [
    780, 755, 758, 682, 802, 808, 777, 743, 738, 769, 670, 799, 816, 794, 807, 821,
    629, 753, 827, 802, 820, 817, 826, 731, 783, 806, 816, 782, 815, 735, 746, 800,
    766, 739, 707, 769, 828, 827, 818, 782, 790, 822, 742, 796, 755, 724, 661, 793
  ],
  [
    734, 807, 734, 756, 842, 813, 731, 776, 725, 627, 815, 599, 811, 748, 809, 827,
    815, 831, 212, 828, 223, 832, 826, 831, 834, 763, 814, 625, 779, 628, 836, 845,
    840, 687, 808, 677, 825, 839, 825, 644, 747, 715, 824, 824, 819, 802, 813, 811
  ],
  [
    811, 808, 817, 819, 820, 823, 756, 813, 776, 698, 783, 681, 825, 654, 827, 783,
    819, 805, 775, 688, 810, 764, 735, 802, 806, 824, 811, 827, 726, 823, 814, 826,
    817, 705, 791, 723, 810, 742, 810, 785, 745, 772, 811, 760, 795, 730, 805, 749
  ],
  [
    690, 720, 586, 784, 793, 827, 721, 782, 686, 823, 826, 841, 659, 808, 719, 824,
    827, 830, 629, 820, 580, 728, 624, 697, 748, 793, 768, 788, 788, 784, 828, 780,
    820, 826, 825, 833, 852, 855, 854, 620, 822, 680, 742, 798, 809, 783, 631, 811
  ]
]
def aLogCap : BF := BFloat16DyadicBounds.ceiling 1 3
def aLog (layer : Fin 48) : Fin 48 → BF := raw aLogDictionary aLogIndices layer

theorem aLogCap_real : Model.toReal aLogCap = 8 := by
  have h := (BFloat16DyadicBounds.ceiling_range 1 3 (by decide) (by decide) (by decide)).2
  norm_num at h
  exact h

set_option maxRecDepth 30000 in
set_option maxHeartbeats 0 in
theorem aLog_checked : TensorWords.check aLogDictionary aLogCap = true := by decide +kernel

set_option maxRecDepth 30000 in
set_option maxHeartbeats 0 in
theorem aLog_dimensions : aLogDictionary.length = 874 ∧ aLogIndices.length = 48 ∧
    aLogIndices.all (fun row => decide (row.length = 48) && row.all (fun i => decide (i < 874))) = true := by
  decide +kernel

theorem aLog_bound (layer : Fin 48) (i : Fin 48) :
    Model.isFinite (aLog layer i) = true ∧ |Model.toReal (aLog layer i)| ≤ 8 := by
  have fallback : Model.isFinite CheckpointRanges.zeroCap = true ∧
      |Model.toReal CheckpointRanges.zeroCap| ≤ Model.toReal aLogCap := by
    refine ⟨by decide +kernel, ?_⟩
    rw [CheckpointRanges.zeroCap_real, aLogCap_real]
    norm_num
  simpa only [aLog, raw, aLogCap_real] using
    TensorWords.check_getD aLogDictionary aLogCap CheckpointRanges.zeroCap aLog_checked fallback
      ((aLogIndices[layer.val]?.getD [])[i.val]?.getD 0)

def dtBiasDictionary : List BF := [
  Model.ofBits 0x3c27, Model.ofBits 0x3c58, Model.ofBits 0x3c5f, Model.ofBits 0x3c6a, Model.ofBits 0x3d10, Model.ofBits 0x3d16, Model.ofBits 0x3d26, Model.ofBits 0x3d2c, Model.ofBits 0x3d38, Model.ofBits 0x3d67, Model.ofBits 0x3d75, Model.ofBits 0x3d80, Model.ofBits 0x3d81, Model.ofBits 0x3d87, Model.ofBits 0x3d94, Model.ofBits 0x3da7,
  Model.ofBits 0x3daa, Model.ofBits 0x3db7, Model.ofBits 0x3dc1, Model.ofBits 0x3dc2, Model.ofBits 0x3de7, Model.ofBits 0x3deb, Model.ofBits 0x3e02, Model.ofBits 0x3e08, Model.ofBits 0x3e17, Model.ofBits 0x3e2a, Model.ofBits 0x3e42, Model.ofBits 0x3e4c, Model.ofBits 0x3e4f, Model.ofBits 0x3e54, Model.ofBits 0x3e63, Model.ofBits 0x3e6b,
  Model.ofBits 0x3e6d, Model.ofBits 0x3e74, Model.ofBits 0x3e75, Model.ofBits 0x3e7b, Model.ofBits 0x3e7f, Model.ofBits 0x3e80, Model.ofBits 0x3e86, Model.ofBits 0x3e8e, Model.ofBits 0x3e96, Model.ofBits 0x3ea1, Model.ofBits 0x3ea2, Model.ofBits 0x3eaa, Model.ofBits 0x3eb4, Model.ofBits 0x3ebb, Model.ofBits 0x3ebc, Model.ofBits 0x3ec1,
  Model.ofBits 0x3ec2, Model.ofBits 0x3ec4, Model.ofBits 0x3ecc, Model.ofBits 0x3ed2, Model.ofBits 0x3ed3, Model.ofBits 0x3eda, Model.ofBits 0x3edc, Model.ofBits 0x3edf, Model.ofBits 0x3ee1, Model.ofBits 0x3ee4, Model.ofBits 0x3ef2, Model.ofBits 0x3ef7, Model.ofBits 0x3efc, Model.ofBits 0x3efe, Model.ofBits 0x3f01, Model.ofBits 0x3f02,
  Model.ofBits 0x3f04, Model.ofBits 0x3f05, Model.ofBits 0x3f07, Model.ofBits 0x3f09, Model.ofBits 0x3f0a, Model.ofBits 0x3f0c, Model.ofBits 0x3f0d, Model.ofBits 0x3f14, Model.ofBits 0x3f17, Model.ofBits 0x3f1a, Model.ofBits 0x3f1b, Model.ofBits 0x3f1d, Model.ofBits 0x3f1f, Model.ofBits 0x3f20, Model.ofBits 0x3f21, Model.ofBits 0x3f24,
  Model.ofBits 0x3f27, Model.ofBits 0x3f28, Model.ofBits 0x3f29, Model.ofBits 0x3f2a, Model.ofBits 0x3f2b, Model.ofBits 0x3f2c, Model.ofBits 0x3f30, Model.ofBits 0x3f32, Model.ofBits 0x3f33, Model.ofBits 0x3f36, Model.ofBits 0x3f3a, Model.ofBits 0x3f3b, Model.ofBits 0x3f3c, Model.ofBits 0x3f41, Model.ofBits 0x3f42, Model.ofBits 0x3f44,
  Model.ofBits 0x3f46, Model.ofBits 0x3f51, Model.ofBits 0x3f52, Model.ofBits 0x3f55, Model.ofBits 0x3f56, Model.ofBits 0x3f59, Model.ofBits 0x3f5c, Model.ofBits 0x3f5e, Model.ofBits 0x3f60, Model.ofBits 0x3f62, Model.ofBits 0x3f67, Model.ofBits 0x3f68, Model.ofBits 0x3f6b, Model.ofBits 0x3f6c, Model.ofBits 0x3f6f, Model.ofBits 0x3f71,
  Model.ofBits 0x3f72, Model.ofBits 0x3f74, Model.ofBits 0x3f75, Model.ofBits 0x3f78, Model.ofBits 0x3f79, Model.ofBits 0x3f7a, Model.ofBits 0x3f7d, Model.ofBits 0x3f80, Model.ofBits 0x3f81, Model.ofBits 0x3f83, Model.ofBits 0x3f84, Model.ofBits 0x3f85, Model.ofBits 0x3f86, Model.ofBits 0x3f87, Model.ofBits 0x3f88, Model.ofBits 0x3f89,
  Model.ofBits 0x3f8b, Model.ofBits 0x3f8d, Model.ofBits 0x3f8f, Model.ofBits 0x3f90, Model.ofBits 0x3f91, Model.ofBits 0x3f92, Model.ofBits 0x3f93, Model.ofBits 0x3f94, Model.ofBits 0x3f95, Model.ofBits 0x3f96, Model.ofBits 0x3f98, Model.ofBits 0x3f9a, Model.ofBits 0x3f9c, Model.ofBits 0x3f9d, Model.ofBits 0x3f9e, Model.ofBits 0x3fa1,
  Model.ofBits 0x3fa2, Model.ofBits 0x3fa4, Model.ofBits 0x3fa6, Model.ofBits 0x3fa8, Model.ofBits 0x3fa9, Model.ofBits 0x3faa, Model.ofBits 0x3fac, Model.ofBits 0x3faf, Model.ofBits 0x3fb2, Model.ofBits 0x3fb4, Model.ofBits 0x3fb5, Model.ofBits 0x3fb6, Model.ofBits 0x3fb9, Model.ofBits 0x3fbb, Model.ofBits 0x3fbd, Model.ofBits 0x3fbe,
  Model.ofBits 0x3fc0, Model.ofBits 0x3fc1, Model.ofBits 0x3fc2, Model.ofBits 0x3fc3, Model.ofBits 0x3fc4, Model.ofBits 0x3fc6, Model.ofBits 0x3fc7, Model.ofBits 0x3fc9, Model.ofBits 0x3fca, Model.ofBits 0x3fcb, Model.ofBits 0x3fcd, Model.ofBits 0x3fd0, Model.ofBits 0x3fd2, Model.ofBits 0x3fd3, Model.ofBits 0x3fd5, Model.ofBits 0x3fd7,
  Model.ofBits 0x3fd8, Model.ofBits 0x3fd9, Model.ofBits 0x3fdc, Model.ofBits 0x3fde, Model.ofBits 0x3fdf, Model.ofBits 0x3fe5, Model.ofBits 0x3fe7, Model.ofBits 0x3feb, Model.ofBits 0x3fec, Model.ofBits 0x3fed, Model.ofBits 0x3ff1, Model.ofBits 0x3ff2, Model.ofBits 0x3ff4, Model.ofBits 0x3ff6, Model.ofBits 0x3ff8, Model.ofBits 0x3ff9,
  Model.ofBits 0x3fff, Model.ofBits 0x4000, Model.ofBits 0x4004, Model.ofBits 0x4005, Model.ofBits 0x4008, Model.ofBits 0x4009, Model.ofBits 0x400b, Model.ofBits 0x400d, Model.ofBits 0x400e, Model.ofBits 0x400f, Model.ofBits 0x4010, Model.ofBits 0x4011, Model.ofBits 0x4012, Model.ofBits 0x4013, Model.ofBits 0x4014, Model.ofBits 0x4017,
  Model.ofBits 0x4018, Model.ofBits 0x401a, Model.ofBits 0x401d, Model.ofBits 0x401e, Model.ofBits 0x401f, Model.ofBits 0x4020, Model.ofBits 0x4024, Model.ofBits 0x4025, Model.ofBits 0x4026, Model.ofBits 0x4027, Model.ofBits 0x402c, Model.ofBits 0x402f, Model.ofBits 0x4034, Model.ofBits 0x403a, Model.ofBits 0x403b, Model.ofBits 0x4043,
  Model.ofBits 0x4045, Model.ofBits 0x4046, Model.ofBits 0x404c, Model.ofBits 0x404f, Model.ofBits 0x4053, Model.ofBits 0x4059, Model.ofBits 0x405a, Model.ofBits 0x4070, Model.ofBits 0x4076, Model.ofBits 0x4077, Model.ofBits 0x4081, Model.ofBits 0x4088, Model.ofBits 0x408d, Model.ofBits 0x408f, Model.ofBits 0x4093, Model.ofBits 0x4094,
  Model.ofBits 0x40a2, Model.ofBits 0x40a6, Model.ofBits 0x40a8, Model.ofBits 0x40ad, Model.ofBits 0x40bd, Model.ofBits 0x40be, Model.ofBits 0x40c1, Model.ofBits 0x40ca, Model.ofBits 0x40cd, Model.ofBits 0x40d3, Model.ofBits 0x40de, Model.ofBits 0x40e0, Model.ofBits 0x4102, Model.ofBits 0x4116, Model.ofBits 0x4119, Model.ofBits 0x4124,
  Model.ofBits 0x414a, Model.ofBits 0x414c, Model.ofBits 0x4152, Model.ofBits 0x4153, Model.ofBits 0x4157, Model.ofBits 0x4160, Model.ofBits 0x416d, Model.ofBits 0x416e, Model.ofBits 0x4176, Model.ofBits 0x4183, Model.ofBits 0x4193, Model.ofBits 0x419a, Model.ofBits 0xbc49, Model.ofBits 0xbc4b, Model.ofBits 0xbc5c, Model.ofBits 0xbcc5,
  Model.ofBits 0xbccf, Model.ofBits 0xbce5, Model.ofBits 0xbcf3, Model.ofBits 0xbcf5, Model.ofBits 0xbd08, Model.ofBits 0xbd0e, Model.ofBits 0xbd19, Model.ofBits 0xbd30, Model.ofBits 0xbd5c, Model.ofBits 0xbd67, Model.ofBits 0xbd6c, Model.ofBits 0xbd91, Model.ofBits 0xbd9a, Model.ofBits 0xbda2, Model.ofBits 0xbdab, Model.ofBits 0xbdb9,
  Model.ofBits 0xbdbb, Model.ofBits 0xbdc2, Model.ofBits 0xbdc8, Model.ofBits 0xbdcb, Model.ofBits 0xbdd4, Model.ofBits 0xbdd6, Model.ofBits 0xbddc, Model.ofBits 0xbde3, Model.ofBits 0xbdfc, Model.ofBits 0xbe03, Model.ofBits 0xbe0a, Model.ofBits 0xbe0e, Model.ofBits 0xbe12, Model.ofBits 0xbe13, Model.ofBits 0xbe18, Model.ofBits 0xbe1d,
  Model.ofBits 0xbe28, Model.ofBits 0xbe2a, Model.ofBits 0xbe2b, Model.ofBits 0xbe32, Model.ofBits 0xbe37, Model.ofBits 0xbe3b, Model.ofBits 0xbe41, Model.ofBits 0xbe47, Model.ofBits 0xbe4a, Model.ofBits 0xbe4e, Model.ofBits 0xbe54, Model.ofBits 0xbe59, Model.ofBits 0xbe5c, Model.ofBits 0xbe63, Model.ofBits 0xbe6d, Model.ofBits 0xbe6f,
  Model.ofBits 0xbe74, Model.ofBits 0xbe76, Model.ofBits 0xbe7b, Model.ofBits 0xbe7d, Model.ofBits 0xbe88, Model.ofBits 0xbe8c, Model.ofBits 0xbe90, Model.ofBits 0xbe92, Model.ofBits 0xbe98, Model.ofBits 0xbe9c, Model.ofBits 0xbe9d, Model.ofBits 0xbe9e, Model.ofBits 0xbea2, Model.ofBits 0xbeab, Model.ofBits 0xbead, Model.ofBits 0xbeae,
  Model.ofBits 0xbeaf, Model.ofBits 0xbeb3, Model.ofBits 0xbeb6, Model.ofBits 0xbeb9, Model.ofBits 0xbebb, Model.ofBits 0xbebc, Model.ofBits 0xbebd, Model.ofBits 0xbec6, Model.ofBits 0xbec7, Model.ofBits 0xbecb, Model.ofBits 0xbecd, Model.ofBits 0xbed8, Model.ofBits 0xbedf, Model.ofBits 0xbee0, Model.ofBits 0xbee2, Model.ofBits 0xbee6,
  Model.ofBits 0xbeea, Model.ofBits 0xbeeb, Model.ofBits 0xbef6, Model.ofBits 0xbef9, Model.ofBits 0xbefb, Model.ofBits 0xbefd, Model.ofBits 0xbefe, Model.ofBits 0xbf03, Model.ofBits 0xbf04, Model.ofBits 0xbf05, Model.ofBits 0xbf06, Model.ofBits 0xbf08, Model.ofBits 0xbf09, Model.ofBits 0xbf0c, Model.ofBits 0xbf12, Model.ofBits 0xbf13,
  Model.ofBits 0xbf14, Model.ofBits 0xbf15, Model.ofBits 0xbf18, Model.ofBits 0xbf1a, Model.ofBits 0xbf1b, Model.ofBits 0xbf1c, Model.ofBits 0xbf1d, Model.ofBits 0xbf1e, Model.ofBits 0xbf1f, Model.ofBits 0xbf21, Model.ofBits 0xbf22, Model.ofBits 0xbf23, Model.ofBits 0xbf25, Model.ofBits 0xbf26, Model.ofBits 0xbf28, Model.ofBits 0xbf29,
  Model.ofBits 0xbf2b, Model.ofBits 0xbf2c, Model.ofBits 0xbf2e, Model.ofBits 0xbf2f, Model.ofBits 0xbf30, Model.ofBits 0xbf33, Model.ofBits 0xbf36, Model.ofBits 0xbf39, Model.ofBits 0xbf3a, Model.ofBits 0xbf3b, Model.ofBits 0xbf3c, Model.ofBits 0xbf3d, Model.ofBits 0xbf3e, Model.ofBits 0xbf3f, Model.ofBits 0xbf40, Model.ofBits 0xbf42,
  Model.ofBits 0xbf43, Model.ofBits 0xbf45, Model.ofBits 0xbf46, Model.ofBits 0xbf48, Model.ofBits 0xbf49, Model.ofBits 0xbf4a, Model.ofBits 0xbf4b, Model.ofBits 0xbf53, Model.ofBits 0xbf54, Model.ofBits 0xbf55, Model.ofBits 0xbf57, Model.ofBits 0xbf59, Model.ofBits 0xbf5b, Model.ofBits 0xbf5e, Model.ofBits 0xbf5f, Model.ofBits 0xbf60,
  Model.ofBits 0xbf61, Model.ofBits 0xbf62, Model.ofBits 0xbf65, Model.ofBits 0xbf66, Model.ofBits 0xbf68, Model.ofBits 0xbf69, Model.ofBits 0xbf6a, Model.ofBits 0xbf6b, Model.ofBits 0xbf6c, Model.ofBits 0xbf6d, Model.ofBits 0xbf6f, Model.ofBits 0xbf70, Model.ofBits 0xbf73, Model.ofBits 0xbf74, Model.ofBits 0xbf75, Model.ofBits 0xbf78,
  Model.ofBits 0xbf79, Model.ofBits 0xbf7a, Model.ofBits 0xbf7b, Model.ofBits 0xbf7d, Model.ofBits 0xbf7e, Model.ofBits 0xbf7f, Model.ofBits 0xbf81, Model.ofBits 0xbf82, Model.ofBits 0xbf83, Model.ofBits 0xbf84, Model.ofBits 0xbf85, Model.ofBits 0xbf86, Model.ofBits 0xbf87, Model.ofBits 0xbf88, Model.ofBits 0xbf89, Model.ofBits 0xbf8a,
  Model.ofBits 0xbf8b, Model.ofBits 0xbf8c, Model.ofBits 0xbf8d, Model.ofBits 0xbf8e, Model.ofBits 0xbf8f, Model.ofBits 0xbf90, Model.ofBits 0xbf91, Model.ofBits 0xbf92, Model.ofBits 0xbf93, Model.ofBits 0xbf94, Model.ofBits 0xbf95, Model.ofBits 0xbf96, Model.ofBits 0xbf97, Model.ofBits 0xbf98, Model.ofBits 0xbf99, Model.ofBits 0xbf9a,
  Model.ofBits 0xbf9b, Model.ofBits 0xbf9c, Model.ofBits 0xbf9d, Model.ofBits 0xbf9f, Model.ofBits 0xbfa0, Model.ofBits 0xbfa1, Model.ofBits 0xbfa3, Model.ofBits 0xbfa4, Model.ofBits 0xbfa5, Model.ofBits 0xbfa6, Model.ofBits 0xbfa7, Model.ofBits 0xbfaa, Model.ofBits 0xbfac, Model.ofBits 0xbfad, Model.ofBits 0xbfae, Model.ofBits 0xbfaf,
  Model.ofBits 0xbfb0, Model.ofBits 0xbfb1, Model.ofBits 0xbfb2, Model.ofBits 0xbfb3, Model.ofBits 0xbfb5, Model.ofBits 0xbfb6, Model.ofBits 0xbfb7, Model.ofBits 0xbfb9, Model.ofBits 0xbfba, Model.ofBits 0xbfbb, Model.ofBits 0xbfbc, Model.ofBits 0xbfbd, Model.ofBits 0xbfbe, Model.ofBits 0xbfbf, Model.ofBits 0xbfc0, Model.ofBits 0xbfc1,
  Model.ofBits 0xbfc2, Model.ofBits 0xbfc4, Model.ofBits 0xbfc5, Model.ofBits 0xbfc6, Model.ofBits 0xbfc7, Model.ofBits 0xbfc8, Model.ofBits 0xbfc9, Model.ofBits 0xbfca, Model.ofBits 0xbfcb, Model.ofBits 0xbfcc, Model.ofBits 0xbfcd, Model.ofBits 0xbfce, Model.ofBits 0xbfd0, Model.ofBits 0xbfd1, Model.ofBits 0xbfd2, Model.ofBits 0xbfd3,
  Model.ofBits 0xbfd4, Model.ofBits 0xbfd5, Model.ofBits 0xbfd6, Model.ofBits 0xbfd8, Model.ofBits 0xbfd9, Model.ofBits 0xbfda, Model.ofBits 0xbfdb, Model.ofBits 0xbfdc, Model.ofBits 0xbfdd, Model.ofBits 0xbfde, Model.ofBits 0xbfdf, Model.ofBits 0xbfe0, Model.ofBits 0xbfe1, Model.ofBits 0xbfe2, Model.ofBits 0xbfe3, Model.ofBits 0xbfe4,
  Model.ofBits 0xbfe5, Model.ofBits 0xbfe6, Model.ofBits 0xbfe7, Model.ofBits 0xbfe9, Model.ofBits 0xbfea, Model.ofBits 0xbfeb, Model.ofBits 0xbfec, Model.ofBits 0xbfed, Model.ofBits 0xbfee, Model.ofBits 0xbfef, Model.ofBits 0xbff0, Model.ofBits 0xbff1, Model.ofBits 0xbff2, Model.ofBits 0xbff3, Model.ofBits 0xbff4, Model.ofBits 0xbff5,
  Model.ofBits 0xbff6, Model.ofBits 0xbff7, Model.ofBits 0xbff8, Model.ofBits 0xbff9, Model.ofBits 0xbffa, Model.ofBits 0xbffb, Model.ofBits 0xbffc, Model.ofBits 0xbffd, Model.ofBits 0xbffe, Model.ofBits 0xbfff, Model.ofBits 0xc001, Model.ofBits 0xc002, Model.ofBits 0xc003, Model.ofBits 0xc004, Model.ofBits 0xc005, Model.ofBits 0xc006,
  Model.ofBits 0xc007, Model.ofBits 0xc008, Model.ofBits 0xc009, Model.ofBits 0xc00a, Model.ofBits 0xc00c, Model.ofBits 0xc00d, Model.ofBits 0xc00e, Model.ofBits 0xc00f, Model.ofBits 0xc010, Model.ofBits 0xc011, Model.ofBits 0xc012, Model.ofBits 0xc013, Model.ofBits 0xc014, Model.ofBits 0xc015, Model.ofBits 0xc016, Model.ofBits 0xc017,
  Model.ofBits 0xc018, Model.ofBits 0xc019, Model.ofBits 0xc01a, Model.ofBits 0xc01b, Model.ofBits 0xc01c, Model.ofBits 0xc01d, Model.ofBits 0xc01e, Model.ofBits 0xc01f, Model.ofBits 0xc020, Model.ofBits 0xc021, Model.ofBits 0xc022, Model.ofBits 0xc023, Model.ofBits 0xc024, Model.ofBits 0xc025, Model.ofBits 0xc026, Model.ofBits 0xc027,
  Model.ofBits 0xc028, Model.ofBits 0xc029, Model.ofBits 0xc02a, Model.ofBits 0xc02b, Model.ofBits 0xc02c, Model.ofBits 0xc02d, Model.ofBits 0xc02e, Model.ofBits 0xc02f, Model.ofBits 0xc030, Model.ofBits 0xc031, Model.ofBits 0xc032, Model.ofBits 0xc033, Model.ofBits 0xc034, Model.ofBits 0xc035, Model.ofBits 0xc036, Model.ofBits 0xc037,
  Model.ofBits 0xc038, Model.ofBits 0xc039, Model.ofBits 0xc03a, Model.ofBits 0xc03b, Model.ofBits 0xc03c, Model.ofBits 0xc03d, Model.ofBits 0xc03e, Model.ofBits 0xc03f, Model.ofBits 0xc040, Model.ofBits 0xc041, Model.ofBits 0xc042, Model.ofBits 0xc043, Model.ofBits 0xc044, Model.ofBits 0xc045, Model.ofBits 0xc046, Model.ofBits 0xc047,
  Model.ofBits 0xc048, Model.ofBits 0xc049, Model.ofBits 0xc04a, Model.ofBits 0xc04b, Model.ofBits 0xc04c, Model.ofBits 0xc04d, Model.ofBits 0xc04e, Model.ofBits 0xc04f, Model.ofBits 0xc050, Model.ofBits 0xc051, Model.ofBits 0xc052, Model.ofBits 0xc053, Model.ofBits 0xc054, Model.ofBits 0xc055, Model.ofBits 0xc056, Model.ofBits 0xc057,
  Model.ofBits 0xc058, Model.ofBits 0xc059, Model.ofBits 0xc05a, Model.ofBits 0xc05b, Model.ofBits 0xc05c, Model.ofBits 0xc05d, Model.ofBits 0xc05e, Model.ofBits 0xc05f, Model.ofBits 0xc060, Model.ofBits 0xc061, Model.ofBits 0xc062, Model.ofBits 0xc063, Model.ofBits 0xc064, Model.ofBits 0xc065, Model.ofBits 0xc066, Model.ofBits 0xc067,
  Model.ofBits 0xc068, Model.ofBits 0xc069, Model.ofBits 0xc06a, Model.ofBits 0xc06b, Model.ofBits 0xc06c, Model.ofBits 0xc06d, Model.ofBits 0xc06e, Model.ofBits 0xc06f, Model.ofBits 0xc070, Model.ofBits 0xc071, Model.ofBits 0xc072, Model.ofBits 0xc073, Model.ofBits 0xc074, Model.ofBits 0xc075, Model.ofBits 0xc076, Model.ofBits 0xc077,
  Model.ofBits 0xc078, Model.ofBits 0xc079, Model.ofBits 0xc07a, Model.ofBits 0xc07b, Model.ofBits 0xc07c, Model.ofBits 0xc07d, Model.ofBits 0xc07e, Model.ofBits 0xc07f, Model.ofBits 0xc080, Model.ofBits 0xc081, Model.ofBits 0xc082, Model.ofBits 0xc083, Model.ofBits 0xc084, Model.ofBits 0xc085, Model.ofBits 0xc086, Model.ofBits 0xc087,
  Model.ofBits 0xc088, Model.ofBits 0xc089, Model.ofBits 0xc08a, Model.ofBits 0xc08b, Model.ofBits 0xc08c, Model.ofBits 0xc08d, Model.ofBits 0xc08e, Model.ofBits 0xc08f, Model.ofBits 0xc090, Model.ofBits 0xc091, Model.ofBits 0xc092, Model.ofBits 0xc093, Model.ofBits 0xc094, Model.ofBits 0xc095, Model.ofBits 0xc096, Model.ofBits 0xc097,
  Model.ofBits 0xc098, Model.ofBits 0xc099, Model.ofBits 0xc09a, Model.ofBits 0xc09b, Model.ofBits 0xc09c, Model.ofBits 0xc09d, Model.ofBits 0xc09e, Model.ofBits 0xc09f, Model.ofBits 0xc0a0, Model.ofBits 0xc0a1, Model.ofBits 0xc0a2, Model.ofBits 0xc0a3, Model.ofBits 0xc0a4, Model.ofBits 0xc0a5, Model.ofBits 0xc0a6, Model.ofBits 0xc0a7,
  Model.ofBits 0xc0a8, Model.ofBits 0xc0a9, Model.ofBits 0xc0aa, Model.ofBits 0xc0ab, Model.ofBits 0xc0ac, Model.ofBits 0xc0ad, Model.ofBits 0xc0ae, Model.ofBits 0xc0af, Model.ofBits 0xc0b0, Model.ofBits 0xc0b1, Model.ofBits 0xc0b2, Model.ofBits 0xc0b3, Model.ofBits 0xc0b4, Model.ofBits 0xc0b5, Model.ofBits 0xc0b6, Model.ofBits 0xc0b7,
  Model.ofBits 0xc0b8, Model.ofBits 0xc0b9, Model.ofBits 0xc0ba, Model.ofBits 0xc0bb, Model.ofBits 0xc0bc, Model.ofBits 0xc0bd, Model.ofBits 0xc0be, Model.ofBits 0xc0bf, Model.ofBits 0xc0c0, Model.ofBits 0xc0c1, Model.ofBits 0xc0c2, Model.ofBits 0xc0c3, Model.ofBits 0xc0c4, Model.ofBits 0xc0c5, Model.ofBits 0xc0c6, Model.ofBits 0xc0c7,
  Model.ofBits 0xc0c8, Model.ofBits 0xc0c9, Model.ofBits 0xc0ca, Model.ofBits 0xc0cb, Model.ofBits 0xc0cc, Model.ofBits 0xc0cd, Model.ofBits 0xc0ce, Model.ofBits 0xc0cf, Model.ofBits 0xc0d0, Model.ofBits 0xc0d1, Model.ofBits 0xc0d2, Model.ofBits 0xc0d3, Model.ofBits 0xc0d4, Model.ofBits 0xc0d5, Model.ofBits 0xc0d6, Model.ofBits 0xc0d7,
  Model.ofBits 0xc0d8, Model.ofBits 0xc0d9, Model.ofBits 0xc0da, Model.ofBits 0xc0db, Model.ofBits 0xc0dc, Model.ofBits 0xc0dd, Model.ofBits 0xc0de, Model.ofBits 0xc0df, Model.ofBits 0xc0e0, Model.ofBits 0xc0e1, Model.ofBits 0xc0e2, Model.ofBits 0xc0e3, Model.ofBits 0xc0e4, Model.ofBits 0xc0e5, Model.ofBits 0xc0e6, Model.ofBits 0xc0e7,
  Model.ofBits 0xc0e9, Model.ofBits 0xc0ea, Model.ofBits 0xc0eb, Model.ofBits 0xc0ec, Model.ofBits 0xc0ee, Model.ofBits 0xc0ef, Model.ofBits 0xc0f0, Model.ofBits 0xc0f1, Model.ofBits 0xc0f2, Model.ofBits 0xc0f3, Model.ofBits 0xc0f6, Model.ofBits 0xc0f7, Model.ofBits 0xc0fa, Model.ofBits 0xc10f
]
def dtBiasIndices : List (List Nat) := [
  [
    646, 258, 589, 446, 611, 517, 266, 727, 267, 240, 526, 247, 562, 511, 589, 624,
    591, 590, 264, 262, 265, 403, 488, 486, 534, 560, 555, 735, 710, 692, 261, 257,
    263, 572, 636, 610, 253, 254, 255, 605, 585, 643, 578, 660, 606, 260, 256, 259
  ],
  [
    8, 696, 69, 599, 773, 623, 741, 639, 698, 490, 721, 422, 42, 797, 105, 514,
    588, 542, 549, 767, 582, 702, 730, 745, 712, 630, 742, 448, 662, 499, 455, 691,
    561, 726, 36, 756, 570, 770, 599, 416, 510, 469, 701, 510, 672, 472, 545, 528
  ],
  [
    682, 685, 691, 728, 756, 765, 573, 701, 589, 589, 763, 624, 723, 518, 702, 694,
    597, 736, 689, 568, 701, 703, 633, 745, 724, 625, 701, 711, 711, 681, 656, 670,
    641, 583, 722, 509, 694, 681, 703, 684, 703, 697, 456, 720, 494, 478, 697, 513
  ],
  [
    524, 609, 483, 560, 680, 515, 587, 754, 637, 386, 688, 291, 743, 717, 722, 495,
    714, 567, 761, 298, 674, 759, 485, 738, 780, 641, 751, 595, 584, 614, 633, 468,
    659, 694, 478, 666, 601, 727, 655, 716, 718, 729, 494, 549, 477, 732, 610, 703
  ],
  [
    727, 716, 755, 556, 450, 462, 735, 784, 752, 568, 389, 594, 271, 350, 372, 724,
    360, 763, 379, 562, 289, 643, 732, 591, 379, 361, 318, 626, 623, 601, 592, 482,
    666, 703, 738, 722, 587, 738, 639, 728, 696, 761, 395, 565, 495, 168, 629, 92
  ],
  [
    568, 649, 595, 660, 729, 685, 417, 423, 454, 592, 548, 565, 648, 741, 693, 613,
    794, 563, 682, 637, 637, 524, 593, 568, 602, 737, 579, 678, 588, 713, 769, 597,
    784, 719, 777, 711, 734, 504, 706, 738, 772, 716, 570, 555, 615, 747, 481, 760
  ],
  [
    669, 719, 686, 453, 681, 537, 685, 408, 653, 729, 579, 705, 44, 738, 295, 561,
    522, 476, 26, 587, 375, 768, 732, 760, 694, 721, 713, 707, 735, 729, 739, 745,
    707, 447, 504, 522, 699, 751, 701, 489, 698, 352, 671, 466, 637, 131, 793, 121
  ],
  [
    520, 615, 586, 551, 555, 586, 572, 627, 621, 722, 738, 736, 692, 388, 710, 606,
    645, 668, 699, 596, 719, 778, 739, 795, 604, 569, 561, 639, 665, 593, 744, 731,
    725, 582, 613, 521, 731, 725, 720, 692, 736, 648, 570, 674, 624, 715, 762, 741
  ],
  [
    755, 736, 768, 502, 699, 567, 631, 745, 586, 688, 638, 651, 756, 664, 779, 760,
    779, 729, 13, 776, 372, 723, 777, 696, 718, 605, 760, 776, 596, 749, 340, 710,
    398, 771, 750, 790, 785, 590, 788, 287, 444, 386, 24, 679, 361, 556, 702, 599
  ],
  [
    694, 767, 657, 780, 756, 793, 726, 480, 703, 650, 663, 679, 711, 714, 694, 764,
    672, 733, 673, 698, 694, 761, 618, 774, 568, 681, 602, 641, 566, 621, 314, 637,
    451, 760, 764, 779, 498, 628, 467, 536, 303, 456, 695, 691, 682, 516, 741, 457
  ],
  [
    753, 507, 710, 697, 556, 684, 694, 578, 678, 693, 622, 710, 550, 624, 456, 592,
    729, 647, 723, 620, 748, 487, 373, 556, 630, 698, 678, 783, 517, 780, 605, 739,
    644, 692, 488, 703, 683, 756, 640, 626, 715, 681, 699, 690, 679, 610, 725, 552
  ],
  [
    591, 556, 535, 538, 732, 490, 728, 591, 709, 713, 648, 702, 665, 684, 691, 288,
    615, 394, 587, 556, 542, 681, 741, 660, 525, 719, 573, 722, 702, 700, 654, 770,
    613, 600, 702, 626, 665, 712, 696, 698, 766, 716, 765, 628, 737, 674, 602, 694
  ],
  [
    548, 681, 461, 563, 761, 610, 716, 544, 696, 745, 642, 726, 755, 709, 733, 709,
    712, 734, 728, 558, 695, 719, 694, 755, 732, 616, 712, 680, 33, 623, 763, 754,
    729, 357, 464, 20, 662, 598, 692, 755, 770, 773, 84, 615, 317, 629, 744, 685
  ],
  [
    728, 715, 715, 713, 758, 728, 702, 708, 681, 791, 709, 762, 682, 548, 640, 603,
    687, 643, 669, 679, 628, 696, 712, 723, 734, 644, 768, 726, 577, 740, 561, 582,
    566, 690, 684, 671, 548, 458, 503, 776, 722, 747, 392, 583, 484, 132, 631, 54
  ],
  [
    725, 791, 688, 488, 723, 437, 611, 690, 640, 25, 729, 96, 740, 699, 721, 623,
    696, 666, 608, 728, 637, 560, 665, 515, 373, 666, 501, 609, 717, 651, 745, 713,
    771, 744, 740, 736, 710, 657, 697, 696, 417, 718, 552, 547, 473, 591, 418, 540
  ],
  [
    461, 674, 385, 347, 682, 435, 719, 699, 721, 713, 721, 717, 545, 551, 480, 729,
    371, 718, 486, 735, 445, 717, 489, 698, 50, 432, 108, 740, 739, 751, 723, 762,
    710, 402, 554, 464, 308, 633, 43, 751, 739, 738, 723, 722, 705, 188, 90, 134
  ],
  [
    648, 137, 599, 705, 727, 715, 232, 727, 235, 713, 716, 724, 569, 684, 623, 720,
    365, 709, 678, 661, 689, 455, 641, 496, 728, 714, 715, 95, 718, 272, 15, 133,
    377, 195, 649, 143, 18, 705, 367, 106, 739, 34, 28, 300, 110, 9, 332, 85
  ],
  [
    603, 460, 518, 104, 86, 138, 526, 429, 449, 404, 654, 499, 192, 396, 129, 68,
    94, 148, 645, 677, 603, 123, 684, 70, 647, 631, 671, 518, 102, 415, 588, 523,
    648, 278, 283, 387, 59, 623, 324, 310, 562, 460, 684, 338, 661, 734, 427, 712
  ],
  [
    678, 711, 661, 513, 684, 426, 661, 383, 685, 710, 558, 726, 81, 747, 79, 563,
    525, 493, 349, 574, 12, 766, 724, 757, 697, 722, 712, 733, 727, 714, 736, 742,
    694, 412, 491, 483, 690, 746, 698, 505, 687, 333, 674, 462, 650, 160, 791, 161
  ],
  [
    555, 618, 585, 585, 553, 554, 646, 631, 609, 728, 733, 722, 701, 443, 715, 597,
    615, 630, 724, 615, 714, 796, 757, 785, 565, 523, 543, 633, 679, 589, 740, 732,
    732, 483, 595, 533, 724, 716, 717, 687, 734, 655, 621, 680, 563, 728, 766, 743
  ],
  [
    761, 731, 754, 521, 709, 561, 606, 746, 641, 668, 649, 690, 759, 657, 775, 760,
    781, 736, 424, 770, 279, 727, 780, 705, 717, 615, 740, 757, 570, 765, 296, 708,
    374, 783, 761, 795, 793, 607, 786, 399, 480, 3, 309, 693, 356, 555, 703, 570
  ],
  [
    688, 761, 656, 790, 757, 782, 727, 505, 703, 667, 669, 682, 698, 701, 687, 735,
    680, 759, 687, 696, 681, 770, 612, 756, 576, 675, 618, 676, 633, 656, 382, 666,
    489, 757, 751, 768, 544, 642, 475, 509, 285, 443, 684, 682, 678, 490, 738, 547
  ],
  [
    733, 440, 749, 682, 511, 699, 691, 564, 677, 721, 638, 700, 514, 609, 454, 659,
    732, 608, 721, 619, 735, 546, 369, 500, 683, 694, 644, 775, 510, 791, 651, 742,
    616, 700, 474, 691, 668, 754, 629, 632, 714, 675, 684, 698, 700, 619, 721, 573
  ],
  [
    535, 550, 574, 530, 737, 488, 724, 607, 710, 705, 662, 714, 703, 690, 686, 17,
    599, 430, 563, 550, 595, 685, 751, 654, 570, 726, 530, 686, 703, 708, 614, 776,
    650, 610, 702, 589, 680, 711, 647, 716, 763, 699, 758, 645, 735, 680, 602, 698
  ],
  [
    532, 674, 453, 613, 756, 563, 702, 557, 715, 734, 620, 724, 733, 703, 747, 748,
    733, 732, 695, 547, 716, 741, 689, 718, 727, 613, 712, 673, 327, 626, 729, 763,
    750, 329, 443, 16, 690, 597, 662, 745, 759, 760, 48, 615, 297, 620, 746, 676
  ],
  [
    708, 706, 718, 710, 756, 719, 697, 707, 681, 792, 703, 777, 626, 520, 673, 642,
    680, 611, 661, 672, 634, 707, 698, 680, 752, 640, 740, 728, 585, 738, 532, 579,
    554, 696, 682, 681, 413, 348, 463, 778, 724, 754, 359, 560, 441, 112, 623, 75
  ],
  [
    694, 790, 720, 434, 725, 501, 644, 693, 620, 124, 721, 32, 727, 675, 708, 613,
    675, 651, 629, 726, 610, 502, 663, 565, 486, 670, 432, 608, 710, 637, 751, 714,
    766, 739, 738, 721, 700, 656, 706, 721, 416, 706, 437, 476, 491, 529, 398, 571
  ],
  [
    433, 669, 366, 395, 669, 313, 717, 694, 712, 709, 717, 713, 518, 509, 457, 721,
    316, 714, 450, 728, 367, 718, 567, 705, 102, 392, 154, 738, 733, 749, 704, 761,
    724, 341, 550, 409, 100, 610, 47, 745, 740, 735, 701, 717, 716, 176, 109, 146
  ],
  [
    600, 147, 638, 707, 717, 689, 236, 718, 231, 719, 709, 710, 564, 680, 595, 707,
    326, 718, 683, 646, 671, 488, 638, 442, 720, 711, 713, 136, 727, 99, 5, 165,
    335, 159, 649, 207, 0, 704, 80, 101, 739, 52, 64, 19, 119, 73, 41, 146
  ],
  [
    545, 425, 570, 182, 146, 166, 411, 370, 489, 407, 641, 301, 208, 431, 169, 183,
    127, 141, 627, 660, 571, 97, 641, 149, 627, 609, 652, 450, 166, 305, 582, 480,
    631, 297, 30, 67, 294, 607, 82, 410, 517, 269, 679, 323, 652, 720, 353, 705
  ],
  [
    660, 704, 639, 401, 671, 457, 662, 334, 680, 708, 530, 725, 122, 747, 88, 453,
    477, 535, 31, 559, 297, 755, 721, 763, 710, 718, 698, 711, 730, 729, 700, 744,
    738, 439, 457, 360, 694, 740, 684, 311, 681, 457, 652, 434, 631, 163, 787, 172
  ],
  [
    491, 590, 559, 518, 519, 566, 631, 625, 603, 727, 729, 719, 708, 406, 697, 580,
    596, 609, 714, 593, 706, 790, 749, 783, 531, 477, 502, 604, 663, 632, 741, 731,
    731, 508, 584, 465, 721, 712, 713, 652, 729, 682, 578, 680, 625, 724, 761, 733
  ],
  [
    749, 725, 757, 477, 701, 527, 592, 742, 620, 682, 623, 653, 763, 637, 751, 746,
    775, 728, 268, 758, 63, 722, 777, 704, 715, 585, 737, 751, 556, 765, 350, 712,
    1, 777, 759, 793, 783, 592, 791, 276, 419, 38, 45, 686, 6, 542, 696, 504
  ],
  [
    648, 757, 684, 786, 755, 780, 722, 465, 697, 670, 655, 651, 688, 697, 670, 749,
    666, 730, 662, 689, 681, 753, 602, 770, 561, 661, 596, 657, 641, 668, 361, 637,
    441, 764, 748, 755, 494, 617, 428, 421, 273, 466, 674, 666, 653, 465, 730, 390
  ],
  [
    725, 389, 748, 677, 492, 690, 681, 521, 659, 706, 617, 693, 478, 599, 414, 639,
    729, 593, 723, 603, 732, 462, 282, 512, 638, 682, 664, 782, 506, 773, 634, 739,
    611, 697, 442, 688, 616, 751, 657, 657, 710, 617, 681, 687, 692, 565, 713, 600
  ],
  [
    495, 505, 557, 459, 729, 488, 702, 580, 717, 708, 641, 697, 686, 687, 663, 302,
    571, 61, 521, 516, 567, 680, 741, 650, 487, 715, 541, 706, 701, 692, 589, 776,
    624, 567, 701, 588, 663, 707, 637, 710, 770, 696, 742, 627, 760, 662, 582, 688
  ],
  [
    382, 640, 473, 518, 758, 570, 695, 509, 707, 716, 610, 729, 726, 695, 743, 747,
    734, 737, 724, 520, 707, 721, 685, 736, 707, 591, 719, 607, 20, 642, 746, 752,
    753, 11, 404, 67, 652, 572, 680, 746, 754, 750, 91, 603, 53, 651, 744, 622
  ],
  [
    712, 705, 720, 718, 756, 708, 689, 702, 673, 783, 703, 789, 631, 487, 665, 626,
    663, 599, 649, 658, 627, 697, 691, 669, 753, 622, 737, 725, 563, 735, 490, 548,
    506, 667, 673, 686, 376, 284, 420, 771, 721, 754, 350, 551, 402, 153, 619, 130
  ],
  [
    704, 795, 725, 391, 717, 452, 608, 690, 639, 93, 718, 159, 722, 679, 706, 631,
    666, 598, 581, 709, 555, 454, 644, 521, 429, 661, 477, 630, 712, 598, 763, 705,
    748, 725, 734, 731, 689, 631, 701, 693, 328, 708, 387, 438, 452, 539, 293, 478
  ],
  [
    290, 679, 355, 306, 654, 29, 717, 694, 721, 710, 718, 713, 419, 479, 473, 716,
    337, 723, 325, 726, 366, 717, 585, 708, 140, 346, 168, 748, 733, 741, 727, 774,
    717, 280, 512, 336, 98, 618, 144, 732, 739, 741, 715, 721, 697, 189, 139, 164
  ],
  [
    620, 184, 578, 701, 715, 672, 242, 720, 238, 712, 709, 719, 581, 680, 531, 717,
    52, 709, 684, 632, 648, 486, 652, 431, 719, 709, 710, 35, 714, 117, 321, 201,
    22, 215, 628, 225, 57, 703, 113, 78, 734, 118, 132, 56, 84, 156, 73, 113
  ],
  [
    497, 385, 568, 218, 202, 224, 418, 364, 485, 281, 649, 378, 215, 393, 229, 192,
    126, 174, 615, 670, 565, 145, 693, 187, 635, 593, 605, 471, 171, 368, 636, 469,
    598, 72, 46, 304, 125, 605, 71, 39, 478, 320, 654, 277, 663, 725, 358, 707
  ],
  [
    226, 214, 230, 604, 611, 575, 608, 643, 641, 607, 219, 566, 695, 741, 686, 222,
    541, 228, 66, 89, 23, 233, 23, 227, 60, 83, 107, 723, 697, 710, 692, 678,
    674, 58, 629, 307, 634, 668, 599, 597, 680, 563, 65, 147, 21, 658, 175, 683
  ],
  [
    565, 421, 502, 345, 694, 380, 555, 158, 476, 436, 473, 503, 706, 749, 699, 10,
    246, 49, 216, 40, 201, 645, 615, 580, 103, 164, 156, 170, 658, 190, 145, 186,
    87, 572, 135, 628, 599, 319, 552, 123, 362, 166, 286, 330, 397, 741, 714, 744
  ],
  [
    197, 191, 213, 425, 476, 470, 189, 221, 187, 167, 185, 111, 134, 203, 177, 7,
    252, 55, 440, 566, 529, 354, 51, 27, 690, 653, 670, 178, 590, 199, 218, 120,
    194, 162, 234, 122, 322, 546, 77, 478, 657, 563, 699, 642, 693, 128, 201, 74
  ],
  [
    110, 617, 155, 108, 425, 77, 157, 209, 196, 250, 405, 249, 205, 579, 217, 494,
    574, 556, 728, 503, 722, 274, 315, 92, 270, 215, 72, 199, 669, 220, 92, 141,
    62, 181, 677, 212, 2, 114, 339, 142, 215, 115, 429, 457, 381, 151, 150, 123
  ],
  [
    582, 169, 534, 299, 275, 342, 206, 601, 155, 200, 197, 157, 473, 740, 366, 207,
    292, 179, 552, 647, 591, 206, 237, 199, 572, 363, 601, 41, 193, 344, 444, 324,
    331, 207, 712, 169, 297, 173, 388, 180, 210, 198, 582, 204, 631, 211, 519, 193
  ],
  [
    245, 564, 244, 348, 566, 403, 312, 690, 37, 104, 211, 4, 152, 716, 116, 670,
    623, 645, 251, 617, 248, 764, 223, 778, 736, 723, 741, 351, 732, 14, 440, 671,
    416, 597, 598, 570, 400, 384, 420, 243, 638, 241, 124, 343, 76, 379, 239, 380
  ]
]
def dtBiasCap : BF := BFloat16DyadicBounds.ceiling 1 5
def dtBias (layer : Fin 48) : Fin 48 → BF := raw dtBiasDictionary dtBiasIndices layer

theorem dtBiasCap_real : Model.toReal dtBiasCap = 32 := by
  have h := (BFloat16DyadicBounds.ceiling_range 1 5 (by decide) (by decide) (by decide)).2
  norm_num at h
  exact h

set_option maxRecDepth 30000 in
set_option maxHeartbeats 0 in
theorem dtBias_checked : TensorWords.check dtBiasDictionary dtBiasCap = true := by decide +kernel

set_option maxRecDepth 30000 in
set_option maxHeartbeats 0 in
theorem dtBias_dimensions : dtBiasDictionary.length = 798 ∧ dtBiasIndices.length = 48 ∧
    dtBiasIndices.all (fun row => decide (row.length = 48) && row.all (fun i => decide (i < 798))) = true := by
  decide +kernel

theorem dtBias_bound (layer : Fin 48) (i : Fin 48) :
    Model.isFinite (dtBias layer i) = true ∧ |Model.toReal (dtBias layer i)| ≤ 32 := by
  have fallback : Model.isFinite CheckpointRanges.zeroCap = true ∧
      |Model.toReal CheckpointRanges.zeroCap| ≤ Model.toReal dtBiasCap := by
    refine ⟨by decide +kernel, ?_⟩
    rw [CheckpointRanges.zeroCap_real, dtBiasCap_real]
    norm_num
  simpa only [dtBias, raw, dtBiasCap_real] using
    TensorWords.check_getD dtBiasDictionary dtBiasCap CheckpointRanges.zeroCap dtBias_checked fallback
      ((dtBiasIndices[layer.val]?.getD [])[i.val]?.getD 0)

def gatedNormDictionary : List BF := [
  Model.ofBits 0x3df8, Model.ofBits 0x3e08, Model.ofBits 0x3e18, Model.ofBits 0x3e1c, Model.ofBits 0x3e50, Model.ofBits 0x3e80, Model.ofBits 0x3e84, Model.ofBits 0x3e8e, Model.ofBits 0x3e96, Model.ofBits 0x3e9a, Model.ofBits 0x3e9e, Model.ofBits 0x3eb6, Model.ofBits 0x3ec0, Model.ofBits 0x3ec4, Model.ofBits 0x3ec8, Model.ofBits 0x3ecc,
  Model.ofBits 0x3ece, Model.ofBits 0x3ed8, Model.ofBits 0x3edc, Model.ofBits 0x3ede, Model.ofBits 0x3ee2, Model.ofBits 0x3ee4, Model.ofBits 0x3ee6, Model.ofBits 0x3ee8, Model.ofBits 0x3eea, Model.ofBits 0x3eec, Model.ofBits 0x3eee, Model.ofBits 0x3ef2, Model.ofBits 0x3ef6, Model.ofBits 0x3ef8, Model.ofBits 0x3efa, Model.ofBits 0x3efe,
  Model.ofBits 0x3f00, Model.ofBits 0x3f01, Model.ofBits 0x3f02, Model.ofBits 0x3f03, Model.ofBits 0x3f08, Model.ofBits 0x3f09, Model.ofBits 0x3f0a, Model.ofBits 0x3f0c, Model.ofBits 0x3f0d, Model.ofBits 0x3f0e, Model.ofBits 0x3f0f, Model.ofBits 0x3f10, Model.ofBits 0x3f13, Model.ofBits 0x3f14, Model.ofBits 0x3f15, Model.ofBits 0x3f16,
  Model.ofBits 0x3f18, Model.ofBits 0x3f1a, Model.ofBits 0x3f1c, Model.ofBits 0x3f1e, Model.ofBits 0x3f1f, Model.ofBits 0x3f20, Model.ofBits 0x3f21, Model.ofBits 0x3f22, Model.ofBits 0x3f23, Model.ofBits 0x3f24, Model.ofBits 0x3f25, Model.ofBits 0x3f26, Model.ofBits 0x3f28, Model.ofBits 0x3f29, Model.ofBits 0x3f2a, Model.ofBits 0x3f2c,
  Model.ofBits 0x3f2d, Model.ofBits 0x3f2e, Model.ofBits 0x3f2f, Model.ofBits 0x3f30, Model.ofBits 0x3f31, Model.ofBits 0x3f32, Model.ofBits 0x3f33, Model.ofBits 0x3f34, Model.ofBits 0x3f35, Model.ofBits 0x3f36, Model.ofBits 0x3f37, Model.ofBits 0x3f38, Model.ofBits 0x3f39, Model.ofBits 0x3f3a, Model.ofBits 0x3f3b, Model.ofBits 0x3f3c,
  Model.ofBits 0x3f3d, Model.ofBits 0x3f3e, Model.ofBits 0x3f3f, Model.ofBits 0x3f40, Model.ofBits 0x3f41, Model.ofBits 0x3f42, Model.ofBits 0x3f43, Model.ofBits 0x3f44, Model.ofBits 0x3f45, Model.ofBits 0x3f46, Model.ofBits 0x3f47, Model.ofBits 0x3f48, Model.ofBits 0x3f49, Model.ofBits 0x3f4a, Model.ofBits 0x3f4b, Model.ofBits 0x3f4c,
  Model.ofBits 0x3f4d, Model.ofBits 0x3f4e, Model.ofBits 0x3f4f, Model.ofBits 0x3f50, Model.ofBits 0x3f51, Model.ofBits 0x3f52, Model.ofBits 0x3f53, Model.ofBits 0x3f54, Model.ofBits 0x3f55, Model.ofBits 0x3f56, Model.ofBits 0x3f57, Model.ofBits 0x3f58, Model.ofBits 0x3f59, Model.ofBits 0x3f5a, Model.ofBits 0x3f5b, Model.ofBits 0x3f5c,
  Model.ofBits 0x3f5d, Model.ofBits 0x3f5e, Model.ofBits 0x3f5f, Model.ofBits 0x3f60, Model.ofBits 0x3f61, Model.ofBits 0x3f62, Model.ofBits 0x3f63, Model.ofBits 0x3f64, Model.ofBits 0x3f65, Model.ofBits 0x3f66, Model.ofBits 0x3f67, Model.ofBits 0x3f68, Model.ofBits 0x3f69, Model.ofBits 0x3f6a, Model.ofBits 0x3f6b, Model.ofBits 0x3f6c,
  Model.ofBits 0x3f6d, Model.ofBits 0x3f6e, Model.ofBits 0x3f6f, Model.ofBits 0x3f70, Model.ofBits 0x3f71, Model.ofBits 0x3f72, Model.ofBits 0x3f73, Model.ofBits 0x3f74, Model.ofBits 0x3f75, Model.ofBits 0x3f76, Model.ofBits 0x3f77, Model.ofBits 0x3f78, Model.ofBits 0x3f79, Model.ofBits 0x3f7a, Model.ofBits 0x3f7b, Model.ofBits 0x3f7c,
  Model.ofBits 0x3f7d, Model.ofBits 0x3f7e, Model.ofBits 0x3f7f, Model.ofBits 0x3f80, Model.ofBits 0x3f81, Model.ofBits 0x3f82, Model.ofBits 0x3f83, Model.ofBits 0x3f84, Model.ofBits 0x3f85, Model.ofBits 0x3f86, Model.ofBits 0x3f87, Model.ofBits 0x3f88, Model.ofBits 0x3f89, Model.ofBits 0x3f8a, Model.ofBits 0x3f8b, Model.ofBits 0x3f8c,
  Model.ofBits 0x3f8d, Model.ofBits 0x3f8e, Model.ofBits 0x3f8f, Model.ofBits 0x3f90, Model.ofBits 0x3f91, Model.ofBits 0x3f92, Model.ofBits 0x3f93, Model.ofBits 0x3f94, Model.ofBits 0x3f95, Model.ofBits 0x3f96, Model.ofBits 0x3f97, Model.ofBits 0x3f98, Model.ofBits 0x3f99, Model.ofBits 0x3f9a, Model.ofBits 0x3f9b, Model.ofBits 0x3f9c,
  Model.ofBits 0x3f9d, Model.ofBits 0x3f9e, Model.ofBits 0x3f9f, Model.ofBits 0x3fa0, Model.ofBits 0x3fa1, Model.ofBits 0x3fa2, Model.ofBits 0x3fa3, Model.ofBits 0x3fa4, Model.ofBits 0x3fa5, Model.ofBits 0x3fa6, Model.ofBits 0x3fa7, Model.ofBits 0x3fa8, Model.ofBits 0x3fa9, Model.ofBits 0x3faa, Model.ofBits 0x3fac, Model.ofBits 0x3fad,
  Model.ofBits 0x3fae, Model.ofBits 0x3faf, Model.ofBits 0x3fb0, Model.ofBits 0x3fb1, Model.ofBits 0x3fb2, Model.ofBits 0x3fb6, Model.ofBits 0x3fba, Model.ofBits 0x3fbf
]
def gatedNormIndices : List (List Nat) := [
  [
    117, 119, 114, 109, 113, 118, 110, 115, 118, 112, 115, 95, 110, 121, 113, 108,
    123, 108, 129, 103, 120, 117, 111, 119, 113, 108, 113, 123, 107, 104, 109, 111,
    109, 115, 120, 109, 99, 113, 97, 108, 123, 124, 125, 124, 112, 114, 122, 122,
    117, 96, 103, 110, 117, 103, 109, 124, 121, 111, 104, 111, 125, 108, 117, 114,
    103, 117, 112, 127, 125, 112, 117, 113, 109, 113, 109, 117, 110, 109, 103, 113,
    113, 118, 115, 107, 111, 112, 105, 111, 100, 108, 116, 103, 129, 117, 119, 121,
    123, 110, 116, 111, 110, 92, 107, 110, 122, 110, 121, 121, 120, 119, 115, 128,
    113, 120, 113, 113, 117, 108, 116, 117, 101, 105, 109, 118, 113, 114, 124, 108
  ],
  [
    115, 116, 119, 116, 111, 121, 108, 59, 116, 113, 110, 125, 119, 116, 114, 116,
    117, 98, 115, 127, 118, 120, 118, 97, 85, 106, 121, 73, 125, 121, 115, 115,
    115, 121, 113, 119, 121, 117, 122, 123, 123, 120, 118, 96, 110, 136, 123, 115,
    105, 116, 116, 110, 121, 99, 120, 111, 117, 116, 113, 98, 113, 120, 118, 124,
    120, 104, 128, 118, 120, 103, 117, 126, 120, 116, 122, 110, 118, 3, 124, 128,
    115, 113, 123, 118, 113, 126, 113, 112, 120, 119, 119, 112, 118, 121, 113, 120,
    6, 125, 117, 100, 119, 125, 114, 113, 125, 113, 113, 38, 113, 117, 119, 120,
    113, 119, 113, 97, 116, 116, 117, 114, 114, 109, 0, 116, 12, 114, 121, 117
  ],
  [
    126, 129, 137, 49, 132, 133, 129, 126, 133, 129, 127, 132, 133, 130, 134, 131,
    125, 129, 126, 131, 138, 134, 125, 131, 133, 135, 127, 132, 136, 135, 131, 135,
    135, 129, 133, 130, 128, 138, 132, 133, 122, 134, 128, 132, 137, 127, 134, 132,
    134, 132, 130, 143, 134, 126, 135, 129, 132, 129, 142, 136, 132, 129, 144, 127,
    134, 131, 128, 135, 128, 132, 135, 135, 132, 134, 133, 133, 133, 132, 126, 139,
    0, 139, 128, 131, 130, 129, 136, 137, 22, 132, 131, 131, 132, 99, 130, 131,
    139, 132, 141, 132, 131, 136, 45, 130, 139, 139, 141, 127, 0, 132, 131, 134,
    135, 138, 145, 129, 127, 136, 135, 133, 125, 133, 124, 134, 129, 131, 125, 126
  ],
  [
    136, 144, 141, 139, 149, 145, 141, 148, 144, 147, 137, 145, 145, 147, 145, 144,
    137, 134, 150, 134, 141, 144, 59, 145, 140, 148, 145, 148, 141, 140, 142, 136,
    145, 133, 136, 147, 147, 132, 136, 147, 117, 147, 147, 139, 136, 146, 142, 146,
    146, 137, 143, 22, 144, 138, 145, 148, 143, 115, 145, 145, 143, 141, 139, 138,
    145, 148, 142, 149, 148, 145, 144, 145, 141, 130, 147, 144, 140, 49, 137, 149,
    143, 151, 143, 149, 65, 145, 139, 140, 142, 147, 144, 147, 1, 150, 148, 149,
    142, 139, 145, 139, 135, 139, 148, 140, 150, 141, 145, 138, 147, 146, 141, 140,
    147, 140, 144, 147, 147, 135, 149, 141, 4, 145, 144, 143, 139, 147, 149, 148
  ],
  [
    130, 127, 117, 133, 140, 119, 134, 131, 129, 137, 32, 127, 129, 135, 131, 10,
    130, 79, 129, 133, 136, 138, 133, 126, 132, 127, 131, 134, 129, 135, 133, 129,
    134, 139, 148, 126, 148, 124, 138, 126, 124, 139, 130, 143, 122, 136, 131, 132,
    121, 131, 137, 131, 142, 135, 125, 132, 125, 127, 135, 132, 130, 133, 127, 129,
    132, 144, 136, 105, 128, 139, 131, 127, 139, 134, 137, 137, 133, 138, 135, 131,
    137, 134, 115, 132, 126, 12, 136, 131, 133, 137, 132, 136, 130, 133, 130, 132,
    138, 141, 145, 134, 137, 131, 128, 136, 129, 142, 128, 137, 138, 129, 138, 135,
    137, 129, 123, 136, 125, 134, 131, 132, 116, 115, 138, 126, 139, 127, 134, 134
  ],
  [
    133, 124, 119, 119, 118, 135, 125, 131, 129, 130, 127, 121, 127, 122, 122, 107,
    128, 127, 129, 123, 128, 13, 119, 131, 126, 125, 127, 19, 120, 123, 134, 117,
    128, 123, 125, 83, 133, 119, 122, 129, 126, 57, 123, 143, 127, 136, 112, 126,
    128, 136, 138, 127, 51, 127, 134, 120, 128, 127, 120, 118, 131, 121, 120, 126,
    128, 127, 129, 128, 127, 126, 109, 123, 136, 121, 103, 122, 140, 126, 129, 130,
    120, 117, 129, 86, 128, 121, 122, 126, 124, 120, 130, 122, 139, 126, 98, 134,
    123, 147, 114, 129, 121, 120, 141, 116, 125, 133, 121, 131, 138, 115, 125, 119,
    136, 112, 129, 137, 144, 131, 121, 126, 127, 119, 132, 122, 125, 110, 130, 126
  ],
  [
    129, 129, 142, 131, 130, 128, 134, 133, 130, 133, 133, 134, 136, 134, 134, 130,
    127, 135, 129, 128, 125, 132, 122, 130, 131, 125, 131, 120, 128, 134, 128, 132,
    133, 131, 130, 128, 91, 128, 138, 129, 134, 121, 134, 126, 128, 128, 140, 125,
    128, 134, 130, 131, 127, 130, 131, 137, 135, 132, 131, 127, 129, 128, 111, 119,
    125, 132, 119, 129, 130, 140, 136, 132, 136, 128, 132, 125, 124, 78, 127, 128,
    126, 134, 141, 123, 128, 124, 90, 137, 121, 129, 80, 128, 134, 134, 59, 122,
    8, 137, 140, 129, 128, 130, 132, 63, 122, 127, 146, 27, 129, 138, 127, 129,
    129, 128, 130, 130, 126, 127, 124, 130, 134, 131, 132, 134, 119, 130, 135, 135
  ],
  [
    105, 122, 131, 125, 130, 126, 132, 122, 134, 131, 135, 135, 129, 127, 124, 135,
    137, 133, 141, 129, 135, 129, 129, 129, 131, 133, 131, 126, 98, 129, 128, 49,
    123, 135, 128, 109, 136, 133, 129, 131, 124, 127, 138, 126, 128, 135, 133, 134,
    105, 134, 134, 108, 124, 128, 137, 123, 127, 128, 127, 125, 124, 131, 134, 133,
    128, 135, 136, 121, 130, 53, 136, 132, 129, 126, 127, 127, 126, 108, 126, 130,
    136, 119, 134, 129, 127, 127, 131, 115, 122, 119, 131, 125, 132, 127, 121, 129,
    127, 63, 132, 137, 130, 110, 133, 132, 132, 129, 133, 127, 134, 130, 130, 130,
    127, 133, 140, 132, 130, 125, 131, 128, 127, 89, 120, 118, 126, 132, 128, 126
  ],
  [
    109, 127, 118, 136, 141, 133, 129, 132, 121, 129, 123, 46, 132, 123, 134, 140,
    123, 128, 140, 127, 126, 128, 125, 113, 119, 130, 124, 126, 137, 127, 129, 131,
    123, 128, 115, 129, 123, 121, 132, 127, 128, 120, 122, 127, 130, 120, 126, 119,
    2, 139, 119, 135, 123, 127, 132, 133, 131, 132, 114, 119, 115, 9, 127, 125,
    132, 132, 126, 128, 126, 127, 129, 131, 113, 132, 123, 126, 128, 125, 125, 115,
    127, 130, 127, 118, 117, 127, 76, 127, 125, 135, 126, 129, 129, 124, 117, 121,
    127, 128, 130, 132, 132, 121, 133, 127, 126, 129, 125, 116, 132, 128, 120, 136,
    125, 123, 130, 119, 128, 126, 138, 114, 125, 124, 59, 128, 123, 134, 122, 133
  ],
  [
    123, 122, 123, 138, 127, 129, 125, 126, 122, 125, 123, 125, 128, 125, 135, 138,
    114, 125, 140, 129, 123, 123, 126, 126, 129, 115, 127, 130, 131, 121, 119, 41,
    132, 119, 148, 134, 131, 128, 122, 139, 115, 128, 137, 129, 114, 130, 121, 26,
    143, 128, 44, 131, 126, 109, 130, 141, 127, 123, 120, 121, 138, 95, 28, 128,
    41, 128, 134, 127, 127, 143, 118, 129, 131, 125, 144, 131, 112, 130, 131, 135,
    132, 133, 114, 138, 132, 131, 120, 135, 120, 150, 117, 128, 105, 132, 131, 132,
    125, 130, 135, 125, 133, 138, 123, 39, 137, 128, 133, 121, 113, 134, 128, 131,
    114, 132, 133, 123, 134, 127, 136, 121, 135, 113, 132, 134, 111, 133, 97, 141
  ],
  [
    136, 132, 128, 136, 138, 139, 129, 132, 117, 129, 138, 133, 131, 146, 145, 131,
    139, 134, 137, 113, 125, 137, 143, 131, 132, 142, 104, 131, 143, 129, 125, 139,
    135, 133, 135, 136, 135, 141, 144, 137, 134, 129, 133, 128, 43, 133, 140, 135,
    132, 130, 53, 137, 131, 140, 126, 138, 130, 146, 129, 125, 146, 137, 150, 143,
    140, 129, 152, 133, 142, 141, 126, 16, 143, 134, 130, 122, 129, 134, 141, 134,
    137, 142, 135, 121, 117, 131, 48, 130, 132, 127, 131, 129, 148, 139, 138, 124,
    145, 131, 135, 123, 136, 149, 133, 127, 147, 138, 131, 149, 137, 125, 142, 133,
    122, 129, 136, 132, 140, 144, 140, 139, 133, 143, 145, 137, 137, 140, 136, 139
  ],
  [
    139, 126, 129, 144, 131, 143, 134, 125, 131, 115, 127, 121, 149, 131, 120, 132,
    129, 132, 133, 133, 129, 121, 125, 124, 129, 124, 118, 127, 129, 126, 127, 134,
    121, 130, 119, 140, 135, 131, 139, 143, 131, 132, 122, 125, 128, 7, 131, 132,
    138, 128, 121, 123, 130, 121, 128, 137, 133, 137, 125, 127, 140, 125, 136, 126,
    30, 127, 120, 123, 136, 136, 120, 146, 123, 126, 130, 141, 139, 124, 129, 109,
    137, 121, 117, 130, 122, 129, 75, 125, 137, 140, 128, 121, 123, 128, 122, 141,
    125, 128, 121, 99, 125, 139, 120, 128, 121, 138, 120, 125, 131, 140, 73, 126,
    139, 119, 128, 131, 14, 124, 128, 120, 131, 126, 129, 140, 123, 121, 143, 123
  ],
  [
    136, 132, 131, 133, 132, 142, 135, 130, 129, 140, 132, 126, 133, 140, 125, 127,
    129, 125, 115, 137, 121, 134, 135, 123, 129, 140, 133, 139, 115, 136, 127, 126,
    119, 123, 144, 131, 137, 132, 130, 135, 123, 118, 122, 125, 137, 119, 125, 136,
    88, 125, 131, 133, 122, 119, 123, 135, 146, 117, 130, 118, 126, 110, 125, 147,
    125, 140, 127, 147, 135, 126, 129, 129, 127, 137, 137, 142, 112, 147, 128, 140,
    129, 129, 132, 125, 133, 134, 122, 143, 60, 122, 123, 132, 130, 119, 137, 127,
    128, 137, 129, 129, 133, 125, 126, 123, 141, 141, 89, 135, 132, 129, 135, 133,
    128, 128, 123, 137, 124, 138, 124, 135, 134, 129, 145, 119, 126, 138, 121, 138
  ],
  [
    127, 132, 125, 123, 133, 139, 122, 134, 113, 130, 125, 115, 128, 123, 125, 121,
    133, 123, 130, 128, 115, 123, 136, 133, 126, 134, 129, 131, 48, 129, 140, 122,
    138, 136, 132, 131, 123, 130, 128, 126, 142, 136, 124, 128, 145, 127, 129, 132,
    126, 113, 121, 138, 127, 127, 135, 129, 134, 121, 116, 131, 106, 122, 122, 142,
    131, 131, 126, 115, 130, 125, 123, 129, 123, 129, 129, 135, 133, 141, 119, 136,
    126, 129, 126, 122, 119, 133, 133, 93, 104, 127, 120, 134, 116, 138, 132, 133,
    138, 134, 133, 137, 138, 120, 130, 134, 60, 126, 126, 138, 124, 129, 134, 138,
    134, 133, 138, 134, 127, 113, 126, 127, 116, 121, 127, 129, 131, 124, 133, 110
  ],
  [
    133, 118, 130, 135, 127, 127, 127, 128, 128, 114, 117, 121, 123, 129, 132, 129,
    124, 124, 117, 121, 122, 131, 127, 125, 143, 128, 127, 122, 122, 109, 114, 133,
    122, 123, 133, 140, 130, 124, 129, 119, 135, 125, 126, 118, 120, 145, 129, 115,
    136, 113, 126, 114, 125, 102, 133, 127, 126, 134, 118, 113, 56, 111, 118, 113,
    111, 125, 125, 119, 127, 131, 130, 127, 112, 127, 124, 123, 126, 137, 115, 133,
    122, 112, 129, 132, 125, 124, 130, 124, 125, 127, 119, 122, 139, 103, 127, 121,
    123, 114, 119, 124, 134, 124, 93, 124, 115, 119, 128, 97, 118, 110, 134, 130,
    132, 135, 123, 117, 109, 125, 104, 125, 127, 115, 125, 114, 125, 129, 115, 124
  ],
  [
    117, 147, 98, 115, 133, 131, 138, 139, 127, 83, 125, 101, 129, 127, 114, 138,
    99, 97, 124, 126, 129, 127, 128, 124, 123, 123, 108, 126, 115, 120, 122, 117,
    105, 124, 147, 119, 148, 119, 143, 131, 132, 130, 116, 128, 123, 118, 122, 130,
    113, 125, 119, 120, 126, 117, 103, 134, 138, 105, 117, 139, 119, 131, 116, 121,
    130, 138, 125, 129, 140, 131, 127, 133, 129, 148, 133, 100, 125, 133, 97, 127,
    106, 122, 112, 119, 146, 110, 127, 130, 136, 120, 118, 133, 115, 141, 120, 142,
    124, 137, 123, 120, 124, 125, 147, 130, 130, 120, 126, 147, 125, 137, 116, 126,
    112, 131, 114, 117, 120, 129, 129, 113, 124, 122, 114, 117, 121, 134, 125, 115
  ],
  [
    87, 132, 128, 124, 132, 118, 114, 127, 101, 127, 131, 128, 128, 127, 117, 138,
    134, 120, 133, 133, 128, 137, 127, 121, 123, 140, 140, 117, 112, 136, 131, 123,
    131, 115, 126, 136, 89, 126, 136, 121, 137, 129, 119, 143, 112, 136, 115, 134,
    115, 118, 125, 137, 110, 139, 148, 116, 120, 133, 106, 63, 129, 137, 60, 138,
    143, 128, 134, 130, 133, 134, 133, 133, 105, 125, 125, 96, 140, 137, 138, 140,
    133, 117, 137, 128, 138, 138, 121, 134, 116, 122, 113, 127, 121, 113, 129, 110,
    132, 139, 136, 132, 145, 121, 129, 96, 134, 141, 134, 131, 122, 113, 135, 140,
    132, 143, 131, 138, 137, 145, 143, 145, 88, 133, 138, 142, 124, 130, 141, 124
  ],
  [
    136, 132, 133, 142, 136, 135, 139, 142, 111, 139, 134, 129, 129, 123, 137, 123,
    141, 142, 146, 136, 143, 124, 129, 103, 133, 136, 146, 135, 128, 132, 141, 135,
    133, 125, 116, 139, 129, 146, 129, 137, 140, 131, 126, 132, 139, 135, 136, 135,
    132, 135, 124, 124, 130, 126, 148, 142, 129, 139, 147, 107, 140, 146, 135, 127,
    134, 141, 149, 142, 133, 105, 112, 128, 139, 133, 118, 144, 152, 135, 105, 123,
    128, 146, 104, 127, 130, 119, 119, 131, 114, 123, 129, 131, 120, 139, 132, 109,
    132, 141, 117, 143, 130, 134, 125, 148, 113, 127, 130, 124, 132, 133, 131, 131,
    149, 121, 145, 89, 128, 123, 143, 125, 135, 130, 146, 129, 99, 143, 112, 132
  ],
  [
    143, 126, 149, 108, 131, 146, 139, 125, 131, 148, 136, 140, 156, 136, 125, 127,
    117, 119, 142, 123, 124, 135, 111, 126, 140, 116, 132, 122, 122, 125, 121, 138,
    138, 126, 134, 122, 33, 133, 142, 117, 139, 123, 137, 125, 125, 127, 131, 114,
    123, 142, 117, 122, 106, 136, 105, 146, 129, 135, 137, 124, 123, 119, 117, 118,
    132, 134, 53, 104, 123, 146, 150, 148, 147, 123, 138, 119, 117, 39, 129, 137,
    127, 135, 139, 117, 118, 127, 86, 149, 118, 128, 129, 131, 133, 120, 21, 122,
    10, 141, 138, 133, 125, 148, 131, 57, 133, 130, 154, 31, 126, 138, 123, 141,
    137, 127, 134, 133, 127, 127, 124, 147, 121, 126, 136, 121, 122, 122, 151, 136
  ],
  [
    75, 120, 129, 121, 116, 127, 150, 127, 139, 145, 126, 142, 128, 119, 124, 149,
    139, 146, 147, 120, 149, 145, 147, 136, 155, 135, 141, 128, 58, 153, 127, 17,
    140, 156, 132, 95, 154, 158, 145, 143, 133, 140, 154, 140, 133, 147, 120, 128,
    148, 155, 135, 117, 119, 154, 134, 135, 116, 107, 116, 134, 122, 149, 155, 136,
    138, 142, 138, 122, 147, 15, 150, 139, 151, 131, 135, 121, 147, 36, 124, 139,
    150, 121, 144, 124, 140, 114, 144, 122, 129, 152, 139, 126, 133, 140, 137, 119,
    133, 79, 147, 150, 131, 127, 129, 129, 125, 137, 144, 127, 154, 132, 145, 140,
    122, 155, 155, 155, 133, 132, 149, 155, 128, 97, 148, 125, 134, 147, 118, 127
  ],
  [
    127, 128, 49, 150, 147, 150, 119, 142, 125, 124, 123, 10, 134, 128, 149, 170,
    120, 128, 149, 132, 132, 131, 105, 107, 110, 139, 117, 112, 151, 139, 133, 150,
    132, 121, 64, 135, 77, 135, 150, 135, 107, 119, 125, 128, 148, 123, 126, 114,
    5, 150, 116, 148, 122, 117, 135, 140, 148, 139, 124, 111, 140, 113, 137, 119,
    139, 135, 147, 123, 147, 145, 131, 147, 127, 128, 128, 143, 141, 143, 114, 39,
    120, 145, 129, 125, 136, 124, 75, 136, 118, 146, 144, 127, 127, 149, 127, 122,
    126, 122, 131, 139, 143, 134, 141, 131, 127, 131, 120, 117, 142, 126, 118, 149,
    117, 120, 142, 121, 106, 133, 66, 128, 148, 149, 77, 130, 134, 173, 106, 143
  ],
  [
    132, 145, 137, 137, 142, 135, 141, 106, 131, 152, 136, 148, 135, 134, 151, 155,
    134, 123, 149, 136, 121, 158, 140, 144, 148, 134, 136, 157, 127, 138, 145, 35,
    152, 155, 105, 143, 147, 141, 121, 154, 129, 143, 153, 136, 129, 117, 130, 29,
    141, 143, 120, 136, 136, 162, 134, 153, 146, 148, 137, 137, 122, 108, 18, 137,
    122, 151, 139, 125, 141, 135, 135, 132, 129, 137, 153, 129, 150, 147, 147, 142,
    148, 152, 112, 144, 138, 154, 133, 151, 122, 155, 59, 73, 140, 122, 151, 138,
    149, 130, 153, 159, 147, 151, 141, 130, 133, 134, 152, 123, 141, 143, 130, 148,
    112, 131, 144, 146, 131, 148, 149, 115, 168, 152, 157, 143, 120, 147, 24, 136
  ],
  [
    165, 149, 153, 154, 166, 165, 151, 154, 122, 154, 147, 159, 130, 167, 161, 152,
    169, 156, 154, 140, 139, 157, 169, 148, 152, 151, 102, 153, 168, 156, 137, 162,
    159, 155, 146, 153, 159, 158, 165, 167, 148, 164, 154, 134, 78, 149, 157, 157,
    153, 166, 37, 158, 161, 183, 153, 157, 128, 161, 136, 157, 161, 170, 167, 165,
    165, 142, 173, 158, 159, 161, 142, 31, 168, 117, 145, 149, 151, 156, 156, 151,
    152, 165, 135, 127, 139, 132, 48, 143, 142, 134, 157, 63, 168, 158, 159, 129,
    160, 141, 157, 167, 159, 163, 150, 150, 150, 153, 157, 170, 160, 149, 150, 155,
    150, 153, 146, 148, 152, 167, 156, 157, 147, 149, 169, 160, 143, 139, 155, 154
  ],
  [
    161, 142, 105, 158, 151, 149, 150, 149, 141, 115, 138, 146, 169, 141, 131, 159,
    141, 127, 163, 139, 138, 137, 121, 149, 133, 124, 125, 132, 130, 161, 150, 142,
    117, 139, 140, 158, 138, 157, 75, 171, 147, 149, 125, 131, 57, 52, 122, 157,
    133, 148, 122, 61, 153, 142, 123, 147, 161, 165, 147, 67, 181, 125, 154, 152,
    60, 146, 133, 120, 161, 160, 119, 162, 149, 129, 145, 110, 154, 129, 163, 118,
    165, 123, 145, 154, 102, 143, 149, 131, 105, 145, 153, 136, 142, 148, 135, 152,
    132, 125, 109, 76, 131, 169, 134, 146, 121, 157, 142, 123, 111, 158, 138, 144,
    161, 139, 124, 146, 40, 119, 133, 121, 148, 133, 152, 136, 67, 140, 150, 110
  ],
  [
    147, 150, 155, 150, 151, 153, 133, 121, 113, 153, 159, 92, 140, 154, 80, 147,
    118, 100, 117, 171, 125, 149, 140, 133, 151, 159, 146, 168, 121, 156, 139, 152,
    99, 137, 164, 139, 161, 159, 153, 148, 130, 141, 144, 156, 158, 155, 142, 152,
    120, 148, 125, 130, 136, 131, 122, 121, 153, 125, 157, 122, 143, 103, 157, 161,
    136, 161, 130, 164, 139, 137, 151, 154, 121, 161, 146, 163, 140, 163, 132, 165,
    152, 152, 125, 155, 80, 149, 125, 159, 77, 138, 149, 150, 143, 153, 160, 141,
    168, 147, 140, 165, 173, 149, 130, 135, 157, 143, 80, 164, 140, 146, 150, 163,
    155, 130, 114, 125, 124, 153, 141, 159, 142, 147, 153, 147, 148, 159, 147, 145
  ],
  [
    151, 144, 130, 157, 159, 152, 140, 154, 144, 149, 135, 151, 160, 130, 148, 141,
    114, 143, 156, 149, 139, 151, 144, 144, 141, 125, 150, 150, 117, 147, 152, 130,
    144, 149, 139, 157, 145, 137, 139, 138, 157, 161, 139, 153, 153, 146, 128, 152,
    147, 141, 127, 150, 158, 135, 143, 108, 155, 152, 125, 151, 80, 141, 140, 159,
    151, 155, 153, 122, 162, 128, 151, 143, 154, 157, 151, 154, 150, 148, 131, 151,
    127, 141, 142, 127, 90, 149, 137, 139, 99, 158, 126, 150, 122, 148, 127, 152,
    160, 154, 154, 156, 153, 120, 135, 153, 83, 146, 134, 157, 87, 149, 139, 158,
    154, 138, 153, 168, 153, 132, 141, 143, 134, 145, 130, 134, 155, 134, 152, 92
  ],
  [
    139, 136, 150, 141, 155, 143, 128, 147, 141, 119, 129, 154, 128, 147, 146, 148,
    127, 121, 147, 79, 137, 139, 117, 154, 144, 149, 126, 126, 153, 93, 132, 129,
    140, 146, 116, 136, 153, 131, 140, 151, 63, 147, 137, 145, 104, 156, 145, 126,
    144, 133, 102, 113, 122, 129, 147, 141, 115, 148, 134, 121, 91, 115, 113, 117,
    132, 131, 127, 75, 149, 153, 146, 147, 131, 143, 120, 122, 131, 149, 124, 139,
    111, 57, 150, 129, 150, 117, 139, 153, 98, 149, 126, 128, 146, 86, 132, 148,
    151, 129, 134, 143, 148, 131, 110, 118, 118, 142, 146, 101, 139, 125, 149, 147,
    138, 139, 79, 148, 131, 140, 121, 136, 141, 115, 127, 111, 141, 124, 123, 129
  ],
  [
    103, 141, 84, 115, 141, 120, 144, 146, 121, 88, 132, 110, 144, 145, 109, 132,
    95, 90, 99, 111, 137, 115, 116, 122, 111, 115, 119, 102, 113, 109, 121, 124,
    89, 127, 148, 121, 148, 108, 143, 132, 132, 127, 110, 140, 122, 128, 118, 110,
    87, 139, 128, 123, 126, 113, 100, 128, 106, 120, 100, 152, 103, 137, 120, 93,
    125, 141, 134, 134, 141, 128, 124, 123, 111, 123, 126, 88, 120, 126, 98, 146,
    78, 121, 122, 119, 140, 98, 126, 125, 144, 124, 113, 142, 115, 153, 105, 122,
    120, 134, 124, 128, 96, 139, 149, 126, 144, 120, 117, 144, 117, 145, 88, 111,
    98, 140, 105, 115, 126, 131, 128, 132, 107, 113, 113, 115, 114, 121, 105, 96
  ],
  [
    67, 121, 97, 112, 128, 143, 94, 111, 90, 94, 129, 111, 111, 138, 105, 117,
    124, 123, 107, 112, 113, 119, 108, 114, 109, 124, 145, 116, 93, 107, 114, 109,
    114, 103, 104, 118, 82, 121, 132, 107, 129, 129, 128, 126, 99, 107, 103, 137,
    90, 77, 122, 121, 108, 118, 135, 91, 116, 133, 115, 79, 121, 121, 47, 111,
    127, 122, 93, 120, 136, 104, 119, 139, 97, 98, 97, 96, 117, 136, 131, 116,
    111, 111, 123, 121, 116, 127, 101, 121, 121, 115, 111, 115, 87, 99, 88, 115,
    137, 112, 100, 136, 112, 129, 108, 112, 125, 129, 121, 129, 126, 117, 135, 136,
    127, 147, 122, 117, 123, 117, 131, 128, 59, 105, 103, 145, 77, 133, 128, 105
  ],
  [
    154, 143, 135, 148, 139, 148, 139, 149, 114, 148, 130, 125, 109, 117, 139, 124,
    123, 155, 134, 148, 152, 120, 147, 95, 128, 109, 124, 127, 122, 123, 143, 138,
    112, 139, 124, 142, 139, 151, 134, 133, 146, 133, 110, 127, 153, 135, 136, 125,
    124, 144, 100, 125, 125, 123, 151, 145, 121, 146, 156, 99, 151, 138, 138, 128,
    139, 125, 147, 113, 129, 120, 114, 125, 143, 124, 131, 150, 167, 129, 94, 113,
    123, 130, 107, 116, 144, 104, 53, 141, 102, 131, 126, 136, 113, 144, 136, 93,
    133, 148, 130, 145, 126, 149, 132, 145, 115, 130, 132, 98, 122, 145, 120, 127,
    157, 129, 144, 86, 130, 122, 151, 111, 120, 130, 152, 131, 108, 159, 118, 129
  ],
  [
    121, 119, 150, 121, 141, 158, 148, 148, 123, 154, 144, 156, 173, 153, 152, 120,
    121, 138, 145, 138, 114, 153, 93, 136, 149, 135, 108, 106, 139, 128, 114, 132,
    140, 121, 138, 119, 41, 129, 151, 115, 148, 127, 142, 130, 128, 126, 149, 89,
    138, 168, 131, 135, 129, 145, 115, 159, 135, 146, 116, 113, 151, 107, 125, 132,
    141, 156, 72, 113, 131, 153, 154, 159, 162, 134, 149, 119, 134, 68, 130, 102,
    123, 150, 144, 122, 109, 121, 118, 154, 134, 113, 142, 139, 146, 129, 45, 147,
    11, 157, 156, 126, 122, 147, 126, 111, 123, 141, 166, 23, 126, 145, 137, 151,
    143, 139, 146, 154, 123, 134, 100, 148, 117, 125, 146, 133, 123, 148, 158, 150
  ],
  [
    95, 119, 150, 127, 133, 144, 168, 117, 148, 150, 146, 153, 157, 135, 147, 161,
    156, 152, 159, 130, 163, 148, 157, 142, 176, 149, 157, 143, 60, 167, 145, 25,
    156, 171, 149, 110, 160, 166, 155, 152, 148, 155, 166, 154, 157, 161, 131, 149,
    166, 167, 143, 123, 142, 169, 149, 139, 125, 128, 119, 151, 134, 161, 154, 149,
    151, 155, 161, 133, 165, 44, 154, 150, 168, 150, 151, 135, 152, 42, 133, 163,
    149, 129, 148, 128, 160, 123, 142, 142, 149, 157, 151, 131, 142, 152, 171, 134,
    145, 111, 155, 169, 149, 115, 146, 141, 146, 154, 154, 150, 162, 148, 148, 156,
    153, 160, 166, 158, 150, 142, 149, 186, 146, 111, 158, 148, 146, 161, 148, 130
  ],
  [
    144, 147, 67, 165, 164, 167, 133, 159, 133, 148, 144, 20, 158, 136, 157, 187,
    129, 148, 161, 138, 149, 153, 115, 117, 124, 154, 125, 135, 164, 164, 152, 161,
    151, 137, 66, 150, 98, 154, 157, 157, 127, 136, 150, 165, 161, 146, 153, 140,
    5, 170, 133, 160, 143, 135, 126, 162, 140, 159, 132, 125, 163, 148, 157, 122,
    162, 156, 157, 146, 160, 159, 137, 163, 140, 147, 152, 142, 160, 155, 130, 51,
    135, 153, 140, 126, 152, 148, 85, 154, 126, 165, 159, 153, 143, 165, 139, 143,
    145, 149, 152, 152, 165, 159, 157, 135, 152, 137, 144, 126, 157, 148, 128, 159,
    119, 131, 152, 149, 117, 153, 140, 154, 159, 163, 116, 151, 154, 190, 152, 169
  ],
  [
    147, 158, 143, 142, 153, 157, 143, 118, 102, 147, 154, 155, 135, 151, 152, 163,
    146, 130, 151, 142, 129, 168, 115, 158, 155, 152, 150, 175, 53, 154, 156, 45,
    166, 170, 93, 149, 163, 150, 126, 164, 140, 138, 159, 149, 149, 141, 137, 34,
    154, 106, 84, 124, 143, 173, 150, 158, 151, 160, 151, 153, 134, 122, 29, 153,
    118, 165, 145, 143, 154, 149, 149, 133, 136, 150, 151, 122, 172, 148, 162, 159,
    147, 169, 111, 150, 143, 176, 140, 155, 120, 166, 81, 86, 154, 138, 166, 143,
    158, 141, 165, 171, 164, 174, 145, 88, 143, 148, 157, 131, 89, 148, 128, 156,
    115, 132, 155, 156, 140, 143, 162, 123, 182, 168, 175, 155, 137, 143, 26, 131
  ],
  [
    170, 165, 166, 165, 173, 184, 156, 165, 150, 161, 154, 174, 129, 194, 172, 165,
    185, 169, 164, 154, 153, 176, 188, 152, 165, 158, 91, 160, 184, 156, 152, 176,
    162, 161, 138, 165, 165, 174, 183, 176, 160, 169, 161, 89, 102, 160, 163, 163,
    168, 177, 62, 174, 173, 193, 166, 166, 136, 170, 151, 151, 179, 187, 197, 194,
    166, 155, 194, 169, 176, 174, 151, 43, 173, 125, 165, 165, 167, 166, 166, 147,
    163, 179, 157, 155, 155, 151, 50, 149, 158, 140, 167, 84, 188, 169, 167, 145,
    166, 142, 174, 179, 156, 173, 163, 159, 159, 159, 169, 190, 172, 156, 159, 161,
    154, 157, 160, 152, 164, 175, 172, 165, 156, 159, 175, 176, 154, 149, 178, 173
  ],
  [
    171, 144, 113, 159, 151, 142, 139, 156, 154, 75, 131, 134, 184, 144, 138, 168,
    149, 147, 171, 157, 150, 134, 120, 150, 156, 125, 131, 151, 135, 165, 164, 124,
    116, 148, 148, 175, 151, 161, 136, 175, 159, 152, 103, 148, 77, 55, 131, 176,
    147, 141, 130, 69, 160, 149, 128, 158, 164, 153, 139, 71, 195, 144, 166, 162,
    84, 145, 148, 130, 161, 168, 129, 172, 164, 153, 128, 145, 156, 142, 165, 129,
    168, 119, 132, 168, 129, 153, 153, 143, 127, 158, 152, 132, 141, 157, 146, 151,
    143, 136, 109, 121, 141, 171, 148, 153, 122, 163, 146, 124, 107, 165, 144, 143,
    178, 149, 139, 160, 54, 125, 149, 137, 150, 138, 147, 147, 79, 149, 159, 105
  ],
  [
    152, 156, 129, 156, 131, 131, 116, 134, 150, 144, 167, 110, 147, 155, 110, 142,
    129, 85, 127, 167, 139, 161, 142, 130, 160, 170, 158, 162, 134, 139, 145, 154,
    121, 122, 158, 131, 165, 168, 157, 136, 138, 142, 135, 164, 154, 136, 139, 144,
    108, 123, 137, 129, 138, 121, 137, 148, 133, 125, 151, 128, 135, 120, 154, 162,
    145, 163, 149, 161, 151, 139, 153, 131, 113, 158, 132, 157, 146, 175, 102, 173,
    145, 154, 107, 151, 93, 148, 133, 160, 97, 151, 161, 142, 136, 140, 170, 132,
    154, 167, 154, 173, 175, 147, 130, 141, 151, 134, 132, 156, 138, 147, 156, 157,
    149, 131, 129, 114, 135, 149, 141, 156, 99, 153, 138, 150, 143, 147, 153, 139
  ],
  [
    156, 167, 108, 166, 177, 152, 148, 171, 149, 159, 148, 154, 150, 123, 159, 154,
    163, 148, 156, 157, 130, 158, 155, 154, 135, 129, 156, 164, 169, 155, 164, 142,
    149, 154, 149, 170, 158, 148, 132, 138, 153, 189, 152, 167, 163, 151, 145, 157,
    144, 152, 148, 156, 170, 133, 146, 142, 168, 151, 151, 152, 103, 152, 154, 176,
    149, 170, 156, 123, 181, 125, 159, 127, 166, 160, 148, 156, 161, 152, 151, 145,
    123, 153, 153, 138, 108, 155, 152, 173, 131, 172, 103, 157, 147, 175, 125, 160,
    160, 155, 159, 154, 166, 131, 127, 162, 90, 156, 152, 181, 74, 159, 149, 162,
    166, 135, 166, 192, 160, 127, 139, 147, 163, 153, 148, 128, 163, 139, 171, 107
  ],
  [
    132, 133, 153, 151, 140, 120, 91, 111, 150, 129, 128, 156, 130, 148, 128, 152,
    127, 116, 120, 125, 134, 132, 125, 136, 164, 148, 111, 132, 128, 116, 125, 126,
    149, 149, 124, 120, 144, 135, 154, 96, 89, 119, 137, 136, 127, 158, 138, 131,
    159, 124, 104, 117, 141, 119, 145, 143, 106, 142, 124, 110, 100, 102, 120, 131,
    133, 122, 131, 104, 149, 154, 144, 137, 113, 150, 131, 130, 131, 149, 119, 132,
    124, 76, 148, 140, 157, 107, 140, 151, 122, 148, 136, 123, 132, 91, 130, 123,
    152, 83, 111, 138, 154, 116, 120, 98, 115, 125, 151, 109, 119, 139, 142, 153,
    95, 122, 86, 112, 122, 109, 116, 130, 145, 132, 133, 119, 144, 99, 134, 130
  ],
  [
    120, 117, 99, 123, 129, 99, 115, 119, 113, 66, 122, 108, 129, 135, 97, 130,
    71, 69, 89, 123, 106, 96, 124, 109, 107, 102, 93, 101, 109, 110, 120, 104,
    127, 137, 129, 106, 149, 109, 119, 117, 135, 111, 108, 127, 110, 91, 125, 123,
    84, 128, 101, 90, 98, 97, 115, 147, 110, 103, 97, 115, 113, 141, 105, 74,
    124, 126, 130, 121, 136, 123, 103, 127, 129, 111, 102, 75, 123, 113, 87, 110,
    106, 139, 97, 123, 107, 91, 104, 103, 116, 123, 84, 94, 91, 141, 90, 115,
    105, 108, 110, 126, 90, 113, 122, 90, 119, 100, 100, 145, 98, 119, 100, 112,
    91, 94, 100, 105, 113, 124, 98, 111, 127, 107, 98, 101, 102, 121, 103, 105
  ],
  [
    113, 98, 91, 107, 128, 83, 99, 141, 105, 96, 120, 107, 126, 148, 122, 142,
    133, 124, 142, 100, 126, 96, 138, 116, 114, 135, 146, 71, 83, 133, 113, 115,
    120, 95, 137, 142, 115, 122, 124, 123, 131, 117, 109, 95, 96, 80, 114, 142,
    102, 113, 116, 127, 103, 131, 121, 115, 115, 108, 101, 96, 134, 140, 83, 122,
    133, 111, 95, 122, 123, 137, 107, 102, 105, 103, 113, 90, 114, 134, 117, 119,
    105, 105, 91, 124, 123, 130, 89, 99, 114, 79, 125, 127, 70, 97, 79, 116,
    103, 91, 116, 141, 124, 121, 119, 98, 119, 136, 99, 144, 123, 125, 112, 125,
    126, 114, 118, 129, 125, 113, 137, 144, 75, 132, 110, 104, 86, 107, 132, 90
  ],
  [
    152, 140, 143, 131, 148, 120, 139, 147, 135, 148, 129, 111, 112, 120, 119, 117,
    146, 128, 153, 149, 146, 150, 150, 120, 119, 137, 113, 114, 121, 137, 141, 98,
    135, 111, 130, 136, 154, 155, 138, 129, 148, 131, 110, 137, 107, 134, 149, 125,
    109, 121, 109, 124, 137, 142, 153, 139, 99, 136, 136, 123, 137, 125, 135, 148,
    144, 119, 148, 108, 129, 132, 131, 108, 98, 135, 140, 142, 147, 120, 81, 117,
    103, 109, 127, 123, 124, 113, 112, 94, 127, 136, 122, 148, 137, 152, 121, 113,
    130, 121, 141, 122, 123, 150, 141, 150, 150, 129, 143, 121, 136, 148, 92, 129,
    148, 116, 146, 116, 141, 140, 148, 130, 117, 144, 133, 115, 113, 149, 97, 131
  ],
  [
    140, 121, 99, 111, 116, 115, 112, 125, 113, 101, 116, 125, 123, 137, 87, 110,
    119, 132, 112, 128, 103, 147, 99, 118, 127, 130, 115, 125, 99, 123, 116, 113,
    127, 116, 95, 145, 107, 100, 113, 147, 143, 111, 119, 109, 123, 130, 106, 101,
    104, 132, 133, 105, 115, 87, 110, 132, 129, 130, 122, 122, 135, 119, 96, 124,
    125, 129, 97, 106, 130, 129, 148, 149, 83, 132, 116, 150, 141, 90, 105, 140,
    108, 121, 140, 109, 126, 148, 98, 137, 94, 119, 117, 119, 138, 116, 134, 122,
    96, 150, 127, 96, 117, 107, 112, 90, 103, 134, 102, 127, 118, 106, 111, 137,
    139, 79, 99, 120, 95, 81, 126, 113, 113, 92, 117, 99, 119, 125, 126, 149
  ],
  [
    105, 140, 143, 198, 131, 152, 130, 196, 123, 132, 128, 97, 129, 141, 110, 104,
    135, 120, 136, 122, 131, 144, 142, 104, 93, 71, 125, 130, 154, 100, 146, 145,
    141, 144, 142, 157, 125, 131, 126, 165, 132, 89, 129, 125, 139, 136, 134, 159,
    143, 146, 141, 107, 120, 114, 153, 138, 133, 145, 129, 129, 150, 125, 135, 138,
    106, 150, 149, 116, 127, 85, 117, 106, 131, 131, 112, 143, 123, 145, 136, 147,
    129, 147, 97, 145, 122, 136, 129, 132, 155, 133, 122, 133, 171, 144, 129, 151,
    131, 127, 119, 114, 154, 142, 113, 140, 95, 117, 140, 117, 149, 150, 127, 153,
    136, 129, 159, 121, 96, 199, 111, 132, 130, 129, 122, 104, 104, 131, 130, 138
  ],
  [
    156, 159, 154, 179, 156, 132, 162, 150, 146, 131, 158, 161, 157, 151, 159, 154,
    137, 130, 149, 148, 119, 115, 140, 154, 120, 156, 157, 161, 159, 154, 158, 142,
    159, 142, 163, 159, 146, 123, 154, 156, 149, 147, 146, 163, 162, 150, 155, 155,
    155, 152, 150, 151, 150, 159, 162, 149, 157, 139, 148, 151, 171, 156, 163, 157,
    163, 160, 166, 162, 159, 172, 151, 148, 154, 147, 157, 135, 146, 157, 142, 148,
    155, 163, 155, 138, 100, 104, 163, 147, 159, 150, 148, 137, 163, 123, 126, 155,
    165, 142, 139, 149, 162, 157, 147, 132, 149, 141, 157, 146, 153, 146, 140, 142,
    153, 156, 149, 148, 160, 164, 160, 141, 169, 120, 158, 130, 109, 157, 147, 137
  ],
  [
    159, 147, 163, 160, 127, 159, 147, 125, 149, 164, 155, 159, 155, 159, 153, 121,
    152, 146, 148, 137, 131, 168, 149, 134, 142, 126, 163, 159, 155, 147, 159, 148,
    155, 116, 159, 159, 141, 160, 145, 169, 149, 150, 151, 150, 142, 166, 138, 155,
    157, 149, 153, 145, 152, 152, 122, 159, 150, 164, 154, 147, 148, 124, 159, 154,
    151, 152, 156, 151, 160, 165, 134, 119, 156, 156, 150, 172, 160, 151, 152, 147,
    150, 146, 148, 137, 181, 151, 128, 140, 132, 144, 139, 152, 151, 157, 159, 127,
    142, 162, 150, 162, 155, 155, 144, 148, 125, 142, 154, 136, 154, 161, 156, 153,
    155, 148, 130, 162, 149, 149, 148, 146, 150, 158, 157, 138, 133, 161, 120, 142
  ],
  [
    154, 170, 179, 164, 187, 161, 170, 168, 166, 181, 186, 159, 185, 180, 163, 185,
    164, 181, 178, 161, 181, 163, 183, 159, 180, 162, 158, 173, 179, 170, 189, 181,
    174, 166, 177, 171, 175, 175, 162, 171, 177, 184, 149, 167, 180, 168, 174, 157,
    167, 174, 195, 174, 187, 164, 164, 166, 152, 167, 162, 169, 173, 189, 169, 177,
    175, 168, 164, 166, 183, 182, 175, 173, 175, 180, 164, 183, 172, 169, 174, 147,
    157, 176, 137, 176, 181, 189, 173, 174, 173, 196, 176, 169, 167, 182, 183, 180,
    164, 170, 157, 185, 175, 150, 167, 188, 165, 173, 173, 178, 166, 179, 175, 185,
    184, 178, 179, 179, 181, 177, 164, 185, 157, 172, 145, 173, 167, 160, 185, 158
  ],
  [
    179, 173, 191, 192, 190, 181, 163, 172, 166, 194, 183, 177, 177, 181, 167, 173,
    173, 167, 180, 170, 180, 188, 179, 176, 154, 186, 185, 175, 180, 182, 152, 173,
    178, 173, 183, 168, 169, 183, 189, 174, 175, 178, 167, 183, 172, 177, 185, 177,
    176, 189, 189, 175, 177, 185, 153, 185, 178, 179, 179, 181, 174, 180, 162, 167,
    166, 196, 167, 169, 191, 167, 168, 195, 185, 187, 192, 177, 181, 175, 176, 171,
    177, 148, 180, 181, 166, 161, 164, 179, 173, 185, 174, 173, 175, 175, 161, 167,
    180, 181, 162, 181, 165, 169, 171, 159, 187, 182, 174, 180, 166, 186, 181, 167,
    167, 181, 179, 167, 178, 178, 167, 172, 166, 162, 171, 184, 180, 177, 184, 161
  ]
]
def gatedNormCap : BF := BFloat16DyadicBounds.ceiling 1 1
def gatedNorm (layer : Fin 48) : Fin 128 → BF := raw gatedNormDictionary gatedNormIndices layer

theorem gatedNormCap_real : Model.toReal gatedNormCap = 2 := by
  have h := (BFloat16DyadicBounds.ceiling_range 1 1 (by decide) (by decide) (by decide)).2
  norm_num at h
  exact h

set_option maxRecDepth 30000 in
set_option maxHeartbeats 0 in
theorem gatedNorm_checked : TensorWords.check gatedNormDictionary gatedNormCap = true := by decide +kernel

set_option maxRecDepth 30000 in
set_option maxHeartbeats 0 in
theorem gatedNorm_dimensions : gatedNormDictionary.length = 200 ∧ gatedNormIndices.length = 48 ∧
    gatedNormIndices.all (fun row => decide (row.length = 128) && row.all (fun i => decide (i < 200))) = true := by
  decide +kernel

theorem gatedNorm_bound (layer : Fin 48) (i : Fin 128) :
    Model.isFinite (gatedNorm layer i) = true ∧ |Model.toReal (gatedNorm layer i)| ≤ 2 := by
  have fallback : Model.isFinite CheckpointRanges.zeroCap = true ∧
      |Model.toReal CheckpointRanges.zeroCap| ≤ Model.toReal gatedNormCap := by
    refine ⟨by decide +kernel, ?_⟩
    rw [CheckpointRanges.zeroCap_real, gatedNormCap_real]
    norm_num
  simpa only [gatedNorm, raw, gatedNormCap_real] using
    TensorWords.check_getD gatedNormDictionary gatedNormCap CheckpointRanges.zeroCap gatedNorm_checked fallback
      ((gatedNormIndices[layer.val]?.getD [])[i.val]?.getD 0)

end Inference.Models.Qwen.CheckpointDeltaData
