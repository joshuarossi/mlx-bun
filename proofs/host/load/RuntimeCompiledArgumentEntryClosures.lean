import host.load.RuntimeCompiledArgumentEntryHead
import host.load.RuntimeCompiledArgumentEntryPlanFrom12
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

-- Thirty actual source steps from 2057, through the closure calls at 2076 and 2086.
-- Closure room is the entry counter plus four; both calls have one parameter.
host_retained_theorem retained_closures := fun (notes : RetainedNotes)
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
    (budget : s.next + 4 ≤ 2 ^ 64) => by
  have targetBound : s.next + 0 ≤ 2 ^ 64 := Nat.le_trans (Nat.le_add_right _ 4) budget
  have earlier := retained_head notes ν₀ ν C₀ C R FR live framed before after old old' s inst state inventory
    role controlNote cellRole entry targetBound
  have post := Classical.choose_spec earlier
  have previous := post.1
  have reached := post.2.1
  have retained := post.2.2.1
  have sourceInst := post.2.2.2
  host_retained_plan_chain_after P.F, From12 using reached, retained, sourceInst
    continuing_run previous initial_relation state
host_assert_retained_schema retained_closures, 30

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema retained_closures, 31

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
