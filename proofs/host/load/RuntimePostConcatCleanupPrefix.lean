import host.load.RuntimePostConcatCleanupPlan
import host.ts.RenameRuntimeStaticCall
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.PostConcatCleanup
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

/- Source 1979 through source 2056 is 77 original steps. The parent discharges
the entry relation, all six retained inventories, the numeric server, the
allocation budget, and the fixed prototypes. The value returned at the entry
keeps its current role (`entryReturn`). The outer `this` cell and the local
read at source 2010 keep their current roles (`outerCell`, `localCell`). The
wrapper's current handle note is not `#disposed`, so the flag write keeps it
and the later handle read uses that same note. No target heap, future
inventory, or desired endpoint is assumed. -/
host_retained_theorem retained_to_call := fun (notes : RetainedNotes)
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
  host_normalize_retained h, inventory
  host_retained_plan_chain P.F, ToCall using h, inventory, inst
host_assert_retained_schema retained_to_call, 41

host_retained_theorem retained_through_call := fun (notes : RetainedNotes)
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
  have earlier := retained_to_call notes ν₀ ν C₀ C R FR live framed before after old old' s inst h inventory
    budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed globalLive globalFixed
    returned entryReturn outerRole outerCell localRole localCell
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  have _controlNote := retainedNext.runtime.object_call_note 4882 2978923 dispose_entry
  host_retained_plan_chain_after P.F, DisposeCall using stateNext, retainedNext, instNext
    continuing_run run initial_relation h
host_assert_retained_schema retained_through_call, 42

noncomputable def ToStore.rules :=
  (AfterB.rules.zip AfterB.starts).filterMap fun entry =>
    if 42 ≤ entry.2 && entry.2 ≤ 54 then some entry.1 else none

noncomputable def StoreStep.rules := [``DisposedStore.retained_transport]

noncomputable def ToUnregister.rules :=
  (AfterB.rules.zip AfterB.starts).filterMap fun entry =>
    if 56 ≤ entry.2 && entry.2 ≤ 66 then some entry.1 else none

noncomputable def ToFree.rules :=
  (AfterB.rules.zip AfterB.starts).filterMap fun entry =>
    if 67 ≤ entry.2 then some entry.1 else none

theorem split_spans :
    ((AfterB.spans.zip AfterB.starts).filterMap fun entry =>
      if 42 ≤ entry.2 && entry.2 ≤ 54 then some entry.1 else none).sum = 13 ∧
    ((AfterB.spans.zip AfterB.starts).filterMap fun entry =>
      if 56 ≤ entry.2 && entry.2 ≤ 66 then some entry.1 else none).sum = 11 ∧
    ((AfterB.spans.zip AfterB.starts).filterMap fun entry =>
      if 67 ≤ entry.2 then some entry.1 else none).sum = 10 := by
  decide +kernel

end Host.Load.Run.Full.Ordinary.PostConcatCleanup
