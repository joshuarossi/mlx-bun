import host.load.RuntimeDynamicDisposedStore
import host.load.RuntimeNamespacedDecodeDynamicSliceWrapper
import host.ts.RenameRuntimeStaticCall
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

theorem cleanup_call : Plan1550.Block83.input.ctl = .call (.obj 4883) (.obj 3126785) [] := by host_kernel_rfl

noncomputable def DynamicCleanup95.rules :=
  (Plan1550.rules.zip Plan1550.starts).filterMap (fun entry => if 83 ≤ entry.2 && entry.2 < 95 then some entry.1 else none)

host_retained_theorem dynamic_slice_cleanup_95 := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan1550.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region1550.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheDynamicSlice.resultNotes notes caller)
      ν₀ ν C₀ C R live Region1550.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal) => by
  have earlier := dynamic_slice_cleanup_83 notes caller ν₀ ν C₀ C R FR live framed before after old old' s inst state inventory budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed globalLive globalFixed
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  have controlNote := retainedNext.runtime.object_call_note 4883 3126785 cleanup_call
  host_retained_plan_chain_after P.F, DynamicCleanup95 using stateNext, retainedNext, instNext continuing_run run initial_relation state
host_assert_retained_schema dynamic_slice_cleanup_95, 95

noncomputable def DynamicCleanup115.rules :=
  (Plan1550.rules.zip Plan1550.starts).filterMap (fun entry => if 95 ≤ entry.2 && entry.2 < 115 then some (if entry.2 == 105 then ``DisposedStore.retained_transport else entry.1) else none)

host_retained_theorem dynamic_slice_cleanup_115 := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan1550.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region1550.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheDynamicSlice.resultNotes notes caller)
      ν₀ ν C₀ C R live Region1550.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal) => by
  have earlier := dynamic_slice_cleanup_95 notes caller ν₀ ν C₀ C R FR live framed before after old old' s inst state inventory budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed globalLive globalFixed
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, DynamicCleanup115 using stateNext, retainedNext, instNext continuing_run run initial_relation state
host_assert_retained_schema dynamic_slice_cleanup_115, 115

noncomputable def DynamicCleanup127.rules :=
  (Plan1550.rules.zip Plan1550.starts).filterMap (fun entry => if 115 ≤ entry.2 && entry.2 < 127 then some entry.1 else none)

host_retained_theorem dynamic_slice_to_free := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan1550.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region1550.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheDynamicSlice.resultNotes notes caller)
      ν₀ ν C₀ C R live Region1550.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal) => by
  have earlier := dynamic_slice_cleanup_115 notes caller ν₀ ν C₀ C R FR live framed before after old old' s inst state inventory budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed globalLive globalFixed
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, DynamicCleanup127 using stateNext, retainedNext, instNext continuing_run run initial_relation state
host_assert_retained_schema dynamic_slice_to_free, 127

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema dynamic_slice_to_free, 128

end Host.Load.Run.Full.Ordinary.NamespacedDecode
