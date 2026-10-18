import host.mlx.OrdinaryVectorStates
import host.mlx.NativeSymbol
import host.ts.RenameRouteDriver

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro2 95 4630 as Ordinary.ArrayCall.calleeObject
host_transport_object P.RestStream.micro0.micro2 95 4253 as Ordinary.ArrayCall.signatureObject
end Host.Load.Run.Full

namespace Host.Load.Run.Full.Ordinary.ArrayCall
open Host.Ts

noncomputable def input : St LSt := P.RestStream.micro0.micro2.s95
noncomputable def output : St LSt := P.RestStream.micro0.micro2.s96
noncomputable def native : Host.Mlx.Ffi.St := input.ffi.mlx
noncomputable def calleeCaps : List Val := match calleeObject.kind with
  | .fn (.native (.ffi .symbol) caps) => caps
  | _ => []

theorem source_control : input.ctl = .call (.obj 4630) (.obj 4817) [] := by host_kernel_rfl
theorem source_callee : input.heap.get 4630 = some (.obj calleeObject) := by host_kernel_rfl
theorem source_callee_kind : calleeObject.kind = .fn (.native (.ffi .symbol) calleeCaps) := by host_kernel_rfl
theorem source_caps : calleeCaps = [.str chars!"mlx_array_new",.obj 4253,.str chars!"u64"] := by host_kernel_rfl
theorem source_signature : input.heap.get 4253 = some (.obj signatureObject) := by host_kernel_rfl
theorem source_signature_kind : signatureObject.kind = .array [] := by host_kernel_rfl
theorem source_native_output : native = output.ffi.mlx := by host_kernel_rfl

end Host.Load.Run.Full.Ordinary.ArrayCall
