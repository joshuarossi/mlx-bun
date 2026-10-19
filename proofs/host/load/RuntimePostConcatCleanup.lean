import host.load.RuntimePostConcatCleanupRun74
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.PostConcatCleanup
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

/- Source 1979 through source 2056 is 77 steps. The parent discharges the entry
relation, the six retained inventories, the numeric server, the allocation
budget, and the fixed prototypes. `entryReturn` is the role of the value
returned at source 1979. `outerCell` is the outer `this` cell. `localCell` is
the local read at source 2010. `handleField` is the wrapper's current `#handle`
note, whose name is not `#disposed`. -/

noncomputable def retained_to_freeRules.rules :=
  (AfterB.rules.zip AfterB.starts).filterMap fun entry =>
    if 74 ≤ entry.2 && entry.2 ≤ 76 then some entry.1 else none

host_retained_theorem retained_to_free := fun (notes : RetainedNotes)
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
    (localCell : notes.runtime.cells.cells AfterA.Block31.address = some localRole)
    (handleRole : Annotated.Value)
    (handleField : notes.privates.owners DisposedStore.sourceAddress = some
      ⟨AfterB.Block75.sourceBrand,AfterB.Block75.sourceName,handleRole⟩) => by
  have earlier := retained_run74 notes ν₀ ν C₀ C R FR live framed before after old old' s inst h inventory
    budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed globalLive globalFixed
    returned entryReturn outerRole outerCell localRole localCell handleRole handleField
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, retained_to_freeRules using stateNext, retainedNext, instNext
    continuing_run run initial_relation h
host_assert_retained_schema retained_to_free, 77


/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema retained_to_free, 78

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  let info ← getConstInfo ``retained_to_free
  forallTelescope info.type fun _ tail => do
    let tail ← whnf tail
    unless tail.isAppOfArity ``Exists 2 do throwError "expected a reached state"
    lambdaTelescope tail.getAppArgs[1]! fun _ body => do
      let rec find (p : Lean.Expr) (name : Lean.Name) : MetaM Lean.Expr := do
        if p.getAppFn.isConstOf name then return p
        if p.isAppOfArity ``And 2 then
          try find p.getAppArgs[0]! name catch _ => find p.getAppArgs[1]! name
        else throwError "missing {name}"
      let state ← find body ``Parametric.StateR
      let retained ← find body ``RetainedInventory
      let rec unwrap (e : Lean.Expr) (fuel : Nat) : MetaM Lean.Expr := do
        if fuel = 0 then return e
        match ← unfoldDefinition? e with
        | some next => if next.isConst then pure next else unwrap next (fuel - 1)
        | none => pure e
      let sourceState ← unwrap (state.getAppArgs[state.getAppArgs.size - 2]!) 4
      unless sourceState.isConstOf ``Region.s77 do
        throwError "retained source endpoint is {sourceState}"
      let retainedSource ← unwrap (retained.getAppArgs[retained.getAppArgs.size - 2]!) 4
      unless retainedSource.isConstOf ``Region.s77 do
        throwError "inventory source endpoint is {retainedSource}"
      let _ ← find body ``Eq
      let _ ← find body ``Inst

end Host.Load.Run.Full.Ordinary.PostConcatCleanup
