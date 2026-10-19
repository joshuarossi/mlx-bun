import host.load.RuntimeCompiledArgumentEntryThrough279Entry
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 2000000
namespace Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

namespace Through106
noncomputable def rules := From64.rules.take 42
end Through106

host_retained_theorem retained_from64_to106 := fun (notes : RetainedNotes)
    (role cellRole receiverRole : Annotated.Value)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ From64.Span64.Block64.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region.s64 s)
    (inventory : RetainedInventory (Through64.notes notes role cellRole receiverRole) ν₀ ν C₀ C R live Region.s64 s)
    (metadata : NativeCaptureNote)
    (selected : notes.captures.owners From64.TypedCount106.address = some metadata)
    (codeNote : metadata.roles 0 = some (.literal (.lit From64.TypedCount106.codeLiteral)))
    (protoNote : metadata.roles 1 = some (.literal (.lit From64.TypedCount106.protoLiteral)))
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (protoLive : live From64.TypedCount106.protoIndex) (protoFixed : R.a From64.TypedCount106.protoIndex = From64.TypedCount106.protoIndex)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (budget : s.next+28 ≤ 2^64) => by
  host_normalize_retained state, inventory
  host_retained_plan_chain P.F, Through106 using state, inventory, inst
host_assert_retained_schema retained_from64_to106, 42

end Host.Load.Run.Full.Ordinary.CompiledArgumentEntry
