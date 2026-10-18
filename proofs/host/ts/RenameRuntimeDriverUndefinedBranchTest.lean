import host.ts.RenameRuntimeDriverUndefinedBranch
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.UndefinedBranch
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def base : St Unit := ⟨PTrie.nil,100,.ret .undef,[],⟨[],(),[],[]⟩⟩
def yes : Stmt := .expr (.id chars!"present")
def no : Stmt := .expr (.id chars!"absent")
host_retained_undefined_branch ffi, (base.push (.s (.if_ yes none []))).ret .undef using server
  to base.ret .undef using server as WithoutElse
host_retained_undefined_branch ffi, (base.push (.s (.if_ yes (some no) []))).ret .undef using server
  to base.go (.ex no []) using server as WithElse

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_undefined_branch ffi, (base.push (.s (.if_ yes (some no) []))).ret .undef using server to base.go (.ex yes []) using server as WrongTruthiness"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "undefined selected a true branch without kernel rejection"
end Host.Ts.Owned.Annotated.Tests.UndefinedBranch
