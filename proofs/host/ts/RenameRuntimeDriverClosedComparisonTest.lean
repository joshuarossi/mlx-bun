import host.ts.RenameRuntimeDriverClosedComparison
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.ClosedComparisonDriver
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def base : St Unit := ⟨.nil,100,.ret .undef,[],⟨[],(),[],[]⟩⟩
def input (op : BinOp) (a b : Nat) : St Unit := (base.push (.e (.binR op (natV a)))).ret (natV b)

host_retained_closed_comparison ffi, input .lt 0 3 using server to base.ret (.bool true) using server as LoopEnter
host_retained_closed_comparison ffi, input .lt 3 3 using server to base.ret (.bool false) using server as LoopExit
host_retained_closed_comparison ffi, input .sne 3 3 using server to base.ret (.bool false) using server as EqualStrictInequality

theorem arithmetic_closed : (SymE.bin .add (.lit (F64.ofNat 0)) (.lit (F64.ofNat 1))).closed = true := rfl
theorem variable_is_not_closed : (SymE.bin .add (.var 0) (.lit (F64.ofNat 1))).closed = false := rfl

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_closed_comparison ffi, input .lt 3 3 using server to base.ret (.bool true) using server as WrongGuard"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "wrong numeric comparison answer was not rejected by the kernel"
end Host.Ts.Owned.Annotated.Tests.ClosedComparisonDriver
