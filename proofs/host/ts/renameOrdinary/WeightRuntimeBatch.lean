import host.ts.renameOrdinary.WeightByteCountSteps
import host.ts.RenameRuntimeBatch
import host.ts.RenameRouteComposition
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_runtime_begin
host_runtime_step P.F, P.RestStream.micro0.micro5.s46 using P.RestStream.micro0.micro5.S46
  to P.RestStream.micro0.micro5.s47 using P.RestStream.micro0.micro5.S47 as BatchDescent
host_runtime_step P.F, P.RestStream.micro0.micro5.s47 using P.RestStream.micro0.micro5.S47
  to P.RestStream.micro0.micro5.s48 using P.RestStream.micro0.micro5.S48 as BatchRank
host_runtime_step P.F, P.RestStream.micro0.micro5.s48 using P.RestStream.micro0.micro5.S48
  to P.RestStream.micro0.micro5.s49 using P.RestStream.micro0.micro5.S49 as BatchLeft
host_runtime_step P.F, P.RestStream.micro0.micro5.s49 using P.RestStream.micro0.micro5.S49
  to P.RestStream.micro0.micro5.s50 using P.RestStream.micro0.micro5.S50 as BatchFour
host_runtime_step P.F, P.RestStream.micro0.micro5.s50 using P.RestStream.micro0.micro5.S50
  to P.RestStream.micro0.micro5.s51 using P.RestStream.micro0.micro5.S51 as BatchMultiply

theorem batch_four_role : BatchFour.parsed.role = .literal (.lit (F64.ofNat 4)) := by host_kernel_rfl

theorem batch_composition (notes : RuntimeNotes) (meaning : SymE) (ν₀ ν : Nat → F64)
    (C₀ C : CSrv) (R : Ren) (FR : Ren → P.F.S → P.F.S → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ (numberServer P.RestStream.micro0.micro5.S46) C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
      P.RestStream.micro0.micro5.s46 s)
    (inventory : RuntimeInventory notes ν₀ ν C₀ C R live P.RestStream.micro0.micro5.s46 s)
    (entry : notes.cells.cells BatchRank.address = some (.literal meaning)) :
    ∃ result, runC P.F 5 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old'
        P.RestStream.micro0.micro5.s51 result ∧
      RuntimeInventory (notes.binaryResult (.literal (.bin .mul meaning (.lit (F64.ofNat 4)))) notes.stack)
        ν₀ ν C₀ C R live P.RestStream.micro0.micro5.s51 result ∧
      Inst ν₀ (numberServer P.RestStream.micro0.micro5.S51) C₀ := by
  obtain ⟨s47,_,run46,h47,inv47,inst47⟩ := BatchDescent.runtime_transport notes ν₀ ν C₀ C R FR
    live framed before after old old' s inst h inventory
  obtain ⟨value48,_,run47,h48,inv48,inst48⟩ := BatchRank.runtime_transport _ ν₀ ν C₀ C R FR
    live framed before after old old' s47 inst47 h47 inv47 (.literal meaning) entry
  obtain ⟨s49,_,run48,h49,inv49,inst49⟩ := BatchLeft.runtime_transport _ ν₀ ν C₀ C R FR
    live framed before after old old' (s47.ret value48) inst48 h48 inv48 (.literal meaning)
    (binaryLeftNote BatchDescent.sourceOp BatchDescent.sourceRight BatchDescent.sourceEnv) notes.stack rfl rfl
  obtain ⟨_,run49,h50,inv50,inst50⟩ := BatchFour.runtime_transport _ ν₀ ν C₀ C R FR
    live framed before after old old' s49 inst49 h49 inv49
  obtain ⟨result,_,run50,inst51,h51,inv51⟩ := BatchMultiply.runtime_literal_transport _ ν₀ ν C₀ C R FR
    live framed before after old old' (s49.ret BatchFour.sourceValue) inst50 h50 inv50
    meaning (.lit (F64.ofNat 4)) notes.stack (by change returnNote BatchFour.parsed.role = _; rw [batch_four_role]) rfl
  refine ⟨result,?_,h51,?_,inst51⟩
  · apply runC_cons P.F 4 s s47 result C C C (h.control.isHalt_eq.trans (by host_kernel_rfl)) run46
    apply runC_cons P.F 3 s47 (s47.ret value48) result C C C (h47.control.isHalt_eq.trans (by host_kernel_rfl)) run47
    apply runC_cons P.F 2 (s47.ret value48) s49 result C C C (h48.control.isHalt_eq.trans (by host_kernel_rfl)) run48
    apply runC_cons P.F 1 s49 (s49.ret BatchFour.sourceValue) result C C C (h49.control.isHalt_eq.trans (by host_kernel_rfl)) run49
    apply runC_cons P.F 0 (s49.ret BatchFour.sourceValue) result result C C C (h50.control.isHalt_eq.trans (by host_kernel_rfl)) run50
    rfl
  · exact inv51

host_runtime_export batch_composition as checked_expression_batch
end Host.Load.Run.Full.Ordinary.VectorToConcat.WeightShape
