import host.load.RuntimeMapSecondGetterBatch
import host.mlx.OrdinaryVectorStates
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RetainedMapArrayBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open RetainedShapeBatch RetainedParameterBatch
host_source_step P.F, P.RestStream.micro0.micro1.s96 using P.RestStream.micro0.micro1.S96 to P.RestStream.micro0.micro1.s97 using P.RestStream.micro0.micro1.S97 as Step196
host_source_step P.F, P.RestStream.micro0.micro1.s97 using P.RestStream.micro0.micro1.S97 to P.RestStream.micro0.micro1.s98 using P.RestStream.micro0.micro1.S98 as Step197
host_source_step P.F, P.RestStream.micro0.micro1.s98 using P.RestStream.micro0.micro1.S98 to P.RestStream.micro0.micro1.s99 using P.RestStream.micro0.micro1.S99 as Step198
host_source_step P.F, P.RestStream.micro0.micro1.s99 using P.RestStream.micro0.micro1.S99 to P.RestStream.micro0.micro1.s100 using P.RestStream.micro0.micro1.S100 as Step199
host_source_step P.F, P.RestStream.micro0.micro2.s0 using P.RestStream.micro0.micro2.S0 to P.RestStream.micro0.micro2.s1 using P.RestStream.micro0.micro2.S1 as Step200
host_source_step P.F, P.RestStream.micro0.micro2.s1 using P.RestStream.micro0.micro2.S1 to P.RestStream.micro0.micro2.s2 using P.RestStream.micro0.micro2.S2 as Step201
host_source_step P.F, P.RestStream.micro0.micro2.s2 using P.RestStream.micro0.micro2.S2 to P.RestStream.micro0.micro2.s3 using P.RestStream.micro0.micro2.S3 as Step202
host_source_step P.F, P.RestStream.micro0.micro2.s3 using P.RestStream.micro0.micro2.S3 to P.RestStream.micro0.micro2.s4 using P.RestStream.micro0.micro2.S4 as Step203
host_source_step P.F, P.RestStream.micro0.micro2.s4 using P.RestStream.micro0.micro2.S4 to P.RestStream.micro0.micro2.s5 using P.RestStream.micro0.micro2.S5 as Step204
host_source_step P.F, P.RestStream.micro0.micro2.s5 using P.RestStream.micro0.micro2.S5 to P.RestStream.micro0.micro2.s6 using P.RestStream.micro0.micro2.S6 as Step205
host_source_step P.F, P.RestStream.micro0.micro2.s6 using P.RestStream.micro0.micro2.S6 to P.RestStream.micro0.micro2.s7 using P.RestStream.micro0.micro2.S7 as Step206
host_source_step P.F, P.RestStream.micro0.micro2.s7 using P.RestStream.micro0.micro2.S7 to P.RestStream.micro0.micro2.s8 using P.RestStream.micro0.micro2.S8 as Step207
host_source_step P.F, P.RestStream.micro0.micro2.s8 using P.RestStream.micro0.micro2.S8 to P.RestStream.micro0.micro2.s9 using P.RestStream.micro0.micro2.S9 as Step208
host_source_step P.F, P.RestStream.micro0.micro2.s9 using P.RestStream.micro0.micro2.S9 to P.RestStream.micro0.micro2.s10 using P.RestStream.micro0.micro2.S10 as Step209
host_source_step P.F, P.RestStream.micro0.micro2.s10 using P.RestStream.micro0.micro2.S10 to P.RestStream.micro0.micro2.s11 using P.RestStream.micro0.micro2.S11 as Step210
host_source_step P.F, P.RestStream.micro0.micro2.s11 using P.RestStream.micro0.micro2.S11 to P.RestStream.micro0.micro2.s12 using P.RestStream.micro0.micro2.S12 as Step211
host_source_step P.F, P.RestStream.micro0.micro2.s12 using P.RestStream.micro0.micro2.S12 to P.RestStream.micro0.micro2.s13 using P.RestStream.micro0.micro2.S13 as Step212
host_source_step P.F, P.RestStream.micro0.micro2.s13 using P.RestStream.micro0.micro2.S13 to P.RestStream.micro0.micro2.s14 using P.RestStream.micro0.micro2.S14 as Step213
host_source_step P.F, P.RestStream.micro0.micro2.s14 using P.RestStream.micro0.micro2.S14 to P.RestStream.micro0.micro2.s15 using P.RestStream.micro0.micro2.S15 as Step214
host_source_step P.F, P.RestStream.micro0.micro2.s15 using P.RestStream.micro0.micro2.S15 to P.RestStream.micro0.micro2.s16 using P.RestStream.micro0.micro2.S16 as Step215
host_source_step P.F, P.RestStream.micro0.micro2.s16 using P.RestStream.micro0.micro2.S16 to P.RestStream.micro0.micro2.s17 using P.RestStream.micro0.micro2.S17 as Step216
host_source_step P.F, P.RestStream.micro0.micro2.s17 using P.RestStream.micro0.micro2.S17 to P.RestStream.micro0.micro2.s18 using P.RestStream.micro0.micro2.S18 as Step217
host_source_step P.F, P.RestStream.micro0.micro2.s18 using P.RestStream.micro0.micro2.S18 to P.RestStream.micro0.micro2.s19 using P.RestStream.micro0.micro2.S19 as Step218
host_source_step P.F, P.RestStream.micro0.micro2.s19 using P.RestStream.micro0.micro2.S19 to P.RestStream.micro0.micro2.s20 using P.RestStream.micro0.micro2.S20 as Step219
host_source_step P.F, P.RestStream.micro0.micro2.s20 using P.RestStream.micro0.micro2.S20 to P.RestStream.micro0.micro2.s21 using P.RestStream.micro0.micro2.S21 as Step220
host_source_step P.F, P.RestStream.micro0.micro2.s21 using P.RestStream.micro0.micro2.S21 to P.RestStream.micro0.micro2.s22 using P.RestStream.micro0.micro2.S22 as Step221
host_source_step P.F, P.RestStream.micro0.micro2.s22 using P.RestStream.micro0.micro2.S22 to P.RestStream.micro0.micro2.s23 using P.RestStream.micro0.micro2.S23 as Step222

host_retained_theorem composed := fun (notes : RetainedNotes) (caller : List Annotated.Tree) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ (numberServer P.RestStream.micro0.micro0.S14) C₀)
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
  have earlier := RetainedMapSecondGetterBatch.shape_to_second_handle notes caller ν₀ ν C₀ C R FR live framed
    before after old old' s inst h inventory budget arrayLive arrayFixed exportEntry namespaceEntry firstEntry secondEntry
    functionLive functionFixed globalLive globalFixed streamEntry firstHandle secondHandle
  have post196 := Classical.choose_spec earlier
  have run196 := post196.1
  have h196 := post196.2.1
  have inv196 := post196.2.2.1
  have inst196 := post196.2.2.2
  host_retained_chain_after P.F, [Step196.retained_transport,Step197.retained_transport,Step198.retained_transport,Step199.retained_transport,Step200.retained_transport,Step201.retained_transport,Step202.retained_transport,Step203.retained_transport,Step204.retained_transport,Step205.retained_transport,Step206.retained_transport,Step207.retained_transport,Step208.retained_transport,Step209.retained_transport,Step210.retained_transport,Step211.retained_transport,Step212.retained_transport,Step213.retained_transport,Step214.retained_transport,Step215.retained_transport,Step216.retained_transport,Step217.retained_transport,Step218.retained_transport,Step219.retained_transport,Step220.retained_transport,Step221.retained_transport,Step222.retained_transport]
    using h196, inv196, inst196 continuing_run run196 initial_relation h
host_retained_theorem shape_to_handle_array := composed
host_assert_retained_schema shape_to_handle_array, 209
end Host.Load.Run.Full.Ordinary.RetainedMapArrayBatch

