import host.ts.renameOrdinary.NativeCallCutStates
import host.mlx.NativeVectorFactoryHost
import host.ts.RenameRouteDriver

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro23 50 4685 as Ordinary.VectorFactoryCall.calleeObject
host_transport_object P.RestStream.micro0.micro23 50 4363 as Ordinary.VectorFactoryCall.signatureObject
end Host.Load.Run.Full

namespace Host.Load.Run.Full.Ordinary.VectorFactoryCall
open Host.Ts
noncomputable def input : St LSt := P.RestStream.micro0.micro23.s50
noncomputable def output : St LSt := P.RestStream.micro0.micro23.s51
noncomputable def caps : List Val := match calleeObject.kind with
  | .fn (.native (.ffi .symbol) caps) => caps
  | _ => []
noncomputable def returns : Name := match Host.Ts.arg caps 2 with | .str name => name | _ => []
theorem source_control : input.ctl = .call (.obj 4685) (.obj 4817) [] := by host_kernel_rfl
theorem source_callee : input.heap.get 4685 = some (.obj calleeObject) := by host_kernel_rfl
theorem source_kind : calleeObject.kind = .fn (.native (.ffi .symbol) caps) := by host_kernel_rfl
theorem source_counter : input.ffi.mlx.next = 29377 := by host_kernel_rfl
theorem source_caps : caps = [.str chars!"mlx_vector_array_new",.obj 4363,.str returns] := by host_kernel_rfl
theorem source_signature : input.heap.get 4363 = some (.obj signatureObject) := by host_kernel_rfl
theorem source_signature_kind : signatureObject.kind = .array [] := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.VectorFactoryCall
