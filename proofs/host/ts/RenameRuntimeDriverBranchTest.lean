import host.ts.RenameRuntimeDriverBranch
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.BranchDriver
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def base : St Unit := ⟨.nil,100,.ret .undef,[],⟨[],(),[],[]⟩⟩
def yes : Stmt := .expr (.lit (.bool true))
def no : Stmt := .expr (.lit (.bool false))
def input (b : Bool) (other : Option Stmt) : St Unit := (base.push (.s (.if_ yes other []))).ret (.bool b)

host_retained_branch ffi, input true (some no) using server to base.go (.ex yes []) using server as Yes
host_retained_branch ffi, input false (some no) using server to base.go (.ex no []) using server as No
host_retained_branch ffi, input false none using server to base using server as Absent

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_branch ffi, input false (some no) using server to base.go (.ex yes []) using server as WrongBranch"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "wrong boolean branch was not rejected by the kernel"
end Host.Ts.Owned.Annotated.Tests.BranchDriver
