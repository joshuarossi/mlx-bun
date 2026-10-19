import host.load.RuntimePostConvCleanup
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.PostConvCleanup
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

/-- Current stack at the convolution return, matching initialized `resultNotes`:
thirteen structured heads, then the caller's own frames. The two outer frames
fixed by `entryFrames` stay in that caller when the source has not entered them. -/
noncomputable def resultFrames (fnRole thisRole : Annotated.Value) (caller : List Annotated.Tree) : List Annotated.Tree :=
  expressionReturnNote::callBoundaryNote::
  declarationFrameNote Plan.Block2.sourceKind Plan.Block2.sourcePattern Plan.Block2.sourceRest Plan.Block2.sourceEnv::
  blockFrameNote (Plan.Block5.sourceStatement::Plan.Block5.sourceRest) Plan.Block5.sourceEnv::
  emptyScopeNote::callBoundaryNote::
  argumentFrameNote false Plan.Block34.sourceKind fnRole thisRole [] Plan.Block34.sourceRest Plan.Block34.sourceEnv::
  expressionReturnNote::
  blockFrameNote [] Plan.Block73.sourceEnv::
  emptyScopeNote::callBoundaryNote::
  declarationFrameNote Plan.Block76.sourceKind Plan.Block76.sourcePattern Plan.Block76.sourceRest Plan.Block76.sourceEnv::
  blockFrameNote (Plan.Block79.sourceStatement::Plan.Block79.sourceRest) Plan.Block79.sourceEnv::
  caller

theorem entryFrames_result (fnRole thisRole : Annotated.Value) (caller : List Annotated.Tree) :
    entryFrames fnRole thisRole caller =
      resultFrames fnRole thisRole (emptyScopeNote::callBoundaryNote::caller) := rfl

host_retained_theorem result_before_return := fun (notes : RetainedNotes)
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
  host_normalize_retained state, inventory
  host_retained_plan_chain P.F, BeforeReturn using state, inventory, inst
host_assert_retained_schema result_before_return, 19

host_retained_theorem result_after_return := fun (notes : RetainedNotes)
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
  have earlier := result_before_return notes ν₀ ν C₀ C R FR live framed before after old old' s inst state inventory budget
    fnRole thisRole caller entryControl entryStack inputRole slotEntry outputSlot inputOwner
    functionLive functionFixed objectLive objectFixed arrayLive arrayFixed bufferLive bufferFixed typedLive typedFixed globalLive globalFixed
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, OutArrayReturn using stateNext, retainedNext, instNext continuing_run run initial_relation state
host_assert_retained_schema result_after_return, 34

host_retained_theorem result_before_disposal := fun (notes : RetainedNotes)
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
  have earlier := result_after_return notes ν₀ ν C₀ C R FR live framed before after old old' s inst state inventory budget
    fnRole thisRole caller entryControl entryStack inputRole slotEntry outputSlot inputOwner
    functionLive functionFixed objectLive objectFixed arrayLive arrayFixed bufferLive bufferFixed typedLive typedFixed globalLive globalFixed
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, BeforeDisposal using stateNext, retainedNext, instNext continuing_run run initial_relation state
host_assert_retained_schema result_before_disposal, 99

end Host.Load.Run.Full.Ordinary.PostConvCleanup
