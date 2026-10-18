import host.mlx.OrdinaryConcatStates
import host.mlx.NativeSymbol
import host.ts.RenameRouteDriver

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro3 36 4708 as Ordinary.ConcatCall.calleeObject
host_transport_object P.RestStream.micro0.micro3 36 3126700 as Ordinary.ConcatCall.bufferObject
host_transport_object P.RestStream.micro0.micro3 36 4409 as Ordinary.ConcatCall.signatureObject
end Host.Load.Run.Full

namespace Host.Load.Run.Full.Ordinary.ConcatCall
open Host.Ts
noncomputable def input : St LSt := P.RestStream.micro0.micro3.s36
noncomputable def output : St LSt := P.RestStream.micro0.micro3.s37
noncomputable def native : Host.Mlx.Ffi.St := input.ffi.mlx
noncomputable def actualBytes : List Byte := match bufferObject.kind with
  | .buf bs => bs
  | _ => []
noncomputable def calleeCaps : List Val := match calleeObject.kind with
  | .fn (.native (.ffi .symbol) caps) => caps
  | _ => []
noncomputable def firstNode : Host.Mlx.Ffi.Node := (native.nodes.get 20208).getD ⟨.zeros,[],[],0⟩
noncomputable def secondNode : Host.Mlx.Ffi.Node := (native.nodes.get 22582).getD ⟨.zeros,[],[],0⟩

theorem source_control : input.ctl = .call (.obj 4708) (.obj 4817)
    [.ptr (.js 3126700) 0,.big (Int.ofNat 29371),.num one,.big (Int.ofNat 2)] := by host_kernel_rfl
theorem source_callee : input.heap.get 4708 = some (.obj calleeObject) := by host_kernel_rfl
theorem source_callee_kind : calleeObject.kind = .fn (.native (.ffi .symbol) calleeCaps) := by host_kernel_rfl
theorem source_buffer : input.heap.get 3126700 = some (.obj bufferObject) := by host_kernel_rfl
theorem source_buffer_kind : bufferObject.kind = .buf actualBytes := by host_kernel_rfl
theorem source_caps : calleeCaps = [.str chars!"mlx_concatenate_axis",.obj 4409,.str chars!"i32"] := by host_kernel_rfl
theorem source_signature : input.heap.get 4409 = some (.obj signatureObject) := by host_kernel_rfl
theorem source_signature_kind : signatureObject.kind = .array [.str chars!"ptr",.str chars!"u64",.str chars!"i32",.str chars!"u64"] := by host_kernel_rfl
theorem source_bytes : actualBytes = cellParts .u64 (.big (Int.ofNat 0)) 8 0 := by host_kernel_rfl
theorem source_counter : native.next = 29372 := by host_kernel_rfl
theorem source_node_counter : native.nnext = 22587 := by host_kernel_rfl
theorem source_vector : native.obj? 29371 = some (.vec [20208,22582]) := by host_kernel_rfl
theorem source_first : native.nodes.get 20208 = some firstNode := by host_kernel_rfl
theorem source_second : native.nodes.get 22582 = some secondNode := by host_kernel_rfl
theorem source_first_shape : firstNode.shape = [.lit 1,.lit 3,.lit 10240] := by host_kernel_rfl
theorem source_second_shape : secondNode.shape = [.lit 1,.lit 1,.lit 10240] := by host_kernel_rfl
theorem source_first_dtype : firstNode.dtype = 12 := by host_kernel_rfl
theorem source_second_dtype : secondNode.dtype = 12 := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.ConcatCall
