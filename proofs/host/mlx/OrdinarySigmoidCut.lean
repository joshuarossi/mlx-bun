import host.mlx.OrdinarySigmoidStates
import host.mlx.NativeUnaryHost
import host.ts.RenameRouteDriver

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro33 28 4700 as Ordinary.SigmoidCall.calleeObject
host_transport_object P.RestStream.micro0.micro33 28 4393 as Ordinary.SigmoidCall.signatureObject
host_transport_object P.RestStream.micro0.micro33 28 3127013 as Ordinary.SigmoidCall.bufferObject
end Host.Load.Run.Full

namespace Host.Load.Run.Full.Ordinary.SigmoidCall
open Host.Ts
noncomputable def input : St LSt := P.RestStream.micro0.micro33.s28
noncomputable def output : St LSt := P.RestStream.micro0.micro33.s29
noncomputable def caps : List Val := match calleeObject.kind with
  | .fn (.native (.ffi .symbol) caps) => caps
  | _ => []
noncomputable def returns : Name := match Host.Ts.arg caps 2 with | .str name => name | _ => []
noncomputable def inputNode : Host.Mlx.Ffi.Node := (input.ffi.mlx.nodes.get 22585).getD ⟨.zeros,[],[],0⟩
theorem source_control : input.ctl = .call (.obj 4700) (.obj 4817)
    [.ptr (.js 3127013) 0,.big (Int.ofNat 29369),.big (Int.ofNat 2)] := by host_kernel_rfl
theorem source_callee : input.heap.get 4700 = some (.obj calleeObject) := by host_kernel_rfl
theorem source_kind : calleeObject.kind = .fn (.native (.ffi .symbol) caps) := by host_kernel_rfl
theorem source_caps : caps = [.str chars!"mlx_sigmoid",.obj 4393,.str returns] := by host_kernel_rfl
theorem source_signature : input.heap.get 4393 = some (.obj signatureObject) := by host_kernel_rfl
theorem source_signature_kind : signatureObject.kind = .array [.str chars!"ptr",.str chars!"u64",.str chars!"u64"] := by host_kernel_rfl
theorem source_buffer : input.heap.get 3127013 = some (.obj bufferObject) := by host_kernel_rfl
theorem source_buffer_kind : bufferObject.kind = .buf (cellParts .u64 (.big (Int.ofNat 0)) 8 0) := by host_kernel_rfl
theorem source_input : input.ffi.mlx.nodeId? 29369 = some 22585 := by host_kernel_rfl
theorem source_node : input.ffi.mlx.nodes.get 22585 = some inputNode := by host_kernel_rfl
theorem source_counter : input.ffi.mlx.next = 29381 := by host_kernel_rfl
theorem source_node_counter : input.ffi.mlx.nnext = 22594 := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.SigmoidCall
