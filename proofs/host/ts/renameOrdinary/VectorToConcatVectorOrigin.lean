import host.ts.renameOrdinary.VectorToConcatVectorPath
import host.ts.RenameIdentifierArguments
import host.mlx.OrdinaryVectorHost
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Mlx.Ffi.Annotated

/-- The real native vector constructor creates the owned handle, and its
returned value flows through the actual 45-step caller prefix into vec.
The final handle annotation is a conclusion of the source execution. -/
theorem create_and_bind_vector (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (nodes : Nat → GraphNode) (boundary : Nat → Prop) (objects : Nat → Object)
    (H N : Nat → Prop) (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St LSt)
    (h : StateR (NumberRoles ν₀ ν C₀ C) (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary objects H N tail host)
      R live framed before after old old' VectorCall.input s)
    (countRole : (Annotated.Value.ordinaryBig (Int.ofNat 2)).Holds ν C R (callArgument s.ctl 1))
    (bufferRole : (VectorBuffer.role [25732,29363]).Holds ν C R (objectKindAt s (R.a 3126688)))
    (signatureFrame : ¬ framed 4411) (firstLive : H 25732) (secondLive : H 29363)
    (nativeBound : s.ffi.mlx.next < 2^64)
    (functionProtoLive : live aFunctionProto) (functionProtoFixed : R.a aFunctionProto = aFunctionProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (heapBound : s.next+32 ≤ 2^64) :
    ∃ result, runC P.F 46 s C = some (result,C) ∧
      StateR (NumberRoles ν₀ ν C₀ C)
        (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary (objectWrite objects 29371 (.vec [20208,22582]))
          (fun a => a = 29371 ∨ H a) N tail host)
        R (outBodyLive live) framed before after old old' ArrayCall.input result ∧
      (Annotated.Value.handle 29371).Holds ν C R (cellValueAt result (R.a VectorBinding251.sourceAddress)) := by
  obtain ⟨s250,_,hr249,h250,hc250⟩ := VectorHost.transport ν₀ ν C₀ C R nodes boundary objects H N tail host
    live framed before after old old' s h countRole bufferRole signatureFrame firstLive secondLive nativeBound
  have next250 : s250.next = s.next := by
    have sourceNext : VectorCall.output.next = VectorCall.input.next := by host_kernel_rfl
    have h₀ := h.heap.fresh 0
    have h₁ := h250.heap.fresh 0
    simp only [Nat.add_zero,sourceNext] at h₀ h₁
    exact h₁.symm.trans h₀
  have bound250 : s250.next+32 ≤ 2^64 := by rw [next250]; exact heapBound
  obtain ⟨result,hr250,h295,stored,_⟩ := vector_to_null_initializer_fields ν₀ ν C₀ C
    (VectorHost.NativeRelation ν₀ ν C₀ C nodes boundary (objectWrite objects 29371 (.vec [20208,22582]))
      (fun a => a = 29371 ∨ H a) N tail host)
    R live framed before after old old' s250 h250 functionProtoLive functionProtoFixed globalLive globalFixed bound250
  have cell := stored _ hc250
  have role : (Annotated.Value.handle 29371).Holds ν C R (cellValueAt result (R.a VectorBinding251.sourceAddress)) := by
    simp only [cellValueAt,cell]
    exact .handle _
  refine ⟨result,?_,h295,role⟩
  apply runC_cons P.F 45 s s250 result C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) hr249
  exact hr250
end Host.Load.Run.Full.Ordinary.VectorToConcat
