import host.ts.RenameRuntimeDriverNumberNull

set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.NumberNull
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def base : St Unit := ⟨.nil,100,.ret .undef,[],⟨[],(),[],[]⟩⟩
def input (value : NumV) : St Unit := (base.push (.e (.binR .seq (.num value)))).ret .null
def output : St Unit := base.ret (.bool false)

host_retained_number_null ffi, input (.lit (F64.ofNat 64)) using server to output using server as Literal
/- Strict type comparison does not resolve this absent numeric reference. -/
host_retained_number_null ffi, input (.ref 999) using server to output using server as Reference

/-- error: host_retained_number_null: expected returned null -/
#guard_msgs in
host_retained_number_null ffi, base using server to output using server as WrongType

/-- error: host_retained_number_null: expected strict equality -/
#guard_msgs in
host_retained_number_null ffi, (base.push (.e (.binR .eq (.num (.ref 999))))).ret .null
  using server to output using server as LooseEquality

open Lean Elab Command in
run_cmd do
  let saved : Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_number_null ffi, input (.ref 999) using server to base.ret (.bool true) using server as WrongAnswer"
  catch exception => rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "incorrect strict number/null result was not rejected by the kernel"

end Host.Ts.Owned.Annotated.Tests.NumberNull
