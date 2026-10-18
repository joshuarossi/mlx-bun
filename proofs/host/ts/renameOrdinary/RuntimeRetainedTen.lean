import host.ts.renameOrdinary.RuntimeRetainedPrefix
import host.ts.RenameRouteComposition
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RetainedPrefix
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

theorem zero_role : Source2.parsed.role = .literal (.lit (F64.ofNat 0)) := by host_kernel_rfl
theorem four_role : Source7.parsed.role = .literal (.lit (F64.ofNat 4)) := by host_kernel_rfl

/-- The first ten actual source steps compose with one retained entry. The
pointer and rank roles are selected from that entry, while the offset and byte
count roles are derived by the original literal/arithmetic/argument steps. -/
theorem first_ten (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ (numberServer P.RestStream.micro0.micro0.S0) C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      P.RestStream.micro0.micro0.s0 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live P.RestStream.micro0.micro0.s0 s)
    (fnRole thisRole pointerRole : Annotated.Value) (tailNotes : List Annotated.Tree)
    (pointerEntry : notes.runtime.cells.cells Source0.address = some pointerRole)
    (rankEntry : notes.runtime.cells.cells Source5.address = some (.literal (.lit (F64.ofNat 3))))
    (stackNotes : notes.runtime.stack = argumentFrameNote false Source1.sourceKind fnRole thisRole []
      Source1.sourceRest Source1.sourceEnv::tailNotes) :
    ∃ result, runC P.F 10 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        P.RestStream.micro0.micro0.s10 result ∧
      RetainedInventory (notes.withRuntime {notes.runtime with control := (callNote fnRole thisRole
        [pointerRole,.literal (.lit (F64.ofNat 0)),
          .literal (.bin .mul (.lit (F64.ofNat 3)) (.lit (F64.ofNat 4)))]),stack := tailNotes})
        ν₀ ν C₀ C R live P.RestStream.micro0.micro0.s10 result ∧
      Inst ν₀ (numberServer P.RestStream.micro0.micro0.S10) C₀ := by
  obtain ⟨ptr,_,r0,h1,i1,q1⟩ := Source0.retained_transport notes ν₀ ν C₀ C R FR live framed before after old old'
    s inst h inventory pointerRole pointerEntry
  let s1 := s.ret ptr
  obtain ⟨s2,_,r1,h2,i2,q2⟩ := Source1.retained_transport _ ν₀ ν C₀ C R FR live framed before after old old'
    s1 q1 h1 i1 pointerRole fnRole thisRole [] tailNotes rfl stackNotes
  obtain ⟨_,r2,h3,i3,q3⟩ := Source2.retained_transport _ ν₀ ν C₀ C R FR live framed before after old old' s2 q2 h2 i2
  let s3 := s2.ret Source2.sourceValue
  obtain ⟨s4,_,r3,h4,i4,q4⟩ := Source3.retained_transport _ ν₀ ν C₀ C R FR live framed before after old old'
    s3 q3 h3 i3 (.literal (.lit (F64.ofNat 0))) fnRole thisRole [pointerRole] tailNotes
      (by change returnNote Source2.parsed.role = _; rw [zero_role]) rfl
  obtain ⟨s5,_,r4,h5,i5,q5⟩ := Source4.retained_transport _ ν₀ ν C₀ C R FR live framed before after old old' s4 q4 h4 i4
  obtain ⟨rank,_,r5,h6,i6,q6⟩ := Source5.retained_transport _ ν₀ ν C₀ C R FR live framed before after old old'
    s5 q5 h5 i5 (.literal (.lit (F64.ofNat 3))) rankEntry
  let argTail := argumentFrameNote false Source3.sourceKind fnRole thisRole
    [.literal (.lit (F64.ofNat 0)),pointerRole] [] Source3.sourceEnv::tailNotes
  obtain ⟨s7,_,r6,h7,i7,q7⟩ := Source6.retained_transport _ ν₀ ν C₀ C R FR live framed before after old old'
    (s5.ret rank) q6 h6 i6 (.literal (.lit (F64.ofNat 3)))
    (binaryLeftNote Source4.sourceOp Source4.sourceRight Source4.sourceEnv) argTail rfl rfl
  obtain ⟨_,r7,h8,i8,q8⟩ := Source7.retained_transport _ ν₀ ν C₀ C R FR live framed before after old old' s7 q7 h7 i7
  obtain ⟨s9,_,r8,q9,h9,i9⟩ := Source8.retained_transport _ ν₀ ν C₀ C R FR live framed before after old old'
    (s7.ret Source7.sourceValue) q8 h8 i8 (.lit (F64.ofNat 3)) (.lit (F64.ofNat 4)) argTail
      (by change returnNote Source7.parsed.role = _; rw [four_role]) rfl
  obtain ⟨result,_,r9,h10,i10,q10⟩ := Source9.retained_transport _ ν₀ ν C₀ C R FR live framed before after old old'
    s9 q9 h9 i9 (.literal (.bin .mul (.lit (F64.ofNat 3)) (.lit (F64.ofNat 4)))) fnRole thisRole
    [.literal (.lit (F64.ofNat 0)),pointerRole] tailNotes rfl rfl
  refine ⟨result,?_,h10,i10,q10⟩
  apply runC_cons P.F 9 s s1 result C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) r0
  apply runC_cons P.F 8 s1 s2 result C C C (h1.control.isHalt_eq.trans (by host_kernel_rfl)) r1
  apply runC_cons P.F 7 s2 s3 result C C C (h2.control.isHalt_eq.trans (by host_kernel_rfl)) r2
  apply runC_cons P.F 6 s3 s4 result C C C (h3.control.isHalt_eq.trans (by host_kernel_rfl)) r3
  apply runC_cons P.F 5 s4 s5 result C C C (h4.control.isHalt_eq.trans (by host_kernel_rfl)) r4
  apply runC_cons P.F 4 s5 (s5.ret rank) result C C C (h5.control.isHalt_eq.trans (by host_kernel_rfl)) r5
  apply runC_cons P.F 3 (s5.ret rank) s7 result C C C (h6.control.isHalt_eq.trans (by host_kernel_rfl)) r6
  apply runC_cons P.F 2 s7 (s7.ret Source7.sourceValue) result C C C (h7.control.isHalt_eq.trans (by host_kernel_rfl)) r7
  apply runC_cons P.F 1 (s7.ret Source7.sourceValue) s9 result C C C (h8.control.isHalt_eq.trans (by host_kernel_rfl)) r8
  apply runC_cons P.F 0 s9 result result C C C (h9.control.isHalt_eq.trans (by host_kernel_rfl)) r9
  rfl

end Host.Load.Run.Full.Ordinary.RetainedPrefix
