import host.mlx.NativeVectorDataRetained

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.VectorCall
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated

/-- The actual source249 call consumes the buffer note established by the
source223 constructor. Its new vector, returned handle, retained inventories
and producer policy follow from current data and native ownership. -/
theorem retained_transport {notes : RetainedNotes}
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (roles : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : Host.Ts.St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary objects H N tail host)
      R live framed before after old old' input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live input s)
    (signatureFrame : ¬ framed 4411) (firstLive : H 25732) (secondLive : H 29363)
    (bound : s.ffi.mlx.next < 2^64) (roots : Nat → Prop) (policy : ProducerAnnotations roots H N roles objects)
    (fnRole thisRole countRole : Value) (countSchema : FixedIntegerRole countRole (Int.ofNat 2))
    (note : notes.runtime.control = callNote fnRole thisRole [.ptr (.js 3126688) 0,countRole])
    (selected : notes.buffers.owners 3126688 = some (handleArrayBytes [25732,29363])) :
    ∃ t, interpC (step Host.Load.ffi input).run C₀ = some (output,C₀) ∧
      interpC (step Host.Load.ffi s).run C = some (t,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C roles boundary (objectWrite objects 29371 (.vec [20208,22582]))
          (fun a => a = 29371 ∨ H a) N tail host) R live framed before after old old' output t ∧
      RetainedInventory (notes.withRuntime ⟨returnNote (.handle 29371),notes.runtime.stack,notes.runtime.cells⟩)
        ν₀ ν C₀ C R live output t ∧
      ProducerAnnotations roots (fun a => a = 29371 ∨ H a) N roles (objectWrite objects 29371 (.vec [20208,22582])) ∧
      ProducerSupport roots (fun a => a = 29371 ∨ H a) N output.ffi.mlx := by
  have callee := source_callee_kind
  rw [source_caps] at callee
  obtain ⟨sourceRun,targetRun,post,retained,newPolicy,producers⟩ := VectorDataHost.retained_from_source ν₀ ν C₀ C R
    roles boundary objects H N tail host live framed before after old old' input s h inventory
    4709 4411 3126688 calleeObject signatureObject chars!"u64" (.obj 4817) [25732,29363] [20208,22582]
    source_control source_callee callee source_signature source_signature_kind signatureFrame
    ⟨firstLive,secondLive,True.intro⟩ source_inputs (by decide +kernel) bound roots policy
    fnRole thisRole countRole countSchema note selected
  have counter : input.ffi.mlx.next = 29371 := source_counter
  rw [counter] at sourceRun post retained newPolicy producers
  simp only [List.length_cons,List.length_nil] at sourceRun post retained producers
  have endpoint : finishBig input (VectorDataHost.resultWorld input.ffi [20208,22582]) chars!"mlx_vector_array_new_data"
      [.jsPtr 3126688 0 (VectorBuffer.bytes [25732,29363]),.big (Int.ofNat 2)] (Int.ofNat 29371) = output := by
    have old := VectorHost.source_post
    simpa only [VectorHost.sourcePost,VectorHost.sourceNative,VectorHost.sourceArgs,
      VectorDataHost.resultWorld,native,source_bytes] using old
  rw [endpoint] at sourceRun post retained producers
  exact ⟨_,sourceRun,targetRun,post,retained,newPolicy,producers⟩

end Host.Load.Run.Full.Ordinary.VectorCall
