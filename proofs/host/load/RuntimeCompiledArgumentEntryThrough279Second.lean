import host.load.RuntimeCompiledArgumentEntryThrough279FirstStore
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 2000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

namespace Through279Second
noncomputable def rules := ((From64.starts.zip From64.rules).filter (fun pair => 156 ≤ pair.1 ∧ pair.1 < 170)).map Prod.snd
end Through279Second

host_retained_theorem retained_from156_to170 := fun (notes : RetainedNotes)
    (role cellRole receiverRole : Annotated.Value)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ From64.Span156.Block156.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s156 s)
    (inventory : RetainedInventory (Through156.notes notes role cellRole receiverRole) ν₀ ν C₀ C R live Region.s156 s)
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
    (allocatedBufferBound : R.a From64.TypedStore155.buffer < 2^64)
    (budget : s.next+8 ≤ 2^64) => by
  host_normalize_retained state, inventory
  host_retained_plan_chain P.F, Through279Second using state, inventory, inst
host_assert_retained_schema retained_from156_to170, 14

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
