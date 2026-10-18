import host.load.ReadTail
namespace Host.Load.Tests.ReadTail
open Host.Ts

/-- A real native uint32 read from one node, with two further readbacks unused. -/
def initial : Option (St Host.Mlx.Ffi.St) :=
  let ffi := Host.Mlx.Ffi.init [.ref 0, .ref 1, .ref 2] [] chars!"applegpu_g13s" []
  let (node, ffi) := ffi.addNode ⟨.zeros, [], [.lit 1], Host.Mlx.Ffi.dtUint32⟩
  let (handle, ffi) := ffi.setArr 0 node
  let s := realm ffi
  let (buffer, s) := s.allocObj (.buf (List.replicate 4 (.lit 0))) (.obj aArrayBufferProto) []
  let (types, s) := newArray s [.str chars!"ptr", .str chars!"u64"]
  let (fn_, s) := s.allocObj (.fn (.native (.ffi .symbol) [.str chars!"mlx_array_item_uint32", .obj types, .str chars!"i32"])) (.obj aFunctionProto) []
  some (s.go (.call (.obj fn_) .undef [.ptr (.js buffer) 0, .big handle]))

set_option maxHeartbeats 0 in
host_stream P : Host.Mlx.Ffi.ffi, initial, (List.range 3).map SymE.var, (fun i => F64.ofNat (100 + i)), 1, 2
end Host.Load.Tests.ReadTail
