import host.load.RuntimeNamespacedDecodePlan1362
import host.ts.renameOrdinary.RankOriginInitializedCacheDynamicSliceEntry

set_option Elab.async false
set_option maxRecDepth 1000000
set_option maxHeartbeats 1000000
namespace Host.Load.Run.Full.Ordinary.NamespacedDecode
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open Host.Mlx.Ffi.Annotated

noncomputable def DynamicSlicePrefix.rules :=
  (Plan1362.rules.zip Plan1362.starts).filterMap (fun entry => if entry.2 < 20 then some entry.1 else none)

host_retained_theorem dynamic_slice_20 := fun
    (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan1362.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region1362.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheDynamicSliceEntry.resultNotes notes caller)
      ν₀ ν C₀ C R live Region1362.s0 s)
    (budget : s.next+32 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 21) (typedFixed : R.a 21 = 21)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (streamEntry : notes.runtime.cells.cells Plan1362.Block10.address = some (.handle 2))
    (capture : notes.captures.owners 90 = some RankOrigin.InitialRetained.constructorMetadata) => by
  host_normalize_retained state, inventory
  host_retained_plan_chain P.F, DynamicSlicePrefix using state, inventory, inst

host_assert_retained_schema dynamic_slice_20, 20

host_retained_theorem dynamic_slice_38 := fun
    (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan1362.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region1362.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheDynamicSliceEntry.resultNotes notes caller)
      ν₀ ν C₀ C R live Region1362.s0 s)
    (budget : s.next+32 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 21) (typedFixed : R.a 21 = 21)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (streamEntry : notes.runtime.cells.cells Plan1362.Block10.address = some (.handle 2))
    (capture : notes.captures.owners 90 = some RankOrigin.InitialRetained.constructorMetadata) => by
  have earlier := dynamic_slice_20 notes caller ν₀ ν C₀ C R FR live framed before after old old' s inst state inventory budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed bufferLive bufferFixed typedLive typedFixed globalLive globalFixed streamEntry capture
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  host_retained_chain_after P.F, [Plan1362.Block20.retained_transport, Plan1362.Block21.retained_transport, Plan1362.Block22.retained_transport, Plan1362.Block23.retained_transport, Plan1362.Block24.retained_transport, Plan1362.Block25.retained_transport, Plan1362.Block26.retained_transport, Plan1362.Block27.retained_transport, Plan1362.Block28.retained_transport, Plan1362.Block29.retained_transport, Plan1362.Block30.retained_transport, Plan1362.Block31.retained_transport, Plan1362.Block32.retained_transport, Plan1362.Block33.retained_transport, Plan1362.Block34.retained_transport, Plan1362.Block35.retained_transport, Plan1362.Block36.retained_transport, Plan1362.Block37.retained_transport] using stateNext, retainedNext, instNext continuing_run run initial_relation state

host_assert_retained_schema dynamic_slice_38, 38

host_retained_theorem dynamic_slice_56 := fun
    (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan1362.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region1362.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheDynamicSliceEntry.resultNotes notes caller)
      ν₀ ν C₀ C R live Region1362.s0 s)
    (budget : s.next+32 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 21) (typedFixed : R.a 21 = 21)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (streamEntry : notes.runtime.cells.cells Plan1362.Block10.address = some (.handle 2))
    (capture : notes.captures.owners 90 = some RankOrigin.InitialRetained.constructorMetadata) => by
  have earlier := dynamic_slice_38 notes caller ν₀ ν C₀ C R FR live framed before after old old' s inst state inventory budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed bufferLive bufferFixed typedLive typedFixed globalLive globalFixed streamEntry capture
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  host_retained_chain_after P.F, [Plan1362.Block38.retained_transport, Plan1362.Block39.retained_transport, Plan1362.Block40.retained_transport, Plan1362.Block41.retained_transport, Plan1362.Block42.retained_transport, Plan1362.Block43.retained_transport, Plan1362.Block44.retained_transport, Plan1362.Block45.retained_transport, Plan1362.Block46.retained_transport, Plan1362.Block47.retained_transport, Plan1362.Block48.retained_transport, Plan1362.Block49.retained_transport, Plan1362.Block50.retained_transport, Plan1362.Block51.retained_transport, Plan1362.Block52.retained_transport, Plan1362.Block53.retained_transport, Plan1362.Block54.retained_transport, Plan1362.Block55.retained_transport] using stateNext, retainedNext, instNext continuing_run run initial_relation state

host_assert_retained_schema dynamic_slice_56, 56

host_retained_theorem dynamic_slice_to_allocation := fun
    (notes : RetainedNotes) (caller : List Annotated.Tree)
    (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → P.F.S → P.F.S → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St P.F.S)
    (inst : Inst ν₀ Plan1362.Block0.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Region1362.s0 s)
    (inventory : RetainedInventory (RankOrigin.InitializedCacheDynamicSliceEntry.resultNotes notes caller)
      ν₀ ν C₀ C R live Region1362.s0 s)
    (budget : s.next+32 ≤ 2^64)
    (functionLive : live aFunctionProto) (functionFixed : R.a aFunctionProto = aFunctionProto)
    (objectLive : live aObjectProto) (objectFixed : R.a aObjectProto = aObjectProto)
    (arrayLive : live aArrayProto) (arrayFixed : R.a aArrayProto = aArrayProto)
    (bufferLive : live aArrayBufferProto) (bufferFixed : R.a aArrayBufferProto = aArrayBufferProto)
    (typedLive : live 21) (typedFixed : R.a 21 = 21)
    (globalLive : live aGlobal) (globalFixed : R.a aGlobal = aGlobal)
    (streamEntry : notes.runtime.cells.cells Plan1362.Block10.address = some (.handle 2))
    (capture : notes.captures.owners 90 = some RankOrigin.InitialRetained.constructorMetadata) => by
  have earlier := dynamic_slice_56 notes caller ν₀ ν C₀ C R FR live framed before after old old' s inst state inventory budget functionLive functionFixed objectLive objectFixed arrayLive arrayFixed bufferLive bufferFixed typedLive typedFixed globalLive globalFixed streamEntry capture
  have post := Classical.choose_spec earlier
  have run := post.1
  have stateNext := post.2.1
  have retainedNext := post.2.2.1
  have instNext := post.2.2.2
  host_normalize_retained stateNext, retainedNext
  host_retained_chain_after P.F, [Plan1362.Block56.retained_transport, Plan1362.Block57.retained_transport, Plan1362.Block58.retained_transport, Plan1362.Block59.retained_transport, Plan1362.Block60.retained_transport, Plan1362.Block61.retained_transport, Plan1362.Block62.retained_transport, Plan1362.Block63.retained_transport, Plan1362.Block64.retained_transport, Plan1362.Block65.retained_transport, Plan1362.Block66.retained_transport, Plan1362.Block67.retained_transport, Plan1362.Block68.retained_transport, Plan1362.Block69.retained_transport, Plan1362.Block70.retained_transport, Plan1362.Block71.retained_transport, Plan1362.Block72.retained_transport, Plan1362.Block73.retained_transport, Plan1362.Block74.retained_transport, Plan1362.Block75.retained_transport] using stateNext, retainedNext, instNext continuing_run run initial_relation state

host_assert_retained_schema dynamic_slice_to_allocation, 76

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema dynamic_slice_to_allocation, 77

end Host.Load.Run.Full.Ordinary.NamespacedDecode
