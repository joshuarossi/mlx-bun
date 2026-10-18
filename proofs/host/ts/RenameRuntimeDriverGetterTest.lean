import host.ts.RenameRuntimeDriverGetter
set_option Elab.async false
namespace Host.Ts.Owned.Annotated.Tests.GetterDriver
open Host.Ts Host.Ts.Owned Host.Ts.Owned.Parametric Host.Ts.Owned.Annotated
def ffi : Ffi := ⟨Unit,fun _ _ _ => .fail "unused",fun _ _ _ _ => none,fun _ => 4096,fun _ _ => .pure none⟩
def server : SSrv := ⟨[],[]⟩
def base : St Unit := ⟨(PTrie.nil.set 50 (.obj ⟨.ordinary,.obj 51,[],[],true⟩)).set 51
  (.obj ⟨.ordinary,.null,[(.str chars!"handle",.acc (.obj 52) .undef false)],[],true⟩),
  100,.ret .undef,[],⟨[],(),[],[]⟩⟩
def source : St Unit := (base.push (.e (.member (.str chars!"handle") false))).ret (.obj 50)
def target : St Unit := base.go (.call (.obj 52) (.obj 50) [])
host_retained_getter ffi, source using server to target using server as Getter

open Lean Elab Command in
run_cmd do
  let saved : Lean.Elab.Command.State ← get
  let mut rejected := false
  try Parametric.Driver.emit "host_retained_getter ffi, source using server to base.go (.call (.obj 52) (.obj 51) []) using server as WrongReceiver"
  catch exception =>
    let message ← exception.toMessageData.toString
    rejected := (message.splitOn "kernel").length > 1
  for message in (← get).messages.toList do
    let rendered ← message.data.toString
    if (rendered.splitOn "kernel").length > 1 then rejected := true
  set saved
  unless rejected do throwError "getter invoked on the prototype instead of the original receiver was not rejected by the kernel"
end Host.Ts.Owned.Annotated.Tests.GetterDriver
