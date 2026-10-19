import host.load.RuntimeNamespacedDecodePlan1770
import host.ts.renameOrdinary.RankOriginInitializedCacheConvolutionEntry
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated Host.Mlx.Ffi.NativeRoles

noncomputable def ConvolutionCall3.rules :=
  [``Null1769.retained_transport] ++ (Plan1770.rules.zip Plan1770.starts).filterMap (fun entry => if 0 ≤ entry.2 && entry.2 < 2 then some entry.1 else none)

host_retained_theorem allocation_to_convolution_3 := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (boundary : Nat → Prop) (objects : Nat → Object) (H N : Nat → Prop)
    (tail : List NumV) (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Null1769.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C RankOrigin.InitializedCacheDynamicFree.roles boundary objects H N tail host)
      R live framed before after old old' At1769.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheConvolutionEntry.resultNotes notes caller)
      ν₀ ν C₀ C R live At1769.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 26) (typedFixed : R.a 26 = 26)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (signatureFrame : ¬ framed Null1769.types)
    (weightNote : notes.privates.owners 329207 = some ⟨4852,chars!"handle",.handle 1365⟩)
    (capture : notes.captures.owners 95 = some RankOrigin.InitializedHandleBuffer.constructorMetadata) => by
  host_normalize_retained state, inventory
  host_retained_plan_chain P.F, ConvolutionCall3 using state, inventory, inst
host_assert_retained_schema allocation_to_convolution_3, 3

noncomputable def ConvolutionCall4.rules :=
  (Plan1770.rules.zip Plan1770.starts).filterMap (fun entry => if 2 ≤ entry.2 && entry.2 < 3 then some entry.1 else none)

host_retained_theorem allocation_to_convolution_4 := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (boundary : Nat → Prop) (objects : Nat → Object) (H N : Nat → Prop)
    (tail : List NumV) (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Null1769.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C RankOrigin.InitializedCacheDynamicFree.roles boundary objects H N tail host)
      R live framed before after old old' At1769.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheConvolutionEntry.resultNotes notes caller)
      ν₀ ν C₀ C R live At1769.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 26) (typedFixed : R.a 26 = 26)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (signatureFrame : ¬ framed Null1769.types)
    (weightNote : notes.privates.owners 329207 = some ⟨4852,chars!"handle",.handle 1365⟩)
    (capture : notes.captures.owners 95 = some RankOrigin.InitializedHandleBuffer.constructorMetadata) => by
  have earlier := allocation_to_convolution_3 notes caller ν₀ ν C₀ C R boundary objects H N tail host live framed before after old old' s inst state inventory budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed bufferLive bufferFixed typedLive typedFixed globalLive globalFixed signatureFrame weightNote capture
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  have room := chain_next_budget_le state stateNext
    (Plan1770.Block1.output.next - At1769.s0.next) 2 64 (2^64)
    (by decide +kernel) (by decide +kernel) budget
  have native := stateNext.native.2
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, ConvolutionCall4 using stateNext, retainedNext, instNext continuing_run run initial_relation state
host_assert_retained_schema allocation_to_convolution_4, 4

noncomputable def ConvolutionCall25.rules :=
  (Plan1770.rules.zip Plan1770.starts).filterMap (fun entry => if 3 ≤ entry.2 && entry.2 < 24 then some entry.1 else none)

host_retained_theorem allocation_to_convolution_25 := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (boundary : Nat → Prop) (objects : Nat → Object) (H N : Nat → Prop)
    (tail : List NumV) (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Null1769.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C RankOrigin.InitializedCacheDynamicFree.roles boundary objects H N tail host)
      R live framed before after old old' At1769.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheConvolutionEntry.resultNotes notes caller)
      ν₀ ν C₀ C R live At1769.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 26) (typedFixed : R.a 26 = 26)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (signatureFrame : ¬ framed Null1769.types)
    (weightNote : notes.privates.owners 329207 = some ⟨4852,chars!"handle",.handle 1365⟩)
    (capture : notes.captures.owners 95 = some RankOrigin.InitializedHandleBuffer.constructorMetadata) => by
  have earlier := allocation_to_convolution_4 notes caller ν₀ ν C₀ C R boundary objects H N tail host live framed before after old old' s inst state inventory budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed bufferLive bufferFixed typedLive typedFixed globalLive globalFixed signatureFrame weightNote capture
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, ConvolutionCall25 using stateNext, retainedNext, instNext continuing_run run initial_relation state
host_assert_retained_schema allocation_to_convolution_25, 25

noncomputable def ConvolutionCall55.rules :=
  (Plan1770.rules.zip Plan1770.starts).filterMap (fun entry => if 24 ≤ entry.2 && entry.2 < 54 then some entry.1 else none)

host_retained_theorem allocation_to_convolution_55 := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (boundary : Nat → Prop) (objects : Nat → Object) (H N : Nat → Prop)
    (tail : List NumV) (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Null1769.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C RankOrigin.InitializedCacheDynamicFree.roles boundary objects H N tail host)
      R live framed before after old old' At1769.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheConvolutionEntry.resultNotes notes caller)
      ν₀ ν C₀ C R live At1769.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 26) (typedFixed : R.a 26 = 26)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (signatureFrame : ¬ framed Null1769.types)
    (weightNote : notes.privates.owners 329207 = some ⟨4852,chars!"handle",.handle 1365⟩)
    (capture : notes.captures.owners 95 = some RankOrigin.InitializedHandleBuffer.constructorMetadata) => by
  have earlier := allocation_to_convolution_25 notes caller ν₀ ν C₀ C R boundary objects H N tail host live framed before after old old' s inst state inventory budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed bufferLive bufferFixed typedLive typedFixed globalLive globalFixed signatureFrame weightNote capture
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, ConvolutionCall55 using stateNext, retainedNext, instNext continuing_run run initial_relation state
host_assert_retained_schema allocation_to_convolution_55, 55

noncomputable def ConvolutionCall76.rules :=
  (Plan1770.rules.zip Plan1770.starts).filterMap (fun entry => if 54 ≤ entry.2 && entry.2 < 75 then some entry.1 else none)

host_retained_theorem allocation_to_convolution_76 := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (boundary : Nat → Prop) (objects : Nat → Object) (H N : Nat → Prop)
    (tail : List NumV) (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Null1769.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C RankOrigin.InitializedCacheDynamicFree.roles boundary objects H N tail host)
      R live framed before after old old' At1769.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheConvolutionEntry.resultNotes notes caller)
      ν₀ ν C₀ C R live At1769.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 26) (typedFixed : R.a 26 = 26)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (signatureFrame : ¬ framed Null1769.types)
    (weightNote : notes.privates.owners 329207 = some ⟨4852,chars!"handle",.handle 1365⟩)
    (capture : notes.captures.owners 95 = some RankOrigin.InitializedHandleBuffer.constructorMetadata) => by
  have earlier := allocation_to_convolution_55 notes caller ν₀ ν C₀ C R boundary objects H N tail host live framed before after old old' s inst state inventory budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed bufferLive bufferFixed typedLive typedFixed globalLive globalFixed signatureFrame weightNote capture
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, ConvolutionCall76 using stateNext, retainedNext, instNext continuing_run run initial_relation state
host_assert_retained_schema allocation_to_convolution_76, 76

noncomputable def ConvolutionCall87.rules :=
  (Plan1770.rules.zip Plan1770.starts).filterMap (fun entry => if 75 ≤ entry.2 && entry.2 < 86 then some entry.1 else none)

host_retained_theorem allocation_to_convolution_call := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (boundary : Nat → Prop) (objects : Nat → Object) (H N : Nat → Prop)
    (tail : List NumV) (host : HostSt → HostSt → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Null1769.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C)
      (VectorHost.NativeRelation ν₀ ν C₀ C RankOrigin.InitializedCacheDynamicFree.roles boundary objects H N tail host)
      R live framed before after old old' At1769.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheConvolutionEntry.resultNotes notes caller)
      ν₀ ν C₀ C R live At1769.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 26) (typedFixed : R.a 26 = 26)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (signatureFrame : ¬ framed Null1769.types)
    (weightNote : notes.privates.owners 329207 = some ⟨4852,chars!"handle",.handle 1365⟩)
    (capture : notes.captures.owners 95 = some RankOrigin.InitializedHandleBuffer.constructorMetadata) => by
  have earlier := allocation_to_convolution_76 notes caller ν₀ ν C₀ C R boundary objects H N tail host live framed before after old old' s inst state inventory budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed bufferLive bufferFixed typedLive typedFixed globalLive globalFixed signatureFrame weightNote capture
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, ConvolutionCall87 using stateNext, retainedNext, instNext continuing_run run initial_relation state
host_assert_retained_schema allocation_to_convolution_call, 87

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema allocation_to_convolution_call, 88
end Host.Load.Run.Full.Ordinary.NamespacedDecode
