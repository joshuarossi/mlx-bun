import host.mlx.OrdinaryVectorResultStates
import host.mlx.NativeVectorSizeHost
import host.ts.RenameRouteDriver

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro24 28 4789 as Ordinary.VectorSizeCall.calleeObject
host_transport_object P.RestStream.micro0.micro24 28 4571 as Ordinary.VectorSizeCall.signatureObject
end Host.Load.Run.Full

namespace Host.Load.Run.Full.Ordinary.VectorSizeCall
open Host.Ts
noncomputable def input : St LSt := P.RestStream.micro0.micro24.s28
noncomputable def output : St LSt := P.RestStream.micro0.micro24.s29
noncomputable def caps : List Val := match calleeObject.kind with
  | .fn (.native (.ffi .symbol) caps) => caps
  | _ => []
noncomputable def returns : Name := match Host.Ts.arg caps 2 with | .str name => name | _ => []
theorem source_control : input.ctl = .call (.obj 4789) (.obj 4817) [.big (Int.ofNat 29377)] := by host_kernel_rfl
theorem source_callee : input.heap.get 4789 = some (.obj calleeObject) := by host_kernel_rfl
theorem source_kind : calleeObject.kind = .fn (.native (.ffi .symbol) caps) := by host_kernel_rfl
theorem source_caps : caps = [.str chars!"mlx_vector_array_size",.obj 4571,.str returns] := by host_kernel_rfl
theorem source_signature : input.heap.get 4571 = some (.obj signatureObject) := by host_kernel_rfl
theorem source_signature_kind : signatureObject.kind = .array [.str chars!"u64"] := by host_kernel_rfl
theorem source_vector : input.ffi.mlx.obj? 29377 = some (.vec [22591,22592,22593]) := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.VectorSizeCall
