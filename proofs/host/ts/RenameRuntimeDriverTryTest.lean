import host.ts.RenameRuntimeDriverTry
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.TryDriver
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def base : St Unit := ⟨PTrie.nil,100,.ret .undef,[],⟨[],(),[],[]⟩⟩
def body : List Stmt := [.decl .const [(.id chars!"saved",some (.lit (.num chars!"7")))]]
def finalizer : Option (List Stmt) := some [.expr (.id chars!"cleanup")]
host_retained_try ffi, base.go (.ex (.try_ body none finalizer) []) using server
  to enterBlock (base.push (.s (.try_ none finalizer []))) body [] using server as LexicalTry

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_try ffi, base.go (.ex (.try_ body none finalizer) []) using server to enterBlock base body [] using server as MissingCleanup"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "try entry lost the cleanup continuation without kernel rejection"
end Host.Ts.Owned.Annotated.Tests.TryDriver
