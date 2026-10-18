import host.ts.RenameRuntimeDriverGuardedComparison
import host.ts.RenameCacheComparisonGuards
import host.ts.RenameRetainedChain

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.GuardedComparisonDriver
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def base : St Unit := ⟨.nil,100,.ret .undef,[],⟨[],(),[],[]⟩⟩
def input (a b : Nat) : St Unit := (base.push (.e (.binR .lt (natV a)))).ret (natV b)
def nextIndex : SymE := .bin .add LoopVariables.cacheIndex (.lit (F64.ofNat 1))

host_retained_guarded_comparison ffi, input 256 4 using server
  to base.ret (.bool false) using server as NoGrowth
host_retained_guarded_comparison ffi, input 256 257 using server
  to base.ret (.bool true) using server as FullGrowth

host_retained_theorem no_growth_transport := fun
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
  have leftNumeric : NumericRole (.literal LoopVariables.capacity) LoopVariables.capacity := .literal _
  have rightNumeric : NumericRole (.literal nextIndex) nextIndex := .literal _
  have guard : F64.test NoGrowth.kind.numOp (LoopVariables.capacity.eval ν) (nextIndex.eval ν) =
      F64.test NoGrowth.kind.numOp NoGrowth.sourceLeft NoGrowth.sourceRight := by
    change F64.test .lt (LoopVariables.capacity.eval ν) (nextIndex.eval ν) = false
    exact CacheGuards.no_growth ν LoopVariables.cacheIndex LoopVariables.capacity i c indexValue capacityValue capacityBound fits
  host_retained_chain ffi, [NoGrowth.retained_transport] using state, inventory, inst
host_assert_retained_schema no_growth_transport, 1

host_retained_theorem full_growth_transport := fun
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
  have leftNumeric : NumericRole (.literal LoopVariables.capacity) LoopVariables.capacity := .literal _
  have rightNumeric : NumericRole (.literal nextIndex) nextIndex := .literal _
  have guard : F64.test FullGrowth.kind.numOp (LoopVariables.capacity.eval ν) (nextIndex.eval ν) =
      F64.test FullGrowth.kind.numOp FullGrowth.sourceLeft FullGrowth.sourceRight := by
    change F64.test .lt (LoopVariables.capacity.eval ν) (nextIndex.eval ν) = true
    exact CacheGuards.full_growth ν LoopVariables.cacheIndex LoopVariables.capacity c indexValue capacityValue nextBound
  host_retained_chain ffi, [FullGrowth.retained_transport] using state, inventory, inst
host_assert_retained_schema full_growth_transport, 1

theorem fill_is_alias (ν : Nat → F64) (indexValue : LoopVariables.cacheIndex.eval ν = F64.ofNat 255)
    (capacityValue : LoopVariables.capacity.eval ν = F64.ofNat 256) :
    F64.test .eq (nextIndex.eval ν) (LoopVariables.capacity.eval ν) = true := by
  have result := CacheGuards.view_alias ν LoopVariables.cacheIndex LoopVariables.capacity 255 256
    indexValue capacityValue (by decide) (by decide)
  exact result.trans (by decide +kernel)

theorem no_growth_not_valid_at_full (ν : Nat → F64) (c : Nat)
    (indexValue : LoopVariables.cacheIndex.eval ν = F64.ofNat c)
    (capacityValue : LoopVariables.capacity.eval ν = F64.ofNat c) (nextBound : c+1 < 2^31) :
    F64.test .lt (LoopVariables.capacity.eval ν) (nextIndex.eval ν) ≠ false := by
  unfold nextIndex
  rw [CacheGuards.full_growth ν LoopVariables.cacheIndex LoopVariables.capacity c indexValue capacityValue nextBound]
  decide

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_guarded_comparison ffi, input 256 257 using server to base.ret (.bool false) using server as WrongGrowthEndpoint"
  catch exception => rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "wrong growth endpoint was not rejected by the kernel"

end Host.Ts.Owned.Annotated.Tests.GuardedComparisonDriver
