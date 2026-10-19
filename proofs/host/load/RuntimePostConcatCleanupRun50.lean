import host.load.RuntimePostConcatCleanupRun46
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.PostConcatCleanup
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

noncomputable def retained_run50Rules.rules :=
  (AfterB.rules.zip AfterB.starts).filterMap fun entry =>
    if 46 ≤ entry.2 && entry.2 ≤ 49 then some entry.1 else none

host_retained_theorem retained_run50 := fun (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren) (FR : Ren → P.F.S → P.F.S → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Before.Block0.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s0 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Region.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (returned : Annotated.Value) (entryReturn : notes.runtime.control = returnNote returned)
    (outerRole : Annotated.Value)
    (outerCell : notes.runtime.cells.cells Mid.Block25.sourceAddress = some outerRole)
    (localRole : Annotated.Value)
    (localCell : notes.runtime.cells.cells AfterA.Block31.address = some localRole) => by
  have earlier := retained_run46 notes ν₀ ν C₀ C R FR live framed before after old old' s inst h inventory
    budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed globalLive globalFixed
    returned entryReturn outerRole outerCell localRole localCell
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, retained_run50Rules using stateNext, retainedNext, instNext
    continuing_run run initial_relation h
host_assert_retained_schema retained_run50, 50

end Host.Load.Run.Full.Ordinary.PostConcatCleanup
