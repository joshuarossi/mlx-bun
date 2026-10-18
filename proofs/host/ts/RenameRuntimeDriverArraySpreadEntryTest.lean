import host.ts.RenameRuntimeDriverArraySpreadEntry
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.ArraySpreadEntry
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def expression : Expr := .id chars!"shape"
def env : Env := [(chars!"shape",50)]
def base : St Unit := ⟨PTrie.nil,100,.ret .undef,[],⟨[],(),[],[]⟩⟩
def input (rest : List Elem) : St Unit := base.go (.ev (.array (.spread expression::rest)) env)
def output (rest : List Elem) : St Unit := (base.push (.l (.spread [] rest env))).go (.ev expression env)

host_retained_array_spread_entry ffi, input [] using server to output [] using server as Final
host_retained_array_spread_entry ffi, input [.expr (.lit (.bool true))] using server
  to output [.expr (.lit (.bool true))] using server as Followed

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_array_spread_entry ffi, input [] using server to base.go (.ev expression env) using server as MissingSpreadFrame"
  catch exception =>
    rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "missing spread continuation was not rejected by the kernel"
end Host.Ts.Owned.Annotated.Tests.ArraySpreadEntry
