import host.load.RuntimePostConvCleanupPlan
import host.ts.RenameRuntimeDriverPrivateOther
import host.ts.RenameRetainedExpressionBody
import host.ts.RenameRetainedParameterBody
import host.ts.RenameRuntimeParameterNotes
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.PostConvCleanup
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

/-- The current declaration frame keeps its fixed pattern and remaining
declarators. The initializer's value role stays in control, not in this frame. -/
def declarationFrameNote (kind : DeclKind) (pattern : Pat) (rest : List (Pat × Option Expr)) (env : Env) : Annotated.Tree :=
  .node "Frame.s" [.node "StmtF.decl" [.atom DeclKind kind,.atom Pat pattern,
    .atom (List (Pat × Option Expr)) rest,environmentNote env]]

/-- Current stack at the convolution return. The callback, `outArray`, the
`new MlxArray` argument frame, and `conv1d`'s return frames stay structured.
The constructor function and accumulated argument roles, plus the caller tail,
stay symbolic. -/
noncomputable def entryFrames (fnRole thisRole : Value) (caller : List Annotated.Tree) : List Annotated.Tree :=
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
  emptyScopeNote::callBoundaryNote::
  caller

host_retained_private_store_other P.F, Region.s99 using (Region.S99.substitute LoopVariables.oracleVariables)
  to Region.s100 using (Region.S100.substitute LoopVariables.oracleVariables) as DisposedStore

namespace DisposedStore

def handleAt (s : St P.F.S) : Option Val :=
  (s.obj? 3126703).bind fun object =>
    match findPriv 4852 chars!"handle" object.priv with
    | some (.data value _ _) => some value
    | _ => none

theorem source_flag : sourceName = chars!"disposed" := by host_kernel_rfl
theorem source_value : sourceValue = .bool true := by host_kernel_rfl
theorem source_owner : sourceAddress = 3126703 := by host_kernel_rfl
theorem handle_before : handleAt input = some (.big 29372) := by host_kernel_rfl
theorem handle_after : handleAt output = some (.big 29372) := by host_kernel_rfl
theorem native_preserved : output.ffi = input.ffi := by host_kernel_rfl

open Lean Elab Command in
run_cmd do
  for claim in [
      "theorem wrong_flag : sourceName = chars!\"handle\" := by host_kernel_rfl",
      "theorem wrong_freed_handle : handleAt output = some (.big 29373) := by host_kernel_rfl",
      "theorem wrong_conv_handle : handleAt output = some (.big 29375) := by host_kernel_rfl",
      "theorem wrong_value : sourceValue = .bool false := by host_kernel_rfl",
      "host_retained_private_store_other P.F, Region.s99 using (Region.S99.substitute LoopVariables.oracleVariables) to Region.s101 using (Region.S101.substitute LoopVariables.oracleVariables) as WrongEndpoint"] do
    let saved : Lean.Elab.Command.State ← get
    let count := saved.messages.toList.length
    let mut rejected := false
    try Host.Ts.Owned.Parametric.Driver.emit claim
    catch exception =>
      rejected := ((← exception.toMessageData.toString).splitOn "(kernel) declaration type mismatch").length > 1
    for message in (← get).messages.toList.drop count do
      if ((← message.data.toString).splitOn "(kernel) declaration type mismatch").length > 1 then rejected := true
    set saved
    unless rejected do throwError "disposed-store negative did not reach the intended kernel rejection: {claim}"
end DisposedStore

noncomputable def BeforeReturn.rules :=
  (Plan.rules.zip Plan.starts).filterMap (fun entry => if entry.2 < 19 then some entry.1 else none)

host_retained_theorem retained_before_return := fun (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s0 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Region.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (fnRole thisRole : Annotated.Value) (caller : List Annotated.Tree)
    (entryControl : notes.runtime.control = returnNote nativeStatusRole)
    (entryStack : notes.runtime.stack = entryFrames fnRole thisRole caller)
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
host_assert_retained_schema retained_before_return, 19

noncomputable def OutArrayReturn.rules :=
  (Plan.rules.zip Plan.starts).filterMap (fun entry => if entry.2 == 19 then some entry.1 else none)

host_retained_theorem retained_after_return := fun (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s0 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Region.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (fnRole thisRole : Annotated.Value) (caller : List Annotated.Tree)
    (entryControl : notes.runtime.control = returnNote nativeStatusRole)
    (entryStack : notes.runtime.stack = entryFrames fnRole thisRole caller)
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
  have earlier := retained_before_return notes ν₀ ν C₀ C R FR live framed before after old old' s inst state inventory budget
    fnRole thisRole caller entryControl entryStack inputRole slotEntry outputSlot inputOwner
    functionLive functionFixed objectLive objectFixed arrayLive arrayFixed bufferLive bufferFixed typedLive typedFixed globalLive globalFixed
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, OutArrayReturn using stateNext, retainedNext, instNext continuing_run run initial_relation state
host_assert_retained_schema retained_after_return, 34

noncomputable def BeforeDisposal.rules :=
  (Plan.rules.zip Plan.starts).filterMap (fun entry => if 34 ≤ entry.2 && entry.2 < 99 then some entry.1 else none)

host_retained_theorem retained_before_disposal := fun (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s0 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Region.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (fnRole thisRole : Annotated.Value) (caller : List Annotated.Tree)
    (entryControl : notes.runtime.control = returnNote nativeStatusRole)
    (entryStack : notes.runtime.stack = entryFrames fnRole thisRole caller)
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
  have earlier := retained_after_return notes ν₀ ν C₀ C R FR live framed before after old old' s inst state inventory budget
    fnRole thisRole caller entryControl entryStack inputRole slotEntry outputSlot inputOwner
    functionLive functionFixed objectLive objectFixed arrayLive arrayFixed bufferLive bufferFixed typedLive typedFixed globalLive globalFixed
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, BeforeDisposal using stateNext, retainedNext, instNext continuing_run run initial_relation state
host_assert_retained_schema retained_before_disposal, 99

end Host.Load.Run.Full.Ordinary.PostConvCleanup
