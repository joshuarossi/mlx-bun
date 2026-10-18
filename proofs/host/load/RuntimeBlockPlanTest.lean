import host.load.RuntimeBlockPlan
import host.ts.renameOrdinary.MapBodyStates
import host.mlx.OrdinaryVectorStates
import host.mlx.OrdinaryConcatStates
import host.mlx.OrdinaryFreeStates
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.RuntimeBlockPlanTest
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

host_source_plan P.F, P.RestStream.micro0 from 119 plan_steps 26 as First
host_source_plan P.F, P.RestStream.micro0 from 176 plan_steps 26 as Second
host_source_plan P.F, P.RestStream.micro0 from 119 plan_steps 25 as Clipped
host_source_plan P.F, P.RestStream.micro0 from 126 plan_steps 17 as Getter
host_source_plan P.F, P.RestStream.micro0 from 125 plan_steps 18 as LookupGetter
host_source_plan P.F, P.RestStream.micro0 from 356 plan_steps 15 as OutArray
host_source_plan P.F, P.RestStream.micro0 from 372 plan_steps 37 as Constructor

theorem first_plan : First.starts = [119] ∧ First.spans = [26] ∧ First.blockCount = 1 := by decide +kernel
theorem second_plan : Second.starts = [176] ∧ Second.spans = [26] ∧ Second.blockCount = 1 := by decide +kernel
theorem getter_plan : Getter.starts = [126] ∧ Getter.spans = [17] ∧ Getter.blockCount = 1 := by decide +kernel
theorem lookup_getter_plan : LookupGetter.starts = [125,126] ∧ LookupGetter.spans = [1,17] := by decide +kernel
theorem clipped_plan : Clipped.starts.head? = some 119 ∧ Clipped.spans.head? = some 1 ∧ Clipped.spans.sum = 25 := by decide +kernel
theorem out_array_plan : OutArray.starts = [356] ∧ OutArray.spans = [15] ∧ OutArray.blockCount = 1 := by decide +kernel
theorem constructor_plan : Constructor.starts = [372] ∧ Constructor.spans = [37] ∧ Constructor.blockCount = 1 := by decide +kernel

host_retained_theorem planned_callback := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ First.Block119.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' First.Block119.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live First.Block119.input s)
    (fnRole thisRole role : Annotated.Value) (extraRoles : List Annotated.Value)
    (controlNote : notes.runtime.control = callNote fnRole thisRole (.obj First.Block119.sourceOwner::extraRoles))
    (fieldNote : notes.privates.owners First.Block119.sourceOwner = some ⟨First.Block119.sourceBrand,First.Block119.sourceHandleName,role⟩)
    (budget : s.next+3 ≤ 2^64) => by
  host_retained_plan_chain P.F, First using h, inventory, inst
host_assert_retained_schema planned_callback, 26

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema planned_callback, 25

/-- error: host_source_plan: expected between 1 and 1000 source transitions -/
#guard_msgs in
host_source_plan P.F, P.RestStream.micro0 from 119 plan_steps 0 as Empty

/-- error: host_source_plan: expected between 1 and 1000 source transitions -/
#guard_msgs in
host_source_plan P.F, P.RestStream.micro0 from 119 plan_steps 1001 as Unbounded

end Host.Load.Run.Full.Ordinary.RuntimeBlockPlanTest
