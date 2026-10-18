import host.load.RuntimeParameterBatch
import host.ts.renameOrdinary.DriverParameters
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RetainedConcatBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open RetainedShapeBatch RetainedParameterBatch
host_source_step P.F, P.RestStream.micro0.micro0.s49 using P.RestStream.micro0.micro0.S49 to P.RestStream.micro0.micro0.s50 using P.RestStream.micro0.micro0.S50 as Step49
host_source_step P.F, P.RestStream.micro0.micro0.s50 using P.RestStream.micro0.micro0.S50 to P.RestStream.micro0.micro0.s51 using P.RestStream.micro0.micro0.S51 as Step50
host_source_step P.F, P.RestStream.micro0.micro0.s51 using P.RestStream.micro0.micro0.S51 to P.RestStream.micro0.micro0.s52 using P.RestStream.micro0.micro0.S52 as Step51
host_source_step P.F, P.RestStream.micro0.micro0.s52 using P.RestStream.micro0.micro0.S52 to P.RestStream.micro0.micro0.s53 using P.RestStream.micro0.micro0.S53 as Step52
host_source_step P.F, P.RestStream.micro0.micro0.s53 using P.RestStream.micro0.micro0.S53 to P.RestStream.micro0.micro0.s54 using P.RestStream.micro0.micro0.S54 as Step53
host_source_step P.F, P.RestStream.micro0.micro0.s54 using P.RestStream.micro0.micro0.S54 to P.RestStream.micro0.micro0.s55 using P.RestStream.micro0.micro0.S55 as Step54
host_source_step P.F, P.RestStream.micro0.micro0.s55 using P.RestStream.micro0.micro0.S55 to P.RestStream.micro0.micro0.s56 using P.RestStream.micro0.micro0.S56 as Step55
host_source_step P.F, P.RestStream.micro0.micro0.s56 using P.RestStream.micro0.micro0.S56 to P.RestStream.micro0.micro0.s57 using P.RestStream.micro0.micro0.S57 as Step56
host_source_step P.F, P.RestStream.micro0.micro0.s57 using P.RestStream.micro0.micro0.S57 to P.RestStream.micro0.micro0.s58 using P.RestStream.micro0.micro0.S58 as Step57
host_source_step P.F, P.RestStream.micro0.micro0.s58 using P.RestStream.micro0.micro0.S58 to P.RestStream.micro0.micro0.s59 using P.RestStream.micro0.micro0.S59 as Step58
host_source_step P.F, P.RestStream.micro0.micro0.s59 using P.RestStream.micro0.micro0.S59 to P.RestStream.micro0.micro0.s60 using P.RestStream.micro0.micro0.S60 as Step59
host_source_step P.F, P.RestStream.micro0.micro0.s60 using P.RestStream.micro0.micro0.S60 to P.RestStream.micro0.micro0.s61 using P.RestStream.micro0.micro0.S61 as Step60
host_source_step P.F, P.RestStream.micro0.micro0.s61 using P.RestStream.micro0.micro0.S61 to P.RestStream.micro0.micro0.s62 using P.RestStream.micro0.micro0.S62 as Step61
host_source_step P.F, P.RestStream.micro0.micro0.s62 using P.RestStream.micro0.micro0.S62 to P.RestStream.micro0.micro0.s63 using P.RestStream.micro0.micro0.S63 as Step62
host_source_step P.F, P.RestStream.micro0.micro0.s63 using P.RestStream.micro0.micro0.S63 to P.RestStream.micro0.micro0.s64 using P.RestStream.micro0.micro0.S64 as Step63

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
  have earlier := RetainedParameterBatch.shape_to_body notes caller ν₀ ν C₀ C R FR live framed
    before after old old' s inst h inventory budget arrayLive arrayFixed exportEntry namespaceEntry firstEntry secondEntry
    functionLive functionFixed globalLive globalFixed streamEntry
  have post49 := Classical.choose_spec earlier
  have run49 := post49.1
  have h49 := post49.2.1
  have inv49 := post49.2.2.1
  have inst49 := post49.2.2.2
  host_retained_chain_after P.F, [Step49.retained_transport,Step50.retained_transport,Step51.retained_transport,Step52.retained_transport,Step53.retained_transport,Step54.retained_transport,Step55.retained_transport,Step56.retained_transport,Step57.retained_transport,Step58.retained_transport,Step59.retained_transport,Step60.retained_transport,Step61.retained_transport,Step62.retained_transport,Step63.retained_transport]
    using h49, inv49, inst49 continuing_run run49 initial_relation h
host_retained_theorem shape_to_callback := composed
host_assert_retained_schema shape_to_callback, 50
end Host.Load.Run.Full.Ordinary.RetainedConcatBatch
