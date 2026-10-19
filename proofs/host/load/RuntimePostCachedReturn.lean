import host.load.RuntimePostCachedReturnToFree
import host.load.RuntimePostCachedReturnNative

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0

namespace Host.Load.Run.Full.Ordinary.PostCachedReturn
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated
open Host.Load.Run.Full.Ordinary.CachedCall
open Host.Load.Run.Full.Ordinary.CachedStrongHost

noncomputable def Continue.rules := [``VectorFree2408.retained_release] ++ BeforeSize.rules ++
  [``VectorSize2428.retained_transport] ++ AfterSize.rules

/- Current-entry meanings come from the cached-call return, the retained
slot pointer/input vector cells, and the cached call's output-slot bytes.
The status and outVec bindings are created by the checked host prefix. -/
host_retained_theorem retained_run64 := fun (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (objects : Nat → Object) (H frame roots : Nat → Prop)
    (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ BeforeFree.Block0.initialServer C₀)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (NativeRelation ν₀ ν C₀ C base (outputObjectRoles objects) H (fun i => N3 i ∨ frame i) tail host)
      R live framed before after old old' From2383.s0 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live From2383.s0 s)
    (policy : ProducerAnnotations roots H (fun i => N3 i ∨ frame i)
      (roles (coupledRoles base)) (outputObjectRoles objects))
    (budget : s.next+64 ≤ 2^64)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (entryReturn : notes.runtime.control = returnNote nativeStatusRole)
    (slotPointer : notes.runtime.cells.cells 3126903 = some (.ptr (.js 3126924) 0))
    (inputVector : notes.runtime.cells.cells 3126901 = some (.handle 29376))
    (outputSlot : notes.buffers.owners 3126924 = some (handleSlotNotes 29377))
    (freeFrame : ¬ framed 4413) (sizeFrame : ¬ framed 4571)
    (outputLive : H 29377) => by
  have earlier := retained_to_vector_free notes ν₀ ν C₀ C R
    (NativeRelation ν₀ ν C₀ C base (outputObjectRoles objects) H (fun i => N3 i ∨ frame i) tail host)
    live framed before after old old' s inst h inventory budget nativeStatusRole entryReturn slotPointer inputVector outputSlot
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  have _statusClosed : (SymE.lit (F64.zero false)).closed = true := rfl
  have _releasedPolicy := release_policy policy
  have _outputRetained := output_retained outputLive
  have sizeSchema : IntegerNumberRole (.ordinaryBig 3) (.lit (F64.ofInt 3)) := .ordinary 3
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, Continue using stateNext, retainedNext, instNext
    continuing_run run initial_relation h
host_assert_retained_schema retained_run64, 64

/- Exactly 64 original steps reach source 2447, with all six inventories,
its namespaced numeric-server instance, the cached replay's strong native
relation, and derived producer policy/support after releasing input 29376. -/
host_retained_theorem retained_through_vector_size := fun (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (objects : Nat → Object) (H frame roots : Nat → Prop)
    (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ BeforeFree.Block0.initialServer C₀)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (NativeRelation ν₀ ν C₀ C base (outputObjectRoles objects) H (fun i => N3 i ∨ frame i) tail host)
      R live framed before after old old' From2383.s0 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live From2383.s0 s)
    (policy : ProducerAnnotations roots H (fun i => N3 i ∨ frame i)
      (roles (coupledRoles base)) (outputObjectRoles objects))
    (budget : s.next+64 ≤ 2^64)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (entryReturn : notes.runtime.control = returnNote nativeStatusRole)
    (slotPointer : notes.runtime.cells.cells 3126903 = some (.ptr (.js 3126924) 0))
    (inputVector : notes.runtime.cells.cells 3126901 = some (.handle 29376))
    (outputSlot : notes.buffers.owners 3126924 = some (handleSlotNotes 29377))
    (freeFrame : ¬ framed 4413) (sizeFrame : ¬ framed 4571)
    (outputLive : H 29377) => by
  have completed := retained_run64 notes ν₀ ν C₀ C R base objects H frame roots tail host
    live framed before after old old' s inst h inventory policy budget
    arrayLive arrayFixed globalLive globalFixed entryReturn slotPointer inputVector outputSlot
    freeFrame sizeFrame outputLive
  have post := Classical.choose_spec completed
  have reachedRun := post.1
  have reachedState := post.2.1
  have reachedInventory := post.2.2.1
  have reachedInst := post.2.2.2
  have reachedPolicy := release_policy policy
  have sourceSupport := reachedPolicy.source reachedState.native.2
  have targetSupport := reachedPolicy.target reachedState.native.2
  have inputReleased := input_released H
  have outputRetained := output_retained outputLive
  run_tac do
    let goal ← Lean.Elab.Tactic.getMainGoal
    goal.withContext do
      let completed ← Lean.mkFVar <$> Lean.Elab.Tactic.getFVarId (Lean.mkIdent `completed)
      let witness ← Lean.Meta.mkAppM ``Classical.choose #[completed]
      let fields ← #[`reachedRun,`reachedState,`reachedInventory,`reachedInst,
        `reachedPolicy,`sourceSupport,`targetSupport,`inputReleased,`outputRetained].mapM fun name =>
          Lean.mkFVar <$> Lean.Elab.Tactic.getFVarId (Lean.mkIdent name)
      let mut body := fields.back!
      for field in fields.toList.dropLast.reverse do
        body ← Lean.Meta.mkAppM ``And.intro #[field,body]
      body ← Lean.instantiateMVars body
      let bodyType ← Lean.instantiateMVars (← Lean.Meta.inferType body)
      let witness ← Lean.instantiateMVars witness
      let abstracted ← Lean.Meta.kabstract bodyType witness
      unless abstracted.hasLooseBVars do throwError "post-cached result did not bind its reached state"
      let domain ← Lean.Meta.inferType witness
      let predicate := Lean.mkLambda `result Lean.BinderInfo.default domain abstracted
      let term ← Lean.instantiateMVars (← Lean.Meta.mkAppOptM ``Exists.intro
        #[some domain,some predicate,some witness,some body])
      if term.hasMVar then throwError "post-cached result has unresolved metavariables"
      unless ← Lean.Meta.isDefEq (← Lean.Meta.inferType term) (← goal.getType) do
        throwError "post-cached result does not match its retained conclusion"
      goal.assign term
    Lean.Elab.Tactic.replaceMainGoal []
host_assert_retained_schema retained_through_vector_size, 64

end Host.Load.Run.Full.Ordinary.PostCachedReturn
