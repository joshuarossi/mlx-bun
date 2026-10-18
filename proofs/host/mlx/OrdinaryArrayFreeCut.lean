import host.mlx.OrdinaryArrayFreeStates
import host.mlx.NativeArrayFreeHost
import host.ts.RenameRouteDriver

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro19 78 4633 as Ordinary.ArrayFreeCall.calleeObject
host_transport_object P.RestStream.micro0.micro19 78 4259 as Ordinary.ArrayFreeCall.signatureObject
end Host.Load.Run.Full

namespace Host.Load.Run.Full.Ordinary.ArrayFreeCall
open Host.Ts
noncomputable def input : St LSt := P.RestStream.micro0.micro19.s78
noncomputable def output : St LSt := P.RestStream.micro0.micro19.s79
noncomputable def caps : List Val := match calleeObject.kind with
  | .fn (.native (.ffi .symbol) caps) => caps
  | _ => []
noncomputable def returns : Name := match Host.Ts.arg caps 2 with | .str name => name | _ => []
theorem source_control : input.ctl = .call (.obj 4633) (.obj 4817) [.big (Int.ofNat 29372)] := by host_kernel_rfl
theorem source_callee : input.heap.get 4633 = some (.obj calleeObject) := by host_kernel_rfl
theorem source_kind : calleeObject.kind = .fn (.native (.ffi .symbol) caps) := by host_kernel_rfl
theorem source_caps : caps = [.str chars!"mlx_array_free",.obj 4259,.str returns] := by host_kernel_rfl
theorem source_signature : input.heap.get 4259 = some (.obj signatureObject) := by host_kernel_rfl
theorem source_signature_kind : signatureObject.kind = .array [.str chars!"u64"] := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.ArrayFreeCall
