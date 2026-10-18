import host.mlx.OrdinaryFreeStates
import host.mlx.NativeSymbol
import host.ts.RenameRouteDriver

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro4 21 4710 as Ordinary.FreeCall.calleeObject
host_transport_object P.RestStream.micro0.micro4 84 4635 as Ordinary.NdimCall.calleeObject
host_transport_object P.RestStream.micro0.micro5 29 4636 as Ordinary.ShapeCall.calleeObject
host_transport_object P.RestStream.micro0.micro4 21 4413 as Ordinary.FreeCall.signatureObject
host_transport_object P.RestStream.micro0.micro4 84 4263 as Ordinary.NdimCall.signatureObject
host_transport_object P.RestStream.micro0.micro5 29 4265 as Ordinary.ShapeCall.signatureObject
end Host.Load.Run.Full

namespace Host.Load.Run.Full.Ordinary.FreeCall
open Host.Ts
noncomputable def input : St LSt := P.RestStream.micro0.micro4.s21
noncomputable def output : St LSt := P.RestStream.micro0.micro4.s22
noncomputable def caps : List Val := match calleeObject.kind with
  | .fn (.native (.ffi .symbol) caps) => caps
  | _ => []
theorem source_control : input.ctl = .call (.obj 4710) (.obj 4817) [.big (Int.ofNat 29371)] := by host_kernel_rfl
theorem source_callee : input.heap.get 4710 = some (.obj calleeObject) := by host_kernel_rfl
theorem source_kind : calleeObject.kind = .fn (.native (.ffi .symbol) caps) := by host_kernel_rfl

noncomputable def returns : Name := match Host.Ts.arg caps 2 with | .str name => name | _ => []
theorem source_caps : caps = [.str chars!"mlx_vector_array_free",.obj 4413,.str returns] := by host_kernel_rfl
theorem source_signature : input.heap.get 4413 = some (.obj signatureObject) := by host_kernel_rfl
theorem source_signature_kind : signatureObject.kind = .array [.str chars!"u64"] := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.FreeCall

namespace Host.Load.Run.Full.Ordinary.NdimCall
open Host.Ts
noncomputable def input : St LSt := P.RestStream.micro0.micro4.s84
noncomputable def output : St LSt := P.RestStream.micro0.micro4.s85
noncomputable def caps : List Val := match calleeObject.kind with
  | .fn (.native (.ffi .symbol) caps) => caps
  | _ => []
noncomputable def node : Host.Mlx.Ffi.Node := (input.ffi.mlx.node? 1365).getD ⟨.zeros,[],[],0⟩
theorem source_control : input.ctl = .call (.obj 4635) (.obj 4817) [.big (Int.ofNat 1365)] := by host_kernel_rfl
theorem source_callee : input.heap.get 4635 = some (.obj calleeObject) := by host_kernel_rfl
theorem source_kind : calleeObject.kind = .fn (.native (.ffi .symbol) caps) := by host_kernel_rfl
theorem source_node : input.ffi.mlx.node? 1365 = some node := by host_kernel_rfl

noncomputable def returns : Name := match Host.Ts.arg caps 2 with | .str name => name | _ => []
theorem source_caps : caps = [.str chars!"mlx_array_ndim",.obj 4263,.str returns] := by host_kernel_rfl
theorem source_signature : input.heap.get 4263 = some (.obj signatureObject) := by host_kernel_rfl
theorem source_signature_kind : signatureObject.kind = .array [.str chars!"u64"] := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.NdimCall

namespace Host.Load.Run.Full.Ordinary.ShapeCall
open Host.Ts
noncomputable def input : St LSt := P.RestStream.micro0.micro5.s29
noncomputable def output : St LSt := P.RestStream.micro0.micro5.s30
noncomputable def caps : List Val := match calleeObject.kind with
  | .fn (.native (.ffi .symbol) caps) => caps
  | _ => []
noncomputable def node : Host.Mlx.Ffi.Node := (input.ffi.mlx.node? 1365).getD ⟨.zeros,[],[],0⟩
theorem source_control : input.ctl = .call (.obj 4636) (.obj 4817) [.big (Int.ofNat 1365)] := by host_kernel_rfl
theorem source_callee : input.heap.get 4636 = some (.obj calleeObject) := by host_kernel_rfl
theorem source_kind : calleeObject.kind = .fn (.native (.ffi .symbol) caps) := by host_kernel_rfl
theorem source_node : input.ffi.mlx.node? 1365 = some node := by host_kernel_rfl

noncomputable def returns : Name := match Host.Ts.arg caps 2 with | .str name => name | _ => []
theorem source_caps : caps = [.str chars!"mlx_array_shape",.obj 4265,.str returns] := by host_kernel_rfl
theorem source_signature : input.heap.get 4265 = some (.obj signatureObject) := by host_kernel_rfl
theorem source_signature_kind : signatureObject.kind = .array [.str chars!"u64"] := by host_kernel_rfl
end Host.Load.Run.Full.Ordinary.ShapeCall
