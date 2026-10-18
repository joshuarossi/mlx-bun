import host.load.RuntimeMapFirstPushBatch
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
set_option Elab.async false
namespace Host.Load.Run.Full.Ordinary.RetainedMapSecondGetterBatch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open RetainedShapeBatch RetainedParameterBatch
host_source_step P.F, P.RestStream.micro0.micro1.s63 using P.RestStream.micro0.micro1.S63 to P.RestStream.micro0.micro1.s64 using P.RestStream.micro0.micro1.S64 as Step163
host_source_step P.F, P.RestStream.micro0.micro1.s64 using P.RestStream.micro0.micro1.S64 to P.RestStream.micro0.micro1.s65 using P.RestStream.micro0.micro1.S65 as Step164
host_source_step P.F, P.RestStream.micro0.micro1.s65 using P.RestStream.micro0.micro1.S65 to P.RestStream.micro0.micro1.s66 using P.RestStream.micro0.micro1.S66 as Step165
host_source_step P.F, P.RestStream.micro0.micro1.s66 using P.RestStream.micro0.micro1.S66 to P.RestStream.micro0.micro1.s67 using P.RestStream.micro0.micro1.S67 as Step166
host_source_step P.F, P.RestStream.micro0.micro1.s67 using P.RestStream.micro0.micro1.S67 to P.RestStream.micro0.micro1.s68 using P.RestStream.micro0.micro1.S68 as Step167
host_source_step P.F, P.RestStream.micro0.micro1.s68 using P.RestStream.micro0.micro1.S68 to P.RestStream.micro0.micro1.s69 using P.RestStream.micro0.micro1.S69 as Step168
host_source_step P.F, P.RestStream.micro0.micro1.s69 using P.RestStream.micro0.micro1.S69 to P.RestStream.micro0.micro1.s70 using P.RestStream.micro0.micro1.S70 as Step169
host_source_step P.F, P.RestStream.micro0.micro1.s70 using P.RestStream.micro0.micro1.S70 to P.RestStream.micro0.micro1.s71 using P.RestStream.micro0.micro1.S71 as Step170
host_source_step P.F, P.RestStream.micro0.micro1.s71 using P.RestStream.micro0.micro1.S71 to P.RestStream.micro0.micro1.s72 using P.RestStream.micro0.micro1.S72 as Step171
host_source_step P.F, P.RestStream.micro0.micro1.s72 using P.RestStream.micro0.micro1.S72 to P.RestStream.micro0.micro1.s73 using P.RestStream.micro0.micro1.S73 as Step172
host_source_step P.F, P.RestStream.micro0.micro1.s73 using P.RestStream.micro0.micro1.S73 to P.RestStream.micro0.micro1.s74 using P.RestStream.micro0.micro1.S74 as Step173
host_source_step P.F, P.RestStream.micro0.micro1.s74 using P.RestStream.micro0.micro1.S74 to P.RestStream.micro0.micro1.s75 using P.RestStream.micro0.micro1.S75 as Step174
host_source_step P.F, P.RestStream.micro0.micro1.s75 using P.RestStream.micro0.micro1.S75 to P.RestStream.micro0.micro1.s76 using P.RestStream.micro0.micro1.S76 as Step175
host_source_step P.F, P.RestStream.micro0.micro1.s76 using P.RestStream.micro0.micro1.S76 to P.RestStream.micro0.micro1.s77 using P.RestStream.micro0.micro1.S77 as Step176
host_source_step P.F, P.RestStream.micro0.micro1.s77 using P.RestStream.micro0.micro1.S77 to P.RestStream.micro0.micro1.s78 using P.RestStream.micro0.micro1.S78 as Step177
host_source_step P.F, P.RestStream.micro0.micro1.s78 using P.RestStream.micro0.micro1.S78 to P.RestStream.micro0.micro1.s79 using P.RestStream.micro0.micro1.S79 as Step178
host_source_step P.F, P.RestStream.micro0.micro1.s79 using P.RestStream.micro0.micro1.S79 to P.RestStream.micro0.micro1.s80 using P.RestStream.micro0.micro1.S80 as Step179
host_source_step P.F, P.RestStream.micro0.micro1.s80 using P.RestStream.micro0.micro1.S80 to P.RestStream.micro0.micro1.s81 using P.RestStream.micro0.micro1.S81 as Step180
host_source_step P.F, P.RestStream.micro0.micro1.s81 using P.RestStream.micro0.micro1.S81 to P.RestStream.micro0.micro1.s82 using P.RestStream.micro0.micro1.S82 as Step181
host_source_step P.F, P.RestStream.micro0.micro1.s82 using P.RestStream.micro0.micro1.S82 to P.RestStream.micro0.micro1.s83 using P.RestStream.micro0.micro1.S83 as Step182
host_source_step P.F, P.RestStream.micro0.micro1.s83 using P.RestStream.micro0.micro1.S83 to P.RestStream.micro0.micro1.s84 using P.RestStream.micro0.micro1.S84 as Step183
host_source_step P.F, P.RestStream.micro0.micro1.s84 using P.RestStream.micro0.micro1.S84 to P.RestStream.micro0.micro1.s85 using P.RestStream.micro0.micro1.S85 as Step184
host_source_step P.F, P.RestStream.micro0.micro1.s85 using P.RestStream.micro0.micro1.S85 to P.RestStream.micro0.micro1.s86 using P.RestStream.micro0.micro1.S86 as Step185
host_source_step P.F, P.RestStream.micro0.micro1.s86 using P.RestStream.micro0.micro1.S86 to P.RestStream.micro0.micro1.s87 using P.RestStream.micro0.micro1.S87 as Step186

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
  have earlier := RetainedMapFirstPushBatch.shape_to_second_callback notes caller ν₀ ν C₀ C R FR live framed
    before after old old' s inst h inventory budget arrayLive arrayFixed exportEntry namespaceEntry firstEntry secondEntry
    functionLive functionFixed globalLive globalFixed streamEntry firstHandle
  have post163 := Classical.choose_spec earlier
  have run163 := post163.1
  have h163 := post163.2.1
  have inv163 := post163.2.2.1
  have inst163 := post163.2.2.2
  host_retained_chain_after P.F, [Step163.retained_transport,Step164.retained_transport,Step165.retained_transport,Step166.retained_transport,Step167.retained_transport,Step168.retained_transport,Step169.retained_transport,Step170.retained_transport,Step171.retained_transport,Step172.retained_transport,Step173.retained_transport,Step174.retained_transport,Step175.retained_transport,Step176.retained_transport,Step177.retained_transport,Step178.retained_transport,Step179.retained_transport,Step180.retained_transport,Step181.retained_transport,Step182.retained_transport,Step183.retained_transport,Step184.retained_transport,Step185.retained_transport,Step186.retained_transport,RetainedGetterBlocks.Second187.retained_transport]
    using h163, inv163, inst163 continuing_run run163 initial_relation h
host_retained_theorem shape_to_second_handle := composed
host_assert_retained_schema shape_to_second_handle, 182
end Host.Load.Run.Full.Ordinary.RetainedMapSecondGetterBatch

