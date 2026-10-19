import host.load.RuntimeNamespacedDecodePlan1550
import host.ts.renameOrdinary.RankOriginInitializedCacheDynamicSlice

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

noncomputable def DynamicCleanup35.rules :=
  (Plan1550.rules.zip Plan1550.starts).filterMap (fun entry => if 0 ≤ entry.2 && entry.2 < 35 then some entry.1 else none)

host_retained_theorem dynamic_slice_cleanup_35 := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
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
  host_normalize_retained state, inventory
  host_retained_plan_chain P.F, DynamicCleanup35 using state, inventory, inst
host_assert_retained_schema dynamic_slice_cleanup_35, 35

noncomputable def DynamicCleanup72.rules :=
  (Plan1550.rules.zip Plan1550.starts).filterMap (fun entry => if 35 ≤ entry.2 && entry.2 < 72 then some entry.1 else none)

host_retained_theorem dynamic_slice_cleanup_72 := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
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
  have earlier := dynamic_slice_cleanup_35 notes caller ν₀ ν C₀ C R FR live framed before after old old' s inst state inventory budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed globalLive globalFixed
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, DynamicCleanup72 using stateNext, retainedNext, instNext continuing_run run initial_relation state
host_assert_retained_schema dynamic_slice_cleanup_72, 72

noncomputable def DynamicCleanup83.rules :=
  (Plan1550.rules.zip Plan1550.starts).filterMap (fun entry => if 72 ≤ entry.2 && entry.2 < 83 then some entry.1 else none)

host_retained_theorem dynamic_slice_cleanup_83 := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
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
  have earlier := dynamic_slice_cleanup_72 notes caller ν₀ ν C₀ C R FR live framed before after old old' s inst state inventory budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed globalLive globalFixed
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, DynamicCleanup83 using stateNext, retainedNext, instNext continuing_run run initial_relation state
host_assert_retained_schema dynamic_slice_cleanup_83, 83

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema dynamic_slice_cleanup_83, 84

end Host.Load.Run.Full.Ordinary.NamespacedDecode
