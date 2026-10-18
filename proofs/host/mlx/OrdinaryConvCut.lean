import host.mlx.OrdinaryConvStates
import host.mlx.FixedNativeRoles
import host.ts.RenameRouteDriver

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro18 56 4742 as Ordinary.ConvCall.calleeObject
host_transport_object P.RestStream.micro0.micro18 56 3126867 as Ordinary.ConvCall.outputBuffer
host_transport_object P.RestStream.micro0.micro18 56 4477 as Ordinary.ConvCall.signatureObject
end Host.Load.Run.Full

namespace Host.Load.Run.Full.Ordinary.ConvCall
open Host.Ts
noncomputable def input : St LSt := P.RestStream.micro0.micro18.s56
noncomputable def output : St LSt := P.RestStream.micro0.micro18.s57
noncomputable def native : Host.Mlx.Ffi.St := input.ffi.mlx
noncomputable def caps : List Val := match calleeObject.kind with
  | .fn (.native (.ffi .symbol) caps) => caps
  | _ => []
noncomputable def outputBytes : List Byte := match outputBuffer.kind with | .buf bs => bs | _ => []
noncomputable def inputNode : Host.Mlx.Ffi.Node := (native.nodes.get 22587).getD ⟨.zeros,[],[],0⟩
noncomputable def weightNode : Host.Mlx.Ffi.Node := (native.node? 1365).getD ⟨.zeros,[],[],0⟩
theorem source_control : input.ctl = .call (.obj 4742) (.obj 4817)
    [.ptr (.js 3126867) 0,.big (Int.ofNat 29372),.big (Int.ofNat 1365),.num one,.num zeroN,.num one,
      .num (.lit (F64.ofInt 10240)),.big (Int.ofNat 2)] := by host_kernel_rfl
theorem source_callee : input.heap.get 4742 = some (.obj calleeObject) := by host_kernel_rfl
theorem source_kind : calleeObject.kind = .fn (.native (.ffi .symbol) caps) := by host_kernel_rfl
noncomputable def returns : Name := match Host.Ts.arg caps 2 with | .str name => name | _ => []
theorem source_caps : caps = [.str chars!"mlx_conv1d",.obj 4477,.str returns] := by host_kernel_rfl
theorem source_signature : input.heap.get 4477 = some (.obj signatureObject) := by host_kernel_rfl
theorem source_signature_kind : signatureObject.kind = .array
    [.str chars!"ptr",.str chars!"u64",.str chars!"u64",.str chars!"i32",.str chars!"i32",.str chars!"i32",
      .str chars!"i32",.str chars!"u64"] := by host_kernel_rfl
theorem source_buffer : input.heap.get 3126867 = some (.obj outputBuffer) := by host_kernel_rfl
theorem source_buffer_kind : outputBuffer.kind = .buf outputBytes := by host_kernel_rfl
theorem source_output_bytes : outputBytes = cellParts .u64 (.big (Int.ofNat 0)) 8 0 := by host_kernel_rfl
theorem source_array : native.arrs.get 29372 = some 22587 := by host_kernel_rfl
theorem source_weight_array : native.arrs.get 1365 = some 1329 := by host_kernel_rfl
theorem source_input_node : native.nodes.get 22587 = some inputNode := by host_kernel_rfl
theorem source_weight_node : native.nodes.get 1329 = some weightNode := by host_kernel_rfl
theorem source_input_shape : inputNode.shape = [.lit 1,.lit 4,.lit 10240] := by host_kernel_rfl
theorem source_weight_shape : weightNode.shape = [.lit 10240,.lit 4,.lit 1] := by host_kernel_rfl
theorem source_input_dtype : inputNode.dtype = 12 := by host_kernel_rfl
theorem source_weight_dtype : weightNode.dtype = 12 := by host_kernel_rfl
theorem source_counter : native.next = 29375 := by host_kernel_rfl
theorem source_node_counter : native.nnext = 22590 := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.ConvCall
