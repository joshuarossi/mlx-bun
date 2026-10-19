import host.load.RuntimeNamespacedDecodeCachedNative
import host.load.RuntimePostCachedArrayJoined

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 2000000

namespace Host.Load.Run.Full.Ordinary.PostCachedArrayJoined
noncomputable def nextServer := CachedArrayEntry.nextServer
def span : Nat := 104
end Host.Load.Run.Full.Ordinary.PostCachedArrayJoined

namespace Host.Load.Run.Full.Ordinary.CachedCallArrayJoined
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi Host.Mlx.Ffi.NativeRoles Host.Mlx.Ffi.Annotated
open Host.Load.Run.Full.Ordinary.CachedCall Host.Load.Run.Full.Ordinary.CachedStrongHost

-- The replay's return annotation and new producer policy are derived by its
-- actual native step before the 104-step host continuation is applied.
host_retained_theorem retained_to_array_new := fun (notes : RetainedNotes)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (base : Nat → GraphNode) (objects : Nat → Object) (H frame roots : Nat → Prop)
    (tail : List NumV) (host : HostSt → HostSt → Prop)
    (live framed : Nat → Prop) (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ NamespacedDecode.Cached2382.initialServer C₀)
    (h : StateR (NumberRoles ν₀ ν C₀ C)
      (NativeRelation ν₀ ν C₀ C base objects H (fun i => N0 i ∨ frame i) tail host)
      R live framed before after old old' NamespacedDecode.Cached2382.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live NamespacedDecode.Cached2382.input s)
    (policy : ProducerAnnotations roots H (fun i => N0 i ∨ frame i)
      (roles (coupledRoles base)) objects)
    (budget : s.next+104 ≤ 2^64)
    (targetNodes : s.ffi.mlx.nnext + trace.order.length < 2^64)
    (targetHandles : s.ffi.mlx.next < 2^64)
    (signatureFrame : ¬ framed 4557) (closureLive : H 1354) (vectorLive : H 29376)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (fnRole thisRole : Annotated.Value)
    (entryCall : notes.runtime.control = callNote fnRole thisRole
      ((CachedFamilyHost.arguments 3126924 1354 29376).map FixedArgument.role))
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
  have heapBound : s.next < 2^64 := by omega
  host_retained_chain P.F,
    [NamespacedDecode.Cached2382.retained_transport,PostCachedArrayJoined.retained_to_array_new]
    using h, inventory, inst

host_assert_retained_schema retained_to_array_new, 105

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema retained_to_array_new, 104

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema retained_to_array_new, 106

theorem actual_entry : NamespacedDecode.Cached2382.input =
    P.RestStream.micro0.micro23.s82 := by host_kernel_rfl

theorem actual_exit : CachedArrayEntry.From2477.Cut.s10 =
    P.RestStream.micro0.micro24.s87 := by host_kernel_rfl

open Lean Elab Command Meta in
run_cmd liftTermElabM do
  forallTelescopeReducing (← getConstInfo ``retained_to_array_new).type fun args conclusion => do
    let conclusion ← whnf conclusion
    unless conclusion.isAppOfArity ``Exists 2 do throwError "cached join: missing reached state"
    withLocalDeclD `result conclusion.getAppArgs[0]! fun result => do
      let rec findState (type : Lean.Expr) : MetaM Lean.Expr := do
        let type ← whnf type
        if type.getAppFn.isConstOf ``Parametric.StateR then return type
        if type.isAppOfArity ``And 2 then
          try findState type.getAppArgs[0]! catch _ => findState type.getAppArgs[1]!
        else throwError "cached join: missing full state relation"
      let post ← findState (mkApp conclusion.getAppArgs[1]! result)
      let nodes ← withLocalDeclD `i (mkConst ``Nat) fun i => do
        mkLambdaFVars #[i] (← mkAppM ``Or #[mkApp (mkConst ``N3) i,mkApp args[9]! i])
      let expectedNative := mkAppN (mkConst ``NativeRelation) #[args[1]!,args[2]!,args[3]!,args[4]!,
        args[6]!,mkApp (mkConst ``outputObjectRoles) args[7]!,
        mkApp (mkConst ``PostCachedReturn.releasedHandles) args[8]!,nodes,args[11]!,args[12]!]
      unless ← isDefEq post.getAppArgs[2]! expectedNative do
        throwError "cached join: changed the expected strong native relation: {post.getAppArgs[2]!}"
      unless ← isDefEq post.getAppArgs[post.getAppArgs.size-2]!
          (mkConst ``CachedArrayEntry.From2477.Cut.s10) do
        throwError "cached join: wrong reached source"

end Host.Load.Run.Full.Ordinary.CachedCallArrayJoined
