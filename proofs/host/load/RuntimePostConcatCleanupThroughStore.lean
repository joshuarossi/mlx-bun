import host.load.RuntimePostConcatCleanupRun55
import host.load.RuntimePostConcatCleanupRun56
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.PostConcatCleanup
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

/-- Live addresses after the closure allocation and its parameter cells. -/
noncomputable def reachedLive (live : Nat → Prop) : Nat → Prop :=
  CellsLive
    (ClosureLive (LiveAfter live From1979.state9part1) From2004.state16part1 AfterB.Block41.sourceArrow
      AfterB.Block41.sourceHome AfterB.Block41.sourceFunction)
    From2004.state17part1 (blockNames AfterB.Block42.sourceBody)

/-- The element bound at the first array pattern, then the second. -/
noncomputable def reachedArrayRoles : List Value :=
  [Value.obj Before.Block8.sourceObject,Value.obj Before.Block6.sourceObject].reverse

/-- Notes at source 2034, before the disposed-flag write.
Private, capture, public, and buffer notes are the entry notes. The closure
and the two bindings have extended the cells, and the array literal has its
element notes. Eight saved frames sit under the current assign frame. -/
noncomputable def reachedNotes (notes : RetainedNotes) : RetainedNotes := {
  runtime := {
    control := returnNote AfterB.Block54.parsed.role
    stack :=
      Tree.node "Frame.a" [Tree.node "AsgF.put" [
          Tree.atom (Option BinOp) none,
          Tree.node "Target.priv" [
            Tree.value (callReceiverNote AfterB.Block40.sourceMode (Value.obj AfterB.Block39.sourceAddress)),
            Tree.address AfterB.Block53.sourceBrand,
            Tree.atom Name AfterB.Block53.sourceName],
          Tree.value Value.undef]] ::
      Tree.node "Frame.s" [Tree.node "StmtF.block" [
          Tree.atom (List Stmt) AfterB.Block49.sourceRest,
          environmentNote AfterB.Block49.sourceEnv]] ::
      Tree.node "Frame.s" [Tree.node "StmtF.scope" [Tree.node "List" []]] ::
      Tree.node "Frame.k" [Tree.node "FnF.fn" [Tree.node "Boundary.call" []]] ::
      Tree.node "Frame.e" [Tree.node "ExprF.chain" []] ::
      Tree.node "Frame.s" [Tree.node "StmtF.block" [
          Tree.atom (List Stmt) AfterA.Block29.sourceRest,
          environmentNote AfterA.Block29.sourceEnv]] ::
      notes.runtime.stack.tail.tail.tail.tail.tail.tail.tail.tail
    cells :=
      ((notes.runtime.cells.write Before.Block16.sourceAddress
          (nthD Value.undef reachedArrayRoles 0)).write Before.Block18.sourceAddress
          (nthD Value.undef reachedArrayRoles.tail 0)).write From2004.state16part1
          (callReceiverNote AfterB.Block40.sourceMode (Value.obj AfterB.Block39.sourceAddress)) }
  privates := notes.privates
  captures := notes.captures
  «arrays» := notes.arrays.write From1979.state9part1 reachedArrayRoles
  publicFields := notes.publicFields
  buffers := notes.buffers }

/-- Notes after the disposed-flag write. The handle note is untouched. -/
noncomputable def storedNotes (notes : RetainedNotes) : RetainedNotes :=
  storeNotes (reachedNotes notes) AfterB.Block54.parsed.role (reachedNotes notes).runtime.stack.tail

/-- Source 1979 through the disposed-flag write at source 2034 is 56 steps. -/
theorem retained_run56 (notes : RetainedNotes)
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
      ⟨AfterB.Block75.sourceBrand,AfterB.Block75.sourceName,handleRole⟩) :
    ∃ result, runC P.F 56 s C = some (result,C) ∧
      Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R (reachedLive live) framed before after old old'
        DisposedStore.output result ∧
      RetainedInventory (storedNotes notes) ν₀ ν C₀ C R (reachedLive live)
        DisposedStore.output result ∧
      Inst ν₀ DisposedStore.nextServer C₀ := by
  obtain ⟨mid,run55,state55,inventory55,inst55⟩ :=
    retained_run55 notes ν₀ ν C₀ C R FR live framed before after old old' s inst h inventory
      budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed globalLive globalFixed
      returned entryReturn outerRole outerCell localRole localCell
  have sourceNext : AfterB.Block54.output.next = Region.s0.next+3 := by host_kernel_rfl
  have targetBound : mid.next ≤ 2^64 :=
    chain_next_budget_le h state55 3 0 64 (2^64) sourceNext (by decide) budget
  obtain ⟨result,one,post,retained,nextInst⟩ := by
    refine store_run (reachedNotes notes) ν₀ ν C₀ C R FR (reachedLive live) framed before after old old'
      mid inst55 ?_ ?_ AfterB.Block54.parsed.role _ _ (by rfl) (by rfl) targetBound
      ⟨AfterB.Block75.sourceBrand,AfterB.Block75.sourceName,handleRole⟩ ?_ handle_not_disposed
    · exact state55
    · exact inventory55
    · exact handleField
  exact ⟨result,runC_join P.F (m := 55) (n := 1) run55 one,post,retained,nextInst⟩

host_assert_retained_schema retained_run56, 56

end Host.Load.Run.Full.Ordinary.PostConcatCleanup
