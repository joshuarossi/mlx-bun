import host.ts.RenameRuntimeDriverCacheGrowth
import host.ts.RenameRuntimeDriverGuardedComparisonTest

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.CacheGrowthDriver
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
open GuardedComparisonDriver

host_retained_cache_growth ffi, input 256 4 using server
  to base.ret (.bool false) using server as NoGrowth
host_retained_cache_growth ffi, input 256 257 using server
  to base.ret (.bool true) using server as FullGrowth
host_retained_cache_growth ffi, input 256 5 using server
  to base.ret (.bool false) using server as ShiftedPhase

host_retained_theorem no_growth_from_ranges := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → Unit → Unit → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St Unit)
    (inst : Inst ν₀ NoGrowth.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' NoGrowth.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live NoGrowth.input s)
    (tail : List Annotated.Tree)
    (controlNote : notes.runtime.control = returnNote (.literal nextIndex))
    (stackNotes : notes.runtime.stack = binaryRightNote .lt (.literal LoopVariables.capacity)::tail)
    (i c : Nat) (indexValue : LoopVariables.cacheIndex.eval ν = F64.ofNat i)
    (capacityValue : LoopVariables.capacity.eval ν = F64.ofNat c)
    (capacityBound : c < 2^31) (fits : i+1 ≤ c) => by
  host_retained_chain ffi, [NoGrowth.retained_transport] using state, inventory, inst
host_assert_retained_schema no_growth_from_ranges, 1

host_retained_theorem growth_from_ranges := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → Unit → Unit → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St Unit)
    (inst : Inst ν₀ FullGrowth.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' FullGrowth.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live FullGrowth.input s)
    (tail : List Annotated.Tree)
    (controlNote : notes.runtime.control = returnNote (.literal nextIndex))
    (stackNotes : notes.runtime.stack = binaryRightNote .lt (.literal LoopVariables.capacity)::tail)
    (c : Nat) (indexValue : LoopVariables.cacheIndex.eval ν = F64.ofNat c)
    (capacityValue : LoopVariables.capacity.eval ν = F64.ofNat c)
    (nextBound : c+1 < 2^31) => by
  host_retained_chain ffi, [FullGrowth.retained_transport] using state, inventory, inst
host_assert_retained_schema growth_from_ranges, 1

host_retained_theorem shifted_phase_from_ranges := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → Unit → Unit → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St Unit)
    (inst : Inst ν₀ ShiftedPhase.initialServer C₀)
    (state : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' ShiftedPhase.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live ShiftedPhase.input s)
    (tail : List Annotated.Tree)
    (controlNote : notes.runtime.control = returnNote (.literal (.bin .add nextIndex (.lit (F64.ofNat 1)))))
    (stackNotes : notes.runtime.stack = binaryRightNote .lt (.literal LoopVariables.capacity)::tail)
    (i c : Nat) (indexValue : nextIndex.eval ν = F64.ofNat i)
    (capacityValue : LoopVariables.capacity.eval ν = F64.ofNat c)
    (capacityBound : c < 2^31) (fits : i+1 ≤ c) => by
  host_retained_chain ffi, [ShiftedPhase.retained_transport] using state, inventory, inst
host_assert_retained_schema shifted_phase_from_ranges, 1

def otherComparison : St Unit := (base.push (.e (.binR .le (natV 256)))).ret (natV 4)
/-- error: host_retained_cache_growth: expected source less-than comparison -/
#guard_msgs in
host_retained_cache_growth ffi, otherComparison using server
  to base.ret (.bool false) using server as RejectOtherComparison

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_cache_growth ffi, input 256 257 using server to base.ret (.bool false) using server as WrongEndpoint"
  catch exception => rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "wrong growth endpoint was not rejected by the kernel"

end Host.Ts.Owned.Annotated.Tests.CacheGrowthDriver
