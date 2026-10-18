import host.load.RuntimeMapGetterBatch
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RetainedMapFirstPushBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open RetainedShapeBatch RetainedParameterBatch
host_source_step P.F, P.RestStream.micro0.micro1.s39 using P.RestStream.micro0.micro1.S39 to P.RestStream.micro0.micro1.s40 using P.RestStream.micro0.micro1.S40 as Step139
host_source_step P.F, P.RestStream.micro0.micro1.s40 using P.RestStream.micro0.micro1.S40 to P.RestStream.micro0.micro1.s41 using P.RestStream.micro0.micro1.S41 as Step140
host_source_step P.F, P.RestStream.micro0.micro1.s41 using P.RestStream.micro0.micro1.S41 to P.RestStream.micro0.micro1.s42 using P.RestStream.micro0.micro1.S42 as Step141
host_source_step P.F, P.RestStream.micro0.micro1.s42 using P.RestStream.micro0.micro1.S42 to P.RestStream.micro0.micro1.s43 using P.RestStream.micro0.micro1.S43 as Step142
host_source_step P.F, P.RestStream.micro0.micro1.s43 using P.RestStream.micro0.micro1.S43 to P.RestStream.micro0.micro1.s44 using P.RestStream.micro0.micro1.S44 as Step143
host_source_step P.F, P.RestStream.micro0.micro1.s44 using P.RestStream.micro0.micro1.S44 to P.RestStream.micro0.micro1.s45 using P.RestStream.micro0.micro1.S45 as Step144
host_source_step P.F, P.RestStream.micro0.micro1.s45 using P.RestStream.micro0.micro1.S45 to P.RestStream.micro0.micro1.s46 using P.RestStream.micro0.micro1.S46 as Step145
host_source_step P.F, P.RestStream.micro0.micro1.s46 using P.RestStream.micro0.micro1.S46 to P.RestStream.micro0.micro1.s47 using P.RestStream.micro0.micro1.S47 as Step146
host_source_step P.F, P.RestStream.micro0.micro1.s47 using P.RestStream.micro0.micro1.S47 to P.RestStream.micro0.micro1.s48 using P.RestStream.micro0.micro1.S48 as Step147
host_source_step P.F, P.RestStream.micro0.micro1.s48 using P.RestStream.micro0.micro1.S48 to P.RestStream.micro0.micro1.s49 using P.RestStream.micro0.micro1.S49 as Step148
host_source_step P.F, P.RestStream.micro0.micro1.s49 using P.RestStream.micro0.micro1.S49 to P.RestStream.micro0.micro1.s50 using P.RestStream.micro0.micro1.S50 as Step149
host_source_step P.F, P.RestStream.micro0.micro1.s50 using P.RestStream.micro0.micro1.S50 to P.RestStream.micro0.micro1.s51 using P.RestStream.micro0.micro1.S51 as Step150
host_source_step P.F, P.RestStream.micro0.micro1.s51 using P.RestStream.micro0.micro1.S51 to P.RestStream.micro0.micro1.s52 using P.RestStream.micro0.micro1.S52 as Step151
host_source_step P.F, P.RestStream.micro0.micro1.s52 using P.RestStream.micro0.micro1.S52 to P.RestStream.micro0.micro1.s53 using P.RestStream.micro0.micro1.S53 as Step152
host_source_step P.F, P.RestStream.micro0.micro1.s53 using P.RestStream.micro0.micro1.S53 to P.RestStream.micro0.micro1.s54 using P.RestStream.micro0.micro1.S54 as Step153
host_source_step P.F, P.RestStream.micro0.micro1.s54 using P.RestStream.micro0.micro1.S54 to P.RestStream.micro0.micro1.s55 using P.RestStream.micro0.micro1.S55 as Step154
host_source_step P.F, P.RestStream.micro0.micro1.s55 using P.RestStream.micro0.micro1.S55 to P.RestStream.micro0.micro1.s56 using P.RestStream.micro0.micro1.S56 as Step155
host_source_step P.F, P.RestStream.micro0.micro1.s56 using P.RestStream.micro0.micro1.S56 to P.RestStream.micro0.micro1.s57 using P.RestStream.micro0.micro1.S57 as Step156
host_source_step P.F, P.RestStream.micro0.micro1.s57 using P.RestStream.micro0.micro1.S57 to P.RestStream.micro0.micro1.s58 using P.RestStream.micro0.micro1.S58 as Step157
host_source_step P.F, P.RestStream.micro0.micro1.s58 using P.RestStream.micro0.micro1.S58 to P.RestStream.micro0.micro1.s59 using P.RestStream.micro0.micro1.S59 as Step158
host_source_step P.F, P.RestStream.micro0.micro1.s59 using P.RestStream.micro0.micro1.S59 to P.RestStream.micro0.micro1.s60 using P.RestStream.micro0.micro1.S60 as Step159
host_source_step P.F, P.RestStream.micro0.micro1.s60 using P.RestStream.micro0.micro1.S60 to P.RestStream.micro0.micro1.s61 using P.RestStream.micro0.micro1.S61 as Step160
host_source_step P.F, P.RestStream.micro0.micro1.s61 using P.RestStream.micro0.micro1.S61 to P.RestStream.micro0.micro1.s62 using P.RestStream.micro0.micro1.S62 as Step161
host_source_step P.F, P.RestStream.micro0.micro1.s62 using P.RestStream.micro0.micro1.S62 to P.RestStream.micro0.micro1.s63 using P.RestStream.micro0.micro1.S63 as Step162

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
      some ⟨RetainedGetterBlocks.First130.sourceBrand,RetainedGetterBlocks.First130.sourceHandleName,.handle 25732⟩) => by
  have earlier := RetainedMapGetterBatch.shape_to_first_handle notes caller ν₀ ν C₀ C R FR live framed
    before after old old' s inst h inventory budget arrayLive arrayFixed exportEntry namespaceEntry firstEntry secondEntry
    functionLive functionFixed globalLive globalFixed streamEntry firstHandle
  have post139 := Classical.choose_spec earlier
  have run139 := post139.1
  have h139 := post139.2.1
  have inv139 := post139.2.2.1
  have inst139 := post139.2.2.2
  host_retained_chain_after P.F, [Step139.retained_transport,Step140.retained_transport,Step141.retained_transport,Step142.retained_transport,Step143.retained_transport,Step144.retained_transport,Step145.retained_transport,Step146.retained_transport,Step147.retained_transport,Step148.retained_transport,Step149.retained_transport,Step150.retained_transport,Step151.retained_transport,Step152.retained_transport,Step153.retained_transport,Step154.retained_transport,Step155.retained_transport,Step156.retained_transport,Step157.retained_transport,Step158.retained_transport,Step159.retained_transport,Step160.retained_transport,Step161.retained_transport,Step162.retained_transport]
    using h139, inv139, inst139 continuing_run run139 initial_relation h
host_retained_theorem shape_to_second_callback := composed
host_assert_retained_schema shape_to_second_callback, 149
end Host.Load.Run.Full.Ordinary.RetainedMapFirstPushBatch

