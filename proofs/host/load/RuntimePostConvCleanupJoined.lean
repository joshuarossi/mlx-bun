import host.load.RuntimePostConvCleanupFree
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.PostConvCleanup
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

/-- Notes carried by a reached inventory. The projection does not inspect the
target heap or counters. -/
def inventoryNotes {S : Type} {notes : RetainedNotes} {ν₀ ν : Nat → F64} {C₀ C : CSrv}
    {R : Ren} {live : Nat → Prop} {source target : St S}
    (_inventory : RetainedInventory notes ν₀ ν C₀ C R live source target) : RetainedNotes :=
  notes

def reachedControl (notes : RetainedNotes) : Annotated.Tree :=
  notes.runtime.control

def reachedHead (notes : RetainedNotes) : Annotated.Tree :=
  notes.runtime.stack.headD (.node "" [])

def reachedTail (notes : RetainedNotes) : List Annotated.Tree :=
  notes.runtime.stack.tail

noncomputable def reachedOwner (notes : RetainedNotes) : Option PrivateNote :=
  notes.privates.owners DisposedStore.sourceAddress

def reachedReceiver (notes : RetainedNotes) : Option Annotated.Value :=
  notes.runtime.cells.cells 3126879

noncomputable def reachedReturnRole : Annotated.Value :=
  Plan.Block98.parsed.role

noncomputable def reachedReceiverNote : Annotated.Value :=
  callReceiverNote Plan.Block84.sourceMode (.obj Plan.Block83.sourceAddress)

/-- Live addresses stay the ones supplied at the convolution return. -/
def carriedLive (live : Nat → Prop) : Nat → Prop :=
  live

theorem carriedLive_eq (live : Nat → Prop) : carriedLive live = live := rfl

theorem prefix_counter_offset : Region.s99.next = Region.s0.next + 7 := by host_kernel_rfl

theorem tail_counter_delta : Region.s121.next = Region.s100.next := by host_kernel_rfl

theorem reached_server : Plan.Block98.nextServer = DisposedStore.initialServer := by host_kernel_rfl

theorem handle_not_disposed : nameEq (chars!"handle") DisposedStore.sourceName = false := by
  host_kernel_rfl

/-- Reached live set. Allocation inside the 99 steps grows this set; the
projection is the live argument of the reached relation, not a new premise. -/
def stateLive {NR : NumV → NumV → Prop} {FR : Ren → P.F.S → P.F.S → Prop} {R : Ren}
    {live framed : Nat → Prop} {before after : List Val} {old old' : List Event}
    {source target : St P.F.S}
    (_state : Parametric.StateR NR FR R live framed before after old old' source target) : Nat → Prop :=
  live

theorem free_endpoint : Plan.Block120.output = Ordinary.ArrayFreeCall.input := by
  host_kernel_rfl

/- The twenty-one steps after the dispose store do not allocate and do not
constrain the target counter. The receiver cell and the existing handle owner
are the only reached-note facts they use. -/
host_retained_theorem retained_tail := fun (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan.Block100.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s100 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Region.s100 s)
    (disposeThis : Annotated.Value)
    (disposeThisEntry : notes.runtime.cells.cells 3126879 = some disposeThis)
    (inputRole : Annotated.Value)
    (inputOwner : notes.privates.owners 3126703 = some ⟨4852,chars!"handle",inputRole⟩) => by
  host_normalize_retained state, inventory
  host_retained_plan_chain P.F, AfterStore using state, inventory, inst
host_assert_retained_schema retained_tail, 21

host_retained_theorem retained_to_free := fun (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s0 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Region.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (fnRole thisRole : Annotated.Value) (caller : List Annotated.Tree)
    (entryControl : notes.runtime.control = returnNote nativeStatusRole)
    (entryStack : notes.runtime.stack = resultFrames fnRole thisRole caller)
    (inputRole : Annotated.Value)
    (slotEntry : notes.runtime.cells.cells 3126863 = some (.ptr (.js 3126867) 0))
    (outputSlot : notes.buffers.owners 3126867 = some (handleSlotNotes 29375))
    (inputOwner : notes.privates.owners 3126703 = some ⟨4852,chars!"handle",inputRole⟩)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live aTypedProto) (typedFixed : R.a aTypedProto = aTypedProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal) => by
  have reached := result_before_disposal notes ν₀ ν C₀ C R FR live framed before after old old' s inst state inventory budget
    fnRole thisRole caller entryControl entryStack inputRole slotEntry outputSlot inputOwner
    functionLive functionFixed objectLive objectFixed arrayLive arrayFixed bufferLive bufferFixed typedLive typedFixed globalLive globalFixed
  have reachedPost := Classical.choose_spec reached
  have run99 := reachedPost.1
  have state99 : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R
      (stateLive reachedPost.2.1) framed before after old old' Region.s99 (Classical.choose reached) :=
    disposal_region ▸ reachedPost.2.1
  have inv99 : RetainedInventory (inventoryNotes reachedPost.2.2.1) ν₀ ν C₀ C R
      (stateLive reachedPost.2.1) Region.s99 (Classical.choose reached) :=
    disposal_region ▸ reachedPost.2.2.1
  have inst99 : Inst ν₀ DisposedStore.initialServer C₀ := reached_server ▸ reachedPost.2.2.2
  let notes99 := inventoryNotes inv99
  have controlNote : reachedControl notes99 = returnNote reachedReturnRole := by host_kernel_rfl
  have stackNote : notes99.runtime.stack = reachedHead notes99 :: reachedTail notes99 := by host_kernel_rfl
  have ownerUnfold : reachedOwner notes99 = notes.privates.owners 3126703 := by host_kernel_rfl
  have ownerFact : reachedOwner notes99 = some ⟨4852,chars!"handle",inputRole⟩ :=
    ownerUnfold.trans inputOwner
  have receiverFact : reachedReceiver notes99 = some reachedReceiverNote := by host_kernel_rfl
  let reachedLive := stateLive state99
  have storeBound : (Classical.choose reached).next ≤ 2^64 := by
    have room : (7 : Nat) + 0 ≤ 64 := by decide
    exact chain_next_budget_le state state99 7 0 64 (2 ^ 64) prefix_counter_offset room budget
  let tracked : PrivateNote := ⟨4852,chars!"handle",inputRole⟩
  have stored := disposal_transport notes99 ν₀ ν C₀ C R FR reachedLive framed before after old old'
      (Classical.choose reached) inst99 state99 inv99 reachedReturnRole (reachedHead notes99) (reachedTail notes99)
      controlNote stackNote storeBound tracked ownerFact handle_not_disposed
  have storedPost := Classical.choose_spec stored
  have run1 := storedPost.1
  have state100 := storedPost.2.1
  have inv100 := storedPost.2.2.1
  have inst100 := storedPost.2.2.2
  let storedNotes := disposalNotes notes99 reachedReturnRole (reachedTail notes99)
  have receiverAfter : storedNotes.runtime.cells.cells 3126879 = some reachedReceiverNote := by
    simpa [storedNotes,disposalNotes,RetainedNotes.withRuntime,reachedReceiver] using receiverFact
  have ownerAfter : storedNotes.privates.owners 3126703 = some ⟨4852,chars!"handle",inputRole⟩ := by
    simpa [storedNotes,disposalNotes,RetainedNotes.withRuntime,reachedOwner,DisposedStore.source_owner] using ownerFact
  have continued := retained_tail storedNotes ν₀ ν C₀ C R FR (stateLive state100) framed before after old old'
    (Classical.choose stored) inst100 state100 inv100 reachedReceiverNote receiverAfter inputRole ownerAfter
  have continuedPost := Classical.choose_spec continued
  have run100 := runC_join P.F (m := 99) (n := 1) run99 run1
  have joined := runC_join P.F (m := 100) (n := 21) run100 continuedPost.1
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
        throwError "convolution join could not bind the reached interpreter state"
      let domain ← Lean.Meta.inferType witness
      let predicate := Lean.mkLambda `result Lean.BinderInfo.default domain abstracted
      let term ← Lean.instantiateMVars (← Lean.Meta.mkAppOptM ``Exists.intro
        #[some domain, some predicate, some witness, some body])
      if term.hasMVar then throwError "convolution join still has metavariables"
      let termType ← Lean.instantiateMVars (← Lean.Meta.inferType term)
      unless ← Lean.Meta.isDefEq termType (← goal.getType) do
        throwError "convolution join does not match the theorem goal"
      goal.assign (← Lean.instantiateMVars term)
    Lean.Elab.Tactic.replaceMainGoal []
host_assert_retained_schema retained_to_free, 121

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema retained_to_free, 120

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema retained_to_free, 122

end Host.Load.Run.Full.Ordinary.PostConvCleanup
