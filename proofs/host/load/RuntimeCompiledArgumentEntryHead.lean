import host.load.RuntimeCompiledArgumentEntryPlan
import host.load.RuntimeCompiledArgumentEntryPlanHead
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

-- Twelve actual source steps from 2057. The chain return at region index 3
-- stays inside the local selector; the other steps use the checked planner.
host_retained_theorem retained_head := fun (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Head.Span0.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s0 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Region.s0 s)
    (role : Annotated.Value)
    (controlNote : notes.runtime.control = returnNote role)
    (cellRole : Annotated.Value)
    (entry : notes.runtime.cells.cells Head.Span4.Block7.sourceAddress = some cellRole)
    (targetBound : s.next + 0 ≤ 2 ^ 64) => by
  host_retained_plan_chain P.F, Head using state, inventory, inst
host_assert_retained_schema retained_head, 12

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema retained_head, 13

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
