import host.ts.renameOrdinary.NativeCallCutStates
import host.mlx.NativeVectorDataHost
import host.ts.RenameRouteDriver

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro23 36 4709 as Ordinary.VectorInputCall.calleeObject
host_transport_object P.RestStream.micro0.micro23 36 4411 as Ordinary.VectorInputCall.signatureObject
host_transport_object P.RestStream.micro0.micro23 36 3126910 as Ordinary.VectorInputCall.bufferObject
end Host.Load.Run.Full

namespace Host.Load.Run.Full.Ordinary.VectorInputCall
open Host.Ts
noncomputable def input : St LSt := P.RestStream.micro0.micro23.s36
noncomputable def output : St LSt := P.RestStream.micro0.micro23.s37
noncomputable def caps : List Val := match calleeObject.kind with
  | .fn (.native (.ffi .symbol) caps) => caps
  | _ => []
noncomputable def returns : Name := match Host.Ts.arg caps 2 with | .str name => name | _ => []
noncomputable def actualBytes : List Byte := match bufferObject.kind with | .buf bs => bs | _ => []
theorem source_control : input.ctl = .call (.obj 4709) (.obj 4817) [.ptr (.js 3126910) 0,.big (Int.ofNat 3)] := by host_kernel_rfl
theorem source_callee : input.heap.get 4709 = some (.obj calleeObject) := by host_kernel_rfl
theorem source_kind : calleeObject.kind = .fn (.native (.ffi .symbol) caps) := by host_kernel_rfl
theorem source_caps : caps = [.str chars!"mlx_vector_array_new_data",.obj 4411,.str returns] := by host_kernel_rfl
theorem source_signature : input.heap.get 4411 = some (.obj signatureObject) := by host_kernel_rfl
theorem source_signature_kind : signatureObject.kind = .array [.str chars!"ptr",.str chars!"u64"] := by host_kernel_rfl
theorem source_buffer : input.heap.get 3126910 = some (.obj bufferObject) := by host_kernel_rfl
theorem source_buffer_kind : bufferObject.kind = .buf actualBytes := by host_kernel_rfl
def handles : List Nat := [29375,40,41]
def nodes : List Nat := [22590,10,11]
theorem source_bytes : actualBytes = Host.Mlx.Ffi.Annotated.VectorBuffer.bytes handles := by host_kernel_rfl
theorem source_nodes : Host.Mlx.Ffi.nodesOf input.ffi.mlx handles = some nodes := by host_kernel_rfl
theorem source_counter : input.ffi.mlx.next = 29376 := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.VectorInputCall
