import host.mlx.OrdinarySliceStates
import host.mlx.NativeSymbol
import host.mlx.FixedNativeRoles
import host.ts.RenameRouteDriver

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro10 86 4713 as Ordinary.SliceCall.calleeObject
host_transport_object P.RestStream.micro0.micro10 86 3126780 as Ordinary.SliceCall.outputBuffer
host_transport_object P.RestStream.micro0.micro10 86 3126752 as Ordinary.SliceCall.startBuffer
host_transport_object P.RestStream.micro0.micro10 86 3126754 as Ordinary.SliceCall.stopBuffer
host_transport_object P.RestStream.micro0.micro10 86 3126768 as Ordinary.SliceCall.strideBuffer
host_transport_object P.RestStream.micro0.micro10 86 4419 as Ordinary.SliceCall.signatureObject
end Host.Load.Run.Full

namespace Host.Load.Run.Full.Ordinary.SliceCall
open Host.Ts
noncomputable def input : St LSt := P.RestStream.micro0.micro10.s86
noncomputable def output : St LSt := P.RestStream.micro0.micro10.s87
noncomputable def native : Host.Mlx.Ffi.St := input.ffi.mlx
noncomputable def caps : List Val := match calleeObject.kind with
  | .fn (.native (.ffi .symbol) caps) => caps
  | _ => []
noncomputable def outputBytes : List Byte := match outputBuffer.kind with | .buf bs => bs | _ => []
noncomputable def startBytes : List Byte := match startBuffer.kind with | .buf bs => bs | _ => []
noncomputable def stopBytes : List Byte := match stopBuffer.kind with | .buf bs => bs | _ => []
noncomputable def strideBytes : List Byte := match strideBuffer.kind with | .buf bs => bs | _ => []
noncomputable def inputNode : Host.Mlx.Ffi.Node := (native.nodes.get 22587).getD ⟨.zeros,[],[],0⟩
theorem source_control : input.ctl = .call (.obj 4713) (.obj 4817)
    [.ptr (.js 3126780) 0,.big (Int.ofNat 29372),.ptr (.js 3126752) 0,.big (Int.ofNat 3),
      .ptr (.js 3126754) 0,.big (Int.ofNat 3),.ptr (.js 3126768) 0,.big (Int.ofNat 3),.big (Int.ofNat 2)] := by host_kernel_rfl
theorem source_callee : input.heap.get 4713 = some (.obj calleeObject) := by host_kernel_rfl
theorem source_kind : calleeObject.kind = .fn (.native (.ffi .symbol) caps) := by host_kernel_rfl
noncomputable def returns : Name := match Host.Ts.arg caps 2 with | .str name => name | _ => []
theorem source_caps : caps = [.str chars!"mlx_slice",.obj 4419,.str returns] := by host_kernel_rfl
theorem source_signature : input.heap.get 4419 = some (.obj signatureObject) := by host_kernel_rfl
theorem source_signature_kind : signatureObject.kind = .array
    [.str chars!"ptr",.str chars!"u64",.str chars!"ptr",.str chars!"u64",.str chars!"ptr",.str chars!"u64",
      .str chars!"ptr",.str chars!"u64",.str chars!"u64"] := by host_kernel_rfl
theorem source_output_buffer : input.heap.get 3126780 = some (.obj outputBuffer) := by host_kernel_rfl
theorem source_start_buffer : input.heap.get 3126752 = some (.obj startBuffer) := by host_kernel_rfl
theorem source_stop_buffer : input.heap.get 3126754 = some (.obj stopBuffer) := by host_kernel_rfl
theorem source_stride_buffer : input.heap.get 3126768 = some (.obj strideBuffer) := by host_kernel_rfl
theorem source_output_kind : outputBuffer.kind = .buf outputBytes := by host_kernel_rfl
theorem source_start_kind : startBuffer.kind = .buf startBytes := by host_kernel_rfl
theorem source_stop_kind : stopBuffer.kind = .buf stopBytes := by host_kernel_rfl
theorem source_stride_kind : strideBuffer.kind = .buf strideBytes := by host_kernel_rfl
theorem source_output_bytes : outputBytes = cellParts .u64 (.big (Int.ofNat 0)) 8 0 := by host_kernel_rfl
theorem source_start_bytes : startBytes = (Owned.Annotated.fixedI32 [0,1,0]).map Owned.Annotated.FixedByte.value := by host_kernel_rfl
theorem source_stop_bytes : stopBytes = (Owned.Annotated.fixedI32 [1,4,10240]).map Owned.Annotated.FixedByte.value := by host_kernel_rfl
theorem source_stride_bytes : strideBytes = (Owned.Annotated.fixedI32 [1,1,1]).map Owned.Annotated.FixedByte.value := by host_kernel_rfl
theorem source_counter : native.next = 29373 := by host_kernel_rfl
theorem source_node_counter : native.nnext = 22588 := by host_kernel_rfl
theorem source_array : native.arrs.get 29372 = some 22587 := by host_kernel_rfl
theorem source_input_node : native.nodes.get 22587 = some inputNode := by host_kernel_rfl
theorem source_input_shape : inputNode.shape = [.lit 1,.lit 4,.lit 10240] := by host_kernel_rfl
theorem source_input_dtype : inputNode.dtype = 12 := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.SliceCall
