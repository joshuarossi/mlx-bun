import host.load.RuntimeConcatBatch
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RetainedMapEntryBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open RetainedShapeBatch RetainedParameterBatch
host_source_step P.F, P.RestStream.micro0.micro0.s64 using P.RestStream.micro0.micro0.S64 to P.RestStream.micro0.micro0.s65 using P.RestStream.micro0.micro0.S65 as Step64
host_source_step P.F, P.RestStream.micro0.micro0.s65 using P.RestStream.micro0.micro0.S65 to P.RestStream.micro0.micro0.s66 using P.RestStream.micro0.micro0.S66 as Step65
host_source_step P.F, P.RestStream.micro0.micro0.s66 using P.RestStream.micro0.micro0.S66 to P.RestStream.micro0.micro0.s67 using P.RestStream.micro0.micro0.S67 as Step66
host_source_step P.F, P.RestStream.micro0.micro0.s67 using P.RestStream.micro0.micro0.S67 to P.RestStream.micro0.micro0.s68 using P.RestStream.micro0.micro0.S68 as Step67
host_source_step P.F, P.RestStream.micro0.micro0.s68 using P.RestStream.micro0.micro0.S68 to P.RestStream.micro0.micro0.s69 using P.RestStream.micro0.micro0.S69 as Step68
host_source_step P.F, P.RestStream.micro0.micro0.s69 using P.RestStream.micro0.micro0.S69 to P.RestStream.micro0.micro0.s70 using P.RestStream.micro0.micro0.S70 as Step69
host_source_step P.F, P.RestStream.micro0.micro0.s70 using P.RestStream.micro0.micro0.S70 to P.RestStream.micro0.micro0.s71 using P.RestStream.micro0.micro0.S71 as Step70
host_source_step P.F, P.RestStream.micro0.micro0.s71 using P.RestStream.micro0.micro0.S71 to P.RestStream.micro0.micro0.s72 using P.RestStream.micro0.micro0.S72 as Step71
host_source_step P.F, P.RestStream.micro0.micro0.s72 using P.RestStream.micro0.micro0.S72 to P.RestStream.micro0.micro0.s73 using P.RestStream.micro0.micro0.S73 as Step72
host_source_step P.F, P.RestStream.micro0.micro0.s73 using P.RestStream.micro0.micro0.S73 to P.RestStream.micro0.micro0.s74 using P.RestStream.micro0.micro0.S74 as Step73
host_source_step P.F, P.RestStream.micro0.micro0.s74 using P.RestStream.micro0.micro0.S74 to P.RestStream.micro0.micro0.s75 using P.RestStream.micro0.micro0.S75 as Step74
host_source_step P.F, P.RestStream.micro0.micro0.s75 using P.RestStream.micro0.micro0.S75 to P.RestStream.micro0.micro0.s76 using P.RestStream.micro0.micro0.S76 as Step75
host_source_step P.F, P.RestStream.micro0.micro0.s76 using P.RestStream.micro0.micro0.S76 to P.RestStream.micro0.micro0.s77 using P.RestStream.micro0.micro0.S77 as Step76
host_source_step P.F, P.RestStream.micro0.micro0.s77 using P.RestStream.micro0.micro0.S77 to P.RestStream.micro0.micro0.s78 using P.RestStream.micro0.micro0.S78 as Step77
host_source_step P.F, P.RestStream.micro0.micro0.s78 using P.RestStream.micro0.micro0.S78 to P.RestStream.micro0.micro0.s79 using P.RestStream.micro0.micro0.S79 as Step78
host_source_step P.F, P.RestStream.micro0.micro0.s79 using P.RestStream.micro0.micro0.S79 to P.RestStream.micro0.micro0.s80 using P.RestStream.micro0.micro0.S80 as Step79

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
  have earlier := RetainedConcatBatch.shape_to_callback notes caller ν₀ ν C₀ C R FR live framed
    before after old old' s inst h inventory budget arrayLive arrayFixed exportEntry namespaceEntry firstEntry secondEntry
    functionLive functionFixed globalLive globalFixed streamEntry
  have post64 := Classical.choose_spec earlier
  have run64 := post64.1
  have h64 := post64.2.1
  have inv64 := post64.2.2.1
  have inst64 := post64.2.2.2
  host_retained_chain_after P.F, [Step64.retained_transport,Step65.retained_transport,Step66.retained_transport,Step67.retained_transport,Step68.retained_transport,Step69.retained_transport,Step70.retained_transport,Step71.retained_transport,Step72.retained_transport,Step73.retained_transport,Step74.retained_transport,Step75.retained_transport,Step76.retained_transport,Step77.retained_transport,Step78.retained_transport,Step79.retained_transport]
    using h64, inv64, inst64 continuing_run run64 initial_relation h
host_retained_theorem shape_to_map_setup := composed
host_assert_retained_schema shape_to_map_setup, 66
end Host.Load.Run.Full.Ordinary.RetainedMapEntryBatch
