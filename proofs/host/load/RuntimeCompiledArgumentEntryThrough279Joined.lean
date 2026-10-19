import host.load.RuntimeCompiledArgumentEntryThrough279Last
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 2000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Lean Elab Meta Tactic in
private partial def proveCompiledLive (type : Lean.Expr) (fuel : Nat := 96) : MetaM Lean.Expr := do
  if fuel == 0 then throwError "compiled argument live-resource derivation exhausted"
  for decl in (← getLCtx) do
    unless decl.isImplementationDetail do
      let saved ← saveState
      if ← isDefEq decl.type type then return decl.toExpr
      saved.restore
  let type ← whnf type
  let args := type.getAppArgs
  if type.isAppOfArity ``LiveAfter 3 then
    return ← mkAppOptM ``Or.inl #[some (mkApp args[0]! args[2]!),some (← mkEq args[2]! args[1]!),some (← proveCompiledLive (mkApp args[0]! args[2]!) (fuel-1))]
  if type.isAppOfArity ``CellsLive 4 then
    return ← mkAppM ``CellsLive.grow #[args[0]!,args[1]!,args[2]!,args[3]!,← proveCompiledLive (mkApp args[0]! args[3]!) (fuel-1)]
  if type.isAppOfArity ``ClosureLive 6 then
    return ← mkAppM ``ClosureLive.grow #[args[0]!,args[1]!,args[2]!,args[3]!,args[4]!,args[5]!,← proveCompiledLive (mkApp args[0]! args[5]!) (fuel-1)]
  if type.isAppOfArity ``Or 2 then
    return ← mkAppOptM ``Or.inl #[some args[0]!,some args[1]!,some (← proveCompiledLive args[0]! (fuel-1))]
  throwError "current-entry live resource was not retained: {type}"
open Lean Elab Meta Tactic in
elab "compiled_argument_live" : tactic => withMainContext do
  let goal ← getMainGoal
  goal.assign (← proveCompiledLive (← goal.getType))
  replaceMainGoal []

-- Only source0 occurrence roles, intrinsic resources and fresh-space budget
-- are assumptions. Every later allocation, local, buffer and loop-index note
-- is obtained from the preceding interpreter execution.
host_retained_theorem retained_through279 := fun (notes : RetainedNotes)
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
    (metadata : NativeCaptureNote)
    (selected : notes.captures.owners 95 = some metadata)
    (codeNote : metadata.roles 0 = some (.literal (.lit From64.TypedCount106.codeLiteral)))
    (protoNote : metadata.roles 1 = some (.literal (.lit From64.TypedCount106.protoLiteral)))
    (inputNote : notes.privates.owners 3126874 = some ⟨4852,chars!"handle",.handle 29375⟩)
    (weightNote : notes.privates.owners 221129 = some ⟨4852,chars!"handle",.handle 40⟩)
    (biasNote : notes.privates.owners 221295 = some ⟨4852,chars!"handle",.handle 41⟩)
    (inputWord : R.handle 29375 < 2^64) (weightWord : R.handle 40 < 2^64) (biasWord : R.handle 41 < 2^64)
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (protoLive : live 26) (protoFixed : R.a 26 = 26)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (budget : s.next+40 ≤ 2^64) => by
  have bufferWord : R.a From64.TypedStore155.buffer < 2^64 := by
    change R.a (Region.s0.next+26) < 2^64
    rw [state.heap.fresh 26]
    omega
  have bufferUnframed : ¬ framed From64.TypedStore155.buffer :=
    chain_not_framed_fresh state _ (by change 3126884 ≤ 3126910; decide)
  have completed64 := retained_wrapper notes ν₀ ν C₀ C R FR live framed before after old old' s
    inst state inventory role controlNote cellRole entry receiverRole receiverEntry (by omega)
  let t64 := Classical.choose completed64
  have post64 := Classical.choose_spec completed64
  have run64 := post64.1
  have h64 := post64.2.1
  have inv64 := post64.2.2.1
  have i64 := post64.2.2.2
  have budget64 : t64.next+28 ≤ 2^64 :=
    chain_next_budget_le state h64 12 28 40 (2^64) source_heap_growth64 (by decide) budget
  have completed106 := retained_from64_to106 notes role cellRole receiverRole
    ν₀ ν C₀ C R FR _ framed before after old old' t64 i64 h64 inv64 metadata selected codeNote protoNote
    (by compiled_argument_live) bufferProtoFixed (by compiled_argument_live) protoFixed
    (by compiled_argument_live) arrayFixed (by compiled_argument_live) globalFixed budget64
  let t106 := Classical.choose completed106
  have post106 := Classical.choose_spec completed106
  have run106 := post106.1
  have h106 := post106.2.1
  have inv106 := post106.2.2.1
  have i106 := post106.2.2.2
  have budget106 : t106.next+14 ≤ 2^64 :=
    chain_next_budget_le state h106 26 14 40 (2^64) source_heap_growth106 (by decide) budget
  have completed156 := retained_from106_to156 notes role cellRole receiverRole ν₀ ν C₀ C R FR _ framed before after old old' t106 i106 h106 inv106
    metadata selected codeNote protoNote inputNote weightNote biasNote inputWord weightWord biasWord
    (by compiled_argument_live) bufferProtoFixed (by compiled_argument_live) protoFixed
    (by compiled_argument_live) arrayFixed (by compiled_argument_live) globalFixed budget106
  let t156 := Classical.choose completed156
  have post156 := Classical.choose_spec completed156
  have run156 := post156.1
  have h156 := post156.2.1
  have inv156 := post156.2.2.1
  have i156 := post156.2.2.2
  have budget156 : t156.next+8 ≤ 2^64 :=
    chain_next_budget_le state h156 32 8 40 (2^64) (by host_kernel_rfl) (by decide) budget
  have completed170 := retained_from156_to170 notes role cellRole receiverRole ν₀ ν C₀ C R FR _ framed before after old old' t156 i156 h156 inv156
    metadata selected codeNote protoNote inputNote weightNote biasNote inputWord weightWord biasWord
    (by compiled_argument_live) bufferProtoFixed (by compiled_argument_live) protoFixed
    (by compiled_argument_live) arrayFixed (by compiled_argument_live) globalFixed bufferWord budget156
  let t170 := Classical.choose completed170
  have post170 := Classical.choose_spec completed170
  have run170 := post170.1
  have h170 := post170.2.1
  have inv170 := post170.2.2.1
  have i170 := post170.2.2.2
  have budget170 : t170.next+7 ≤ 2^64 :=
    chain_next_budget_le state h170 33 7 40 (2^64) (by host_kernel_rfl) (by decide) budget
  have inv170lit := retained_closed_cell inv170 From64.VariableIndex170.indexCell
    (Through170.indexRole notes role cellRole receiverRole) From64.VariableIndex170.literal
    (through170_index_selected notes role cellRole receiverRole)
    (through170_index_closed notes role cellRole receiverRole) through170_index_source
  have completed214 := retained_from170_to214 notes role cellRole receiverRole ν₀ ν C₀ C R FR _ framed before after old old' t170 i170 h170 inv170lit
    metadata selected codeNote protoNote inputNote weightNote biasNote inputWord weightWord biasWord
    (by compiled_argument_live) bufferProtoFixed (by compiled_argument_live) protoFixed
    (by compiled_argument_live) arrayFixed (by compiled_argument_live) globalFixed bufferUnframed bufferWord budget170
  let t214 := Classical.choose completed214
  have post214 := Classical.choose_spec completed214
  have run214 := post214.1
  have h214 := post214.2.1
  have inv214 := post214.2.2.1
  have i214 := post214.2.2.2
  have budget214 : t214.next+4 ≤ 2^64 :=
    chain_next_budget_le state h214 36 4 40 (2^64) (by host_kernel_rfl) (by decide) budget
  have inv214lit := retained_closed_cell inv214 From64.VariableIndex214.indexCell
    (Through214.indexRole notes role cellRole receiverRole) From64.VariableIndex214.literal
    (through214_index_selected notes role cellRole receiverRole)
    (through214_index_closed notes role cellRole receiverRole) through214_index_source
  have completed272 := retained_from214_to272 notes role cellRole receiverRole ν₀ ν C₀ C R FR _ framed before after old old' t214 i214 h214 inv214lit
    metadata selected codeNote protoNote inputNote weightNote biasNote inputWord weightWord biasWord
    (by compiled_argument_live) bufferProtoFixed (by compiled_argument_live) protoFixed
    (by compiled_argument_live) arrayFixed (by compiled_argument_live) globalFixed bufferUnframed bufferWord budget214
  let t272 := Classical.choose completed272
  have post272 := Classical.choose_spec completed272
  have run272 := post272.1
  have h272 := post272.2.1
  have inv272 := post272.2.2.1
  have i272 := post272.2.2.2
  have budget272 : t272.next+1 ≤ 2^64 :=
    chain_next_budget_le state h272 39 1 40 (2^64) (by host_kernel_rfl) (by decide) budget
  have completed277 := retained_from272_to277 notes role cellRole receiverRole ν₀ ν C₀ C R FR _ framed before after old old' t272 i272 h272 inv272
    metadata selected codeNote protoNote inputNote weightNote biasNote inputWord weightWord biasWord
    (by compiled_argument_live) bufferProtoFixed (by compiled_argument_live) protoFixed
    (by compiled_argument_live) arrayFixed (by compiled_argument_live) globalFixed bufferWord budget272
  let t277 := Classical.choose completed277
  have post277 := Classical.choose_spec completed277
  have run277 := post277.1
  have h277 := post277.2.1
  have inv277 := post277.2.2.1
  have i277 := post277.2.2.2
  have budget277 : t277.next+1 ≤ 2^64 :=
    chain_next_budget_le state h277 39 1 40 (2^64) (by host_kernel_rfl) (by decide) budget
  have previous := runC_join P.F (runC_join P.F (runC_join P.F (runC_join P.F
    (runC_join P.F (runC_join P.F run64 run106) run156) run170) run214) run272) run277
  have control := through277_control notes role cellRole receiverRole
  have closed := through277_closed notes role cellRole receiverRole
  host_normalize_retained h277, inv277
  host_retained_plan_chain_after P.F, Through279Last using h277, inv277, i277
    continuing_run previous initial_relation state
host_assert_retained_schema retained_through279, 279

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema retained_through279, 278

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema retained_through279, 280
end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
