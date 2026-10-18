import host.mlx.OrdinaryMetalStates
import host.mlx.NativeKernelRoles
import host.mlx.NativeSymbol
import host.ts.RenameRouteDriver

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro57 60 4798 as Ordinary.MetalCall.calleeObject
host_transport_object P.RestStream.micro0.micro57 60 4589 as Ordinary.MetalCall.signatureObject
host_transport_object P.RestStream.micro0.micro57 60 3127256 as Ordinary.MetalCall.bufferObject
end Host.Load.Run.Full

namespace Host.Load.Run.Full.Ordinary.MetalCall
open Host.Ts
noncomputable def input : St LSt := P.RestStream.micro0.micro57.s60
noncomputable def output : St LSt := P.RestStream.micro0.micro57.s61
noncomputable def native : Host.Mlx.Ffi.St := input.ffi.mlx
noncomputable def caps : List Val := match calleeObject.kind with
  | .fn (.native (.ffi .symbol) caps) => caps
  | _ => []
noncomputable def config : Host.Mlx.Ffi.Cfg := match native.obj? 29386 with
  | some (.cfg c) => c
  | _ => .empty
noncomputable def inputs : List Nat := match native.obj? 29387 with
  | some (.vec xs) => xs
  | _ => []
noncomputable def kernelName : Name := match native.obj? 18215 with
  | some (.kernel name _ _ _ _) => name
  | _ => []
noncomputable def kernelSource : Name := match native.obj? 18215 with
  | some (.kernel _ source _ _ _) => source
  | _ => []
noncomputable def kernelHeader : Name := match native.obj? 18215 with
  | some (.kernel _ _ header _ _) => header
  | _ => []
noncomputable def returns : Name := match Host.Ts.arg caps 2 with | .str name => name | _ => []
theorem source_control : input.ctl = .call (.obj 4798) (.obj 4817)
    [.ptr (.js 3127256) 0,.big (Int.ofNat 18215),.big (Int.ofNat 29387),.big (Int.ofNat 29386),.big (Int.ofNat 2)] := by host_kernel_rfl
theorem source_callee : input.heap.get 4798 = some (.obj calleeObject) := by host_kernel_rfl
theorem source_kind : calleeObject.kind = .fn (.native (.ffi .symbol) caps) := by host_kernel_rfl
theorem source_caps : caps = [.str chars!"mlx_fast_metal_kernel_apply",.obj 4589,.str returns] := by host_kernel_rfl
theorem source_signature : input.heap.get 4589 = some (.obj signatureObject) := by host_kernel_rfl
theorem source_signature_kind : signatureObject.kind = .array
    [.str chars!"ptr",.str chars!"u64",.str chars!"u64",.str chars!"u64",.str chars!"u64"] := by host_kernel_rfl
theorem source_buffer : input.heap.get 3127256 = some (.obj bufferObject) := by host_kernel_rfl
theorem source_buffer_kind : bufferObject.kind = .buf (cellParts .u64 (.big (Int.ofNat 29388)) 8 0) := by host_kernel_rfl
theorem source_kernel : native.obj? 18215 = some (.kernel kernelName kernelSource kernelHeader 7 2) := by host_kernel_rfl
theorem source_config : native.obj? 29386 = some (.cfg config) := by host_kernel_rfl
theorem source_inputs : native.obj? 29387 = some (.vec inputs) := by host_kernel_rfl
theorem source_output : native.obj? 29388 = some (.vec []) := by host_kernel_rfl
theorem source_node_counter : native.nnext = 22603 := by host_kernel_rfl
theorem source_output_count : config.outs.length = 2 := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.MetalCall
