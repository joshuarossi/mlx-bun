import host.ts.RenameRuntimeDriverArrayLength
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.ArrayLengthDriver
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def base : St Unit := ⟨PTrie.nil.set 50 (.obj ⟨.array [.big 17,natV 3],.obj aArrayProto,[],[],true⟩),
  100,.ret .undef,[],⟨[],(),[],[]⟩⟩
def input (opt : Bool) : St Unit := (base.push (.e (.member kLength opt))).ret (.obj 50)

host_retained_array_length ffi, input false using server to base.ret (natV 2) using server as Required
host_retained_array_length ffi, input true using server to base.ret (natV 2) using server as Optional

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_array_length ffi, input false using server to base.ret (natV 3) using server as WrongLength"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "wrong retained length result was not rejected by the kernel"
end Host.Ts.Owned.Annotated.Tests.ArrayLengthDriver
