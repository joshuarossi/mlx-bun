import host.load.RuntimeNamespacedDecodePlan1678
import host.ts.renameOrdinary.RankOriginInitializedCacheDynamicFree
set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

noncomputable def ConvolutionEntry30.rules :=
  (Plan1678.rules.zip Plan1678.starts).filterMap (fun entry => if 0 ≤ entry.2 && entry.2 < 30 then some entry.1 else none)

host_retained_theorem convolution_entry_30 := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan1678.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region1678.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheDynamicFree.resultNotes notes caller)
      ν₀ ν C₀ C R live Region1678.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (streamEntry : notes.runtime.cells.cells Plan1678.Block47.address = some (.handle 2)) => by
  host_normalize_retained state, inventory
  host_retained_plan_chain P.F, ConvolutionEntry30 using state, inventory, inst
host_assert_retained_schema convolution_entry_30, 30

noncomputable def ConvolutionEntry60.rules :=
  (Plan1678.rules.zip Plan1678.starts).filterMap (fun entry => if 30 ≤ entry.2 && entry.2 < 60 then some entry.1 else none)

host_retained_theorem convolution_entry_60 := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan1678.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region1678.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheDynamicFree.resultNotes notes caller)
      ν₀ ν C₀ C R live Region1678.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (streamEntry : notes.runtime.cells.cells Plan1678.Block47.address = some (.handle 2)) => by
  have earlier := convolution_entry_30 notes caller ν₀ ν C₀ C R FR live framed before after old old' s inst state inventory budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed globalLive globalFixed streamEntry
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, ConvolutionEntry60 using stateNext, retainedNext, instNext continuing_run run initial_relation state
host_assert_retained_schema convolution_entry_60, 60

noncomputable def ConvolutionEntry91.rules :=
  (Plan1678.rules.zip Plan1678.starts).filterMap (fun entry => if 60 ≤ entry.2 && entry.2 < 91 then some entry.1 else none)

host_retained_theorem convolution_to_allocation := fun (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan1678.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region1678.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheDynamicFree.resultNotes notes caller)
      ν₀ ν C₀ C R live Region1678.s0 s)
    (budget : s.next+64 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (streamEntry : notes.runtime.cells.cells Plan1678.Block47.address = some (.handle 2)) => by
  have earlier := convolution_entry_60 notes caller ν₀ ν C₀ C R FR live framed before after old old' s inst state inventory budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed globalLive globalFixed streamEntry
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  host_retained_plan_chain_after P.F, ConvolutionEntry91 using stateNext, retainedNext, instNext continuing_run run initial_relation state
host_assert_retained_schema convolution_to_allocation, 91

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema convolution_to_allocation, 92
end Host.Load.Run.Full.Ordinary.NamespacedDecode
