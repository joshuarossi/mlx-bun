import host.mlx.OrdinaryVectorGetStates
import host.mlx.NativeVectorGetHost
import host.ts.RenameRouteDriver

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro25 7 4684 as Ordinary.VectorGetCall.calleeObject
host_transport_object P.RestStream.micro0.micro25 7 4361 as Ordinary.VectorGetCall.signatureObject
host_transport_object P.RestStream.micro0.micro25 7 3126927 as Ordinary.VectorGetCall.bufferObject
end Host.Load.Run.Full

namespace Host.Load.Run.Full.Ordinary.VectorGetCall
open Host.Ts
noncomputable def input : St LSt := P.RestStream.micro0.micro25.s7
noncomputable def output : St LSt := P.RestStream.micro0.micro25.s8
noncomputable def caps : List Val := match calleeObject.kind with
  | .fn (.native (.ffi .symbol) caps) => caps
  | _ => []
noncomputable def returns : Name := match Host.Ts.arg caps 2 with | .str name => name | _ => []
theorem source_control : input.ctl = .call (.obj 4684) (.obj 4817)
    [.ptr (.js 3126927) 0,.big (Int.ofNat 29377),.big (Int.ofNat 0)] := by host_kernel_rfl
theorem source_callee : input.heap.get 4684 = some (.obj calleeObject) := by host_kernel_rfl
theorem source_kind : calleeObject.kind = .fn (.native (.ffi .symbol) caps) := by host_kernel_rfl
theorem source_caps : caps = [.str chars!"mlx_vector_array_get",.obj 4361,.str returns] := by host_kernel_rfl
theorem source_signature : input.heap.get 4361 = some (.obj signatureObject) := by host_kernel_rfl
theorem source_signature_kind : signatureObject.kind = .array [.str chars!"ptr",.str chars!"u64",.str chars!"u64"] := by host_kernel_rfl
theorem source_buffer : input.heap.get 3126927 = some (.obj bufferObject) := by host_kernel_rfl
theorem source_buffer_kind : bufferObject.kind = .buf (cellParts .u64 (.big (Int.ofNat 0)) 8 0) := by host_kernel_rfl
theorem source_vector : input.ffi.mlx.obj? 29377 = some (.vec [22591,22592,22593]) := by host_kernel_rfl
theorem source_counter : input.ffi.mlx.next = 29378 := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.VectorGetCall
