import host.load.RuntimePostCachedReturn
import host.load.RuntimeCachedArrayEntry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 0
namespace Host.Load.Run.Full.Ordinary.CachedArrayEntry
-- Checked endpoint server used by the retained-chain adapter.
noncomputable def nextServer := From2477.Cut.S10
def span : Nat := 40
end Host.Load.Run.Full.Ordinary.CachedArrayEntry

namespace Host.Load.Run.Full.Ordinary.PostCachedArrayJoined
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated
open Host.Load.Run.Full.Ordinary.CachedCall Host.Load.Run.Full.Ordinary.CachedStrongHost

/- Join the actual cached return, vector release/size and array-slot setup.
Only current source2383 roles are supplied; the new count/control notes at2447
must be derived by the first interval before the second is applied. -/
host_retained_theorem retained_to_array_new := fun (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (objects : Nat → Object) (H frame roots : Nat → Prop)
    (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ PostCachedReturn.BeforeFree.Block0.initialServer C₀)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (NativeRelation ν₀ ν C₀ C base (outputObjectRoles objects) H (fun i => N3 i ∨ frame i) tail host)
      R live framed before after old old' PostCachedReturn.From2383.s0 s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live PostCachedReturn.From2383.s0 s)
    (policy : ProducerAnnotations roots H (fun i => N3 i ∨ frame i)
      (roles (coupledRoles base)) (outputObjectRoles objects))
    (budget : s.next+104 ≤ 2^64)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (entryReturn : notes.runtime.control = returnNote nativeStatusRole)
    (slotPointer : notes.runtime.cells.cells 3126903 = some (.ptr (.js 3126924) 0))
    (inputVector : notes.runtime.cells.cells 3126901 = some (.handle 29376))
    (outputSlot : notes.buffers.owners 3126924 = some (handleSlotNotes 29377))
    (freeFrame : ¬ framed 4413) (sizeFrame : ¬ framed 4571) (outputLive : H 29377)
    (metadata : NativeCaptureNote)
    (selected : notes.captures.owners CachedArrayEntry.Allocation.address = some metadata)
    (codeNote : metadata.roles 0 = some (.literal (.lit CachedArrayEntry.Allocation.codeLiteral)))
    (protoNote : metadata.roles 1 = some (.literal (.lit CachedArrayEntry.Allocation.protoLiteral)))
    (bufferProtoLive : live aArrayBufferProto) (bufferProtoFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (protoLive : live CachedArrayEntry.Allocation.protoIndex)
    (protoFixed : R.a CachedArrayEntry.Allocation.protoIndex = CachedArrayEntry.Allocation.protoIndex) => by
  have completed := PostCachedReturn.retained_run64 notes ν₀ ν C₀ C R base objects H frame roots tail host
    live framed before after old old' s inst h inventory policy (by omega)
    arrayLive arrayFixed globalLive globalFixed entryReturn slotPointer inputVector outputSlot freeFrame sizeFrame outputLive
  have post := Classical.choose_spec completed
  have previous := post.1
  have reached := post.2.1
  have retained := post.2.2.1
  have sourceInst := post.2.2.2
  host_normalize_retained reached, retained
  host_retained_chain_after P.F, [CachedArrayEntry.retained_to_array_new] using reached, retained, sourceInst
    continuing_run previous initial_relation h
host_assert_retained_schema retained_to_array_new, 104

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema retained_to_array_new, 103

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema retained_to_array_new, 105

end Host.Load.Run.Full.Ordinary.PostCachedArrayJoined
