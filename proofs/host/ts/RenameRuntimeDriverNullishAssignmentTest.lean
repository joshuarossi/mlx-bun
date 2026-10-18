import host.ts.RenameRuntimeDriverNullishAssignment
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.NullishAssignment
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def base : St Unit := ⟨.nil,100,.ret .undef,[],⟨[],(),[],[]⟩⟩
def rhs : Expr := .lit (.num ['9'])
def input : St Unit := (base.push (.a (.old (.log .nullish) (.var ['x'] []) rhs []))).ret (.obj 23)
host_retained_nullish_object ffi, input using server to base.ret (.obj 23) using server as Existing

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_nullish_object ffi, input using server to base.go (.ev rhs []) using server as WrongRhs"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "executing skipped nullish RHS was not rejected by kernel"

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_nullish_object ffi, input.ret .undef using server to base.ret .undef using server as WrongConstructor"
  catch _ => rejected := true
  for message in (← get).messages.toList do
    if message.severity == .error then rejected := true
  set saved
  unless rejected do throwError "nullish object frontend accepted undefined"
end Host.Ts.Owned.Annotated.Tests.NullishAssignment
