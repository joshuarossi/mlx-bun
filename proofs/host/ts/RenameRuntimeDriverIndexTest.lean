import host.ts.RenameRuntimeDriverIndex
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.IndexDriver
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[.var 0],[]⟩
def base : St Unit := ⟨PTrie.nil.set 50 (.obj ⟨.array [.big 17,.num (.ref 0)],.obj aArrayProto,[],[],true⟩),
  100,.ret .undef,[],⟨[],(),[],[]⟩⟩
def receiver : St Unit := (base.push (.e (.indexL (.id chars!"index") [] false))).ret (.obj 50)
def key : St Unit := (base.push (.e (.indexR (.obj 50)))).ret (natV 1)
host_retained_index ffi, receiver using server
  to (base.push (.e (.indexR (.obj 50)))).go (.ev (.id chars!"index") []) using server as Receiver
host_retained_index ffi, key using server to base.ret (.num (.ref 0)) using server as Element

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_index ffi, key using server to base.ret (.big 17) using server as WrongElement"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "wrong array element was not rejected by the kernel"
end Host.Ts.Owned.Annotated.Tests.IndexDriver
