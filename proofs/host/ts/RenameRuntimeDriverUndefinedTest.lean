import host.ts.RenameRuntimeDriverUndefined
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.UndefinedDriver
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated

def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def base : St Unit := ⟨.nil,100,.ret .undef,[],⟨[],(),[],[]⟩⟩
def input : St Unit := base.push (.e (.binR .sne .undef))
def output : St Unit := base.ret (.bool false)
def wrongSource : St Unit := (base.push (.e (.binR .sne .null))).ret .null

host_retained_undefined ffi, input using server to output using server as Checked

open Lean Elab Command in
run_cmd do
  for command in ["host_retained_undefined ffi, input using server to base using server as WrongEndpoint",
      "host_retained_undefined ffi, wrongSource using server to output using server as WrongConstructor"] do
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
    unless rejected do throwError "invalid undefined guard was not rejected by the kernel"
end Host.Ts.Owned.Annotated.Tests.UndefinedDriver
