import host.load.RuntimePostConvCleanupFrames
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.PostConvCleanup
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

theorem disposal_source : Plan.Block98.output = DisposedStore.input := by host_kernel_rfl
theorem disposal_region : Plan.Block98.output = Region.s99 := by host_kernel_rfl
theorem disposal_output : DisposedStore.output = Region.s100 := by host_kernel_rfl
theorem disposal_running : isHalt DisposedStore.input.ctl = false := by host_kernel_rfl

/-- Notes after the differently named `#disposed` store. Live addresses stay
the entry live set; this step does not allocate. -/
def disposalNotes (notes : RetainedNotes) (role : Annotated.Value) (tailNotes : List Annotated.Tree) :
    RetainedNotes :=
  notes.withRuntime ⟨returnNote role,tailNotes,notes.runtime.cells⟩

theorem runC_one {F : Ffi} (s result : St F.S) (C : CSrv)
    (running : isHalt s.ctl = false)
    (stepRun : interpC (step F s).run C = some (result,C)) :
    runC F 1 s C = some (result,C) := by
  have zero : runC F 0 result C = some (result,C) := by
    unfold runC
    exact runWith_zero F interpC result C
  exact runC_cons F 0 s result result C C C running stepRun zero

/-- One original step from the concat-input dispose store. Notes, live set,
and the reached target stay arbitrary apart from the current store premises. -/
theorem disposal_transport (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ DisposedStore.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s99 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Region.s99 s)
    (role : Annotated.Value) (headNote : Annotated.Tree) (tailNotes : List Annotated.Tree)
    (controlNote : notes.runtime.control = returnNote role)
    (stackNotes : notes.runtime.stack = headNote::tailNotes)
    (targetBound : s.next ≤ 2^64)
    (tracked : PrivateNote)
    (entry : notes.privates.owners DisposedStore.sourceAddress = some tracked)
    (different : nameEq tracked.name DisposedStore.sourceName = false) :
    ∃ result,
      runC P.F 1 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s100 result ∧
      RetainedInventory (disposalNotes notes role tailNotes) ν₀ ν C₀ C R live Region.s100 result ∧
      Inst ν₀ DisposedStore.nextServer C₀ := by
  have inputEq : DisposedStore.input = Region.s99 := disposal_source.symm.trans disposal_region
  have outputEq : DisposedStore.output = Region.s100 := disposal_output
  have stateAt : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' DisposedStore.input s :=
    inputEq.symm ▸ state
  have retainedAt : RetainedInventory notes ν₀ ν C₀ C R live DisposedStore.input s :=
    inputEq.symm ▸ inventory
  obtain ⟨result,_sourceRun,targetRun,stored,retained,inst'⟩ :=
    DisposedStore.retained_transport notes ν₀ ν C₀ C R FR live framed before after old old' s inst
      stateAt retainedAt role headNote tailNotes controlNote stackNotes targetBound tracked entry different
  have running : isHalt s.ctl = false :=
    (ControlR.isHalt_eq stateAt.control).trans disposal_running
  have run1 := runC_one s result C running targetRun
  have storedAt : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s100 result :=
    outputEq ▸ stored
  have retainedOut : RetainedInventory (disposalNotes notes role tailNotes) ν₀ ν C₀ C R live Region.s100 result := by
    simpa [disposalNotes] using (outputEq ▸ retained)
  exact ⟨result,run1,storedAt,retainedOut,inst'⟩

host_assert_retained_schema disposal_transport, 1

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema disposal_transport, 2

noncomputable def AfterStore.rules :=
  (Plan.rules.zip Plan.starts).filterMap (fun entry =>
    if 100 ≤ entry.2 && entry.2 < 121 then some entry.1 else none)

host_retained_theorem retained_after_store := fun (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan.Block100.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s100 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Region.s100 s)
    (budget : s.next+64 ≤ 2^64)
    (disposeThis : Annotated.Value)
    (disposeThisEntry : notes.runtime.cells.cells 3126879 = some disposeThis)
    (inputRole : Annotated.Value)
    (inputOwner : notes.privates.owners 3126703 = some ⟨4852,chars!"handle",inputRole⟩) => by
  host_normalize_retained state, inventory
  host_retained_plan_chain P.F, AfterStore using state, inventory, inst
host_assert_retained_schema retained_after_store, 21

theorem disposal_next : Region.s100.next = Region.s99.next := by host_kernel_rfl
theorem disposal_server : DisposedStore.nextServer = Plan.Block100.initialServer := by host_kernel_rfl
theorem tail_plan : Plan.Block120.output = Region.s121 := by host_kernel_rfl
theorem tail_endpoint : Region.s121 = Ordinary.ArrayFreeCall.input := by host_kernel_rfl

host_retained_theorem retained_store_to_free := fun (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ DisposedStore.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s99 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Region.s99 s)
    (role : Annotated.Value) (headNote : Annotated.Tree) (tailNotes : List Annotated.Tree)
    (controlNote : notes.runtime.control = returnNote role)
    (stackNotes : notes.runtime.stack = headNote::tailNotes)
    (budget : s.next+64 ≤ 2^64)
    (tracked : PrivateNote)
    (entry : notes.privates.owners DisposedStore.sourceAddress = some tracked)
    (different : nameEq tracked.name DisposedStore.sourceName = false)
    (disposeThis : Annotated.Value)
    (disposeThisEntry : notes.runtime.cells.cells 3126879 = some disposeThis)
    (inputRole : Annotated.Value)
    (inputOwner : notes.privates.owners 3126703 = some ⟨4852,chars!"handle",inputRole⟩) => by
  have storeBound : s.next ≤ 2^64 := Nat.le_trans (Nat.le_add_right _ _) budget
  have stored := disposal_transport notes ν₀ ν C₀ C R FR live framed before after old old' s inst state inventory
    role headNote tailNotes controlNote stackNotes storeBound tracked entry different
  have storedPost := Classical.choose_spec stored
  have run1 := storedPost.1
  have state100 := storedPost.2.1
  have inv100 := storedPost.2.2.1
  have inst100 := storedPost.2.2.2
  have thisAfter : (disposalNotes notes role tailNotes).runtime.cells.cells 3126879 = some disposeThis := by
    simpa [disposalNotes,RetainedNotes.withRuntime] using disposeThisEntry
  have ownerAfter : (disposalNotes notes role tailNotes).privates.owners 3126703 =
      some ⟨4852,chars!"handle",inputRole⟩ := by
    simpa [disposalNotes,RetainedNotes.withRuntime] using inputOwner
  have nextEq : (Classical.choose stored).next = s.next :=
    StateR.target_next_eq state state100 disposal_next
  have laterBudget : (Classical.choose stored).next+64 ≤ 2^64 := by
    simpa [nextEq] using budget
  have continued := retained_after_store (disposalNotes notes role tailNotes) ν₀ ν C₀ C R FR live framed before after old old'
    (Classical.choose stored) inst100 state100 inv100 laterBudget disposeThis thisAfter inputRole ownerAfter
  have continuedPost := Classical.choose_spec continued
  have joined := runC_join P.F run1 continuedPost.1
  -- The reached witness is Classical.choose, and this goal has no announced
  -- proposition, so the elaborator cannot bind that witness. Rebind it here.
  run_tac do
    let goal ← Lean.Elab.Tactic.getMainGoal
    goal.withContext do
      let continued ← Lean.mkFVar <$> Lean.Elab.Tactic.getFVarId (Lean.mkIdent `continued)
      let joined ← Lean.mkFVar <$> Lean.Elab.Tactic.getFVarId (Lean.mkIdent `joined)
      let continuedPost ← Lean.mkFVar <$> Lean.Elab.Tactic.getFVarId (Lean.mkIdent `continuedPost)
      let witness ← Lean.Meta.mkAppM ``Classical.choose #[continued]
      let rest ← Lean.Meta.mkAppM ``And.right #[continuedPost]
      let stateProof ← Lean.Meta.mkAppM ``And.left #[rest]
      let rest ← Lean.Meta.mkAppM ``And.right #[rest]
      let inventoryProof ← Lean.Meta.mkAppM ``And.left #[rest]
      let instProof ← Lean.Meta.mkAppM ``And.right #[rest]
      let body ← Lean.instantiateMVars (← Lean.Meta.mkAppM ``And.intro #[joined,
        ← Lean.Meta.mkAppM ``And.intro #[stateProof,
        ← Lean.Meta.mkAppM ``And.intro #[inventoryProof, instProof]]])
      let bodyType ← Lean.Meta.whnf (← Lean.instantiateMVars (← Lean.Meta.inferType body))
      let witness ← Lean.instantiateMVars witness
      let abstracted ← Lean.Meta.kabstract bodyType witness
      if !abstracted.hasLooseBVars then
        throwError "convolution cleanup could not bind the reached interpreter state"
      let domain ← Lean.Meta.inferType witness
      let predicate := Lean.mkLambda `result Lean.BinderInfo.default domain abstracted
      let term ← Lean.instantiateMVars (← Lean.Meta.mkAppOptM ``Exists.intro
        #[some domain, some predicate, some witness, some body])
      if term.hasMVar then throwError "convolution cleanup tail still has metavariables"
      let termType ← Lean.instantiateMVars (← Lean.Meta.inferType term)
      unless ← Lean.Meta.isDefEq termType (← goal.getType) do
        throwError "convolution cleanup tail does not match the theorem goal"
      goal.assign (← Lean.instantiateMVars term)
    Lean.Elab.Tactic.replaceMainGoal []
host_assert_retained_schema retained_store_to_free, 22

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema retained_store_to_free, 23

end Host.Load.Run.Full.Ordinary.PostConvCleanup
