import host.load.RuntimeNamespacedDecodePlan1438
import host.ts.renameOrdinary.RankOriginInitializedCacheDynamicSliceAllocationEntry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles

noncomputable def DynamicCall3.rules :=
  (Plan1438.rules.zip Plan1438.starts).filterMap (fun entry => if 0 ≤ entry.2 && entry.2 < 3 then some entry.1 else none)

host_retained_theorem allocation_to_dynamic_3 := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (boundary : Nat → Prop) (objects : Nat → Object) (H N : Nat → Prop)
    (tail : List NumV) (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan1438.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C RankOrigin.InitializedCacheSlice.roles boundary objects H N tail host)
      R live framed before after old old' Region1438.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheDynamicSliceAllocationEntry.resultNotes notes caller)
      ν₀ ν C₀ C R live Region1438.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 26) (typedFixed : R.a 26 = 26)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (signatureFrame : ¬ framed Plan1438.Block0.types)
    (startNote : notes.privates.owners 2674420 = some ⟨4852,chars!"handle",.handle 18170⟩)
    (capture : notes.captures.owners 95 = some RankOrigin.InitializedHandleBuffer.constructorMetadata) => by
  host_normalize_retained state, inventory
  host_retained_plan_chain P.F, DynamicCall3 using state, inventory, inst

host_assert_retained_schema allocation_to_dynamic_3, 3

noncomputable def DynamicCall4.rules :=
  (Plan1438.rules.zip Plan1438.starts).filterMap (fun entry => if 3 ≤ entry.2 && entry.2 < 4 then some entry.1 else none)

host_retained_theorem allocation_to_dynamic_4 := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (boundary : Nat → Prop) (objects : Nat → Object) (H N : Nat → Prop)
    (tail : List NumV) (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan1438.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C RankOrigin.InitializedCacheSlice.roles boundary objects H N tail host)
      R live framed before after old old' Region1438.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheDynamicSliceAllocationEntry.resultNotes notes caller)
      ν₀ ν C₀ C R live Region1438.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 26) (typedFixed : R.a 26 = 26)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (signatureFrame : ¬ framed Plan1438.Block0.types)
    (startNote : notes.privates.owners 2674420 = some ⟨4852,chars!"handle",.handle 18170⟩)
    (capture : notes.captures.owners 95 = some RankOrigin.InitializedHandleBuffer.constructorMetadata) => by
  have earlier := allocation_to_dynamic_3 notes caller ν₀ ν C₀ C R boundary objects H N tail host live framed before after old old' s inst state inventory budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed bufferLive bufferFixed typedLive typedFixed globalLive globalFixed signatureFrame startNote capture
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  have room := chain_next_budget_le state stateNext
    (Plan1438.Block2.output.next - Region1438.s0.next) 2 64 (2^64)
    (by decide +kernel) (by decide +kernel) budget
  have native := stateNext.native.2
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, DynamicCall4 using stateNext, retainedNext, instNext continuing_run run initial_relation state

host_assert_retained_schema allocation_to_dynamic_4, 4

noncomputable def DynamicCall25.rules :=
  (Plan1438.rules.zip Plan1438.starts).filterMap (fun entry => if 4 ≤ entry.2 && entry.2 < 25 then some entry.1 else none)

host_retained_theorem allocation_to_dynamic_25 := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (boundary : Nat → Prop) (objects : Nat → Object) (H N : Nat → Prop)
    (tail : List NumV) (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan1438.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C RankOrigin.InitializedCacheSlice.roles boundary objects H N tail host)
      R live framed before after old old' Region1438.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheDynamicSliceAllocationEntry.resultNotes notes caller)
      ν₀ ν C₀ C R live Region1438.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 26) (typedFixed : R.a 26 = 26)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (signatureFrame : ¬ framed Plan1438.Block0.types)
    (startNote : notes.privates.owners 2674420 = some ⟨4852,chars!"handle",.handle 18170⟩)
    (capture : notes.captures.owners 95 = some RankOrigin.InitializedHandleBuffer.constructorMetadata) => by
  have earlier := allocation_to_dynamic_4 notes caller ν₀ ν C₀ C R boundary objects H N tail host live framed before after old old' s inst state inventory budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed bufferLive bufferFixed typedLive typedFixed globalLive globalFixed signatureFrame startNote capture
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, DynamicCall25 using stateNext, retainedNext, instNext continuing_run run initial_relation state

host_assert_retained_schema allocation_to_dynamic_25, 25

noncomputable def DynamicCall55.rules :=
  (Plan1438.rules.zip Plan1438.starts).filterMap (fun entry => if 25 ≤ entry.2 && entry.2 < 55 then some entry.1 else none)

host_retained_theorem allocation_to_dynamic_55 := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (boundary : Nat → Prop) (objects : Nat → Object) (H N : Nat → Prop)
    (tail : List NumV) (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan1438.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C RankOrigin.InitializedCacheSlice.roles boundary objects H N tail host)
      R live framed before after old old' Region1438.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheDynamicSliceAllocationEntry.resultNotes notes caller)
      ν₀ ν C₀ C R live Region1438.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 26) (typedFixed : R.a 26 = 26)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (signatureFrame : ¬ framed Plan1438.Block0.types)
    (startNote : notes.privates.owners 2674420 = some ⟨4852,chars!"handle",.handle 18170⟩)
    (capture : notes.captures.owners 95 = some RankOrigin.InitializedHandleBuffer.constructorMetadata) => by
  have earlier := allocation_to_dynamic_25 notes caller ν₀ ν C₀ C R boundary objects H N tail host live framed before after old old' s inst state inventory budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed bufferLive bufferFixed typedLive typedFixed globalLive globalFixed signatureFrame startNote capture
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, DynamicCall55 using stateNext, retainedNext, instNext continuing_run run initial_relation state

host_assert_retained_schema allocation_to_dynamic_55, 55

noncomputable def DynamicCall76.rules :=
  (Plan1438.rules.zip Plan1438.starts).filterMap (fun entry => if 55 ≤ entry.2 && entry.2 < 76 then some entry.1 else none)

host_retained_theorem allocation_to_dynamic_76 := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (boundary : Nat → Prop) (objects : Nat → Object) (H N : Nat → Prop)
    (tail : List NumV) (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan1438.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C RankOrigin.InitializedCacheSlice.roles boundary objects H N tail host)
      R live framed before after old old' Region1438.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheDynamicSliceAllocationEntry.resultNotes notes caller)
      ν₀ ν C₀ C R live Region1438.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 26) (typedFixed : R.a 26 = 26)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (signatureFrame : ¬ framed Plan1438.Block0.types)
    (startNote : notes.privates.owners 2674420 = some ⟨4852,chars!"handle",.handle 18170⟩)
    (capture : notes.captures.owners 95 = some RankOrigin.InitializedHandleBuffer.constructorMetadata) => by
  have earlier := allocation_to_dynamic_55 notes caller ν₀ ν C₀ C R boundary objects H N tail host live framed before after old old' s inst state inventory budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed bufferLive bufferFixed typedLive typedFixed globalLive globalFixed signatureFrame startNote capture
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, DynamicCall76 using stateNext, retainedNext, instNext continuing_run run initial_relation state

host_assert_retained_schema allocation_to_dynamic_76, 76

noncomputable def DynamicCall95.rules :=
  (Plan1438.rules.zip Plan1438.starts).filterMap (fun entry => if 76 ≤ entry.2 && entry.2 < 95 then some entry.1 else none)

host_retained_theorem allocation_to_dynamic_95 := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (boundary : Nat → Prop) (objects : Nat → Object) (H N : Nat → Prop)
    (tail : List NumV) (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan1438.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C RankOrigin.InitializedCacheSlice.roles boundary objects H N tail host)
      R live framed before after old old' Region1438.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheDynamicSliceAllocationEntry.resultNotes notes caller)
      ν₀ ν C₀ C R live Region1438.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 26) (typedFixed : R.a 26 = 26)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (signatureFrame : ¬ framed Plan1438.Block0.types)
    (startNote : notes.privates.owners 2674420 = some ⟨4852,chars!"handle",.handle 18170⟩)
    (capture : notes.captures.owners 95 = some RankOrigin.InitializedHandleBuffer.constructorMetadata) => by
  have earlier := allocation_to_dynamic_76 notes caller ν₀ ν C₀ C R boundary objects H N tail host live framed before after old old' s inst state inventory budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed bufferLive bufferFixed typedLive typedFixed globalLive globalFixed signatureFrame startNote capture
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  have axisClosed (valuation : Nat → F64) :
      (SymE.lit Plan1438.Block91.sourceValue).eval valuation = Plan1438.Block91.sourceValue := rfl
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, DynamicCall95 using stateNext, retainedNext, instNext continuing_run run initial_relation state

host_assert_retained_schema allocation_to_dynamic_95, 95

noncomputable def DynamicCall111.rules :=
  (Plan1438.rules.zip Plan1438.starts).filterMap (fun entry => if 95 ≤ entry.2 && entry.2 < 111 then some entry.1 else none)

host_retained_theorem allocation_to_dynamic_call := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (boundary : Nat → Prop) (objects : Nat → Object) (H N : Nat → Prop)
    (tail : List NumV) (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan1438.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C RankOrigin.InitializedCacheSlice.roles boundary objects H N tail host)
      R live framed before after old old' Region1438.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheDynamicSliceAllocationEntry.resultNotes notes caller)
      ν₀ ν C₀ C R live Region1438.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 26) (typedFixed : R.a 26 = 26)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (signatureFrame : ¬ framed Plan1438.Block0.types)
    (startNote : notes.privates.owners 2674420 = some ⟨4852,chars!"handle",.handle 18170⟩)
    (capture : notes.captures.owners 95 = some RankOrigin.InitializedHandleBuffer.constructorMetadata) => by
  have earlier := allocation_to_dynamic_95 notes caller ν₀ ν C₀ C R boundary objects H N tail host live framed before after old old' s inst state inventory budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed bufferLive bufferFixed typedLive typedFixed globalLive globalFixed signatureFrame startNote capture
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  have sizeClosed (valuation : Nat → F64) :
      (SymE.lit Plan1438.Block107.sourceValue).eval valuation = Plan1438.Block107.sourceValue := rfl
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, DynamicCall111 using stateNext, retainedNext, instNext continuing_run run initial_relation state

host_assert_retained_schema allocation_to_dynamic_call, 111

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema allocation_to_dynamic_call, 112

end Host.Load.Run.Full.Ordinary.NamespacedDecode
