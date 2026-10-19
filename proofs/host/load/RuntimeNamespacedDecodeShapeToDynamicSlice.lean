import host.load.RuntimeNamespacedDecodePlan1331
import host.ts.renameOrdinary.RankOriginInitializedCacheShapePointerEntry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles

noncomputable def ShapeBufferEntry.rules := [``Meta1330.retained_transport] ++
  (Plan1331.rules.zip Plan1331.starts).filterMap (fun entry => if entry.2 < 22 then some entry.1 else none)

host_retained_theorem shape_to_buffer := fun
    (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (boundary : Nat → Prop) (objects : Nat → Object) (H N : Nat → Prop)
    (tail : List NumV) (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Meta1330.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C RankOrigin.InitializedCacheSlice.roles boundary objects H N tail host)
      R live framed before after old old' At1330.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheShapePointerEntry.resultNotes notes caller)
      ν₀ ν C₀ C R live At1330.s0 s)
    (budget : s.next+32 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 21) (typedFixed : R.a 21 = 21)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (signatureFrame : ¬ framed Meta1330.types)
    (owned : H Meta1330.handle) (region : R.region (4*Meta1330.handle) = 4*R.handle Meta1330.handle)
    (capture : notes.captures.owners 90 = some RankOrigin.InitialRetained.constructorMetadata) => by
  host_normalize_retained state, inventory
  host_retained_plan_chain P.F, ShapeBufferEntry using state, inventory, inst

host_assert_retained_schema shape_to_buffer, 23
/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema shape_to_buffer, 24

host_retained_theorem shape_to_spread := fun
    (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (boundary : Nat → Prop) (objects : Nat → Object) (H N : Nat → Prop)
    (tail : List NumV) (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Meta1330.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C RankOrigin.InitializedCacheSlice.roles boundary objects H N tail host)
      R live framed before after old old' At1330.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheShapePointerEntry.resultNotes notes caller)
      ν₀ ν C₀ C R live At1330.s0 s)
    (budget : s.next+32 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 21) (typedFixed : R.a 21 = 21)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (signatureFrame : ¬ framed Meta1330.types)
    (owned : H Meta1330.handle) (region : R.region (4*Meta1330.handle) = 4*R.handle Meta1330.handle)
    (capture : notes.captures.owners 90 = some RankOrigin.InitialRetained.constructorMetadata) => by
  have earlier := shape_to_buffer notes caller ν₀ ν C₀ C R boundary objects H N tail host live framed before after old old' s inst state inventory
    budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed bufferLive bufferFixed
    typedLive typedFixed globalLive globalFixed signatureFrame owned region capture
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  have offsetClosed (valuation : Nat → F64) :
      (SymE.lit (F64.zero false)).eval valuation = Plan1331.Block22.offset := rfl
  have countClosed (valuation : Nat → F64) :
      (SymE.bin Plan1331.Block20.kind.numOp
        (.lit (F64.ofInt (Int.ofNat (len Meta1285.node.shape))))
        (.lit (F64.fin false 4 (Int.ofNat 0)))).eval valuation = Plan1331.Block22.count := by
    host_kernel_rfl
  host_normalize_retained stateNext, retainedNext
  host_retained_chain_after P.F, [Plan1331.Block22.retained_transport, Plan1331.Block23.retained_transport, Plan1331.Block24.retained_transport] using stateNext, retainedNext, instNext continuing_run run initial_relation state

host_assert_retained_schema shape_to_spread, 26

host_retained_theorem shape_to_dynamic_slice := fun
    (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (boundary : Nat → Prop) (objects : Nat → Object) (H N : Nat → Prop)
    (tail : List NumV) (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Meta1330.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C RankOrigin.InitializedCacheSlice.roles boundary objects H N tail host)
      R live framed before after old old' At1330.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheShapePointerEntry.resultNotes notes caller)
      ν₀ ν C₀ C R live At1330.s0 s)
    (budget : s.next+32 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 21) (typedFixed : R.a 21 = 21)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (signatureFrame : ¬ framed Meta1330.types)
    (owned : H Meta1330.handle) (region : R.region (4*Meta1330.handle) = 4*R.handle Meta1330.handle)
    (capture : notes.captures.owners 90 = some RankOrigin.InitialRetained.constructorMetadata) => by
  have earlier := shape_to_spread notes caller ν₀ ν C₀ C R boundary objects H N tail host live framed before after old old' s inst state inventory
    budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed bufferLive bufferFixed
    typedLive typedFixed globalLive globalFixed signatureFrame owned region capture
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  have native := stateNext.native.2
  host_normalize_retained stateNext, retainedNext
  host_retained_chain_after P.F, [Plan1331.Block25.retained_transport, Plan1331.Block26.retained_transport, Plan1331.Block27.retained_transport, Plan1331.Block28.retained_transport, Plan1331.Block29.retained_transport, Plan1331.Block30.retained_transport] using stateNext, retainedNext, instNext continuing_run run initial_relation state

host_assert_retained_schema shape_to_dynamic_slice, 32

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema shape_to_dynamic_slice, 33

end Host.Load.Run.Full.Ordinary.NamespacedDecode
