import host.load.RuntimeMapEntryBatch
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RetainedMapGuardBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open RetainedShapeBatch RetainedParameterBatch
host_source_step P.F, P.RestStream.micro0.micro0.s80 using P.RestStream.micro0.micro0.S80 to P.RestStream.micro0.micro0.s81 using P.RestStream.micro0.micro0.S81 as Step80
host_source_step P.F, P.RestStream.micro0.micro0.s81 using P.RestStream.micro0.micro0.S81 to P.RestStream.micro0.micro0.s82 using P.RestStream.micro0.micro0.S82 as Step81
host_source_step P.F, P.RestStream.micro0.micro0.s82 using P.RestStream.micro0.micro0.S82 to P.RestStream.micro0.micro0.s83 using P.RestStream.micro0.micro0.S83 as Step82
host_source_step P.F, P.RestStream.micro0.micro0.s83 using P.RestStream.micro0.micro0.S83 to P.RestStream.micro0.micro0.s84 using P.RestStream.micro0.micro0.S84 as Step83
host_source_step P.F, P.RestStream.micro0.micro0.s84 using P.RestStream.micro0.micro0.S84 to P.RestStream.micro0.micro0.s85 using P.RestStream.micro0.micro0.S85 as Step84
host_source_step P.F, P.RestStream.micro0.micro0.s85 using P.RestStream.micro0.micro0.S85 to P.RestStream.micro0.micro0.s86 using P.RestStream.micro0.micro0.S86 as Step85
host_source_step P.F, P.RestStream.micro0.micro0.s86 using P.RestStream.micro0.micro0.S86 to P.RestStream.micro0.micro0.s87 using P.RestStream.micro0.micro0.S87 as Step86
host_source_step P.F, P.RestStream.micro0.micro0.s87 using P.RestStream.micro0.micro0.S87 to P.RestStream.micro0.micro0.s88 using P.RestStream.micro0.micro0.S88 as Step87
host_source_step P.F, P.RestStream.micro0.micro0.s88 using P.RestStream.micro0.micro0.S88 to P.RestStream.micro0.micro0.s89 using P.RestStream.micro0.micro0.S89 as Step88
host_source_step P.F, P.RestStream.micro0.micro0.s89 using P.RestStream.micro0.micro0.S89 to P.RestStream.micro0.micro0.s90 using P.RestStream.micro0.micro0.S90 as Step89
host_source_step P.F, P.RestStream.micro0.micro0.s90 using P.RestStream.micro0.micro0.S90 to P.RestStream.micro0.micro0.s91 using P.RestStream.micro0.micro0.S91 as Step90
host_source_step P.F, P.RestStream.micro0.micro0.s91 using P.RestStream.micro0.micro0.S91 to P.RestStream.micro0.micro0.s92 using P.RestStream.micro0.micro0.S92 as Step91
host_source_step P.F, P.RestStream.micro0.micro0.s92 using P.RestStream.micro0.micro0.S92 to P.RestStream.micro0.micro0.s93 using P.RestStream.micro0.micro0.S93 as Step92
host_source_step P.F, P.RestStream.micro0.micro0.s93 using P.RestStream.micro0.micro0.S93 to P.RestStream.micro0.micro0.s94 using P.RestStream.micro0.micro0.S94 as Step93
host_source_step P.F, P.RestStream.micro0.micro0.s94 using P.RestStream.micro0.micro0.S94 to P.RestStream.micro0.micro0.s95 using P.RestStream.micro0.micro0.S95 as Step94
host_source_step P.F, P.RestStream.micro0.micro0.s95 using P.RestStream.micro0.micro0.S95 to P.RestStream.micro0.micro0.s96 using P.RestStream.micro0.micro0.S96 as Step95
host_source_step P.F, P.RestStream.micro0.micro0.s96 using P.RestStream.micro0.micro0.S96 to P.RestStream.micro0.micro0.s97 using P.RestStream.micro0.micro0.S97 as Step96
host_source_step P.F, P.RestStream.micro0.micro0.s97 using P.RestStream.micro0.micro0.S97 to P.RestStream.micro0.micro0.s98 using P.RestStream.micro0.micro0.S98 as Step97
host_source_step P.F, P.RestStream.micro0.micro0.s98 using P.RestStream.micro0.micro0.S98 to P.RestStream.micro0.micro0.s99 using P.RestStream.micro0.micro0.S99 as Step98
host_source_step P.F, P.RestStream.micro0.micro0.s99 using P.RestStream.micro0.micro0.S99 to P.RestStream.micro0.micro0.s100 using P.RestStream.micro0.micro0.S100 as Step99

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
    (streamEntry : notes.runtime.cells.cells Parameter45.address = some (.handle defaultStreamHandle.toNat)) => by
  have earlier := RetainedMapEntryBatch.shape_to_map_setup notes caller ν₀ ν C₀ C R FR live framed
    before after old old' s inst h inventory budget arrayLive arrayFixed exportEntry namespaceEntry firstEntry secondEntry
    functionLive functionFixed globalLive globalFixed streamEntry
  have post80 := Classical.choose_spec earlier
  have run80 := post80.1
  have h80 := post80.2.1
  have inv80 := post80.2.2.1
  have inst80 := post80.2.2.2
  host_retained_chain_after P.F, [Step80.retained_transport,Step81.retained_transport,Step82.retained_transport,Step83.retained_transport,Step84.retained_transport,Step85.retained_transport,Step86.retained_transport,Step87.retained_transport,Step88.retained_transport,Step89.retained_transport,Step90.retained_transport,Step91.retained_transport,Step92.retained_transport,Step93.retained_transport,Step94.retained_transport,Step95.retained_transport,Step96.retained_transport,Step97.retained_transport,Step98.retained_transport,Step99.retained_transport]
    using h80, inv80, inst80 continuing_run run80 initial_relation h
host_retained_theorem shape_to_map_guard := composed
host_assert_retained_schema shape_to_map_guard, 86
end Host.Load.Run.Full.Ordinary.RetainedMapGuardBatch
