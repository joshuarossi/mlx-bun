import host.ts.RenameRuntimeDriverFinally
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.FinallyDriver
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def base : St Unit := ⟨PTrie.nil,100,.ret .undef,[],⟨[],(),[],[]⟩⟩
def fin : List Stmt := [.expr (.lit (.bool true))]
def entry : St Unit := (base.push (.s (.try_ none (some fin) []))).go (.abr (.ret (.obj 50)))
def entered : St Unit := enterBlock (base.push (.s (.finally_ (.abrupt (.ret (.obj 50)))))) fin []
def resume : St Unit := (base.push (.s (.finally_ (.abrupt (.ret (.obj 50)))))).ret (.bool true)
host_retained_finally ffi, entry using server to entered using server as SaveObject
host_retained_finally ffi, resume using server to base.go (.abr (.ret (.obj 50))) using server as ResumeObject

open Lean Elab Command in
run_cmd do
  for command in [
      "host_retained_finally ffi, entry using server to enterBlock base fin [] using server as LostPendingObject",
      "host_retained_finally ffi, resume using server to base.go (.abr (.ret (.bool true))) using server as ReturnedCleanupValue"] do
    let saved : Lean.Elab.Command.State ← get
    let mut rejected := false
    try Parametric.Driver.emit command
    catch exception =>
      let message ← exception.toMessageData.toString
      rejected := (message.splitOn "kernel").length > 1
    for message in (← get).messages.toList do
      let rendered ← message.data.toString
      if (rendered.splitOn "kernel").length > 1 then rejected := true
    set saved
    unless rejected do throwError "cleanup lost or replaced the pending object without kernel rejection"
end Host.Ts.Owned.Annotated.Tests.FinallyDriver
