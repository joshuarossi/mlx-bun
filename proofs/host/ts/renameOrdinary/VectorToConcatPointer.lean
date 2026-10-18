import host.ts.RenameParametricPointer
import host.ts.RenameRouteDriver
import host.mlx.OrdinaryConcatStates
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full
host_transport_object P.RestStream.micro0.micro3 9 2638 as Ordinary.VectorToConcat.Pointer309.functionObject
host_transport_object P.RestStream.micro0.micro3 9 3126701 as Ordinary.VectorToConcat.Pointer309.viewObject
host_transport_object P.RestStream.micro0.micro3 9 3126700 as Ordinary.VectorToConcat.Pointer309.bufferObject
end Host.Load.Run.Full
namespace Host.Load.Run.Full.Ordinary.VectorToConcat.Pointer309
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric
noncomputable def input : St LSt := P.RestStream.micro0.micro3.s9
noncomputable def output : St LSt := P.RestStream.micro0.micro3.s10
noncomputable def sourceThis : Val := match input.ctl with | .call _ v _ => v | _ => .undef
theorem source_control : input.ctl = .call (.obj 2638) sourceThis [.obj 3126701] := by host_kernel_rfl
theorem source_function : input.heap.get 2638 = some (.obj functionObject) := by host_kernel_rfl
theorem source_kind : functionObject.kind = .fn (.native (.ffi .ptr) []) := by host_kernel_rfl
theorem source_view : input.heap.get 3126701 = some (.obj viewObject) := by host_kernel_rfl
theorem source_view_kind : viewObject.kind = .typed .u64 3126700 0 1 := by host_kernel_rfl
theorem source_buffer : input.heap.get 3126700 = some (.obj bufferObject) := by host_kernel_rfl
theorem source_buffer_kind : bufferObject.kind = .buf (cellParts .u64 (.big 0) 8 0) := by host_kernel_rfl
theorem source_post : input.ret (.ptr (.js 3126700) 0) = output := by host_kernel_rfl

/-- At the actual ptr(slot) call, source-only heap facts determine the
mapped JS pointer. The output-slot heap and every other heap entry survive. -/
theorem transport (NR : NumV → NumV → Prop) (FR : Ren → LSt → LSt → Prop)
    (R : Ren) (C₀ C : CSrv) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR NR FR R live framed before after old old' input s) :
    ∃ result, interpC (step P.F s).run C = some (result,C) ∧
      StateR NR FR R live framed before after old old' output result ∧
      result.ctl = .ret (.ptr (.js (R.a 3126700)) 0) ∧ result.heap = s.heap ∧ result.next = s.next := by
  obtain ⟨_,hr,hs⟩ := step_ptr_typed_buffer_from_source P.F NR FR R C₀ C live framed before after old old' input s h
    2638 3126701 3126700 0 1 functionObject viewObject bufferObject .u64 [] sourceThis
    (cellParts .u64 (.big 0) 8 0) source_control source_function source_kind source_view source_view_kind
    source_buffer source_buffer_kind (by decide)
  exact ⟨_,hr,source_post ▸ hs,rfl,rfl,rfl⟩
end Host.Load.Run.Full.Ordinary.VectorToConcat.Pointer309
