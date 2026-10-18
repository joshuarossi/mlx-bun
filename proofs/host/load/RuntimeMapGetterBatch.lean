import host.load.RuntimeMapGuardBatch
import host.load.RuntimeGetterBlocks
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RetainedMapGetterBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open RetainedShapeBatch RetainedParameterBatch
host_source_step P.F, P.RestStream.micro0.micro1.s0 using P.RestStream.micro0.micro1.S0 to P.RestStream.micro0.micro1.s1 using P.RestStream.micro0.micro1.S1 as Step100
host_source_step P.F, P.RestStream.micro0.micro1.s1 using P.RestStream.micro0.micro1.S1 to P.RestStream.micro0.micro1.s2 using P.RestStream.micro0.micro1.S2 as Step101
host_source_step P.F, P.RestStream.micro0.micro1.s2 using P.RestStream.micro0.micro1.S2 to P.RestStream.micro0.micro1.s3 using P.RestStream.micro0.micro1.S3 as Step102
host_source_step P.F, P.RestStream.micro0.micro1.s3 using P.RestStream.micro0.micro1.S3 to P.RestStream.micro0.micro1.s4 using P.RestStream.micro0.micro1.S4 as Step103
host_source_step P.F, P.RestStream.micro0.micro1.s4 using P.RestStream.micro0.micro1.S4 to P.RestStream.micro0.micro1.s5 using P.RestStream.micro0.micro1.S5 as Step104
host_source_step P.F, P.RestStream.micro0.micro1.s5 using P.RestStream.micro0.micro1.S5 to P.RestStream.micro0.micro1.s6 using P.RestStream.micro0.micro1.S6 as Step105
host_source_step P.F, P.RestStream.micro0.micro1.s6 using P.RestStream.micro0.micro1.S6 to P.RestStream.micro0.micro1.s7 using P.RestStream.micro0.micro1.S7 as Step106
host_source_step P.F, P.RestStream.micro0.micro1.s7 using P.RestStream.micro0.micro1.S7 to P.RestStream.micro0.micro1.s8 using P.RestStream.micro0.micro1.S8 as Step107
host_source_step P.F, P.RestStream.micro0.micro1.s8 using P.RestStream.micro0.micro1.S8 to P.RestStream.micro0.micro1.s9 using P.RestStream.micro0.micro1.S9 as Step108
host_source_step P.F, P.RestStream.micro0.micro1.s9 using P.RestStream.micro0.micro1.S9 to P.RestStream.micro0.micro1.s10 using P.RestStream.micro0.micro1.S10 as Step109
host_source_step P.F, P.RestStream.micro0.micro1.s10 using P.RestStream.micro0.micro1.S10 to P.RestStream.micro0.micro1.s11 using P.RestStream.micro0.micro1.S11 as Step110
host_source_step P.F, P.RestStream.micro0.micro1.s11 using P.RestStream.micro0.micro1.S11 to P.RestStream.micro0.micro1.s12 using P.RestStream.micro0.micro1.S12 as Step111
host_source_step P.F, P.RestStream.micro0.micro1.s12 using P.RestStream.micro0.micro1.S12 to P.RestStream.micro0.micro1.s13 using P.RestStream.micro0.micro1.S13 as Step112
host_source_step P.F, P.RestStream.micro0.micro1.s13 using P.RestStream.micro0.micro1.S13 to P.RestStream.micro0.micro1.s14 using P.RestStream.micro0.micro1.S14 as Step113
host_source_step P.F, P.RestStream.micro0.micro1.s14 using P.RestStream.micro0.micro1.S14 to P.RestStream.micro0.micro1.s15 using P.RestStream.micro0.micro1.S15 as Step114
host_source_step P.F, P.RestStream.micro0.micro1.s15 using P.RestStream.micro0.micro1.S15 to P.RestStream.micro0.micro1.s16 using P.RestStream.micro0.micro1.S16 as Step115
host_source_step P.F, P.RestStream.micro0.micro1.s16 using P.RestStream.micro0.micro1.S16 to P.RestStream.micro0.micro1.s17 using P.RestStream.micro0.micro1.S17 as Step116
host_source_step P.F, P.RestStream.micro0.micro1.s17 using P.RestStream.micro0.micro1.S17 to P.RestStream.micro0.micro1.s18 using P.RestStream.micro0.micro1.S18 as Step117
host_source_step P.F, P.RestStream.micro0.micro1.s18 using P.RestStream.micro0.micro1.S18 to P.RestStream.micro0.micro1.s19 using P.RestStream.micro0.micro1.S19 as Step118
host_source_step P.F, P.RestStream.micro0.micro1.s19 using P.RestStream.micro0.micro1.S19 to P.RestStream.micro0.micro1.s20 using P.RestStream.micro0.micro1.S20 as Step119
host_source_step P.F, P.RestStream.micro0.micro1.s20 using P.RestStream.micro0.micro1.S20 to P.RestStream.micro0.micro1.s21 using P.RestStream.micro0.micro1.S21 as Step120
host_source_step P.F, P.RestStream.micro0.micro1.s21 using P.RestStream.micro0.micro1.S21 to P.RestStream.micro0.micro1.s22 using P.RestStream.micro0.micro1.S22 as Step121
host_source_step P.F, P.RestStream.micro0.micro1.s22 using P.RestStream.micro0.micro1.S22 to P.RestStream.micro0.micro1.s23 using P.RestStream.micro0.micro1.S23 as Step122
host_source_step P.F, P.RestStream.micro0.micro1.s23 using P.RestStream.micro0.micro1.S23 to P.RestStream.micro0.micro1.s24 using P.RestStream.micro0.micro1.S24 as Step123
host_source_step P.F, P.RestStream.micro0.micro1.s24 using P.RestStream.micro0.micro1.S24 to P.RestStream.micro0.micro1.s25 using P.RestStream.micro0.micro1.S25 as Step124
host_source_step P.F, P.RestStream.micro0.micro1.s25 using P.RestStream.micro0.micro1.S25 to P.RestStream.micro0.micro1.s26 using P.RestStream.micro0.micro1.S26 as Step125
host_source_step P.F, P.RestStream.micro0.micro1.s26 using P.RestStream.micro0.micro1.S26 to P.RestStream.micro0.micro1.s27 using P.RestStream.micro0.micro1.S27 as Step126
host_source_step P.F, P.RestStream.micro0.micro1.s27 using P.RestStream.micro0.micro1.S27 to P.RestStream.micro0.micro1.s28 using P.RestStream.micro0.micro1.S28 as Step127
host_source_step P.F, P.RestStream.micro0.micro1.s28 using P.RestStream.micro0.micro1.S28 to P.RestStream.micro0.micro1.s29 using P.RestStream.micro0.micro1.S29 as Step128
host_source_step P.F, P.RestStream.micro0.micro1.s29 using P.RestStream.micro0.micro1.S29 to P.RestStream.micro0.micro1.s30 using P.RestStream.micro0.micro1.S30 as Step129

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
  have earlier := RetainedMapGuardBatch.shape_to_map_guard notes caller ν₀ ν C₀ C R FR live framed
    before after old old' s inst h inventory budget arrayLive arrayFixed exportEntry namespaceEntry firstEntry secondEntry
    functionLive functionFixed globalLive globalFixed streamEntry
  have post100 := Classical.choose_spec earlier
  have run100 := post100.1
  have h100 := post100.2.1
  have inv100 := post100.2.2.1
  have inst100 := post100.2.2.2
  host_retained_chain_after P.F, [Step100.retained_transport,Step101.retained_transport,Step102.retained_transport,Step103.retained_transport,Step104.retained_transport,Step105.retained_transport,Step106.retained_transport,Step107.retained_transport,Step108.retained_transport,Step109.retained_transport,Step110.retained_transport,Step111.retained_transport,Step112.retained_transport,Step113.retained_transport,Step114.retained_transport,Step115.retained_transport,Step116.retained_transport,Step117.retained_transport,Step118.retained_transport,Step119.retained_transport,Step120.retained_transport,Step121.retained_transport,Step122.retained_transport,Step123.retained_transport,Step124.retained_transport,Step125.retained_transport,Step126.retained_transport,Step127.retained_transport,Step128.retained_transport,Step129.retained_transport,RetainedGetterBlocks.First130.retained_transport]
    using h100, inv100, inst100 continuing_run run100 initial_relation h
host_retained_theorem shape_to_first_handle := composed
host_assert_retained_schema shape_to_first_handle, 125
end Host.Load.Run.Full.Ordinary.RetainedMapGetterBatch

