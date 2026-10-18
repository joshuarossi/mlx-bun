import host.load.RuntimeNamespacedMap100
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.NamespacedMap
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open RetainedShapeBatch RetainedParameterBatch
host_source_plan_subst P.F, P.RestStream.micro0 from 100 plan_steps 49 substitute LoopVariables.oracleVariables as Plan100

host_retained_theorem through149 := fun (notes : RetainedNotes) (caller : List Annotated.Tree) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan14.Block14.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' P.RestStream.micro0.micro0.s14 s)
    (inventory : RetainedInventory (RetainedShapePrefix.EndNotes notes caller
      [.literal (.lit (F64.ofNat 1)),.literal (.lit (F64.ofNat 1)),.literal (.lit (F64.ofNat 10240))])
      ν₀ ν C₀ C R live P.RestStream.micro0.micro0.s14 s)
    (budget : s.next + 64 ≤ 2^64)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (exportEntry : notes.runtime.cells.cells 518 = some (.obj 2790))
    (namespaceEntry : notes.runtime.cells.cells Preparation28.address = some (.obj 607))
    (firstEntry : notes.runtime.cells.cells Preparation32.address = some (.obj initialObject32))
    (secondEntry : notes.runtime.cells.cells Preparation34.address = some (.obj initialObject34))
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (streamEntry : notes.runtime.cells.cells Parameter45.address = some (.handle defaultStreamHandle.toNat))
    (firstHandle : notes.privates.owners RetainedGetterBlocks.First130.sourceOwner =
      some ⟨RetainedGetterBlocks.First130.sourceBrand,RetainedGetterBlocks.First130.sourceHandleName,.handle 25732⟩)
    (secondHandle : notes.privates.owners RetainedGetterBlocks.Second187.sourceOwner =
      some ⟨RetainedGetterBlocks.Second187.sourceBrand,RetainedGetterBlocks.Second187.sourceHandleName,.handle 29363⟩) => by
  have earlier := through100 notes caller ν₀ ν C₀ C R FR live framed before after old old' s inst h inventory budget arrayLive arrayFixed exportEntry namespaceEntry firstEntry secondEntry functionLive functionFixed globalLive globalFixed streamEntry firstHandle secondHandle
  have post := Classical.choose_spec earlier
  have run := post.1
  have state := post.2.1
  have retained := post.2.2.1
  have instNext := post.2.2.2
  host_retained_plan_chain_after P.F, Plan100 using state, retained, instNext continuing_run run initial_relation h
host_assert_retained_schema through149, 135
end Host.Load.Run.Full.Ordinary.NamespacedMap
