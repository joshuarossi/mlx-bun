import host.mlx.OrdinaryVectorStates
import host.mlx.NativeSymbol
import host.mlx.NativeVectorObjects
import host.ts.RenameRouteDriver

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro2 49 4709 as Ordinary.VectorCall.calleeObject
host_transport_object P.RestStream.micro0.micro2 49 3126688 as Ordinary.VectorCall.bufferObject
host_transport_object P.RestStream.micro0.micro2 49 4411 as Ordinary.VectorCall.signatureObject
end Host.Load.Run.Full

namespace Host.Load.Run.Full.Ordinary.VectorCall
open Host.Ts

noncomputable def input : St LSt := P.RestStream.micro0.micro2.s49
noncomputable def output : St LSt := P.RestStream.micro0.micro2.s50
noncomputable def native : Host.Mlx.Ffi.St := input.ffi.mlx
noncomputable def actualBytes : List Byte := match bufferObject.kind with
  | .buf bytes => bytes
  | _ => []
noncomputable def calleeCaps : List Val := match calleeObject.kind with
  | .fn (.native (.ffi .symbol) caps) => caps
  | _ => []

theorem source_control : input.ctl = .call (.obj 4709) (.obj 4817) [.ptr (.js 3126688) 0,.big (Int.ofNat 2)] := by host_kernel_rfl
theorem source_callee : input.heap.get 4709 = some (.obj calleeObject) := by host_kernel_rfl
theorem source_callee_kind : calleeObject.kind = .fn (.native (.ffi .symbol) calleeCaps) := by host_kernel_rfl
theorem source_symbol : calleeCaps.head? = some (.str chars!"mlx_vector_array_new_data") := by host_kernel_rfl
theorem source_buffer : input.heap.get 3126688 = some (.obj bufferObject) := by host_kernel_rfl
theorem source_buffer_kind : bufferObject.kind = .buf actualBytes := by host_kernel_rfl
theorem source_buffer_length : actualBytes.length = 16 := by host_kernel_rfl
theorem source_caps : calleeCaps = [.str chars!"mlx_vector_array_new_data",.obj 4411,.str chars!"u64"] := by host_kernel_rfl
theorem source_signature : input.heap.get 4411 = some (.obj signatureObject) := by host_kernel_rfl
theorem source_signature_kind : signatureObject.kind = .array [.str chars!"ptr",.str chars!"u64"] := by host_kernel_rfl
theorem source_bytes : actualBytes = Host.Mlx.Ffi.Annotated.VectorBuffer.bytes [25732,29363] := by host_kernel_rfl
theorem source_counter : native.next = 29371 := by host_kernel_rfl
theorem source_inputs : Host.Mlx.Ffi.nodesOf native [25732,29363] = some [20208,22582] := by host_kernel_rfl
theorem source_first_array : native.arrs.get 25732 = some 20208 := by host_kernel_rfl
theorem source_second_array : native.arrs.get 29363 = some 22582 := by host_kernel_rfl
theorem source_native_output : (native.newObj (.vec [20208,22582])).2 = output.ffi.mlx := by host_kernel_rfl

end Host.Load.Run.Full.Ordinary.VectorCall
