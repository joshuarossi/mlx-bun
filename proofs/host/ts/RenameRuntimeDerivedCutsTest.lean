import host.ts.RenameRuntimeDerivedCuts
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.DerivedCuts
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def base : St Unit := ⟨.nil,100,.ret .undef,[],⟨[],(),[],[]⟩⟩
def input : St Unit := base.go (.ev (.lit (.bool true)) [])
def nativeInput : St Unit := (base.setObj 1
  ⟨.fn (.native (.ffi .symbol) []),.null,[],[],true⟩).go (.call (.obj 1) .undef [])
host_derive_source_cuts ffi, input using server steps 1 as Literal
example : Literal.s1 = base.ret (.bool true) := by host_kernel_rfl
example : Literal.S1 = server := by host_kernel_rfl

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "theorem wrong_endpoint : Literal.s1 = base.ret (.bool false) := by host_kernel_rfl"
  catch exception =>
    rejected := ((← exception.toMessageData.toString).splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "wrong derived source endpoint was not rejected by kernel"

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_derive_source_cuts ffi, input using server steps 26 as Unbounded"
  catch exception =>
    rejected := ((← exception.toMessageData.toString).splitOn "between 1 and 25").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "between 1 and 25").length > 1 then rejected := true
  set saved
  unless rejected do throwError "unbounded source derivation was accepted"

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_derive_source_cuts ffi, nativeInput using server steps 1 as Native"
  catch exception =>
    rejected := ((← exception.toMessageData.toString).splitOn "requires a materialized cut").length > 1
  for message in (← get).messages.toList do
    if ((← message.data.toString).splitOn "requires a materialized cut").length > 1 then rejected := true
  set saved
  unless rejected do throwError "source derivation attempted an original native symbol"
end Host.Ts.Owned.Annotated.Tests.DerivedCuts
