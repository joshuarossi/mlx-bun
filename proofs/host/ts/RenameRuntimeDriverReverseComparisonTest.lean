import host.ts.RenameRuntimeDriverReverseComparison
import host.ts.RenameRetainedChain
import host.ts.RenameCacheComparisonGuards
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.ReverseComparison
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def base : St Unit := ⟨.nil,100,.ret .undef,[],⟨[],(),[],[]⟩⟩
def input (op : BinOp) (a b : Nat) : St Unit :=
  (base.push (.e (.binR op (.num (.lit (F64.ofNat a)))))).ret (.num (.lit (F64.ofNat b)))
host_retained_closed_reverse_comparison ffi, input .gt 3 2 using server to base.ret (.bool true) using server as Greater
host_retained_closed_reverse_comparison ffi, input .ge 3 3 using server to base.ret (.bool true) using server as GreaterEqual
host_retained_closed_reverse_comparison ffi, input .gt 2 3 using server to base.ret (.bool false) using server as Smaller

host_retained_theorem greater_complete := fun
    (notes : RetainedNotes) (ν₀ ν : Nat → F64) (C₀ C : CSrv) (R : Ren)
    (FR : Ren → Unit → Unit → Prop) (live framed : Nat → Prop)
    (before after : List Val) (old old' : List Event) (s : St Unit)
    (inst : Inst ν₀ Greater.initialServer C₀)
    (h : Parametric.StateR (NumberRoles ν₀ ν C₀ C) FR R live framed before after old old' Greater.input s)
    (inventory : RetainedInventory notes ν₀ ν C₀ C R live Greater.input s)
    (ea eb : SymE) (tail : List Annotated.Tree)
    (controlNote : notes.runtime.control = returnNote (.literal eb))
    (stackNotes : notes.runtime.stack = binaryRightNote .gt (.literal ea)::tail)
    (leftClosed : ea.closed = true) (rightClosed : eb.closed = true) => by
  host_retained_chain ffi, [Greater.retained_transport] using h, inventory, inst
host_assert_retained_schema greater_complete, 1

/-- error: retained batch schema: target run has the wrong step count -/
#guard_msgs in
host_assert_retained_schema greater_complete, 2

/-- Pure range guards for varying current meanings, suitable for the generic
reverse comparison rule without an execution or target-value premise. -/
theorem varying_positive (ν₀ ν : Nat → F64) (meaning : SymE) (n m : Nat)
    (sourceValue : meaning.eval ν₀ = F64.ofNat n) (targetValue : meaning.eval ν = F64.ofNat m)
    (sourceBound : n < 2^31) (targetBound : m < 2^31) (sourcePositive : 0 < n) (targetPositive : 0 < m) :
    F64.test .lt ((SymE.lit (F64.ofNat 0)).eval ν₀) (meaning.eval ν₀) = true ∧
    F64.test .lt ((SymE.lit (F64.ofNat 0)).eval ν) (meaning.eval ν) = true := by
  constructor
  · rw [CacheGuards.less_than ν₀ (.lit (F64.ofNat 0)) meaning 0 n rfl sourceValue (by omega) sourceBound]
    exact decide_eq_true sourcePositive
  · rw [CacheGuards.less_than ν (.lit (F64.ofNat 0)) meaning 0 m rfl targetValue (by omega) targetBound]
    exact decide_eq_true targetPositive

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_closed_reverse_comparison ffi, input .gt 3 2 using server to base.ret (.bool false) using server as WrongDirection"
  catch exception =>
    rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "reversing greater-comparison result was not rejected by kernel"
end Host.Ts.Owned.Annotated.Tests.ReverseComparison
