import host.load.RuntimeCompiledArgumentEntryClosures
import host.load.RuntimeCompiledArgumentEntryPlanFrom30
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

-- Sixty-four actual source steps from 2057, through the wrapper call at 2120.
-- The entry counter needs twelve cells of room for the calls seen so far.
host_retained_theorem retained_wrapper := fun (notes : RetainedNotes)
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
    (receiverRole : Annotated.Value)
    (receiverEntry : notes.runtime.cells.cells From12.Span12.Block24.sourceAddress = some receiverRole)
    (budget : s.next + 12 ≤ 2 ^ 64) => by
  have earlierBudget : s.next + 4 ≤ 2 ^ 64 := Nat.le_trans (Nat.le_add_right (s.next + 4) 8) budget
  have earlier := retained_closures notes ν₀ ν C₀ C R FR live framed before after old old' s inst state inventory
    role controlNote cellRole entry receiverRole receiverEntry earlierBudget
  have post := Classical.choose_spec earlier
  have previous := post.1
  have reached := post.2.1
  have retained := post.2.2.1
  have sourceInst := post.2.2.2
  host_retained_plan_chain_after P.F, From30 using reached, retained, sourceInst
    continuing_run previous initial_relation state
host_assert_retained_schema retained_wrapper, 64

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema retained_wrapper, 63

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema retained_wrapper, 65

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
